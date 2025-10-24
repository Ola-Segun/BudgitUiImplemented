import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Button variants for different use cases
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

/// Button sizes
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Comprehensive button component following design system
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading || onPressed == null;

    return SizedBox(
      width: width ?? _getWidth(),
      height: height ?? _getHeight(),
      child: ElevatedButton(
        onPressed: effectiveDisabled ? null : onPressed,
        style: _getButtonStyle(context),
        child: _buildContent(),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading || onPressed == null;

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: effectiveDisabled ? AppColors.borderSubtle : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textTertiary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          textStyle: _getTextStyle(),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );

      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: effectiveDisabled ? AppColors.borderSubtle : AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textTertiary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          textStyle: _getTextStyle(),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );

      case AppButtonVariant.outline:
        return ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: effectiveDisabled ? AppColors.textTertiary : AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
            side: BorderSide(
              color: effectiveDisabled ? AppColors.border : AppColors.primary,
              width: 1.5,
            ),
          ),
          textStyle: _getTextStyle(),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );

      case AppButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: effectiveDisabled ? AppColors.textTertiary : AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          textStyle: _getTextStyle(),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        width: AppDimensions.iconSm,
        height: AppDimensions.iconSm,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary || variant == AppButtonVariant.secondary
                ? Colors.white
                : AppColors.primary,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _getIconSize()),
          const SizedBox(width: 8),
        ],
        Text(text),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: _getIconSize()),
        ],
      ],
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return AppTypography.button;
      case AppButtonSize.large:
        return AppTypography.button.copyWith(fontSize: 18);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.iconSm;
      case AppButtonSize.medium:
        return AppDimensions.iconMd;
      case AppButtonSize.large:
        return AppDimensions.iconLg;
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeightMd;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLg;
    }
  }

  double? _getWidth() {
    return null; // Full width by default, can be overridden
  }
}