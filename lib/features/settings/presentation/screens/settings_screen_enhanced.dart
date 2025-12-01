import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_slider_tile.dart';
import '../widgets/theme_selector_sheet.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/date_format_selector_sheet.dart';
import '../widgets/account_themes_editor_sheet.dart';
import '../widgets/export_data_dialog.dart';
import '../widgets/import_data_dialog.dart';
import '../widgets/clear_data_dialog.dart';
import '../../domain/services/locale_service.dart';
import 'two_factor_setup_screen.dart';
import '../../domain/entities/settings.dart';
import '../../../accounts/domain/entities/account_type_theme.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart' as onboarding_providers;

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
        child: SizedBox(
          width: double.infinity,
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

            // Language Section
            Semantics(
              label: 'Language settings section',
              child: _buildLanguageSection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Quiet Hours Section
            Semantics(
              label: 'Quiet hours settings section',
              child: _buildQuietHoursSection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 450.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 450.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Export Options Section
            Semantics(
              label: 'Export options settings section',
              child: _buildExportOptionsSection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 475.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 475.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Advanced Settings Section
            Semantics(
              label: 'Advanced settings section',
              child: _buildAdvancedSettingsSection(context, settings).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 490.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 490.ms),
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
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final userProfile = ref.watch(onboarding_providers.userProfileProvider);

    return Semantics(
      label: 'User profile card',
      hint: 'Displays user information and edit option',
      child: EditableProfileCard(
        userProfile: userProfile,
        onSave: (name, email) => _saveProfile(context, name, email),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context, String name, String email) async {
    final updateProfile = ref.read(onboarding_providers.updateUserProfileProvider);

    final result = await updateProfile(name: name, email: email);

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      error: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.categoryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.palette,
                  color: ModernColors.categoryPurple,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Appearance',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Theme Selection
          Semantics(
            label: 'Theme selection',
            hint: 'Double tap to change app theme',
            child: ModernActionButton(
              text: 'Theme: ${_getThemeDisplayName(settings.themeMode)}',
              icon: Icons.dark_mode,
              isPrimary: false,
              onPressed: () => _showThemeSelector(context, settings.themeMode),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),

          SizedBox(height: spacing_md),

          // Currency Selection
          Semantics(
            label: 'Currency selection',
            hint: 'Double tap to change currency',
            child: ModernActionButton(
              text: 'Currency: ${settings.currencyCode ?? 'USD'}',
              icon: Icons.attach_money,
              isPrimary: false,
              onPressed: () => _showCurrencySelector(context, settings.currencyCode ?? 'USD'),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),

          SizedBox(height: spacing_md),

          // Date Format Selection
          Semantics(
            label: 'Date format selection',
            hint: 'Double tap to change date format',
            child: ModernActionButton(
              text: 'Date Format: ${settings.dateFormat}',
              icon: Icons.calendar_today,
              isPrimary: false,
              onPressed: () => _showDateFormatSelector(context, settings.dateFormat),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildAccountThemesSection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: ModernColors.accentGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Account Themes',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Account Themes Customization
          Semantics(
            label: 'Account themes customization',
            hint: 'Double tap to customize account type themes',
            child: ModernActionButton(
              text: 'Customize Account Themes',
              icon: Icons.color_lens,
              isPrimary: false,
              onPressed: () => _showAccountThemesEditor(context, settings.accountTypeThemes),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.notifications,
                  color: ModernColors.warning,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Notifications',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Push Notifications Toggle
Semantics(
  label: 'Push notifications toggle',
  hint: 'Double tap to enable or disable push notifications',
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Push Notifications',
              style: ModernTypography.bodyLarge,
            ),
            Text(
              'Receive app notifications',
              style: ModernTypography.labelMedium,
            ),
          ],
        ),
      ),
      SizedBox(width: spacing_md),
      ModernToggleButton(
        options: ['Off', 'On'],
        selectedIndex: settings.notificationsEnabled ? 1 : 0,
        onChanged: (index) {
          ref.read(settingsNotifierProvider.notifier)
              .updateNotificationsEnabled(index == 1);
        },
      ),
    ],
  ),
).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),

          if (settings.notificationsEnabled) ...[
            SizedBox(height: spacing_md),

            // Budget Alerts Toggle
            Semantics(
              label: 'Budget alerts toggle',
              hint: 'Double tap to enable or disable budget alerts',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Alerts',
                          style: ModernTypography.bodyLarge,
                        ),
                        Text(
                          'Notify when approaching budget limits',
                          style: ModernTypography.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing_md),
                  ModernToggleButton(
                    options: ['Off', 'On'],
                    selectedIndex: settings.budgetAlertsEnabled ? 1 : 0,
                    onChanged: (index) {
                      ref.read(settingsNotifierProvider.notifier)
                          .updateBudgetAlertsEnabled(index == 1);
                    },
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),

            if (settings.budgetAlertsEnabled) ...[
              SizedBox(height: spacing_md),
              // Budget Alert Threshold Slider (keeping as is for now)
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
                ),
              ).animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
                .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),
            ],

            SizedBox(height: spacing_md),

            // Bill Reminders Toggle
            Semantics(
              label: 'Bill reminders toggle',
              hint: 'Double tap to enable or disable bill reminders',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill Reminders',
                          style: ModernTypography.bodyLarge,
                        ),
                        Text(
                          'Remind about upcoming bills',
                          style: ModernTypography.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing_md),
                  ModernToggleButton(
                    options: ['Off', 'On'],
                    selectedIndex: settings.billRemindersEnabled ? 1 : 0,
                    onChanged: (index) {
                      ref.read(settingsNotifierProvider.notifier)
                          .updateBillRemindersEnabled(index == 1);
                    },
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 150.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 150.ms),

            if (settings.billRemindersEnabled) ...[
              SizedBox(height: spacing_md),
              // Bill Reminder Days Slider (keeping as is for now)
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
                ),
              ).animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 200.ms)
                .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 200.ms),
            ],

            SizedBox(height: spacing_md),

            // Income Reminders Toggle
            Semantics(
              label: 'Income reminders toggle',
              hint: 'Double tap to enable or disable income reminders',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income Reminders',
                          style: ModernTypography.bodyLarge,
                        ),
                        Text(
                          'Remind about expected income',
                          style: ModernTypography.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing_md),
                  ModernToggleButton(
                    options: ['Off', 'On'],
                    selectedIndex: settings.incomeRemindersEnabled ? 1 : 0,
                    onChanged: (index) {
                      ref.read(settingsNotifierProvider.notifier)
                          .updateIncomeRemindersEnabled(index == 1);
                    },
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 250.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 250.ms),

            if (settings.incomeRemindersEnabled) ...[
              SizedBox(height: spacing_md),
              // Income Reminder Days Slider (keeping as is for now)
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
                ),
              ).animate()
                .fadeIn(duration: ModernAnimations.normal, delay: 300.ms)
                .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 300.ms),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.security,
                  color: ModernColors.error,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Security & Privacy',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Biometric Authentication Toggle
          FutureBuilder<bool>(
            future: ref.read(settingsRepositoryProvider)
                .isBiometricAvailable()
                .then((result) => result.getOrDefault(false)),
            builder: (context, snapshot) {
              final isAvailable = snapshot.data ?? false;
              return Semantics(
                label: 'Biometric authentication toggle',
                hint: 'Double tap to enable or disable biometric authentication',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biometric Authentication',
                            style: ModernTypography.bodyLarge,
                          ),
                          Text(
                            isAvailable
                                ? 'Use fingerprint or face unlock'
                                : 'Not available on this device',
                            style: ModernTypography.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: spacing_md),
                    ModernToggleButton(
                      options: ['Off', 'On'],
                      selectedIndex: (settings.biometricEnabled && isAvailable) ? 1 : 0,
                      onChanged: isAvailable ? (index) {
                        ref.read(settingsNotifierProvider.notifier)
                            .updateSetting('biometricEnabled', index == 1);
                      } : (index) {},
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: ModernAnimations.normal)
                .slideX(begin: -0.1, duration: ModernAnimations.normal);
            },
          ),

          SizedBox(height: spacing_md),

          // Auto Backup Toggle
          Semantics(
            label: 'Auto backup toggle',
            hint: 'Double tap to enable or disable automatic backup',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Backup',
                        style: ModernTypography.bodyLarge,
                      ),
                      Text(
                        'Automatically backup data to cloud',
                        style: ModernTypography.labelMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing_md),
                ModernToggleButton(
                  options: ['Off', 'On'],
                  selectedIndex: settings.autoBackupEnabled ? 1 : 0,
                  onChanged: (index) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateSetting('autoBackupEnabled', index == 1);
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),

          SizedBox(height: spacing_md),

          // Two-Factor Authentication Button
Semantics(
  button: true,
  label: 'Two-factor authentication setup button',
  hint: 'Double tap to setup two-factor authentication',
  child: SizedBox(
    width: double.infinity, // Force full width
    child: ModernActionButton(
      text: settings.twoFactorEnabled
          ? 'Two-Factor Auth (${_getMethodDisplayName(settings.twoFactorMethod)})'  // Shortened text
          : 'Setup Two-Factor Auth',  // Shortened text
      icon: Icons.security,
      isPrimary: !settings.twoFactorEnabled,
      onPressed: () => _navigateToTwoFactorSetup(context),
    ),
  ),
).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.categoryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.visibility_off,
                  color: ModernColors.categoryPurple,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Privacy Mode',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Privacy Mode Toggle
          Semantics(
            label: 'Privacy mode toggle',
            hint: 'Double tap to enable or disable privacy mode',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Mode',
                        style: ModernTypography.bodyLarge,
                      ),
                      Text(
                        'Hide sensitive information like balances and account numbers',
                        style: ModernTypography.labelMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing_md),
                ModernToggleButton(
                  options: ['Off', 'On'],
                  selectedIndex: settings.privacyModeEnabled ? 1 : 0,
                  onChanged: (index) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateSetting('privacyModeEnabled', index == 1);
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),

          SizedBox(height: spacing_md),

          // Gesture Activation Toggle
          Semantics(
            label: 'Privacy mode gesture toggle',
            hint: 'Double tap to enable or disable three-finger double tap gesture',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gesture Activation',
                        style: ModernTypography.bodyLarge,
                      ),
                      Text(
                        'Activate privacy mode with three-finger double tap',
                        style: ModernTypography.labelMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing_md),
                ModernToggleButton(
                  options: ['Off', 'On'],
                  selectedIndex: settings.privacyModeGestureEnabled ? 1 : 0,
                  onChanged: (index) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateSetting('privacyModeGestureEnabled', index == 1);
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.storage,
                  color: ModernColors.info,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Data Management',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Export Data Button
          Semantics(
            button: true,
            label: 'Export data button',
            hint: 'Double tap to export your data as JSON file',
            child: ModernActionButton(
              text: 'Export Data',
              icon: Icons.download,
              isPrimary: false,
              onPressed: () => _showExportDialog(context),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),

          SizedBox(height: spacing_md),

          // Import Data Button
          Semantics(
            button: true,
            label: 'Import data button',
            hint: 'Double tap to import data from JSON file',
            child: ModernActionButton(
              text: 'Import Data',
              icon: Icons.upload,
              isPrimary: false,
              onPressed: () => _showImportDialog(context),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),

          SizedBox(height: spacing_md),

          // Clear All Data Button
          Semantics(
            button: true,
            label: 'Clear all data button',
            hint: 'Double tap to permanently delete all app data',
            child: ModernActionButton(
              text: 'Clear All Data',
              icon: Icons.delete_forever,
              isPrimary: false,
              onPressed: () => _showClearDataDialog(context),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.categoryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.language,
                  color: ModernColors.categoryBlue,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Language',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Language Selection
          Semantics(
            label: 'Language selection',
            hint: 'Double tap to change app language',
            child: ModernActionButton(
              text: 'Language: ${_getLanguageDisplayName(settings.languageCode)}',
              icon: Icons.language,
              isPrimary: false,
              onPressed: () => _showLanguageSelector(context, settings.languageCode),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.nightlight,
                  color: ModernColors.warning,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Quiet Hours',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Quiet Hours Toggle
          Semantics(
            label: 'Quiet hours toggle',
            hint: 'Double tap to enable or disable quiet hours',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Quiet Hours',
                        style: ModernTypography.bodyLarge,
                      ),
                      Text(
                        'Silence notifications during specified hours',
                        style: ModernTypography.labelMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing_md),
                ModernToggleButton(
                  options: ['Off', 'On'],
                  selectedIndex: settings.quietHoursEnabled ? 1 : 0,
                  onChanged: (index) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateSetting('quietHoursEnabled', index == 1);
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),

          if (settings.quietHoursEnabled) ...[
            SizedBox(height: spacing_md),

            // Start Time Picker
            Semantics(
              label: 'Quiet hours start time',
              hint: 'Double tap to set quiet hours start time',
              child: ModernActionButton(
                text: 'Start Time: ${settings.quietHoursStart}',
                icon: Icons.schedule,
                isPrimary: false,
                onPressed: () => _showTimePicker(context, true, settings.quietHoursStart),
              ),
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),

            SizedBox(height: spacing_md),

            // End Time Picker
            Semantics(
              label: 'Quiet hours end time',
              hint: 'Double tap to set quiet hours end time',
              child: ModernActionButton(
                text: 'End Time: ${settings.quietHoursEnd}',
                icon: Icons.schedule,
                isPrimary: false,
                onPressed: () => _showTimePicker(context, false, settings.quietHoursEnd),
              ),
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildExportOptionsSection(BuildContext context, AppSettings settings) {
    final scheduledExportService = ref.watch(scheduledExportServiceProvider);

    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.file_download,
                  color: ModernColors.accentGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Export Options',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Default Export Format
          Semantics(
            label: 'Default export format selection',
            hint: 'Double tap to change default export format',
            child: ModernActionButton(
              text: 'Default Format: ${_getExportFormatDisplayName(settings.defaultExportFormat)}',
              icon: Icons.file_present,
              isPrimary: false,
              onPressed: () => _showExportFormatSelector(context, settings.defaultExportFormat),
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),

          SizedBox(height: spacing_md),

          // Scheduled Export Toggle
          Semantics(
            label: 'Scheduled export toggle',
            hint: 'Double tap to enable or disable scheduled export',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Export',
                        style: ModernTypography.bodyLarge,
                      ),
                      Text(
                        'Automatically export data at set intervals',
                        style: ModernTypography.labelMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing_md),
                ModernToggleButton(
                  options: ['Off', 'On'],
                  selectedIndex: settings.scheduledExportEnabled ? 1 : 0,
                  onChanged: (index) async {
                    if (index == 1) {
                      // Enable scheduled export
                      await scheduledExportService.enableScheduledExport(
                        frequency: settings.scheduledExportFrequency,
                        format: settings.defaultExportFormat,
                      );
                    } else {
                      // Disable scheduled export
                      await scheduledExportService.disableScheduledExport();
                    }
                    // Refresh settings
                    ref.invalidate(settingsNotifierProvider);
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),

          if (settings.scheduledExportEnabled) ...[
            SizedBox(height: spacing_md),

            // Export Frequency
            Semantics(
              label: 'Export frequency selection',
              hint: 'Double tap to change scheduled export frequency',
              child: ModernActionButton(
                text: 'Frequency: ${_getFrequencyDisplayName(settings.scheduledExportFrequency)}',
                icon: Icons.repeat,
                isPrimary: false,
                onPressed: () => _showExportFrequencySelector(context, settings.scheduledExportFrequency),
              ),
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 100.ms),

            SizedBox(height: spacing_md),

            // Scheduled Export Status
            FutureBuilder<Map<String, dynamic>>(
              future: scheduledExportService.getScheduledExportStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: EdgeInsets.all(spacing_sm),
                    decoration: BoxDecoration(
                      color: ModernColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(radius_md),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(ModernColors.info),
                          ),
                        ),
                        SizedBox(width: spacing_sm),
                        Text(
                          'Checking status...',
                          style: ModernTypography.labelMedium.copyWith(
                            color: ModernColors.info,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final status = snapshot.data;
                if (status == null || !status['isEnabled']) {
                  return Container(
                    padding: EdgeInsets.all(spacing_sm),
                    decoration: BoxDecoration(
                      color: ModernColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(radius_md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: ModernColors.warning,
                        ),
                        SizedBox(width: spacing_sm),
                        Expanded(
                          child: Text(
                            'Scheduled export is enabled but status checking is not yet implemented.',
                            style: ModernTypography.labelMedium.copyWith(
                              color: ModernColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: EdgeInsets.all(spacing_sm),
                  decoration: BoxDecoration(
                    color: ModernColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(radius_md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: ModernColors.success,
                      ),
                      SizedBox(width: spacing_sm),
                      Expanded(
                        child: Text(
                          'Scheduled export is active',
                          style: ModernTypography.labelMedium.copyWith(
                            color: ModernColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 150.ms)
              .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 150.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsSection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.categoryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.settings_applications,
                  color: ModernColors.categoryPurple,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Advanced Settings',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Activity Logging Toggle
          Semantics(
            label: 'Activity logging toggle',
            hint: 'Double tap to enable or disable activity logging',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Logging',
                        style: ModernTypography.bodyLarge,
                      ),
                      Text(
                        'Track and log user activities for analytics and troubleshooting',
                        style: ModernTypography.labelMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing_md),
                ModernToggleButton(
                  options: ['Off', 'On'],
                  selectedIndex: settings.activityLoggingEnabled ? 1 : 0,
                  onChanged: (index) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateSetting('activityLoggingEnabled', index == 1);
                  },
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: -0.1, duration: ModernAnimations.normal),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.info,
                  color: ModernColors.textSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'About',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          FutureBuilder<String>(
            future: ref.read(settingsRepositoryProvider)
                .getAppVersion()
                .then((result) => result.getOrDefault('1.0.0')),
            builder: (context, snapshot) {
              final version = snapshot.data ?? '1.0.0';
              return _buildInfoRow('App Version', version).animate()
                .fadeIn(duration: ModernAnimations.normal)
                .slideX(begin: -0.1, duration: ModernAnimations.normal);
            },
          ),
          SizedBox(height: spacing_sm),
          _buildInfoRow('Build Number', '100').animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 50.ms)
            .slideX(begin: -0.1, duration: ModernAnimations.normal, delay: 50.ms),

          SizedBox(height: spacing_md),

          Row(
            children: [
              Expanded(
                child: ModernActionButton(
                  text: 'Terms',
                  isPrimary: false,
                  onPressed: () => context.go('/more/settings/terms'),
                ).animate()
                  .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
                  .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 100.ms),
              ),
              SizedBox(width: spacing_sm),
              Expanded(
                child: ModernActionButton(
                  text: 'Privacy Policy',
                  isPrimary: false,
                  onPressed: () => context.go('/more/settings/privacy'),
                ).animate()
                  .fadeIn(duration: ModernAnimations.normal, delay: 150.ms)
                  .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 150.ms),
              ),
            ],
          ),
        ],
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountThemesEditorSheet(
        currentThemes: currentThemes.cast<String, AccountTypeTheme>(),
      ),
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

  // Helper methods for new sections
  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      default:
        return 'English';
    }
  }

  void _showLanguageSelector(BuildContext context, String currentLanguage) {
    final localeService = ref.read(localeServiceProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        decoration: BoxDecoration(
          color: ColorTokens.surfacePrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: TypographyTokens.heading4,
            ),
            SizedBox(height: DesignTokens.spacing4),
            ...localeService.getSupportedLanguageCodes().map((code) => ListTile(
              title: Text(localeService.getLanguageDisplayName(code)),
              leading: Icon(
                currentLanguage == code ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: currentLanguage == code ? ColorTokens.teal500 : ColorTokens.textSecondary,
              ),
              onTap: () async {
                if (currentLanguage != code) {
                  // Update the language setting
                  await localeService.setLocale(code);
                  Navigator.pop(context);

                  // Show restart dialog
                  _showRestartDialog(context);
                } else {
                  Navigator.pop(context);
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, bool isStartTime, String currentTime) async {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: ColorTokens.surfacePrimary,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      final settingKey = isStartTime ? 'quietHoursStart' : 'quietHoursEnd';
      ref.read(settingsNotifierProvider.notifier).updateSetting(settingKey, formattedTime);
    }
  }

  String _getExportFormatDisplayName(String format) {
    switch (format) {
      case 'csv':
        return 'CSV';
      case 'json':
        return 'JSON';
      case 'pdf':
        return 'PDF';
      default:
        return 'CSV';
    }
  }

  void _showExportFormatSelector(BuildContext context, String currentFormat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        decoration: BoxDecoration(
          color: ColorTokens.surfacePrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Export Format',
              style: TypographyTokens.heading4,
            ),
            SizedBox(height: DesignTokens.spacing4),
            ...['csv', 'json', 'pdf'].map((format) => ListTile(
              title: Text(_getExportFormatDisplayName(format)),
              leading: Icon(
                currentFormat == format ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: currentFormat == format ? ColorTokens.teal500 : ColorTokens.textSecondary,
              ),
              onTap: () {
                ref.read(settingsNotifierProvider.notifier).updateSetting('defaultExportFormat', format);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      default:
        return 'Monthly';
    }
  }

  void _showExportFrequencySelector(BuildContext context, String currentFrequency) {
    final scheduledExportService = ref.read(scheduledExportServiceProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        decoration: BoxDecoration(
          color: ColorTokens.surfacePrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Export Frequency',
              style: TypographyTokens.heading4,
            ),
            SizedBox(height: DesignTokens.spacing4),
            ...['daily', 'weekly', 'monthly', 'quarterly'].map((frequency) => ListTile(
              title: Text(_getFrequencyDisplayName(frequency)),
              leading: Icon(
                currentFrequency == frequency ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: currentFrequency == frequency ? ColorTokens.teal500 : ColorTokens.textSecondary,
              ),
              onTap: () async {
                // Update the scheduled export with new frequency
                final currentSettings = ref.read(currentSettingsProvider);
                if (currentSettings != null && currentSettings.scheduledExportEnabled) {
                  await scheduledExportService.updateScheduledExport(
                    frequency: frequency,
                    format: currentSettings.defaultExportFormat,
                  );
                } else {
                  // Just update the setting
                  await ref.read(settingsNotifierProvider.notifier).updateSetting('scheduledExportFrequency', frequency);
                }
                Navigator.pop(context);
                // Refresh settings
                ref.invalidate(settingsNotifierProvider);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
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
                color: ColorTokens.warning500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                Icons.restart_alt,
                color: ColorTokens.warning500,
                size: DesignTokens.iconMd,
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Text(
              'Restart Required',
              style: TypographyTokens.heading5,
            ),
          ],
        ),
        content: Text(
          'The app needs to restart to apply the new language setting. Would you like to restart now?',
          style: TypographyTokens.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Restart the app by exiting and letting the system restart it
              // This is a simple approach - in production you might want more sophisticated restart logic
              // For now, we'll just show a message that the app will restart on next launch
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language changed. Please restart the app to see changes.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.teal500,
            ),
            child: Text(
              'Restart Now',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.teal500,
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

/// Editable profile card widget with state management
class EditableProfileCard extends StatefulWidget {
  final UserProfile? userProfile;
  final Function(String name, String email) onSave;

  const EditableProfileCard({
    super.key,
    required this.userProfile,
    required this.onSave,
  });

  @override
  State<EditableProfileCard> createState() => _EditableProfileCardState();
}

class _EditableProfileCardState extends State<EditableProfileCard> {
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile?.name ?? '');
    _emailController = TextEditingController(text: widget.userProfile?.email ?? '');
  }

  @override
  void didUpdateWidget(EditableProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile) {
      _nameController.text = widget.userProfile?.name ?? '';
      _emailController.text = widget.userProfile?.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nameController.text = widget.userProfile?.name ?? '';
      _emailController.text = widget.userProfile?.email ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // Basic validation
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(name, email);
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ModernColors.accentGreen, ModernColors.categoryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius_xl),
        boxShadow: [ModernShadows.medium],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Semantics(
                label: 'User avatar',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(radius_lg),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                    semanticLabel: 'User profile icon',
                  ),
                ).animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: ModernAnimations.normal,
                    delay: 200.ms,
                    curve: ModernCurves.bounceOut,
                  ),
              ),

              SizedBox(width: spacing_md),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userProfile?.name ?? 'No name set',
                      style: ModernTypography.titleLarge.copyWith(
                        color: ModernColors.lightText,
                      ),
                      semanticsLabel: 'User name: ${widget.userProfile?.name ?? 'No name set'}',
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 300.ms)
                      .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 300.ms),

                    const SizedBox(height: 4),
                    Text(
                      widget.userProfile?.email ?? 'No email set',
                      style: ModernTypography.bodyLarge.copyWith(
                        color: ModernColors.lightText.withValues(alpha: 0.9),
                      ),
                      semanticsLabel: 'User email: ${widget.userProfile?.email ?? 'No email set'}',
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 400.ms)
                      .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 400.ms),
                  ],
                ),
              ),

              // Edit Button
              if (!_isEditing)
                Semantics(
                  button: true,
                  label: 'Edit profile',
                  hint: 'Double tap to edit user profile information',
                  child: GestureDetector(
                    onTap: _startEditing,
                    child: Container(
                      padding: EdgeInsets.all(spacing_xs),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(radius_md),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                        semanticLabel: 'Edit profile icon',
                      ),
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: ModernAnimations.normal,
                        delay: 500.ms,
                        curve: ModernCurves.bounceOut,
                      ),
                  ),
                )
              else
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Cancel editing',
                      hint: 'Double tap to cancel profile editing',
                      child: GestureDetector(
                        onTap: _cancelEditing,
                        child: Container(
                          padding: EdgeInsets.all(spacing_xs),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(radius_md),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                            semanticLabel: 'Cancel edit icon',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: spacing_sm),
                    Semantics(
                      button: true,
                      label: 'Save profile',
                      hint: 'Double tap to save profile changes',
                      child: GestureDetector(
                        onTap: _saveProfile,
                        child: Container(
                          padding: EdgeInsets.all(spacing_xs),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(radius_md),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Colors.white,
                                  semanticLabel: 'Save profile icon',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          if (_isEditing) ...[
            SizedBox(height: spacing_lg),

            // Editable Profile Fields
            ModernTextField(
              controller: _nameController,
              label: 'Name',
              placeholder: 'Enter your name',
              prefixIcon: Icons.person,
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 600.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 600.ms),

            SizedBox(height: spacing_md),

            ModernTextField(
              controller: _emailController,
              label: 'Email',
              placeholder: 'Enter your email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 700.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 700.ms),

            SizedBox(height: spacing_lg),

            Row(
              children: [
                Expanded(
                  child: ModernActionButton(
                    text: 'Cancel',
                    icon: Icons.close,
                    isPrimary: false,
                    onPressed: _cancelEditing,
                  ),
                ),
                SizedBox(width: spacing_md),
                Expanded(
                  child: ModernActionButton(
                    text: 'Save',
                    icon: Icons.save,
                    isLoading: _isLoading,
                    onPressed: _saveProfile,
                  ),
                ),
              ],
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 800.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 800.ms),
          ],
        ],
      ),
    );
  }
}