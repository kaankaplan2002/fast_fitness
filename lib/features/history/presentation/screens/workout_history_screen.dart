import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/history/data/models/workout_history_model.dart';
import 'package:fast_fitness/features/history/presentation/providers/workout_history_provider.dart';
import 'package:fast_fitness/features/history/presentation/widgets/history_filter_bar.dart';
import 'package:fast_fitness/features/history/presentation/widgets/history_search_bar.dart';
import 'package:fast_fitness/features/history/presentation/widgets/workout_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<WorkoutHistoryModel> _applyFilters({
    required List<WorkoutHistoryModel> workouts,
    required String searchQuery,
    required String filter,
    required String sort,
  }) {
    var result = [...workouts];

    if (searchQuery.isNotEmpty) {
      result = result.where((workout) {
        return workout.workoutTitle.toLowerCase().contains(searchQuery);
      }).toList();
    }

    if (filter != 'All') {
      result = result.where((workout) {
        return workout.workoutTitle.toLowerCase().contains(
          filter.toLowerCase(),
        );
      }).toList();
    }

    switch (sort) {
      case 'Oldest':
        result.sort((a, b) => a.completedAt.compareTo(b.completedAt));
        break;
      case 'Longest':
        result.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
        break;
      case 'Shortest':
        result.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
      case 'Newest':
      default:
        result.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        break;
    }

    return result;
  }

  Map<String, dynamic> _workoutToExtra(WorkoutHistoryModel workout) {
    return {
      'id': workout.id,
      'workoutTitle': workout.workoutTitle,
      'exerciseCount': workout.exerciseCount,
      'durationMinutes': workout.durationMinutes,
      'completedAt': workout.completedAt.toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final searchQuery = ref.watch(historySearchQueryProvider);
    final selectedFilter = ref.watch(historyFilterProvider);
    final selectedSort = ref.watch(historySortProvider);

    return SafeArea(
      child: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Workout history could not be loaded.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (workouts) {
          final filteredWorkouts = _applyFilters(
            workouts: workouts,
            searchQuery: searchQuery,
            filter: selectedFilter,
            sort: selectedSort,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            children: [
              const Text(
                'Workout History',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                '${filteredWorkouts.length} workouts shown',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              HistorySearchBar(
                controller: searchController,
                onChanged: (value) {
                  ref.read(historySearchQueryProvider.notifier).update(value);
                },
              ),
              const SizedBox(height: 16),
              HistoryFilterBar(
                selectedFilter: selectedFilter,
                selectedSort: selectedSort,
                onFilterChanged: (value) {
                  ref.read(historyFilterProvider.notifier).update(value);
                },
                onSortChanged: (value) {
                  ref.read(historySortProvider.notifier).update(value);
                },
              ),
              const SizedBox(height: 24),
              if (filteredWorkouts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text(
                      'No workouts match your filters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ...filteredWorkouts.map(
                  (workout) => WorkoutHistoryCard(
                    workout: workout,
                    onTap: () {
                      context.push(
                        '/history-detail',
                        extra: _workoutToExtra(workout),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
