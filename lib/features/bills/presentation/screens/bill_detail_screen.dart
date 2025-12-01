import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../settings/presentation/widgets/formatting_widgets.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';
import '../widgets/edit_bill_bottom_sheet.dart';
import '../widgets/payment_recording_bottom_sheet.dart';

/// Screen for displaying detailed bill information and managing bill actions
class BillDetailScreen extends ConsumerStatefulWidget {
  const BillDetailScreen({
    super.key,
    required this.billId,
  });

  final String billId;

  @override
  ConsumerState<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends ConsumerState<BillDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final billAsync = ref.watch(billProvider(widget.billId));

    return Scaffold(
      appBar: AppBar(
        title: billAsync.when(
          data: (bill) => Text(bill?.name ?? 'Bill Details'),
          loading: () => const Text('Loading...'),
          error: (error, stack) => const Text('Bill Details'),
        ),
        actions: [
          billAsync.when(
            data: (bill) {
              if (bill == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, ref, bill, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit Bill'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Bill', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: billAsync.when(
        data: (bill) {
          if (bill == null) {
            return const Center(
              child: Text('Bill not found'),
            );
          }

          return _buildBillDetail(context, ref, bill);
        },
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(billProvider(widget.billId)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMarkAsPaidSheet(context, ref),
        tooltip: 'Mark as Paid',
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildBillDetail(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billNotifierProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        padding: AppTheme.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Status Card
            _buildBillStatusCard(context, bill),
            const SizedBox(height: 24),

            // Bill Information
            _buildBillInfo(context, bill),
            const SizedBox(height: 24),

            // Payment History
            _buildPaymentHistory(context, bill),
            const SizedBox(height: 16), // Add bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildBillStatusCard(BuildContext context, Bill bill) {
    final color = _getUrgencyColor(bill);
    final statusText = _getStatusText(bill);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                PrivacyModeAmount(
                  amount: bill.amount,
                  currency: '\$',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due Date',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SettingsDateText(
                  date: bill.dueDate,
                  format: 'MMM dd, yyyy',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            if (bill.daysUntilDue != 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Days Until Due',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${bill.daysUntilDue.abs()} days ${bill.isOverdue ? 'overdue' : 'remaining'}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: bill.isOverdue ? Colors.red : Colors.green,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillInfo(BuildContext context, Bill bill) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Name
            _buildInfoRow('Name', bill.name),

            // Amount
            Consumer(
              builder: (context, ref, child) {
                return _buildInfoRowWidget('Amount', PrivacyModeAmount(
                  amount: bill.amount,
                  currency: '\$',
                  style: Theme.of(context).textTheme.bodyMedium,
                ));
              },
            ),

            // Frequency
            _buildInfoRow('Frequency', bill.frequency.displayName),

            // Due Date
            Consumer(
              builder: (context, ref, child) {
                return _buildInfoRowWidget('Due Date', SettingsDateText(
                  date: bill.dueDate,
                  format: 'MMM dd, yyyy',
                  style: Theme.of(context).textTheme.bodyMedium,
                ));
              },
            ),

            // Next Due Date
            Consumer(
              builder: (context, ref, child) {
                return _buildInfoRowWidget('Next Due Date', SettingsDateText(
                  date: bill.calculatedNextDueDate,
                  format: 'MMM dd, yyyy',
                  style: Theme.of(context).textTheme.bodyMedium,
                ));
              },
            ),

            // Account Information
            if (bill.accountId != null) ...[
              Consumer(
                builder: (context, ref, child) {
                  final accountAsync = ref.watch(accountProvider(bill.accountId!));
                  return accountAsync.when(
                    data: (account) {
                      if (account == null) {
                        return _buildInfoRow('Account', 'Account not found');
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Linked Account',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(account.type.color).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Color(account.type.color),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.displayName,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${account.type.displayName} • ${account.formattedAvailableBalance}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      if (account.institution != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          account.institution!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (account.isBankConnected) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Connected',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Linked Account',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Loading account details...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    error: (error, stack) => _buildInfoRow('Account', 'Error loading account: $error'),
                  );
                },
              ),
            ] else ...[
              // No account linked
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_off,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Account Linked',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Link an account to enable automatic payments',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Payee
            if (bill.payee != null && bill.payee!.isNotEmpty)
              _buildInfoRow('Payee', bill.payee!),

            // Auto Pay - Prominent display
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bill.isAutoPay
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: bill.isAutoPay
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bill.isAutoPay
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      bill.isAutoPay ? Icons.autorenew : Icons.autorenew_outlined,
                      color: bill.isAutoPay
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto Pay',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: bill.isAutoPay
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bill.isAutoPay
                              ? 'This bill will be paid automatically when due'
                              : 'Auto pay is disabled for this bill',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (bill.isAutoPay && bill.accountId != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Linked to account for automatic payments',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (bill.isAutoPay) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Description
            if (bill.description != null && bill.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                bill.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Website
            if (bill.website != null && bill.website!.isNotEmpty)
              _buildInfoRow('Website', bill.website!),

            // Notes
            if (bill.notes != null && bill.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                bill.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWidget(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: value,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(BuildContext context, Bill bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to full payment history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full payment history - Coming soon!')),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (bill.paymentHistory.isEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payment history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment history will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          ...bill.paymentHistory.take(5).map((payment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  title: PrivacyModeAmount(
                    amount: payment.amount,
                    currency: '\$',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsDateText(
                        date: payment.paymentDate,
                        format: 'MMM dd, yyyy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (payment.notes != null && payment.notes!.isNotEmpty)
                        Text(payment.notes!),
                    ],
                  ),
                  trailing: Text(
                    payment.method.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              )),
        ],
      ],
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditBillSheet(context, ref, bill);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, bill);
        break;
    }
  }

  Future<void> _showMarkAsPaidSheet(BuildContext context, WidgetRef ref) async {
    final billAsync = ref.read(billProvider(widget.billId));
    final bill = billAsync.value;

    if (bill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill not found')),
      );
      return;
    }

    await PaymentRecordingBottomSheet.show(
      context: context,
      bill: bill,
      onPaymentRecorded: () {
        // Refresh the bill data
        ref.invalidate(billProvider(widget.billId));
        ref.read(billNotifierProvider.notifier).refresh();
      },
    );
  }

  Future<void> _showEditBillSheet(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: EditBillBottomSheet(
        bill: bill,
        onSubmit: (updatedBill) async {
          final success = await ref
              .read(billNotifierProvider.notifier)
              .updateBill(updatedBill);

          if (success && mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bill updated successfully')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update bill'),
                backgroundColor: Colors.red,
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
    Bill bill,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text(
          'Are you sure you want to delete "${bill.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(billNotifierProvider.notifier)
          .deleteBill(bill.id);

      if (success && mounted) {
        context.go('/more/bills'); // Go back to bills list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill deleted successfully')),
        );
      }
    }
  }

  Color _getUrgencyColor(Bill bill) {
    if (bill.isOverdue) return Colors.red;
    if (bill.isDueSoon) return Colors.orange;
    if (bill.isDueToday) return Colors.red;
    return Colors.green;
  }

  String _getStatusText(Bill bill) {
    if (bill.isPaid) return 'Paid';
    if (bill.isOverdue) return 'Overdue';
    if (bill.isDueToday) return 'Due Today';
    if (bill.isDueSoon) return 'Due Soon';
    return 'Upcoming';
  }
}