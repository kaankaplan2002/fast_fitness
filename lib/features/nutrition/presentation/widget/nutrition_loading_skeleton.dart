import 'package:fast_fitness/app/theme.dart';
import 'package:flutter/material.dart';

class NutritionLoadingSkeleton extends StatefulWidget {
  const NutritionLoadingSkeleton({super.key});

  @override
  State<NutritionLoadingSkeleton> createState() =>
      _NutritionLoadingSkeletonState();
}

class _NutritionLoadingSkeletonState extends State<NutritionLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonHeader(opacity: animation.value),
                const SizedBox(height: 20),
                _SkeletonMacroRow(opacity: animation.value),
                const SizedBox(height: 28),
                _SkeletonLine(width: 150, height: 22, opacity: animation.value),
                const SizedBox(height: 16),
                _SkeletonMealCard(opacity: animation.value),
                const SizedBox(height: 14),
                _SkeletonMealCard(opacity: animation.value),
                const SizedBox(height: 14),
                _SkeletonMealCard(opacity: animation.value),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonHeader extends StatelessWidget {
  final double opacity;

  const _SkeletonHeader({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppTheme.primary.withValues(alpha: 0.14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 48, height: 48, radius: 18, opacity: opacity),
          const Spacer(),
          _SkeletonLine(width: 210, height: 28, opacity: opacity),
          const SizedBox(height: 12),
          _SkeletonLine(width: 170, height: 16, opacity: opacity),
          const SizedBox(height: 24),
          _SkeletonLine(width: double.infinity, height: 10, opacity: opacity),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SkeletonBox(height: 72, radius: 22, opacity: opacity),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SkeletonBox(height: 72, radius: 22, opacity: opacity),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonMacroRow extends StatelessWidget {
  final double opacity;

  const _SkeletonMacroRow({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroSkeleton(opacity: opacity)),
        Expanded(child: _MacroSkeleton(opacity: opacity)),
        Expanded(child: _MacroSkeleton(opacity: opacity)),
      ],
    );
  }
}

class _MacroSkeleton extends StatelessWidget {
  final double opacity;

  const _MacroSkeleton({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SkeletonBox(width: 72, height: 72, radius: 999, opacity: opacity),
        const SizedBox(height: 10),
        _SkeletonLine(width: 60, height: 13, opacity: opacity),
        const SizedBox(height: 6),
        _SkeletonLine(width: 48, height: 11, opacity: opacity),
      ],
    );
  }
}

class _SkeletonMealCard extends StatelessWidget {
  final double opacity;

  const _SkeletonMealCard({required this.opacity});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          _SkeletonBox(width: 54, height: 54, radius: 999, opacity: opacity),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 150, height: 17, opacity: opacity),
                const SizedBox(height: 10),
                _SkeletonLine(width: 105, height: 13, opacity: opacity),
                const SizedBox(height: 8),
                _SkeletonLine(width: 180, height: 12, opacity: opacity),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _SkeletonBox(width: 32, height: 32, radius: 12, opacity: opacity),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(
      width: width,
      height: height,
      radius: 999,
      opacity: opacity,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final double opacity;

  const _SkeletonBox({
    this.width,
    required this.height,
    required this.radius,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: isDark
            ? Colors.white.withValues(alpha: opacity * 0.12)
            : Colors.black.withValues(alpha: opacity * 0.08),
      ),
    );
  }
}
