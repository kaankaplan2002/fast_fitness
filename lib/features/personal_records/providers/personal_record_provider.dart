import 'package:fast_fitness/features/personal_records/data/models/personal_record_model.dart';
import 'package:fast_fitness/features/personal_records/data/repository/personal_record_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final personalRecordRepositoryProvider = Provider<PersonalRecordRepository>((
  ref,
) {
  return PersonalRecordRepository();
});

final personalRecordsProvider = StreamProvider<List<PersonalRecordModel>>((
  ref,
) {
  return ref.watch(personalRecordRepositoryProvider).watchPersonalRecords();
});
