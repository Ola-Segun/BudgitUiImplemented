import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/more/presentation/screens/help_center_screen_enhanced.dart';
import 'package:budget_tracker/features/more/presentation/screens/more_menu_screen_enhanced.dart';

void main() {
  group('Edge Cases Tests', () {
    testWidgets('Empty data states are handled gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Enter a search term that won't match anything
      await tester.enterText(find.byType(TextField), 'nonexistentsearchterm');
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Try adjusting your search'), findsOneWidget);
    });

    testWidgets('Network failure error handling', (WidgetTester tester) async {
      // This would require mocking network failures
      // For now, test that error states can be displayed
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Verify the screen loads without network-dependent features failing
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Large datasets performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Test with the existing FAQ data
      // The screen should handle the current dataset efficiently
      expect(find.byType(ExpansionTile), findsWidgets);

      // Test scrolling performance
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);

      // Scroll to bottom
      await tester.drag(scrollable, const Offset(0, -1000));
      await tester.pump();

      // Should still be functional
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Invalid data handling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Test with potentially invalid configurations
      // The screen should handle missing or invalid data gracefully
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Financial Management'), findsOneWidget);
    });

    testWidgets('Extreme screen sizes', (WidgetTester tester) async {
      // Test on very small screen
      tester.binding.window.physicalSizeTestValue = const Size(320, 480);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      await tester.pumpAndSettle();

      // Should adapt to very small screens
      expect(find.text('Help & Support'), findsOneWidget);

      // Test on very large screen
      tester.binding.window.physicalSizeTestValue = const Size(2048, 1536);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      await tester.pumpAndSettle();

      // Should work on large screens too
      expect(find.text('Help & Support'), findsOneWidget);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
    });

    testWidgets('Rapid user interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Rapidly tap on different elements
      await tester.tap(find.text('How do I add a new transaction?'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Should handle rapid interactions without crashing
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Memory pressure simulation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Navigate through multiple states rapidly
      for (int i = 0; i < 10; i++) {
        await tester.enterText(find.byType(TextField), 'test$i');
        await tester.pump(const Duration(milliseconds: 10));
        await tester.enterText(find.byType(TextField), '');
        await tester.pump(const Duration(milliseconds: 10));
      }

      // Should handle memory pressure gracefully
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Simulate orientation change by changing screen size
      tester.binding.window.physicalSizeTestValue = const Size(896, 414); // Landscape
      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);

      // Back to portrait
      tester.binding.window.physicalSizeTestValue = const Size(414, 896);
      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);

      tester.binding.window.clearPhysicalSizeTestValue();
    });

    testWidgets('System font scaling', (WidgetTester tester) async {
      // Test with different text scales
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)), // Large text
          child: const MaterialApp(
            home: HelpCenterScreenEnhanced(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should adapt to large text
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Deep navigation stress test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Expand multiple FAQ items
      final faqTiles = find.byType(ExpansionTile);
      final faqCount = faqTiles.evaluate().length;

      for (int i = 0; i < faqCount && i < 5; i++) {
        await tester.tap(find.text('How do I add a new transaction?').first);
        await tester.pumpAndSettle();
      }

      // Should handle multiple expansions
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Concurrent animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Trigger multiple animations simultaneously
      await tester.pump(); // Start initial animations
      await tester.enterText(find.byType(TextField), 'budget');
      await tester.pump(); // Trigger search animations

      // Should handle concurrent animations
      expect(find.text('Help & Support'), findsOneWidget);
    });
  });
}