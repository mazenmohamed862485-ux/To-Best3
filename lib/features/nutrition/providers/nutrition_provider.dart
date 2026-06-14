// lib/features/nutrition/providers/nutrition_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/features/nutrition/models/food_model.dart';
import 'package:to_best/services/api_service.dart';
import 'package:to_best/services/cache_service.dart';
import 'package:to_best/services/sync_service.dart';
import 'package:to_best/core/utils/date_helper.dart';

class NutritionState {
  final DailyMealsModel?      today;
  final List<FoodModel>       foodDatabase;
  final Map<String, dynamic>? mealPlan;
  final bool                  loading;
  final String?               error;

  const NutritionState({
    this.today,
    this.foodDatabase = const [],
    this.mealPlan,
    this.loading = false,
    this.error,
  });

  NutritionState copyWith({
    DailyMealsModel?      today,
    List<FoodModel>?      foodDatabase,
    Map<String, dynamic>? mealPlan,
    bool?                 loading,
    String?               error,
    bool                  clearError = false,
  }) =>
      NutritionState(
        today:        today        ?? this.today,
        foodDatabase: foodDatabase ?? this.foodDatabase,
        mealPlan:     mealPlan     ?? this.mealPlan,
        loading:      loading      ?? this.loading,
        error:        clearError ? null : (error ?? this.error),
      );
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier() : super(const NutritionState());

  final _api   = ApiService.instance;
  final _cache = CacheService.instance;
  final _sync  = SyncService.instance;

  Future<void> loadToday(String uid) async {
    final today  = DateHelper.today();
    // Cache first
    final cached = await _cache.getMeals(uid, today);
    if (cached != null) {
      state = state.copyWith(today: DailyMealsModel.fromJson(cached));
    }
    // Server
    try {
      final data  = await _api.fetchUserData(uid);
      final meals = data?['meals']?[today];
      if (meals != null) {
        final model = DailyMealsModel.fromJson(meals as Map<String, dynamic>);
        await _cache.saveMeals(uid, today, model.toJson());
        state = state.copyWith(today: model);
      } else {
        state = state.copyWith(
            today: state.today ??
                DailyMealsModel(uid: uid, dateKey: today, items: []));
      }
    } catch (_) {
      state = state.copyWith(
          today: state.today ??
              DailyMealsModel(uid: uid, dateKey: today, items: []));
    }
  }

  Future<void> addMealEntry(String uid, MealEntry entry) async {
    final today    = DateHelper.today();
    final existing = state.today;
    final updated  = DailyMealsModel(
      uid:         uid,
      dateKey:     today,
      items:       [...(existing?.items ?? []), entry],
      waterLiters: existing?.waterLiters ?? 0,
    );
    state = state.copyWith(today: updated);
    await _cache.saveMeals(uid, today, updated.toJson());
    await _sync.enqueue('SAVE_MEALS', '${uid}_$today', updated.toJson());
  }

  Future<void> removeMealEntry(String uid, int index) async {
    final today    = DateHelper.today();
    final existing = state.today;
    if (existing == null) return;
    final items   = List<MealEntry>.from(existing.items)..removeAt(index);
    final updated = DailyMealsModel(
        uid: uid, dateKey: today, items: items,
        waterLiters: existing.waterLiters);
    state = state.copyWith(today: updated);
    await _cache.saveMeals(uid, today, updated.toJson());
    await _sync.enqueue('SAVE_MEALS', '${uid}_$today', updated.toJson());
  }

  Future<void> updateWater(String uid, double liters) async {
    final today    = DateHelper.today();
    final existing = state.today;
    final updated  = DailyMealsModel(
      uid: uid, dateKey: today,
      items:       existing?.items ?? [],
      waterLiters: liters,
    );
    state = state.copyWith(today: updated);
    await _cache.saveMeals(uid, today, updated.toJson());
    await _sync.enqueue('SAVE_WATER', '${uid}_$today', {'water': liters});
  }
}

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>(
        (_) => NutritionNotifier());
