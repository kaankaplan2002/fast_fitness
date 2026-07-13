class UserLevelModel {
  final int level;
  final int totalXp;
  final int currentLevelXp;
  final int nextLevelXp;

  const UserLevelModel({
    required this.level,
    required this.totalXp,
    required this.currentLevelXp,
    required this.nextLevelXp,
  });

  double get progress {
    if (nextLevelXp == 0) return 0;
    return (currentLevelXp / nextLevelXp).clamp(0.0, 1.0);
  }

  factory UserLevelModel.fromTotalXp(int totalXp) {
    var level = 1;
    var remainingXp = totalXp;
    var requiredXp = 500;

    while (remainingXp >= requiredXp) {
      remainingXp -= requiredXp;
      level++;
      requiredXp = level * 500;
    }

    return UserLevelModel(
      level: level,
      totalXp: totalXp,
      currentLevelXp: remainingXp,
      nextLevelXp: requiredXp,
    );
  }
}
