import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String name;

  const HomeHeader({super.key, required this.name});

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning,';
    if (hour < 18) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String get initials {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return 'U';

    final parts = trimmedName.split(' ');

    if (parts.length == 1) {
      return parts.first.substring(0, 1);
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        AppAvatar(initials: initials, size: 52),
      ],
    );
  }
}
