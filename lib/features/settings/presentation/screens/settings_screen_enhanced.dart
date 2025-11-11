import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/info_card_pattern.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_toggle_tile.dart';
import '../widgets/settings_slider_tile.dart';
import '../widgets/settings_selection_tile.dart';
import '../widgets/theme_selector_sheet.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/date_format_selector_sheet.dart';
import '../widgets/export_data_dialog.dart';
import '../widgets/import_data_dialog.dart';
import '../widgets/clear_data_dialog.dart';
import 'two_factor_setup_screen.dart';
import '../../domain/entities/settings.dart';

// Accessibility utilities
class AccessibilityUtils {
  // Ensure minimum touch target size (48x48dp)
  static const double minTouchTargetSize = 48.0;

  // Check if color meets contrast requirements
  static bool meetsContrastRatio(Color foreground, Color background) {
    // Simple luminance calculation for contrast checking
    double getLuminance(Color color) {
      final r = color.r / 255.0;
      final g = color.g / 255.0;
      final b = color.b / 255.0;
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    final fgLuminance = getLuminance(foreground);
    final bgLuminance = getLuminance(background);
    final contrast = (fgLuminance > bgLuminance)
        ? (fgLuminance + 0.05) / (bgLuminance + 0.05)
        : (bgLuminance + 0.05) / (fgLuminance + 0.05);

    return contrast >= 4.5;
  }

  // Get accessible text color based on background
  static Color getAccessibleTextColor(Color background) {
    return ColorTokens.isLight(background)
        ? ColorTokens.textPrimary
        : ColorTokens.textInverse;
  }
}

/// Enhanced settings screen with modern UI and smooth animations
class SettingsScreenEnhanced extends ConsumerStatefulWidget {
  const SettingsScreenEnhanced({super.key});

  @override
  ConsumerState<SettingsScreenEnhanced> createState() => _SettingsScreenEnhancedState();
}

class _SettingsScreenEnhancedState extends ConsumerState<SettingsScreenEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: DesignTokens.curveEaseOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Semantics(
          label: 'Settings screen',
          hint: 'Scroll to view and modify app settings',
          child: settingsAsync.when(
            data: (state) => _buildSettingsContent(context, state.settings),
            loading: () => const LoadingView(),
            error: (error, stack) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.refresh(settingsNotifierProvider),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorTokens.surfacePrimary,
      elevation: 0,
      title: Text(
        'Settings',
        style: TypographyTokens.heading3,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.restore),
          tooltip: 'Reset to defaults',
          onPressed: () => _showResetDialog(context),
        ),
      ],
    );
  }

  Widget _buildSettingsContent(BuildContext context, AppSettings settings) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(settingsNotifierProvider.notifier).loadSettings();
      },
      color: ColorTokens.teal500,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Semantics(
              label: 'User profile section',
              child: _buildProfileCard(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Appearance Section
            Semantics(
              label: 'Appearance settings section',
              child: _buildAppearanceSection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Account Themes Section
            Semantics(
              label: 'Account themes settings section',
              child: _buildAccountThemesSection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Notifications Section
            Semantics(
              label: 'Notification settings section',
              child: _buildNotificationsSection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Security Section
            Semantics(
              label: 'Security and privacy settings section',
              child: _buildSecuritySection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Privacy Mode Section
            Semantics(
              label: 'Privacy mode settings section',
              child: _buildPrivacySection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 350.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 350.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Data Management Section
            Semantics(
              label: 'Data management section',
              child: _buildDataManagementSection(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // About Section
            Semantics(
              label: 'About section',
              child: _buildAboutSection(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),
            ),

            SizedBox(height: DesignTokens.spacing8),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Semantics(
      label: 'User profile card',
      hint: 'Displays user information and edit option',
      child: Container(
        padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
        decoration: BoxDecoration(
          gradient: ColorTokens.gradientPrimary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          boxShadow: DesignTokens.elevationColored(
            ColorTokens.teal500,
            alpha: 0.3,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Semantics(
              label: 'User avatar',
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
                child: Icon(
                  Icons.person,
                  size: DesignTokens.iconXl,
                  color: Colors.white,
                  semanticLabel: 'User profile icon',
                ),
              ).animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: DesignTokens.durationNormal,
                  delay: 200.ms,
                  curve: DesignTokens.curveElastic,
                ),
            ),

            SizedBox(width: DesignTokens.spacing4),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: TypographyTokens.heading5.copyWith(
                      color: AccessibilityUtils.getAccessibleTextColor(ColorTokens.teal500),
                    ),
                    semanticsLabel: 'User name: John Doe',
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                    .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

                  const SizedBox(height: 4),
                  Text(
                    'john.doe@example.com',
                    style: TypographyTokens.bodyMd.copyWith(
                      color: AccessibilityUtils.getAccessibleTextColor(ColorTokens.teal500).withValues(alpha: 0.9),
                    ),
                    semanticsLabel: 'User email: john.doe@example.com',
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                    .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),
                ],
              ),
            ),

            // Edit Button
            Semantics(
              button: true,
              label: 'Edit profile',
              hint: 'Double tap to edit user profile information',
              child: Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  Icons.edit,
                  size: DesignTokens.iconMd,
                  color: Colors.white,
                  semanticLabel: 'Edit profile icon',
                ),
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: DesignTokens.durationNormal,
                  delay: 500.ms,
                  curve: DesignTokens.curveElastic,
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppSettings settings) {
    return InfoCardPattern(
      title: 'Appearance',
      icon: Icons.palette,
      iconColor: ColorTokens.purple600,
      children: [
        Semantics(
          label: 'Theme selection',
          hint: 'Double tap to change app theme',
          child: SettingsSelectionTile(
            title: 'Theme',
            subtitle: _getThemeDisplayName(settings.themeMode),
            icon: Icons.dark_mode,
            onTap: () => _showThemeSelector(context, settings.themeMode),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
        ),

        SizedBox(height: DesignTokens.spacing2),

        Semantics(
          label: 'Currency selection',
          hint: 'Double tap to change currency',
          child: SettingsSelectionTile(
            title: 'Currency',
            subtitle: settings.currencyCode ?? 'USD',
            icon: Icons.attach_money,
            onTap: () => _showCurrencySelector(context, settings.currencyCode ?? 'USD'),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),
        ),

        SizedBox(height: DesignTokens.spacing2),

        Semantics(
          label: 'Date format selection',
          hint: 'Double tap to change date format',
          child: SettingsSelectionTile(
            title: 'Date Format',
            subtitle: settings.dateFormat,
            icon: Icons.calendar_today,
            onTap: () => _showDateFormatSelector(context, settings.dateFormat),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
        ),
      ],
    );
  }

  Widget _buildAccountThemesSection(BuildContext context, AppSettings settings) {
    return InfoCardPattern(
      title: 'Account Themes',
      icon: Icons.account_balance_wallet,
      iconColor: ColorTokens.teal600,
      children: [
        Semantics(
          label: 'Account themes customization',
          hint: 'Double tap to customize account type themes',
          child: SettingsSelectionTile(
            title: 'Customize Account Themes',
            subtitle: 'Change colors and icons for account types',
            icon: Icons.color_lens,
            onTap: () => _showAccountThemesEditor(context, settings.accountTypeThemes),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, AppSettings settings) {
    return InfoCardPattern(
      title: 'Notifications',
      icon: Icons.notifications,
      iconColor: ColorTokens.warning500,
      children: [
        Semantics(
          label: 'Push notifications toggle',
          hint: 'Double tap to enable or disable push notifications',
          child: SettingsToggleTile(
            title: 'Push Notifications',
            subtitle: 'Receive app notifications',
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsNotifierProvider.notifier)
                  .updateNotificationsEnabled(value);
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
        ),

        if (settings.notificationsEnabled) ...[
          SizedBox(height: DesignTokens.spacing2),
          Semantics(
            label: 'Budget alerts toggle',
            hint: 'Double tap to enable or disable budget alerts',
            child: SettingsToggleTile(
              title: 'Budget Alerts',
              subtitle: 'Notify when approaching budget limits',
              value: settings.budgetAlertsEnabled,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier)
                    .updateBudgetAlertsEnabled(value);
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),
          ),

          SizedBox(height: DesignTokens.spacing2),
          Semantics(
            label: 'Budget alert threshold slider',
            hint: 'Adjust the percentage at which budget alerts trigger',
            child: SettingsSliderTile(
              title: 'Budget Alert Threshold',
              subtitle: '${settings.budgetAlertThreshold}% of budget',
              value: settings.budgetAlertThreshold.toDouble(),
              min: 50,
              max: 100,
              divisions: 10,
              enabled: settings.budgetAlertsEnabled,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier)
                    .updateBudgetAlertThreshold(value.round());
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
          ),

          SizedBox(height: DesignTokens.spacing2),
          Semantics(
            label: 'Bill reminders toggle',
            hint: 'Double tap to enable or disable bill reminders',
            child: SettingsToggleTile(
              title: 'Bill Reminders',
              subtitle: 'Remind about upcoming bills',
              value: settings.billRemindersEnabled,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier)
                    .updateBillRemindersEnabled(value);
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
          ),

          SizedBox(height: DesignTokens.spacing2),
          Semantics(
            label: 'Bill reminder days slider',
            hint: 'Adjust how many days before due date to send reminders',
            child: SettingsSliderTile(
              title: 'Bill Reminder Days',
              subtitle: '${settings.billReminderDays} days before due',
              value: settings.billReminderDays.toDouble(),
              min: 1,
              max: 14,
              divisions: 13,
              enabled: settings.billRemindersEnabled,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier)
                    .updateBillReminderDays(value.round());
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
          ),

          SizedBox(height: DesignTokens.spacing2),
          Semantics(
            label: 'Income reminders toggle',
            hint: 'Double tap to enable or disable income reminders',
            child: SettingsToggleTile(
              title: 'Income Reminders',
              subtitle: 'Remind about expected income',
              value: settings.incomeRemindersEnabled,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier)
                    .updateIncomeRemindersEnabled(value);
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 250.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 250.ms),
          ),

          SizedBox(height: DesignTokens.spacing2),
          Semantics(
            label: 'Income reminder days slider',
            hint: 'Adjust how many days before expected income to send reminders',
            child: SettingsSliderTile(
              title: 'Income Reminder Days',
              subtitle: '${settings.incomeReminderDays} days before',
              value: settings.incomeReminderDays.toDouble(),
              min: 0,
              max: 7,
              divisions: 7,
              enabled: settings.incomeRemindersEnabled,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier)
                    .updateIncomeReminderDays(value.round());
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 300.ms),
          ),
        ],
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context, AppSettings settings) {
    return InfoCardPattern(
      title: 'Security & Privacy',
      icon: Icons.security,
      iconColor: ColorTokens.critical500,
      children: [
        FutureBuilder<bool>(
          future: ref.read(settingsRepositoryProvider)
              .isBiometricAvailable()
              .then((result) => result.getOrDefault(false)),
          builder: (context, snapshot) {
            final isAvailable = snapshot.data ?? false;
            return SettingsToggleTile(
              title: 'Biometric Authentication',
              subtitle: isAvailable
                  ? 'Use fingerprint or face unlock'
                  : 'Not available on this device',
              value: settings.biometricEnabled && isAvailable,
              enabled: isAvailable,
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier)
                    .updateSetting('biometricEnabled', value);
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal);
          },
        ),
        SizedBox(height: DesignTokens.spacing2),
        SettingsToggleTile(
          title: 'Auto Backup',
          subtitle: 'Automatically backup data to cloud',
          value: settings.autoBackupEnabled,
          onChanged: (value) {
            ref.read(settingsNotifierProvider.notifier)
                .updateSetting('autoBackupEnabled', value);
          },
        ).animate()
          .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
          .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),

        SizedBox(height: DesignTokens.spacing2),

        Semantics(
          button: true,
          label: 'Two-factor authentication setup button',
          hint: 'Double tap to setup two-factor authentication',
          child: SettingsSelectionTile(
            title: 'Two-Factor Authentication',
            subtitle: settings.twoFactorEnabled
                ? 'Enabled (${_getMethodDisplayName(settings.twoFactorMethod)})'
                : 'Add an extra layer of security',
            icon: Icons.security,
            onTap: () => _navigateToTwoFactorSetup(context),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, AppSettings settings) {
    return InfoCardPattern(
      title: 'Privacy Mode',
      icon: Icons.visibility_off,
      iconColor: ColorTokens.purple600,
      children: [
        Semantics(
          label: 'Privacy mode toggle',
          hint: 'Double tap to enable or disable privacy mode',
          child: SettingsToggleTile(
            title: 'Privacy Mode',
            subtitle: 'Hide sensitive information like balances and account numbers',
            value: settings.privacyModeEnabled,
            onChanged: (value) {
              ref.read(settingsNotifierProvider.notifier)
                  .updateSetting('privacyModeEnabled', value);
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
        ),

        SizedBox(height: DesignTokens.spacing2),

        Semantics(
          label: 'Privacy mode gesture toggle',
          hint: 'Double tap to enable or disable three-finger double tap gesture',
          child: SettingsToggleTile(
            title: 'Gesture Activation',
            subtitle: 'Activate privacy mode with three-finger double tap',
            value: settings.privacyModeGestureEnabled,
            onChanged: (value) {
              ref.read(settingsNotifierProvider.notifier)
                  .updateSetting('privacyModeGestureEnabled', value);
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context) {
    return InfoCardPattern(
      title: 'Data Management',
      icon: Icons.storage,
      iconColor: ColorTokens.info500,
      children: [
        Semantics(
          button: true,
          label: 'Export data button',
          hint: 'Double tap to export your data as JSON file',
          child: _buildActionTile(
            context,
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your data as JSON',
            color: ColorTokens.success500,
            onTap: () => _showExportDialog(context),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
        ),

        SizedBox(height: DesignTokens.spacing2),

        Semantics(
          button: true,
          label: 'Import data button',
          hint: 'Double tap to import data from JSON file',
          child: _buildActionTile(
            context,
            icon: Icons.upload,
            title: 'Import Data',
            subtitle: 'Import from JSON file',
            color: ColorTokens.info500,
            onTap: () => _showImportDialog(context),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),
        ),

        SizedBox(height: DesignTokens.spacing2),

        Semantics(
          button: true,
          label: 'Clear all data button',
          hint: 'Double tap to permanently delete all app data',
          child: _buildActionTile(
            context,
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Permanently delete all app data',
            color: ColorTokens.critical500,
            onTap: () => _showClearDataDialog(context),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return InfoCardPattern(
      title: 'About',
      icon: Icons.info,
      iconColor: ColorTokens.neutral500,
      children: [
        FutureBuilder<String>(
          future: ref.read(settingsRepositoryProvider)
              .getAppVersion()
              .then((result) => result.getOrDefault('1.0.0')),
          builder: (context, snapshot) {
            final version = snapshot.data ?? '1.0.0';
            return _buildInfoRow('App Version', version).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal);
          },
        ),
        SizedBox(height: DesignTokens.spacing2),
        _buildInfoRow('Build Number', '100').animate()
          .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
          .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),

        SizedBox(height: DesignTokens.spacing4),

        Row(
          children: [
            Expanded(
              child: ActionButtonPattern(
                label: 'Terms of Service',
                variant: ButtonVariant.tertiary,
                size: ButtonSize.small,
                onPressed: () {},
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(
              child: ActionButtonPattern(
                label: 'Privacy Policy',
                variant: ButtonVariant.tertiary,
                size: ButtonSize.small,
                onPressed: () {},
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AccessibilityUtils.minTouchTargetSize,
          ),
          child: Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: ColorTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: ColorTokens.withOpacity(color, 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(icon, color: color, size: DesignTokens.iconMd, semanticLabel: '$title icon'),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TypographyTokens.bodyLg, semanticsLabel: title),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TypographyTokens.captionMd, semanticsLabel: subtitle),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: ColorTokens.textSecondary,
                  size: DesignTokens.iconMd,
                  semanticLabel: 'Navigate to $title',
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(duration: DesignTokens.durationNormal)
          .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TypographyTokens.bodyMd),
        Text(
          value,
          style: TypographyTokens.bodyMd.copyWith(
            fontWeight: TypographyTokens.weightSemiBold,
          ),
        ),
      ],
    );
  }

  // Helper methods for dialogs
  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeSelector(BuildContext context, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeSelectorSheet(currentTheme: current),
    );
  }

  void _showCurrencySelector(BuildContext context, String current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelectorSheet(currentCurrency: current),
    );
  }

  void _showDateFormatSelector(BuildContext context, String current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DateFormatSelectorSheet(currentFormat: current),
    );
  }

  void _showAccountThemesEditor(BuildContext context, Map<String, dynamic> currentThemes) {
    // TODO: Implement account themes editor sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account themes editor coming soon!')),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportDataDialog(),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImportDataDialog(),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ClearDataDialog(),
    );
  }

  String _getMethodDisplayName(String method) {
    switch (method) {
      case 'authenticator':
        return 'Authenticator App';
      case 'sms':
        return 'SMS';
      case 'email':
        return 'Email';
      default:
        return 'Unknown';
    }
  }

  void _navigateToTwoFactorSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TwoFactorSetupScreen(),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorTokens.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing2),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.warning500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                Icons.restore,
                color: ColorTokens.warning500,
                size: DesignTokens.iconMd,
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Text(
              'Reset Settings',
              style: TypographyTokens.heading5,
            ),
          ],
        ),
        content: Text(
          'Reset all settings to default values? This action cannot be undone.',
          style: TypographyTokens.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Reset settings
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.critical500,
            ),
            child: Text(
              'Reset',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.critical500,
                fontWeight: TypographyTokens.weightSemiBold,
              ),
            ),
          ),
        ],
      ).animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.curveElastic,
        )
        .fadeIn(duration: DesignTokens.durationNormal),
    );
  }
}