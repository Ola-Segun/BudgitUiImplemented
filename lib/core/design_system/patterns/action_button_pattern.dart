import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

/// Button variants
enum ButtonVariant {
  primary,      // Gradient with shadow
  secondary,    // Outlined
  tertiary,     // Text only
  danger,       // Red/destructive
}

/// Action button with consistent styling
///
/// Features:
/// - Multiple sizes and variants
/// - Gradient backgrounds
/// - Optional icon
/// - Loading state
/// - Haptic feedback
/// - Disabled state
///
/// Usage:
/// ```dart
/// ActionButtonPattern(
///   label: 'Create Budget',
///   icon: Icons.add,
///   variant: ButtonVariant.primary,
///   size: ButtonSize.large,
///   gradient: ColorTokens.gradientPrimary,
///   onPressed: () {},
/// )
/// ```
class ActionButtonPattern extends StatelessWidget {
  const ActionButtonPattern({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.gradient,
    this.color,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Gradient? gradient;
  final Color? color;
  final bool isFullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final isEnabled = onPressed != null && !isLoading;

    Widget button = _buildButton(context, dimensions, isEnabled);

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButton(BuildContext context, _ButtonDimensions dimensions, bool isEnabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(dimensions, isEnabled);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(dimensions, isEnabled);
      case ButtonVariant.tertiary:
        return _buildTertiaryButton(dimensions, isEnabled);
      case ButtonVariant.danger:
        return _buildDangerButton(dimensions, isEnabled);
    }
  }

  Widget _buildPrimaryButton(_ButtonDimensions dimensions, bool isEnabled) {
    final effectiveGradient = gradient ?? ColorTokens.gradientPrimary;
    final effectiveColor = color ?? ColorTokens.teal500;

    return Container(
      height: dimensions.height,
      decoration: BoxDecoration(
        gradient: isEnabled ? effectiveGradient : null,
        color: isEnabled ? null : ColorTokens.neutral300,
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        boxShadow: isEnabled
            ? DesignTokens.elevationColored(effectiveColor, alpha: 0.3)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(dimensions, ColorTokens.textInverse),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(_ButtonDimensions dimensions, bool isEnabled) {
    final effectiveColor = color ?? ColorTokens.teal500;

    return Container(
      height: dimensions.height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        border: Border.all(
          color: isEnabled ? effectiveColor : ColorTokens.neutral300,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(
              dimensions,
              isEnabled ? effectiveColor : ColorTokens.neutral400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTertiaryButton(_ButtonDimensions dimensions, bool isEnabled) {
    final effectiveColor = color ?? ColorTokens.teal500;

    return SizedBox(
      height: dimensions.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(
              dimensions,
              isEnabled ? effectiveColor : ColorTokens.neutral400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerButton(_ButtonDimensions dimensions, bool isEnabled) {
    return Container(
      height: dimensions.height,
      decoration: BoxDecoration(
        gradient: isEnabled ? ColorTokens.gradientCritical : null,
        color: isEnabled ? null : ColorTokens.neutral300,
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        boxShadow: isEnabled
            ? DesignTokens.elevationColored(ColorTokens.critical500, alpha: 0.3)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dimensions.paddingH),
            child: _buildButtonContent(dimensions, ColorTokens.textInverse),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(_ButtonDimensions dimensions, Color textColor) {
    return Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: dimensions.iconSize,
            height: dimensions.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
        ] else if (icon != null) ...[
          Icon(icon, color: textColor, size: dimensions.iconSize),
          SizedBox(width: dimensions.iconSpacing),
        ],
        Text(
          label,
          style: _getTextStyle().copyWith(color: textColor),
        ),
      ],
    );
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    onPressed?.call();
  }

  _ButtonDimensions _getDimensions() {
    switch (size) {
      case ButtonSize.small:
        return _ButtonDimensions(
          height: DesignTokens.buttonHeightSm,
          paddingH: DesignTokens.buttonPaddingHSm,
          iconSize: DesignTokens.iconSm,
          iconSpacing: DesignTokens.spacing1,
        );
      case ButtonSize.medium:
        return _ButtonDimensions(
          height: DesignTokens.buttonHeightMd,
          paddingH: DesignTokens.buttonPaddingHMd,
          iconSize: DesignTokens.iconMd,
          iconSpacing: DesignTokens.spacing2,
        );
      case ButtonSize.large:
        return _ButtonDimensions(
          height: DesignTokens.buttonHeightLg,
          paddingH: DesignTokens.buttonPaddingHLg,
          iconSize: DesignTokens.iconLg,
          iconSpacing: DesignTokens.spacing2,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return TypographyTokens.buttonSm;
      case ButtonSize.medium:
        return TypographyTokens.buttonMd;
      case ButtonSize.large:
        return TypographyTokens.buttonLg;
    }
  }
}

class _ButtonDimensions {
  final double height;
  final double paddingH;
  final double iconSize;
  final double iconSpacing;

  _ButtonDimensions({
    required this.height,
    required this.paddingH,
    required this.iconSize,
    required this.iconSpacing,
  });
}