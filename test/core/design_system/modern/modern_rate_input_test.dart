import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/core/design_system/modern/modern_rate_input.dart';

void main() {
  group('ModernRateInput', () {
    testWidgets('displays label and icon correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateInput(label: 'Interest Rate'),
          ),
        ),
      );

      expect(find.byIcon(Icons.percent), findsOneWidget);
      expect(find.text('Interest Rate'), findsOneWidget);
    });

    testWidgets('accepts input and calls onChanged', (WidgetTester tester) async {
      double? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateInput(
              label: 'Rate',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '15.5');
      expect(changedValue, 15.5);
    });

    testWidgets('validates input range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateInput(
              label: 'Rate',
              minValue: 0.0,
              maxValue: 100.0,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '150');
      await tester.pump();

      expect(find.text('Percentage cannot exceed 100.0%'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateInput(
              label: 'Rate',
              minValue: 0.0,
              maxValue: 50.0,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '75');
      await tester.pump();

      expect(find.text('Percentage cannot exceed 50.0%'), findsOneWidget);
    });
  });
}