import 'package:flutter/material.dart';

class BadgeModel {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final int currentValue;
  final int targetValue;

  const BadgeModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.currentValue,
    required this.targetValue,
  });

  double get progress {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }
}
