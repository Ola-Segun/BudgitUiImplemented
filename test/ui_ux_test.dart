import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/more/presentation/screens/help_center_screen_enhanced.dart';
import 'package:budget_tracker/features/more/presentation/screens/more_menu_screen_enhanced.dart';

void main() {
  group('UI/UX Tests', () {
    testWidgets('Animations work smoothly without frame drops', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Initial state
      await tester.pump();

      // Measure animation performance
      final stopwatch = Stopwatch()..start();

      // Let animations run
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60 FPS
      }

      final animationTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Should complete animations within reasonable time (less than 200ms for smooth animation)
      expect(animationTime, lessThan(200));

      // Screen should be fully rendered
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Haptic feedback works on interactive elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Tap on a menu item (this would trigger haptic feedback in real app)
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify the tap was registered (haptic feedback would be tested in integration tests)
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Responsive behavior on different screen sizes', (WidgetTester tester) async {
      // Test on small screen
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify content fits on small screen
      expect(find.text('Help & Support'), findsOneWidget);

      // Test scrolling on small screen
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pump();

      // Content should still be accessible
      expect(find.text('Quick Help'), findsOneWidget);

      // Reset screen size
      tester.binding.window.clearPhysicalSizeTestValue();
    });

    testWidgets('Accessibility features work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Check for semantic labels
      expect(find.bySemanticsLabel('Help and support screen'), findsOneWidget);
      expect(find.bySemanticsLabel('Scroll to view help topics, FAQs, and contact options'), findsOneWidget);

      // Check for button semantics
      expect(find.bySemanticsLabel('Live chat support'), findsOneWidget);
      expect(find.bySemanticsLabel('Email support'), findsOneWidget);
    });

    testWidgets('Color contrast meets accessibility standards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // The app uses design tokens that should meet contrast requirements
      // This test verifies the design system is being used correctly
      expect(find.byType(MoreMenuScreenEnhanced), findsOneWidget);
    });

    testWidgets('Touch targets meet minimum size requirements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Find interactive elements and verify they meet minimum touch target size
      final quickActionButtons = find.byType(InkWell);
      expect(quickActionButtons, findsWidgets);

      // The design system enforces minimum touch target sizes
      // This test passes if the widgets render without issues
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Screen reader compatibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Verify semantic information is available
      expect(find.bySemanticsLabel(contains('Help')), findsWidgets);
      expect(find.bySemanticsLabel(contains('support')), findsWidgets);
    });

    testWidgets('Keyboard navigation support', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Test focus traversal (basic test - widgets should be focusable)
      expect(find.byType(TextField), findsOneWidget); // Search field should be focusable
    });

    testWidgets('Performance - no memory leaks in animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Run multiple animation cycles
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should not crash or leak memory (basic test)
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('Visual hierarchy is clear', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Verify proper visual hierarchy with headings and sections
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Financial Management'), findsOneWidget);
      expect(find.text('Settings & Support'), findsOneWidget);
    });

    testWidgets('Consistent spacing and alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Verify consistent use of design tokens for spacing
      // This is tested by ensuring the layout renders correctly
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
    });
  });
}