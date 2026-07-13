import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/service/snackbar_service.dart';
import 'package:fast_fitness/core/widgets/app_button.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String name;
  final String muscleGroup;
  final String equipment;
  final String difficulty;
  final int sets;
  final String reps;
  final int restSeconds;
  final String description;
  final String gifUrl;

  const ExerciseDetailScreen({
    super.key,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.difficulty,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.description,
    required this.gifUrl,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool isFavorite = false;
  bool isSharing = false;

  Color get difficultyColor {
    switch (widget.difficulty.toLowerCase()) {
      case 'advanced':
        return AppTheme.error;
      case 'intermediate':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  String get safeDescription {
    final trimmedDescription = widget.description.trim();

    if (trimmedDescription.isEmpty) {
      return 'Exercise instructions have not been added yet. Keep your '
          'movement controlled, maintain proper posture, and avoid using '
          'more weight than you can handle safely.';
    }

    return trimmedDescription;
  }

  List<String> get performanceSteps {
    final description = widget.description.trim();

    if (description.isEmpty) {
      return [
        'Set up the equipment and choose a manageable resistance.',
        'Maintain a stable posture before beginning the movement.',
        'Perform each repetition with a controlled range of motion.',
        'Breathe steadily and avoid holding your breath.',
        'Stop the set if your technique begins to break down.',
      ];
    }

    final normalized = description
        .replaceAll('\r', '\n')
        .split(RegExp(r'\n+|(?<=[.!?])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (normalized.length >= 2) {
      return normalized.take(6).toList();
    }

    return [
      description,
      'Use a controlled tempo throughout the movement.',
      'Keep the target muscle engaged during every repetition.',
      'Avoid sacrificing technique to complete additional reps.',
    ];
  }

  List<String> get techniqueTips {
    return [
      'Use a weight that lets you complete every repetition with control.',
      'Keep your core engaged to support a stable body position.',
      'Move through a comfortable range without forcing the joints.',
      'Focus on the target muscle instead of rushing the movement.',
    ];
  }

  List<String> get commonMistakes {
    return [
      'Using momentum instead of controlled muscle tension.',
      'Choosing resistance that is too heavy for proper technique.',
      'Moving too quickly through the most difficult part of the repetition.',
      'Holding your breath or losing core stability.',
    ];
  }

  Map<String, dynamic> _exerciseMap() {
    return {
      'id': '',
      'name': widget.name,
      'muscleGroup': widget.muscleGroup,
      'equipment': widget.equipment,
      'difficulty': widget.difficulty,
      'sets': widget.sets,
      'reps': widget.reps,
      'restSeconds': widget.restSeconds,
      'description': widget.description,
      'gifUrl': widget.gifUrl,
    };
  }

  Future<void> _goBack() async {
    await HapticService.light();

    if (!mounted) return;

    context.pop();
  }

  Future<void> _toggleFavorite() async {
    await HapticService.selection();

    if (!mounted) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    if (!mounted) return;

    if (isFavorite) {
      SnackBarService.success(
        context,
        '${widget.name} was added to favorites.',
        title: 'Added to Favorites',
      );
    } else {
      SnackBarService.info(
        context,
        '${widget.name} was removed from favorites.',
        title: 'Removed from Favorites',
      );
    }
  }

  Future<void> _shareExercise() async {
    if (isSharing) return;

    await HapticService.light();

    setState(() {
      isSharing = true;
    });

    try {
      final text =
          '''
FastFitness Exercise

${widget.name}
Muscle group: ${widget.muscleGroup}
Equipment: ${widget.equipment}
Difficulty: ${widget.difficulty}
Target: ${widget.sets} sets × ${widget.reps} reps
Rest: ${widget.restSeconds} seconds

$safeDescription
''';

      await Share.share(text, subject: 'FastFitness Exercise: ${widget.name}');

      if (!mounted) return;

      await HapticService.success();
    } catch (_) {
      if (!mounted) return;

      await HapticService.error();

      if (!mounted) return;

      SnackBarService.error(
        context,
        'Exercise details could not be shared.',
        title: 'Share Failed',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSharing = false;
        });
      }
    }
  }

  Future<void> _startExercise() async {
    await HapticService.selection();

    if (!mounted) return;

    context.push(
      '/workout-session',
      extra: {
        'title': '${widget.name} Workout',
        'exercises': [_exerciseMap()],
        'currentExerciseIndex': 0,
        'completedSets': 0,
        'elapsedSeconds': 0,
        'source': 'exercise_library',
        'focus': widget.muscleGroup,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Detail'),
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _toggleFavorite,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isFavorite),
                color: isFavorite ? AppTheme.error : AppTheme.textSecondary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Share exercise',
            onPressed: isSharing ? null : _shareExercise,
            icon: isSharing
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.ios_share_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExerciseMediaCard(
                name: widget.name,
                gifUrl: widget.gifUrl,
                muscleGroup: widget.muscleGroup,
              ),
              const SizedBox(height: 24),

              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  AppChip(
                    label: widget.muscleGroup,
                    icon: Icons.accessibility_new_rounded,
                  ),
                  AppChip(
                    label: widget.equipment,
                    icon: Icons.fitness_center_rounded,
                  ),
                  AppChip(
                    label: widget.difficulty,
                    icon: Icons.signal_cellular_alt_rounded,
                    backgroundColor: difficultyColor.withValues(alpha: 0.12),
                    foregroundColor: difficultyColor,
                  ),
                ],
              ),
              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: _ExerciseMetricCard(
                      title: 'Sets',
                      value: '${widget.sets}',
                      icon: Icons.repeat_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExerciseMetricCard(
                      title: 'Reps',
                      value: widget.reps,
                      icon: Icons.numbers_rounded,
                      color: AppTheme.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExerciseMetricCard(
                      title: 'Rest',
                      value: '${widget.restSeconds}s',
                      icon: Icons.timer_outlined,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const _SectionHeader(
                title: 'How to Perform',
                subtitle: 'Follow each step with controlled technique',
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(height: 16),

              _InstructionCard(
                description: safeDescription,
                steps: performanceSteps,
              ),
              const SizedBox(height: 26),

              const _SectionHeader(
                title: 'Technique Tips',
                subtitle: 'Small details that improve each repetition',
                icon: Icons.lightbulb_rounded,
              ),
              const SizedBox(height: 16),

              _AdviceCard(
                items: techniqueTips,
                icon: Icons.check_circle_rounded,
                color: AppTheme.success,
              ),
              const SizedBox(height: 26),

              const _SectionHeader(
                title: 'Common Mistakes',
                subtitle: 'Avoid these issues during your working sets',
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 16),

              _AdviceCard(
                items: commonMistakes,
                icon: Icons.close_rounded,
                color: AppTheme.error,
              ),
              const SizedBox(height: 26),

              _CoachTipCard(
                muscleGroup: widget.muscleGroup,
                difficulty: widget.difficulty,
              ),
              const SizedBox(height: 28),

              AppButton(
                text: 'Start Exercise',
                icon: Icons.play_arrow_rounded,
                onPressed: _startExercise,
              ),
              const SizedBox(height: 12),

              AppButton(
                text: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                type: AppButtonType.secondary,
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseMediaCard extends StatelessWidget {
  final String name;
  final String gifUrl;
  final String muscleGroup;

  const _ExerciseMediaCard({
    required this.name,
    required this.gifUrl,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXXLarge,
      showBorder: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
        child: SizedBox(
          height: 250,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (gifUrl.trim().isNotEmpty)
                Image.network(
                  gifUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    final expectedBytes = loadingProgress.expectedTotalBytes;

                    final progress = expectedBytes == null
                        ? null
                        : loadingProgress.cumulativeBytesLoaded / expectedBytes;

                    return Container(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        value: progress,
                        color: AppTheme.primary,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return _ExerciseMediaPlaceholder(name: name);
                  },
                )
              else
                _ExerciseMediaPlaceholder(name: name),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.66),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        muscleGroup,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseMediaPlaceholder extends StatelessWidget {
  final String name;

  const _ExerciseMediaPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -48,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -78,
            left: -55,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 76,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ExerciseMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      borderRadius: AppTheme.radiusLarge,
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 11),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final String description;
  final List<String> steps;

  const _InstructionCard({required this.description, required this.steps});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      borderRadius: AppTheme.radiusXLarge,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == steps.length - 1 ? 0 : 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;

  const _AdviceCard({
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: AppTheme.radiusXLarge,
      showShadow: false,
      child: Column(
        children: items.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key == items.length - 1 ? 0 : 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CoachTipCard extends StatelessWidget {
  final String muscleGroup;
  final String difficulty;

  const _CoachTipCard({required this.muscleGroup, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXLarge,
      showBorder: false,
      showShadow: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withValues(alpha: 0.20),
              AppTheme.primary.withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.primary,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coach Tip',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Because this is a $difficulty $muscleGroup exercise, '
                    'prioritize controlled repetitions and consistent form '
                    'before increasing resistance.',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
