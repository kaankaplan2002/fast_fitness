import 'package:cloud_firestore/cloud_firestore.dart';

class WeightHistoryModel {
  final String id;
  final double weight;
  final DateTime createdAt;

  const WeightHistoryModel({
    required this.id,
    required this.weight,
    required this.createdAt,
  });

  factory WeightHistoryModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return WeightHistoryModel(
      id: doc.id,
      weight: (data['weight'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}