import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class SetupNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;

  const SetupNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        suffixText: suffix,
      ),
    );
  }
}