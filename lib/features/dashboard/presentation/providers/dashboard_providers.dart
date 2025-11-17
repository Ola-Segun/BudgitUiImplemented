import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_data.dart';
import '../../domain/usecases/calculate_dashboard_data.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../bills/presentation/providers/bill_providers.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../goals/presentation/providers/goal_providers.dart';

// Repository providers
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(core_providers.transactionRepositoryProvider),
    ref.watch(core_providers.budgetRepositoryProvider),
    ref.watch(core_providers.billRepositoryProvider),
    ref.watch(core_providers.accountRepositoryProvider),
    ref.watch(core_providers.insightRepositoryProvider),
    ref.watch(core_providers.transactionCategoryRepositoryProvider),
    ref.watch(core_providers.calculateBudgetStatusProvider),
    ref.watch(core_providers.recurringIncomeRepositoryProvider),
  );
});

// Use case providers
final getDashboardDataUseCaseProvider = Provider<GetDashboardData>((ref) {
  return GetDashboardData(ref.watch(dashboardRepositoryProvider));
});

final calculateDashboardDataUseCaseProvider = Provider<CalculateDashboardData>((ref) {
  return CalculateDashboardData(ref.watch(dashboardRepositoryProvider));
});

// Cache for dashboard data to avoid recomputation
class _DashboardCache {
  DashboardData? _cachedData;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5); // Cache for 5 minutes

  bool get isValid => _cachedData != null &&
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < _cacheDuration;

  DashboardData? get data => isValid ? _cachedData : null;

  void setData(DashboardData data) {
    _cachedData = data;
    _lastFetchTime = DateTime.now();
  }

  void invalidate() {
    _cachedData = null;
    _lastFetchTime = null;
  }
}

final _dashboardCache = _DashboardCache();

// State providers - using StateNotifier for synchronous access and reduced flickering
final dashboardDataProvider = StateNotifierProvider<DashboardDataNotifier, AsyncValue<DashboardData>>((ref) {
  final notifier = DashboardDataNotifier(ref);
  return notifier;
});

class DashboardDataNotifier extends StateNotifier<AsyncValue<DashboardData>> {
  final Ref ref;

  DashboardDataNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initialize();
    _setupListeners();
  }

  void _initialize() async {
    try {
      // Check cache first
      if (_dashboardCache.isValid) {
        state = AsyncValue.data(_dashboardCache.data!);
        return;
      }

      // Load data asynchronously
      final calculateDashboardData = ref.read(calculateDashboardDataUseCaseProvider);
      final result = await calculateDashboardData();

      result.when(
        success: (data) {
          _dashboardCache.setData(data);
          state = AsyncValue.data(data);
        },
        error: (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupListeners() {
    // Listen to reactive providers to trigger data refresh
    ref.listen(transactionNotifierProvider, (previous, next) {
      if (previous != next) {
        _dashboardCache.invalidate();
        _refreshData();
      }
    });

    ref.listen(budgetNotifierProvider, (previous, next) {
      if (previous != next) {
        _dashboardCache.invalidate();
        _refreshData();
      }
    });

    ref.listen(billNotifierProvider, (previous, next) {
      if (previous != next) {
        _dashboardCache.invalidate();
        _refreshData();
      }
    });

    ref.listen(accountNotifierProvider, (previous, next) {
      if (previous != next) {
        _dashboardCache.invalidate();
        _refreshData();
      }
    });

    ref.listen(core_providers.recurringIncomeNotifierProvider, (previous, next) {
      if (previous != next) {
        _dashboardCache.invalidate();
        _refreshData();
      }
    });

    // Listen to goal changes to invalidate dashboard
    ref.listen(goalNotifierProvider, (previous, next) {
      if (previous != next) {
        _dashboardCache.invalidate();
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    state = const AsyncValue.loading();

    try {
      final calculateDashboardData = ref.read(calculateDashboardDataUseCaseProvider);
      final result = await calculateDashboardData();

      result.when(
        success: (data) {
          _dashboardCache.setData(data);
          state = AsyncValue.data(data);
        },
        error: (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    _dashboardCache.invalidate();
    await _refreshData();
  }
}

// Provider for refreshing dashboard data - now uses the notifier
final refreshDashboardProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(dashboardDataProvider.notifier);
  await notifier.refresh();
});
