import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/achievement_model.dart';

class AchievementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AchievementRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Future<List<AchievementModel>> getAchievements() async {
    final user = _auth.currentUser;

    if (user == null) {
      return _buildAchievements(
        workoutCount: 0,
        streakDays: 0,
        caloriesBurned: 0,
        totalXp: 0,
        fiveStarRatings: 0,
      );
    }

    final workoutsSnapshot = await _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .get();

    int workoutCount = workoutsSnapshot.docs.length;
    int caloriesBurned = 0;
    int totalXp = 0;
    int fiveStarRatings = 0;

    final workoutDates = <DateTime>[];

    for (final doc in workoutsSnapshot.docs) {
      final data = doc.data();

      caloriesBurned += _readInt(data, ['calories', 'caloriesBurned']);
      totalXp += _readInt(data, ['xp', 'xpEarned', 'earnedXp']);

      final rating = _readDouble(data, ['rating', 'workoutRating']);
      if (rating >= 5) {
        fiveStarRatings++;
      }

      final date = _readDate(data, ['completedAt', 'createdAt', 'date']);
      if (date != null) {
        workoutDates.add(DateTime(date.year, date.month, date.day));
      }
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    if (userData != null) {
      final userXp = _readInt(userData, ['xp', 'totalXp']);
      if (userXp > totalXp) {
        totalXp = userXp;
      }
    }

    final streakDays = _calculateCurrentStreak(workoutDates);

    return _buildAchievements(
      workoutCount: workoutCount,
      streakDays: streakDays,
      caloriesBurned: caloriesBurned,
      totalXp: totalXp,
      fiveStarRatings: fiveStarRatings,
    );
  }

  List<AchievementModel> _buildAchievements({
    required int workoutCount,
    required int streakDays,
    required int caloriesBurned,
    required int totalXp,
    required int fiveStarRatings,
  }) {
    final definitions = <AchievementModel>[
      AchievementModel(
        id: 'first_workout',
        title: 'First Step',
        description: 'Complete your first workout.',
        icon: '🏁',
        category: AchievementCategory.workout,
        requirementType: AchievementRequirementType.workoutCount,
        requiredValue: 1,
        currentValue: workoutCount,
        unlocked: workoutCount >= 1,
      ),
      AchievementModel(
        id: 'ten_workouts',
        title: 'Committed',
        description: 'Complete 10 workouts.',
        icon: '💪',
        category: AchievementCategory.workout,
        requirementType: AchievementRequirementType.workoutCount,
        requiredValue: 10,
        currentValue: workoutCount,
        unlocked: workoutCount >= 10,
      ),
      AchievementModel(
        id: 'twenty_five_workouts',
        title: 'Athlete Mode',
        description: 'Complete 25 workouts.',
        icon: '🏆',
        category: AchievementCategory.workout,
        requirementType: AchievementRequirementType.workoutCount,
        requiredValue: 25,
        currentValue: workoutCount,
        unlocked: workoutCount >= 25,
      ),
      AchievementModel(
        id: 'three_day_streak',
        title: '3-Day Streak',
        description: 'Train for 3 active days in a row.',
        icon: '🔥',
        category: AchievementCategory.streak,
        requirementType: AchievementRequirementType.streakDays,
        requiredValue: 3,
        currentValue: streakDays,
        unlocked: streakDays >= 3,
      ),
      AchievementModel(
        id: 'seven_day_streak',
        title: 'Weekly Beast',
        description: 'Train for 7 active days in a row.',
        icon: '⚡',
        category: AchievementCategory.streak,
        requirementType: AchievementRequirementType.streakDays,
        requiredValue: 7,
        currentValue: streakDays,
        unlocked: streakDays >= 7,
      ),
      AchievementModel(
        id: 'calorie_1000',
        title: 'Burn Starter',
        description: 'Burn 1,000 total calories.',
        icon: '🔥',
        category: AchievementCategory.calories,
        requirementType: AchievementRequirementType.caloriesBurned,
        requiredValue: 1000,
        currentValue: caloriesBurned,
        unlocked: caloriesBurned >= 1000,
      ),
      AchievementModel(
        id: 'calorie_5000',
        title: 'Calorie Crusher',
        description: 'Burn 5,000 total calories.',
        icon: '🚀',
        category: AchievementCategory.calories,
        requirementType: AchievementRequirementType.caloriesBurned,
        requiredValue: 5000,
        currentValue: caloriesBurned,
        unlocked: caloriesBurned >= 5000,
      ),
      AchievementModel(
        id: 'xp_1000',
        title: 'Rising Level',
        description: 'Earn 1,000 total XP.',
        icon: '⭐',
        category: AchievementCategory.xp,
        requirementType: AchievementRequirementType.totalXp,
        requiredValue: 1000,
        currentValue: totalXp,
        unlocked: totalXp >= 1000,
      ),
      AchievementModel(
        id: 'xp_5000',
        title: 'Elite Progress',
        description: 'Earn 5,000 total XP.',
        icon: '👑',
        category: AchievementCategory.xp,
        requirementType: AchievementRequirementType.totalXp,
        requiredValue: 5000,
        currentValue: totalXp,
        unlocked: totalXp >= 5000,
      ),
      AchievementModel(
        id: 'five_star_3',
        title: 'Perfect Sessions',
        description: 'Finish 3 workouts with a 5-star rating.',
        icon: '🌟',
        category: AchievementCategory.rating,
        requirementType: AchievementRequirementType.fiveStarRatings,
        requiredValue: 3,
        currentValue: fiveStarRatings,
        unlocked: fiveStarRatings >= 3,
      ),
    ];

    return definitions;
  }

  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final uniqueDates = dates.toSet().toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    DateTime expectedDate = DateTime(today.year, today.month, today.day);

    final hasToday = uniqueDates.any((date) => _isSameDate(date, expectedDate));

    if (!hasToday) {
      expectedDate = expectedDate.subtract(const Duration(days: 1));
    }

    int streak = 0;

    for (final date in uniqueDates) {
      if (_isSameDate(date, expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  double _readDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  DateTime? _readDate(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
    }

    return null;
  }
}
