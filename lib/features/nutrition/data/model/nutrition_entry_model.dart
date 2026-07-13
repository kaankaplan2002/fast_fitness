import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType { breakfast, lunch, dinner, snack }

class NutritionEntryModel {
  final String id;
  final String userId;
  final String foodName;
  final MealType mealType;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;
  final DateTime createdAt;

  const NutritionEntryModel({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
    required this.createdAt,
  });

  factory NutritionEntryModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return NutritionEntryModel(
      id: id,
      userId: map['userId'] ?? '',
      foodName: map['foodName'] ?? '',
      mealType: _mealTypeFromString(map['mealType']),
      calories: _readInt(map['calories']),
      protein: _readDouble(map['protein']),
      carbs: _readDouble(map['carbs']),
      fat: _readDouble(map['fat']),
      date: _readDate(map['date']) ?? DateTime.now(),
      createdAt: _readDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodName': foodName,
      'mealType': mealType.name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NutritionEntryModel copyWith({
    String? id,
    String? userId,
    String? foodName,
    MealType? mealType,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return NutritionEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static MealType _mealTypeFromString(dynamic value) {
    final text = value?.toString();

    return MealType.values.firstWhere(
      (type) => type.name == text,
      orElse: () => MealType.snack,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
