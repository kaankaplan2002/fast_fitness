import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/progress/data/models/workout_statistics_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutStatisticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<WorkoutStatisticsModel> watchStatistics() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(
        const WorkoutStatisticsModel(
          weeklyWorkouts: 0,
          monthlyWorkouts: 0,
          totalWorkouts: 0,
          totalMinutes: 0,
          averageWorkoutMinutes: 0,
          totalCalories: 0,
          favoriteMuscleGroup: '-',
          lastWorkoutText: '-',
        ),
      );
    }

    return _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final monthStart = DateTime(now.year, now.month, 1);

          int weekly = 0;
          int monthly = 0;
          int totalMinutes = 0;
          Timestamp? latestTimestamp;
          final Map<String, int> muscleCounts = {};

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final duration = (data['durationMinutes'] ?? 0) as int;
            final title = (data['workoutTitle'] ?? 'Workout').toString();
            final completedAt = data['completedAt'];

            totalMinutes += duration;

            final muscle = title.split(' ').first;
            muscleCounts[muscle] = (muscleCounts[muscle] ?? 0) + 1;

            if (completedAt is Timestamp) {
              final date = completedAt.toDate();

              if (date.isAfter(weekStart)) {
                weekly++;
              }

              if (date.isAfter(monthStart)) {
                monthly++;
              }

              if (latestTimestamp == null ||
                  completedAt.compareTo(latestTimestamp) > 0) {
                latestTimestamp = completedAt;
              }
            }
          }

          String favoriteMuscle = '-';

          if (muscleCounts.isNotEmpty) {
            favoriteMuscle = muscleCounts.entries
                .reduce((a, b) => a.value >= b.value ? a : b)
                .key;
          }

          String lastWorkoutText = '-';

          if (latestTimestamp != null) {
            final lastDate = latestTimestamp.toDate();
            final difference = now.difference(lastDate).inDays;

            if (difference == 0) {
              lastWorkoutText = 'Today';
            } else if (difference == 1) {
              lastWorkoutText = 'Yesterday';
            } else {
              lastWorkoutText = '$difference days ago';
            }
          }

          final totalWorkouts = snapshot.docs.length;
          final averageMinutes = totalWorkouts == 0
              ? 0
              : (totalMinutes / totalWorkouts).round();

          return WorkoutStatisticsModel(
            weeklyWorkouts: weekly,
            monthlyWorkouts: monthly,
            totalWorkouts: totalWorkouts,
            totalMinutes: totalMinutes,
            averageWorkoutMinutes: averageMinutes,
            totalCalories: totalMinutes * 8,
            favoriteMuscleGroup: favoriteMuscle,
            lastWorkoutText: lastWorkoutText,
          );
        });
  }
}
