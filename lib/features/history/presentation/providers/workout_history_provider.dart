import 'package:fast_fitness/features/history/data/models/workout_history_model.dart';
import 'package:fast_fitness/features/history/data/repository/workout_history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>((
  ref,
) {
  return WorkoutHistoryRepository();
});

final workoutHistoryProvider = StreamProvider<List<WorkoutHistoryModel>>((ref) {
  return ref.watch(workoutHistoryRepositoryProvider).watchWorkoutHistory();
});

final historySearchQueryProvider =
    NotifierProvider<HistorySearchQueryNotifier, String>(
      HistorySearchQueryNotifier.new,
    );

class HistorySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) {
    state = value.trim().toLowerCase();
  }
}

final historyFilterProvider = NotifierProvider<HistoryFilterNotifier, String>(
  HistoryFilterNotifier.new,
);

class HistoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void update(String value) {
    state = value;
  }
}

final historySortProvider = NotifierProvider<HistorySortNotifier, String>(
  HistorySortNotifier.new,
);

class HistorySortNotifier extends Notifier<String> {
  @override
  String build() => 'Newest';

  void update(String value) {
    state = value;
  }
}
