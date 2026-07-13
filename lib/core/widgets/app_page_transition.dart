import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageTransition<T> extends CustomTransitionPage<T> {
  AppPageTransition({
    required super.key,
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
         transitionDuration: const Duration(milliseconds: 260),
         reverseTransitionDuration: const Duration(milliseconds: 220),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );

           final slideAnimation = Tween<Offset>(
             begin: const Offset(0.05, 0),
             end: Offset.zero,
           ).animate(curvedAnimation);

           return FadeTransition(
             opacity: curvedAnimation,
             child: SlideTransition(position: slideAnimation, child: child),
           );
         },
       );
}
