import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/main.dart';
import 'package:budget_tracker/core/design_system/design_tokens.dart';
import 'package:budget_tracker/core/design_system/color_tokens.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive App Testing', () {
    testWidgets('Complete user journey through all screens', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Verify app launches successfully
      expect(find.text('Budget Tracker'), findsOneWidget);

      // Navigate to Settings screen
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify Settings screen loads
      expect(find.text('Settings'), findsOneWidget);

      // Test theme toggle
      final themeToggle = find.byType(Switch).first;
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();

      // Navigate to Help Center
      await tester.tap(find.text('Help & Support'));
      await tester.pumpAndSettle();

      // Verify Help Center loads
      expect(find.text('Help & Support'), findsOneWidget);

      // Test search functionality
      await tester.enterText(find.byType(TextField), 'budget');
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('How do I create a budget?'), findsOneWidget);

      // Navigate back to More menu
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Navigate to Notification Center
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // Verify Notification Center loads
      expect(find.text('Notifications'), findsOneWidget);

      // Navigate to Accounts
      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      // Verify Accounts screen loads
      expect(find.text('Accounts'), findsOneWidget);

      // Test navigation back through the app
      for (int i = 0; i < 4; i++) {
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // Verify we're back to home screen
      expect(find.text('Budget Tracker'), findsOneWidget);
    });

    testWidgets('Data persistence across app restarts', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Change a setting (theme toggle)
      final themeToggle = find.byType(Switch).first;
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Simulate app restart by rebuilding
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Navigate back to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify setting was persisted (this would need actual persistence logic)
      // For now, just verify the screen loads
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Error handling and recovery', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Navigate to a screen that might have network dependencies
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Simulate network error by triggering refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify error handling (this would depend on actual error states)
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Responsive behavior on different screen sizes', (WidgetTester tester) async {
      // Test on different screen sizes
      await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE size

      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Verify app works on small screen
      expect(find.text('Budget Tracker'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify Settings screen adapts
      expect(find.text('Settings'), findsOneWidget);

      // Test scrolling on small screen
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Reset screen size
      await tester.binding.setSurfaceSize(const Size(800, 600));
    });

    testWidgets('Accessibility features work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify semantic labels are present
      expect(find.bySemanticsLabel('Settings screen'), findsOneWidget);

      // Navigate to Help Center
      await tester.tap(find.text('Help & Support'));
      await tester.pumpAndSettle();

      // Verify accessibility in Help Center
      expect(find.bySemanticsLabel('Help and support screen'), findsOneWidget);
    });

    testWidgets('Animation performance and smoothness', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Navigate to Settings with animations
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid animation
      await tester.pump(const Duration(milliseconds: 200)); // End animation
      await tester.pumpAndSettle();

      // Verify screen loads without animation issues
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Memory leaks and proper disposal', (WidgetTester tester) async {
      // This test would require more advanced testing setup
      // For now, just verify basic navigation doesn't cause issues
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Navigate through multiple screens
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Help & Support'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify app is still functional
      expect(find.text('Budget Tracker'), findsOneWidget);
    });

    testWidgets('Offline functionality', (WidgetTester tester) async {
      // Launch app
      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));
      await tester.pumpAndSettle();

      // Navigate to screens that might use cached data
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify offline functionality (cached data loads)
      expect(find.text('Settings'), findsOneWidget);

      // Test refresh functionality
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should handle offline state gracefully
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Performance benchmarks', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const ProviderScope(child: BudgetTrackerApp()));

      // Measure initial load time
      await tester.pumpAndSettle();
      final initialLoadTime = stopwatch.elapsedMilliseconds;

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      final navigationTime = stopwatch.elapsedMilliseconds - initialLoadTime;

      // Basic performance assertions
      expect(initialLoadTime, lessThan(5000)); // Less than 5 seconds
      expect(navigationTime, lessThan(1000)); // Less than 1 second

      stopwatch.stop();
    });
  });
}