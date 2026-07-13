import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/ai/data/models/ai_coach_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiCoachRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AiCoachModel> watchCoachAdvice() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(
        const AiCoachModel(
          title: 'Today’s AI Coach',
          message: 'Log in to get personalized coaching.',
          recommendation: 'Complete your first workout to unlock smart tips.',
          weeklyWorkouts: 0,
          totalWorkouts: 0,
          currentStreak: 0,
          suggestedDuration: 30,
          suggestedCalories: 240,
          suggestedFocus: 'Full Body',
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

          final workoutDates = <DateTime>[];
          final focusCounts = <String, int>{};

          var weeklyWorkouts = 0;
          var totalMinutes = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final completedAt = data['completedAt'];
            final duration = (data['durationMinutes'] ?? 0) as int;
            final title = (data['workoutTitle'] ?? 'Full Body').toString();

            totalMinutes += duration;

            final focus = _extractFocus(title);
            focusCounts[focus] = (focusCounts[focus] ?? 0) + 1;

            if (completedAt is Timestamp) {
              final date = completedAt.toDate();
              workoutDates.add(date);

              if (date.isAfter(weekStart) || _isSameDay(date, weekStart)) {
                weeklyWorkouts++;
              }
            }
          }

          final totalWorkouts = snapshot.docs.length;
          final currentStreak = _calculateCurrentStreak(workoutDates);
          final averageDuration = totalWorkouts == 0
              ? 30
              : (totalMinutes / totalWorkouts).round();

          final suggestedFocus = _suggestFocus(focusCounts, totalWorkouts);
          final suggestedDuration = _suggestDuration(
            weeklyWorkouts: weeklyWorkouts,
            averageDuration: averageDuration,
          );
          final suggestedCalories = suggestedDuration * 8;

          return AiCoachModel(
            title: 'Today’s AI Coach',
            message: _buildMessage(
              weeklyWorkouts: weeklyWorkouts,
              totalWorkouts: totalWorkouts,
              currentStreak: currentStreak,
            ),
            recommendation: _buildRecommendation(
              suggestedFocus: suggestedFocus,
              suggestedDuration: suggestedDuration,
              suggestedCalories: suggestedCalories,
            ),
            weeklyWorkouts: weeklyWorkouts,
            totalWorkouts: totalWorkouts,
            currentStreak: currentStreak,
            suggestedDuration: suggestedDuration,
            suggestedCalories: suggestedCalories,
            suggestedFocus: suggestedFocus,
          );
        });
  }

  String _extractFocus(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('chest')) return 'Chest';
    if (lower.contains('back')) return 'Back';
    if (lower.contains('leg')) return 'Legs';
    if (lower.contains('shoulder')) return 'Shoulders';
    if (lower.contains('arm')) return 'Arms';
    if (lower.contains('biceps')) return 'Biceps';
    if (lower.contains('triceps')) return 'Triceps';
    if (lower.contains('core') || lower.contains('abs')) return 'Core';
    if (lower.contains('cardio')) return 'Cardio';

    return 'Full Body';
  }

  String _suggestFocus(Map<String, int> focusCounts, int totalWorkouts) {
    if (totalWorkouts == 0) return 'Full Body';

    final focuses = ['Chest', 'Back', 'Legs', 'Shoulders', 'Core', 'Cardio'];

    focuses.sort((a, b) {
      final aCount = focusCounts[a] ?? 0;
      final bCount = focusCounts[b] ?? 0;
      return aCount.compareTo(bCount);
    });

    return focuses.first;
  }

  int _suggestDuration({
    required int weeklyWorkouts,
    required int averageDuration,
  }) {
    if (weeklyWorkouts == 0) return 35;
    if (weeklyWorkouts <= 2) return 40;
    if (weeklyWorkouts <= 4) return averageDuration.clamp(35, 55);
    return 30;
  }

  String _buildMessage({
    required int weeklyWorkouts,
    required int totalWorkouts,
    required int currentStreak,
  }) {
    if (totalWorkouts == 0) {
      return 'Welcome to FastFitness. Start with a simple full-body workout today.';
    }

    if (weeklyWorkouts == 0) {
      return 'You have not completed a workout this week yet. Today is a good day to restart.';
    }

    if (currentStreak >= 7) {
      return 'Great consistency. You are building a strong workout habit.';
    }

    if (weeklyWorkouts >= 3) {
      return 'Nice work. You are on track with your weekly training goal.';
    }

    return 'Good progress. A focused workout today can help keep your momentum.';
  }

  String _buildRecommendation({
    required String suggestedFocus,
    required int suggestedDuration,
    required int suggestedCalories,
  }) {
    return 'Focus on $suggestedFocus today. Aim for about $suggestedDuration minutes and roughly $suggestedCalories kcal. Keep the intensity controlled and finish with stretching.';
  }

  int _calculateCurrentStreak(List<DateTime> workoutDates) {
    if (workoutDates.isEmpty) return 0;

    final workoutDays = workoutDates.map(_dateKey).toSet();
    final today = DateTime.now();

    var streak = 0;

    for (int i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      final key = _dateKey(day);

      if (workoutDays.contains(key)) {
        streak++;
      } else {
        if (i == 0) continue;
        break;
      }
    }

    return streak;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
