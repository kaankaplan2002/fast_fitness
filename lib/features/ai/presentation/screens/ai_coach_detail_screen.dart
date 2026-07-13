import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/ai/data/models/ai_coach_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiCoachDetailScreen extends StatelessWidget {
  final AiCoachModel coach;

  const AiCoachDetailScreen({super.key, required this.coach});

  void _generateSuggestedWorkout(BuildContext context) {
    context.push(
      '/generated-workout',
      extra: {
        'focus': coach.suggestedFocus,
        'duration': coach.suggestedDuration,
        'calories': coach.suggestedCalories,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach Detail'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      coach.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      coach.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _generateSuggestedWorkout(context),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  'Generate ${coach.suggestedFocus} Workout',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Recommendation',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  coach.recommendation,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _CoachDetailStatCard(
                      title: 'Focus',
                      value: coach.suggestedFocus,
                      icon: Icons.fitness_center_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _CoachDetailStatCard(
                      title: 'Duration',
                      value: '${coach.suggestedDuration} min',
                      icon: Icons.timer_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _CoachDetailStatCard(
                      title: 'Calories',
                      value: '${coach.suggestedCalories}',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _CoachDetailStatCard(
                      title: 'Streak',
                      value: '${coach.currentStreak}',
                      icon: Icons.whatshot_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Why this recommendation?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              _ReasonTile(
                icon: Icons.calendar_view_week_rounded,
                title: 'Weekly Activity',
                subtitle:
                    'You completed ${coach.weeklyWorkouts} workouts this week.',
              ),
              _ReasonTile(
                icon: Icons.history_rounded,
                title: 'Training History',
                subtitle:
                    'You completed ${coach.totalWorkouts} workouts in total.',
              ),
              _ReasonTile(
                icon: Icons.local_fire_department_rounded,
                title: 'Consistency',
                subtitle: 'Your current streak is ${coach.currentStreak} days.',
              ),
              _ReasonTile(
                icon: Icons.psychology_rounded,
                title: 'Smart Focus Choice',
                subtitle:
                    'The coach suggests ${coach.suggestedFocus} to balance your training routine.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachDetailStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _CoachDetailStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 30),
          const SizedBox(height: 12),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReasonTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
