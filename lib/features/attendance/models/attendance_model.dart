// lib/features/attendance/models/attendance_model.dart

class AttendanceDay {
  final String dateKey;
  final String status; // 'gym', 'absent', 'rest'

  const AttendanceDay({required this.dateKey, required this.status});

  bool get isGym    => status == 'gym';
  bool get isAbsent => status == 'absent';
  bool get isRest   => status == 'rest';
}
