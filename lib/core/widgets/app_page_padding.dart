import 'package:flutter/material.dart';

class AppPagePadding extends StatelessWidget {
  final Widget child;

  const AppPagePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: child,
    );
  }
}
