// lib/features/admin/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/auth/models/user_model.dart';
import 'package:to_best/services/api_service.dart';

class AdminState {
  final List<UserModel>            users;
  final List<Map<String, dynamic>> subRequests;
  final List<Map<String, dynamic>> promoCodes;
  final List<Map<String, dynamic>> guestCodes;
  final List<Map<String, dynamic>> bannedList;
  final bool                       loading;
  final String?                    error;

  const AdminState({
    this.users       = const [],
    this.subRequests = const [],
    this.promoCodes  = const [],
    this.guestCodes  = const [],
    this.bannedList  = const [],
    this.loading     = false,
    this.error,
  });

  AdminState copyWith({
    List<UserModel>?            users,
    List<Map<String, dynamic>>? subRequests,
    List<Map<String, dynamic>>? promoCodes,
    List<Map<String, dynamic>>? guestCodes,
    List<Map<String, dynamic>>? bannedList,
    bool?                       loading,
    String?                     error,
    bool                        clearError = false,
  }) =>
      AdminState(
        users:       users       ?? this.users,
        subRequests: subRequests ?? this.subRequests,
        promoCodes:  promoCodes  ?? this.promoCodes,
        guestCodes:  guestCodes  ?? this.guestCodes,
        bannedList:  bannedList  ?? this.bannedList,
        loading:     loading     ?? this.loading,
        error:       clearError ? null : (error ?? this.error),
      );
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  final _api = ApiService.instance;

  // ── Users ─────────────────────────────────────────────────
  Future<void> loadUsers() async {
    state = state.copyWith(loading: true);
    try {
      final list = await _api.fetchAllUsers();
      if (list != null) {
        final users = list.map((u) => UserModel.fromJson(u)).toList();
        state = state.copyWith(users: users, loading: false);
      } else {
        state = state.copyWith(loading: false);
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> approveUser(String uid, bool approved) async {
    final ok = await _api.adminApprove(uid, approved);
    if (ok) await loadUsers();
    return ok;
  }

  Future<bool> deleteUser(String uid) async {
    final ok = await _api.adminDeleteUser(uid);
    if (ok) await loadUsers();
    return ok;
  }

  Future<bool> updateUser(String uid, Map<String, dynamic> fields) async {
    final ok = await _api.adminUpdateUser(uid, fields);
    if (ok) await loadUsers();
    return ok;
  }

  Future<bool> approveProgram(
      String uid, String programId, int programDays) async {
    return _api.approveProgram(uid, programId, programDays);
  }

  Future<bool> forceLogoutUser(String uid, String token) async {
    return _api.forceLogoutUser(uid, token);
  }

  Future<bool> forceLogoutAll(String token) async {
    return _api.forceLogoutAll(token);
  }

  // ── Subscriptions ─────────────────────────────────────────
  Future<void> loadSubRequests() async {
    state = state.copyWith(loading: true);
    try {
      final list = await _api.getSubscriptionRequests();
      state = state.copyWith(subRequests: list, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  Future<bool> updateSubRequest(
      String id, String status, Map<String, dynamic> fields) async {
    final ok = await _api.updateSubscriptionRequest(id, status, fields);
    if (ok) await loadSubRequests();
    return ok;
  }

  // ── Promo codes ───────────────────────────────────────────
  Future<void> loadPromos() async {
    state = state.copyWith(loading: true);
    try {
      final res = await _api.listPromos();
      final codes =
          (res?['codes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(promoCodes: codes, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  Future<bool> createPromo(
      String code, double discount, int maxUses) async {
    final ok = await _api.createPromo(code, discount, maxUses);
    if (ok) await loadPromos();
    return ok;
  }

  Future<bool> deletePromo(String code) async {
    final ok = await _api.deletePromo(code);
    if (ok) await loadPromos();
    return ok;
  }

  // ── Guest codes ───────────────────────────────────────────
  Future<void> loadGuestCodes() async {
    state = state.copyWith(loading: true);
    try {
      final res = await _api.listGuestCodes();
      final codes =
          (res?['codes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(guestCodes: codes, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  Future<bool> createGuestCode(String code) async {
    final ok = await _api.createGuestCode(code);
    if (ok) await loadGuestCodes();
    return ok;
  }

  Future<bool> deleteGuestCode(String code) async {
    final ok = await _api.deleteGuestCode(code);
    if (ok) await loadGuestCodes();
    return ok;
  }

  // ── Identity ban ──────────────────────────────────────────
  Future<void> loadBanned() async {
    state = state.copyWith(loading: true);
    try {
      final res  = await _api.listBanned();
      final list =
          (res?['banned'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(bannedList: list, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  Future<bool> banIdentity(Map<String, dynamic> banEntry) async {
    final ok = await _api.banIdentity(banEntry);
    if (ok) await loadBanned();
    return ok;
  }

  Future<bool> unbanIdentity(String banId) async {
    final ok = await _api.unbanIdentity(banId);
    if (ok) await loadBanned();
    return ok;
  }
}

final adminProvider =
    StateNotifierProvider<AdminNotifier, AdminState>(
        (_) => AdminNotifier());
