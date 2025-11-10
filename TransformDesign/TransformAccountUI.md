# Complete Account UI Transformation Guide - Modern Design System

## 📋 Overview

Transform account screens from basic cards to modern, gradient-rich UI matching the app's design language. This guide follows the same patterns established in the home dashboard and transaction screens.

---

## 🎯 Phase 1: Component Analysis & Mapping

### Current Account Components

**Existing Components:**
```
✓ AccountCard - Basic account display
✓ NetWorthCard - Simple net worth display
✓ AccountBalanceCard - Balance information
✓ AccountsOverviewScreen - List of accounts
✓ AccountDetailScreen - Individual account details
```

### Budget Screen Components Available for Reuse

**🔄 Reusable Components:**
```
1. CircularBudgetIndicator - For net worth visualization
2. DateSelectorPills - For date navigation
3. BudgetMetricCards - For financial metrics
4. BudgetStatsRow - For three-column stats
5. MiniTrendIndicator - For account trends
6. BudgetStatusBanner - For account status messages
```

### Transformation Mapping

| Current Component | Transform To | Enhancement |
|------------------|--------------|-------------|
| AccountCard | Gradient Card | ✅ Add gradient backgrounds, white text, icons |
| NetWorthCard | Circular Progress | ✅ Use CircularBudgetIndicator with stats |
| AccountBalanceCard | Enhanced Metrics | ✅ Add progress bars, trend indicators |
| AccountsOverviewScreen | Modern Dashboard | ✅ Quick actions, grouped sections |
| AccountDetailScreen | Rich Details | ✅ Enhanced sections, animations |

---

## 🎨 Phase 2: Enhanced Account Components

### 2.1 Enhanced Account Card

```dart
// lib/features/accounts/presentation/widgets/enhanced_account_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/account.dart';

/// Modern account card with gradient background and enhanced visuals
class EnhancedAccountCard extends StatelessWidget {
  const EnhancedAccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.lightImpact();
            onTap!();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            gradient: _getAccountGradient(account.type),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getAccountColor(account.type).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacing3),
                  
                  // Account Name & Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: AppTypographyExtended.statsValue.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.type.displayName,
                          style: AppTypographyExtended.metricLabel.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge (if inactive)
                  if (!account.isActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Inactive',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              SizedBox(height: AppDimensions.spacing4),
              
              // Balance Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: account.currentBalance),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        NumberFormat.currency(
                          symbol: '${account.currency} ',
                          decimalDigits: 2,
                        ).format(value),
                        style: AppTypographyExtended.circularProgressPercentage.copyWith(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // Credit Card Specific Info
              if (account.type == AccountType.creditCard && 
                  account.creditLimit != null) ...[
                SizedBox(height: AppDimensions.spacing3),
                _buildCreditUtilization(account),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditUtilization(Account account) {
    final utilization = account.utilizationRate ?? 0;
    final isHighUtilization = utilization > 30;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Credit Used',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            Text(
              '${utilization.toStringAsFixed(0)}%',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing1),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isHighUtilization 
                  ? Colors.red.shade300 
                  : Colors.white,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  LinearGradient _getAccountGradient(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetPrimary,
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
          ],
        );
      case AccountType.creditCard:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetSecondary,
            AppColorsExtended.budgetSecondary.withValues(alpha: 0.8),
          ],
        );
      case AccountType.loan:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.statusCritical,
            AppColorsExtended.statusCritical.withValues(alpha: 0.8),
          ],
        );
      case AccountType.investment:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.statusNormal,
            AppColorsExtended.statusNormal.withValues(alpha: 0.8),
          ],
        );
      case AccountType.manualAccount:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        );
    }
  }

  Color _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return AppColorsExtended.budgetPrimary;
      case AccountType.creditCard:
        return AppColorsExtended.budgetSecondary;
      case AccountType.loan:
        return AppColorsExtended.statusCritical;
      case AccountType.investment:
        return AppColorsExtended.statusNormal;
      case AccountType.manualAccount:
        return AppColors.primary;
    }
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.loan:
        return Icons.account_balance;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.manualAccount:
        return Icons.edit;
    }
  }
}
```

### 2.2 Modern Net Worth Card

```dart
// lib/features/accounts/presentation/widgets/modern_net_worth_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../budgets/presentation/widgets/circular_budget_indicator.dart';

/// Modern net worth card with circular indicator and enhanced visuals
class ModernNetWorthCard extends StatelessWidget {
  const ModernNetWorthCard({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
  });

  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;

  @override
  Widget build(BuildContext context) {
    final isPositive = netWorth >= 0;
    final percentage = totalAssets > 0 
        ? (totalAssets - totalLiabilities) / totalAssets 
        : 0.0;

    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPositive 
                      ? AppColorsExtended.statusNormal 
                      : AppColorsExtended.statusCritical).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: isPositive 
                      ? AppColorsExtended.statusNormal 
                      : AppColorsExtended.statusCritical,
                  size: 20,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Net Worth',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive 
                      ? AppColorsExtended.statusNormal 
                      : AppColorsExtended.statusCritical).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isPositive 
                          ? AppColorsExtended.statusNormal 
                          : AppColorsExtended.statusCritical,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPositive ? 'Positive' : 'Negative',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: isPositive 
                            ? AppColorsExtended.statusNormal 
                            : AppColorsExtended.statusCritical,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, duration: 400.ms),
          
          SizedBox(height: AppDimensions.spacing4),
          
          // Circular Indicator
          Center(
            child: CircularBudgetIndicator(
              percentage: percentage.clamp(0.0, 1.0),
              spent: totalLiabilities,
              total: totalAssets > 0 ? totalAssets : totalLiabilities,
              size: 200,
              strokeWidth: 20,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              duration: 600.ms,
              delay: 200.ms,
              curve: Curves.elasticOut,
            ),
          
          SizedBox(height: AppDimensions.spacing5),
          
          // Assets & Liabilities Row
          Row(
            children: [
              Expanded(
                child: _buildAmountColumn(
                  'Assets',
                  totalAssets,
                  Icons.trending_up,
                  AppColorsExtended.statusNormal,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideX(begin: -0.1, duration: 400.ms, delay: 400.ms),
              ),
              SizedBox(width: AppDimensions.spacing4),
              Expanded(
                child: _buildAmountColumn(
                  'Liabilities',
                  totalLiabilities,
                  Icons.trending_down,
                  AppColorsExtended.statusCritical,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .slideX(begin: 0.1, duration: 400.ms, delay: 500.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountColumn(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              SizedBox(width: AppDimensions.spacing1),
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing2),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: amount),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value),
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 18,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 2.3 Enhanced Account Overview Screen

```dart
// lib/features/accounts/presentation/screens/accounts_overview_screen_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/account_providers.dart';
import '../widgets/enhanced_account_card.dart';
import '../widgets/modern_net_worth_card.dart';
import '../widgets/add_edit_account_bottom_sheet.dart';

/// Enhanced Accounts Overview Screen with modern UI
class AccountsOverviewScreenEnhanced extends ConsumerWidget {
  const AccountsOverviewScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountNotifierProvider);
    final accountsByType = ref.watch(accountsByTypeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, ref),
            
            // Main Content
            Expanded(
              child: accountState.when(
                data: (state) => _buildBody(context, ref, state, accountsByType),
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.refresh(accountNotifierProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Accounts',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.add_rounded,
                color: AppColorsExtended.budgetPrimary,
              ),
              onPressed: () => _showAddAccountSheet(context, ref),
              tooltip: 'Add Account',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
    AsyncValue<Map<dynamic, List<dynamic>>> accountsByType,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(accountNotifierProvider.notifier).loadAccounts();
      },
      color: AppColorsExtended.budgetPrimary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Worth Card (Modern)
            ModernNetWorthCard(
              netWorth: state.netWorth,
              totalAssets: state.totalAssets,
              totalLiabilities: state.totalLiabilities,
            ).animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic),
            
            SizedBox(height: AppDimensions.sectionGap),

            // Quick Actions Section
            _buildQuickActionsSection(context, ref).animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.1, duration: 400.ms, delay: 100.ms),

            SizedBox(height: AppDimensions.sectionGap),

            // Accounts by Type
            accountsByType.when(
              data: (accountsMap) => _buildAccountsList(context, ref, accountsMap),
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  size: 20,
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'Quick Actions',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Account',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetPrimary,
                      AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () => _showAddAccountSheet(context, ref),
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.link,
                  label: 'Connect Bank',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetSecondary,
                      AppColorsExtended.budgetSecondary.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () {
                    context.push('/more/accounts/bank-connection');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(
    BuildContext context,
    WidgetRef ref,
    Map<dynamic, List<dynamic>> accountsByType,
  ) {
    if (accountsByType.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    final widgets = <Widget>[];
    int index = 0;

    for (final entry in accountsByType.entries) {
      final accountType = entry.key;
      final accounts = entry.value;

      // Section Header
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spacing3),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _getTypeColor(accountType),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                accountType.displayName,
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(accountType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${accounts.length}',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: _getTypeColor(accountType),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index++))
          .slideX(begin: -0.1, duration: 300.ms),
      );

      // Account Cards
      for (final account in accounts) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacing3),
            child: EnhancedAccountCard(
              account: account,
              onTap: () {
                context.push('/more/accounts/${account.id}');
              },
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * index++))
            .slideY(begin: 0.1, duration: 400.ms),
        );
      }

      widgets.add(SizedBox(height: AppDimensions.spacing4));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
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
            'No accounts yet',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Add your first account to start\ntracking your finances',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),
          SizedBox(height: AppDimensions.spacing5),
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorsExtended.budgetPrimary,
                  AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),```dart
              boxShadow: [
                BoxShadow(
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddAccountSheet(context, ref),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add Account',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Color _getTypeColor(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return AppColorsExtended.budgetPrimary;
      case AccountType.creditCard:
        return AppColorsExtended.budgetSecondary;
      case AccountType.loan:
        return AppColorsExtended.statusCritical;
      case AccountType.investment:
        return AppColorsExtended.statusNormal;
      case AccountType.manualAccount:
        return AppColors.primary;
    }
  }

  Future<void> _showAddAccountSheet(BuildContext context, WidgetRef ref) async {
    await AppBottomSheet.show(
      context: context,
      child: AddEditAccountBottomSheet(
        onSubmit: (account) async {
          final success = await ref
              .read(accountNotifierProvider.notifier)
              .createAccount(account);

          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account added successfully'),
                backgroundColor: AppColorsExtended.statusNormal,
              ),
            );
          }
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(height: AppDimensions.spacing2),
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.4 Enhanced Account Detail Screen

```dart
// lib/features/accounts/presentation/screens/account_detail_screen_enhanced.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/enhanced_transaction_tile.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';
import '../widgets/add_edit_account_bottom_sheet.dart';

/// Enhanced Account Detail Screen with modern UI
class AccountDetailScreenEnhanced extends ConsumerWidget {
  const AccountDetailScreenEnhanced({
    super.key,
    required this.accountId,
  });

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountProvider(accountId));
    final accountTransactionsAsync = ref.watch(accountTransactionsProvider(accountId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: accountAsync.when(
          data: (account) {
            if (account == null) {
              return Center(
                child: Text(
                  'Account not found',
                  style: AppTypographyExtended.statsValue,
                ),
              );
            }

            return _buildAccountDetail(context, ref, account, accountTransactionsAsync);
          },
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.refresh(accountProvider(accountId)),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetail(
    BuildContext context,
    WidgetRef ref,
    Account account,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar
        _buildAppBar(context, ref, account),
        
        // Main Content
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Card
                _buildAccountCard(context, account).animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: AppDimensions.sectionGap),

                // Balance Visualization
                _buildBalanceVisualization(context, account).animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 100.ms),

                SizedBox(height: AppDimensions.sectionGap),

                // Quick Actions
                _buildQuickActions(context, account).animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms),

                SizedBox(height: AppDimensions.sectionGap),

                // Account Information
                _buildAccountInfo(context, account).animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 300.ms),

                SizedBox(height: AppDimensions.sectionGap),

                // Transaction History
                _buildTransactionHistory(context, transactionsAsync).animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms),

                SizedBox(height: AppDimensions.spacing8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, Account account) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Text(
        account.name,
        style: AppTypographyExtended.statsValue.copyWith(
          fontSize: 18,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, ref, account, value),
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: AppColorsExtended.budgetPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit Account'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: AppColorsExtended.statusCritical,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delete Account',
                    style: TextStyle(color: AppColorsExtended.statusCritical),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: _getAccountGradient(account.type),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getAccountColor(account.type).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Type and Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getAccountTypeIcon(account.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: AppTypographyExtended.statsValue.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.type.displayName,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacing4),

          // Balance
          Text(
            'Current Balance',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: account.currentBalance),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${account.currency} ${value.toStringAsFixed(2)}',
                style: AppTypographyExtended.circularProgressPercentage.copyWith(
                  fontSize: 32,
                  color: Colors.white,
                ),
              );
            },
          ),

          // Account Status
          if (!account.isActive) ...[
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Inactive',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceVisualization(BuildContext context, Account account) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insights,
                  size: 20,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'Balance Overview',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          // Balance Progress (for credit cards and loans)
          if (account.type == AccountType.creditCard && account.creditLimit != null) ...[
            _buildBalanceProgress(account),
            SizedBox(height: AppDimensions.spacing4),
          ],

          // Balance Stats
          Row(
            children: [
              Expanded(
                child: _buildBalanceStat(
                  'Available',
                  '${account.currency} ${account.availableBalance.toStringAsFixed(2)}',
                  AppColorsExtended.statusNormal,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: _buildBalanceStat(
                  'Used',
                  '${account.currency} ${(account.currentBalance - account.availableBalance).abs().toStringAsFixed(2)}',
                  AppColorsExtended.statusWarning,
                ),
              ),
            ],
          ),

          // Credit utilization for credit cards
          if (account.type == AccountType.creditCard && account.utilizationRate != null) ...[
            SizedBox(height: AppDimensions.spacing4),
            _buildUtilizationSection(account),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceProgress(Account account) {
    final usedAmount = account.creditLimit! - (account.availableCredit ?? 0);
    final utilizationRate = account.utilizationRate ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Credit Used',
              style: AppTypographyExtended.metricLabel.copyWith(
                fontSize: 13,
              ),
            ),
            Text(
              '${account.currency} ${usedAmount.toStringAsFixed(2)} / ${account.currency} ${account.creditLimit!.toStringAsFixed(2)}',
              style: AppTypographyExtended.metricLabel.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: utilizationRate / 100,
            backgroundColor: AppColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(
              utilizationRate > 30 
                  ? AppColorsExtended.statusCritical 
                  : AppColorsExtended.statusNormal,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceStat(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
          SizedBox(height: AppDimensions.spacing1),
          Text(
            value,
            style: AppTypographyExtended.statsValue.copyWith(
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizationSection(Account account) {
    final utilization = account.utilizationRate!;
    final isHigh = utilization > 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Credit Utilization',
              style: AppTypographyExtended.metricLabel.copyWith(
                fontSize: 13,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isHigh 
                    ? AppColorsExtended.statusCritical 
                    : AppColorsExtended.statusNormal).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${utilization.toStringAsFixed(1)}%',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: isHigh 
                      ? AppColorsExtended.statusCritical 
                      : AppColorsExtended.statusNormal,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: AppColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(
              isHigh 
                  ? AppColorsExtended.statusCritical 
                  : AppColorsExtended.statusNormal,
            ),
            minHeight: 8,
          ),
        ),
        if (isHigh) ...[
          SizedBox(height: AppDimensions.spacing2),
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: AppColorsExtended.statusCritical,
              ),
              SizedBox(width: AppDimensions.spacing1),
              Expanded(
                child: Text(
                  'High utilization may affect your credit score',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColorsExtended.statusCritical,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Account account) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  size: 20,
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'Quick Actions',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Transaction',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetPrimary,
                      AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () => _addTransaction(context),
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Transfer',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetSecondary,
                      AppColorsExtended.budgetSecondary.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () => _transferMoney(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.receipt_long,
                  label: 'View Statement',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.statusNormal,
                      AppColorsExtended.statusNormal.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () => _viewStatement(context),
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.share,
                  label: 'Share Details',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () => _shareAccountDetails(context, account),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, Account account) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'Account Information',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          // Account Type
          _buildInfoRow('Type', account.type.displayName),

          // Institution
          if (account.institution != null)
            _buildInfoRow('Institution', account.institution!),

          // Account Number
          if (account.accountNumber != null)
            _buildInfoRow('Account Number', account.accountNumber!),

          // Currency
          _buildInfoRow('Currency', account.currency),

          // Status
          _buildInfoRow('Status', account.isActive ? 'Active' : 'Inactive'),

          // Created Date
          if (account.createdAt != null)
            _buildInfoRow(
              'Created',
              DateFormat('MMM dd, yyyy').format(account.createdAt!),
            ),

          // Description
          if (account.description != null && account.description!.isNotEmpty) ...[
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              decoration: BoxDecoration(
                color: AppColorsExtended.pillBgUnselected,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: AppTypographyExtended.metricLabel.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing1),
                  Text(
                    account.description!,
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Type-specific information
          ..._buildTypeSpecificInfo(context, account),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypographyExtended.metricLabel.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeSpecificInfo(BuildContext context, Account account) {
    switch (account.type) {
      case AccountType.creditCard:
        if (account.creditLimit != null) {
          return [
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              decoration: BoxDecoration(
                color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 16,
                        color: AppColorsExtended.budgetSecondary,
                      ),
                      SizedBox(width: AppDimensions.spacing1),
                      Text(
                        'Credit Card Details',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColorsExtended.budgetSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacing2),
                  _buildInfoRow(
                    'Credit Limit',
                    '${account.currency} ${account.creditLimit!.toStringAsFixed(2)}',
                  ),```dart
                  if (account.availableCredit != null)
                    _buildInfoRow(
                      'Available Credit',
                      '${account.currency} ${account.availableCredit!.toStringAsFixed(2)}',
                    ),

                  if (account.minimumPayment != null)
                    _buildInfoRow(
                      'Minimum Payment',
                      '${account.currency} ${account.minimumPayment!.toStringAsFixed(2)}',
                    ),
                ],
              ),
            ),
          ];
        }
        return [];

      case AccountType.loan:
        if (account.interestRate != null || account.minimumPayment != null) {
          return [
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              decoration: BoxDecoration(
                color: AppColorsExtended.statusCritical.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColorsExtended.statusCritical.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 16,
                        color: AppColorsExtended.statusCritical,
                      ),
                      SizedBox(width: AppDimensions.spacing1),
                      Text(
                        'Loan Details',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColorsExtended.statusCritical,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacing2),
                  if (account.interestRate != null)
                    _buildInfoRow(
                      'Interest Rate',
                      '${account.interestRate!.toStringAsFixed(2)}%',
                    ),

                  if (account.minimumPayment != null)
                    _buildInfoRow(
                      'Monthly Payment',
                      '${account.currency} ${account.minimumPayment!.toStringAsFixed(2)}',
                    ),
                ],
              ),
            ),
          ];
        }
        return [];

      default:
        return [];
    }
  }

  Widget _buildTransactionHistory(
    BuildContext context,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history,
                  size: 20,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return _buildEmptyTransactions();
              }

              // Show only recent 10 transactions
              final recentTransactions = transactions.take(10).toList();

              return Column(
                children: [
                  ...recentTransactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final transaction = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < recentTransactions.length - 1 
                            ? AppDimensions.spacing2 
                            : 0,
                      ),
                      child: EnhancedTransactionTile(transaction: transaction),
                    );
                  }),
                  SizedBox(height: AppDimensions.spacing3),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate to full transaction list for this account
                          context.go('/transactions');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All Transactions',
                                style: AppTypographyExtended.metricLabel.copyWith(
                                  color: AppColorsExtended.budgetPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppColorsExtended.budgetPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Failed to load transactions',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColorsExtended.statusCritical,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColorsExtended.budgetPrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
          SizedBox(height: AppDimensions.spacing3),
          Text(
            'No transactions yet',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 16,
            ),
          ),
          SizedBox(height: AppDimensions.spacing1),
          Text(
            'Transactions for this account\nwill appear here',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LinearGradient _getAccountGradient(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetPrimary,
            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
          ],
        );
      case AccountType.creditCard:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.budgetSecondary,
            AppColorsExtended.budgetSecondary.withValues(alpha: 0.8),
          ],
        );
      case AccountType.loan:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.statusCritical,
            AppColorsExtended.statusCritical.withValues(alpha: 0.8),
          ],
        );
      case AccountType.investment:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsExtended.statusNormal,
            AppColorsExtended.statusNormal.withValues(alpha: 0.8),
          ],
        );
      case AccountType.manualAccount:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        );
    }
  }

  Color _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return AppColorsExtended.budgetPrimary;
      case AccountType.creditCard:
        return AppColorsExtended.budgetSecondary;
      case AccountType.loan:
        return AppColorsExtended.statusCritical;
      case AccountType.investment:
        return AppColorsExtended.statusNormal;
      case AccountType.manualAccount:
        return AppColors.primary;
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.loan:
        return Icons.account_balance;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.manualAccount:
        return Icons.edit;
    }
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    Account account,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditAccountSheet(context, ref, account);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, account);
        break;
    }
  }

  Future<void> _showEditAccountSheet(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: AddEditAccountBottomSheet(
        account: account,
        onSubmit: (updatedAccount) async {
          final success = await ref
              .read(accountNotifierProvider.notifier)
              .updateAccount(updatedAccount);

          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account updated successfully'),
                backgroundColor: AppColorsExtended.statusNormal,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorsExtended.statusCritical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_forever,
                color: AppColorsExtended.statusCritical,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Account',
              style: AppTypographyExtended.statsValue.copyWith(
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${account.name}"? This action cannot be undone.',
              style: AppTypographyExtended.metricLabel.copyWith(
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing3),
              decoration: BoxDecoration(
                color: AppColorsExtended.statusCritical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColorsExtended.statusCritical,
                    size: 18,
                  ),
                  SizedBox(width: AppDimensions.spacing2),
                  Expanded(
                    child: Text(
                      'All associated transactions will remain in your history.',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColorsExtended.statusCritical,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColorsExtended.pillBgUnselected,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, false),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorsExtended.statusCritical,
                        AppColorsExtended.statusCritical.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorsExtended.statusCritical.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, true),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.delete_forever, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: AppTypographyExtended.metricLabel.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(accountNotifierProvider.notifier)
          .deleteAccount(account.id);

      if (success && context.mounted) {
        context.go('/more/accounts'); // Go back to accounts list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: AppColorsExtended.statusNormal,
          ),
        );
      }
    }
  }

  void _addTransaction(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add transaction - Coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _transferMoney(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transfer money - Coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _viewStatement(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('View statement - Coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _shareAccountDetails(BuildContext context, Account account) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${account.name} details...'),
        backgroundColor: AppColorsExtended.statusNormal,
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(height: AppDimensions.spacing2),
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 📋 Phase 3: Implementation Summary

### Files Created

1. **`enhanced_account_card.dart`** - Modern gradient account card
2. **`modern_net_worth_card.dart`** - Circular net worth visualization
3. **`accounts_overview_screen_enhanced.dart`** - Enhanced overview screen
4. **`account_detail_screen_enhanced.dart`** - Enhanced detail screen

### Files Modified

- Update imports in existing routing/navigation files
- Replace old widgets with enhanced versions

### Key Visual Enhancements

✅ **Gradient Backgrounds** - All primary cards use gradients with colored shadows
✅ **White Text on Colors** - High contrast text on gradient backgrounds
✅ **Icon Containers** - Semi-transparent backgrounds for icons
✅ **Progress Indicators** - Enhanced progress bars with proper styling
✅ **Staggered Animations** - Sequential fade-in and slide effects
✅ **Circular Visualization** - Net worth displayed with circular progress
✅ **Quick Actions** - Gradient action buttons with icons
✅ **Info Cards** - Organized sections with consistent styling
✅ **Empty States** - Beautiful empty states with icons and CTAs

### Animation Patterns Used

```dart
// Standard card animation
.animate()
  .fadeIn(duration: 400.ms, delay: XXXms)
  .slideY(begin: 0.1, duration: 400.ms, delay: XXXms)

// List item staggered animation
.animate()
  .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index))
  .slideX(begin: -0.1, duration: 300.ms)

// Hero element animation
.animate()
  .fadeIn(duration: 500.ms)
  .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic)
```

### Color Mapping

| Account Type | Primary Color | Usage |
|--------------|---------------|-------|
| Bank Account | `AppColorsExtended.budgetPrimary` | Teal gradient |
| Credit Card | `AppColorsExtended.budgetSecondary` | Purple gradient |
| Loan | `AppColorsExtended.statusCritical` | Red gradient |
| Investment | `AppColorsExtended.statusNormal` | Green gradient |
| Manual | `AppColors.primary` | Blue gradient |

### Integration Steps

1. **Create new widget files** in `lib/features/accounts/presentation/widgets/`
2. **Create enhanced screen files** in `lib/features/accounts/presentation/screens/`
3. **Update routing** to use enhanced screens
4. **Test animations** on different devices
5. **Verify accessibility** (contrast ratios, touch targets)
6. **Test performance** (60fps maintained)

### Testing Checklist

- [ ] All account types display correctly
- [ ] Gradients render smoothly
- [ ] Animations perform at 60fps
- [ ] Touch targets meet 48x48dp minimum
- [ ] Text contrast meets WCAG AA standards
- [ ] Loading states work correctly
- [ ] Error states display properly
- [ ] Empty states show appropriate CTAs
- [ ] Quick actions trigger correct functions
- [ ] Navigation works between screens
- [ ] Delete confirmation works
- [ ] Edit account flow works
- [ ] Transactions load and display
- [ ] Credit utilization displays correctly
- [ ] Loan details display correctly

---

## 🎯 Final Notes

This transformation brings account screens to the same modern design language as the home dashboard and transaction screens. All components follow consistent patterns for:

- **Visual hierarchy** - Important information stands out
- **Color usage** - Semantic colors for different states
- **Spacing** - Consistent padding and gaps
- **Typography** - Clear size and weight hierarchy
- **Animations** - Smooth, purposeful motion
- **Interactions** - Haptic feedback and visual responses

The design system ensures maintainability and scalability across the entire app.