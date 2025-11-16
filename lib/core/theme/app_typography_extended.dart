import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Extended typography system for budget components
/// Based on the redesign guide with Inter font family
class AppTypographyExtended {
  AppTypographyExtended._();

  // ═══════════════════════════════════════════════════════════
  // ACCOUNT UI TYPOGRAPHY - SF Pro Display/Inter fonts
  // ═══════════════════════════════════════════════════════════

  /// Hero balance display - Large, bold numbers
  static final TextStyle accountBalanceHero = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.5,
    color: Colors.white,
  );

  /// Account balance display - Medium size
  static final TextStyle accountBalance = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1,
    color: Colors.white,
  );

  /// Account balance small - For secondary displays
  static final TextStyle accountBalanceSmall = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  /// Account label - For balance labels
  static final TextStyle accountLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Colors.white.withValues(alpha: 0.9),
  );

  /// Account name - Card titles
  static final TextStyle accountName = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: const Color(0xFF1F2937),
  );

  /// Account type - Subtitles
  static final TextStyle accountType = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: const Color(0xFF6B7280),
  );

  /// Status text - For healthy/attention indicators
  static final TextStyle statusText = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
  );

  /// Action button text
  static final TextStyle actionButton = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // ═══════════════════════════════════════════════════════════
  // CIRCULAR PROGRESS INDICATOR STYLES
  // ═══════════════════════════════════════════════════════════

  /// Circular progress percentage text
  static final TextStyle circularProgressPercentage = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Circular progress amount text
  static final TextStyle circularProgressAmount = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════
  // DATE PILL STYLES
  // ═══════════════════════════════════════════════════════════

  /// Date pill day number
  static final TextStyle datePillDay = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Date pill label (day name)
  static final TextStyle datePillLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ═══════════════════════════════════════════════════════════
  // STATUS MESSAGE STYLES
  // ═══════════════════════════════════════════════════════════

  /// Status message text
  static final TextStyle statusMessage = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════
  // METRIC CARD STYLES
  // ═══════════════════════════════════════════════════════════

  /// Metric percentage display
  static final TextStyle metricPercentage = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Metric label text
  static final TextStyle metricLabel = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ═══════════════════════════════════════════════════════════
  // STATS STYLES
  // ═══════════════════════════════════════════════════════════

  /// Stats value display
  static final TextStyle statsValue = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Stats label text
  static final TextStyle statsLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: const Color(0xFF6B7280),
  );

  // ═══════════════════════════════════════════════════════════
  // CHART STYLES
  // ═══════════════════════════════════════════════════════════

  /// Chart axis labels
  static final TextStyle chartLabel = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF9CA3AF),
  );

  /// Chart tooltip text
  static final TextStyle chartTooltip = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  /// Get colored status message style
  static TextStyle getColoredStatusMessage(Color color) {
    return statusMessage.copyWith(color: color);
  }

  /// Get colored metric percentage style
  static TextStyle getColoredMetricPercentage(Color color) {
    return metricPercentage.copyWith(color: color);
  }

  /// Get colored stats value style
  static TextStyle getColoredStatsValue(Color color) {
    return statsValue.copyWith(color: color);
  }

  /// Get colored account balance style
  static TextStyle getColoredAccountBalance(Color color) {
    return accountBalance.copyWith(color: color);
  }

  /// Get colored status text style
  static TextStyle getColoredStatusText(Color color) {
    return statusText.copyWith(color: color);
  }
}