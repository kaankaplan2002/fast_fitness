class NutritionGoalModel {
  final int calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  const NutritionGoalModel({
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  factory NutritionGoalModel.defaultGoal() {
    return const NutritionGoalModel(
      calorieGoal: 2200,
      proteinGoal: 150,
      carbsGoal: 250,
      fatGoal: 70,
    );
  }

  factory NutritionGoalModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return NutritionGoalModel.defaultGoal();

    return NutritionGoalModel(
      calorieGoal: _readInt(map['calorieGoal'], fallback: 2200),
      proteinGoal: _readDouble(map['proteinGoal'], fallback: 150),
      carbsGoal: _readDouble(map['carbsGoal'], fallback: 250),
      fatGoal: _readDouble(map['fatGoal'], fallback: 70),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
    };
  }

  NutritionGoalModel copyWith({
    int? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
  }) {
    return NutritionGoalModel(
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
    );
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _readDouble(dynamic value, {required double fallback}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}
