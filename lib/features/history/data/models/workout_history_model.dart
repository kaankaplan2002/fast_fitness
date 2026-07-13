import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutHistoryModel {
  final String id;
  final String workoutTitle;
  final int exerciseCount;
  final int durationMinutes;
  final DateTime completedAt;

  const WorkoutHistoryModel({
    required this.id,
    required this.workoutTitle,
    required this.exerciseCount,
    required this.durationMinutes,
    required this.completedAt,
  });

  int get caloriesBurned => durationMinutes * 8;

  factory WorkoutHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WorkoutHistoryModel(
      id: doc.id,
      workoutTitle: data['workoutTitle'] ?? 'Workout',
      exerciseCount: data['exerciseCount'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 0,
      completedAt: data['completedAt'] is Timestamp
          ? (data['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
