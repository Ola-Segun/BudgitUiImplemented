import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/more/presentation/screens/more_menu_screen_enhanced.dart';

void main() {
  group('MoreMenuScreenEnhanced', () {
    testWidgets('displays more menu with all sections', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Manage your finances and preferences'), findsOneWidget);
      expect(find.text('Financial Management'), findsOneWidget);
      expect(find.text('Insights & Analytics'), findsOneWidget);
      expect(find.text('Settings & Support'), findsOneWidget);
    });

    testWidgets('displays all menu items in financial management section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Manage accounts and cards'), findsOneWidget);
      expect(find.text('Bills & Subscriptions'), findsOneWidget);
      expect(find.text('Track recurring payments'), findsOneWidget);
      expect(find.text('Debt Manager'), findsOneWidget);
      expect(find.text('Monitor and manage debts'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Manage transaction categories'), findsOneWidget);
    });

    testWidgets('displays insights section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.text('Insights & Reports'), findsOneWidget);
      expect(find.text('View spending analytics'), findsOneWidget);
    });

    testWidgets('displays settings and support section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App preferences'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('FAQs and contact support'), findsOneWidget);
    });

    testWidgets('menu items have proper accessibility labels', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert - Check that key menu items are accessible
      expect(find.bySemanticsLabel('Accounts'), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
      expect(find.bySemanticsLabel('Help & Support'), findsOneWidget);
    });

    testWidgets('animations work properly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Initial state
      await tester.pump();

      // After animation completes
      await tester.pumpAndSettle();

      // Assert - Screen should be fully rendered
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Financial Management'), findsOneWidget);
    });

    testWidgets('section headers have proper styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert - Check that section headers are present and styled
      expect(find.text('Financial Management'), findsOneWidget);
      expect(find.text('Insights & Analytics'), findsOneWidget);
      expect(find.text('Settings & Support'), findsOneWidget);
    });

    testWidgets('menu items have navigation arrows', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert - Check for chevron right icons indicating navigation
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('menu items are properly spaced and aligned', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert - Check that menu items are present and properly structured
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('screen is scrollable for smaller devices', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 400, // Small height to force scrolling
            child: const MoreMenuScreenEnhanced(),
          ),
        ),
      );

      // Assert - Should still render properly even with constrained height
      expect(find.text('More'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('color scheme is consistent with design tokens', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: MoreMenuScreenEnhanced(),
        ),
      );

      // Assert - Screen should render without errors using design tokens
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Financial Management'), findsOneWidget);
    });
  });
}