import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  /// Light theme - primary theme for the app
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ═══════════════════════════════════════════════════════════
      // COLOR SCHEME
      // ═══════════════════════════════════════════════════════════

      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),

      // ═══════════════════════════════════════════════════════════
      // TYPOGRAPHY
      // ═══════════════════════════════════════════════════════════

      textTheme: AppTypography.textTheme,

      // ═══════════════════════════════════════════════════════════
      // SCAFFOLD
      // ═══════════════════════════════════════════════════════════

      scaffoldBackgroundColor: AppColors.background,

      // ═══════════════════════════════════════════════════════════
      // APP BAR
      // ═══════════════════════════════════════════════════════════

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.h2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),

      // ═══════════════════════════════════════════════════════════
      // CARD
      // ═══════════════════════════════════════════════════════════

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.cardBorderRadius,
        ),
        color: AppColors.surface,
        margin: EdgeInsets.zero,
      ),

      // ═══════════════════════════════════════════════════════════
      // BUTTONS
      // ═══════════════════════════════════════════════════════════

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.buttonBorderRadius,
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(120, 48),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // INPUT DECORATION
      // ═══════════════════════════════════════════════════════════

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
      ),

      // ═══════════════════════════════════════════════════════════
      // FAB
      // ═══════════════════════════════════════════════════════════

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // BOTTOM NAVIGATION
      // ═══════════════════════════════════════════════════════════

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ═══════════════════════════════════════════════════════════
      // DIVIDER
      // ═══════════════════════════════════════════════════════════

      dividerTheme: DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // ═══════════════════════════════════════════════════════════
      // PAGE TRANSITIONS
      // ═══════════════════════════════════════════════════════════

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ═══════════════════════════════════════════════════════════
      // DRAWER THEME
      // ═══════════════════════════════════════════════════════════

      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppDimensions.radiusLg),
            bottomRight: Radius.circular(AppDimensions.radiusLg),
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // NAVIGATION RAIL THEME (for larger screens)
      // ═══════════════════════════════════════════════════════════

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: IconThemeData(color: AppColors.primary, size: 24),
        unselectedIconTheme: IconThemeData(color: AppColors.textTertiary, size: 24),
        selectedLabelTextStyle: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
        ),
        elevation: 4,
        groupAlignment: 0,
      ),

      // ═══════════════════════════════════════════════════════════
      // NAVIGATION BAR THEME (Material 3)
      // ═══════════════════════════════════════════════════════════

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        indicatorColor: AppColors.primary.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.caption.copyWith(color: AppColors.textTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: AppColors.textTertiary, size: 24);
        }),
      ),
    );
  }

  /// Dark theme - for future implementation
  static ThemeData darkTheme() {
    // TODO: Implement dark theme
    return lightTheme();
  }

  // ═══════════════════════════════════════════════════════════
  // SPACING GETTERS - Delegate to AppSpacing
  // ═══════════════════════════════════════════════════════════

  static EdgeInsets get screenPaddingAll => AppSpacing.screenPaddingAll;
  static EdgeInsets get cardPaddingAll => AppSpacing.cardPaddingAll;
  static double get xs => AppSpacing.xs;
  static double get sm => AppSpacing.sm;
  static double get md => AppSpacing.md;
  static double get lg => AppSpacing.lg;
  static double get xl => AppSpacing.xl;
}