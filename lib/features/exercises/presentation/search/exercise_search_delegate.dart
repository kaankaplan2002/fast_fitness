import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:fast_fitness/core/widgets/app_card.dart';
import 'package:fast_fitness/core/widgets/app_chip.dart';
import 'package:fast_fitness/features/exercises/data/models/exercise_model.dart';
import 'package:fast_fitness/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExerciseSearchDelegate extends SearchDelegate<ExerciseModel?> {
  final List<ExerciseModel> exercises;
  final Set<String> favoriteExerciseIds;
  final ValueChanged<String>? onFavoriteToggle;
  final ValueChanged<String>? onSearchSubmitted;

  static const suggestedSearches = [
    'Chest',
    'Back',
    'Legs',
    'Core',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Dumbbell',
    'Barbell',
    'Bodyweight',
  ];

  ExerciseSearchDelegate({
    required this.exercises,
    required this.favoriteExerciseIds,
    this.onFavoriteToggle,
    this.onSearchSubmitted,
  });

  List<ExerciseModel> _filteredExercises(String queryText) {
    final search = queryText.trim().toLowerCase();

    if (search.isEmpty) return [];

    return exercises.where((exercise) {
      final name = exercise.name.toLowerCase();
      final muscle = exercise.muscleGroup.toLowerCase();
      final equip = exercise.equipment.toLowerCase();
      final diff = exercise.difficulty.toLowerCase();

      return name.contains(search) ||
          muscle.contains(search) ||
          equip.contains(search) ||
          diff.contains(search);
    }).toList();
  }

  Future<void> _toggleFavorite(String exerciseId) async {
    await HapticService.selection();
    onFavoriteToggle?.call(exerciseId);
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.success;
      case 'intermediate':
        return AppTheme.primary;
      case 'advanced':
        return AppTheme.error;
      default:
        return AppTheme.success;
    }
  }

  Future<void> _selectSuggestion(
    BuildContext context,
    String suggestion,
  ) async {
    await HapticService.selection();

    if (!context.mounted) return;

    query = suggestion;
    showResults(context);

    onSearchSubmitted?.call(suggestion);
  }

  Future<void> _openExercise(
    BuildContext context,
    ExerciseModel exercise,
  ) async {
    await HapticService.light();

    if (!context.mounted) return;

    onSearchSubmitted?.call(query.trim());

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

  @override
  ThemeData appBarTheme(BuildContext context) {
    final baseTheme = Theme.of(context);
    final isDarkMode = baseTheme.brightness == Brightness.dark;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: baseTheme.scaffoldBackgroundColor,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: baseTheme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: baseTheme.cardColor,
        hintStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear search',
          onPressed: () async {
            await HapticService.light();

            if (!context.mounted) return;

            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.close_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () async {
        await HapticService.light();

        if (!context.mounted) return;

        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionQuery = query.trim();
    final matches = _filteredExercises(suggestionQuery);

    if (suggestionQuery.isNotEmpty) {
      if (matches.isEmpty) {
        return _SearchEmptyState(
          title: 'No Exercises Found',
          message: 'No exercise matches “$suggestionQuery”. Try searching for other muscle groups or equipment.',
          query: suggestionQuery,
          onSuggestionTap: (suggestion) {
            _selectSuggestion(context, suggestion);
          },
        );
      }

      return _ExerciseSearchResults(
        title: 'Search Suggestions',
        subtitle: '${matches.length} exercise${matches.length == 1 ? '' : 's'} match your search',
        exercises: matches,
        favoriteExerciseIds: favoriteExerciseIds,
        difficultyColor: _difficultyColor,
        onExerciseTap: (exercise) {
          _openExercise(context, exercise);
        },
        onFavoriteTap: _toggleFavorite,
      );
    }

    final recommended = exercises.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        const _SearchHeroCard(),
        const SizedBox(height: 28),
        const Text(
          'Popular Searches',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: suggestedSearches.map((suggestion) {
            return _SuggestionChip(
              label: suggestion,
              onTap: () {
                _selectSuggestion(context, suggestion);
              },
            );
          }).toList(),
        ),

        if (recommended.isNotEmpty) ...[
          const SizedBox(height: 30),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Exercises',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Start exploring the exercise library.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${recommended.length}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...recommended.map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ExerciseCard(
                exercise: exercise,
                isFavorite: favoriteExerciseIds.contains(exercise.id),
                onTap: () {
                  _openExercise(context, exercise);
                },
                onFavoriteTap: () {
                  _toggleFavorite(exercise.id);
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final submittedQuery = query.trim();

    if (submittedQuery.isEmpty) {
      return buildSuggestions(context);
    }

    onSearchSubmitted?.call(submittedQuery);

    final matches = _filteredExercises(submittedQuery);

    if (matches.isEmpty) {
      return _SearchEmptyState(
        title: 'No Exercises Found',
        message: 'No exercise matches “$submittedQuery”. Try searching for a muscle group, equipment type, or difficulty.',
        query: submittedQuery,
        onSuggestionTap: (suggestion) {
          _selectSuggestion(context, suggestion);
        },
      );
    }

    return _ExerciseSearchResults(
      title: 'Search Results',
      subtitle: '${matches.length} exercise${matches.length == 1 ? '' : 's'} found for “$submittedQuery”',
      exercises: matches,
      favoriteExerciseIds: favoriteExerciseIds,
      difficultyColor: _difficultyColor,
      onExerciseTap: (exercise) {
        _openExercise(context, exercise);
      },
      onFavoriteTap: _toggleFavorite,
    );
  }
}

class _ExerciseSearchResults extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ExerciseModel> exercises;
  final Set<String> favoriteExerciseIds;
  final Color Function(String difficulty) difficultyColor;
  final ValueChanged<ExerciseModel> onExerciseTap;
  final ValueChanged<String> onFavoriteTap;

  const _ExerciseSearchResults({
    required this.title,
    required this.subtitle,
    required this.exercises,
    required this.favoriteExerciseIds,
    required this.difficultyColor,
    required this.onExerciseTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      itemCount: exercises.length + 1,
      separatorBuilder: (_, index) {
        if (index == 0) {
          return const SizedBox(height: 18);
        }

        return const SizedBox(height: 14);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
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
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ],
          );
        }

        final exercise = exercises[index - 1];

        return ExerciseCard(
          exercise: exercise,
          isFavorite: favoriteExerciseIds.contains(exercise.id),
          onTap: () {
            onExerciseTap(exercise);
          },
          onFavoriteTap: () {
            onFavoriteTap(exercise.id);
          },
        );
      },
    );
  }
}

class _SearchHeroCard extends StatelessWidget {
  const _SearchHeroCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXXLarge,
      showBorder: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -58,
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.search_rounded, color: Colors.white, size: 42),
                SizedBox(height: 18),
                Text(
                  'Find an Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Search the library by exercise name, target muscle, equipment, or difficulty.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  IconData get icon {
    switch (label.toLowerCase()) {
      case 'chest':
      case 'back':
      case 'legs':
      case 'core':
        return Icons.accessibility_new_rounded;
      case 'beginner':
      case 'intermediate':
      case 'advanced':
        return Icons.signal_cellular_alt_rounded;
      case 'dumbbell':
      case 'barbell':
        return Icons.fitness_center_rounded;
      case 'bodyweight':
        return Icons.self_improvement_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AppChip(label: label, icon: icon),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String query;
  final ValueChanged<String> onSuggestionTap;

  const _SearchEmptyState({
    required this.title,
    required this.message,
    required this.query,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 34),
      children: [
        Center(
          child: Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppTheme.primary,
              size: 58,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Try searching for',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 9,
          runSpacing: 9,
          children: ExerciseSearchDelegate.suggestedSearches
              .where(
                (suggestion) => suggestion.toLowerCase() != query.toLowerCase(),
              )
              .take(6)
              .map((suggestion) {
                return _SuggestionChip(
                  label: suggestion,
                  onTap: () {
                    onSuggestionTap(suggestion);
                  },
                );
              })
              .toList(),
        ),
      ],
    );
  }
}
