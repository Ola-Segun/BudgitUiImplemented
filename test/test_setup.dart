import 'package:mockito/mockito.dart';

import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';

// Import all entities that might be used in Result<T> types
import 'package:budget_tracker/features/accounts/domain/entities/account.dart';
import 'package:budget_tracker/features/budgets/domain/entities/budget.dart';
import 'package:budget_tracker/features/bills/domain/entities/bill.dart';
import 'package:budget_tracker/features/collaboration/domain/entities/shared_budget.dart';
import 'package:budget_tracker/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:budget_tracker/features/debt/domain/entities/debt.dart';
import 'package:budget_tracker/features/goals/domain/entities/goal.dart';
import 'package:budget_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:budget_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:budget_tracker/features/insights/domain/entities/insight.dart';
import 'package:budget_tracker/features/notifications/domain/entities/notification.dart' as notification;
import 'package:budget_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:budget_tracker/features/receipt_scanning/domain/entities/receipt_data.dart';
import 'package:budget_tracker/features/seasonal_analysis/domain/entities/seasonal_analysis.dart';
import 'package:budget_tracker/features/settings/domain/entities/settings.dart';
import 'package:budget_tracker/features/transactions/domain/entities/transaction.dart';

/// Common test setup for providing dummy values for Mockito Result<T> types
void setupMockitoDummies() {
  // Primitive types
  provideDummy<Result<void>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<bool>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<int>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<double>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<String>>(Result.error(Failure.unknown('dummy')));

  // Transaction related
  provideDummy<Result<Transaction>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<Transaction?>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<Transaction>>>(Result.error(Failure.unknown('dummy')));

  // Account related
  provideDummy<Result<Account>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<Account?>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<Account>>>(Result.error(Failure.unknown('dummy')));

  // Budget related
  provideDummy<Result<Budget>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<Budget?>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<Budget>>>(Result.error(Failure.unknown('dummy')));

  // Bill related
  provideDummy<Result<Bill>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<Bill?>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<Bill>>>(Result.error(Failure.unknown('dummy')));

  // Shared Budget related
  provideDummy<Result<SharedBudget>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<SharedBudget?>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<SharedBudget>>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<String>>>(Result.error(Failure.unknown('dummy')));

  // Dashboard related
  provideDummy<Result<DashboardData>>(Result.error(Failure.unknown('dummy')));

  // Debt related
  provideDummy<Result<Debt>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<Debt?>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<Debt>>>(Result.error(Failure.unknown('dummy')));

  // Goal related
  provideDummy<Result<Goal>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<Goal?>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<Goal>>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<GoalContribution>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<GoalContribution>>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<GoalProgress>>(Result.error(Failure.unknown('dummy')));

  // Insight related
  provideDummy<Result<Insight>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<Insight>>>(Result.error(Failure.unknown('dummy')));

  // Notification related
  provideDummy<Result<notification.AppNotification>>(Result.error(Failure.unknown('dummy')));
  provideDummy<Result<List<notification.AppNotification>>>(Result.error(Failure.unknown('dummy')));

  // Onboarding related
  provideDummy<Result<UserProfile>>(Result.error(Failure.unknown('dummy')));

  // Receipt scanning related
  provideDummy<Result<ReceiptData>>(Result.error(Failure.unknown('dummy')));


  // Seasonal analysis related
  provideDummy<Result<SeasonalAnalysis>>(Result.error(Failure.unknown('dummy')));

  // Settings related
  provideDummy<Result<AppSettings>>(Result.error(Failure.unknown('dummy')));

  // Transaction filter related
  provideDummy<Result<List<Transaction>>>(Result.error(Failure.unknown('dummy')));
}