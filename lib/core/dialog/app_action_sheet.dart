import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/core/service/haptic_service.dart';
import 'package:flutter/material.dart';

class AppActionSheetItem {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const AppActionSheetItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });
}

class AppActionSheet {
  AppActionSheet._();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<AppActionSheetItem> actions,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                ...actions.map(
                  (action) => ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: Icon(
                      action.icon,
                      color: action.color ?? AppTheme.primary,
                    ),
                    title: Text(
                      action.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: action.color,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await HapticService.selection();
                      action.onTap();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
