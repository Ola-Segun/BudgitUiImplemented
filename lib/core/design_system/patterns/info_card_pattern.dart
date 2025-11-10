import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Standard info card pattern with consistent styling
///
/// Features:
/// - Icon header with colored background
/// - Title with optional trailing widget
/// - Flexible content area
/// - Consistent padding and styling
/// - Optional tap handler
///
/// Usage:
/// ```dart
/// InfoCardPattern(
///   title: 'Budget Overview',
///   icon: Icons.pie_chart,
///   iconColor: ColorTokens.budgetPrimary,
///   trailing: TextButton(child: Text('View All')),
///   children: [
///     Text('Your content here'),
///   ],
///   onTap: () => navigate(),
/// )
/// ```
class InfoCardPattern extends StatelessWidget {
  const InfoCardPattern({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.trailing,
    required this.children,
    this.onTap,
    this.padding,
    this.elevation,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final List<Widget> children;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final List<BoxShadow>? elevation;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? ColorTokens.teal500;
    final effectivePadding = padding ?? EdgeInsets.all(DesignTokens.cardPaddingLg);
    final effectiveElevation = elevation ?? DesignTokens.elevationLow;

    final cardContent = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        boxShadow: effectiveElevation,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: ColorTokens.withOpacity(color, 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  icon,
                  size: DesignTokens.iconMd,
                  color: color,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Text(
                  title,
                  style: TypographyTokens.heading6,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: DesignTokens.spacing2),
                trailing!,
              ],
            ],
          ),
          SizedBox(height: DesignTokens.spacing4),

          // Content
          ...children,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}