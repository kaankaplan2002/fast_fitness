import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/widgets/app_loading_indicator.dart';
import 'package:fast_fitness/core/widgets/app_section_title.dart';
import 'package:fast_fitness/core/widgets/empty_state.dart';
import 'package:fast_fitness/core/widgets/error_state.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';
import 'package:fast_fitness/features/exercises/presentation/providers/exercise_provider.dart';
import 'package:fast_fitness/features/exercises/presentation/search/exercise_search_delegate.dart';
import 'package:fast_fitness/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  bool showOnlyFavorites = false;

  final Set<String> favoriteExerciseIds = <String>{};

  final List<_MuscleFilter> muscleFilters = const [
    _MuscleFilter(title: 'Chest', icon: Icons.accessibility_new_rounded),
    _MuscleFilter(title: 'Back', icon: Icons.fitness_center_rounded),
    _MuscleFilter(title: 'Legs', icon: Icons.directions_run_rounded),
    _MuscleFilter(title: 'Core', icon: Icons.sports_gymnastics_rounded),
  ];

  Future<void> _selectMuscleGroup(String muscleGroup) async {
    await HapticService.selection();

    ref
        .read(selectedMuscleGroupProvider.notifier)
        .selectMuscleGroup(muscleGroup);
  }

  Future<void> _toggleFavoritesFilter() async {
    await HapticService.selection();

    if (!mounted) return;

    setState(() {
      showOnlyFavorites = !showOnlyFavorites;
    });
  }

  Future<void> _toggleFavorite(String exerciseId) async {
    await HapticService.selection();

    if (!mounted) return;

    setState(() {
      if (favoriteExerciseIds.contains(exerciseId)) {
        favoriteExerciseIds.remove(exerciseId);
      } else {
        favoriteExerciseIds.add(exerciseId);
      }
    });
  }

  void _toggleFavoriteFromSearch(String exerciseId) {
    if (!mounted) return;

    setState(() {
      if (favoriteExerciseIds.contains(exerciseId)) {
        favoriteExerciseIds.remove(exerciseId);
      } else {
        favoriteExerciseIds.add(exerciseId);
      }
    });
  }

  Future<void> _openExerciseDetail(ExerciseModel exercise) async {
    await HapticService.light();

    if (!mounted) return;

    await context.push(
      '/exercise-detail',
      extra: {
        'name': exercise.name,
        'muscleGroup': exercise.muscleGroup,
        'equipment': exercise.equipment,
        'difficulty': exercise.difficulty,
        'sets': exercise.sets,
        'reps': exercise.reps,
        'restSeconds': exercise.restSeconds,
        'description': exercise.description,
        'gifUrl': exercise.gifUrl,
      },
    );
  }

  Future<void> _openSearch(List<ExerciseModel> allExercises) async {
    await HapticService.selection();

    if (!mounted) return;

    final selectedExercise = await showSearch<ExerciseModel?>(
      context: context,
      delegate: ExerciseSearchDelegate(
        exercises: allExercises,
        favoriteExerciseIds: favoriteExerciseIds,
        onFavoriteToggle: _toggleFavoriteFromSearch,
      ),
    );

    if (!mounted) return;

    setState(() {});

    if (selectedExercise != null) {
      await _openExerciseDetail(selectedExercise);
    }
  }

  Future<void> _refreshExercises() async {
    await HapticService.light();

    ref.invalidate(exercisesProvider);
  }

  List<ExerciseModel> _filterExercises({
    required List<ExerciseModel> allExercises,
    required String selectedMuscle,
  }) {
    var filteredExercises = allExercises.where((exercise) {
      return exercise.muscleGroup.trim().toLowerCase() ==
          selectedMuscle.trim().toLowerCase();
    }).toList();

    if (showOnlyFavorites) {
      filteredExercises = filteredExercises.where((exercise) {
        return favoriteExerciseIds.contains(exercise.id);
      }).toList();
    }

    filteredExercises.sort((first, second) {
      final firstFavorite = favoriteExerciseIds.contains(first.id);
      final secondFavorite = favoriteExerciseIds.contains(second.id);

      if (firstFavorite != secondFavorite) {
        return firstFavorite ? -1 : 1;
      }

      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });

    return filteredExercises;
  }

  String _emptyStateTitle() {
    if (showOnlyFavorites) {
      return 'No Favorite Exercises';
    }

    return 'No Exercises Available';
  }

  String _emptyStateMessage(String selectedMuscle) {
    if (showOnlyFavorites) {
      return 'Add $selectedMuscle exercises to your favorites and they will appear here.';
    }

    return 'There are no $selectedMuscle exercises available yet.';
  }

  @override
  Widget build(BuildContext context) {
    final selectedMuscle = ref.watch(selectedMuscleGroupProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: _ExerciseHeaderCard(),
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: exercisesAsync.when(
              loading: () {
                return const _SearchLauncher(isEnabled: false, onTap: null);
              },
              error: (_, __) {
                return const _SearchLauncher(isEnabled: false, onTap: null);
              },
              data: (allExercises) {
                return _SearchLauncher(
                  isEnabled: allExercises.isNotEmpty,
                  onTap: allExercises.isEmpty
                      ? null
                      : () => _openSearch(allExercises),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: muscleFilters.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 10);
              },
              itemBuilder: (context, index) {
                final filter = muscleFilters[index];
                final isSelected = filter.title == selectedMuscle;

                return _MuscleFilterChip(
                  title: filter.title,
                  icon: filter.icon,
                  isSelected: isSelected,
                  onTap: () => _selectMuscleGroup(filter.title),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: AppSectionTitle(
                    title: '$selectedMuscle Exercises',
                    subtitle: showOnlyFavorites
                        ? 'Showing your favorite exercises'
                        : 'Choose an exercise to view its details',
                  ),
                ),
                const SizedBox(width: 12),
                _FavoriteFilterButton(
                  isSelected: showOnlyFavorites,
                  favoriteCount: favoriteExerciseIds.length,
                  onTap: _toggleFavoritesFilter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: exercisesAsync.when(
              loading: () =>
                  const AppLoadingIndicator(message: 'Loading exercises...'),
              error: (error, stackTrace) {
                return AppErrorState(
                  title: 'Exercises could not be loaded',
                  message:
                      'We could not retrieve the exercise library. Check your connection and try again.',
                  onRetry: () {
                    ref.invalidate(exercisesProvider);
                  },
                );
              },
              data: (allExercises) {
                final exercises = _filterExercises(
                  allExercises: allExercises,
                  selectedMuscle: selectedMuscle,
                );

                if (exercises.isEmpty) {
                  return RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _refreshExercises,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.42,
                          child: AppEmptyState(
                            title: _emptyStateTitle(),
                            message: _emptyStateMessage(selectedMuscle),
                            icon: showOnlyFavorites
                                ? Icons.favorite_border_rounded
                                : Icons.fitness_center_rounded,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: _refreshExercises,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) {
                      return const SizedBox(height: 14);
                    },
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];

                      return ExerciseCard(
                        exercise: exercise,
                        isFavorite: favoriteExerciseIds.contains(exercise.id),
                        onTap: () => _openExerciseDetail(exercise),
                        onFavoriteTap: () {
                          _toggleFavorite(exercise.id);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchLauncher extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;

  const _SearchLauncher({required this.isEnabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.07),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isEnabled ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  isEnabled
                      ? 'Search exercises...'
                      : 'Exercise search unavailable',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(
                      alpha: isEnabled ? 1 : 0.65,
                    ),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: AppTheme.primary,
                        size: 14,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
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

class _ExerciseHeaderCard extends StatelessWidget {
  const _ExerciseHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -62,
            right: -48,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -72,
            left: -56,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.white, size: 30),
              SizedBox(height: 12),
              Text(
                'Exercise Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Explore exercises, learn proper technique, and build better workouts.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MuscleFilterChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MuscleFilterChip({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : isDarkMode
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteFilterButton extends StatelessWidget {
  final bool isSelected;
  final int favoriteCount;
  final VoidCallback onTap;

  const _FavoriteFilterButton({
    required this.isSelected,
    required this.favoriteCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.error.withValues(alpha: 0.15)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? AppTheme.error.withValues(alpha: 0.38)
                  : isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  isSelected
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isSelected ? AppTheme.error : AppTheme.textSecondary,
                ),
              ),
              if (favoriteCount > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 21,
                      minHeight: 21,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$favoriteCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuscleFilter {
  final String title;
  final IconData icon;

  const _MuscleFilter({required this.title, required this.icon});
}
