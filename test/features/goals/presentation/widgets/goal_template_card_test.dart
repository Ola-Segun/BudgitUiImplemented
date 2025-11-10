import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/goals/domain/entities/goal_template.dart';
import 'package:budget_tracker/features/goals/presentation/widgets/goal_template_card.dart';

void main() {
  late GoalTemplate testTemplate;

  setUp(() {
    testTemplate = GoalTemplates.all.first;
  });

  group('GoalTemplateCard', () {
    testWidgets('should display template name and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: testTemplate,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(); // Wait for animations to complete

      expect(find.text(testTemplate.name), findsOneWidget);
      expect(find.text(testTemplate.description), findsOneWidget);
    });

    testWidgets('should display template details (amount, months, contribution)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: testTemplate,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('\$${testTemplate.suggestedAmount.toStringAsFixed(0)}'), findsOneWidget);
      expect(find.text('${testTemplate.suggestedMonths} months'), findsOneWidget);
      expect(find.text('\$${(testTemplate.monthlyContribution).toStringAsFixed(0)}/month'), findsOneWidget);
    });

    testWidgets('should show selected state when isSelected is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: testTemplate,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selected'), findsOneWidget);
      // Check for selection indicator
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: testTemplate,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GoalTemplateCard), warnIfMissed: false);
      expect(tapped, isTrue);
    });

    testWidgets('should display tip preview when showPreview is true and tips exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: testTemplate,
              onTap: () {},
              showPreview: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      expect(find.text(testTemplate.tips.first), findsOneWidget);
    });

    testWidgets('should not display tip preview when showPreview is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: testTemplate,
              onTap: () {},
              showPreview: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
    });

    testWidgets('should handle template with custom color', (WidgetTester tester) async {
      final coloredTemplate = testTemplate.customize(newColor: 0xFFFF0000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: coloredTemplate,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test renders without error
      expect(find.text(coloredTemplate.name), findsOneWidget);
    });

    testWidgets('should handle template with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalTemplateCard(
              template: testTemplate,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Icon should be present (specific icon depends on template.icon value)
      expect(find.byType(Icon), findsWidgets);
    });
  });
}