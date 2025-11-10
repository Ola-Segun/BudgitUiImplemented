import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Status badge sizes
enum StatusBadgeSize {
  small,
  medium,
  large,
}

/// Status badge variants
enum StatusBadgeVariant {
  filled,      // Solid background
  outlined,    // Border only
  subtle,      // Light background
}

/// Standard status badge pattern
///
/// Features:
/// - Multiple sizes and variants
/// - Optional icon
/// - Semantic colors
/// - Consistent styling
///
/// Usage:
/// ```dart
/// StatusBadgePattern(
///   label: 'Active',
///   color: ColorTokens.statusNormal,
///   icon: Icons.check_circle,
///   size: StatusBadgeSize.medium,
///   variant: StatusBadgeVariant.subtle,
/// )
/// ```
class StatusBadgePattern extends StatelessWidget {
  const StatusBadgePattern({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.size = StatusBadgeSize.medium,
    this.variant = StatusBadgeVariant.subtle,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final StatusBadgeSize size;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final textStyle = _getTextStyle();
    final decoration = _getDecoration();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.paddingH,
        vertical: dimensions.paddingV,
      ),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dimensions.iconSize, color: _getContentColor()),
            SizedBox(width: dimensions.iconSpacing),
          ],
          Text(
            label,
            style: textStyle.copyWith(color: _getContentColor()),
          ),
        ],
      ),
    );
  }

  _BadgeDimensions _getDimensions() {
    switch (size) {
      case StatusBadgeSize.small:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing2,
          paddingV: DesignTokens.spacing05,
          iconSize: DesignTokens.iconXs,
          iconSpacing: DesignTokens.spacing1,
        );
      case StatusBadgeSize.medium:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing3,
          paddingV: DesignTokens.spacing1,
          iconSize: DesignTokens.iconSm,
          iconSpacing: DesignTokens.spacing1,
        );
      case StatusBadgeSize.large:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing4,
          paddingV: DesignTokens.spacing2,
          iconSize: DesignTokens.iconMd,
          iconSpacing: DesignTokens.spacing2,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case StatusBadgeSize.small:
        return TypographyTokens.labelXs;
      case StatusBadgeSize.medium:
        return TypographyTokens.labelSm;
      case StatusBadgeSize.large:
        return TypographyTokens.labelMd;
    }
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case StatusBadgeVariant.filled:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
        );
      case StatusBadgeVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          border: Border.all(color: color, width: 1.5),
        );
      case StatusBadgeVariant.subtle:
        return BoxDecoration(
          color: ColorTokens.withOpacity(color, 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          border: Border.all(
            color: ColorTokens.withOpacity(color, 0.3),
            width: 1,
          ),
        );
    }
  }

  Color _getContentColor() {
    switch (variant) {
      case StatusBadgeVariant.filled:
        return ColorTokens.getContrastingTextColor(color);
      case StatusBadgeVariant.outlined:
      case StatusBadgeVariant.subtle:
        return color;
    }
  }
}

class _BadgeDimensions {
  final double paddingH;
  final double paddingV;
  final double iconSize;
  final double iconSpacing;

  _BadgeDimensions({
    required this.paddingH,
    required this.paddingV,
    required this.iconSize,
    required this.iconSpacing,
  });
}