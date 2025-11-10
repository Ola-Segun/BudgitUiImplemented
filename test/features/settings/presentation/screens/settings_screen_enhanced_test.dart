import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:budget_tracker/features/settings/presentation/screens/settings_screen_enhanced.dart';
import 'package:budget_tracker/features/settings/presentation/providers/settings_providers.dart';
import 'package:budget_tracker/features/settings/presentation/notifiers/settings_notifier.dart';
import 'package:budget_tracker/features/settings/presentation/states/settings_state.dart';
import 'package:budget_tracker/features/settings/domain/entities/settings.dart';
import 'package:budget_tracker/core/design_system/design_tokens.dart';
import 'package:budget_tracker/core/design_system/color_tokens.dart';
import 'package:budget_tracker/features/settings/domain/entities/settings.dart' as settings;
@GenerateMocks([SettingsNotifier])
import 'settings_screen_enhanced_test.mocks.dart';

void main() {
  late MockSettingsNotifier mockSettingsNotifier;

  setUp(() {
    mockSettingsNotifier = MockSettingsNotifier();
  });

  group('SettingsScreenEnhanced', () {
    testWidgets('displays loading state initially', (WidgetTester tester) async {
      // Arrange
      when(mockSettingsNotifier.state).thenReturn(
        const AsyncValue.loading(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays error state when loading fails', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load settings';
      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.error(errorMessage, StackTrace.current),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays settings content when loaded successfully', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
      expect(find.text('Data Management'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('profile card displays user information', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('theme selection tile displays current theme', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.dark,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('currency selection tile displays current currency', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.system,
        currencyCode: 'EUR',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
    });

    testWidgets('notifications section shows all toggles when enabled', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: true,
        incomeReminderDays: 2,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(SettingsState(
          settings: mockSettings,
          isLoading: false,
          error: null,
        )),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith((ref) => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Budget Alerts'), findsOneWidget);
      expect(find.text('Budget Alert Threshold'), findsOneWidget);
      expect(find.text('Bill Reminders'), findsOneWidget);
      expect(find.text('Bill Reminder Days'), findsOneWidget);
      expect(find.text('Income Reminders'), findsOneWidget);
      expect(find.text('Income Reminder Days'), findsOneWidget);
    });

    testWidgets('notifications section hides detailed options when notifications disabled', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: false,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: true,
        incomeReminderDays: 2,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(SettingsState(
          settings: mockSettings,
          isLoading: false,
          error: null,
        )),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Budget Alerts'), findsNothing);
      expect(find.text('Budget Alert Threshold'), findsNothing);
      expect(find.text('Bill Reminders'), findsNothing);
      expect(find.text('Bill Reminder Days'), findsNothing);
      expect(find.text('Income Reminders'), findsNothing);
      expect(find.text('Income Reminder Days'), findsNothing);
    });

    testWidgets('data management section shows all action buttons', (WidgetTester tester) async {
      // Arrange
      final mockSettings = settings.AppSettings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
        languageCode: 'en',
        isFirstTime: false,
        appVersion: '1.0.0',
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Import Data'), findsOneWidget);
      expect(find.text('Clear All Data'), findsOneWidget);
    });

    testWidgets('reset to defaults dialog shows on app bar button tap', (WidgetTester tester) async {
      // Arrange
      final mockSettings = settings.AppSettings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
        languageCode: 'en',
        isFirstTime: false,
        appVersion: '1.0.0',
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the reset button
      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reset Settings'), findsOneWidget);
      expect(find.text('Reset all settings to default values? This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('refresh indicator works on pull to refresh', (WidgetTester tester) async {
      // Arrange
      final mockSettings = settings.AppSettings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
        languageCode: 'en',
        isFirstTime: false,
        appVersion: '1.0.0',
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
      await tester.pump();

      // Assert
      verify(mockSettingsNotifier.loadSettings()).called(1);
    });

    testWidgets('accessibility features are properly implemented', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.bySemanticsLabel('Settings screen'), findsOneWidget);
      expect(find.bySemanticsLabel('Scroll to view and modify app settings'), findsOneWidget);
      expect(find.bySemanticsLabel('User profile section'), findsOneWidget);
      expect(find.bySemanticsLabel('Appearance settings section'), findsOneWidget);
      expect(find.bySemanticsLabel('Notification settings section'), findsOneWidget);
      expect(find.bySemanticsLabel('Security and privacy settings section'), findsOneWidget);
      expect(find.bySemanticsLabel('Data management section'), findsOneWidget);
      expect(find.bySemanticsLabel('About section'), findsOneWidget);
    });

    testWidgets('animations work properly', (WidgetTester tester) async {
      // Arrange
      final mockSettings = Settings(
        themeMode: ThemeMode.system,
        currencyCode: 'USD',
        dateFormat: 'MM/dd/yyyy',
        notificationsEnabled: true,
        budgetAlertsEnabled: true,
        budgetAlertThreshold: 80,
        billRemindersEnabled: true,
        billReminderDays: 3,
        incomeRemindersEnabled: false,
        incomeReminderDays: 1,
        biometricEnabled: false,
        autoBackupEnabled: true,
      );

      when(mockSettingsNotifier.state).thenReturn(
        AsyncValue.data(mockSettings),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(() => mockSettingsNotifier),
          ],
          child: const MaterialApp(
            home: SettingsScreenEnhanced(),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // After animation completes
      await tester.pumpAndSettle();

      // Assert - Screen should be fully rendered with animations completed
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });
  });
}