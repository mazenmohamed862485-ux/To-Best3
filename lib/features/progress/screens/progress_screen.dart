// lib/features/progress/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/progress/providers/progress_provider.dart';
import 'package:to_best/features/progress/models/measurement_model.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/utils/date_helper.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});
  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(progressProvider.notifier).loadMeasurements(user.uid);
    }
  }

  void _showAddMeasurementDialog() {
    final locale = ref.read(localeProvider).languageCode;
    final isAr   = locale == 'ar';
    final controllers = <String, TextEditingController>{
      'weight': TextEditingController(),
      'bodyFat': TextEditingController(),
      'chest': TextEditingController(),
      'waist': TextEditingController(),
      'hips': TextEditingController(),
      'bicepsL': TextEditingController(),
      'bicepsR': TextEditingController(),
      'thighL': TextEditingController(),
      'thighR': TextEditingController(),
    };
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isAr ? 'إضافة قياسات' : 'Add Measurements',
                  style: context.text.titleMedium),
              const SizedBox(height: 16),
              _MeasurementField(
                ctrl:  controllers['weight']!,
                label: isAr ? 'الوزن (kg)' : 'Weight (kg)',
              ),
              _MeasurementField(
                ctrl:  controllers['bodyFat']!,
                label: isAr ? 'نسبة الدهون (%)' : 'Body Fat (%)',
              ),
              _MeasurementField(
                ctrl:  controllers['chest']!,
                label: isAr ? 'الصدر (cm)' : 'Chest (cm)',
              ),
              _MeasurementField(
                ctrl:  controllers['waist']!,
                label: isAr ? 'الخصر (cm)' : 'Waist (cm)',
              ),
              _MeasurementField(
                ctrl:  controllers['hips']!,
                label: isAr ? 'الأرداف (cm)' : 'Hips (cm)',
              ),
              Row(children: [
                Expanded(child: _MeasurementField(
                  ctrl: controllers['bicepsL']!,
                  label: isAr ? 'بايسبس ي' : 'Bicep L',
                )),
                const SizedBox(width: 8),
                Expanded(child: _MeasurementField(
                  ctrl: controllers['bicepsR']!,
                  label: isAr ? 'بايسبس ش' : 'Bicep R',
                )),
              ]),
              Row(children: [
                Expanded(child: _MeasurementField(
                  ctrl: controllers['thighL']!,
                  label: isAr ? 'فخذ ي' : 'Thigh L',
                )),
                const SizedBox(width: 8),
                Expanded(child: _MeasurementField(
                  ctrl: controllers['thighR']!,
                  label: isAr ? 'فخذ ش' : 'Thigh R',
                )),
              ]),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'ملاحظة' : 'Note',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  double? _d(String key) =>
                      double.tryParse(controllers[key]!.text);
                  final entry = MeasurementEntry(
                    dateKey:     DateHelper.today(),
                    weight:      _d('weight'),
                    bodyFat:     _d('bodyFat'),
                    chest:       _d('chest'),
                    waist:       _d('waist'),
                    hips:        _d('hips'),
                    bicepsLeft:  _d('bicepsL'),
                    bicepsRight: _d('bicepsR'),
                    thighLeft:   _d('thighL'),
                    thighRight:  _d('thighR'),
                    note:        noteCtrl.text.isEmpty ? null : noteCtrl.text,
                  );
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref.read(progressProvider.notifier)
                        .addMeasurement(user.uid, entry);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
                child: Text(isAr ? 'حفظ' : 'Save'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale  = ref.watch(localeProvider).languageCode;
    final isAr    = locale == 'ar';
    final progSt  = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'التقدم' : 'Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMeasurementDialog,
          ),
        ],
      ),
      body: progSt.loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.accent))
          : progSt.measurements.isEmpty
              ? EmptyState(
                  icon:     Icons.show_chart,
                  title:    isAr ? 'لا يوجد قياسات بعد' : 'No measurements yet',
                  subtitle: isAr
                      ? 'اضغط + لإضافة قياساتك الأولى'
                      : 'Tap + to add your first measurement',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Latest stats
                      if (progSt.latest != null) ...[
                        _LatestCard(entry: progSt.latest!, locale: locale),
                        const SizedBox(height: 16),
                      ],
                      // Weight chart
                      if (progSt.weightTimeline.length > 1) ...[
                        _WeightChart(
                            data: progSt.weightTimeline, locale: locale),
                        const SizedBox(height: 16),
                      ],
                      // History list
                      Text(
                        isAr ? 'السجل' : 'History',
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...progSt.measurements.reversed.map((m) =>
                          _MeasurementHistoryCard(entry: m, locale: locale)),
                    ],
                  ),
                ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _MeasurementField({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, isDense: true),
    ),
  );
}

class _LatestCard extends StatelessWidget {
  final MeasurementEntry entry;
  final String locale;
  const _LatestCard({required this.entry, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? 'آخر قياس' : 'Latest Measurement',
                style: context.text.titleSmall),
            const SizedBox(height: 10),
            if (entry.weight != null)
              Row(
                children: [
                  Text(
                    '${entry.weight!.toStringAsFixed(1)} kg',
                    style: context.text.headlineSmall?.copyWith(
                      color: AppColors.accent, fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.dateKey, style: context.text.bodySmall),
                ],
              ),
            if (entry.bodyFat != null)
              Text(
                '${isAr ? "الدهون" : "Body Fat"}: ${entry.bodyFat!.toStringAsFixed(1)}%',
                style: context.text.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String locale;
  const _WeightChart({required this.data, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    final spots = data
        .asMap()
        .entries
        .where((e) => e.value['value'] != null)
        .map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['value'] as double),
            ))
        .toList();

    if (spots.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? 'منحنى الوزن' : 'Weight Chart',
                style: context.text.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: context.theme.dividerColor,
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) =>
                        FlLine(color: Colors.transparent),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots:        spots,
                      isCurved:     true,
                      color:        AppColors.accent,
                      barWidth:     2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent.withOpacity(0.1),
                      ),
                      dotData: FlDotData(show: spots.length < 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementHistoryCard extends StatelessWidget {
  final MeasurementEntry entry;
  final String           locale;
  const _MeasurementHistoryCard({required this.entry, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(entry.dateKey, style: context.text.titleSmall),
        subtitle: Text(
          [
            if (entry.weight  != null) '⚖️ ${entry.weight!.toStringAsFixed(1)}kg',
            if (entry.bodyFat != null) '🔥 ${entry.bodyFat!.toStringAsFixed(1)}%',
            if (entry.chest   != null) '${isAr ? "صدر" : "chest"}: ${entry.chest!.toInt()}cm',
            if (entry.waist   != null) '${isAr ? "خصر" : "waist"}: ${entry.waist!.toInt()}cm',
          ].join('  ·  '),
          style: context.text.bodySmall,
        ),
      ),
    );
  }
}
