import 'package:fast_fitness/features/workout/data/datasource/workout_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRemoteDatasourceProvider = Provider<WorkoutRemoteDatasource>((ref) {
  return WorkoutRemoteDatasource();
});

final workoutLoadingProvider =
    NotifierProvider<WorkoutLoadingNotifier, bool>(WorkoutLoadingNotifier.new);

class WorkoutLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}