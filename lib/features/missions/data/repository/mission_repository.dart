import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/mission_model.dart';

class MissionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MissionRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Future<List<MissionModel>> getDailyMissions() async {
    final user = _auth.currentUser;

    if (user == null) {
      return _buildMissions(
        completedWorkoutCount: 0,
        caloriesBurned: 0,
        xpEarned: 0,
        ratedWorkoutCount: 0,
        claimedMissionIds: {},
      );
    }

    final todayKey = _todayKey();

    final workoutsSnapshot = await _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .get();

    int completedWorkoutCount = 0;
    int caloriesBurned = 0;
    int xpEarned = 0;
    int ratedWorkoutCount = 0;

    for (final doc in workoutsSnapshot.docs) {
      final data = doc.data();
      final completedAt = _readDate(data, ['completedAt', 'createdAt', 'date']);

      if (completedAt == null || !_isToday(completedAt)) {
        continue;
      }

      completedWorkoutCount++;
      caloriesBurned += _readInt(data, ['calories', 'caloriesBurned']);
      xpEarned += _readInt(data, ['xp', 'xpEarned', 'earnedXp']);

      final rating = _readDouble(data, ['rating', 'workoutRating']);
      if (rating > 0) {
        ratedWorkoutCount++;
      }
    }

    final missionDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_missions')
        .doc(todayKey)
        .get();

    final claimedMissionIds = <String>{};

    if (missionDoc.exists) {
      final data = missionDoc.data();
      final claimed = data?['claimedMissionIds'];

      if (claimed is List) {
        claimedMissionIds.addAll(claimed.map((item) => item.toString()));
      }
    }

    return _buildMissions(
      completedWorkoutCount: completedWorkoutCount,
      caloriesBurned: caloriesBurned,
      xpEarned: xpEarned,
      ratedWorkoutCount: ratedWorkoutCount,
      claimedMissionIds: claimedMissionIds,
    );
  }

  Future<void> claimMissionReward(MissionModel mission) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    if (!mission.completed) {
      throw Exception('Mission is not completed yet.');
    }

    if (mission.claimed) {
      throw Exception('Mission reward has already been claimed.');
    }

    final todayKey = _todayKey();
    final userRef = _firestore.collection('users').doc(user.uid);
    final missionRef = userRef.collection('daily_missions').doc(todayKey);

    await _firestore.runTransaction((transaction) async {
      final missionSnapshot = await transaction.get(missionRef);
      final userSnapshot = await transaction.get(userRef);

      final missionData = missionSnapshot.data();
      final claimedMissionIds = <String>[];

      if (missionData != null && missionData['claimedMissionIds'] is List) {
        claimedMissionIds.addAll(
          (missionData['claimedMissionIds'] as List).map(
            (item) => item.toString(),
          ),
        );
      }

      if (claimedMissionIds.contains(mission.id)) {
        throw Exception('Mission reward has already been claimed.');
      }

      claimedMissionIds.add(mission.id);

      final userData = userSnapshot.data();
      final currentXp = _readInt(userData ?? {}, ['xp', 'totalXp']);
      final newXp = currentXp + mission.rewardValue;

      transaction.set(missionRef, {
        'dateKey': todayKey,
        'claimedMissionIds': claimedMissionIds,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(userRef, {
        'xp': newXp,
        'totalXp': newXp,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  List<MissionModel> _buildMissions({
    required int completedWorkoutCount,
    required int caloriesBurned,
    required int xpEarned,
    required int ratedWorkoutCount,
    required Set<String> claimedMissionIds,
  }) {
    final missions = <MissionModel>[
      MissionModel(
        id: 'daily_complete_1_workout',
        title: 'Complete 1 Workout',
        description: 'Finish one workout session today.',
        icon: '🏋️',
        type: MissionType.completeWorkout,
        rewardType: MissionRewardType.xp,
        requiredValue: 1,
        currentValue: completedWorkoutCount,
        rewardValue: 50,
        completed: completedWorkoutCount >= 1,
        claimed: claimedMissionIds.contains('daily_complete_1_workout'),
      ),
      MissionModel(
        id: 'daily_burn_150_calories',
        title: 'Burn 150 Calories',
        description: 'Burn at least 150 calories today.',
        icon: '🔥',
        type: MissionType.burnCalories,
        rewardType: MissionRewardType.xp,
        requiredValue: 150,
        currentValue: caloriesBurned,
        rewardValue: 40,
        completed: caloriesBurned >= 150,
        claimed: claimedMissionIds.contains('daily_burn_150_calories'),
      ),
      MissionModel(
        id: 'daily_earn_100_xp',
        title: 'Earn 100 XP',
        description: 'Collect 100 XP from your training today.',
        icon: '⭐',
        type: MissionType.earnXp,
        rewardType: MissionRewardType.xp,
        requiredValue: 100,
        currentValue: xpEarned,
        rewardValue: 35,
        completed: xpEarned >= 100,
        claimed: claimedMissionIds.contains('daily_earn_100_xp'),
      ),
      MissionModel(
        id: 'daily_rate_1_workout',
        title: 'Rate Your Workout',
        description: 'Complete and rate one workout today.',
        icon: '🌟',
        type: MissionType.rateWorkout,
        rewardType: MissionRewardType.xp,
        requiredValue: 1,
        currentValue: ratedWorkoutCount,
        rewardValue: 25,
        completed: ratedWorkoutCount >= 1,
        claimed: claimedMissionIds.contains('daily_rate_1_workout'),
      ),
    ];

    return missions;
  }

  String _todayKey() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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
