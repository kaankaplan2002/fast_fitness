import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/achievement_model.dart';
import '../../data/repository/achievement_repository.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final achievementsProvider = FutureProvider<List<AchievementModel>>((
  ref,
) async {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getAchievements();
});

final unlockedAchievementsProvider = FutureProvider<List<AchievementModel>>((
  ref,
) async {
  final achievements = await ref.watch(achievementsProvider.future);
  return achievements.where((achievement) => achievement.unlocked).toList();
});

final lockedAchievementsProvider = FutureProvider<List<AchievementModel>>((
  ref,
) async {
  final achievements = await ref.watch(achievementsProvider.future);
  return achievements.where((achievement) => !achievement.unlocked).toList();
});
