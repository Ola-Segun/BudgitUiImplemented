import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';
import '../widgets/edit_recurring_income_bottom_sheet.dart';
import '../widgets/receipt_recording_bottom_sheet.dart';

/// Detail screen for viewing and managing a specific recurring income
class RecurringIncomeDetailScreen extends ConsumerStatefulWidget {
  const RecurringIncomeDetailScreen({
    super.key,
    required this.incomeId,
  });

  final String incomeId;

  @override
  ConsumerState<RecurringIncomeDetailScreen> createState() => _RecurringIncomeDetailScreenState();
}

class _RecurringIncomeDetailScreenState extends ConsumerState<RecurringIncomeDetailScreen> {
  RecurringIncome? _income;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  Future<void> _loadIncome() async {
    final incomeState = ref.read(recurringIncomeNotifierProvider);
    final incomes = incomeState.maybeWhen(
      loaded: (incomes, summary) => incomes,
      orElse: () => <RecurringIncome>[],
    );

    final income = incomes.firstWhere(
      (inc) => inc.id == widget.incomeId,
      orElse: () => throw Exception('Income not found'),
    );

    if (mounted) {
      setState(() {
        _income = income;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Income Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_income == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Income Details')),
        body: const Center(
          child: Text('Income not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => EditRecurringIncomeBottomSheet.show(context, incomeId: _income!.id),
            tooltip: 'Edit Income',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Delete Income',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppTheme.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income Header
            _buildIncomeHeader(),
            const SizedBox(height: 24),

            // Income Details
            _buildIncomeDetails(),
            const SizedBox(height: 24),

            // Account Information
            _buildAccountInformation(),
            const SizedBox(height: 24),

            // Income History
            _buildIncomeHistory(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeHeader() {
    final income = _income!;
    final isActive = !income.hasEnded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    income.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Ended',
                    style: TextStyle(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${income.amount.toStringAsFixed(2)} • ${income.frequency.displayName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (income.description != null) ...[
              const SizedBox(height: 8),
              Text(
                income.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeDetails() {
    final income = _income!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Frequency', income.frequency.displayName),
            _buildDetailRow('Start Date', DateFormat('MMM dd, yyyy').format(income.startDate)),
            if (income.nextExpectedDate != null)
              _buildDetailRow('Next Expected Date', DateFormat('MMM dd, yyyy').format(income.nextExpectedDate!)),
            if (income.endDate != null)
              _buildDetailRow('End Date', DateFormat('MMM dd, yyyy').format(income.endDate!)),
            if (income.payer != null)
              _buildDetailRow('Payer', income.payer!),
            if (income.website != null)
              _buildDetailRow('Website', income.website!),
            if (income.notes != null)
              _buildDetailRow('Notes', income.notes!),
            if (income.isVariableAmount) ...[
              _buildDetailRow('Amount Type', 'Variable'),
              if (income.minAmount != null)
                _buildDetailRow('Min Amount', '\$${income.minAmount!.toStringAsFixed(2)}'),
              if (income.maxAmount != null)
                _buildDetailRow('Max Amount', '\$${income.maxAmount!.toStringAsFixed(2)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInformation() {
    return Consumer(
      builder: (context, ref, child) {
        final accountsAsync = ref.watch(filteredAccountsProvider);

        return accountsAsync.when(
          data: (accounts) {
            final income = _income!;
            Account? defaultAccount;
            try {
              defaultAccount = accounts.firstWhere(
                (account) => account.id == income.defaultAccountId,
              );
            } catch (e) {
              defaultAccount = null;
            }
            final allowedAccounts = accounts.where(
              (account) => income.allowedAccountIds?.contains(account.id) ?? false,
            ).toList();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (defaultAccount != null) ...[
                      _buildDetailRow('Default Account', defaultAccount.displayName),
                      const SizedBox(height: 8),
                    ],
                    if (allowedAccounts.isNotEmpty) ...[
                      Text(
                        'Allowed Accounts',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allowedAccounts.map((account) {
                          return Chip(
                            avatar: Icon(
                              Icons.account_balance_wallet,
                              size: 16,
                              color: Color(account.type.color),
                            ),
                            label: Text(account.displayName),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      _buildDetailRow('Accounts', 'No specific accounts assigned'),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading accounts: $error'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeHistory() {
    final income = _income!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Income History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${income.incomeHistory.length} entries',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (income.incomeHistory.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No income history yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ...income.incomeHistory.map((instance) => _buildHistoryItem(instance)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(RecurringIncomeInstance instance) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text('\$${instance.amount.toStringAsFixed(2)}'),
      subtitle: Text(DateFormat('MMM dd, yyyy').format(instance.receivedDate)),
      trailing: instance.accountId != null ? const Icon(Icons.account_balance_wallet) : null,
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => EditRecurringIncomeBottomSheet.show(context, incomeId: _income!.id),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _recordIncomeReceipt,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Record Receipt'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Future<void> _confirmDelete() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Income'),
        content: Text(
          'Are you sure you want to delete "${_income!.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteIncome();
    }
  }

  Future<void> _deleteIncome() async {
    final success = await ref
        .read(recurringIncomeNotifierProvider.notifier)
        .deleteIncome(_income!.id);

    if (success && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recurring income deleted')),
          );
          context.go('/more/incomes');
        }
      });
    }
  }

  Future<void> _recordIncomeReceipt() async {
    // Show receipt recording bottom sheet
    await ReceiptRecordingBottomSheet.show(
      context: context,
      incomeId: _income!.id,
      onReceiptRecorded: () {
        // Refresh the income data after recording
        _loadIncome();
      },
    );
  }
}