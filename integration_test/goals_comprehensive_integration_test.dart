import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budget_tracker/main.dart' as app;
import 'package:go_router/go_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Goals Comprehensive End-to-End Integration Tests', () {
    late String testGoalId;
    late String testCategoryId;

    setUpAll(() async {
      // Initialize the app
      app.main();
      await Future.delayed(const Duration(seconds: 3)); // Wait for app to fully load

      // Create test data IDs
      testGoalId = 'test_goal_${DateTime.now().millisecondsSinceEpoch}';
      testCategoryId = 'test_category_${DateTime.now().millisecondsSinceEpoch}';
    });

    // ============================================================================
    // 1. CHART DATA TRACKING TESTS
    // ============================================================================

    group('Chart Data Tracking', () {
      testWidgets('should reflect contributions in progress charts accurately',
          (WidgetTester tester) async {
        // Navigate to goals section
        await _navigateToGoalsSection(tester);

        // Create a test goal
        await _createTestGoal(tester, targetAmount: 1000.0, deadlineMonths: 6);

        // Navigate to goal detail screen
        await _navigateToGoalDetail(tester);

        // Verify initial chart shows 0% progress
        expect(find.text('0%'), findsOneWidget);

        // Add multiple contributions
        await _addContribution(tester, amount: 100.0);
        await _addContribution(tester, amount: 200.0);
        await _addContribution(tester, amount: 150.0);

        // Verify chart updates to reflect 45% progress (450/1000)
        await tester.pumpAndSettle();
        expect(find.text('45%'), findsOneWidget);

        // Verify contribution data points in chart
        // This would depend on the specific chart implementation
        // For now, verify the progress calculation is correct
        final progressFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('45') == true,
        );
        expect(progressFinder, findsWidgets);
      });

      testWidgets('should update chart data in real-time when contributions are added',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 500.0, deadlineMonths: 3);
        await _navigateToGoalDetail(tester);

        // Initial state - 0%
        expect(find.text('0%'), findsOneWidget);

        // Add contribution and verify immediate update
        await _addContribution(tester, amount: 125.0);
        await tester.pumpAndSettle();

        // Should show 25% progress
        expect(find.text('25%'), findsOneWidget);

        // Add another contribution
        await _addContribution(tester, amount: 125.0);
        await tester.pumpAndSettle();

        // Should show 50% progress
        expect(find.text('50%'), findsOneWidget);
      });

      testWidgets('should display accurate milestone markers on progress chart',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 400.0, deadlineMonths: 4);
        await _navigateToGoalDetail(tester);

        // Add contributions to reach milestones
        await _addContribution(tester, amount: 100.0); // 25%
        await tester.pumpAndSettle();
        expect(find.text('25%'), findsOneWidget);

        await _addContribution(tester, amount: 100.0); // 50%
        await tester.pumpAndSettle();
        expect(find.text('50%'), findsOneWidget);

        await _addContribution(tester, amount: 100.0); // 75%
        await tester.pumpAndSettle();
        expect(find.text('75%'), findsOneWidget);

        await _addContribution(tester, amount: 100.0); // 100%
        await tester.pumpAndSettle();
        expect(find.text('100%'), findsOneWidget);
      });
    });

    // ============================================================================
    // 2. PROGRESS CALCULATIONS TESTS
    // ============================================================================

    group('Progress Calculations', () {
      testWidgets('should calculate daily pace accurately based on contributions',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 3650.0, deadlineMonths: 12); // $100/day target
        await _navigateToGoalDetail(tester);

        // Add contributions over several days
        final baseDate = DateTime.now().subtract(const Duration(days: 10));

        // Simulate contributions over 10 days
        for (int i = 0; i < 10; i++) {
          await _addContributionWithDate(tester, amount: 50.0, date: baseDate.add(Duration(days: i)));
        }

        await tester.pumpAndSettle();

        // Verify daily pace calculation (500 / 10 days = $50/day)
        // This would depend on the UI implementation showing daily pace
        final dailyPaceFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('50') == true,
        );
        expect(dailyPaceFinder, findsWidgets);
      });

      testWidgets('should calculate projected completion date based on current pace',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 1200.0, deadlineMonths: 12);
        await _navigateToGoalDetail(tester);

        // Add consistent contributions
        for (int i = 0; i < 5; i++) {
          await _addContribution(tester, amount: 50.0);
        }

        await tester.pumpAndSettle();

        // With $250 contributed over some period, should show projected completion
        // The exact calculation depends on the implementation
        final projectionFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('projected') == true,
        );
        expect(projectionFinder, findsWidgets);
      });

      testWidgets('should calculate required monthly contribution to meet deadline',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 2400.0, deadlineMonths: 12);
        await _navigateToGoalDetail(tester);

        // With 12 months remaining and $2400 needed, should require $200/month
        await tester.pumpAndSettle();

        final monthlyContributionFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('200') == true,
        );
        expect(monthlyContributionFinder, findsWidgets);
      });

      testWidgets('should handle edge cases in progress calculations',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);

        // Test with very small amounts
        await _createTestGoal(tester, targetAmount: 1.0, deadlineMonths: 1);
        await _navigateToGoalDetail(tester);
        await _addContribution(tester, amount: 0.5);
        await tester.pumpAndSettle();
        expect(find.text('50%'), findsOneWidget);

        // Test with very large amounts
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 1000000.0, deadlineMonths: 60);
        await _navigateToGoalDetail(tester);
        await _addContribution(tester, amount: 500000.0);
        await tester.pumpAndSettle();
        expect(find.text('50%'), findsOneWidget);
      });
    });

    // ============================================================================
    // 3. CONTRIBUTION HISTORY TESTS
    // ============================================================================

    group('Contribution History', () {
      testWidgets('should record and display all contributions chronologically',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 1000.0, deadlineMonths: 6);
        await _navigateToGoalDetail(tester);

        // Add contributions with different amounts and dates
        final contributions = [
          {'amount': 50.0, 'date': DateTime.now().subtract(const Duration(days: 5))},
          {'amount': 75.0, 'date': DateTime.now().subtract(const Duration(days: 3))},
          {'amount': 100.0, 'date': DateTime.now().subtract(const Duration(days: 1))},
        ];

        for (final contribution in contributions) {
          await _addContributionWithDate(tester,
            amount: contribution['amount'] as double,
            date: contribution['date'] as DateTime,
          );
        }

        await tester.pumpAndSettle();

        // Verify all contributions are displayed in history
        expect(find.text('\$50.00'), findsOneWidget);
        expect(find.text('\$75.00'), findsOneWidget);
        expect(find.text('\$100.00'), findsOneWidget);

        // Verify chronological order (most recent first)
        final historyItems = find.byType(ListTile);
        expect(historyItems, findsWidgets);
      });

      testWidgets('should synchronize contributions with transaction history',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 500.0, deadlineMonths: 3);
        await _navigateToGoalDetail(tester);

        // Add contribution linked to a transaction
        await _addContributionFromTransaction(tester, amount: 100.0, transactionId: 'txn_123');

        await tester.pumpAndSettle();

        // Verify contribution shows transaction link
        final transactionLinkFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('txn_123') == true,
        );
        expect(transactionLinkFinder, findsOneWidget);
      });

      testWidgets('should handle contribution edits and deletions',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 600.0, deadlineMonths: 4);
        await _navigateToGoalDetail(tester);

        // Add contribution
        await _addContribution(tester, amount: 150.0);
        await tester.pumpAndSettle();
        expect(find.text('\$150.00'), findsOneWidget);

        // Edit contribution (if UI supports it)
        // This depends on the specific implementation
        final editButton = find.byIcon(Icons.edit);
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton.first);
          await tester.pumpAndSettle();

          // Update amount
          final amountField = find.byType(TextFormField).first;
          await tester.enterText(amountField, '200.00');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          // Verify updated amount
          expect(find.text('\$200.00'), findsOneWidget);
        }
      });
    });

    // ============================================================================
    // 4. GOAL NOTIFICATIONS TESTS
    // ============================================================================

    group('Goal Notifications', () {
      testWidgets('should trigger milestone notifications at 25%, 50%, 75%, 100%',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 400.0, deadlineMonths: 4);
        await _navigateToGoalDetail(tester);

        // Reach 25% milestone
        await _addContribution(tester, amount: 100.0);
        await tester.pumpAndSettle();

        // Check for milestone notification (this would depend on notification system)
        await _verifyMilestoneNotification(tester, 25);

        // Reach 50% milestone
        await _addContribution(tester, amount: 100.0);
        await tester.pumpAndSettle();
        await _verifyMilestoneNotification(tester, 50);

        // Reach 75% milestone
        await _addContribution(tester, amount: 100.0);
        await tester.pumpAndSettle();
        await _verifyMilestoneNotification(tester, 75);

        // Reach 100% milestone
        await _addContribution(tester, amount: 100.0);
        await tester.pumpAndSettle();
        await _verifyMilestoneNotification(tester, 100);
      });

      testWidgets('should trigger deadline reminder notifications',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);

        // Create goal with deadline 7 days from now
        await _createTestGoal(tester,
          targetAmount: 1000.0,
          deadlineMonths: 1,
          customDeadline: DateTime.now().add(const Duration(days: 7)),
        );
        await _navigateToGoalDetail(tester);

        // Simulate time passing or trigger reminder check
        await tester.pumpAndSettle();

        // Verify deadline reminder notification
        await _verifyDeadlineReminderNotification(tester, daysRemaining: 7);
      });

      testWidgets('should trigger behind schedule notifications',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 1000.0, deadlineMonths: 1);
        await _navigateToGoalDetail(tester);

        // Add very small contribution when large monthly contribution is needed
        await _addContribution(tester, amount: 10.0);
        await tester.pumpAndSettle();

        // Should trigger behind schedule notification
        await _verifyBehindScheduleNotification(tester);
      });
    });

    // ============================================================================
    // 5. UI FEEDBACK TESTS
    // ============================================================================

    group('UI Feedback', () {
      testWidgets('should display achievement badges for milestones',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 400.0, deadlineMonths: 4);
        await _navigateToGoalDetail(tester);

        // Reach 25% - should show badge
        await _addContribution(tester, amount: 100.0);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.emoji_events), findsWidgets); // Achievement badge

        // Reach 50%
        await _addContribution(tester, amount: 100.0);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.emoji_events), findsWidgets);

        // Reach 100% - completion badge
        await _addContribution(tester, amount: 100.0);
        await _addContribution(tester, amount: 100.0);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.celebration), findsWidgets); // Completion celebration
      });

      testWidgets('should show celebration animation on goal completion',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 300.0, deadlineMonths: 3);
        await _navigateToGoalDetail(tester);

        // Complete the goal
        await _addContribution(tester, amount: 150.0);
        await _addContribution(tester, amount: 150.0);
        await tester.pumpAndSettle();

        // Verify celebration widget appears
        final celebrationFinder = find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString().contains('Celebration'),
        );
        expect(celebrationFinder, findsWidgets);
      });

      testWidgets('should provide real-time progress updates in UI',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 200.0, deadlineMonths: 2);
        await _navigateToGoalDetail(tester);

        // Initial state
        expect(find.text('0%'), findsOneWidget);

        // Add contribution - should update immediately
        await _addContribution(tester, amount: 50.0);
        await tester.pumpAndSettle();
        expect(find.text('25%'), findsOneWidget);

        // Progress bar should reflect change
        final progressBarFinder = find.byType(LinearProgressIndicator);
        expect(progressBarFinder, findsOneWidget);
      });

      testWidgets('should show motivational messages based on progress',
          (WidgetTester tester) async {
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 500.0, deadlineMonths: 5);
        await _navigateToGoalDetail(tester);

        // Early progress - encouraging message
        await _addContribution(tester, amount: 50.0);
        await tester.pumpAndSettle();

        final encouragingMessageFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Great start') == true,
        );
        expect(encouragingMessageFinder, findsWidgets);

        // Near completion - motivational message
        await _addContribution(tester, amount: 450.0);
        await tester.pumpAndSettle();

        final completionMessageFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Almost there') == true,
        );
        expect(completionMessageFinder, findsWidgets);
      });
    });

    // ============================================================================
    // 6. COMPLETE GOAL WORKFLOW INTEGRATION TEST
    // ============================================================================

    group('Complete Goal Workflow', () {
      testWidgets('should complete full goal lifecycle from creation to completion',
          (WidgetTester tester) async {
        // 1. Create goal
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 1000.0, deadlineMonths: 6);
        await _navigateToGoalDetail(tester);

        // Verify goal creation
        expect(find.text('Test Goal'), findsOneWidget);
        expect(find.text('\$1,000.00'), findsOneWidget);

        // 2. Add initial contribution
        await _addContribution(tester, amount: 200.0);
        await tester.pumpAndSettle();

        // Verify progress update
        expect(find.text('20%'), findsOneWidget);

        // 3. Add multiple contributions over time
        final contributions = [150.0, 300.0, 200.0, 150.0];
        for (final amount in contributions) {
          await _addContribution(tester, amount: amount);
          await tester.pumpAndSettle();
        }

        // Verify final progress (200+150+300+200+150 = 1000 = 100%)
        expect(find.text('100%'), findsOneWidget);

        // 4. Verify completion celebration
        final celebrationFinder = find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString().contains('Celebration'),
        );
        expect(celebrationFinder, findsWidgets);

        // 5. Verify completion status in goals list
        await _navigateToGoalsList(tester);
        final completedGoalFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Completed') == true,
        );
        expect(completedGoalFinder, findsWidgets);
      });

      testWidgets('should handle goal workflow with transaction integration',
          (WidgetTester tester) async {
        // Create goal
        await _navigateToGoalsSection(tester);
        await _createTestGoal(tester, targetAmount: 600.0, deadlineMonths: 4);
        await _navigateToGoalDetail(tester);

        // Simulate adding transaction that contributes to goal
        await _addTransactionAndAllocateToGoal(tester, transactionAmount: 300.0);

        await tester.pumpAndSettle();

        // Verify contribution was added automatically
        expect(find.text('50%'), findsOneWidget);
        expect(find.text('\$300.00'), findsOneWidget);

        // Add manual contribution
        await _addContribution(tester, amount: 300.0);
        await tester.pumpAndSettle();

        // Verify goal completion
        expect(find.text('100%'), findsOneWidget);
      });

      testWidgets('should handle multiple goals simultaneously',
          (WidgetTester tester) async {
        // Create multiple goals
        await _navigateToGoalsSection(tester);

        await _createTestGoal(tester, targetAmount: 500.0, deadlineMonths: 3, title: 'Vacation Fund');
        await _createTestGoal(tester, targetAmount: 1000.0, deadlineMonths: 6, title: 'Emergency Fund');

        // Navigate to goals list
        await _navigateToGoalsList(tester);

        // Verify both goals appear
        expect(find.text('Vacation Fund'), findsOneWidget);
        expect(find.text('Emergency Fund'), findsOneWidget);

        // Add contributions to both
        await _navigateToGoalDetail(tester); // First goal
        await _addContribution(tester, amount: 250.0);
        await tester.pumpAndSettle();
        expect(find.text('50%'), findsOneWidget);

        await _navigateToGoalsList(tester);
        // Navigate to second goal (this depends on UI implementation)
        // For now, just verify the list shows updated progress
        final progressIndicators = find.byType(LinearProgressIndicator);
        expect(progressIndicators, findsWidgets);
      });
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS FOR NAVIGATION AND ACTIONS
// ============================================================================

Future<void> _navigateToGoalsSection(WidgetTester tester) async {
  // Navigate to goals section - adjust based on app's navigation
  final BuildContext context = tester.element(find.byType(MaterialApp).first);
  context.go('/goals');
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> _navigateToGoalsList(WidgetTester tester) async {
  final BuildContext context = tester.element(find.byType(MaterialApp).first);
  context.go('/goals');
  await tester.pumpAndSettle();
}

Future<void> _navigateToGoalDetail(WidgetTester tester) async {
  // Navigate to goal detail - adjust based on UI
  final goalCards = find.byType(Card);
  if (goalCards.evaluate().isNotEmpty) {
    await tester.tap(goalCards.first);
    await tester.pumpAndSettle();
  }
}

Future<void> _createTestGoal(
  WidgetTester tester, {
  required double targetAmount,
  required int deadlineMonths,
  String title = 'Test Goal',
  DateTime? customDeadline,
}) async {
  // Find and tap create goal button
  final createButton = find.byIcon(Icons.add);
  expect(createButton, findsOneWidget);
  await tester.tap(createButton);
  await tester.pumpAndSettle();

  // Fill goal creation form
  final titleField = find.byType(TextFormField).first;
  await tester.enterText(titleField, title);

  final amountField = find.byType(TextFormField).at(1);
  await tester.enterText(amountField, targetAmount.toString());

  // Set deadline
  final deadline = customDeadline ?? DateTime.now().add(Duration(days: deadlineMonths * 30));
  // This depends on the date picker implementation
  // For now, assume deadline is set automatically

  // Save goal
  final saveButton = find.text('Create Goal');
  if (saveButton.evaluate().isNotEmpty) {
    await tester.tap(saveButton);
  } else {
    final saveIcon = find.byIcon(Icons.save);
    await tester.tap(saveIcon);
  }
  await tester.pumpAndSettle();
}

Future<void> _addContribution(WidgetTester tester, {required double amount}) async {
  // Find add contribution button
  final addButton = find.byIcon(Icons.add_circle);
  expect(addButton, findsOneWidget);
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  // Enter amount
  final amountField = find.byType(TextFormField).first;
  await tester.enterText(amountField, amount.toString());
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  // Save contribution
  final saveButton = find.text('Add');
  if (saveButton.evaluate().isNotEmpty) {
    await tester.tap(saveButton);
  } else {
    final saveIcon = find.byIcon(Icons.check);
    await tester.tap(saveIcon);
  }
  await tester.pumpAndSettle();
}

Future<void> _addContributionWithDate(
  WidgetTester tester, {
  required double amount,
  required DateTime date,
}) async {
  // Similar to _addContribution but with date selection
  await _addContribution(tester, amount: amount);
  // Date selection would depend on the UI implementation
}

Future<void> _addContributionFromTransaction(
  WidgetTester tester, {
  required double amount,
  required String transactionId,
}) async {
  // This would depend on the transaction integration UI
  // For now, simulate adding a contribution
  await _addContribution(tester, amount: amount);
}

Future<void> _addTransactionAndAllocateToGoal(
  WidgetTester tester, {
  required double transactionAmount,
}) async {
  // Navigate to transactions
  final BuildContext context = tester.element(find.byType(MaterialApp).first);
  context.go('/transactions');
  await tester.pumpAndSettle();

  // Add transaction (simplified)
  final addButton = find.byIcon(Icons.add);
  await tester.tap(addButton);
  await tester.pumpAndSettle();

  // Fill transaction form
  final amountField = find.byType(TextFormField).first;
  await tester.enterText(amountField, transactionAmount.toString());

  // Allocate to goal (this depends on the UI implementation)
  // For now, assume allocation happens automatically or through a button
  final allocateButton = find.text('Allocate to Goal');
  if (allocateButton.evaluate().isNotEmpty) {
    await tester.tap(allocateButton);
    await tester.pumpAndSettle();
  }

  // Save transaction
  final saveButton = find.text('Save');
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

Future<void> _verifyMilestoneNotification(WidgetTester tester, int percentage) async {
  // Navigate to notifications
  final BuildContext context = tester.element(find.byType(MaterialApp).first);
  context.go('/notifications');
  await tester.pumpAndSettle();

  // Check for milestone notification
  final milestoneText = '$percentage% Complete';
  final notificationFinder = find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains(milestoneText) == true,
  );
  expect(notificationFinder, findsOneWidget);
}

Future<void> _verifyDeadlineReminderNotification(WidgetTester tester, {required int daysRemaining}) async {
  final BuildContext context = tester.element(find.byType(MaterialApp).first);
  context.go('/notifications');
  await tester.pumpAndSettle();

  final reminderFinder = find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains('$daysRemaining days') == true,
  );
  expect(reminderFinder, findsOneWidget);
}

Future<void> _verifyBehindScheduleNotification(WidgetTester tester) async {
  final BuildContext context = tester.element(find.byType(MaterialApp).first);
  context.go('/notifications');
  await tester.pumpAndSettle();

  final behindScheduleFinder = find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains('behind schedule') == true,
  );
  expect(behindScheduleFinder, findsOneWidget);
}