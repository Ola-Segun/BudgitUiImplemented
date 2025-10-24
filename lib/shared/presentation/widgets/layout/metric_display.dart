import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Metric display component for showing key statistics and numbers
class MetricDisplay extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;
  final Color? labelColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const MetricDisplay({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
    this.labelColor,
    this.iconColor,
    this.backgroundColor,
    this.valueStyle,
    this.labelStyle,
    this.padding,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(AppDimensions.cardPadding);

    Widget content = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon (if provided)
          if (icon != null) ...[
            Icon(
              icon,
              size: AppDimensions.iconLg,
              color: iconColor ?? AppColors.primary,
            ).animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
          ],

          // Value
          Text(
            value,
            style: valueStyle ??
                AppTypography.currency.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 100.ms, curve: Curves.easeOutCubic),

          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: labelStyle ??
                AppTypography.caption.copyWith(
                  color: labelColor ?? AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.05, duration: 500.ms, curve: Curves.easeOutCubic);

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: InkWell(
          onTap: () {
            Feedback.forTap(context);
            onTap!();
          },
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Compact metric display for inline usage
class CompactMetricDisplay extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;
  final Color? labelColor;
  final Color? iconColor;

  const CompactMetricDisplay({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: AppDimensions.iconMd,
            color: iconColor ?? AppColors.primary,
          ),
          const SizedBox(width: 8),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: labelColor ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}