import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:budget_tracker/features/onboarding/presentation/onboarding_flow.dart';

void main() {
  setUp(() async {
    // Create a temporary directory for testing
    final tempDir = await Directory.systemTemp.createTemp('budget_tracker_integration_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
  });

  group('OnboardingFlow Integration Test', () {
    testWidgets('should complete full onboarding flow without errors', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingFlow(),
          ),
        ),
      );

      // Wait for initial build
      await tester.pumpAndSettle();

      // Verify welcome screen is displayed
      expect(find.text('Welcome to Budget Tracker'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Fill in welcome form
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe'); // Name field
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com'); // Email field

      // Tap continue button
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should be on budget type selection screen
      expect(find.text('Choose Your Budget Style'), findsOneWidget);

      // Select a budget type (Zero-Based)
      await tester.tap(find.text('Zero-Based'));
      await tester.pumpAndSettle();

      // Should be on income entry screen
      print('All text widgets: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}');
      expect(find.text('Tell us about your income'), findsOneWidget);

      // Add income source
      await tester.enterText(find.byType(TextFormField).at(0), 'Salary'); // Income name
      await tester.enterText(find.byType(TextFormField).at(1), '5000'); // Amount
      // Frequency dropdown should default to monthly

      // Add the income source
      await tester.tap(find.text('Add Income Source'));
      await tester.pumpAndSettle();

      // Continue to budget setup
      await tester.tap(find.text('Continue to Budget Setup'));
      await tester.pumpAndSettle();

      // Should be on budget setup screen
      expect(find.text('Set Up Your Budget'), findsOneWidget);

      // Continue to bank connection (budget categories should be auto-populated)
      await tester.tap(find.text('Continue to Bank Connection'));
      await tester.pumpAndSettle();

      // Should be on bank connection screen
      expect(find.text('Connect Your Bank (Optional)'), findsOneWidget);

      // Select manual entry option
      await tester.tap(find.text('Add Transactions Manually'));
      await tester.pumpAndSettle();

      // Complete setup
      await tester.tap(find.text('Complete Setup'));
      await tester.pumpAndSettle();

      // Should be on completion screen
      expect(find.text('Congratulations'), findsOneWidget);
      expect(find.text('Your budget is ready to go'), findsOneWidget);

      // Complete onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify no errors occurred during the flow
      // The flow should complete without throwing any exceptions
    });

    testWidgets('should handle text input validation properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingFlow(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to continue without filling required fields
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should still be on welcome screen (validation failed)
      expect(find.text('Welcome to Budget Tracker'), findsOneWidget);

      // Fill only name, leave email empty
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should still be on welcome screen
      expect(find.text('Welcome to Budget Tracker'), findsOneWidget);

      // Fill valid email
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should proceed to next screen
      expect(find.text('Choose Your Budget Style'), findsOneWidget);
    });

    testWidgets('should handle navigation flow smoothly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingFlow(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Complete welcome screen
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify smooth transition to budget type screen
      expect(find.text('Choose Your Budget Style'), findsOneWidget);

      // Select budget type
      await tester.tap(find.text('Zero Based').first);
      await tester.pumpAndSettle();

      // Verify smooth transition to income screen
      expect(find.text('Tell us about your income'), findsOneWidget);

      // Add income and continue
      await tester.enterText(find.byType(TextFormField).at(0), 'Salary');
      await tester.enterText(find.byType(TextFormField).at(1), '5000');
      await tester.tap(find.text('Add Income Source'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to Budget Setup'));
      await tester.pumpAndSettle();

      // Verify smooth transition to budget setup screen
      expect(find.text('Set Up Your Budget'), findsOneWidget);

      // Continue to bank connection
      await tester.tap(find.text('Continue to Bank Connection'));
      await tester.pumpAndSettle();

      // Verify smooth transition to bank connection screen
      expect(find.text('Connect Your Bank (Optional)'), findsOneWidget);

      // Complete setup
      await tester.tap(find.text('Add Transactions Manually'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete Setup'));
      await tester.pumpAndSettle();

      // Verify smooth transition to completion screen
      expect(find.text('Congratulations'), findsOneWidget);
    });

    testWidgets('should not show Overlay or ScaffoldMessenger errors', (tester) async {
      // Capture any errors that occur during the test
      final errorLogs = <String>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        errorLogs.add(details.exceptionAsString());
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingFlow(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Complete the full flow
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zero Based').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Salary');
      await tester.enterText(find.byType(TextFormField).at(1), '5000');
      await tester.tap(find.text('Add Income Source'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to Budget Setup'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Bank Connection'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Transactions Manually'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete Setup'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Restore original error handler
      FlutterError.onError = originalOnError;

      // Check for Overlay or ScaffoldMessenger related errors
      final overlayErrors = errorLogs.where((error) =>
        error.contains('Overlay') ||
        error.contains('ScaffoldMessenger') ||
        error.contains('deactivated') ||
        error.contains('widget') && error.contains('lifecycle')
      ).toList();

      expect(overlayErrors, isEmpty, reason: 'Found Overlay/ScaffoldMessenger lifecycle errors: $overlayErrors');
    });
  });
}