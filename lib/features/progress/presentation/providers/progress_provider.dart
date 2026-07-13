import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/progress/data/models/weight_history_model.dart';
import 'package:fast_fitness/features/progress/data/models/workout_analytics_model.dart';
import 'package:fast_fitness/features/progress/data/models/workout_statistics_model.dart';
import 'package:fast_fitness/features/progress/data/repository/progress_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Internal: cached repository instance
// ---------------------------------------------------------------------------

final _progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

// ---------------------------------------------------------------------------
// Internal: single shared Stream<QuerySnapshot> for completed_workouts.
//
// Using Provider<Stream<T>> (not StreamProvider<T>) allows multiple
// StreamProvider children to call ref.watch() on this without Riverpod
// trying to listen to a StreamProvider<T> via .stream (which does not exist
// in Riverpod 3).  Each child StreamProvider subscribes to the same
// underlying Firestore listener through the shared Stream reference.
// ---------------------------------------------------------------------------

final _completedWorkoutsStreamProvider =
    Provider<Stream<QuerySnapshot<Map<String, dynamic>>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('completed_workouts')
      .where('userId', isEqualTo: user.uid)
      .snapshots();
});

// ---------------------------------------------------------------------------
// Public providers — all derived from the single shared Firestore stream
// ---------------------------------------------------------------------------

/// Total number of completed workouts.
final completedWorkoutsCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(_completedWorkoutsStreamProvider)
      .map((snapshot) => snapshot.docs.length);
});

/// Sum of durationMinutes across all completed workouts.
final totalWorkoutMinutesProvider = StreamProvider<int>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
    var total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['durationMinutes'] ?? 0) as int;
    }
    return total;
  });
});

/// Distinct dates on which at least one workout was completed.
final workoutHeatmapDatesProvider = StreamProvider<List<DateTime>>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
    return snapshot.docs
        .map((doc) {
          final completedAt = doc.data()['completedAt'];
          if (completedAt is Timestamp) return completedAt.toDate();
          return null;
        })
        .whereType<DateTime>()
        .toList();
  });
});

/// Whether the current user completed any workout today.
final workoutCompletedTodayProvider = StreamProvider<bool>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
    final today = DateTime.now();
    for (final doc in snapshot.docs) {
      final completedAt = doc.data()['completedAt'];
      if (completedAt is Timestamp) {
        if (_isSameDay(completedAt.toDate(), today)) return true;
      }
    }
    return false;
  });
});

/// Number of workouts in the current Mon–Sun week.
final weeklyChallengeProgressProvider = StreamProvider<int>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    var count = 0;
    for (final doc in snapshot.docs) {
      final completedAt = doc.data()['completedAt'];
      if (completedAt is Timestamp) {
        final date = completedAt.toDate();
        if (date.isAfter(weekStart) || _isSameDay(date, weekStart)) count++;
      }
    }
    return count;
  });
});

/// Number of workouts in the current calendar month.
final monthlyChallengeProgressProvider = StreamProvider<int>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    var count = 0;
    for (final doc in snapshot.docs) {
      final completedAt = doc.data()['completedAt'];
      if (completedAt is Timestamp) {
        final date = completedAt.toDate();
        if (date.isAfter(monthStart) || _isSameDay(date, monthStart)) count++;
      }
    }
    return count;
  });
});

/// Current workout streak (consecutive days ending today or yesterday).
final currentStreakProvider = StreamProvider<int>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
    final workoutDays = <String>{};
    for (final doc in snapshot.docs) {
      final completedAt = doc.data()['completedAt'];
      if (completedAt is Timestamp) {
        workoutDays.add(_dateKey(completedAt.toDate()));
      }
    }
    return _calculateStreak(workoutDays);
  });
});

/// Aggregated workout statistics: weekly/monthly totals, averages,
/// favourite muscle group, and last-workout label.
final workoutStatisticsProvider = StreamProvider<WorkoutStatisticsModel>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    int weekly = 0;
    int monthly = 0;
    int totalMinutes = 0;
    Timestamp? latestTimestamp;
    final muscleCounts = <String, int>{};

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
        if (date.isAfter(weekStart)) weekly++;
        if (date.isAfter(monthStart)) monthly++;
        if (latestTimestamp == null ||
            completedAt.compareTo(latestTimestamp) > 0) {
          latestTimestamp = completedAt;
        }
      }
    }

    String favoriteMuscle = '-';
    if (muscleCounts.isNotEmpty) {
      favoriteMuscle =
          muscleCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    String lastWorkoutText = '-';
    if (latestTimestamp != null) {
      final diff = now.difference(latestTimestamp.toDate()).inDays;
      lastWorkoutText = diff == 0
          ? 'Today'
          : diff == 1
              ? 'Yesterday'
              : '$diff days ago';
    }

    final total = snapshot.docs.length;
    return WorkoutStatisticsModel(
      weeklyWorkouts: weekly,
      monthlyWorkouts: monthly,
      totalWorkouts: total,
      totalMinutes: totalMinutes,
      averageWorkoutMinutes: total == 0 ? 0 : (totalMinutes / total).round(),
      totalCalories: totalMinutes * 8,
      favoriteMuscleGroup: favoriteMuscle,
      lastWorkoutText: lastWorkoutText,
    );
  });
});

/// Per-weekday minute breakdown and aggregate analytics for the Progress screen.
final workoutAnalyticsProvider = StreamProvider<WorkoutAnalyticsModel>((ref) {
  return ref.watch(_completedWorkoutsStreamProvider).map((snapshot) {
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
      if (duration > longestWorkout) longestWorkout = duration;

      if (completedAt is Timestamp) {
        final date = completedAt.toDate();
        final dayOnly = DateTime(date.year, date.month, date.day);
        if (dayOnly.isAfter(weekStart) || _isSameDay(dayOnly, weekStart)) {
          final index = dayOnly.weekday - 1;
          if (index >= 0 && index < 7) weeklyMinutes[index] += duration;
        }
      }
    }

    final avg =
        workoutCount == 0 ? 0 : (totalMinutes / workoutCount).round();

    return WorkoutAnalyticsModel(
      mondayMinutes: weeklyMinutes[0],
      tuesdayMinutes: weeklyMinutes[1],
      wednesdayMinutes: weeklyMinutes[2],
      thursdayMinutes: weeklyMinutes[3],
      fridayMinutes: weeklyMinutes[4],
      saturdayMinutes: weeklyMinutes[5],
      sundayMinutes: weeklyMinutes[6],
      averageDuration: avg,
      longestWorkout: longestWorkout,
      averageCalories: avg * 8,
      workoutFrequency: workoutCount,
    );
  });
});

/// User's weight history entries ordered oldest-first.
final weightHistoryProvider = StreamProvider<List<WeightHistoryModel>>((ref) {
  return ref.watch(_progressRepositoryProvider).getWeightHistory();
});

/// Average workout rating and total rating count.
final workoutRatingSummaryProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value({'averageRating': 0.0, 'ratingCount': 0});
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('workout_ratings')
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) {
      return {'averageRating': 0.0, 'ratingCount': 0};
    }
    var total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['rating'] ?? 0) as int;
    }
    return {
      'averageRating': total / snapshot.docs.length,
      'ratingCount': snapshot.docs.length,
    };
  });
});

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

int _calculateStreak(Set<String> workoutDays) {
  if (workoutDays.isEmpty) return 0;

  final today = DateTime.now();
  var streak = 0;

  for (int i = 0; i < 365; i++) {
    final key = _dateKey(today.subtract(Duration(days: i)));
    if (workoutDays.contains(key)) {
      streak++;
    } else {
      // i == 0 means today had no workout; allow yesterday to keep streak.
      if (i == 0) continue;
      break;
    }
  }

  return streak;
}
