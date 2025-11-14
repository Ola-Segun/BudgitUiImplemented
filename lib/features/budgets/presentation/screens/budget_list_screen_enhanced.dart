import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';
import '../../../budgets/presentation/widgets/budget_bar_chart.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';
import '../states/budget_state.dart';
import '../widgets/budget_category_breakdown_enhanced.dart';
import '../widgets/budget_overview_enhanced.dart';
import 'budget_creation_screen.dart';

/// ✨ COMPLETELY REDESIGNED Budget List Screen
/// Matches Home/Transaction design aesthetics with:
/// - Segmented circular indicators
/// - Enhanced gradient cards
/// - Interactive animations
/// - Sophisticated visual hierarchy
class BudgetListScreenEnhanced extends ConsumerStatefulWidget {
  const BudgetListScreenEnhanced({super.key});

  @override
  ConsumerState<BudgetListScreenEnhanced> createState() =>
      _BudgetListScreenEnhancedState();
}

class _BudgetListScreenEnhancedState
    extends ConsumerState<BudgetListScreenEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetNotifierProvider);
    final statsState = ref.watch(budgetStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            _buildEnhancedHeader(),

            // Main Content
            Expanded(
              child: budgetState.when(
                data: (state) => _buildBody(state, statsState),
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.refresh(budgetNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildEnhancedFAB(),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: EdgeInsets.all(AppDimensions.screenPaddingH),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Budgets',
                        style: AppTypographyExtended.circularProgressPercentage
                            .copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your spending goals',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.search,
                      onPressed: () => _showSearchSheet(context),
                      tooltip: 'Search',
                    ),
                    SizedBox(width: AppDimensions.spacing2),
                    _HeaderIconButton(
                      icon: Icons.filter_list,
                      onPressed: () => _showFilterSheet(context),
                      tooltip: 'Filter',
                    ),
                  ],
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.1, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildBody(BudgetState state, AsyncValue<BudgetStats> statsAsync) {
    if (state.budgets.isEmpty) {
      return _buildEmptyState();
    }

    // Get active budget for featured display
    final activeBudget = state.activeBudgets.isNotEmpty
        ? state.activeBudgets.first
        : state.budgets.first;

    final budgetStatus = state.budgetStatuses
        .where((s) => s.budget.id == activeBudget.id)
        .firstOrNull;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(budgetNotifierProvider.notifier).loadBudgets();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Budget - Circular Progress
            if (budgetStatus != null) ...[
              _buildFeaturedBudgetSection(activeBudget, budgetStatus),
              SizedBox(height: AppDimensions.sectionGap),
            ],

            // Quick Stats
            if (budgetStatus != null) ...[
              _buildQuickStats(budgetStatus),
              SizedBox(height: AppDimensions.sectionGap),
            ],

            // ✨ ENHANCED: Category Breakdown with Segmented Indicator
            if (budgetStatus != null) ...[
              BudgetCategoryBreakdownEnhanced(
                budget: activeBudget,
                budgetStatus: budgetStatus,
              ),
              SizedBox(height: AppDimensions.sectionGap),
            ],

            // Chart Section with Tabs
            _buildChartSection(activeBudget, budgetStatus),
            SizedBox(height: AppDimensions.sectionGap),

            // ✨ ENHANCED: Budget Overview Section
            BudgetOverviewEnhanced(
              budgets: state.budgets,
              budgetStatuses: state.budgetStatuses,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBudgetSection(Budget budget, BudgetStatus status) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Label
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing3,
                  vertical: AppDimensions.spacing1,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColorsExtended.budgetPrimary,
                      AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: AppDimensions.spacing1),
                    Text(
                      'Featured Budget',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/budgets/${budget.id}'),
                child: Text(
                  'View Details',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColorsExtended.budgetPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          // Circular Indicator
          Center(
            child: CircularBudgetIndicator(
              percentage: status.totalSpent / status.totalBudget,
              spent: status.totalSpent,
              total: status.totalBudget,
              size: 200,
              strokeWidth: 22,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .scale(
              begin: const Offset(0.85, 0.85),
              duration: 600.ms,
              delay: 200.ms,
              curve: Curves.elasticOut,
            ),

          SizedBox(height: AppDimensions.spacing4),

          // Budget name
          Text(
            budget.name,
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            budget.type.displayName,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildQuickStats(BudgetStatus status) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.trending_up,
            label: 'Usage',
            value: '${((status.totalSpent / status.totalBudget) * 100).toInt()}%',
            color: AppColorsExtended.budgetPrimary,
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 300.ms),
        ),
        SizedBox(width: AppDimensions.spacing3),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.access_time,
            label: 'Days Left',
            value: '${status.daysRemaining}',
            color: AppColorsExtended.budgetSecondary,
          ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 400.ms),
        ),
      ],
    );
  }

  Widget _buildChartSection(Budget budget, BudgetStatus? status) {
    return Container(
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
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColorsExtended.budgetPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: AppColorsExtended.budgetPrimary,
                  width: 3,
                ),
                insets: EdgeInsets.symmetric(horizontal: 40),
              ),
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
              ],
            ),
          ),

          // Tab Views
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Daily Chart
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: BudgetBarChart(
                    data: _getDailyData(budget, status),
                    title: 'Daily Spending',
                    period: 'Last 7 Days',
                    height: 200,
                  ),
                ),

                // Weekly Chart
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: BudgetBarChart(
                    data: _getWeeklyData(budget, status),
                    title: 'Weekly Spending',
                    period: 'Last 4 Weeks',
                    height: 200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 600.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 600.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                    AppColorsExtended.budgetPrimary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 72,
                color: AppColorsExtended.budgetPrimary,
              ),
            ).animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
            SizedBox(height: AppDimensions.spacing4),
            Text(
              'No budgets yet',
              style: AppTypographyExtended.circularProgressPercentage.copyWith(
                fontSize: 24,
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),
            SizedBox(height: AppDimensions.spacing2),
            Text(
              'Create your first budget to start\ntracking your spending goals',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 300.ms, delay: 300.ms),
            SizedBox(height: AppDimensions.spacing5),
            ElevatedButton.icon(
              onPressed: () => _navigateToBudgetCreation(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsExtended.budgetPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
              ),
            ).animate()
              .fadeIn(duration: 300.ms, delay: 400.ms)
              .slideY(
                begin: 0.1,
                duration: 300.ms,
                delay: 400.ms,
                curve: Curves.elasticOut,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFAB() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetPrimary,
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _navigateToBudgetCreation();
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'New Budget',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 800.ms)
      .slideY(
        begin: 0.1,
        duration: 300.ms,
        delay: 800.ms,
        curve: Curves.elasticOut,
      );
  }

  // Helper methods
  List<BudgetChartData> _getDailyData(Budget budget, BudgetStatus? status) {
    final now = DateTime.now();
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayOfWeek = date.weekday % 7;
      final baseAmount = (status?.totalSpent ?? 100) / 7;
      final variance = (index * 0.2) - 0.6;
      final amount = baseAmount * (1 + variance);

      return BudgetChartData(
        label: weekDays[dayOfWeek],
        value: amount.clamp(0, double.infinity),
      );
    });
  }

  List<BudgetChartData> _getWeeklyData(Budget budget, BudgetStatus? status) {
    return List.generate(4, (index) {
      final weekLabel = 'Week ${index + 1}';
      final baseAmount = (status?.totalBudget ?? 1000) / 4;
      final variance = (index * 0.2) - 0.3;
      final amount = baseAmount * (1 + variance);
      return BudgetChartData(
        label: weekLabel,
        value: amount.clamp(0, double.infinity),
      );
    });
  }

  void _navigateToBudgetCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BudgetCreationScreen(),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    // Implement search
  }

  void _showFilterSheet(BuildContext context) {
    // Implement filter
  }
}

/// Header icon button widget
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 20,
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Quick stat card widget
class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            value,
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}