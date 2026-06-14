// lib/features/progress/providers/progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/progress/models/measurement_model.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:to_best/core/utils/date_helper.dart';

class ProgressState {
  final List<MeasurementEntry> measurements;
  final bool   loading;
  final String? error;

  const ProgressState({
    this.measurements = const [],
    this.loading      = false,
    this.error,
  });

  ProgressState copyWith({
    List<MeasurementEntry>? measurements,
    bool?    loading,
    String?  error,
    bool     clearError = false,
  }) =>
      ProgressState(
        measurements: measurements ?? this.measurements,
        loading:      loading      ?? this.loading,
        error:        clearError ? null : (error ?? this.error),
      );

  MeasurementEntry? get latest =>
      measurements.isEmpty ? null : measurements.last;

  double? get latestWeight => latest?.weight;

  List<Map<String, dynamic>> get weightTimeline {
    return measurements
        .where((m) => m.weight != null)
        .map((m) => {'date': m.dateKey, 'value': m.weight})
        .toList();
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(const ProgressState());

  final _api   = ApiService.instance;
  final _cache = CacheService.instance;
  final _sync  = SyncService.instance;

  Future<void> loadMeasurements(String uid) async {
    state = state.copyWith(loading: true);
    // Cache
    final cached = await _cache.getMeasurements(uid);
    if (cached != null) {
      final list = _parseList(cached['measurements']);
      state = state.copyWith(measurements: list, loading: false);
    }
    // Server
    try {
      final data = await _api.fetchUserData(uid);
      final raw  = data?['measurements'];
      if (raw != null) {
        final list = _parseList(raw);
        await _cache.saveMeasurements(uid, {'measurements': raw});
        state = state.copyWith(measurements: list, loading: false);
      }
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  List<MeasurementEntry> _parseList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map((e) => MeasurementEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (raw is Map) {
      return raw.entries
          .map((e) => MeasurementEntry.fromJson({
                ...e.value as Map<String, dynamic>,
                'dateKey': e.key,
              }))
          .toList()
        ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    }
    return [];
  }

  Future<void> addMeasurement(
      String uid, MeasurementEntry entry) async {
    final updated = [...state.measurements, entry]
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    state = state.copyWith(measurements: updated);
    final raw = {for (var m in updated) m.dateKey: m.toJson()};
    await _cache.saveMeasurements(uid, {'measurements': raw});
    await _sync.enqueue('SAVE_MEASUREMENT', uid, {
      'uid':         uid,
      'dateKey':     entry.dateKey,
      'measurement': entry.toJson(),
    });
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>(
        (_) => ProgressNotifier());
