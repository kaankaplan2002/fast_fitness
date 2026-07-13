import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/missions/data/model/mission_model.dart';
import 'package:fast_fitness/features/missions/presentation/provider/mission_provider.dart';
import 'package:fast_fitness/features/missions/presentation/widget/mission_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyMissionsScreen extends ConsumerStatefulWidget {
  const DailyMissionsScreen({super.key});

  @override
  ConsumerState<DailyMissionsScreen> createState() =>
      _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends ConsumerState<DailyMissionsScreen> {
  String? claimingMissionId;

  Future<void> _claimMission(MissionModel mission) async {
    setState(() {
      claimingMissionId = mission.id;
    });

    try {
      await ref.read(missionRepositoryProvider).claimMissionReward(mission);

      ref.invalidate(dailyMissionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+${mission.rewardValue} XP claimed successfully.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          claimingMissionId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(dailyMissionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Missions'), centerTitle: false),
      body: missionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Daily missions could not be loaded.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (missions) {
          final completedCount = missions
              .where((mission) => mission.completed)
              .length;
          final claimedCount = missions
              .where((mission) => mission.claimed)
              .length;
          final totalCount = missions.length;
          final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              ref.invalidate(dailyMissionsProvider);
              await ref.read(dailyMissionsProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.96),
                            AppTheme.primary.withValues(alpha: 0.58),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.task_alt_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Today’s Missions',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete small daily goals, collect XP rewards and build consistency.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0, 1),
                              minHeight: 9,
                              backgroundColor: Colors.white.withValues(alpha: 0.22),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              _MissionHeaderStat(
                                title: 'Completed',
                                value: '$completedCount/$totalCount',
                              ),
                              const SizedBox(width: 12),
                              _MissionHeaderStat(
                                title: 'Claimed',
                                value: '$claimedCount',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList.separated(
                    itemCount: missions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final mission = missions[index];

                      return MissionCard(
                        mission: mission,
                        claiming: claimingMissionId == mission.id,
                        onClaim: () => _claimMission(mission),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MissionHeaderStat extends StatelessWidget {
  final String title;
  final String value;

  const _MissionHeaderStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withValues(alpha: 0.16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
