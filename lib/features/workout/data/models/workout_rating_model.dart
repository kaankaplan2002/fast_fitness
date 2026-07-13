import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutRatingModel {
  final String workoutTitle;
  final int rating;
  final String feedback;
  final DateTime createdAt;

  const WorkoutRatingModel({
    required this.workoutTitle,
    required this.rating,
    required this.feedback,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'workoutTitle': workoutTitle,
      'rating': rating,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
