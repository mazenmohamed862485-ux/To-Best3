// lib/features/attendance/providers/attendance_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:to_best/core/utils/date_helper.dart';
import 'package:to_best/core/constants/app_constants.dart';

class AttendanceState {
  final Map<String, String> monthData; // dateKey → 'gym'|'absent'|'rest'
  final bool loading;
  final String? error;

  const AttendanceState({
    this.monthData = const {},
    this.loading   = false,
    this.error,
  });

  AttendanceState copyWith({
    Map<String, String>? monthData,
    bool? loading,
    String? error,
    bool clearError = false,
  }) =>
      AttendanceState(
        monthData: monthData ?? this.monthData,
        loading:   loading   ?? this.loading,
        error:     clearError ? null : (error ?? this.error),
      );

  int get gymCount    => monthData.values.where((v) => v == AppConstants.attGym).length;
  int get absentCount => monthData.values.where((v) => v == AppConstants.attAbs).length;
  int get restCount   => monthData.values.where((v) => v == AppConstants.attRest).length;
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(const AttendanceState());

  final _api   = ApiService.instance;
  final _cache = CacheService.instance;
  final _sync  = SyncService.instance;

  Future<void> loadMonth(String uid, {String? monthKey}) async {
    final month  = monthKey ?? DateHelper.thisMonth();
    // Cache first
    final cached = await _cache.getAttendance(uid, month);
    if (cached != null) {
      final data = Map<String, String>.from(
          cached.map((k, v) => MapEntry(k, v.toString())));
      state = state.copyWith(monthData: data);
    }
    // Server
    try {
      final data = await _api.fetchUserData(uid);
      final att  = data?['attendance']?[month];
      if (att != null && att is Map) {
        final m = Map<String, String>.from(
            att.map((k, v) => MapEntry(k.toString(), v.toString())));
        await _cache.saveAttendance(uid, month, m);
        state = state.copyWith(monthData: m);
      }
    } catch (_) {}
  }

  Future<void> markDay(String uid, String dateKey, String status) async {
    final month   = dateKey.substring(0, 7); // YYYY-MM
    final updated = {...state.monthData, dateKey: status};
    state = state.copyWith(monthData: updated);
    await _cache.saveAttendance(uid, month, updated);
    await _sync.enqueue('SAVE_ATTENDANCE', '${uid}_$month', {
      'uid':     uid,
      'month':   month,
      'dateKey': dateKey,
      'status':  status,
      'data':    updated,
    });
  }

  void clearDay(String dateKey) {
    final updated = Map<String, String>.from(state.monthData)
      ..remove(dateKey);
    state = state.copyWith(monthData: updated);
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>(
        (_) => AttendanceNotifier());
