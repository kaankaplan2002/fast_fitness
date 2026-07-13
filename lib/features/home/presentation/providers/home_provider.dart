import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_fitness/features/auth/data/models/app_user_model.dart';
import 'package:fast_fitness/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final currentAppUserProvider = StreamProvider<AppUserModel?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
    data: (firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(null);
      }

      return firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              return null;
            }

            final data = snapshot.data();

            if (data == null) {
              return null;
            }

            return AppUserModel.fromMap(data);
          });
    },
  );
});

final recentCompletedWorkoutsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final firestore = ref.watch(firestoreProvider);
      final authState = ref.watch(authStateProvider);

      return authState.when(
        loading: () => Stream.value(const []),
        error: (_, __) => Stream.value(const []),
        data: (firebaseUser) {
          if (firebaseUser == null) {
            return Stream.value(const []);
          }

          return firestore
              .collection('completed_workouts')
              .where('userId', isEqualTo: firebaseUser.uid)
              .snapshots()
              .map((snapshot) {
                final list = snapshot.docs.map((doc) {
                  final data = Map<String, dynamic>.from(doc.data());

                  data['id'] = doc.id;

                  if (data['completedAt'] == null) {
                    data['completedAt'] = Timestamp.now();
                  }

                  return data;
                }).toList();

                // Sort descending in memory
                list.sort((a, b) {
                  final aTime = (a['completedAt'] as Timestamp?) ?? Timestamp.now();
                  final bTime = (b['completedAt'] as Timestamp?) ?? Timestamp.now();
                  return bTime.compareTo(aTime);
                });

                // Return top 5
                return list.take(5).toList();
              });
        },
      );
    });
