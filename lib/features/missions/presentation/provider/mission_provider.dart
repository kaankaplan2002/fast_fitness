import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/mission_model.dart';
import '../../data/repository/mission_repository.dart';

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository();
});

final dailyMissionsProvider = FutureProvider<List<MissionModel>>((ref) async {
  final repository = ref.watch(missionRepositoryProvider);
  return repository.getDailyMissions();
});

final completedDailyMissionsProvider = FutureProvider<List<MissionModel>>((
  ref,
) async {
  final missions = await ref.watch(dailyMissionsProvider.future);
  return missions.where((mission) => mission.completed).toList();
});

final claimMissionRewardProvider = FutureProvider.family<void, MissionModel>((
  ref,
  mission,
) async {
  final repository = ref.watch(missionRepositoryProvider);
  await repository.claimMissionReward(mission);

  ref.invalidate(dailyMissionsProvider);
});
