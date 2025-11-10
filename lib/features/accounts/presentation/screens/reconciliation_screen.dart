import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/info_card_pattern.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';

/// Enhanced account reconciliation screen
/// Allows users to manually reconcile account balances against bank statements
/// with discrepancy detection and resolution tools
class ReconciliationScreen extends ConsumerStatefulWidget {
  const ReconciliationScreen({
    super.key,
    required this.accountId,
  });

  final String accountId;

  @override
  ConsumerState<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends ConsumerState<ReconciliationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Reconciliation state
  double? _statementBalance;
  DateTime? _statementDate;
  bool _isReconciling = false;
  String? _reconciliationNotes;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: DesignTokens.curveEaseOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountProvider(widget.accountId));
    final accountTransactionsAsync = ref.watch(accountTransactionsProvider(widget.accountId));

    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: _buildAppBar(context, accountAsync),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: accountAsync.when(
          data: (account) {
            if (account == null) {
              return const Center(
                child: Text('Account not found'),
              );
            }

            return _buildReconciliationContent(context, ref, account, accountTransactionsAsync);
          },
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.refresh(accountProvider(widget.accountId)),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AsyncValue<Account?> accountAsync) {
    return AppBar(
      backgroundColor: ColorTokens.surfacePrimary,
      elevation: 0,
      title: accountAsync.when(
        data: (account) => Text(
          'Reconcile ${account?.name ?? 'Account'}',
          style: TypographyTokens.heading3,
        ),
        loading: () => Text(
          'Loading...',
          style: TypographyTokens.heading3,
        ),
        error: (error, stack) => Text(
          'Reconciliation',
          style: TypographyTokens.heading3,
        ),
      ),
      actions: [
        accountAsync.when(
          data: (account) {
            if (account == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showReconciliationHelp(context),
              tooltip: 'Reconciliation Help',
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildReconciliationContent(
    BuildContext context,
    WidgetRef ref,
    Account account,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(accountNotifierProvider.notifier).loadAccounts(),
          ref.read(transactionNotifierProvider.notifier).loadTransactions(),
        ]);
      },
      color: ColorTokens.teal500,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Comparison Section
            Semantics(
              label: 'Balance comparison section',
              child: _buildBalanceComparison(context, account).animate()
                .fadeIn(duration: DesignTokens.durationNormal)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Statement Balance Input
            Semantics(
              label: 'Statement balance input section',
              child: _buildStatementBalanceInput(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Discrepancy Analysis
            if (_statementBalance != null)
              Semantics(
                label: 'Discrepancy analysis section',
                child: _buildDiscrepancyAnalysis(context, account).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
              ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Unreconciled Transactions
            Semantics(
              label: 'Unreconciled transactions section',
              child: _buildUnreconciledTransactions(context, transactionsAsync).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Reconciliation Actions
            Semantics(
              label: 'Reconciliation actions section',
              child: _buildReconciliationActions(context, ref, account).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),
            ),

            SizedBox(height: DesignTokens.spacing8),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceComparison(BuildContext context, Account account) {
    return InfoCardPattern(
      title: 'Balance Comparison',
      icon: Icons.compare_arrows,
      iconColor: ColorTokens.teal500,
      children: [
        // App Balance
        _buildBalanceRow(
          'App Balance',
          '${account.currency ?? 'USD'} ${account.currentBalance.toStringAsFixed(2)}',
          'Current balance in the app',
          ColorTokens.teal500,
        ),

        SizedBox(height: DesignTokens.spacing3),

        // Statement Balance
        _buildBalanceRow(
          'Statement Balance',
          _statementBalance != null
              ? '${account.currency ?? 'USD'} ${_statementBalance!.toStringAsFixed(2)}'
              : 'Not entered',
          'Balance from your bank statement',
          _statementBalance != null ? ColorTokens.success500 : ColorTokens.neutral500,
        ),

        // Discrepancy
        if (_statementBalance != null) ...[
          SizedBox(height: DesignTokens.spacing3),
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: _getDiscrepancyColor(account).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  _getDiscrepancyIcon(account),
                  color: _getDiscrepancyColor(account),
                  size: DesignTokens.iconMd,
                ),
                SizedBox(width: DesignTokens.spacing2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Difference',
                        style: TypographyTokens.labelMd.copyWith(
                          color: _getDiscrepancyColor(account),
                        ),
                      ),
                      Text(
                        '${account.currency ?? 'USD'} ${account.balanceDiscrepancy?.abs().toStringAsFixed(2) ?? '0.00'}',
                        style: TypographyTokens.numericMd.copyWith(
                          color: _getDiscrepancyColor(account),
                          fontWeight: TypographyTokens.weightSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBalanceRow(String label, String value, String subtitle, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TypographyTokens.labelMd,
              ),
              SizedBox(height: DesignTokens.spacing1),
              Text(
                subtitle,
                style: TypographyTokens.captionMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TypographyTokens.numericLg.copyWith(
            color: color,
            fontWeight: TypographyTokens.weightSemiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatementBalanceInput(BuildContext context) {
    return InfoCardPattern(
      title: 'Enter Statement Balance',
      icon: Icons.edit,
      iconColor: ColorTokens.info500,
      children: [
        // Balance Input
        TextFormField(
          initialValue: _statementBalance?.toStringAsFixed(2),
          decoration: InputDecoration(
            labelText: 'Statement Balance',
            hintText: 'Enter balance from your bank statement',
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            setState(() {
              _statementBalance = double.tryParse(value);
            });
          },
        ),

        SizedBox(height: DesignTokens.spacing3),

        // Statement Date
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _statementDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) {
              setState(() {
                _statementDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Statement Date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _statementDate != null
                      ? DateFormat('MMM dd, yyyy').format(_statementDate!)
                      : 'Select date',
                  style: TypographyTokens.bodyMd,
                ),
                Icon(
                  Icons.calendar_today,
                  color: ColorTokens.teal500,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: DesignTokens.spacing3),

        // Notes
        TextFormField(
          initialValue: _reconciliationNotes,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Add any notes about this reconciliation',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _reconciliationNotes = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDiscrepancyAnalysis(BuildContext context, Account account) {
    final discrepancy = account.balanceDiscrepancy ?? 0.0;
    final isDiscrepancy = discrepancy.abs() > 0.01;

    return InfoCardPattern(
      title: 'Discrepancy Analysis',
      icon: isDiscrepancy ? Icons.warning : Icons.check_circle,
      iconColor: isDiscrepancy ? ColorTokens.warning500 : ColorTokens.success500,
      children: [
        if (isDiscrepancy) ...[
          Text(
            'There is a discrepancy between your app balance and statement balance.',
            style: TypographyTokens.bodyMd,
          ),
          SizedBox(height: DesignTokens.spacing3),
          Text(
            'Possible causes:',
            style: TypographyTokens.labelMd,
          ),
          SizedBox(height: DesignTokens.spacing2),
          _buildCauseItem('Outstanding transactions not yet recorded in the app'),
          _buildCauseItem('Bank fees or interest not accounted for'),
          _buildCauseItem('Timing differences in transaction processing'),
          _buildCauseItem('Data entry errors'),
        ] else ...[
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: ColorTokens.success500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: ColorTokens.success500,
                ),
                SizedBox(width: DesignTokens.spacing2),
                Expanded(
                  child: Text(
                    'Balances match! Your account is reconciled.',
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.success500,
                      fontWeight: TypographyTokens.weightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCauseItem(String cause) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacing1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TypographyTokens.bodyMd),
          Expanded(
            child: Text(
              cause,
              style: TypographyTokens.bodyMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreconciledTransactions(
    BuildContext context,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    return InfoCardPattern(
      title: 'Recent Transactions',
      icon: Icons.history,
      iconColor: ColorTokens.neutral600,
      children: [
        transactionsAsync.when(
          data: (transactions) {
            final recentTransactions = transactions
                .where((t) => t.date.isAfter(DateTime.now().subtract(const Duration(days: 30))))
                .take(10)
                .toList();

            if (recentTransactions.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing4),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: ColorTokens.neutral500,
                    ),
                    SizedBox(height: DesignTokens.spacing3),
                    Text(
                      'No recent transactions',
                      style: TypographyTokens.heading6,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: recentTransactions.map((transaction) {
                return Padding(
                  padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.description ?? 'No description',
                              style: TypographyTokens.bodyMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('MMM dd').format(transaction.date),
                              style: TypographyTokens.captionMd.copyWith(
                                color: ColorTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${transaction.amount >= 0 ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
                        style: TypographyTokens.numericMd.copyWith(
                          color: transaction.amount >= 0
                              ? ColorTokens.success500
                              : ColorTokens.critical500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Failed to load transactions: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildReconciliationActions(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    final canReconcile = _statementBalance != null;
    final hasDiscrepancy = (account.balanceDiscrepancy?.abs() ?? 0) > 0.01;

    return InfoCardPattern(
      title: 'Reconciliation Actions',
      icon: Icons.build,
      iconColor: ColorTokens.warning500,
      children: [
        // Auto Reconcile Button
        ActionButtonPattern(
          label: 'Auto Reconcile',
          icon: Icons.sync,
          variant: canReconcile ? ButtonVariant.primary : ButtonVariant.secondary,
          size: ButtonSize.medium,
          isFullWidth: true,
          isLoading: _isReconciling,
          onPressed: canReconcile && !_isReconciling
              ? () => _performAutoReconciliation(context, ref, account)
              : null,
        ),

        SizedBox(height: DesignTokens.spacing3),

        // Manual Adjustment Button
        if (hasDiscrepancy)
          ActionButtonPattern(
            label: 'Manual Adjustment',
            icon: Icons.edit,
            variant: ButtonVariant.secondary,
            size: ButtonSize.medium,
            isFullWidth: true,
            onPressed: () => _showManualAdjustmentDialog(context, ref, account),
          ),

        SizedBox(height: DesignTokens.spacing3),

        // Mark as Reconciled Button
        ActionButtonPattern(
          label: 'Mark as Reconciled',
          icon: Icons.check_circle,
          variant: ButtonVariant.primary,
          size: ButtonSize.medium,
          isFullWidth: true,
          onPressed: canReconcile ? () => _markAsReconciled(context, ref, account) : null,
        ),
      ],
    );
  }

  Color _getDiscrepancyColor(Account account) {
    final discrepancy = account.balanceDiscrepancy?.abs() ?? 0.0;
    if (discrepancy > 10.0) return ColorTokens.critical500;
    if (discrepancy > 0.01) return ColorTokens.warning500;
    return ColorTokens.success500;
  }

  IconData _getDiscrepancyIcon(Account account) {
    final discrepancy = account.balanceDiscrepancy?.abs() ?? 0.0;
    if (discrepancy > 10.0) return Icons.error;
    if (discrepancy > 0.01) return Icons.warning;
    return Icons.check_circle;
  }

  Future<void> _performAutoReconciliation(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    setState(() {
      _isReconciling = true;
    });

    try {
      final reconcileUseCase = ref.read(core_providers.reconcileAccountBalanceProvider);
      final result = await reconcileUseCase(account.id);

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account reconciled successfully'),
              backgroundColor: ColorTokens.success500,
            ),
          );
          // Refresh data
          ref.invalidate(accountProvider(widget.accountId));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reconciliation failed: ${result.failureOrNull}'),
              backgroundColor: ColorTokens.critical500,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during reconciliation: $e'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReconciling = false;
        });
      }
    }
  }

  Future<void> _showManualAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final discrepancy = account.balanceDiscrepancy ?? 0.0;
    double adjustmentAmount = discrepancy;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorTokens.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Text(
          'Manual Balance Adjustment',
          style: TypographyTokens.heading5,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current discrepancy: ${account.currency ?? 'USD'} ${discrepancy.abs().toStringAsFixed(2)}',
              style: TypographyTokens.bodyMd,
            ),
            SizedBox(height: DesignTokens.spacing3),
            TextFormField(
              initialValue: adjustmentAmount.toStringAsFixed(2),
              decoration: InputDecoration(
                labelText: 'Adjustment Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                adjustmentAmount = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TypographyTokens.buttonMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Adjust',
              style: TypographyTokens.buttonMd.copyWith(
                color: ColorTokens.teal500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && adjustmentAmount != 0.0) {
      // Update account balance
      final updatedBalance = account.cachedBalance! + adjustmentAmount;
      final updatedAccount = account.copyWith(
        cachedBalance: updatedBalance,
        lastBalanceUpdate: DateTime.now(),
      );

      final success = await ref
          .read(accountNotifierProvider.notifier)
          .updateAccount(updatedAccount);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Balance adjusted successfully'),
            backgroundColor: ColorTokens.success500,
          ),
        );
        ref.invalidate(accountProvider(widget.accountId));
      }
    }
  }

  Future<void> _markAsReconciled(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorTokens.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Text(
          'Mark as Reconciled',
          style: TypographyTokens.heading5,
        ),
        content: Text(
          'This will mark the account as reconciled with the entered statement balance, even if there are discrepancies. Continue?',
          style: TypographyTokens.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TypographyTokens.buttonMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Mark Reconciled',
              style: TypographyTokens.buttonMd.copyWith(
                color: ColorTokens.teal500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedAccount = account.copyWith(
        reconciledBalance: _statementBalance,
        lastReconciliation: DateTime.now(),
      );

      final success = await ref
          .read(accountNotifierProvider.notifier)
          .updateAccount(updatedAccount);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account marked as reconciled'),
            backgroundColor: ColorTokens.success500,
          ),
        );
        ref.invalidate(accountProvider(widget.accountId));
      }
    }
  }

  void _showReconciliationHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorTokens.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Text(
          'Reconciliation Help',
          style: TypographyTokens.heading5,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account reconciliation ensures your app balances match your bank statements.',
                style: TypographyTokens.bodyMd,
              ),
              SizedBox(height: DesignTokens.spacing3),
              Text(
                'Steps:',
                style: TypographyTokens.labelMd,
              ),
              SizedBox(height: DesignTokens.spacing2),
              _buildHelpItem('1. Enter your statement balance and date'),
              _buildHelpItem('2. Review any discrepancies'),
              _buildHelpItem('3. Check recent transactions'),
              _buildHelpItem('4. Use auto reconcile or manual adjustment'),
              _buildHelpItem('5. Mark as reconciled when done'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TypographyTokens.buttonMd.copyWith(
                color: ColorTokens.teal500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacing1),
      child: Text(
        text,
        style: TypographyTokens.bodyMd.copyWith(
          color: ColorTokens.textSecondary,
        ),
      ),
    );
  }
}