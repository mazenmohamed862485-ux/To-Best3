// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/attendance/providers/attendance_provider.dart';
import 'package:to_best/features/nutrition/providers/nutrition_provider.dart';
import 'package:to_best/features/workout/providers/workout_provider.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/utils/date_helper.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _pendingSync = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    SyncService.instance.pendingCountStream.listen((count) {
      if (mounted) setState(() => _pendingSync = count);
    });
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await Future.wait([
      ref.read(attendanceProvider.notifier).loadMonth(user.uid),
      ref.read(nutritionProvider.notifier).loadToday(user.uid),
      ref.read(workoutProvider.notifier).loadToday(user.uid),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user   = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final isDark = context.isDark;
    if (user == null) return const SizedBox.shrink();

    final attSt  = ref.watch(attendanceProvider);
    final nutSt  = ref.watch(nutritionProvider);
    final wrkSt  = ref.watch(workoutProvider);
    final today  = DateHelper.today();
    final todayAtt = attSt.monthData[today];
    final hasWorkout = wrkSt.logs.containsKey(today);
    final nutrition  = nutSt.today;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────
            SliverAppBar(
              floating:   true,
              snap:       true,
              pinned:     false,
              title: Row(
                children: [
                  Image.asset(
                    isDark
                        ? 'assets/icons/logo_dark.png'
                        : 'assets/icons/logo_light.png',
                    width: 28, height: 28,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fitness_center, size: 28, color: AppColors.accent),
                  ),
                  const SizedBox(width: 8),
                  const Text('TO Best', style: TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
              actions: [
                if (_pendingSync > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: SyncIndicator(pendingCount: _pendingSync),
                  ),
                if (user.isAdminLike)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    onPressed: () => context.push('/admin'),
                    tooltip: locale == 'ar' ? 'لوحة الإدارة' : 'Admin Panel',
                  ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Greeting ─────────────────────────────────
                  _GreetingCard(name: user.name, locale: locale),
                  const SizedBox(height: 16),

                  // ── Quick Stats Row ───────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: locale == 'ar' ? 'جيم هذا الشهر' : 'Gym Days',
                          value: '${attSt.gymCount}',
                          icon:  Icons.fitness_center,
                          color: AppColors.accent,
                          sub:   locale == 'ar' ? 'هذا الشهر' : 'this month',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: locale == 'ar' ? 'سعرات اليوم' : "Today's Cal",
                          value: '${(nutrition?.totalCalories ?? 0).toInt()}',
                          icon:  Icons.local_fire_department,
                          color: AppColors.warn,
                          sub:   '/ ${user.dailyCals ?? 0} kcal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Today Attendance ──────────────────────────
                  _TodayAttendanceCard(
                    dateKey:   today,
                    status:    todayAtt,
                    locale:    locale,
                    gymDays:   user.programDays,
                    onMark: (status) {
                      ref.read(attendanceProvider.notifier)
                          .markDay(user.uid, today, status);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Workout today ─────────────────────────────
                  _WorkoutCard(
                    hasLog:   hasWorkout,
                    session:  hasWorkout ? wrkSt.logs[today]?.session : null,
                    locale:   locale,
                  ),
                  const SizedBox(height: 16),

                  // ── Nutrition summary ─────────────────────────
                  _NutritionSummaryCard(
                    meals:    nutrition,
                    target:   user.dailyCals,
                    protein:  user.protein,
                    locale:   locale,
                  ),
                  const SizedBox(height: 16),

                  // ── Subscription warning ──────────────────────
                  if (!user.subscriptionActive && !user.isAdminLike)
                    _SubscriptionBanner(locale: locale),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Greeting Card ─────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final String name;
  final String locale;
  const _GreetingCard({required this.name, required this.locale});

  String _greeting() {
    final h = DateTime.now().hour;
    if (locale == 'ar') {
      if (h < 12) return 'صباح الخير';
      if (h < 17) return 'مساء الخير';
      return 'مساء النور';
    } else {
      if (h < 12) return 'Good morning';
      if (h < 17) return 'Good afternoon';
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greeting()}،',
          style: context.text.bodyMedium?.copyWith(color: context.scheme.primary),
        ),
        Text(
          name.split(' ').first,
          style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        Text(
          DateHelper.format(DateTime.now(), arabic: locale == 'ar'),
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

// ── Today Attendance Card ─────────────────────────────────────
class _TodayAttendanceCard extends StatelessWidget {
  final String  dateKey;
  final String? status;
  final String  locale;
  final int?    gymDays;
  final void Function(String) onMark;

  const _TodayAttendanceCard({
    required this.dateKey,
    required this.status,
    required this.locale,
    this.gymDays,
    required this.onMark,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'إلتزام اليوم' : "Today's Attendance",
                  style: context.text.titleSmall,
                ),
                const Spacer(),
                if (status != null)
                  _StatusChip(status: status!),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AttBtn(
                    label:   isAr ? '🏋️ جيم' : '🏋️ Gym',
                    active:  status == AppConstants.attGym,
                    color:   AppColors.accent,
                    onTap:   () => onMark(AppConstants.attGym),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AttBtn(
                    label:   isAr ? '😴 راحة' : '😴 Rest',
                    active:  status == AppConstants.attRest,
                    color:   AppColors.info,
                    onTap:   () => onMark(AppConstants.attRest),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AttBtn(
                    label:   isAr ? '❌ غياب' : '❌ Absent',
                    active:  status == AppConstants.attAbs,
                    color:   AppColors.err,
                    onTap:   () => onMark(AppConstants.attAbs),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttBtn extends StatelessWidget {
  final String  label;
  final bool    active;
  final Color   color;
  final VoidCallback onTap;

  const _AttBtn({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.transparent,
            border: Border.all(
              color: active ? color : context.theme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color:      active ? color : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'gym':    color = AppColors.accent; label = '🏋️'; break;
      case 'rest':   color = AppColors.info;   label = '😴'; break;
      case 'absent': color = AppColors.err;    label = '❌'; break;
      default:       color = AppColors.accent; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

// ── Workout Card ──────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final bool    hasLog;
  final String? session;
  final String  locale;
  const _WorkoutCard({required this.hasLog, this.session, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color:        AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            hasLog ? Icons.check_circle_outline : Icons.fitness_center,
            color: hasLog ? AppColors.ok : AppColors.accent,
          ),
        ),
        title: Text(
          isAr ? 'تمرين اليوم' : "Today's Workout",
          style: context.text.titleSmall,
        ),
        subtitle: Text(
          hasLog
              ? (session != null
                  ? (isAr ? 'جلسة $session ✓' : 'Session $session ✓')
                  : (isAr ? 'تم تسجيل التمرين ✓' : 'Logged ✓'))
              : (isAr ? 'لم يُسجّل بعد' : 'Not logged yet'),
          style: context.text.bodySmall?.copyWith(
            color: hasLog ? AppColors.ok : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/workout'),
      ),
    );
  }
}

// ── Nutrition Summary Card ─────────────────────────────────────
class _NutritionSummaryCard extends StatelessWidget {
  final dynamic meals;
  final int?    target;
  final int?    protein;
  final String  locale;

  const _NutritionSummaryCard({
    this.meals, this.target, this.protein, required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    final cal  = meals?.totalCalories as double? ?? 0;
    final prot = meals?.totalProtein  as double? ?? 0;
    final tCal = (target ?? 0).toDouble();
    final tProt = (protein ?? 0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_outlined,
                    size: 16, color: AppColors.warn),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'التغذية اليوم' : "Today's Nutrition",
                  style: context.text.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/nutrition'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(isAr ? 'التفاصيل' : 'Details',
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${cal.toInt()}',
                        style: context.text.headlineSmall?.copyWith(
                          color:      AppColors.warn,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        isAr ? 'سعرة / $tCal' : 'kcal / $tCal',
                        style: context.text.labelSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${prot.toInt()}g',
                        style: context.text.headlineSmall?.copyWith(
                          color:      AppColors.info,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        isAr ? 'بروتين / ${tProt.toInt()}g' : 'protein / ${tProt.toInt()}g',
                        style: context.text.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subscription Banner ────────────────────────────────────────
class _SubscriptionBanner extends StatelessWidget {
  final String locale;
  const _SubscriptionBanner({required this.locale});

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.warn.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.warn.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warn),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr
                  ? 'اشتراكك غير نشط. يرجى تجديد الاشتراك للاستمرار.'
                  : 'Your subscription is inactive. Please renew to continue.',
              style: const TextStyle(fontSize: 12, color: AppColors.warn),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/profile'),
            child: Text(isAr ? 'تجديد' : 'Renew',
                style: const TextStyle(color: AppColors.warn, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
