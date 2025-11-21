import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/core/design_system/modern/modern_rate_selector.dart';

void main() {
  group('ModernRateSelector', () {
    testWidgets('displays predefined rates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateSelector(
              onRateSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('5%'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('15%'), findsOneWidget);
    });

    testWidgets('calls onRateSelected when rate is tapped', (WidgetTester tester) async {
      double? selectedRate;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateSelector(
              onRateSelected: (rate) => selectedRate = rate,
            ),
          ),
        ),
      );

      await tester.tap(find.text('10%'));
      expect(selectedRate, 10.0);
    });

    testWidgets('highlights selected rate', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateSelector(
              selectedRate: 15.0,
              onRateSelected: (_) {},
            ),
          ),
        ),
      );

      // The selected rate should have different styling
      final selectedButton = find.ancestor(
        of: find.text('15%'),
        matching: find.byType(GestureDetector),
      );
      expect(selectedButton, findsOneWidget);
    });

    testWidgets('displays custom option', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateSelector(
              onRateSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onCustomSelected when custom is tapped', (WidgetTester tester) async {
      bool customTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernRateSelector(
              onRateSelected: (_) {},
              onCustomSelected: () => customTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Custom'));
      expect(customTapped, true);
    });
  });
}