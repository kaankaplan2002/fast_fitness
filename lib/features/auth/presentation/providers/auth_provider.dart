import 'package:fast_fitness/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRemoteDatasourceProvider).authStateChanges();
});

final authLoadingProvider =
    NotifierProvider<AuthLoadingNotifier, bool>(AuthLoadingNotifier.new);

class AuthLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}