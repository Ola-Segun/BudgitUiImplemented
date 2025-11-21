import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/core/design_system/modern/modern_rate_display.dart';

void main() {
  group('ModernRateDisplay', () {
    testWidgets('displays rate with default percentage symbol', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateDisplay(rate: 5.25, label: 'Interest Rate'),
          ),
        ),
      );

      expect(find.text('5.25%'), findsOneWidget);
      expect(find.text('Interest Rate'), findsOneWidget);
    });

    testWidgets('displays rate with custom symbol', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateDisplay(rate: 3.5, rateSymbol: 'APR', label: 'APR Rate'),
          ),
        ),
      );

      expect(find.text('3.50APR'), findsOneWidget);
      expect(find.text('APR Rate'), findsOneWidget);
    });

    testWidgets('respects decimal places parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateDisplay(rate: 4.123, decimalPlaces: 1, label: 'Rate'),
          ),
        ),
      );

      expect(find.text('4.1%'), findsOneWidget);
      expect(find.text('Rate'), findsOneWidget);
    });

    testWidgets('displays icon and label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateDisplay(rate: 6.0, label: 'Interest Rate'),
          ),
        ),
      );

      expect(find.byIcon(Icons.percent), findsOneWidget);
      expect(find.text('Interest Rate'), findsOneWidget);
      expect(find.text('6.00%'), findsOneWidget);
    });

    testWidgets('has correct semantic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateDisplay(rate: 7.5, label: 'Savings Rate'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ModernRateDisplay));
      expect(semantics.label, contains('Savings Rate rate display'));
      expect(semantics.value, contains('7.50%'));
    });

    testWidgets('applies correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateDisplay(rate: 8.0, label: 'Rate'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ModernRateDisplay),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFF5F5F5));
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(container.constraints?.maxHeight, 48);
    });

    testWidgets('displays rate correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateDisplay(rate: 5.0, label: 'Test Rate'),
          ),
        ),
      );

      expect(find.text('5.00%'), findsOneWidget);
      expect(find.text('Test Rate'), findsOneWidget);
    });
  });
}