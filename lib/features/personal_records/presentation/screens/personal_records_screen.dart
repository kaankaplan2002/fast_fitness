import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/personal_records/providers/personal_record_provider.dart';
import 'package:fast_fitness/features/personal_records/presentation/widgets/personal_record_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(personalRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Records'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: recordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Personal records could not be loaded.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (records) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Personal Records',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Track your best performances and long-term progress.',
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...records.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PersonalRecordCard(record: record),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
