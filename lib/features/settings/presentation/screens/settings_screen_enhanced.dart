import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                        'John Doe',
                        style: ModernTypography.titleLarge.copyWith(
                          color: ModernColors.lightText,
                        ),
                        semanticsLabel: 'User name: John Doe',
                      ).animate()
                        .fadeIn(duration: ModernAnimations.normal, delay: 300.ms)
                        .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 300.ms),

                      const SizedBox(height: 4),
                      Text(
                        'john.doe@example.com',
                        style: ModernTypography.bodyLarge.copyWith(
                          color: ModernColors.lightText.withValues(alpha: 0.9),
                        ),
                        semanticsLabel: 'User email: john.doe@example.com',
                      ).animate()
                        .fadeIn(duration: ModernAnimations.normal, delay: 400.ms)
                        .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 400.ms),
                    ],
                  ),
                ),

                // Edit Button
                Semantics(
                  button: true,
                  label: 'Edit profile',
                  hint: 'Double tap to edit user profile information',
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
              ],
            ),

            SizedBox(height: spacing_lg),

            // Editable Profile Fields
            ModernTextField(
              label: 'Name',
              placeholder: 'Enter your name',
              prefixIcon: Icons.person,
              initialValue: 'John Doe',
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 600.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 600.ms),

            SizedBox(height: spacing_md),

            ModernTextField(
              label: 'Email',
              placeholder: 'Enter your email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              initialValue: 'john.doe@example.com',
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 700.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 700.ms),

            SizedBox(height: spacing_md),

            ModernTextField(
              label: 'Phone',
              placeholder: 'Enter your phone number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              initialValue: '+1 (555) 123-4567',
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 800.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 800.ms),

            SizedBox(height: spacing_lg),

            ModernActionButton(
              text: 'Save Profile',
              icon: Icons.save,
              onPressed: () {
                // TODO: Implement profile save functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved successfully!')),
                );
              },
            ).animate()
              .fadeIn(duration: ModernAnimations.normal, delay: 900.ms)
              .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 900.ms),
          ],
        ),
      ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
            child: ModernActionButton(
              text: settings.twoFactorEnabled
                  ? 'Two-Factor Authentication (${_getMethodDisplayName(settings.twoFactorMethod)})'
                  : 'Setup Two-Factor Authentication',
              icon: Icons.security,
              isPrimary: !settings.twoFactorEnabled,
              onPressed: () => _navigateToTwoFactorSetup(context),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                  text: 'Terms of Service',
                  isPrimary: false,
                  onPressed: () {},
                ).animate()
                  .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
                  .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 100.ms),
              ),
              SizedBox(width: spacing_sm),
              Expanded(
                child: ModernActionButton(
                  text: 'Privacy Policy',
                  isPrimary: false,
                  onPressed: () {},
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