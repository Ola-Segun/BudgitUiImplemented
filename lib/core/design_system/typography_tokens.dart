import 'package:flutter/material.dart';
import 'color_tokens.dart';

/// Complete typography system with semantic naming
class TypographyTokens {

  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilyFallback = 'SF Pro Display';
  static const String fontFamilyMono = 'JetBrains Mono';

  static const List<String> fontFamilyStack = [
    fontFamilyPrimary,
    fontFamilyFallback,
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  // ============================================================================
  // FONT WEIGHTS
  // ============================================================================

  static const FontWeight weightThin = FontWeight.w100;
  static const FontWeight weightExtraLight = FontWeight.w200;
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;
  static const FontWeight weightBlack = FontWeight.w900;

  // ============================================================================
  // FONT SIZES
  // ============================================================================

  static const double fontSize3xs = 10.0;
  static const double fontSize2xs = 11.0;
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeBase = 14.0;   // Base size
  static const double fontSizeMd = 15.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSize2xl = 20.0;
  static const double fontSize3xl = 24.0;
  static const double fontSize4xl = 28.0;
  static const double fontSize5xl = 32.0;
  static const double fontSize6xl = 36.0;
  static const double fontSize7xl = 48.0;
  static const double fontSize8xl = 64.0;

  // ============================================================================
  // LINE HEIGHTS
  // ============================================================================

  static const double lineHeightTight = 1.2;
  static const double lineHeightSnug = 1.3;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.5;
  static const double lineHeightLoose = 1.6;

  // ============================================================================
  // LETTER SPACING
  // ============================================================================

  static const double letterSpacingTighter = -0.8;
  static const double letterSpacingTight = -0.4;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.4;
  static const double letterSpacingWider = 0.8;

  // ============================================================================
  // DISPLAY STYLES (Hero text, large headings)
  // ============================================================================

  static TextStyle get display1 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize8xl,
    fontWeight: weightBlack,
    height: lineHeightTight,
    letterSpacing: letterSpacingTighter,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get display2 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize7xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get display3 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize6xl,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );

  // ============================================================================
  // HEADING STYLES
  // ============================================================================

  static TextStyle get heading1 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize5xl,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get heading2 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize4xl,
    fontWeight: weightBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get heading3 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize3xl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get heading4 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get heading5 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get heading6 => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  // ============================================================================
  // BODY TEXT STYLES
  // ============================================================================

  static TextStyle get bodyXl => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXl,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get bodyLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get bodyMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get bodySm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get bodyXs => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  // ============================================================================
  // LABEL STYLES
  // ============================================================================

  static TextStyle get labelLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get labelMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get labelSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get labelXs => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: ColorTokens.textPrimary,
  );

  // ============================================================================
  // CAPTION STYLES
  // ============================================================================

  static TextStyle get captionLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );

  static TextStyle get captionMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );

  static TextStyle get captionSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );

  // ============================================================================
  // OVERLINE STYLES (Small caps, uppercase labels)
  // ============================================================================

  static TextStyle get overlineLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: ColorTokens.textSecondary,
  );

  static TextStyle get overlineMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: ColorTokens.textSecondary,
  );

  static TextStyle get overlineSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize3xs,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
    color: ColorTokens.textSecondary,
  );

  // ============================================================================
  // BUTTON TEXT STYLES
  // ============================================================================

  static TextStyle get buttonLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get buttonMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get buttonSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  // ============================================================================
  // NUMERIC STYLES (For financial data)
  // ============================================================================

  static TextStyle get numericXl => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize5xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get numericLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize3xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get numericMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get numericSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ============================================================================
  // LINK STYLES
  // ============================================================================

  static TextStyle get linkLg => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textLink,
    decoration: TextDecoration.underline,
  );

  static TextStyle get linkMd => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightMedium,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textLink,
    decoration: TextDecoration.underline,
  );

  static TextStyle get linkSm => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textLink,
    decoration: TextDecoration.underline,
  );

  // ============================================================================
  // CODE/MONOSPACE STYLES
  // ============================================================================

  static TextStyle get codeLg => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: fontSizeLg,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get codeMd => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: fontSizeBase,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  static TextStyle get codeSm => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: fontSizeSm,
    fontWeight: weightRegular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  // ============================================================================
  // SEMANTIC STYLES (App-specific)
  // ============================================================================

  /// Circular progress percentage (e.g., "32%")
  static TextStyle get circularProgressPercentage => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize5xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Circular progress amount (e.g., "$83 / $200")
  static TextStyle get circularProgressAmount => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Date pill day (e.g., "24")
  static TextStyle get datePillDay => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  /// Date pill label (e.g., "Mon")
  static TextStyle get datePillLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );

  /// Status message
  static TextStyle get statusMessage => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeBase,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
  );

  /// Metric percentage (e.g., "56%")
  static TextStyle get metricPercentage => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize4xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Metric label (e.g., "Usage Rate")
  static TextStyle get metricLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );

  /// Stats value (e.g., "$1,250")
  static TextStyle get statsValue => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xl,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Stats label (e.g., "Spent")
  static TextStyle get statsLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textSecondary,
  );

  /// Chart label
  static TextStyle get chartLabel => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSize2xs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textTertiary,
  );

  /// Chart tooltip
  static TextStyle get chartTooltip => TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: fontSizeXs,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: ColorTokens.textInverse,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Make text style bold
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: weightBold);
  }

  /// Make text style italic
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Apply underline decoration
  static TextStyle underline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }

  /// Apply line through decoration
  static TextStyle strikethrough(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.lineThrough);
  }

  /// Apply opacity to text
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }

  /// Get text style by name
  static TextStyle? getStyleByName(String name) {
    switch (name.toLowerCase()) {
      case 'display1': return display1;
      case 'display2': return display2;
      case 'display3': return display3;
      case 'heading1': case 'h1': return heading1;
      case 'heading2': case 'h2': return heading2;
      case 'heading3': case 'h3': return heading3;
      case 'heading4': case 'h4': return heading4;
      case 'heading5': case 'h5': return heading5;
      case 'heading6': case 'h6': return heading6;
      case 'bodyxl': return bodyXl;
      case 'bodylg': return bodyLg;
      case 'bodymd': return bodyMd;
      case 'bodysm': return bodySm;
      case 'bodyxs': return bodyXs;
      default: return null;
    }
  }
}