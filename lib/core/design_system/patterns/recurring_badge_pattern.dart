// lib/core/design_system/patterns/recurring_badge_pattern.dart

import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Recurring transaction badge pattern following TransformDesign
/// Shows that a transaction is generated from a recurring template
class RecurringBadgePattern extends StatelessWidget {
  const RecurringBadgePattern({
    super.key,
    this.size = RecurringBadgeSize.small,
    this.variant = RecurringBadgeVariant.subtle,
    this.onTap,
  });

  final RecurringBadgeSize size;
  final RecurringBadgeVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final textStyle = _getTextStyle();
    final decoration = _getDecoration();

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.paddingH,
        vertical: dimensions.paddingV,
      ),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            size: dimensions.iconSize,
            color: _getContentColor(),
          ),
          // SizedBox(width: dimensions.iconSpacing),
          // Text(
          //   'Recurring',
          //   style: textStyle.copyWith(color: _getContentColor()),
          // ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          child: badge,
        ),
      );
    }

    return badge;
  }

  _BadgeDimensions _getDimensions() {
    switch (size) {
      case RecurringBadgeSize.small:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing2,
          paddingV: DesignTokens.spacing05,
          iconSize: DesignTokens.iconXs,
          iconSpacing: DesignTokens.spacing1,
        );
      case RecurringBadgeSize.medium:
        return _BadgeDimensions(
          paddingH: DesignTokens.spacing3,
          paddingV: DesignTokens.spacing1,
          iconSize: DesignTokens.iconSm,
          iconSpacing: DesignTokens.spacing1,
        );
      case RecurringBadgeSize.large:
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
      case RecurringBadgeSize.small:
        return TypographyTokens.labelXs;
      case RecurringBadgeSize.medium:
        return TypographyTokens.labelSm;
      case RecurringBadgeSize.large:
        return TypographyTokens.labelMd;
    }
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case RecurringBadgeVariant.filled:
        return BoxDecoration(
          color: ColorTokens.purple600,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
        );
      case RecurringBadgeVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          border: Border.all(
            color: ColorTokens.purple600,
            width: 1.5,
          ),
        );
      case RecurringBadgeVariant.subtle:
        return BoxDecoration(
          color: ColorTokens.withOpacity(ColorTokens.purple600, 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          border: Border.all(
            color: ColorTokens.withOpacity(ColorTokens.purple600, 0.3),
            width: 1,
          ),
        );
    }
  }

  Color _getContentColor() {
    switch (variant) {
      case RecurringBadgeVariant.filled:
        return ColorTokens.textInverse;
      case RecurringBadgeVariant.outlined:
      case RecurringBadgeVariant.subtle:
        return ColorTokens.purple600;
    }
  }
}

/// Recurring badge sizes
enum RecurringBadgeSize {
  small,
  medium,
  large,
}

/// Recurring badge variants
enum RecurringBadgeVariant {
  filled,    // Solid background
  outlined,  // Border only
  subtle,    // Light background
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