import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<int> watchCurrentStreak() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('completed_workouts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final workoutDays = <String>{};

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final completedAt = data['completedAt'];

            if (completedAt is Timestamp) {
              final date = completedAt.toDate();
              final key = _dateKey(date);
              workoutDays.add(key);
            }
          }

          return _calculateStreak(workoutDays);
        });
  }

  int _calculateStreak(Set<String> workoutDays) {
    if (workoutDays.isEmpty) return 0;

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

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
