// lib/features/workout/screens/workout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/workout/providers/workout_provider.dart';
import 'package:to_best/features/workout/models/exercise_model.dart';
import 'package:to_best/features/workout/models/workout_log_model.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/utils/date_helper.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});
  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(workoutProvider.notifier).loadAllLogs(user.uid);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr   = locale == 'ar';
    final wrkSt  = ref.watch(workoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'التمرين' : 'Workout'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: isAr ? 'اليوم' : 'Today'),
            Tab(text: isAr ? 'السجل' : 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _TodayTab(locale: locale),
          _HistoryTab(logs: wrkSt.logs, locale: locale),
        ],
      ),
    );
  }
}

// ─────────────────────────── Today Tab ───────────────────────
class _TodayTab extends ConsumerWidget {
  final String locale;
  const _TodayTab({required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr  = locale == 'ar';
    final user  = ref.watch(currentUserProvider);
    final wrkSt = ref.watch(workoutProvider);
    final today = DateHelper.today();
    final todayLog = wrkSt.logs[today];
    final inSession = wrkSt.inSession;

    if (user == null) return const SizedBox();

    if (inSession && wrkSt.activeSession != null) {
      return _ActiveSessionView(
        session: wrkSt.activeSession!,
        locale:  locale,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Program info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        isAr ? 'برنامجك' : 'Your Program',
                        style: context.text.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.program != null
                        ? (AppConstants.programs[user.program] ?? user.program!)
                        : (isAr ? 'لا يوجد برنامج محدد' : 'No program set'),
                    style: context.text.bodyMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (user.programDays != null)
                    Text(
                      isAr
                          ? '${user.programDays} أيام في الأسبوع'
                          : '${user.programDays} days/week',
                      style: context.text.bodySmall,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Today log
          if (todayLog != null) ...[
            _LoggedSessionCard(log: todayLog, locale: locale),
            const SizedBox(height: 12),
          ],

          // Session buttons
          if (user.program != null)
            _SessionSelector(
              program: user.program!,
              locale:  locale,
              onStart: (sessionName) {
                ref.read(workoutProvider.notifier).startSession(
                  uid:       user.uid,
                  session:   sessionName,
                  program:   user.program!,
                  dateKey:   today,
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        AppColors.warn.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warn.withOpacity(0.3)),
              ),
              child: Text(
                isAr
                    ? 'يرجى التواصل مع المدرب لتحديد البرنامج.'
                    : 'Please contact your coach to set your program.',
                style: const TextStyle(color: AppColors.warn, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Session Selector ─────────────────────────────────────────
class _SessionSelector extends StatelessWidget {
  final String program;
  final String locale;
  final void Function(String) onStart;

  const _SessionSelector({
    required this.program,
    required this.locale,
    required this.onStart,
  });

  List<String> _getSessions() {
    switch (program) {
      case 'UL':     return ['Upper A', 'Lower A', 'Upper B', 'Lower B'];
      case 'AP':     return ['Anterior A', 'Posterior A', 'Anterior B', 'Posterior B'];
      case 'FB':     return ['Full Body #1', 'Full Body #2', 'Full Body #3'];
      case 'ARNOLD': return ['Chest & Back', 'Shoulders & Arms', 'Legs'];
      case 'PPL':    return ['PUSH', 'PULL', 'LEGS'];
      default:       return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _getSessions();
    final isAr     = locale == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'ابدأ جلسة' : 'Start Session',
          style: context.text.titleSmall,
        ),
        const SizedBox(height: 10),
        ...sessions.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              title: Text(s, style: context.text.titleSmall),
              subtitle: Text(
                '${ExerciseDB.getSession(s).length} ${isAr ? "تمرين" : "exercises"}',
                style: context.text.bodySmall,
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:        AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAr ? 'ابدأ' : 'Start',
                  style: const TextStyle(
                    color:      AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize:   13,
                  ),
                ),
              ),
              onTap: () => onStart(s),
            ),
          ),
        )),
      ],
    );
  }
}

// ─── Logged Session Card ──────────────────────────────────────
class _LoggedSessionCard extends StatelessWidget {
  final WorkoutLog log;
  final String     locale;
  const _LoggedSessionCard({required this.log, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Card(
      color: AppColors.ok.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.ok, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${isAr ? "جلسة" : "Session"} ${log.session} ✓',
                  style: context.text.titleSmall
                      ?.copyWith(color: AppColors.ok),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${log.exercises.length} ${isAr ? "تمرين" : "exercises"} '
              '· ${log.exercises.fold(0, (s, e) => s + e.sets.length)} ${isAr ? "سيت" : "sets"}',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Active Session View ──────────────────────────────────────
class _ActiveSessionView extends ConsumerStatefulWidget {
  final WorkoutLog session;
  final String     locale;
  const _ActiveSessionView({required this.session, required this.locale});

  @override
  ConsumerState<_ActiveSessionView> createState() =>
      _ActiveSessionViewState();
}

class _ActiveSessionViewState extends ConsumerState<_ActiveSessionView> {
  late List<ExerciseLog> _exercises;

  @override
  void initState() {
    super.initState();
    // Init from config
    final configs = ExerciseDB.getSession(widget.session.session);
    _exercises = widget.session.exercises.isNotEmpty
        ? List.from(widget.session.exercises)
        : configs
            .map((c) => ExerciseLog(
                  name:   c.name,
                  muscle: c.muscle,
                  sets:   List.generate(
                    c.sets,
                    (_) => const SetEntry(weight: 0, reps: 0),
                  ),
                  note: c.note.isEmpty ? null : c.note,
                ))
            .toList();
  }

  Future<void> _finish() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    // Update exercises
    ref.read(workoutProvider.notifier).updateExercises(_exercises);
    await ref.read(workoutProvider.notifier).finishSession(user.uid);
    if (mounted) {
      context.showSnack(
        widget.locale == 'ar' ? 'تم حفظ الجلسة ✓' : 'Session saved ✓',
      );
    }
  }

  void _cancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.locale == 'ar' ? 'إلغاء الجلسة' : 'Cancel Session'),
        content: Text(widget.locale == 'ar'
            ? 'هل تريد إلغاء الجلسة الحالية؟'
            : 'Cancel current session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.locale == 'ar' ? 'لا' : 'No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(workoutProvider.notifier).cancelSession();
            },
            child: Text(widget.locale == 'ar' ? 'إلغاء الجلسة' : 'Cancel',
                style: const TextStyle(color: AppColors.err)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.locale == 'ar';

    return Column(
      children: [
        // Session header
        Container(
          color: AppColors.accent.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.fitness_center,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                widget.session.session,
                style: context.text.titleSmall
                    ?.copyWith(color: AppColors.accent),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.close, size: 16, color: AppColors.err),
                label: Text(isAr ? 'إلغاء' : 'Cancel',
                    style: const TextStyle(color: AppColors.err, fontSize: 12)),
                onPressed: _cancel,
              ),
            ],
          ),
        ),
        // Exercises
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _exercises.length,
            itemBuilder: (_, i) => _ExerciseCard(
              config: ExerciseDB.getSession(widget.session.session)
                  .elementAtOrNull(i),
              log:    _exercises[i],
              locale: widget.locale,
              onUpdate: (updated) {
                setState(() => _exercises[i] = updated);
              },
            ),
          ),
        ),
        // Finish button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon:     const Icon(Icons.check),
            label:    Text(isAr ? 'إنهاء الجلسة' : 'Finish Session'),
            onPressed: _finish,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Exercise Card ────────────────────────────────────────────
class _ExerciseCard extends StatefulWidget {
  final ExerciseConfig? config;
  final ExerciseLog     log;
  final String          locale;
  final void Function(ExerciseLog) onUpdate;

  const _ExerciseCard({
    this.config,
    required this.log,
    required this.locale,
    required this.onUpdate,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  late List<SetEntry> _sets;

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.log.sets);
  }

  void _updateSet(int idx, double weight, int reps) {
    setState(() {
      _sets[idx] = SetEntry(
        weight: weight,
        reps:   reps,
        isPR:   _isPR(weight, reps),
      );
    });
    widget.onUpdate(widget.log.copyWith(sets: _sets));
  }

  bool _isPR(double weight, int reps) {
    // Simple check: max weight in all existing sets
    return _sets.every((s) => weight >= s.weight);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.locale == 'ar';
    final cfg  = widget.config;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.log.name,
                    style: context.text.titleSmall,
                  ),
                ),
                if (widget.log.muscle.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.log.muscle.muscleColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.log.muscle,
                      style: TextStyle(
                        fontSize: 10,
                        color:    widget.log.muscle.muscleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            if (cfg != null && cfg.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                cfg.note,
                style: context.text.bodySmall?.copyWith(
                  color: AppColors.warn,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (cfg != null) ...[
              const SizedBox(height: 4),
              Text(
                '${isAr ? "تكرارات" : "Reps"}: ${cfg.reps}  ·  '
                '${isAr ? "راحة" : "Rest"}: ${cfg.rest} min',
                style: context.text.labelSmall,
              ),
            ],
            const SizedBox(height: 10),

            // Header
            Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(isAr ? 'سيت' : 'Set',
                      style: context.text.labelSmall),
                ),
                Expanded(
                  child: Text(
                    isAr ? 'الوزن (kg)' : 'Weight (kg)',
                    style: context.text.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    isAr ? 'التكرارات' : 'Reps',
                    style: context.text.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const Divider(height: 8),

            // Sets
            ..._sets.asMap().entries.map((e) => _SetRow(
              index:    e.key,
              entry:    e.value,
              locale:   widget.locale,
              onUpdate: (w, r) => _updateSet(e.key, w, r),
            )),

            // Add set
            TextButton.icon(
              icon:  const Icon(Icons.add, size: 16),
              label: Text(isAr ? 'إضافة سيت' : 'Add Set',
                  style: const TextStyle(fontSize: 12)),
              onPressed: () {
                setState(() => _sets.add(const SetEntry(weight: 0, reps: 0)));
                widget.onUpdate(widget.log.copyWith(sets: _sets));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Set Row ──────────────────────────────────────────────────
class _SetRow extends StatelessWidget {
  final int      index;
  final SetEntry entry;
  final String   locale;
  final void Function(double, int) onUpdate;

  const _SetRow({
    required this.index,
    required this.entry,
    required this.locale,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${index + 1}',
              style: context.text.bodySmall?.copyWith(
                color:      entry.isPR ? AppColors.pr : null,
                fontWeight: entry.isPR ? FontWeight.w700 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _NumField(
              value:    entry.weight,
              decimal:  true,
              onChanged: (v) => onUpdate(v, entry.reps),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NumField(
              value:    entry.reps.toDouble(),
              decimal:  false,
              onChanged: (v) => onUpdate(entry.weight, v.toInt()),
            ),
          ),
          const SizedBox(width: 4),
          if (entry.isPR)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.emoji_events, size: 16, color: AppColors.pr),
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _NumField extends StatefulWidget {
  final double   value;
  final bool     decimal;
  final void Function(double) onChanged;

  const _NumField({
    required this.value,
    required this.decimal,
    required this.onChanged,
  });

  @override
  State<_NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<_NumField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toString(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: TextInputType.numberWithOptions(
          decimal: widget.decimal),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (v) {
        final n = double.tryParse(v);
        if (n != null) widget.onChanged(n);
      },
    );
  }
}

// ─── History Tab ──────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final Map<String, WorkoutLog> logs;
  final String locale;

  const _HistoryTab({required this.logs, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isAr   = locale == 'ar';
    final sorted = logs.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    if (sorted.isEmpty) {
      return EmptyState(
        icon:     Icons.fitness_center,
        title:    isAr ? 'لا يوجد سجل تمرين' : 'No workout history',
        subtitle: isAr ? 'ابدأ جلستك الأولى الآن!' : 'Start your first session!',
      );
    }

    return ListView.builder(
      padding:     const EdgeInsets.all(12),
      itemCount:   sorted.length,
      itemBuilder: (_, i) {
        final log = sorted[i].value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color:        AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center,
                  size: 20, color: AppColors.accent),
            ),
            title: Text(log.session, style: context.text.titleSmall),
            subtitle: Text(
              '${log.exercises.length} ${isAr ? "تمرين" : "ex"} · '
              '${log.exercises.fold(0, (s, e) => s + e.sets.length)} ${isAr ? "سيت" : "sets"}',
              style: context.text.bodySmall,
            ),
            trailing: Text(
              log.dateKey,
              style: context.text.labelSmall,
            ),
          ),
        );
      },
    );
  }
}

extension on List<ExerciseConfig> {
  ExerciseConfig? elementAtOrNull(int i) =>
      i >= 0 && i < length ? this[i] : null;
}
