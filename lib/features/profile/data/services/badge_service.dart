import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/profile/data/models/badge_model.dart';
import 'package:fast_fitness/features/profile/data/models/user_level_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<BadgeModel>> watchBadges() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          final userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();
          final userData = userDoc.data();

          final totalXp = userData?['totalXp'] ?? 0;
          final level = UserLevelModel.fromTotalXp(totalXp).level;

          final workoutCount = snapshot.docs.length;
          final workoutDates = <DateTime>[];

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final completedAt = data['completedAt'];

            if (completedAt is Timestamp) {
              workoutDates.add(completedAt.toDate());
            }
          }

          final streak = _calculateCurrentStreak(workoutDates);
          final weeklyWorkouts = _countThisWeek(workoutDates);
          final monthlyWorkouts = _countThisMonth(workoutDates);

          return [
            BadgeModel(
              title: 'First Workout',
              description: 'Complete your first workout',
              icon: Icons.flag_rounded,
              unlocked: workoutCount >= 1,
              currentValue: workoutCount,
              targetValue: 1,
            ),
            BadgeModel(
              title: 'Workout Lover',
              description: 'Complete 10 workouts',
              icon: Icons.fitness_center_rounded,
              unlocked: workoutCount >= 10,
              currentValue: workoutCount,
              targetValue: 10,
            ),
            BadgeModel(
              title: 'Iron Athlete',
              description: 'Complete 50 workouts',
              icon: Icons.workspace_premium_rounded,
              unlocked: workoutCount >= 50,
              currentValue: workoutCount,
              targetValue: 50,
            ),
            BadgeModel(
              title: '7 Day Streak',
              description: 'Train for 7 days in a row',
              icon: Icons.local_fire_department_rounded,
              unlocked: streak >= 7,
              currentValue: streak,
              targetValue: 7,
            ),
            BadgeModel(
              title: '30 Day Streak',
              description: 'Train for 30 days in a row',
              icon: Icons.whatshot_rounded,
              unlocked: streak >= 30,
              currentValue: streak,
              targetValue: 30,
            ),
            BadgeModel(
              title: 'First Level Up',
              description: 'Reach Level 2',
              icon: Icons.trending_up_rounded,
              unlocked: level >= 2,
              currentValue: level,
              targetValue: 2,
            ),
            BadgeModel(
              title: 'Fitness Master',
              description: 'Reach Level 10',
              icon: Icons.military_tech_rounded,
              unlocked: level >= 10,
              currentValue: level,
              targetValue: 10,
            ),
            BadgeModel(
              title: 'Weekly Winner',
              description: 'Complete 3 workouts this week',
              icon: Icons.calendar_view_week_rounded,
              unlocked: weeklyWorkouts >= 3,
              currentValue: weeklyWorkouts,
              targetValue: 3,
            ),
            BadgeModel(
              title: 'Monthly Champion',
              description: 'Complete 12 workouts this month',
              icon: Icons.calendar_month_rounded,
              unlocked: monthlyWorkouts >= 12,
              currentValue: monthlyWorkouts,
              targetValue: 12,
            ),
          ];
        });
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
        if (i == 0) {
          continue;
        }

        break;
      }
    }

    return streak;
  }

  int _countThisWeek(List<DateTime> dates) {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return dates.where((date) {
      return date.isAfter(weekStart) || _isSameDay(date, weekStart);
    }).length;
  }

  int _countThisMonth(List<DateTime> dates) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return dates.where((date) {
      return date.isAfter(monthStart) || _isSameDay(date, monthStart);
    }).length;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
