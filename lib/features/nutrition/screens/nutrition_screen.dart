// lib/features/nutrition/screens/nutrition_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/auth/providers/auth_provider.dart';
import 'package:to_best/features/nutrition/providers/nutrition_provider.dart';
import 'package:to_best/features/nutrition/models/food_model.dart';
import 'package:to_best/core/constants/app_colors.dart';
import 'package:to_best/core/utils/date_helper.dart';
import 'package:to_best/core/utils/extensions.dart';
import 'package:to_best/widgets/common_widgets.dart';
import 'package:to_best/app.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});
  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(nutritionProvider.notifier).loadToday(user.uid);
    }
  }

  void _showAddFoodDialog() {
    final locale = ref.read(localeProvider).languageCode;
    final isAr   = locale == 'ar';
    final nameCtrl = TextEditingController();
    final calCtrl  = TextEditingController();
    final protCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl  = TextEditingController();
    final gramCtrl = TextEditingController(text: '100');
    String mealType = 'snack';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocalState) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isAr ? 'إضافة وجبة' : 'Add Food',
                  style: ctx.text.titleMedium),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'اسم الطعام' : 'Food Name',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: calCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: isAr ? 'سعرات' : 'Calories',
                    ),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(
                    controller: gramCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: isAr ? 'جرام' : 'Grams'),
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(
                  controller: protCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: isAr ? 'بروتين' : 'Protein'),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: carbCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: isAr ? 'كارب' : 'Carbs'),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: fatCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: isAr ? 'دهون' : 'Fat'),
                )),
              ]),
              const SizedBox(height: 10),
              // Meal type
              DropdownButtonFormField<String>(
                value: mealType,
                decoration: InputDecoration(
                  labelText: isAr ? 'نوع الوجبة' : 'Meal Type',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'breakfast',
                    child: Text(isAr ? 'إفطار' : 'Breakfast'),
                  ),
                  DropdownMenuItem(
                    value: 'lunch',
                    child: Text(isAr ? 'غداء' : 'Lunch'),
                  ),
                  DropdownMenuItem(
                    value: 'dinner',
                    child: Text(isAr ? 'عشاء' : 'Dinner'),
                  ),
                  DropdownMenuItem(
                    value: 'snack',
                    child: Text(isAr ? 'سناك' : 'Snack'),
                  ),
                ],
                onChanged: (v) => setLocalState(() => mealType = v ?? 'snack'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final entry = MealEntry(
                    foodName: nameCtrl.text.trim(),
                    grams:    double.tryParse(gramCtrl.text) ?? 100,
                    calories: double.tryParse(calCtrl.text)  ?? 0,
                    protein:  double.tryParse(protCtrl.text) ?? 0,
                    carbs:    double.tryParse(carbCtrl.text) ?? 0,
                    fat:      double.tryParse(fatCtrl.text)  ?? 0,
                    mealType: mealType,
                    ts:       DateTime.now().millisecondsSinceEpoch,
                  );
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref.read(nutritionProvider.notifier)
                        .addMealEntry(user.uid, entry);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
                child: Text(isAr ? 'إضافة' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr   = locale == 'ar';
    final user   = ref.watch(currentUserProvider);
    final nutSt  = ref.watch(nutritionProvider);
    final meals  = nutSt.today;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'التغذية' : 'Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddFoodDialog,
            tooltip: isAr ? 'إضافة وجبة' : 'Add Food',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Macros summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      isAr ? 'ملخص اليوم' : "Today's Summary",
                      style: context.text.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    // Calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${(meals?.totalCalories ?? 0).toInt()}',
                              style: context.text.headlineSmall?.copyWith(
                                color:      AppColors.warn,
                                fontWeight: FontWeight.w900,
                                fontSize:   36,
                              ),
                            ),
                            Text(
                              '/ ${user?.dailyCals ?? 0} kcal',
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    MacroProgressBar(
                      label:   isAr ? 'بروتين' : 'Protein',
                      current: meals?.totalProtein ?? 0,
                      target:  (user?.protein ?? 0).toDouble(),
                      color:   AppColors.info,
                    ),
                    const SizedBox(height: 8),
                    MacroProgressBar(
                      label:   isAr ? 'كارب' : 'Carbs',
                      current: meals?.totalCarbs ?? 0,
                      target:  (user?.carbs ?? 0).toDouble(),
                      color:   AppColors.warn,
                    ),
                    const SizedBox(height: 8),
                    MacroProgressBar(
                      label:   isAr ? 'دهون' : 'Fat',
                      current: meals?.totalFat ?? 0,
                      target:  (user?.fat ?? 0).toDouble(),
                      color:   AppColors.err,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Water card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop_outlined,
                                size: 18, color: AppColors.info),
                            const SizedBox(width: 6),
                            Text(
                              isAr ? 'الماء' : 'Water',
                              style: context.text.titleSmall,
                            ),
                          ],
                        ),
                        Text(
                          '${(meals?.waterLiters ?? 0).toStringAsFixed(1)} L',
                          style: context.text.titleMedium?.copyWith(
                              color: AppColors.info),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [0.25, 0.5, 0.75, 1.0].map((amount) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: OutlinedButton(
                              onPressed: () {
                                if (user == null) return;
                                final current = meals?.waterLiters ?? 0;
                                ref.read(nutritionProvider.notifier)
                                    .updateWater(user.uid, current + amount);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                side: const BorderSide(color: AppColors.info),
                              ),
                              child: Text('+${amount}L',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.info)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Food items
            if (meals == null || meals.items.isEmpty)
              EmptyState(
                icon:     Icons.restaurant_outlined,
                title:    isAr ? 'لا يوجد وجبات اليوم' : 'No food logged today',
                subtitle: isAr ? 'اضغط + لإضافة وجبة' : 'Tap + to add food',
              )
            else ...[
              Text(
                isAr ? 'الوجبات' : 'Meals',
                style: context.text.titleSmall,
              ),
              const SizedBox(height: 8),
              ...meals.items.asMap().entries.map((e) => Dismissible(
                key: Key('meal_${e.key}_${e.value.ts}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.only(right: 16),
                  color: AppColors.err,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  if (user != null) {
                    ref.read(nutritionProvider.notifier)
                        .removeMealEntry(user.uid, e.key);
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color:        AppColors.warn.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant,
                          size: 20, color: AppColors.warn),
                    ),
                    title: Text(
                      e.value.foodName.isEmpty
                          ? (isAr ? 'وجبة' : 'Meal')
                          : e.value.foodName,
                      style: context.text.bodyMedium,
                    ),
                    subtitle: Text(
                      '${e.value.calories.toInt()} kcal · '
                      '${isAr ? "ب" : "P"}:${e.value.protein.toInt()} '
                      '${isAr ? "ك" : "C"}:${e.value.carbs.toInt()} '
                      '${isAr ? "د" : "F"}:${e.value.fat.toInt()}',
                      style: context.text.bodySmall,
                    ),
                    trailing: Text(
                      '${e.value.grams.toInt()}g',
                      style: context.text.labelSmall,
                    ),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
