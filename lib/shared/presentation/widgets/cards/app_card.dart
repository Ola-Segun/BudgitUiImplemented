import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Card elevation levels
enum AppCardElevation {
  none,
  low,
  medium,
  high,
}

/// Base card component following design system
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AppCardElevation elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation = AppCardElevation.none,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.onTap,
    this.width,
    this.height,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(AppDimensions.cardPadding);
    final effectiveBorderRadius = borderRadius ?? AppDimensions.cardBorderRadius;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.surface;

    Widget card = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: _getShadow(),
      ),
      clipBehavior: clipBehavior,
      child: child,
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.05, duration: 400.ms, curve: Curves.easeOutCubic);

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: Semantics(
          label: 'Tap to interact with card',
          button: true,
          child: InkWell(
            onTap: () {
              // Add haptic feedback
              Feedback.forTap(context);
              onTap!();
            },
            borderRadius: effectiveBorderRadius,
            child: card,
          ),
        ),
      ).animate()
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.98, 0.98), duration: 100.ms, curve: Curves.easeInOut)
        .then()
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), duration: 100.ms, curve: Curves.easeInOut);
    }

    return card;
  }

  List<BoxShadow>? _getShadow() {
    switch (elevation) {
      case AppCardElevation.none:
        return null;
      case AppCardElevation.low:
        return [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case AppCardElevation.medium:
        return [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case AppCardElevation.high:
        return [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ];
    }
  }
}