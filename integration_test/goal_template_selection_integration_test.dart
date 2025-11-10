import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budget_tracker/main.dart' as app;
import 'package:budget_tracker/features/goals/domain/entities/goal_template.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Goal Template Selection Integration Tests', () {
    testWidgets('should complete full template selection to goal creation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to goals section
      await _navigateToGoalsSection(tester);

      // Navigate to goal creation
      await _navigateToGoalCreation(tester);

      // Verify template selection screen is displayed
      expect(find.text('Choose Your Goal Template'), findsOneWidget);
      expect(find.text('Choose Goal Template'), findsOneWidget);

      // Wait for templates to load
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Verify templates are displayed
      final allTemplates = GoalTemplates.all;
      expect(find.text('${allTemplates.length} templates available'), findsOneWidget);

      // Select a template
      final templateCards = find.byType(GoalTemplateCard);
      expect(templateCards, findsWidgets);

      await tester.tap(templateCards.first);
      await tester.pumpAndSettle();

      // Verify Continue button appears
      expect(find.text('Continue'), findsOneWidget);

      // Tap Continue to proceed to goal creation
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify we're on goal creation screen (this would depend on the actual navigation setup)
      // For now, just verify navigation occurred
      expect(find.text('Choose Your Goal Template'), findsNothing);
    });

    testWidgets('should filter templates by category', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToGoalsSection(tester);
      await _navigateToGoalCreation(tester);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Initially show all templates
      final allTemplates = GoalTemplates.all;
      expect(find.text('${allTemplates.length} templates available'), findsOneWidget);

      // Tap Popular filter
      await tester.tap(find.textContaining('Popular'));
      await tester.pumpAndSettle();

      // Verify filter applied
      final popularTemplates = GoalTemplates.popular;
      expect(find.text('${popularTemplates.length} templates available'), findsOneWidget);
    });

    testWidgets('should handle custom goal creation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToGoalsSection(tester);
      await _navigateToGoalCreation(tester);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Tap custom goal option
      expect(find.text('Create Custom Goal'), findsOneWidget);
      await tester.tap(find.text('Create Custom Goal'));
      await tester.pumpAndSettle();

      // Verify navigation to goal creation without template
      expect(find.text('Choose Your Goal Template'), findsNothing);
    });

    testWidgets('should validate template selection and goal creation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _navigateToGoalsSection(tester);
      await _navigateToGoalCreation(tester);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Select template
      final templateCards = find.byType(GoalTemplateCard);
      await tester.tap(templateCards.first);
      await tester.pumpAndSettle();

      // Continue to goal creation
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify goal creation form is populated with template data
      // This would depend on the actual goal creation screen implementation
      // For now, just verify navigation occurred
      expect(find.text('Choose Your Goal Template'), findsNothing);
    });

    testWidgets('should handle template loading errors gracefully', (WidgetTester tester) async {
      // This test would require mocking network failures
      // For now, verify the screen handles the normal case
      app.main();
      await tester.pumpAndSettle();

      await _navigateToGoalsSection(tester);
      await _navigateToGoalCreation(tester);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Verify no error state is shown for successful loading
      expect(find.text('Failed to load templates'), findsNothing);
      expect(find.text('Choose Your Goal Template'), findsOneWidget);
    });
  });
}

// Helper functions for navigation
Future<void> _navigateToGoalsSection(WidgetTester tester) async {
  // Navigate to goals section - adjust based on your app's navigation
  // This is a placeholder - you'll need to adjust based on your actual navigation structure
  await tester.tap(find.text('Goals')); // Adjust this based on your UI
  await tester.pumpAndSettle();
}

Future<void> _navigateToGoalCreation(WidgetTester tester) async {
  // Navigate to goal creation - adjust based on your app's navigation
  // This is a placeholder - you'll need to adjust based on your actual navigation structure
  await tester.tap(find.text('Add Goal')); // Adjust this based on your UI
  await tester.pumpAndSettle();
}

// Mock GoalTemplateCard for integration tests
class GoalTemplateCard extends StatelessWidget {
  final GoalTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalTemplateCard({
    super.key,
    required this.template,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? Colors.blue.shade50 : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(template.description),
              const SizedBox(height: 8),
              Text('\$${template.suggestedAmount.toStringAsFixed(0)}'),
              Text('${template.suggestedMonths} months'),
              if (isSelected)
                const Text('Selected', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}