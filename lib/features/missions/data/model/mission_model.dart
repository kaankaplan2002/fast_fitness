enum MissionType { completeWorkout, burnCalories, earnXp, rateWorkout }

enum MissionRewardType { xp }

class MissionModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final MissionType type;
  final MissionRewardType rewardType;
  final int requiredValue;
  final int currentValue;
  final int rewardValue;
  final bool completed;
  final bool claimed;

  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.rewardType,
    required this.requiredValue,
    required this.currentValue,
    required this.rewardValue,
    required this.completed,
    required this.claimed,
  });

  double get progress {
    if (requiredValue <= 0) return 0;
    return (currentValue / requiredValue).clamp(0, 1);
  }

  MissionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    MissionType? type,
    MissionRewardType? rewardType,
    int? requiredValue,
    int? currentValue,
    int? rewardValue,
    bool? completed,
    bool? claimed,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rewardType: rewardType ?? this.rewardType,
      requiredValue: requiredValue ?? this.requiredValue,
      currentValue: currentValue ?? this.currentValue,
      rewardValue: rewardValue ?? this.rewardValue,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
    );
  }
}
