import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/dialog/app_dialog.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  Stream<List<Map<String, dynamic>>> _historyStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final workouts = snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();

          workouts.sort((a, b) {
            final aDate = a['completedAt'];
            final bDate = b['completedAt'];

            if (aDate is Timestamp && bDate is Timestamp) {
              return bDate.compareTo(aDate);
            }

            return 0;
          });

          return workouts;
        });
  }

  Future<void> _refreshHistory() async {
    await HapticService.light();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _openWorkoutDetail(Map<String, dynamic> workout) async {
    await HapticService.selection();

    if (!mounted) return;

    final completedAt = workout['completedAt'];

    context.push(
      '/history-detail',
      extra: {
        'id': workout['id'] ?? '',
        'workoutTitle': workout['workoutTitle'] ?? 'Workout',
        'exerciseCount': workout['exerciseCount'] ?? 0,
        'durationMinutes': workout['durationMinutes'] ?? 0,
        'completedAt': completedAt is Timestamp
            ? completedAt.toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _deleteWorkout(Map<String, dynamic> workout) async {
    final id = workout['id']?.toString() ?? '';
    final title = workout['workoutTitle']?.toString() ?? 'Workout';

    if (id.isEmpty) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Workout could not be deleted because its ID was missing.',
        title: 'Delete Failed',
      );
      return;
    }

    await HapticService.warning();

    if (!mounted) return;

    final shouldDelete = await AppDialog.confirm(
      context,
      title: 'Delete Workout?',
      message: 'Are you sure you want to delete "$title" from your history?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDanger: true,
    );

    if (!shouldDelete) return;

    try {
      await FirebaseFirestore.instance
          .collection('completed_workouts')
          .doc(id)
          .delete();

      await HapticService.success();

      if (!mounted) return;

      SnackBarService.success(
        context,
        'Workout deleted from history.',
        title: 'Deleted',
      );
    } catch (error) {
      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(context, error.toString(), title: 'Delete Failed');
    }
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return 'Unknown date';
    }

    final date = value.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatSource(Map<String, dynamic> workout) {
    final source = workout['source']?.toString() ?? 'manual';

    if (source == 'ai_generated') {
      return 'AI Generated';
    }

    return 'Manual';
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Workout History'),
        leading: IconButton(
          onPressed: () async {
            await HapticService.light();

            if (context.mounted) {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _historyStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _HistoryLoadingState();
            }

            if (snapshot.hasError) {
              return _HistoryErrorState(
                message: snapshot.error.toString(),
                onRetry: _refreshHistory,
              );
            }

            final workouts = snapshot.data ?? [];

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _refreshHistory,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    sliver: SliverToBoxAdapter(
                      child: _HistoryHeaderCard(
                        totalWorkouts: workouts.length,
                        totalMinutes: workouts.fold<int>(0, (total, workout) {
                          return total + _readInt(workout['durationMinutes']);
                        }),
                      ),
                    ),
                  ),
                  if (workouts.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _HistoryEmptyState(),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      sliver: SliverToBoxAdapter(
                        child: _SectionTitle(
                          title: 'Completed Workouts',
                          subtitle: '${workouts.length} sessions logged',
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      sliver: SliverList.separated(
                        itemCount: workouts.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 14);
                        },
                        itemBuilder: (context, index) {
                          final workout = workouts[index];

                          return Dismissible(
                            key: ValueKey(workout['id'] ?? index),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              await _deleteWorkout(workout);
                              return false;
                            },
                            background: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                              ),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: AppTheme.error,
                              ),
                            ),
                            child: _WorkoutHistoryCard(
                              title:
                                  workout['workoutTitle']?.toString() ??
                                  'Workout',
                              exerciseCount: _readInt(workout['exerciseCount']),
                              duration: _readInt(workout['durationMinutes']),
                              date: _formatDate(workout['completedAt']),
                              source: _formatSource(workout),
                              focus: workout['focus']?.toString() ?? 'General',
                              onTap: () => _openWorkoutDetail(workout),
                              onDelete: () => _deleteWorkout(workout),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryHeaderCard extends StatelessWidget {
  final int totalWorkouts;
  final int totalMinutes;

  const _HistoryHeaderCard({
    required this.totalWorkouts,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final hours = totalMinutes / 60;

    return Container(
      width: double.infinity,
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
          const Icon(Icons.history_rounded, color: Colors.white, size: 42),
          const SizedBox(height: 18),
          const Text(
            'Your Training History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your completed workouts and progress over time.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _HeaderStat(title: 'Workouts', value: '$totalWorkouts'),
              const SizedBox(width: 12),
              _HeaderStat(title: 'Hours', value: hours.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String title;
  final String value;

  const _HeaderStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final String title;
  final int exerciseCount;
  final int duration;
  final String date;
  final String source;
  final String focus;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WorkoutHistoryCard({
    required this.title,
    required this.exerciseCount,
    required this.duration,
    required this.date,
    required this.source,
    required this.focus,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    final isAi = source == 'AI Generated';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: isAi
                    ? AppTheme.primary.withValues(alpha: 0.16)
                    : AppTheme.success.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Icon(
                isAi ? Icons.auto_awesome_rounded : Icons.check_circle_rounded,
                color: isAi ? AppTheme.primary : AppTheme.success,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$exerciseCount exercises • $duration min',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      _SmallChip(label: source),
                      if (focus != 'General') ...[
                        const SizedBox(width: 8),
                        _SmallChip(label: focus),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;

  const _SmallChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 122,
            height: 122,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppTheme.primary,
              size: 58,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'No Workouts Yet',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            'Complete your first workout and it will appear here with your stats and progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLoadingState extends StatelessWidget {
  const _HistoryLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: const [
        _SkeletonHeader(),
        SizedBox(height: 26),
        _SkeletonLine(width: 180, height: 22),
        SizedBox(height: 16),
        _SkeletonCard(),
        SizedBox(height: 14),
        _SkeletonCard(),
        SizedBox(height: 14),
        _SkeletonCard(),
      ],
    );
  }
}

class _HistoryErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _HistoryErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.error.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.error_rounded,
                color: AppTheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'History could not be loaded',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 246,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppTheme.primary.withValues(alpha: 0.14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 48, height: 48, radius: 18),
          const Spacer(),
          const _SkeletonLine(width: 220, height: 28),
          const SizedBox(height: 12),
          const _SkeletonLine(width: 180, height: 16),
          const SizedBox(height: 22),
          Row(
            children: const [
              Expanded(child: _SkeletonBox(height: 70, radius: 22)),
              SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 70, radius: 22)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppTheme.darkCard : AppTheme.lightCard;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: const [
          _SkeletonBox(width: 56, height: 56, radius: 19),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 160, height: 16),
                SizedBox(height: 10),
                _SkeletonLine(width: 120, height: 13),
                SizedBox(height: 10),
                _SkeletonLine(width: 90, height: 20),
              ],
            ),
          ),
          SizedBox(width: 12),
          _SkeletonBox(width: 54, height: 16, radius: 999),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(width: width, height: height, radius: 999);
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonBox({this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
