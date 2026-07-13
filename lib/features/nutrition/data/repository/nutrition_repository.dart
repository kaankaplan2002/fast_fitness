import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/nutrition_entry_model.dart';
import '../model/nutrition_goal_model.dart';

class NutritionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NutritionRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _entryCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('nutrition_entries');
  }

  DocumentReference<Map<String, dynamic>> _goalDocument(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('nutrition_goals')
        .doc('current');
  }

  Stream<List<NutritionEntryModel>> watchTodayEntries() {
    final userId = _userId;

    if (userId == null) {
      return Stream.value([]);
    }

    final range = _todayRange();

    return _entryCollection(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('date', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    NutritionEntryModel.fromMap(id: doc.id, map: doc.data()),
              )
              .toList(),
        );
  }

  Stream<NutritionGoalModel> watchNutritionGoal() {
    final userId = _userId;

    if (userId == null) {
      return Stream.value(NutritionGoalModel.defaultGoal());
    }

    return _goalDocument(userId).snapshots().map(
      (snapshot) => NutritionGoalModel.fromMap(snapshot.data()),
    );
  }

  Future<void> addEntry({
    required String foodName,
    required MealType mealType,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final now = DateTime.now();

    final entry = NutritionEntryModel(
      id: '',
      userId: userId,
      foodName: foodName,
      mealType: mealType,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      date: now,
      createdAt: now,
    );

    await _entryCollection(userId).add(entry.toMap());
  }

  Future<void> deleteEntry(String entryId) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await _entryCollection(userId).doc(entryId).delete();
  }

  Future<void> updateGoal(NutritionGoalModel goal) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await _goalDocument(userId).set({
      ...goal.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  _DateRange _todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _DateRange(start: start, end: end);
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange({required this.start, required this.end});
}
