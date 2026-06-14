// lib/features/auth/repositories/auth_repository.dart
import 'package:to_best/features/auth/models/user_model.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';
import 'package:to_best/services/secure_storage_service.dart';
import 'package:to_best/core/errors/app_error.dart';

class AuthRepository {
  final _api     = ApiService.instance;
  final _cache   = CacheService.instance;
  final _storage = SecureStorageService.instance;

  // ── Login ─────────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    final res = await _api.login(email, password);

    if (res == null) {
      throw AppError.fromCode('network');
    }

    if (res['ok'] != true) {
      final code = res['error']?.toString() ?? 'unknown';
      throw AppError.fromCode(code);
    }

    final userData = res['user'] as Map<String, dynamic>?;
    if (userData == null) {
      throw const AppError(
          type: AppErrorType.server, message: 'بيانات المستخدم غير صحيحة');
    }

    final user = UserModel.fromJson(userData);

    // Save session token
    final token = res['sessionToken']?.toString() ?? user.sessionToken ?? '';
    if (token.isNotEmpty) {
      await _storage.saveSessionToken(token);
    }

    // Cache user
    await _cache.saveCurrentUser(user.toJson());
    return user;
  }

  // ── Register ──────────────────────────────────────────────
  Future<UserModel?> register(Map<String, dynamic> data) async {
    final res = await _api.register(data);
    if (res == null || res['ok'] != true) {
      final code = res?['error']?.toString() ?? 'unknown';
      throw AppError.fromCode(code);
    }
    final userData = res['user'] as Map<String, dynamic>?;
    if (userData == null) return null;
    final user = UserModel.fromJson(userData);
    await _cache.saveCurrentUser(user.toJson());
    return user;
  }

  // ── Guest Login ───────────────────────────────────────────
  Future<UserModel?> guestLogin(String code) async {
    final res = await _api.guestLogin(code);
    if (res == null || res['ok'] != true) {
      final code2 = res?['error']?.toString() ?? 'unknown';
      throw AppError.fromCode(code2);
    }
    final userData = res['user'] as Map<String, dynamic>?;
    if (userData == null) return null;
    final user = UserModel.fromJson(userData);
    await _cache.saveCurrentUser(user.toJson());
    return user;
  }

  // ── Load cached user ──────────────────────────────────────
  Future<UserModel?> loadCachedUser() async {
    final data = await _cache.getCurrentUser();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.clearSessionToken();
    await _cache.clearCurrentUser();
  }

  // ── Check force logout ────────────────────────────────────
  Future<bool> checkForceLogout(UserModel user) async {
    try {
      final res = await _api.fetchUserData(user.uid);
      if (res == null) return false;
      final serverToken = res['forceLogoutToken']?.toString();
      if (serverToken == null || serverToken.isEmpty) return false;
      final seenToken = await _cache.getSetting('force_logout_seen_${user.uid}');
      if (seenToken == serverToken) return false;
      // Different token — force logout
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markForceLogoutSeen(String uid, String token) async {
    await _cache.saveSetting('force_logout_seen_$uid', token);
  }

  // ── Refresh user data ──────────────────────────────────────
  Future<UserModel?> refreshUser(String uid) async {
    try {
      final data = await _api.fetchUserData(uid);
      if (data == null) return null;
      final user = UserModel.fromJson(data);
      await _cache.saveCurrentUser(user.toJson());
      return user;
    } catch (_) {
      return null;
    }
  }
}
