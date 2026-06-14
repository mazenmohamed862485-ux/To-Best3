// lib/features/workout/models/workout_log_model.dart
import 'dart:convert';

class SetEntry {
  final double weight;
  final int    reps;
  final bool   isPR;
  final double? rpe;

  const SetEntry({
    required this.weight,
    required this.reps,
    this.isPR  = false,
    this.rpe,
  });

  factory SetEntry.fromJson(Map<String, dynamic> j) => SetEntry(
    weight: (j['weight'] as num?)?.toDouble() ?? 0,
    reps:   (j['reps']   as num?)?.toInt()    ?? 0,
    isPR:   j['isPR']   == true,
    rpe:    (j['rpe']   as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps':   reps,
    if (isPR) 'isPR': true,
    if (rpe != null) 'rpe': rpe,
  };
}

class ExerciseLog {
  final String       name;
  final String       muscle;
  final List<SetEntry> sets;
  final String?      note;
  final String?      videoUrl;

  const ExerciseLog({
    required this.name,
    required this.muscle,
    required this.sets,
    this.note,
    this.videoUrl,
  });

  double? get maxWeight => sets.isEmpty
      ? null
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  int? get totalVolume => sets.isEmpty
      ? null
      : sets.fold(0, (sum, s) => sum + (s.weight * s.reps).toInt());

  factory ExerciseLog.fromJson(Map<String, dynamic> j) => ExerciseLog(
    name:     j['name']?.toString()   ?? '',
    muscle:   j['muscle']?.toString() ?? '',
    sets:     (j['sets'] as List?)
                  ?.map((s) => SetEntry.fromJson(s as Map<String, dynamic>))
                  .toList() ??
              [],
    note:     j['note']?.toString(),
    videoUrl: j['videoUrl']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'name':   name,
    'muscle': muscle,
    'sets':   sets.map((s) => s.toJson()).toList(),
    if (note != null)     'note':     note,
    if (videoUrl != null) 'videoUrl': videoUrl,
  };

  ExerciseLog copyWith({
    String? name, String? muscle, List<SetEntry>? sets, String? note,
  }) => ExerciseLog(
    name:   name   ?? this.name,
    muscle: muscle ?? this.muscle,
    sets:   sets   ?? this.sets,
    note:   note   ?? this.note,
  );
}

class WorkoutLog {
  final String           uid;
  final String           dateKey;
  final String           session;
  final String           program;
  final List<ExerciseLog> exercises;
  final int?             startTs;
  final int?             endTs;
  final String?          notes;
  final String?          eval;

  const WorkoutLog({
    required this.uid,
    required this.dateKey,
    required this.session,
    required this.program,
    required this.exercises,
    this.startTs,
    this.endTs,
    this.notes,
    this.eval,
  });

  Duration? get duration {
    if (startTs == null || endTs == null) return null;
    return Duration(milliseconds: endTs! - startTs!);
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> j) => WorkoutLog(
    uid:       j['uid']?.toString()     ?? '',
    dateKey:   j['dateKey']?.toString() ?? '',
    session:   j['session']?.toString() ?? '',
    program:   j['program']?.toString() ?? '',
    exercises: (j['exercises'] as List?)
                   ?.map((e) =>
                       ExerciseLog.fromJson(e as Map<String, dynamic>))
                   .toList() ??
               [],
    startTs: (j['startTs'] as num?)?.toInt(),
    endTs:   (j['endTs']   as num?)?.toInt(),
    notes:   j['notes']?.toString(),
    eval:    j['eval']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'uid':       uid,
    'dateKey':   dateKey,
    'session':   session,
    'program':   program,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    if (startTs != null) 'startTs': startTs,
    if (endTs   != null) 'endTs':   endTs,
    if (notes   != null) 'notes':   notes,
    if (eval    != null) 'eval':    eval,
  };

  String toJsonString() => jsonEncode(toJson());

  WorkoutLog copyWith({
    List<ExerciseLog>? exercises,
    int? startTs, int? endTs,
    String? notes, String? eval,
  }) => WorkoutLog(
    uid:       uid,
    dateKey:   dateKey,
    session:   session,
    program:   program,
    exercises: exercises ?? this.exercises,
    startTs:   startTs   ?? this.startTs,
    endTs:     endTs     ?? this.endTs,
    notes:     notes     ?? this.notes,
    eval:      eval      ?? this.eval,
  );
}
