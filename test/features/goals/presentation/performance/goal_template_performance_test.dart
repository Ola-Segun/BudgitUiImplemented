import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/goals/domain/entities/goal_template.dart';
import 'package:budget_tracker/features/goals/presentation/widgets/goal_template_card.dart';
import 'package:budget_tracker/features/goals/presentation/screens/goal_template_selection_screen.dart';

void main() {
  group('Goal Template Performance Tests', () {
    testWidgets('should render template cards within performance budget', (WidgetTester tester) async {
      // Create a large number of templates to test performance
      final templates = List.generate(20, (index) {
        final baseTemplate = GoalTemplates.all.first;
        return baseTemplate.customize(
          newName: 'Template ${index + 1}',
          newAmount: baseTemplate.suggestedAmount + index * 100,
        );
      });

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return GoalTemplateCard(
                  template: templates[index],
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      );

      // Wait for initial render
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Performance assertion: should render within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Template cards should render within 2 seconds for good UX');

      // Verify some cards are rendered (ListView only renders visible items)
      expect(find.byType(GoalTemplateCard), findsWidgets);
    });

    testWidgets('should handle template selection performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      // Wait for loading
      await tester.pump(const Duration(milliseconds: 600));

      final stopwatch = Stopwatch()..start();

      // Select a template
      final templateCards = find.byType(GoalTemplateCard);
      expect(templateCards, findsWidgets);

      await tester.tap(templateCards.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Performance assertion: selection should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Template selection should complete within 500ms');
    });

    testWidgets('should filter templates efficiently', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final stopwatch = Stopwatch()..start();

      // Apply filter
      await tester.tap(find.textContaining('Popular'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Performance assertion: filtering should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(300),
          reason: 'Template filtering should complete within 300ms');
    });

    testWidgets('should handle large template lists without performance degradation', (WidgetTester tester) async {
      // Test with a very large number of templates
      final largeTemplateList = List.generate(50, (index) {
        final baseTemplate = GoalTemplates.all[index % GoalTemplates.all.length];
        return baseTemplate.customize(
          newName: 'Large Template ${index + 1}',
        );
      });

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: largeTemplateList.length,
              itemBuilder: (context, index) {
                return GoalTemplateCard(
                  template: largeTemplateList[index],
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Performance assertion: should handle large lists within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'Large template lists should render within 3 seconds');

      // Verify some items are rendered (ListView only renders visible items)
      expect(find.byType(GoalTemplateCard), findsWidgets);
    });

    testWidgets('should maintain smooth scrolling performance', (WidgetTester tester) async {
      final templates = List.generate(30, (index) {
        final baseTemplate = GoalTemplates.all[index % GoalTemplates.all.length];
        return baseTemplate.customize(
          newName: 'Scroll Template ${index + 1}',
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return GoalTemplateCard(
                  template: templates[index],
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test scrolling performance by scrolling to the end
      final stopwatch = Stopwatch()..start();

      await tester.scrollUntilVisible(
        find.text('Scroll Template 30'),
        500.0,
        scrollable: find.byType(Scrollable),
      );

      stopwatch.stop();

      // Performance assertion: scrolling should be smooth
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Scrolling to end should complete within 1 second');
    });
  });
}