import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/progress/data/models/weight_history_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressRemoteDatasource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> saveWeight(double weight) async {
    final uid = auth.currentUser!.uid;

    await firestore
        .collection('users')
        .doc(uid)
        .collection('weight_history')
        .add({
      'weight': weight,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<WeightHistoryModel>> getWeightHistory() {
    final user = auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('weight_history')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WeightHistoryModel.fromFirestore(doc);
      }).toList();
    });
  }
}