import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  final String uid;
  final String name;
  final String email;
  final int? age;
  final double? height;
  final double? weight;
  final double? targetWeight;
  final String? goal;
  final String? activityLevel;
  final bool profileCompleted;
  final int streak;
  final int dailyCalories;
  final Timestamp? createdAt;

  const AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.targetWeight,
    this.goal,
    this.activityLevel,
    required this.profileCompleted,
    required this.streak,
    required this.dailyCalories,
    this.createdAt,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'],
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      goal: map['goal'],
      activityLevel: map['activityLevel'],
      profileCompleted: map['profileCompleted'] ?? false,
      streak: map['streak'] ?? 0,
      dailyCalories: map['dailyCalories'] ?? 2400,
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'goal': goal,
      'activityLevel': activityLevel,
      'profileCompleted': profileCompleted,
      'streak': streak,
      'dailyCalories': dailyCalories,
      'createdAt': createdAt,
    };
  }
}