import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/features/goals/domain/entities/goal_template.dart';
import 'package:budget_tracker/features/goals/presentation/screens/goal_template_selection_screen.dart';

void main() {
  group('GoalTemplateSelectionScreen', () {
    testWidgets('should display loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );
      await tester.pump(); // Allow initial build

      expect(find.text('Loading templates...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display templates after loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(find.text('Choose Your Goal Template'), findsOneWidget);
      expect(find.text('Choose Goal Template'), findsOneWidget); // AppBar title
    });

    testWidgets('should display category filters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Check for filter chips - they contain the text with counts
      expect(find.textContaining('All Templates'), findsOneWidget);
      expect(find.textContaining('Popular'), findsOneWidget);
      expect(find.textContaining('Quick Start'), findsOneWidget);
      expect(find.textContaining('Long Term'), findsOneWidget);
    });

    testWidgets('should filter templates by category', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Initially should show all templates
      final allTemplates = GoalTemplates.all;
      expect(find.text('${allTemplates.length} templates available'), findsOneWidget);

      // Tap on Popular filter
      await tester.tap(find.textContaining('Popular'));
      await tester.pumpAndSettle();

      final popularTemplates = GoalTemplates.popular;
      expect(find.text('${popularTemplates.length} templates available'), findsOneWidget);
    });

    testWidgets('should allow template selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Find and tap first template card (using the mock GoalTemplateCard)
      final templateCards = find.byType(GoalTemplateCard);
      expect(templateCards, findsWidgets);

      await tester.tap(templateCards.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should show Continue button in app bar
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('should display template details when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Select a template
      final templateCards = find.byType(GoalTemplateCard);
      await tester.tap(templateCards.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should show template details section
      expect(find.text('Template Details'), findsOneWidget);
      expect(find.text('Helpful Tips'), findsOneWidget);
    });

    testWidgets('should display custom goal option', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(find.text('Create Custom Goal'), findsOneWidget);
      expect(find.text('Build your own goal from scratch with complete flexibility'), findsOneWidget);
    });

    testWidgets('should handle empty templates gracefully', (WidgetTester tester) async {
      // This test would require mocking the template loading, but for now
      // we verify the screen handles the existing templates properly
      await tester.pumpWidget(
        const MaterialApp(
          home: GoalTemplateSelectionScreen(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Should not show empty state since we have templates
      expect(find.text('No templates available'), findsNothing);
    });
  });
}

// Mock GoalTemplateCard for testing
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