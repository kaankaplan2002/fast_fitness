import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/progress/data/models/workout_analytics_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutAnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<WorkoutAnalyticsModel> watchAnalytics() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(
        const WorkoutAnalyticsModel(
          mondayMinutes: 0,
          tuesdayMinutes: 0,
          wednesdayMinutes: 0,
          thursdayMinutes: 0,
          fridayMinutes: 0,
          saturdayMinutes: 0,
          sundayMinutes: 0,
          averageDuration: 0,
          longestWorkout: 0,
          averageCalories: 0,
          workoutFrequency: 0,
        ),
      );
    }

    return _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final weekStart = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: now.weekday - 1));

          final weeklyMinutes = List<int>.filled(7, 0);
          var totalMinutes = 0;
          var longestWorkout = 0;
          var workoutCount = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final completedAt = data['completedAt'];
            final duration = (data['durationMinutes'] ?? 0) as int;

            totalMinutes += duration;
            workoutCount++;

            if (duration > longestWorkout) {
              longestWorkout = duration;
            }

            if (completedAt is Timestamp) {
              final date = completedAt.toDate();
              final dayOnly = DateTime(date.year, date.month, date.day);

              final isThisWeek =
                  dayOnly.isAfter(weekStart) || _isSameDay(dayOnly, weekStart);

              if (isThisWeek) {
                final index = dayOnly.weekday - 1;
                if (index >= 0 && index < 7) {
                  weeklyMinutes[index] += duration;
                }
              }
            }
          }

          final averageDuration = workoutCount == 0
              ? 0
              : (totalMinutes / workoutCount).round();

          final averageCalories = averageDuration * 8;

          return WorkoutAnalyticsModel(
            mondayMinutes: weeklyMinutes[0],
            tuesdayMinutes: weeklyMinutes[1],
            wednesdayMinutes: weeklyMinutes[2],
            thursdayMinutes: weeklyMinutes[3],
            fridayMinutes: weeklyMinutes[4],
            saturdayMinutes: weeklyMinutes[5],
            sundayMinutes: weeklyMinutes[6],
            averageDuration: averageDuration,
            longestWorkout: longestWorkout,
            averageCalories: averageCalories,
            workoutFrequency: workoutCount,
          );
        });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
