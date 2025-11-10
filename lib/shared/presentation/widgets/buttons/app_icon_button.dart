import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Icon button variants for different use cases
enum AppIconButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

/// Icon button sizes
enum AppIconButtonSize {
  small,
  medium,
  large,
}

/// Icon button component following design system
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppIconButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final String? tooltip;
  final Color? customColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.primary,
    this.size = AppIconButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.tooltip,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading || onPressed == null;

    return SizedBox(
      width: _getSize(),
      height: _getSize(),
      child: IconButton(
        onPressed: effectiveDisabled ? null : onPressed,
        icon: _buildIcon(),
        style: _getButtonStyle(context),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: _getSize(),
          minHeight: _getSize(),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading || onPressed == null;

    switch (variant) {
      case AppIconButtonVariant.primary:
        return IconButton.styleFrom(
          backgroundColor: effectiveDisabled ? AppColors.borderSubtle : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          padding: EdgeInsets.zero,
        );

      case AppIconButtonVariant.secondary:
        return IconButton.styleFrom(
          backgroundColor: effectiveDisabled ? AppColors.borderSubtle : AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          padding: EdgeInsets.zero,
        );

      case AppIconButtonVariant.outline:
        return IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: effectiveDisabled ? AppColors.textTertiary : AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
            side: BorderSide(
              color: effectiveDisabled ? AppColors.border : AppColors.primary,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.zero,
        );

      case AppIconButtonVariant.ghost:
        return IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: effectiveDisabled ? AppColors.textTertiary : AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          padding: EdgeInsets.zero,
        );
    }
  }

  Widget _buildIcon() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppIconButtonVariant.primary || variant == AppIconButtonVariant.secondary
                ? Colors.white
                : AppColors.primary,
          ),
        ),
      );
    }

    return Icon(
      icon,
      size: _getIconSize(),
      color: customColor,
    );
  }

  double _getSize() {
    switch (size) {
      case AppIconButtonSize.small:
        return 48; // Meets accessibility requirements (48x48dp minimum)
      case AppIconButtonSize.medium:
        return AppDimensions.buttonHeightMd > 48 ? AppDimensions.buttonHeightMd : 48;
      case AppIconButtonSize.large:
        return AppDimensions.buttonHeightLg > 48 ? AppDimensions.buttonHeightLg : 48;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppIconButtonSize.small:
        return AppDimensions.iconSm;
      case AppIconButtonSize.medium:
        return AppDimensions.iconMd;
      case AppIconButtonSize.large:
        return AppDimensions.iconLg;
    }
  }
}