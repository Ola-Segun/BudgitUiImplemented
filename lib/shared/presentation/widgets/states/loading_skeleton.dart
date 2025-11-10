import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_animations.dart';

/// Loading skeleton component with shimmer effect
class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: AppColors.borderSubtle.withValues(alpha: 0.3),
        highlightColor: AppColors.surface.withValues(alpha: 0.8),
        period: AppAnimations.normal, // Use consistent animation timing
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.borderSubtle.withValues(alpha: 0.4),
            borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: AppAnimations.fast) // Use consistent timing
      .scale(begin: const Offset(0.95, 0.95), duration: AppAnimations.fast) // Optimized timing
      .shimmer(duration: AppAnimations.slow, delay: AppAnimations.fast); // Consistent shimmer duration
  }
}

/// Predefined skeleton components for common use cases
class SkeletonComponents {
  /// Card skeleton
  static Widget card({double? width, double? height}) {
    return LoadingSkeleton(
      width: width ?? double.infinity,
      height: height ?? 120,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  /// Text skeleton
  static Widget text({double? width, double? height}) {
    return LoadingSkeleton(
      width: width ?? 200,
      height: height ?? 16,
      borderRadius: BorderRadius.circular(4),
      margin: const EdgeInsets.only(bottom: 8),
    );
  }

  /// Avatar skeleton
  static Widget avatar({double? size}) {
    final avatarSize = size ?? 48;
    return LoadingSkeleton(
      width: avatarSize,
      height: avatarSize,
      borderRadius: BorderRadius.circular(avatarSize / 2),
    );
  }

  /// Button skeleton
  static Widget button({double? width, double? height}) {
    return LoadingSkeleton(
      width: width ?? 120,
      height: height ?? AppDimensions.buttonHeightMd,
      borderRadius: AppDimensions.buttonBorderRadius,
    );
  }

  /// List item skeleton
  static Widget listItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SkeletonComponents.avatar(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonComponents.text(width: 150),
                const SizedBox(height: 4),
                SkeletonComponents.text(width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Transaction card skeleton with enhanced animations
  static Widget transactionCard() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderSubtle.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SkeletonComponents.avatar(size: 48)
              .animate()
              .fadeIn(duration: AppAnimations.fast)
              .scale(begin: const Offset(0.8, 0.8), duration: AppAnimations.fast, curve: Curves.elasticOut)
              .shimmer(duration: AppAnimations.slow, delay: AppAnimations.fast),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonComponents.text(width: 120)
                    .animate()
                    .slideX(begin: 0.1, duration: AppAnimations.normal, delay: AppAnimations.fast)
                    .fadeIn(duration: AppAnimations.normal, delay: AppAnimations.fast),
                const SizedBox(height: 4),
                SkeletonComponents.text(width: 80)
                    .animate()
                    .slideX(begin: 0.1, duration: AppAnimations.normal, delay: AppAnimations.fast * 1.5)
                    .fadeIn(duration: AppAnimations.normal, delay: AppAnimations.fast * 1.5),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonComponents.text(width: 60)
                  .animate()
                  .slideX(begin: -0.1, duration: AppAnimations.normal, delay: AppAnimations.fast * 2)
                  .fadeIn(duration: AppAnimations.normal, delay: AppAnimations.fast * 2),
              const SizedBox(height: 4),
              SkeletonComponents.text(width: 40)
                  .animate()
                  .slideX(begin: -0.1, duration: AppAnimations.normal, delay: AppAnimations.fast * 2.5)
                  .fadeIn(duration: AppAnimations.normal, delay: AppAnimations.fast * 2.5),
            ],
          ),
        ],
      ),
    ).animate()
        .slideY(begin: 0.05, duration: AppAnimations.normal)
        .fadeIn(duration: AppAnimations.fast)
        .shimmer(duration: AppAnimations.slow, delay: AppAnimations.normal);
  }
}