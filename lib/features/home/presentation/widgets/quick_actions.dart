import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Future<void> _openAction(BuildContext context, _QuickAction action) async {
    await HapticService.selection();

    if (!context.mounted) return;

    context.push(action.route, extra: action.extra);
  }

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      const _QuickAction(
        title: 'Workout',
        subtitle: 'Start training',
        icon: Icons.fitness_center_rounded,
        route: '/generated-workout',
        color: AppTheme.primary,
        extra: {'focus': 'Full Body', 'duration': 35, 'calories': 280},
      ),
      const _QuickAction(
        title: 'Nutrition',
        subtitle: 'Track your meals',
        icon: Icons.restaurant_menu_rounded,
        route: '/nutrition',
        color: AppTheme.success,
      ),
      const _QuickAction(
        title: 'History',
        subtitle: 'View past sessions',
        icon: Icons.history_rounded,
        route: '/workout-history',
        color: AppTheme.info,
      ),
      const _QuickAction(
        title: 'Records',
        subtitle: 'See your bests',
        icon: Icons.emoji_events_rounded,
        route: '/personal-records',
        color: AppTheme.warning,
      ),
      const _QuickAction(
        title: 'Missions',
        subtitle: 'Complete goals',
        icon: Icons.task_alt_rounded,
        route: '/daily-missions',
        color: Color(0xFFEC4899),
      ),
      const _QuickAction(
        title: 'Settings',
        subtitle: 'Manage your app',
        icon: Icons.settings_rounded,
        route: '/settings',
        color: Color(0xFF8B5CF6),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.28,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return AppCard(
          padding: EdgeInsets.zero,
          borderRadius: AppTheme.radiusLarge,
          showShadow: false,
          onTap: () => _openAction(context, action),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -28,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: action.color.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: action.color.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          action.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                action.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: action.color,
                              size: 17,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;
  final Map<String, dynamic>? extra;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
    this.extra,
  });
}
