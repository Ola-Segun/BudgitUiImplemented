import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';
import '../theme/app_animations.dart';

/// Skeleton loader widget with shimmer effect
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1000), // Optimized for performance
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      highlightColor: highlightColor ?? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      period: period,
      child: child,
    ).animate()
      .fadeIn(duration: AppAnimations.fast)
      .shimmer(duration: AppAnimations.slow, delay: AppAnimations.fast);
  }
}

/// Skeleton rectangle with rounded corners
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusSm),
      ),
    );
  }
}

/// Skeleton text line
class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width ?? MediaQuery.of(context).size.width * 0.6,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
    );
  }
}

/// Skeleton circle
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Transaction tile skeleton
class TransactionTileSkeleton extends StatelessWidget {
  const TransactionTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category icon skeleton
            const SkeletonCircle(size: 40),
            const SizedBox(width: 12),

            // Transaction details skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const SkeletonText(width: 120, height: 18),
                  const SizedBox(height: 6),

                  // Description
                  const SkeletonText(width: 80, height: 14),
                  const SizedBox(height: 6),

                  // Category and date
                  Row(
                    children: [
                      const SkeletonText(width: 60, height: 12),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SkeletonText(width: 40, height: 12),
                    ],
                  ),
                ],
              ),
            ),

            // Amount skeleton
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SkeletonText(width: 70, height: 18),
                const SizedBox(height: 4),
                const SkeletonText(width: 35, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction list skeleton with multiple tiles and staggered animations
class TransactionListSkeleton extends StatelessWidget {
  const TransactionListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) => TransactionTileSkeleton()
            .animate()
            .fadeIn(duration: AppAnimations.normal, delay: Duration(milliseconds: index * 100))
            .slideY(begin: 0.1, duration: AppAnimations.normal, delay: Duration(milliseconds: index * 100)),
      ),
    );
  }
}

/// Stats card skeleton with enhanced animations
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonText(width: 100, height: 16)
                .animate()
                .fadeIn(duration: AppAnimations.fast)
                .slideX(begin: 0.1, duration: AppAnimations.fast),
            const SizedBox(height: 8),
            const SkeletonText(width: 80, height: 24)
                .animate()
                .fadeIn(duration: AppAnimations.fast, delay: AppAnimations.fast)
                .slideX(begin: 0.1, duration: AppAnimations.fast, delay: AppAnimations.fast),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonText(width: 60, height: 14)
                          .animate()
                          .fadeIn(duration: AppAnimations.fast, delay: AppAnimations.fast * 2)
                          .slideY(begin: 0.1, duration: AppAnimations.fast, delay: AppAnimations.fast * 2),
                      const SizedBox(height: 4),
                      const SkeletonText(width: 40, height: 16)
                          .animate()
                          .fadeIn(duration: AppAnimations.fast, delay: AppAnimations.fast * 2.5)
                          .slideY(begin: 0.1, duration: AppAnimations.fast, delay: AppAnimations.fast * 2.5),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonText(width: 60, height: 14)
                          .animate()
                          .fadeIn(duration: AppAnimations.fast, delay: AppAnimations.fast * 3)
                          .slideY(begin: 0.1, duration: AppAnimations.fast, delay: AppAnimations.fast * 3),
                      const SizedBox(height: 4),
                      const SkeletonText(width: 40, height: 16)
                          .animate()
                          .fadeIn(duration: AppAnimations.fast, delay: AppAnimations.fast * 3.5)
                          .slideY(begin: 0.1, duration: AppAnimations.fast, delay: AppAnimations.fast * 3.5),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: AppAnimations.fast)
      .slideY(begin: 0.05, duration: AppAnimations.normal);
  }
}