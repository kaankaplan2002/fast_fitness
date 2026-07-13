import 'package:flutter/material.dart';

class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry margin;

  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 18,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: .25,
      end: .55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: .08)
              : Colors.black.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class AppSkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const AppSkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(width: width, height: height, radius: 999);
  }
}

class AppSkeletonCircle extends StatelessWidget {
  final double size;

  const AppSkeletonCircle({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(width: size, height: size, radius: size);
  }
}

class AppSkeletonCard extends StatelessWidget {
  final double height;

  const AppSkeletonCard({super.key, this.height = 110});

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      height: height,
      radius: 24,
      margin: const EdgeInsets.only(bottom: 16),
    );
  }
}

class AppListSkeleton extends StatelessWidget {
  final int itemCount;

  const AppListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        return const AppSkeletonCard();
      },
    );
  }
}

class AppProfileSkeleton extends StatelessWidget {
  const AppProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        Center(child: AppSkeletonCircle(size: 90)),
        SizedBox(height: 24),
        Center(child: AppSkeletonLine(width: 180, height: 22)),
        SizedBox(height: 10),
        Center(child: AppSkeletonLine(width: 130)),
        SizedBox(height: 32),
        AppSkeletonCard(height: 70),
        AppSkeletonCard(height: 70),
        AppSkeletonCard(height: 70),
        AppSkeletonCard(height: 70),
      ],
    );
  }
}

class AppHomeSkeleton extends StatelessWidget {
  const AppHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        AppSkeleton(height: 180, radius: 28),
        SizedBox(height: 24),
        AppSkeletonCard(height: 120),
        AppSkeletonCard(height: 120),
        AppSkeletonCard(height: 120),
      ],
    );
  }
}

class AppNutritionSkeleton extends StatelessWidget {
  const AppNutritionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        AppSkeleton(height: 170, radius: 26),
        SizedBox(height: 22),
        AppSkeletonCard(height: 95),
        AppSkeletonCard(height: 95),
        AppSkeletonCard(height: 95),
        AppSkeletonCard(height: 95),
      ],
    );
  }
}

class AppWorkoutSkeleton extends StatelessWidget {
  const AppWorkoutSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        AppSkeleton(height: 210, radius: 28),
        SizedBox(height: 24),
        AppSkeletonCard(height: 95),
        AppSkeletonCard(height: 95),
        AppSkeletonCard(height: 95),
      ],
    );
  }
}
