import 'package:fast_fitness/features/workout/domain/models/workout_session_model.dart';

class WorkoutSessionStorage {
  static WorkoutSessionModel? _currentSession;

  Future<void> saveSession(WorkoutSessionModel session) async {
    _currentSession = session;
  }

  Future<WorkoutSessionModel?> getSession() async {
    return _currentSession;
  }

  Future<void> clearSession() async {
    _currentSession = null;
  }
}
