import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/settings.dart' as settings_entity;
import '../providers/settings_providers.dart';
import '../widgets/settings_section.dart';

/// Settings screen with comprehensive app configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        data: (settingsState) => _buildSettingsContent(context, ref, settingsState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(settingsNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    dynamic settingsState,
  ) {
    return ListView(
      padding: AppTheme.screenPaddingAll,
      children: [
        // Appearance Section
        SettingsSection(
          title: 'Appearance',
          icon: Icons.palette,
          children: [
            _buildThemeSelector(context, ref, settingsState.settings),
            _buildCurrencySelector(context, ref, settingsState.settings),
            _buildDateFormatSelector(context, ref, settingsState.settings),
          ],
        ),

        const SizedBox(height: 24),

        // Notifications Section
        SettingsSection(
          title: 'Notifications',
          icon: Icons.notifications,
          children: [
            _buildNotificationToggle(context, ref, settingsState.settings),
            _buildBudgetAlertsToggle(context, ref, settingsState.settings),
            _buildBillRemindersToggle(context, ref, settingsState.settings),
            _buildIncomeRemindersToggle(context, ref, settingsState.settings),
            _buildBudgetAlertThreshold(context, ref, settingsState.settings),
            _buildBillReminderDays(context, ref, settingsState.settings),
            _buildIncomeReminderDays(context, ref, settingsState.settings),
          ],
        ),

        const SizedBox(height: 24),

        // Data Management Section
        SettingsSection(
          title: 'Data Management',
          icon: Icons.storage,
          children: [
            _buildExportDataButton(context, ref),
            _buildImportDataButton(context, ref),
            _buildClearDataButton(context, ref),
          ],
        ),

        const SizedBox(height: 24),

        // Privacy & Security Section
        SettingsSection(
          title: 'Privacy & Security',
          icon: Icons.security,
          children: [
            _buildBiometricToggle(context, ref, settingsState.settings),
            _buildAutoBackupToggle(context, ref, settingsState.settings),
          ],
        ),

        const SizedBox(height: 24),

        // Account Section
        SettingsSection(
          title: 'Account',
          icon: Icons.account_circle,
          children: [
            _buildAccountManagementButton(context),
          ],
        ),

        const SizedBox(height: 24),

        // About Section
        SettingsSection(
          title: 'About',
          icon: Icons.info,
          children: [
            _buildAppVersion(context, ref),
            _buildAppInfo(context),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, dynamic settings) {
    return ListTile(
      title: const Text('Theme'),
      subtitle: Text(_getThemeDisplayName(settings.themeMode)),
      leading: const Icon(Icons.dark_mode),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeSelector(context, ref, settings.themeMode),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, WidgetRef ref, dynamic settings) {
    return ListTile(
      title: const Text('Currency'),
      subtitle: Text(settings.currencyCode ?? 'USD'),
      leading: const Icon(Icons.attach_money),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCurrencySelector(context, ref, settings.currencyCode ?? 'USD'),
    );
  }

  Widget _buildDateFormatSelector(BuildContext context, WidgetRef ref, dynamic settings) {
    return ListTile(
      title: const Text('Date Format'),
      subtitle: Text(settings.dateFormat),
      leading: const Icon(Icons.calendar_today),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDateFormatSelector(context, ref, settings.dateFormat),
    );
  }

  Widget _buildNotificationToggle(BuildContext context, WidgetRef ref, dynamic settings) {
    return SwitchListTile(
      title: const Text('Push Notifications'),
      subtitle: const Text('Receive notifications from the app'),
      value: settings.notificationsEnabled,
      onChanged: (value) {
        ref.read(settingsNotifierProvider.notifier).updateNotificationsEnabled(value);
      },
    );
  }

  Widget _buildBudgetAlertsToggle(BuildContext context, WidgetRef ref, dynamic settings) {
    return SwitchListTile(
      title: const Text('Budget Alerts'),
      subtitle: const Text('Get notified when approaching budget limits'),
      value: settings.budgetAlertsEnabled,
      onChanged: settings.notificationsEnabled
          ? (value) {
              ref.read(settingsNotifierProvider.notifier).updateBudgetAlertsEnabled(value);
            }
          : null,
    );
  }

  Widget _buildBillRemindersToggle(BuildContext context, WidgetRef ref, dynamic settings) {
    return SwitchListTile(
      title: const Text('Bill Reminders'),
      subtitle: const Text('Get reminded about upcoming bill payments'),
      value: settings.billRemindersEnabled,
      onChanged: settings.notificationsEnabled
          ? (value) {
              ref.read(settingsNotifierProvider.notifier).updateBillRemindersEnabled(value);
            }
          : null,
    );
  }

  Widget _buildBudgetAlertThreshold(BuildContext context, WidgetRef ref, dynamic settings) {
    return ListTile(
      title: const Text('Budget Alert Threshold'),
      subtitle: Text('${settings.budgetAlertThreshold}% of budget'),
      leading: const Icon(Icons.warning),
      enabled: settings.notificationsEnabled && settings.budgetAlertsEnabled,
      trailing: const Icon(Icons.chevron_right),
      onTap: (settings.notificationsEnabled && settings.budgetAlertsEnabled)
          ? () => _showBudgetThresholdSelector(context, ref, settings.budgetAlertThreshold)
          : null,
    );
  }

  Widget _buildBillReminderDays(BuildContext context, WidgetRef ref, dynamic settings) {
    return ListTile(
      title: const Text('Bill Reminder Days'),
      subtitle: Text('${settings.billReminderDays} days before due date'),
      leading: const Icon(Icons.schedule),
      enabled: settings.notificationsEnabled && settings.billRemindersEnabled,
      trailing: const Icon(Icons.chevron_right),
      onTap: (settings.notificationsEnabled && settings.billRemindersEnabled)
          ? () => _showBillReminderDaysSelector(context, ref, settings.billReminderDays)
          : null,
    );
  }

  Widget _buildIncomeRemindersToggle(BuildContext context, WidgetRef ref, dynamic settings) {
    return SwitchListTile(
      title: const Text('Income Reminders'),
      subtitle: const Text('Get reminded about expected income receipts'),
      value: settings.incomeRemindersEnabled,
      onChanged: settings.notificationsEnabled
          ? (value) {
              ref.read(settingsNotifierProvider.notifier).updateIncomeRemindersEnabled(value);
            }
          : null,
    );
  }

  Widget _buildIncomeReminderDays(BuildContext context, WidgetRef ref, dynamic settings) {
    return ListTile(
      title: const Text('Income Reminder Days'),
      subtitle: Text('${settings.incomeReminderDays} days before expected date'),
      leading: const Icon(Icons.trending_up),
      enabled: settings.notificationsEnabled && settings.incomeRemindersEnabled,
      trailing: const Icon(Icons.chevron_right),
      onTap: (settings.notificationsEnabled && settings.incomeRemindersEnabled)
          ? () => _showIncomeReminderDaysSelector(context, ref, settings.incomeReminderDays)
          : null,
    );
  }

  Widget _buildExportDataButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('Export Data'),
      subtitle: const Text('Download your data as JSON'),
      leading: const Icon(Icons.download),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showExportDataDialog(context, ref),
    );
  }

  Widget _buildImportDataButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('Import Data'),
      subtitle: const Text('Import data from JSON file'),
      leading: const Icon(Icons.upload),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showImportDataDialog(context, ref),
    );
  }

  Widget _buildClearDataButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('Clear All Data'),
      subtitle: const Text('Permanently delete all app data'),
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showClearDataDialog(context, ref),
    );
  }

  Widget _buildBiometricToggle(BuildContext context, WidgetRef ref, dynamic settings) {
    return FutureBuilder<bool>(
      future: ref.read(settingsRepositoryProvider).isBiometricAvailable().then(
            (result) => result.getOrDefault(false),
          ),
      builder: (context, snapshot) {
        final isAvailable = snapshot.data ?? false;
        return SwitchListTile(
          title: const Text('Biometric Authentication'),
          subtitle: Text(isAvailable
              ? 'Use fingerprint or face unlock'
              : 'Biometric authentication not available'),
          value: settings.biometricEnabled && isAvailable,
          onChanged: isAvailable
              ? (value) {
                  ref.read(settingsNotifierProvider.notifier).updateSetting('biometricEnabled', value);
                }
              : null,
        );
      },
    );
  }

  Widget _buildAutoBackupToggle(BuildContext context, WidgetRef ref, dynamic settings) {
    return SwitchListTile(
      title: const Text('Auto Backup'),
      subtitle: const Text('Automatically backup data to cloud'),
      value: settings.autoBackupEnabled,
      onChanged: (value) {
        ref.read(settingsNotifierProvider.notifier).updateSetting('autoBackupEnabled', value);
      },
    );
  }

  Widget _buildAccountManagementButton(BuildContext context) {
    return ListTile(
      title: const Text('Account Management'),
      subtitle: const Text('Manage your accounts and balances'),
      leading: const Icon(Icons.account_balance),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to accounts screen
        context.go('/more/accounts');
      },
    );
  }

  Widget _buildAppVersion(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref.read(settingsRepositoryProvider).getAppVersion().then(
            (result) => result.getOrDefault('1.0.0'),
          ),
      builder: (context, snapshot) {
        final version = snapshot.data ?? '1.0.0';
        return ListTile(
          title: const Text('App Version'),
          subtitle: Text(version),
          leading: const Icon(Icons.info),
        );
      },
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return const ListTile(
      title: Text('About Budget Tracker'),
      subtitle: Text('A comprehensive personal finance management app'),
      leading: Icon(Icons.business),
    );
  }

  // Helper methods for dialogs and selectors
  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: ThemeMode.values.map((theme) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).updateThemeMode(theme);
              Navigator.pop(context);
            },
            child: Text(_getThemeDisplayName(theme)),
          );
        }).toList(),
      ),
    );
  }

  void _showCurrencySelector(BuildContext context, WidgetRef ref, String currentCurrency) {
    final currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'NGN'];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose Currency'),
        children: currencies.map((currency) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).updateCurrencyCode(currency);
              Navigator.pop(context);
            },
            child: Text(currency),
          );
        }).toList(),
      ),
    );
  }

  void _showDateFormatSelector(BuildContext context, WidgetRef ref, String currentFormat) {
    final formats = ['MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd', 'MMM dd, yyyy'];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose Date Format'),
        children: formats.map((format) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).updateSetting('dateFormat', format);
              Navigator.pop(context);
            },
            child: Text(format),
          );
        }).toList(),
      ),
    );
  }

  void _showBudgetThresholdSelector(BuildContext context, WidgetRef ref, int currentThreshold) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Budget Alert Threshold'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Get notified when you reach $currentThreshold% of your budget'),
            Slider(
              value: currentThreshold.toDouble(),
              min: 50,
              max: 100,
              divisions: 10,
              label: '$currentThreshold%',
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier).updateBudgetAlertThreshold(value.round());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showBillReminderDaysSelector(BuildContext context, WidgetRef ref, int currentDays) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bill Reminder Days'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Get reminded $currentDays days before bills are due'),
            Slider(
              value: currentDays.toDouble(),
              min: 1,
              max: 14,
              divisions: 13,
              label: '$currentDays days',
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier).updateBillReminderDays(value.round());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showIncomeReminderDaysSelector(BuildContext context, WidgetRef ref, int currentDays) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Income Reminder Days'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Get reminded $currentDays days before income is expected'),
            Slider(
              value: currentDays.toDouble(),
              min: 0,
              max: 7,
              divisions: 7,
              label: '$currentDays days',
              onChanged: (value) {
                ref.read(settingsNotifierProvider.notifier).updateIncomeReminderDays(value.round());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('This will export your settings and data as a JSON file. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref.read(settingsRepositoryProvider).exportData(settings_entity.DataExportType.json);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.getOrDefault('Export failed'))),
                );
              }
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showImportDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('This feature is not yet implemented. It will allow you to import data from a JSON file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your transactions, accounts, budgets, and settings. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref.read(settingsRepositoryProvider).clearAllData();
              if (result.isSuccess && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}