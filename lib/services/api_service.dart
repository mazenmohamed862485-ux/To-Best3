// lib/services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:to_best/services/secure_storage_service.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/errors/app_error.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      sendTimeout:    Duration(seconds: AppConstants.apiTimeoutSeconds),
      contentType: 'application/x-www-form-urlencoded',
    ),
  );

  // ── Core POST (form-encoded, same as web app, avoids CORS preflight) ──
  Future<Map<String, dynamic>?> _post(
    Map<String, dynamic> payload, {
    bool public = false,
  }) async {
    final url = await SecureStorageService.instance.getWebAppUrl();
    if (url == null || url.isEmpty) {
      throw AppError.fromCode('not_configured');
    }

    final secretKey = await SecureStorageService.instance.getSecretKey();
    final sessionToken = await SecureStorageService.instance.getSessionToken();

    final fullPayload = {
      ...payload,
      if (secretKey != null && secretKey.isNotEmpty) 'secret': secretKey,
      if (!public && sessionToken != null && sessionToken.isNotEmpty)
        'sessionToken': sessionToken,
    };

    // Encode all values as strings for form-urlencoded
    final encoded = <String, String>{};
    for (final entry in fullPayload.entries) {
      final v = entry.value;
      if (v is String) {
        encoded[entry.key] = v;
      } else if (v is Map || v is List) {
        encoded[entry.key] = jsonEncode(v);
      } else {
        encoded[entry.key] = v.toString();
      }
    }

    try {
      final res = await _dio.post(
        url,
        data: Uri(queryParameters: encoded).query,
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        // Store new session token if returned
        final newToken = data['sessionToken']?.toString();
        if (newToken != null && newToken.isNotEmpty) {
          await SecureStorageService.instance.saveSessionToken(newToken);
        }
        return data;
      }

      // Try to parse if string
      if (res.data is String) {
        try {
          final parsed = jsonDecode(res.data as String);
          if (parsed is Map<String, dynamic>) return parsed;
        } catch (_) {}
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw AppError.fromCode('network');
      }
      rethrow;
    }
  }

  // ── Auth ─────────────────────────────────────────────────
  Future<Map<String, dynamic>?> login(String email, String password) async {
    return _post({'action': 'LOGIN', 'email': email, 'password': password},
        public: true);
  }

  Future<Map<String, dynamic>?> register(Map<String, dynamic> data) async {
    return _post({'action': 'REGISTER', ...data}, public: true);
  }

  Future<bool> forgotPassword(String email) async {
    final res = await _post(
        {'action': 'FORGOT_PASSWORD', 'email': email}, public: true);
    return res?['ok'] == true;
  }

  Future<bool> resetPassword(String email, String code, String newPwd) async {
    final res = await _post({
      'action': 'RESET_PASSWORD',
      'email': email, 'code': code, 'newPassword': newPwd,
    }, public: true);
    return res?['ok'] == true;
  }

  Future<bool> changePassword(String uid, String oldPwd, String newPwd) async {
    final res = await _post({
      'action': 'CHANGE_PASSWORD', 'uid': uid,
      'oldPassword': oldPwd, 'newPassword': newPwd,
    });
    return res?['ok'] == true;
  }

  Future<Map<String, dynamic>?> guestLogin(String code) async {
    return _post({'action': 'GUEST_LOGIN', 'code': code}, public: true);
  }

  Future<bool> ping() async {
    try {
      final res = await _post({'action': 'PING'});
      return res?['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkBan(
      String email, String? phone) async {
    return _post(
        {'action': 'CHECK_BAN', 'email': email, 'phone': phone ?? ''},
        public: true);
  }

  // ── Version Check ─────────────────────────────────────────
  Future<Map<String, dynamic>?> checkVersion(
      String version, int buildNumber) async {
    try {
      return _post({
        'action': 'CHECK_VERSION',
        'version': version,
        'build': buildNumber,
      }, public: true);
    } catch (_) {
      return null;
    }
  }

  // ── User Data ─────────────────────────────────────────────
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    final res = await _post({'action': 'FETCH_USER_DATA', 'uid': uid});
    return res?['ok'] == true
        ? res?['data'] as Map<String, dynamic>?
        : null;
  }

  Future<List<Map<String, dynamic>>?> fetchAllUsers() async {
    final res = await _post({'action': 'FETCH_ALL_USERS'});
    if (res?['ok'] != true) return null;
    return (res!['users'] as List?)?.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> fullSyncPull(String uid) async {
    final res = await _post({'action': 'FULL_SYNC_PULL', 'uid': uid});
    return res?['ok'] == true
        ? res?['data'] as Map<String, dynamic>?
        : null;
  }

  Future<bool> pushData(Map<String, dynamic> payload) async {
    try {
      final res = await _post(payload);
      return res?['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── Admin ─────────────────────────────────────────────────
  Future<bool> adminUpdateUser(
      String uid, Map<String, dynamic> fields) async {
    final res = await _post(
        {'action': 'ADMIN_UPDATE_USER', 'uid': uid, 'fields': fields});
    return res?['ok'] == true;
  }

  Future<bool> adminApprove(String uid, bool approved) async {
    final res = await _post(
        {'action': 'ADMIN_APPROVE', 'uid': uid, 'approved': approved});
    return res?['ok'] == true;
  }

  Future<bool> adminDeleteUser(String uid) async {
    final res =
        await _post({'action': 'ADMIN_DELETE_USER', 'uid': uid});
    return res?['ok'] == true;
  }

  Future<bool> approveProgram(
      String uid, String programId, int programDays) async {
    final res = await _post({
      'action': 'APPROVE_PROGRAM', 'uid': uid,
      'programId': programId, 'programDays': programDays,
    });
    return res?['ok'] == true;
  }

  // ── Chat ──────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchMessages(
      String roomId, int since) async {
    final res = await _post(
        {'action': 'FETCH_MSGS', 'roomId': roomId, 'since': since});
    if (res?['ok'] != true) return [];
    return (res!['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<bool> sendMessage(
      String roomId, Map<String, dynamic> msg) async {
    final res = await _post(
        {'action': 'SEND_MSG', 'roomId': roomId, 'msg': msg});
    return res?['ok'] == true;
  }

  Future<bool> deleteMessage(String roomId, String msgId) async {
    final res = await _post(
        {'action': 'DELETE_MSG', 'roomId': roomId, 'msgId': msgId});
    return res?['ok'] == true;
  }

  Future<bool> editMessage(
      String roomId, String msgId, String newText) async {
    final res = await _post({
      'action': 'EDIT_MSG',
      'roomId': roomId, 'msgId': msgId, 'newText': newText,
    });
    return res?['ok'] == true;
  }

  Future<bool> pinMessage(
      String roomId, Map<String, dynamic> msg) async {
    final res = await _post(
        {'action': 'PIN_MSG', 'roomId': roomId, 'msg': msg});
    return res?['ok'] == true;
  }

  Future<Map<String, dynamic>?> fetchPinnedMessage(String roomId) async {
    final res =
        await _post({'action': 'GET_PINNED', 'roomId': roomId});
    return res?['ok'] == true
        ? res?['pinned'] as Map<String, dynamic>?
        : null;
  }

  // ── Subscription ──────────────────────────────────────────
  Future<bool> submitSubscriptionPayment(
      String uid, Map<String, dynamic> data) async {
    final res = await _post(
        {'action': 'SUB_REQUEST', 'uid': uid, 'data': data});
    return res?['ok'] == true;
  }

  Future<List<Map<String, dynamic>>> getSubscriptionRequests() async {
    final res = await _post({'action': 'GET_SUB_REQUESTS'});
    if (res?['ok'] != true) return [];
    return (res!['requests'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<bool> updateSubscriptionRequest(
      String id, String status, Map<String, dynamic> fields) async {
    final res = await _post({
      'action': 'UPDATE_SUB_REQUEST',
      'id': id, 'status': status, 'fields': fields,
    });
    return res?['ok'] == true;
  }

  // ── Promo codes ───────────────────────────────────────────
  Future<Map<String, dynamic>?> checkPromo(String code) async {
    return _post({'action': 'PROMO_CHECK', 'code': code});
  }

  Future<bool> createPromo(
      String code, double discount, int maxUses) async {
    final res = await _post({
      'action': 'PROMO_CREATE',
      'code': code, 'discount': discount, 'maxUses': maxUses,
    });
    return res?['ok'] == true;
  }

  Future<Map<String, dynamic>?> listPromos() async {
    return _post({'action': 'PROMO_LIST'});
  }

  Future<bool> deletePromo(String code) async {
    final res =
        await _post({'action': 'PROMO_DELETE', 'code': code});
    return res?['ok'] == true;
  }

  // ── Guest codes ───────────────────────────────────────────
  Future<bool> createGuestCode(String code) async {
    final res =
        await _post({'action': 'GUEST_CREATE', 'code': code});
    return res?['ok'] == true;
  }

  Future<Map<String, dynamic>?> listGuestCodes() async {
    return _post({'action': 'GUEST_LIST'});
  }

  Future<bool> deleteGuestCode(String code) async {
    final res =
        await _post({'action': 'GUEST_DELETE', 'code': code});
    return res?['ok'] == true;
  }

  // ── Identity Ban ──────────────────────────────────────────
  Future<bool> banIdentity(Map<String, dynamic> banEntry) async {
    final res =
        await _post({'action': 'BAN_IDENTITY', 'banEntry': banEntry});
    return res?['ok'] == true;
  }

  Future<bool> unbanIdentity(String banId) async {
    final res =
        await _post({'action': 'UNBAN_IDENTITY', 'banId': banId});
    return res?['ok'] == true;
  }

  Future<Map<String, dynamic>?> listBanned() async {
    return _post({'action': 'LIST_BANNED'});
  }

  // ── Force Logout ──────────────────────────────────────────
  Future<bool> forceLogoutUser(String uid, String token) async {
    final res = await _post(
        {'action': 'FORCE_LOGOUT_USER', 'uid': uid, 'token': token});
    return res?['ok'] == true;
  }

  Future<bool> forceLogoutAll(String token) async {
    final res =
        await _post({'action': 'FORCE_LOGOUT_ALL', 'token': token});
    return res?['ok'] == true;
  }

  // ── Profile Picture ───────────────────────────────────────
  Future<Map<String, dynamic>?> saveProfilePicture(
      String uid, String imageData) async {
    return _post({'action': 'SAVE_PROFILE_PIC', 'uid': uid, 'imageData': imageData});
  }

  // ── Referral Stats ────────────────────────────────────────
  Future<Map<String, dynamic>?> getReferralStats(String code) async {
    return _post({'action': 'GET_REFERRAL_STATS', 'code': code});
  }

  // ── Settings ──────────────────────────────────────────────
  Future<bool> saveSetting(String key, dynamic value) async {
    final res =
        await _post({'action': 'SETTING', 'key': key, 'data': value});
    return res?['ok'] == true;
  }
}
