enum AchievementCategory { workout, streak, calories, xp, rating, consistency }

enum AchievementRequirementType {
  workoutCount,
  streakDays,
  caloriesBurned,
  totalXp,
  fiveStarRatings,
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRequirementType requirementType;
  final int requiredValue;
  final int currentValue;
  final bool unlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirementType,
    required this.requiredValue,
    required this.currentValue,
    required this.unlocked,
  });

  double get progress {
    if (requiredValue <= 0) return 0;
    final value = currentValue / requiredValue;
    return value.clamp(0, 1);
  }

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementCategory? category,
    AchievementRequirementType? requirementType,
    int? requiredValue,
    int? currentValue,
    bool? unlocked,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      requirementType: requirementType ?? this.requirementType,
      requiredValue: requiredValue ?? this.requiredValue,
      currentValue: currentValue ?? this.currentValue,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
