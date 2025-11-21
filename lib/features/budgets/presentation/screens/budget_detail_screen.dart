import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/crash_detector.dart';
import '../../../../core/widgets/memory_monitor.dart';
import '../../../../core/widgets/platform_crash_handler.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../domain/entities/budget.dart' as budget_entity;
import '../../../../core/theme/app_colors_extended.dart' as app_colors_extended;
import '../../domain/models/aggregated_category.dart';
import '../providers/budget_providers.dart';
import '../widgets/circular_budget_indicator.dart';
import '../widgets/budget_status_banner.dart';
import '../widgets/budget_metric_cards.dart';
import '../widgets/budget_stats_row.dart';
import '../widgets/budget_bar_chart.dart';
import '../widgets/budget_category_breakdown_enhanced.dart';
import '../widgets/budget_edit_bottom_sheet.dart';

/// Enhanced Budget Detail Screen with advanced visualizations
class BudgetDetailScreen extends ConsumerStatefulWidget {
  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  final String budgetId;

  @override
  ConsumerState<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends ConsumerState<BudgetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _connectionCheckTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startConnectionMonitoring();

    // Initialize crash detector for this screen
    CrashDetector().initialize();

    // Start memory monitoring for this screen
    MemoryMonitor().startMonitoring();

    // Initialize platform-specific crash handling
    PlatformCrashHandler().initialize();
  }

  @override
  void dispose() {
    debugPrint('BudgetDetailScreen: dispose called, _isDisposed: $_isDisposed');

    try {
      _isDisposed = true;

      debugPrint('BudgetDetailScreen: Cancelling connection check timer');
      _connectionCheckTimer?.cancel();

      debugPrint('BudgetDetailScreen: Disposing tab controller');
      _tabController.dispose();

      // Stop memory monitoring
      MemoryMonitor().stopMonitoring();

      debugPrint('BudgetDetailScreen: dispose completed successfully');
    } catch (e, stackTrace) {
      debugPrint('BudgetDetailScreen: CRITICAL - Error during dispose: $e');
      debugPrint('BudgetDetailScreen: Dispose stack trace: $stackTrace');
      // Don't rethrow during dispose
    }

    super.dispose();
  }

  /// Start monitoring connection status for automatic recovery
  void _startConnectionMonitoring() {
    debugPrint('BudgetDetailScreen: Starting connection monitoring');

    try {
      _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_isDisposed) {
          debugPrint('BudgetDetailScreen: Connection monitoring cancelled - widget disposed');
          timer.cancel();
          return;
        }

        try {
          final budgetAsync = ref.read(budgetProvider(widget.budgetId));
          final budgetStatusAsync = ref.read(budgetStatusProvider(widget.budgetId));

          // If we're in an error state, try to refresh automatically
          if (budgetAsync.hasError || budgetStatusAsync.hasError) {
            if (_isConnectionError(budgetAsync.error) || _isConnectionError(budgetStatusAsync.error)) {
              debugPrint('BudgetDetailScreen: Connection error detected, attempting automatic refresh');
              ref.refresh(budgetProvider(widget.budgetId));
              ref.refresh(budgetStatusProvider(widget.budgetId));
            }
          }
        } catch (e, stackTrace) {
          debugPrint('BudgetDetailScreen: ERROR in connection monitoring: $e');
          debugPrint('BudgetDetailScreen: Connection monitoring stack trace: $stackTrace');
        }
      });

      debugPrint('BudgetDetailScreen: Connection monitoring started successfully');
    } catch (e, stackTrace) {
      debugPrint('BudgetDetailScreen: CRITICAL - Failed to start connection monitoring: $e');
      debugPrint('BudgetDetailScreen: Connection monitoring setup stack trace: $stackTrace');
    }
  }

  // Helper method for budget health calculation
  static budget_entity.BudgetHealth _getBudgetHealth(double percentage) {
    if (percentage > 100) return budget_entity.BudgetHealth.overBudget;
    if (percentage > 90) return budget_entity.BudgetHealth.critical;
    if (percentage > 75) return budget_entity.BudgetHealth.warning;
    return budget_entity.BudgetHealth.healthy;
  }

  // Helper method to check if error is connection-related
  static bool _isConnectionError(Object? error) {
    if (error == null) return false;
    final errorString = error.toString().toLowerCase();
    return errorString.contains('connection') ||
            errorString.contains('network') ||
            errorString.contains('timeout') ||
            errorString.contains('socket') ||
            errorString.contains('unreachable') ||
            errorString.contains('dns') ||
            errorString.contains('http') ||
            errorString.contains('server error') ||
            errorString.contains('service unavailable') ||
            errorString.contains('temporary failure') ||
            errorString.contains('rate limit');
  }

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(budgetProvider(widget.budgetId));
    final budgetStatusAsync = ref.watch(budgetStatusProvider(widget.budgetId));
    ref.watch(categoryNotifierProvider);

    // Diagnostic logging
    debugPrint('BudgetDetailScreen: Building with budgetId: ${widget.budgetId}');
    debugPrint('BudgetDetailScreen: budgetAsync state: ${budgetAsync.runtimeType}');
    debugPrint('BudgetDetailScreen: budgetStatusAsync state: ${budgetStatusAsync.runtimeType}');

    // Enhanced connection error detection and handling
    if (budgetAsync.hasError) {
      debugPrint('BudgetDetailScreen: CRITICAL - Budget provider error: ${budgetAsync.error}');
      debugPrint('BudgetDetailScreen: CRITICAL - Budget provider stack: ${budgetAsync.stackTrace}');
      final errorString = budgetAsync.error.toString().toLowerCase();
      if (errorString.contains('connection') || errorString.contains('network') || errorString.contains('timeout')) {
        debugPrint('BudgetDetailScreen: CRITICAL - CONNECTION ERROR in budget provider detected');
      }
    }
    if (budgetStatusAsync.hasError) {
      debugPrint('BudgetDetailScreen: CRITICAL - Budget status provider error: ${budgetStatusAsync.error}');
      debugPrint('BudgetDetailScreen: CRITICAL - Budget status provider stack: ${budgetStatusAsync.stackTrace}');
      final errorString = budgetStatusAsync.error.toString().toLowerCase();
      if (errorString.contains('connection') || errorString.contains('network') || errorString.contains('timeout')) {
        debugPrint('BudgetDetailScreen: CRITICAL - CONNECTION ERROR in budget status provider detected');
      }
    }

    // Check for offline/connection states
    final isBudgetOffline = budgetAsync.hasValue && budgetAsync.value == null;
    final isStatusOffline = budgetStatusAsync.hasValue && budgetStatusAsync.value == null;
    final hasConnectionError = (budgetAsync.hasError && _isConnectionError(budgetAsync.error)) ||
                              (budgetStatusAsync.hasError && _isConnectionError(budgetStatusAsync.error));

    // Check for null states that could cause crashes
    if (budgetAsync.hasValue && budgetAsync.value == null) {
      debugPrint('BudgetDetailScreen: WARNING - Budget provider returned null value');
    }
    if (budgetStatusAsync.hasValue && budgetStatusAsync.value == null) {
      debugPrint('BudgetDetailScreen: WARNING - Budget status provider returned null value');
    }

    // Additional crash prevention checks
    if (budgetAsync.hasValue && budgetAsync.value != null) {
      final budget = budgetAsync.value!;
      if (budget.categories.isEmpty) {
      debugPrint('BudgetDetailScreen: WARNING - Budget has no categories');
    } else {
      // Check for corrupted category data
      for (final category in budget.categories) {
        if (category.id.isEmpty) {
          debugPrint('BudgetDetailScreen: ERROR - Budget category with null/empty ID found');
        }
        if (category.amount.isNaN || category.amount.isInfinite) {
          debugPrint('BudgetDetailScreen: ERROR - Budget category ${category.id} has invalid amount: ${category.amount}');
        }
      }
    }
    }

    if (budgetStatusAsync.hasValue && budgetStatusAsync.value != null) {
      final status = budgetStatusAsync.value!;
      if (status.totalBudget.isNaN || status.totalBudget.isInfinite) {
        debugPrint('BudgetDetailScreen: ERROR - Budget status has invalid total budget: ${status.totalBudget}');
      }
      if (status.totalSpent.isNaN || status.totalSpent.isInfinite) {
        debugPrint('BudgetDetailScreen: ERROR - Budget status has invalid total spent: ${status.totalSpent}');
      }
      if (status.categoryStatuses.isEmpty) {
      debugPrint('BudgetDetailScreen: WARNING - Budget status has no category statuses');
    }
    }

   return CrashBoundary(
     onCrash: (crash) {
       debugPrint('BudgetDetailScreen: CRASH DETECTED - ${crash.message}');
       // Report crash to analytics or logging service
     },
     child: Scaffold(
        backgroundColor: AppColors.background,
        body: budgetAsync.when(
        data: (budget) {
          debugPrint('BudgetDetailScreen: Budget data received: ${budget?.id ?? 'null'}');
          if (budget == null) {
            debugPrint('BudgetDetailScreen: Budget is null, showing not found');
            return const Center(child: Text('Budget not found'));
          }

          // Handle offline/connection states
          if (hasConnectionError || isBudgetOffline || isStatusOffline) {
            debugPrint('BudgetDetailScreen: Connection issue detected, showing offline state');
            return _buildOfflineState(context, ref, budget, isBudgetOffline, isStatusOffline, hasConnectionError);
          }

          return _buildBudgetDetail(context, ref, budget, budgetStatusAsync);
        },
        loading: () {
          debugPrint('BudgetDetailScreen: Loading budget data');
          return const LoadingView();
        },
        error: (error, stack) {
          debugPrint('BudgetDetailScreen: Error loading budget: $error');
          debugPrint('BudgetDetailScreen: Stack trace: $stack');

          if (_isConnectionError(error)) {
            debugPrint('BudgetDetailScreen: Connection error detected, showing offline UI');
            return _buildConnectionErrorState(context, ref, error);
          }

          return ErrorView(
            message: error.toString(),
            onRetry: () => ref.refresh(budgetProvider(widget.budgetId)),
          );
        },
      ),
    ),
   );
  }

  Widget _buildBudgetDetail(
    BuildContext context,
    WidgetRef ref,
    budget_entity.Budget budget,
    AsyncValue<budget_entity.BudgetStatus?> budgetStatusAsync,
  ) {
    debugPrint('BudgetDetailScreen: Building budget detail for budget: ${budget.id}');
    debugPrint('BudgetDetailScreen: Budget categories count: ${budget.categories.length}');

    return CustomScrollView(
      slivers: [
        // Animated App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Budget options',
              onPressed: () => _showBudgetOptions(context, ref, budget),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              budget.name,
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                    AppColors.surface,
                  ],
                ),
              ),
              child: budgetStatusAsync.when(
                data: (status) {
                  debugPrint('BudgetDetailScreen: Budget status data received: ${status?.totalSpent ?? 'null'}');
                  if (status == null) {
                    debugPrint('BudgetDetailScreen: Budget status is null');
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: CircularBudgetIndicator(
                        percentage: status.totalSpent / status.totalBudget,
                        spent: status.totalSpent,
                        total: status.totalBudget,
                        size: 120,
                        strokeWidth: 12,
                      ),
                    ),
                  );
                },
                loading: () {
                  debugPrint('BudgetDetailScreen: Loading budget status');
                  return const SizedBox.shrink();
                },
                error: (error, stack) {
                  debugPrint('BudgetDetailScreen: Error loading budget status: $error');
                  debugPrint('BudgetDetailScreen: Status stack trace: $stack');
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(budgetNotifierProvider.notifier).loadBudgets();
              },
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.screenPaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  SizedBox(height: AppDimensions.sectionGap),

                  // Status Banner
                  budgetStatusAsync.when(
                    data: (status) {
                      if (status == null) return const SizedBox.shrink();
                      return BudgetStatusBanner(
                        remainingAmount: status.remainingAmount,
                        health: status.overallHealth,
                      ).animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, duration: 400.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Metric Cards
                  budgetStatusAsync.when(
                    data: (status) {
                      if (status == null) return const SizedBox.shrink();
                      return BudgetMetricCards(
                        usageRate: status.totalSpent / status.totalBudget,
                        allotmentRate: _calculateAllotmentRate(status),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Stats Row
                  budgetStatusAsync.when(
                    data: (status) {
                      if (status == null) return const SizedBox.shrink();
                      return BudgetStatsRow(
                        allotted: status.totalBudget,
                        used: status.totalSpent,
                        remaining: status.remainingAmount,
                      ).animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Category Breakdown
                  budgetStatusAsync.when(
                    data: (status) {
                      debugPrint('BudgetDetailScreen: Rendering BudgetCategoryBreakdownEnhanced with status: ${status?.totalSpent ?? 'null'}');
                      if (status == null) {
                        debugPrint('BudgetDetailScreen: Status is null, skipping category breakdown');
                        return const SizedBox.shrink();
                      }

                      try {
                        return BudgetCategoryBreakdownEnhanced(
                          budget: budget,
                          budgetStatus: status,
                        );
                      } catch (e, stackTrace) {
                        debugPrint('BudgetDetailScreen: CRITICAL - BudgetCategoryBreakdownEnhanced crashed: $e');
                        debugPrint('BudgetDetailScreen: Category breakdown crash stack: $stackTrace');
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: const Center(
                            child: Text('Failed to load category breakdown'),
                          ),
                        );
                      }
                    },
                    loading: () {
                      debugPrint('BudgetDetailScreen: Loading category breakdown');
                      return const SizedBox.shrink();
                    },
                    error: (error, stack) {
                      debugPrint('BudgetDetailScreen: Error in category breakdown: $error');
                      debugPrint('BudgetDetailScreen: Category breakdown stack: $stack');
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text('Error loading categories: $error'),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppDimensions.sectionGap),

                  // // Enhanced Interactive Budget Chart
                  // budgetStatusAsync.when(
                  //   data: (status) {
                  //     debugPrint('BudgetDetailScreen: Rendering InteractiveBudgetChart with status: ${status?.totalSpent ?? 'null'}');
                  //     if (status == null || status.categoryStatuses.isEmpty) {
                  //       debugPrint('BudgetDetailScreen: No data for chart, status null or empty categories');
                  //       return Container(
                  //         padding: const EdgeInsets.all(24),
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(16),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.black.withValues(alpha: 0.04),
                  //               blurRadius: 8,
                  //               offset: const Offset(0, 2),
                  //             ),
                  //           ],
                  //         ),
                  //         child: const Center(
                  //           child: Text('No data available for chart'),
                  //         ),
                  //       );
                  //     }

                  //     debugPrint('BudgetDetailScreen: Preparing chart data for ${status.categoryStatuses.length} categories');

                  //     try {
                  //       // Prepare chart data with enhanced styling
                  //       final chartData = status.categoryStatuses.map((categoryStatus) {
                  //         debugPrint('BudgetDetailScreen: Processing category ${categoryStatus.categoryId}');
                  //         final budgetCategory = budget.categories.firstWhere(
                  //           (cat) => cat.id == categoryStatus.categoryId,
                  //           orElse: () => budget_entity.BudgetCategory(
                  //             id: categoryStatus.categoryId,
                  //             name: 'Unknown',
                  //             amount: categoryStatus.budget,
                  //           ),
                  //         );

                  //         final transactionCategory = ref.watch(categoryNotifierProvider.notifier).getCategoryById(categoryStatus.categoryId);
                  //         final displayName = transactionCategory?.name ?? budgetCategory.name;
                  //         final displayColor = transactionCategory != null
                  //             ? ref.watch(categoryIconColorServiceProvider).getColorForCategory(transactionCategory.id)
                  //             : AppColors.primary;

                  //         // Validate chart data
                  //         final spentAmount = categoryStatus.spent.isNaN || categoryStatus.spent.isInfinite
                  //             ? 0.0
                  //             : categoryStatus.spent.clamp(0.0, double.infinity);
                  //         final budgetAmount = categoryStatus.budget.isNaN || categoryStatus.budget.isInfinite
                  //             ? 0.0
                  //             : categoryStatus.budget.clamp(0.0, double.infinity);

                  //         debugPrint('BudgetDetailScreen: Chart category: $displayName, spent: $spentAmount, budget: $budgetAmount');

                  //         return BudgetChartCategory(
                  //           name: displayName,
                  //           spentAmount: spentAmount,
                  //           budgetAmount: budgetAmount,
                  //           color: displayColor,
                  //         );
                  //       }).toList();

                  //       return Container(
                  //         padding: const EdgeInsets.all(20),
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(16),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.black.withValues(alpha: 0.06),
                  //               blurRadius: 16,
                  //               offset: const Offset(0, 4),
                  //             ),
                  //           ],
                  //         ),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             // Enhanced header with gradient
                  //             Row(
                  //               children: [
                  //                 Container(
                  //                   padding: const EdgeInsets.all(8),
                  //                   decoration: BoxDecoration(
                  //                     gradient: LinearGradient(
                  //                       begin: Alignment.topLeft,
                  //                       end: Alignment.bottomRight,
                  //                       colors: [
                  //                         AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                  //                         AppColorsExtended.budgetTertiary.withValues(alpha: 0.05),
                  //                       ],
                  //                     ),
                  //                     borderRadius: BorderRadius.circular(8),
                  //                   ),
                  //                   child: Icon(
                  //                     Icons.bar_chart_rounded,
                  //                     size: 20,
                  //                     color: AppColorsExtended.budgetTertiary,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 12),
                  //                 Text(
                  //                   'Spending Analysis',
                  //                   style: AppTypography.h3.copyWith(
                  //                     fontWeight: FontWeight.w700,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             const SizedBox(height: 20),
                  //             InteractiveBudgetChart(
                  //               categoryData: chartData,
                  //               totalBudget: status.totalBudget,
                  //               totalSpent: status.totalSpent,
                  //               height: 350,
                  //               showLegend: true,
                  //               isInteractive: true,
                  //             ),
                  //           ],
                  //         ),
                  //       ).animate()
                  //         .fadeIn(duration: 500.ms, delay: 400.ms)
                  //         .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms);
                  //     } catch (e, stackTrace) {
                  //       debugPrint('BudgetDetailScreen: CRITICAL - Error preparing chart data: $e');
                  //       debugPrint('BudgetDetailScreen: Chart data preparation stack trace: $stackTrace');
                  //       return Container(
                  //         padding: const EdgeInsets.all(24),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.error.withValues(alpha: 0.1),
                  //           borderRadius: BorderRadius.circular(16),
                  //           border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  //         ),
                  //         child: const Center(
                  //           child: Text('Failed to prepare chart data'),
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   loading: () => Container(
                  //     height: 350,
                  //     padding: const EdgeInsets.all(24),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(16),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withValues(alpha: 0.04),
                  //           blurRadius: 8,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: const Center(child: CircularProgressIndicator()),
                  //   ),
                  //   error: (error, stack) => Container(
                  //     height: 350,
                  //     padding: const EdgeInsets.all(24),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(16),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withValues(alpha: 0.04),
                  //           blurRadius: 8,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Center(
                  //       child: Text('Failed to load chart: $error'),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Budget Information
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                                    AppColorsExtended.budgetTertiary.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColorsExtended.budgetTertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Budget Information',
                              style: AppTypography.h3.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _InfoRow(
                          label: 'Type',
                          value: budget.type.displayName,
                          icon: Icons.category_outlined,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Period',
                          value: '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd, yyyy').format(budget.endDate)}',
                          icon: Icons.calendar_today,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Total Budget',
                          value: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(budget.totalBudget),
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Status',
                          value: budget.isActive ? 'Active' : 'Inactive',
                          icon: budget.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                          valueColor: budget.isActive ? AppColorsExtended.statusNormal : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Rollover',
                          value: budget.allowRollover ? 'Enabled' : 'Disabled',
                          icon: budget.allowRollover ? Icons.autorenew : Icons.block,
                          valueColor: budget.allowRollover ? AppColorsExtended.statusNormal : AppColors.textSecondary,
                        ),

                        if (budget.description != null && budget.description!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColorsExtended.pillBgUnselected,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Description',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  budget.description!,
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideY(begin: 0.1, duration: 500.ms, delay: 500.ms),
                  SizedBox(height: AppDimensions.sectionGap),

                  // Enhanced Recent Transactions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                                    AppColorsExtended.budgetPrimary.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                size: 20,
                                color: AppColorsExtended.budgetPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Recent Transactions',
                                style: AppTypography.h3.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to all transactions
                              },
                              child: Text(
                                'View All',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColorsExtended.budgetPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        ref.watch(transactionNotifierProvider).when(
                          data: (state) {
                            debugPrint('BudgetDetailScreen: Processing transactions for recent list');
                            final categoryIds = budget.categories.map((c) => c.id).toSet();
                            debugPrint('BudgetDetailScreen: Budget category IDs: $categoryIds');
                            final transactions = state.transactions.where((transaction) {
                              if (!categoryIds.contains(transaction.categoryId)) return false;
                              return transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
                                  transaction.date.isBefore(budget.endDate.add(const Duration(days: 1))) &&
                                  transaction.type == TransactionType.expense;
                            }).toList()
                              ..sort((a, b) => b.date.compareTo(a.date));

                            debugPrint('BudgetDetailScreen: Filtered transactions count: ${transactions.length}');

                            if (transactions.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    // Lottie Animation for empty transactions
                                    SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: Lottie.asset(
                                        'assets/animations/empty_transactions.json',
                                        fit: BoxFit.contain,
                                        repeat: true,
                                        animate: true,
                                      ),
                                    ).animate()
                                      .fadeIn(duration: 500.ms)
                                      .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),

                                    const SizedBox(height: 16),

                                    Text(
                                      'No transactions found',
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ).animate()
                                      .fadeIn(duration: 300.ms, delay: 200.ms),

                                    const SizedBox(height: 8),

                                    Text(
                                      'Transactions for this budget\nwill appear here',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ).animate()
                                      .fadeIn(duration: 300.ms, delay: 300.ms),
                                  ],
                                ),
                              );
                            }

                            final recentTransactions = transactions.take(5).toList();
                            final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

                            return Column(
                              children: recentTransactions.asMap().entries.map((entry) {
                                final index = entry.key;
                                final transaction = entry.value;
                                final categoryIcon = categoryIconColorService.getIconForCategory(transaction.categoryId);
                                final categoryColor = categoryIconColorService.getColorForCategory(transaction.categoryId);

                                return Padding(
                                  padding: EdgeInsets.only(bottom: index < recentTransactions.length - 1 ? 12 : 0),
                                  child: _TransactionItem(
                                    transaction: transaction,
                                    icon: categoryIcon,
                                    color: categoryColor,
                                  ).animate()
                                    .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                                    .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (error, stack) => Container(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load transactions',
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms)
                    .slideY(begin: 0.1, duration: 500.ms, delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
    ),
    ],
    );
  }

  // Helper methods
  double _calculateAllotmentRate(budget_entity.BudgetStatus status) {
    final now = DateTime.now();
    final budget = status.budget;
    final totalDays = budget.endDate.difference(budget.startDate).inDays;
    final daysElapsed = now.difference(budget.startDate).inDays;
    final timeProgress = (daysElapsed / totalDays).clamp(0.0, 1.0);

    final idealSpendingRate = timeProgress;
    final actualSpendingRate = status.totalSpent / status.totalBudget;

    return (actualSpendingRate / (idealSpendingRate == 0 ? 0.01 : idealSpendingRate)).clamp(0.0, 2.0);
  }

  /// Build offline state UI when data is unavailable due to connection issues
  Widget _buildOfflineState(
    BuildContext context,
    WidgetRef ref,
    budget_entity.Budget budget,
    bool isBudgetOffline,
    bool isStatusOffline,
    bool hasConnectionError,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Budget options',
              onPressed: () => _showBudgetOptions(context, ref, budget),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              budget.name,
              style: AppTypography.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                    AppColors.surface,
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Offline Mode',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced offline indicator with detailed status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorsExtended.statusWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColorsExtended.statusWarning.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: AppColorsExtended.statusWarning,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Limited Connectivity',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColorsExtended.statusWarning,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Using cached data. Some features may be unavailable.',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.refresh(budgetProvider(widget.budgetId));
                              ref.refresh(budgetStatusProvider(widget.budgetId));
                            },
                            child: Text(
                              'Refresh',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColorsExtended.budgetPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Status indicators
                      Row(
                        children: [
                          _buildStatusIndicator(
                            icon: Icons.check_circle,
                            label: 'Budget Info',
                            available: true,
                          ),
                          const SizedBox(width: 16),
                          _buildStatusIndicator(
                            icon: Icons.cached,
                            label: 'Cached Data',
                            available: true,
                          ),
                          const SizedBox(width: 16),
                          _buildStatusIndicator(
                            icon: Icons.sync_problem,
                            label: 'Live Updates',
                            available: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.sectionGap),

                // Basic budget info (available offline)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                                  AppColorsExtended.budgetTertiary.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColorsExtended.budgetTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Budget Information',
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _InfoRow(
                        label: 'Type',
                        value: budget.type.displayName,
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Period',
                        value: '${DateFormat('MMM dd').format(budget.startDate)} - ${DateFormat('MMM dd, yyyy').format(budget.endDate)}',
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Total Budget',
                        value: NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(budget.totalBudget),
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Status',
                        value: budget.isActive ? 'Active' : 'Inactive',
                        icon: budget.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                        valueColor: budget.isActive ? AppColorsExtended.statusNormal : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppDimensions.sectionGap),

                // Placeholder for spending data
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 48,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Spending data unavailable',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect to the internet to view\nyour budget progress and transactions.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build connection error state UI with enhanced recovery options
  Widget _buildConnectionErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                'Connection Error',
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load budget data.\nPlease check your internet connection.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${error.toString()}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate back to budget list
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColorsExtended.budgetPrimary,
                      side: BorderSide(color: AppColorsExtended.budgetPrimary),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.refresh(budgetProvider(widget.budgetId));
                      ref.refresh(budgetStatusProvider(widget.budgetId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsExtended.budgetPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  // Show offline help
                  _showOfflineHelpDialog(context);
                },
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('Offline Help'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show offline help dialog
  void _showOfflineHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Mode'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('When offline, you can still:'),
            SizedBox(height: 8),
            Text('• View basic budget information'),
            Text('• Access cached spending data'),
            Text('• Navigate between budgets'),
            SizedBox(height: 12),
            Text('Data will sync automatically when connection is restored.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Build status indicator widget
  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required bool available,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: available ? AppColorsExtended.statusNormal : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: available ? AppColorsExtended.statusNormal : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build error boundary fallback UI for failed components
  Widget _buildErrorBoundaryFallback(String componentName) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            '$componentName Unavailable',
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'This component failed to load.\nPlease try refreshing the page.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<List<BudgetChartData>> _getDailyData(budget_entity.Budget budget, budget_entity.BudgetStatus? status) async {
    final now = DateTime.now();
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Get transaction repository from providers
    final transactionRepository = ref.read(core_providers.transactionRepositoryProvider);

    final dailyData = <BudgetChartData>[];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayOfWeek = date.weekday % 7;
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Get transactions for this day that belong to budget categories
      final categoryIds = budget.categories.map((c) => c.id).toSet();
      double dailyAmount = 0.0;

      try {
        // Get all transactions for the day
        final transactionsResult = await transactionRepository.getByDateRange(dayStart, dayEnd);
        if (transactionsResult.isSuccess) {
          final dayTransactions = transactionsResult.dataOrNull ?? [];
          // Filter by budget categories and expense type
          final budgetTransactions = dayTransactions.where((transaction) =>
            categoryIds.contains(transaction.categoryId) &&
            transaction.type == TransactionType.expense &&
            transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(budget.endDate.add(const Duration(days: 1)))
          ).toList();

          dailyAmount = budgetTransactions.fold<double>(0.0, (sum, transaction) => sum + transaction.amount);
        }
      } catch (e) {
        // On error, use 0 for the day
        dailyAmount = 0.0;
      }

      dailyData.add(BudgetChartData(
        label: weekDays[dayOfWeek],
        value: dailyAmount,
      ));
    }

    return dailyData;
  }

  Future<List<BudgetChartData>> _getWeeklyData(budget_entity.Budget budget, budget_entity.BudgetStatus? status) async {
    final now = DateTime.now();
    final transactionRepository = ref.read(core_providers.transactionRepositoryProvider);
    final categoryIds = budget.categories.map((c) => c.id).toSet();

    final weeklyData = <BudgetChartData>[];

    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (3 - i) * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weekLabel = 'Week ${i + 1}';

      double weeklyAmount = 0.0;

      try {
        // Get transactions for this week
        final transactionsResult = await transactionRepository.getByDateRange(weekStart, weekEnd);
        if (transactionsResult.isSuccess) {
          final weekTransactions = transactionsResult.dataOrNull ?? [];
          // Filter by budget categories and expense type
          final budgetTransactions = weekTransactions.where((transaction) =>
            categoryIds.contains(transaction.categoryId) &&
            transaction.type == TransactionType.expense &&
            transaction.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(budget.endDate.add(const Duration(days: 1)))
          ).toList();

          weeklyAmount = budgetTransactions.fold<double>(0.0, (sum, transaction) => sum + transaction.amount);
        }
      } catch (e) {
        // On error, use 0 for the week
        weeklyAmount = 0.0;
      }

      weeklyData.add(BudgetChartData(
        label: weekLabel,
        value: weeklyAmount,
      ));
    }

    return weeklyData;
  }

  void _showCategoryDetails(BuildContext context, String categoryName, AggregatedCategory category, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Category Details',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress visualization
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${((category.totalSpent / category.totalBudget) * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (category.totalSpent / category.totalBudget).clamp(0.0, 1.0),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Spent',
                    '\$${category.totalSpent.toStringAsFixed(2)}',
                    Icons.trending_up,
                    color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Budget',
                    '\$${category.totalBudget.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Remaining',
                    '\$${(category.totalBudget - category.totalSpent).toStringAsFixed(2)}',
                    Icons.trending_down,
                    (category.totalBudget - category.totalSpent) >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Status',
                    _getStatusText(category.status),
                    _getStatusIcon(category.status),
                    _getStatusColor(category.status),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0: return 'Healthy';
      case 1: return 'Warning';
      case 2: return 'Critical';
      case 3: return 'Over Budget';
      default: return 'Unknown';
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0: return Icons.check_circle;
      case 1: return Icons.warning;
      case 2: return Icons.error;
      case 3: return Icons.cancel;
      default: return Icons.help;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return Colors.green;
      case 1: return Colors.orange;
      case 2: return Colors.red;
      case 3: return Colors.red.shade800;
      default: return Colors.grey;
    }
  }

void _showBudgetOptions(BuildContext context, WidgetRef ref, budget_entity.Budget budget) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('Edit Budget'),
            onTap: () {
              // Close the options bottom sheet first
              Navigator.pop(context);
              
              // Then show the edit bottom sheet
              BudgetEditBottomSheet.show(
                context: context,
                budget: budget,
                onSubmit: (updatedBudget) async {
                  await ref
                      .read(budgetNotifierProvider.notifier)
                      .updateBudget(updatedBudget);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget updated successfully')),
                    );
                  }
                },
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            ),
            title: const Text('Delete Budget'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, budget);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    budget_entity.Budget budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete "${budget.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && !_isDisposed) {
      final success = await ref
          .read(budgetNotifierProvider.notifier)
          .deleteBudget(budget.id);

      if (success && mounted && !_isDisposed) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget deleted successfully')),
        );
      }
    }
  }
}





/// Category Progress Item
class _CategoryProgressItem extends StatelessWidget {
  const _CategoryProgressItem({
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.spent,
    required this.budget,
    required this.status,
  });

  final String categoryName;
  final IconData icon;
  final Color color;
  final double spent;
  final double budget;
  final budget_entity.BudgetHealth status;

  Color _getHealthColor(budget_entity.BudgetHealth health) {
    switch (health) {
      case budget_entity.BudgetHealth.healthy:
        return app_colors_extended.AppColorsExtended.statusNormal;
      case budget_entity.BudgetHealth.warning:
        return app_colors_extended.AppColorsExtended.statusWarning;
      case budget_entity.BudgetHealth.critical:
        return app_colors_extended.AppColorsExtended.statusCritical;
      case budget_entity.BudgetHealth.overBudget:
        return app_colors_extended.AppColorsExtended.statusOverBudget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (spent / budget).clamp(0.0, 1.0);
    final healthColor = _getHealthColor(status);
    final isOverBudget = status == budget_entity.BudgetHealth.overBudget;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
        border: isOverBudget ? Border.all(
          color: healthColor.withValues(alpha: 0.3),
          width: 2,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(progress * 100).toInt()}% used',
                      style: AppTypography.caption.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(spent),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: healthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        healthColor,
                        healthColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: healthColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(budget)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (isOverBudget)
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: healthColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${(spent - budget).toStringAsFixed(0)} over',
                      style: AppTypography.caption.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '\$${(budget - spent).toStringAsFixed(0)} left',
                  style: AppTypography.caption.copyWith(
                    color: AppColorsExtended.statusNormal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}


/// Transaction Item Widget
class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.transaction,
    required this.icon,
    required this.color,
  });

  final Transaction transaction;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy').format(transaction.date),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(transaction.amount),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}