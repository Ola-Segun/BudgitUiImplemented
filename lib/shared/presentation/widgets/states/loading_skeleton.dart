import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

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
        baseColor: AppColors.borderSubtle,
        highlightColor: AppColors.surface,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.borderSubtle,
            borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .shimmer(duration: 1500.ms, delay: 200.ms);
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

  /// Transaction card skeleton
  static Widget transactionCard() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SkeletonComponents.avatar(size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonComponents.text(width: 120),
                const SizedBox(height: 4),
                SkeletonComponents.text(width: 80),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonComponents.text(width: 60),
              const SizedBox(height: 4),
              SkeletonComponents.text(width: 40),
            ],
          ),
        ],
      ),
    );
  }
}