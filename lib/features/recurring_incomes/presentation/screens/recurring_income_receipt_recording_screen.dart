import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';

/// Screen for recording income receipts with account selection and amount input
class RecurringIncomeReceiptRecordingScreen extends ConsumerStatefulWidget {
  const RecurringIncomeReceiptRecordingScreen({
    super.key,
    required this.incomeId,
  });

  final String incomeId;

  @override
  ConsumerState<RecurringIncomeReceiptRecordingScreen> createState() =>
      _RecurringIncomeReceiptRecordingScreenState();
}

class _RecurringIncomeReceiptRecordingScreenState
    extends ConsumerState<RecurringIncomeReceiptRecordingScreen> {
  RecurringIncome? _income;
  Account? _selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
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
        _amountController.text = income.amount.toStringAsFixed(2);
        _selectedAccount = _getDefaultAccount(income);
        _isLoading = false;
      });
    }
  }

  Account? _getDefaultAccount(RecurringIncome income) {
    final accountsAsync = ref.read(filteredAccountsProvider);
    return accountsAsync.maybeWhen(
      data: (accounts) {
        // Try to find the default account first
        if (income.defaultAccountId != null) {
          return accounts.firstWhere(
            (account) => account.id == income.defaultAccountId,
            orElse: () => accounts.firstWhere(
              (account) => income.allowedAccountIds?.contains(account.id) ?? false,
              orElse: () => accounts.first,
            ),
          );
        }
        // Fall back to first allowed account or any account
        return accounts.firstWhere(
          (account) => income.allowedAccountIds?.contains(account.id) ?? false,
          orElse: () => accounts.first,
        );
      },
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Receipt')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_income == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Receipt')),
        body: const Center(
          child: Text('Income not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _scanReceipt,
            tooltip: 'Scan Receipt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppTheme.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income Summary Card
            _buildIncomeSummary(),
            const SizedBox(height: 24),

            // Receipt Details Form
            _buildReceiptForm(),
            const SizedBox(height: 24),

            // Transaction Preview
            _buildTransactionPreview(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSummary() {
    final income = _income!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', income.name),
            _buildDetailRow('Expected Amount', '\$${income.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Frequency', income.frequency.displayName),
            if (income.nextExpectedDate != null)
              _buildDetailRow(
                'Next Expected',
                DateFormat('MMM dd, yyyy').format(income.nextExpectedDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Amount Input
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Received Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: _validateAmount,
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Receipt Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account Selection
            Consumer(
              builder: (context, ref, child) {
                final accountsAsync = ref.watch(filteredAccountsProvider);

                return accountsAsync.when(
                  data: (accounts) => DropdownButtonFormField<Account>(
                    initialValue: _selectedAccount,
                    decoration: const InputDecoration(
                      labelText: 'Deposit Account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem<Account>(
                        value: account,
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 20,
                              color: Color(account.type.color),
                            ),
                            const SizedBox(width: 8),
                            Text(account.displayName),
                            if (account.id == _income!.defaultAccountId) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (account) {
                      setState(() {
                        _selectedAccount = account;
                      });
                    },
                    validator: (account) {
                      if (account == null) {
                        return 'Please select an account';
                      }
                      return null;
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error loading accounts: $error'),
                );
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionPreview() {
    if (_selectedAccount == null) {
      return const SizedBox.shrink();
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Preview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Type', 'Income'),
            _buildDetailRow('Amount', '+\$${amount.toStringAsFixed(2)}'),
            _buildDetailRow('Account', _selectedAccount!.displayName),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(_selectedDate)),
            if (_notesController.text.isNotEmpty)
              _buildDetailRow('Notes', _notesController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isRecording ? null : () => context.pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isRecording ? null : _recordReceipt,
            child: _isRecording
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Record Receipt'),
          ),
        ),
      ],
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

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _scanReceipt() async {
    // Navigate to receipt scanning screen and wait for result
    final result = await context.push('/scan-receipt');

    if (result != null && result is Map<String, dynamic>) {
      // Update amount if scanned data contains amount
      if (result['amount'] != null) {
        _amountController.text = result['amount'].toStringAsFixed(2);
      }

      // Update date if scanned data contains date
      if (result['date'] != null) {
        setState(() {
          _selectedDate = result['date'] as DateTime;
        });
      }

      // Update notes with scanned data
      if (result['description'] != null) {
        _notesController.text = result['description'] as String;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt data applied successfully')),
      );
    }
  }

  Future<void> _recordReceipt() async {
    if (_income == null || _selectedAccount == null) {
      return;
    }

    // Validate form
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      // Create income instance
      final instance = RecurringIncomeInstance(
        id: 'receipt_${_income!.id}_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        receivedDate: _selectedDate,
        transactionId: null, // Will be set by the repository
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        accountId: _selectedAccount!.id,
      );

      // Record the receipt
      final success = await ref
          .read(recurringIncomeNotifierProvider.notifier)
          .recordIncomeReceipt(_income!.id, instance, accountId: _selectedAccount!.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Income receipt recorded successfully')),
        );
        context.go('/more/incomes/${_income!.id}');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to record income receipt')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }
}