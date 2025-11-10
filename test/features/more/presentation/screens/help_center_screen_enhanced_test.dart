import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/more/presentation/screens/help_center_screen_enhanced.dart';

void main() {
  group('HelpCenterScreenEnhanced', () {
    testWidgets('displays help center screen with all sections', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Quick Help'), findsOneWidget);
      expect(find.text('Popular Topics'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Still Need Help?'), findsOneWidget);
    });

    testWidgets('search functionality filters FAQs', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'budget');
      await tester.pump();

      // Assert - Should show filtered results
      expect(find.text('How do I create a budget?'), findsOneWidget);
      expect(find.text('How do I add a new transaction?'), findsNothing);
    });

    testWidgets('FAQ expansion tiles work correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Initially, answer should not be visible
      expect(find.text('Tap the "+" button on the home screen'), findsNothing);

      // Tap on FAQ to expand
      await tester.tap(find.text('How do I add a new transaction?'));
      await tester.pumpAndSettle();

      // Now answer should be visible
      expect(find.text('Tap the "+" button on the home screen'), findsOneWidget);
    });

    testWidgets('topic chips filter FAQs by category', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Tap on "Budgets" topic chip
      await tester.tap(find.text('Budgets'));
      await tester.pump();

      // Assert - Should show budget-related FAQs
      expect(find.text('How do I create a budget?'), findsOneWidget);
      expect(find.text('How do I add a new transaction?'), findsNothing);
    });

    testWidgets('quick action buttons are present and accessible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.text('Live Chat'), findsOneWidget);
      expect(find.text('Email Us'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
      expect(find.text('Report Bug'), findsOneWidget);

      // Check accessibility labels
      expect(find.bySemanticsLabel('Live chat support'), findsOneWidget);
      expect(find.bySemanticsLabel('Email support'), findsOneWidget);
      expect(find.bySemanticsLabel('Send feedback'), findsOneWidget);
      expect(find.bySemanticsLabel('Report bug'), findsOneWidget);
    });

    testWidgets('contact options are displayed correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.text('Email Support'), findsOneWidget);
      expect(find.text('support@budgettracker.com'), findsOneWidget);
      expect(find.text('Phone Support'), findsOneWidget);
      expect(find.text('Community Forum'), findsOneWidget);
      expect(find.text('Visit Help Center'), findsOneWidget);
    });

    testWidgets('empty search results show appropriate message', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Enter search text that won't match anything
      await tester.enterText(find.byType(TextField), 'nonexistenttopic');
      await tester.pump();

      // Assert
      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Try adjusting your search'), findsOneWidget);
    });

    testWidgets('clear search button appears when text is entered', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Text should be cleared and button should disappear
      expect(find.text('test'), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('FAQ helpful feedback works', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Expand FAQ
      await tester.tap(find.text('How do I add a new transaction?'));
      await tester.pumpAndSettle();

      // Tap helpful button
      await tester.tap(find.byIcon(Icons.thumb_up_outlined).first);
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('Thanks for your feedback!'), findsOneWidget);
    });

    testWidgets('animations work properly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Initial state
      await tester.pump();

      // After animation completes
      await tester.pumpAndSettle();

      // Assert - Screen should be fully rendered
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('accessibility features are properly implemented', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreenEnhanced(),
        ),
      );

      // Assert
      expect(find.bySemanticsLabel('Help and support screen'), findsOneWidget);
      expect(find.bySemanticsLabel('Scroll to view help topics, FAQs, and contact options'), findsOneWidget);
      expect(find.bySemanticsLabel('Quick help actions'), findsOneWidget);
      expect(find.bySemanticsLabel('Popular help topics'), findsOneWidget);
      expect(find.bySemanticsLabel('Frequently asked questions'), findsOneWidget);
      expect(find.bySemanticsLabel('Contact support options'), findsOneWidget);
    });
  });
}