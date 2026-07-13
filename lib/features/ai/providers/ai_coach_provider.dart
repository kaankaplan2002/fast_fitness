import 'package:fast_fitness/features/ai/data/models/ai_coach_model.dart';
import 'package:fast_fitness/features/ai/data/repository/ai_coach_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  return AiCoachRepository();
});

final aiCoachProvider = StreamProvider<AiCoachModel>((ref) {
  return ref.watch(aiCoachRepositoryProvider).watchCoachAdvice();
});
