// lib/features/profile/providers/profile_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileNotifier(this.ref) : super(const AsyncData(null));

  final Ref     ref;
  final _api    = ApiService.instance;
  final _cache  = CacheService.instance;
  final _picker = ImagePicker();

  Future<bool> updateProfile(String uid, Map<String, dynamic> fields) async {
    state = const AsyncLoading();
    try {
      final ok = await _api.pushData({
        'action': 'UPDATE_PROFILE', 'uid': uid, 'fields': fields,
      });
      if (ok) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          final updated = user.copyWith(
            name:  fields['name']  as String? ?? user.name,
            phone: fields['phone'] as String? ?? user.phone,
          );
          ref.read(authProvider.notifier).updateUser(updated);
          await _cache.saveCurrentUser(updated.toJson());
        }
      }
      state = const AsyncData(null);
      return ok;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> changePassword(
      String uid, String oldPwd, String newPwd) async {
    state = const AsyncLoading();
    try {
      final ok = await _api.changePassword(uid, oldPwd, newPwd);
      state = const AsyncData(null);
      return ok;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> uploadProfilePicture(String uid) async {
    try {
      final picked = await _picker.pickImage(
        source:       ImageSource.gallery,
        maxWidth:     800,
        maxHeight:    800,
        imageQuality: 75,
      );
      if (picked == null) return false;

      final bytes     = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);

      final res = await _api.saveProfilePicture(uid, base64Str);
      if (res?['ok'] == true) {
        final url  = res!['url']?.toString();
        final user = ref.read(currentUserProvider);
        if (user != null && url != null) {
          final updated = user.copyWith(profilePicUrl: url);
          ref.read(authProvider.notifier).updateUser(updated);
          await _cache.saveCurrentUser(updated.toJson());
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getReferralStats(String code) async {
    return _api.getReferralStats(code);
  }

  Future<bool> submitSubscriptionRequest(
      String uid, Map<String, dynamic> data) async {
    return _api.submitSubscriptionPayment(uid, data);
  }

  Future<bool> forgotPassword(String email) async {
    return _api.forgotPassword(email);
  }

  Future<bool> resetPassword(
      String email, String code, String newPwd) async {
    return _api.resetPassword(email, code, newPwd);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<void>>(
        (ref) => ProfileNotifier(ref));
