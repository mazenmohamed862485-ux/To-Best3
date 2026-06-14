// lib/features/attendance/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/attendance/providers/attendance_provider.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/utils/date_helper.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _viewMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  void _loadMonth() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    ref.read(attendanceProvider.notifier)
        .loadMonth(user.uid, monthKey: DateHelper.toMonthKey(_viewMonth));
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
    });
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    final locale  = ref.watch(localeProvider).languageCode;
    final isAr    = locale == 'ar';
    final attSt   = ref.watch(attendanceProvider);
    final user    = ref.watch(currentUserProvider);

    final daysInMonth = DateHelper.daysInMonth(
        _viewMonth.year, _viewMonth.month);
    final firstWeekday = daysInMonth.first.weekday % 7; // Sun=0

    const weekDays = ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س'];
    const weekDaysEn = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإلتزام' : 'Attendance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: isAr ? 'جيم' : 'Gym',
                    value: '${attSt.gymCount}',
                    color: AppColors.accent,
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: isAr ? 'راحة' : 'Rest',
                    value: '${attSt.restCount}',
                    color: AppColors.info,
                    icon: Icons.bedtime_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: isAr ? 'غياب' : 'Absent',
                    value: '${attSt.absentCount}',
                    color: AppColors.err,
                    icon: Icons.close,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeMonth(-1),
                        ),
                        Text(
                          _monthName(_viewMonth, isAr),
                          style: context.text.titleSmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                    // Week day headers
                    Row(
                      children: (isAr ? weekDays : weekDaysEn).map((d) {
                        return Expanded(
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    // Calendar grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: firstWeekday + daysInMonth.length,
                      itemBuilder: (ctx, idx) {
                        if (idx < firstWeekday) {
                          return const SizedBox.shrink();
                        }
                        final day   = daysInMonth[idx - firstWeekday];
                        final key   = DateHelper.toDateKey(day);
                        final status = attSt.monthData[key];
                        final isToday = DateHelper.isSameDay(
                            day, DateTime.now());

                        return GestureDetector(
                          onTap: () => _showDayOptions(
                              context, key, status, user?.uid, isAr),
                          child: _DayCell(
                            day:     day.day,
                            status:  status,
                            isToday: isToday,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legend
            Wrap(
              spacing: 12,
              children: [
                _Legend(
                    color: AppColors.accent,
                    label: isAr ? 'جيم' : 'Gym'),
                _Legend(
                    color: AppColors.info,
                    label: isAr ? 'راحة' : 'Rest'),
                _Legend(
                    color: AppColors.err,
                    label: isAr ? 'غياب' : 'Absent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDayOptions(
    BuildContext context,
    String dateKey,
    String? current,
    String? uid,
    bool isAr,
  ) {
    if (uid == null) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dateKey, style: context.text.titleSmall),
            const SizedBox(height: 12),
            _AttOption(
              icon:   Icons.fitness_center,
              label:  isAr ? 'جيم' : 'Gym',
              color:  AppColors.accent,
              active: current == AppConstants.attGym,
              onTap: () {
                ref.read(attendanceProvider.notifier)
                    .markDay(uid, dateKey, AppConstants.attGym);
                Navigator.pop(context);
              },
            ),
            _AttOption(
              icon:   Icons.bedtime_outlined,
              label:  isAr ? 'يوم راحة' : 'Rest Day',
              color:  AppColors.info,
              active: current == AppConstants.attRest,
              onTap: () {
                ref.read(attendanceProvider.notifier)
                    .markDay(uid, dateKey, AppConstants.attRest);
                Navigator.pop(context);
              },
            ),
            _AttOption(
              icon:   Icons.close,
              label:  isAr ? 'غياب' : 'Absent',
              color:  AppColors.err,
              active: current == AppConstants.attAbs,
              onTap: () {
                ref.read(attendanceProvider.notifier)
                    .markDay(uid, dateKey, AppConstants.attAbs);
                Navigator.pop(context);
              },
            ),
            if (current != null)
              _AttOption(
                icon:   Icons.clear,
                label:  isAr ? 'مسح' : 'Clear',
                color:  Colors.grey,
                active: false,
                onTap: () {
                  ref.read(attendanceProvider.notifier).clearDay(dateKey);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  String _monthName(DateTime d, bool isAr) {
    const arMonths = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
    ];
    const enMonths = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${isAr ? arMonths[d.month - 1] : enMonths[d.month - 1]} ${d.year}';
  }
}

class _DayCell extends StatelessWidget {
  final int     day;
  final String? status;
  final bool    isToday;

  const _DayCell({
    required this.day,
    this.status,
    required this.isToday,
  });

  Color get _bgColor {
    switch (status) {
      case 'gym':    return AppColors.accent.withOpacity(0.25);
      case 'rest':   return AppColors.info.withOpacity(0.2);
      case 'absent': return AppColors.err.withOpacity(0.2);
      default:       return Colors.transparent;
    }
  }

  Color? get _textColor {
    switch (status) {
      case 'gym':    return AppColors.accent;
      case 'rest':   return AppColors.info;
      case 'absent': return AppColors.err;
      default:       return null;
    }
  }

  String get _emoji {
    switch (status) {
      case 'gym':    return '🏋️';
      case 'rest':   return '😴';
      case 'absent': return '❌';
      default:       return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize:   11,
              fontWeight: isToday ? FontWeight.w900 : FontWeight.w400,
              color:      _textColor,
            ),
          ),
          if (_emoji.isNotEmpty)
            Text(_emoji, style: const TextStyle(fontSize: 8)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color  color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color, shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: context.text.bodySmall),
      ],
    );
  }
}

class _AttOption extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final Color      color;
  final bool       active;
  final VoidCallback onTap;

  const _AttOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title:   Text(label),
      tileColor: active ? color.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      trailing: active ? Icon(Icons.check, color: color, size: 18) : null,
      onTap: onTap,
    );
  }
}
