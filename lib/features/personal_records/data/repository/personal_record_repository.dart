import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/personal_records/data/models/personal_record_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalRecordRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<PersonalRecordModel>> watchPersonalRecords() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          int longestWorkout = 0;
          int highestExerciseCount = 0;
          int totalWorkouts = snapshot.docs.length;
          int totalMinutes = 0;
          int aiWorkouts = 0;
          int generatedPrograms = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final duration = (data['durationMinutes'] ?? 0) as int;
            final exerciseCount = (data['exerciseCount'] ?? 0) as int;
            final source = (data['source'] ?? '').toString();

            totalMinutes += duration;

            if (duration > longestWorkout) {
              longestWorkout = duration;
            }

            if (exerciseCount > highestExerciseCount) {
              highestExerciseCount = exerciseCount;
            }

            if (source == 'ai_generated') {
              aiWorkouts++;
              generatedPrograms++;
            }
          }

          final estimatedCalories = totalMinutes * 8;

          return [
            PersonalRecordModel(
              title: 'Longest Workout',
              value: '$longestWorkout min',
              subtitle: 'Best workout duration',
              iconName: 'timer',
            ),
            PersonalRecordModel(
              title: 'Most Exercises',
              value: '$highestExerciseCount',
              subtitle: 'Highest exercises in one workout',
              iconName: 'fitness',
            ),
            PersonalRecordModel(
              title: 'Total Workouts',
              value: '$totalWorkouts',
              subtitle: 'Completed workouts',
              iconName: 'trophy',
            ),
            PersonalRecordModel(
              title: 'Calories Burned',
              value: '$estimatedCalories',
              subtitle: 'Estimated total burn',
              iconName: 'fire',
            ),
            PersonalRecordModel(
              title: 'AI Workouts',
              value: '$aiWorkouts',
              subtitle: 'AI generated sessions completed',
              iconName: 'ai',
            ),
            PersonalRecordModel(
              title: 'Generated Plans',
              value: '$generatedPrograms',
              subtitle: 'Smart workout plans used',
              iconName: 'spark',
            ),
          ];
        });
  }
}
