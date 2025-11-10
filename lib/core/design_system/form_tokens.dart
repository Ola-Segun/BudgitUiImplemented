import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'color_tokens.dart';
import 'typography_tokens.dart';

/// Complete token system for forms
class FormTokens {

  // ============================================================================
  // FIELD DIMENSIONS
  // ============================================================================

  static const double fieldHeightSm = 40.0;
  static const double fieldHeightMd = 48.0;
  static const double fieldHeightLg = 56.0;

  static const double fieldPaddingH = DesignTokens.spacing4;  // 16px
  static const double fieldPaddingV = DesignTokens.spacing3;  // 12px

  // ============================================================================
  // FIELD SPACING
  // ============================================================================

  static const double fieldGapSm = DesignTokens.spacing3;   // 12px
  static const double fieldGapMd = DesignTokens.spacing4;   // 16px
  static const double fieldGapLg = DesignTokens.spacing5;   // 20px

  static const double sectionGap = DesignTokens.spacing6;    // 24px
  static const double groupGap = DesignTokens.spacing2;      // 8px

  // ============================================================================
  // FIELD COLORS
  // ============================================================================

  static const Color fieldBackground = ColorTokens.surfacePrimary;
  static const Color fieldBackgroundHover = ColorTokens.surfaceSecondary;
  static const Color fieldBackgroundFocused = ColorTokens.surfacePrimary;
  static const Color fieldBackgroundDisabled = ColorTokens.surfaceSecondary;

  static const Color fieldBorder = ColorTokens.borderPrimary;
  static const Color fieldBorderHover = ColorTokens.neutral400;
  static const Color fieldBorderFocused = ColorTokens.teal500;
  static const Color fieldBorderError = ColorTokens.critical500;
  static const Color fieldBorderSuccess = ColorTokens.success500;
  static const Color fieldBorderDisabled = ColorTokens.borderSecondary;

  // ============================================================================
  // LABEL & TEXT COLORS
  // ============================================================================

  static const Color labelColor = ColorTokens.textPrimary;
  static const Color labelColorDisabled = ColorTokens.textTertiary;
  static const Color hintColor = ColorTokens.textSecondary;
  static const Color helperColor = ColorTokens.textSecondary;
  static const Color errorColor = ColorTokens.critical500;
  static const Color successColor = ColorTokens.success500;

  // ============================================================================
  // ICON COLORS
  // ============================================================================

  static const Color iconColor = ColorTokens.textSecondary;
  static const Color iconColorFocused = ColorTokens.teal500;
  static const Color iconColorError = ColorTokens.critical500;
  static const Color iconColorDisabled = ColorTokens.textTertiary;

  // ============================================================================
  // FIELD BORDER RADIUS
  // ============================================================================

  static const double fieldRadiusSm = DesignTokens.radiusMd;   // 8px
  static const double fieldRadiusMd = DesignTokens.radiusLg;   // 12px
  static const double fieldRadiusLg = DesignTokens.radiusXl;   // 16px

  // ============================================================================
  // VALIDATION INDICATOR
  // ============================================================================

  static const double validationIndicatorSize = 16.0;
  static const double validationIndicatorStroke = 2.0;

  // ============================================================================
  // DROPDOWN
  // ============================================================================

  static const double dropdownMaxHeight = 300.0;
  static const double dropdownItemHeight = 48.0;
  static const double dropdownItemPadding = DesignTokens.spacing4;

  // ============================================================================
  // SWITCH & CHECKBOX
  // ============================================================================

  static const double switchWidth = 48.0;
  static const double switchHeight = 28.0;
  static const double switchThumbSize = 24.0;

  static const double checkboxSize = 20.0;
  static const double checkboxBorderWidth = 2.0;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get field decoration based on state
  static InputDecoration getDecoration({
    required String label,
    String? hint,
    String? helper,
    String? error,
    Widget? prefix,
    Widget? suffix,
    bool enabled = true,
    bool isValidating = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      errorText: error,
      prefixIcon: prefix,
      suffixIcon: isValidating
          ? SizedBox(
              width: validationIndicatorSize,
              height: validationIndicatorSize,
              child: Padding(
                padding: EdgeInsets.all(DesignTokens.spacing3),
                child: CircularProgressIndicator(
                  strokeWidth: validationIndicatorStroke,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColorFocused),
                ),
              ),
            )
          : suffix,
      enabled: enabled,
      filled: true,
      fillColor: enabled ? fieldBackground : fieldBackgroundDisabled,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderFocused, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderError, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderError, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderDisabled, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: fieldPaddingH,
        vertical: fieldPaddingV,
      ),
      labelStyle: TypographyTokens.labelMd.copyWith(
        color: enabled ? labelColor : labelColorDisabled,
      ),
      hintStyle: TypographyTokens.bodyMd.copyWith(
        color: hintColor,
      ),
      helperStyle: TypographyTokens.captionMd.copyWith(
        color: helperColor,
      ),
      errorStyle: TypographyTokens.captionMd.copyWith(
        color: errorColor,
        height: 0.8,
      ),
    );
  }
}