import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Progress indicator pattern with automatic color-coding
///
/// Features:
/// - Automatic health color based on percentage
/// - Gradient progress bar
/// - Optional percentage and amounts display
/// - Animated transitions
/// - Glow effect for emphasis
///
/// Usage:
/// ```dart
/// ProgressIndicatorPattern(
///   label: 'Budget Usage',
///   current: 750,
///   total: 1000,
///   color: ColorTokens.budgetPrimary, // Optional override
///   showPercentage: true,
///   showAmounts: true,
/// )
/// ```
class ProgressIndicatorPattern extends StatelessWidget {
  const ProgressIndicatorPattern({
    super.key,
    required this.label,
    required this.current,
    required this.total,
    this.color,
    this.showPercentage = true,
    this.showAmounts = true,
    this.height = 8.0,
    this.animate = true,
  });

  final String label;
  final double current;
  final double total;
  final Color? color;
  final bool showPercentage;
  final bool showAmounts;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final progressColor = color ?? _getAutoColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TypographyTokens.labelMd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showPercentage) ...[
              SizedBox(width: DesignTokens.spacing2),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TypographyTokens.labelSm.copyWith(
                  color: progressColor,
                  fontWeight: TypographyTokens.weightBold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: DesignTokens.spacing2),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              // Background
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: ColorTokens.neutral200,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              // Progress
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: percentage),
                duration: animate ? DesignTokens.durationNormal : Duration.zero,
                curve: DesignTokens.curveEaseOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor,
                            ColorTokens.lighten(progressColor, 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: DesignTokens.elevationGlow(
                          progressColor,
                          alpha: 0.3,
                          spread: 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        if (showAmounts) ...[
          SizedBox(height: DesignTokens.spacing2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatCurrency(current),
                style: TypographyTokens.labelSm.copyWith(
                  color: progressColor,
                  fontWeight: TypographyTokens.weightBold,
                ),
              ),
              Text(
                'of ${_formatCurrency(total)}',
                style: TypographyTokens.captionMd,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getAutoColor(double percentage) {
    if (percentage < 0.5) return ColorTokens.success500;
    if (percentage < 0.75) return ColorTokens.warning500;
    if (percentage < 1.0) return ColorTokens.critical500;
    return ColorTokens.critical600;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    ).format(amount);
  }
}