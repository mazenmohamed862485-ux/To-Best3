// lib/features/nutrition/models/food_model.dart
class FoodModel {
  final String  name;
  final double  calories;
  final double  protein;
  final double  carbs;
  final double  fat;
  final String  unit;      // g, ml, piece, etc.
  final double  serving;   // default serving size

  const FoodModel({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.unit    = 'g',
    this.serving = 100,
  });

  factory FoodModel.fromJson(Map<String, dynamic> j) => FoodModel(
    name:     j['name']?.toString()          ?? '',
    calories: (j['calories'] as num?)?.toDouble() ?? 0,
    protein:  (j['protein']  as num?)?.toDouble() ?? 0,
    carbs:    (j['carbs']    as num?)?.toDouble() ?? 0,
    fat:      (j['fat']      as num?)?.toDouble() ?? 0,
    unit:     j['unit']?.toString()          ?? 'g',
    serving:  (j['serving']  as num?)?.toDouble() ?? 100,
  );

  Map<String, dynamic> toJson() => {
    'name':     name,
    'calories': calories,
    'protein':  protein,
    'carbs':    carbs,
    'fat':      fat,
    'unit':     unit,
    'serving':  serving,
  };

  /// Scale macros to a custom gram amount
  FoodModel scaled(double grams) {
    final ratio = grams / (serving == 0 ? 100 : serving);
    return FoodModel(
      name:     name,
      calories: calories * ratio,
      protein:  protein  * ratio,
      carbs:    carbs    * ratio,
      fat:      fat      * ratio,
      unit:     unit,
      serving:  grams,
    );
  }
}

class MealEntry {
  final String  foodName;
  final double  grams;
  final double  calories;
  final double  protein;
  final double  carbs;
  final double  fat;
  final String  mealType; // breakfast, lunch, dinner, snack
  final int     ts;

  const MealEntry({
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.mealType = 'snack',
    required this.ts,
  });

  factory MealEntry.fromJson(Map<String, dynamic> j) => MealEntry(
    foodName: j['foodName']?.toString()        ?? '',
    grams:    (j['grams']    as num?)?.toDouble() ?? 0,
    calories: (j['calories'] as num?)?.toDouble() ?? 0,
    protein:  (j['protein']  as num?)?.toDouble() ?? 0,
    carbs:    (j['carbs']    as num?)?.toDouble() ?? 0,
    fat:      (j['fat']      as num?)?.toDouble() ?? 0,
    mealType: j['mealType']?.toString()        ?? 'snack',
    ts:       (j['ts']       as num?)?.toInt()    ??
              DateTime.now().millisecondsSinceEpoch,
  );

  Map<String, dynamic> toJson() => {
    'foodName': foodName,
    'grams':    grams,
    'calories': calories,
    'protein':  protein,
    'carbs':    carbs,
    'fat':      fat,
    'mealType': mealType,
    'ts':       ts,
  };
}

class DailyMealsModel {
  final String          uid;
  final String          dateKey;
  final List<MealEntry> items;
  final double          waterLiters;

  const DailyMealsModel({
    required this.uid,
    required this.dateKey,
    required this.items,
    this.waterLiters = 0,
  });

  double get totalCalories => items.fold(0, (s, i) => s + i.calories);
  double get totalProtein  => items.fold(0, (s, i) => s + i.protein);
  double get totalCarbs    => items.fold(0, (s, i) => s + i.carbs);
  double get totalFat      => items.fold(0, (s, i) => s + i.fat);

  factory DailyMealsModel.fromJson(Map<String, dynamic> j) => DailyMealsModel(
    uid:         j['uid']?.toString()              ?? '',
    dateKey:     j['dateKey']?.toString()          ?? '',
    items:       (j['items'] as List?)
                     ?.map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
                     .toList() ??
                 [],
    waterLiters: (j['waterLiters'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'uid':         uid,
    'dateKey':     dateKey,
    'items':       items.map((i) => i.toJson()).toList(),
    'waterLiters': waterLiters,
  };
}
