import 'package:flutter/material.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../domain/entities/notification.dart';

/// Simplified design tokens for notifications
class NotificationTokens {
  // ============================================================================
  // VISUAL HIERARCHY
  // ============================================================================

  /// Large, obvious unread indicator
  static const double unreadDotSize = 10.0;

  /// Reduced border width for cleaner appearance
  static const double cardBorderWidth = 1.0;

  /// Consistent card radius across app
  static const double cardRadius = 12.0;

  /// Generous padding for touch-friendly cards
  static const double cardPadding = 16.0;

  /// Clear spacing between notification cards
  static const double cardSpacing = 12.0;

  // ============================================================================
  // SIMPLIFIED COLOR SYSTEM
  // ============================================================================

  /// Unread background - subtle highlight
  static final Color unreadBackground = ColorTokens.teal500.withValues(alpha: 0.03);

  /// Read background - clean white
  static const Color readBackground = ColorTokens.surfacePrimary;

  /// Unread indicator - prominent teal
  static const Color unreadIndicator = ColorTokens.teal500;

  /// Type indicators - simplified palette matching transaction categories
  static const Map<NotificationType, Color> typeColors = {
    NotificationType.budgetAlert: Color(0xFFF59E0B), // Amber
    NotificationType.billReminder: Color(0xFF3B82F6), // Blue
    NotificationType.goalMilestone: Color(0xFF10B981), // Green
    NotificationType.accountAlert: Color(0xFFEF4444), // Red
    NotificationType.transactionReceipt: Color(0xFF8B5CF6), // Purple
    NotificationType.incomeReminder: Color(0xFF10B981), // Green
    NotificationType.systemUpdate: Color(0xFF6366F1), // Indigo
  };

  // ============================================================================
  // INTERACTION STATES
  // ============================================================================

  /// Subtle press feedback
  static const double pressScale = 0.98;

  /// Quick, responsive animations
  static const Duration interactionDuration = Duration(milliseconds: 150);

  /// Smooth scroll physics
  static const ScrollPhysics scrollPhysics = BouncingScrollPhysics();

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  /// Notification title - clear and readable
  static TextStyle get titleStyle => TypographyTokens.labelMd.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.4,
    color: ColorTokens.textPrimary,
  );

  /// Notification message - secondary info
  static TextStyle get messageStyle => TypographyTokens.bodyMd.copyWith(
    fontSize: 14,
    height: 1.5,
    color: ColorTokens.textSecondary,
  );

  /// Timestamp - tertiary info
  static TextStyle get timestampStyle => TypographyTokens.captionMd.copyWith(
    fontSize: 12,
    color: ColorTokens.textTertiary,
  );

  /// Type badge - small, clear label
  static TextStyle get typeBadgeStyle => TypographyTokens.captionSm.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}