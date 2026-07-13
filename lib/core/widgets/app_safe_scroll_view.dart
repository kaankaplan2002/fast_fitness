import 'package:flutter/material.dart';

class AppSafeScrollView extends StatelessWidget {
  final Widget child;

  const AppSafeScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: child,
      ),
    );
  }
}
