import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class NewRecordDialog extends StatelessWidget {
  final String title;
  final String oldValue;
  final String newValue;

  const NewRecordDialog({
    super.key,
    required this.title,
    required this.oldValue,
    required this.newValue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text('New Personal Record!', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppTheme.primary,
            size: 64,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          Text(
            oldValue.isEmpty ? 'No previous record' : 'Previous: $oldValue',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'New: $newValue',
            style: const TextStyle(
              color: AppTheme.success,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Great!'),
        ),
      ],
    );
  }
}
