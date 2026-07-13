import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final IconData icon;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 64,
    this.icon = Icons.person_rounded,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: .35),
            width: 2,
          ),
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withValues(alpha: .14),
      ),
      child: Center(
        child: initials != null && initials!.isNotEmpty
            ? Text(
                initials!.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: size * .34,
                  color: AppTheme.primary,
                ),
              )
            : Icon(icon, size: size * .48, color: AppTheme.primary),
      ),
    );
  }
}
