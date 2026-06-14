// lib/features/workout/providers/workout_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/workout/models/workout_log_model.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:to_best/core/utils/date_helper.dart';

class WorkoutState {
  final Map<String, WorkoutLog> logs;        // dateKey → WorkoutLog
  final WorkoutLog?             activeSession;
  final bool                    inSession;
  final bool                    loading;
  final String?                 error;

  const WorkoutState({
    this.logs         = const {},
    this.activeSession,
    this.inSession    = false,
    this.loading      = false,
    this.error,
  });

  WorkoutState copyWith({
    Map<String, WorkoutLog>? logs,
    WorkoutLog?  activeSession,
    bool?        inSession,
    bool?        loading,
    String?      error,
    bool         clearSession = false,
    bool         clearError   = false,
  }) {
    return WorkoutState(
      logs:          logs          ?? this.logs,
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      inSession:     inSession     ?? this.inSession,
      loading:       loading       ?? this.loading,
      error:         clearError   ? null : (error ?? this.error),
    );
  }
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  WorkoutNotifier() : super(const WorkoutState());

  final _api   = ApiService.instance;
  final _cache = CacheService.instance;
  final _sync  = SyncService.instance;

  // ── Load today's log ─────────────────────────────────────
  Future<void> loadToday(String uid) async {
    final today  = DateHelper.today();
    final cached = await _cache.getWorkoutLog(uid, today);
    if (cached != null) {
      final log = WorkoutLog.fromJson(cached);
      state = state.copyWith(logs: {...state.logs, today: log});
    }

    // Pull from server
    try {
      final data = await _api.fetchUserData(uid);
      final logsData = data?['workoutLogs'] as Map<String, dynamic>?;
      if (logsData != null) {
        final newLogs = <String, WorkoutLog>{};
        for (final entry in logsData.entries) {
          try {
            newLogs[entry.key] =
                WorkoutLog.fromJson(entry.value as Map<String, dynamic>);
          } catch (_) {}
        }
        state = state.copyWith(logs: newLogs);
        // Cache today
        if (newLogs.containsKey(today)) {
          await _cache.saveWorkoutLog(uid, today, newLogs[today]!.toJson());
        }
      }
    } catch (_) {}
  }

  // ── Load all logs for history ─────────────────────────────
  Future<void> loadAllLogs(String uid) async {
    state = state.copyWith(loading: true);
    // From cache first
    final cached = await _cache.getAllWorkoutLogs(uid);
    final logs   = <String, WorkoutLog>{};
    for (final entry in cached.entries) {
      try { logs[entry.key] = WorkoutLog.fromJson(entry.value); } catch (_) {}
    }
    state = state.copyWith(logs: logs, loading: false);

    // Then from server
    try {
      final data = await _api.fullSyncPull(uid);
      final logsData = data?['workoutLogs'] as Map<String, dynamic>?;
      if (logsData != null) {
        final serverLogs = <String, WorkoutLog>{};
        for (final entry in logsData.entries) {
          try {
            final log = WorkoutLog.fromJson(entry.value as Map<String, dynamic>);
            serverLogs[entry.key] = log;
            await _cache.saveWorkoutLog(uid, entry.key, log.toJson());
          } catch (_) {}
        }
        state = state.copyWith(logs: serverLogs, loading: false);
      }
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  // ── Start a session ────────────────────────────────────────
  void startSession({
    required String uid,
    required String session,
    required String program,
    required String dateKey,
  }) {
    final log = WorkoutLog(
      uid:       uid,
      dateKey:   dateKey,
      session:   session,
      program:   program,
      exercises: [],
      startTs:   DateTime.now().millisecondsSinceEpoch,
    );
    state = state.copyWith(activeSession: log, inSession: true);
  }

  // ── Update exercises in active session ────────────────────
  void updateExercises(List<ExerciseLog> exercises) {
    if (state.activeSession == null) return;
    state = state.copyWith(
      activeSession: state.activeSession!.copyWith(exercises: exercises),
    );
  }

  // ── Finish session ─────────────────────────────────────────
  Future<void> finishSession(String uid) async {
    if (state.activeSession == null) return;
    final finished = state.activeSession!.copyWith(
      endTs: DateTime.now().millisecondsSinceEpoch,
    );
    final dateKey = finished.dateKey;

    final newLogs = {...state.logs, dateKey: finished};
    state = state.copyWith(
      logs: newLogs,
      clearSession: true,
      inSession: false,
    );

    // Save to cache
    await _cache.saveWorkoutLog(uid, dateKey, finished.toJson());

    // Sync to server
    await _sync.enqueue(
      'SAVE_WORKOUT_LOG',
      '${uid}_$dateKey',
      {'uid': uid, 'dateKey': dateKey, 'log': finished.toJson()},
    );
  }

  // ── Cancel session ─────────────────────────────────────────
  void cancelSession() {
    state = state.copyWith(clearSession: true, inSession: false);
  }

  // ── Get exercise history ───────────────────────────────────
  List<Map<String, dynamic>> getExerciseHistory(
      String exerciseName, {String? excludeDate}) {
    final history = <Map<String, dynamic>>[];
    for (final entry in state.logs.entries) {
      if (excludeDate != null && entry.key == excludeDate) continue;
      for (final ex in entry.value.exercises) {
        if (ex.name == exerciseName && ex.sets.isNotEmpty) {
          history.add({
            'date':   entry.key,
            'maxWt':  ex.maxWeight,
            'volume': ex.totalVolume,
            'sets':   ex.sets.length,
          });
        }
      }
    }
    history.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return history;
  }
}

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, WorkoutState>(
        (_) => WorkoutNotifier());
