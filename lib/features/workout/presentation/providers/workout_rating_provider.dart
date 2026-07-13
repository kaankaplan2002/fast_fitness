import 'package:fast_fitness/features/workout/data/datasource/workout_rating_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRatingRemoteDatasourceProvider =
    Provider<WorkoutRatingRemoteDatasource>((ref) {
      return WorkoutRatingRemoteDatasource();
    });

final workoutRatingLoadingProvider =
    NotifierProvider<WorkoutRatingLoadingNotifier, bool>(
      WorkoutRatingLoadingNotifier.new,
    );

class WorkoutRatingLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}
