import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import 'action_button_pattern.dart';

/// Empty state pattern for consistent "no data" screens
///
/// Features:
/// - Icon with colored background
/// - Title and description
/// - Optional action button
/// - Animated entrance
///
/// Usage:
/// ```dart
/// EmptyStatePattern(
///   icon: Icons.inbox_outlined,
///   iconColor: ColorTokens.teal500,
///   title: 'No transactions yet',
///   description: 'Start tracking your finances by adding your first transaction',
///   actionLabel: 'Add Transaction',
///   onAction: () => navigate(),
/// )
/// ```
class EmptyStatePattern extends StatelessWidget {
  const EmptyStatePattern({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? ColorTokens.teal500;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacing8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing6),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(effectiveIconColor, 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: DesignTokens.icon3xl,
                color: effectiveIconColor,
              ),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: DesignTokens.durationNormal,
                curve: DesignTokens.curveElastic,
              ),

            SizedBox(height: DesignTokens.spacing5),

            // Title
            Text(
              title,
              style: TypographyTokens.heading4,
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms),

            if (description != null) ...[
              SizedBox(height: DesignTokens.spacing2),
              Text(
                description!,
                style: TypographyTokens.bodyMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms),
            ],

            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: DesignTokens.spacing6),
              ActionButtonPattern(
                label: actionLabel!,
                icon: actionIcon ?? Icons.add,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                gradient: ColorTokens.gradientCustom(
                  effectiveIconColor,
                  ColorTokens.darken(effectiveIconColor, 0.1),
                ),
                onPressed: onAction,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideY(
                  begin: 0.1,
                  duration: DesignTokens.durationNormal,
                  delay: 300.ms,
                  curve: DesignTokens.curveElastic,
                ),
            ],
          ],
        ),
      ),
    );
  }
}