// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/auth/models/user_model.dart';
import 'package:to_best/features/auth/repositories/auth_repository.dart';

// ── Auth State ────────────────────────────────────────────────
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user:      clearUser  ? null  : (user      ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error:     clearError ? null  : (error     ?? this.error),
    );
  }
}

// ── Auth Notifier ─────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadCachedUser();
  }

  final _repo = AuthRepository();

  Future<void> _loadCachedUser() async {
    final user = await _repo.loadCachedUser();
    if (user != null && mounted) {
      state = state.copyWith(user: user);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(email, password);
      if (mounted) state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
            isLoading: false, error: e.toString(), clearUser: false);
      }
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.register(data);
      if (mounted) {
        state = state.copyWith(user: user, isLoading: false);
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  Future<bool> guestLogin(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.guestLogin(code);
      if (mounted) state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    if (mounted) state = const AuthState();
  }

  void updateUser(UserModel user) {
    if (mounted) state = state.copyWith(user: user);
  }

  Future<bool> checkForceLogout() async {
    final user = state.user;
    if (user == null) return false;
    return _repo.checkForceLogout(user);
  }

  Future<void> refreshUser() async {
    final user = state.user;
    if (user == null) return;
    final updated = await _repo.refreshUser(user.uid);
    if (updated != null && mounted) {
      state = state.copyWith(user: updated);
    }
  }

  void clearError() {
    if (mounted) state = state.copyWith(clearError: true);
  }
}

// ── Providers ─────────────────────────────────────────────────
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((_) => AuthNotifier());

final currentUserProvider =
    Provider<UserModel?>((ref) => ref.watch(authProvider).user);

final authStateProvider = StreamProvider<UserModel?>((ref) async* {
  final user = ref.watch(currentUserProvider);
  yield user;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isAdminLike ?? false;
});
