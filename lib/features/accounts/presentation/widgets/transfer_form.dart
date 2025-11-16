import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart' as core_providers;
import '../../../../core/error/result.dart' as result;
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/add_transaction.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/get_accounts.dart';
import '../../domain/usecases/transfer_money.dart';
import '../providers/account_providers.dart';
import 'account_selector.dart';

/// Provider for TransferMoney use case
final transferMoneyProvider = Provider<TransferMoney>((ref) {
  return TransferMoney(
    ref.read(core_providers.accountRepositoryProvider),
    ref.read(core_providers.addTransactionProvider),
  );
});

/// Form widget for transferring money between accounts
class TransferForm extends ConsumerStatefulWidget {
  const TransferForm({
    super.key,
    this.sourceAccountId,
    this.onTransferComplete,
  });

  final String? sourceAccountId;
  final VoidCallback? onTransferComplete;

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _descriptionController = TextEditingController();

  Account? _sourceAccount;
  Account? _destinationAccount;
  double _amount = 0.0;
  double _fee = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();

    // Listen for account creation events to refresh the account list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(accountNotifierProvider, (previous, next) {
        if (next.value != null && previous?.value != null) {
          final prevCount = previous!.value!.accounts.length;
          final newCount = next.value!.accounts.length;
          if (newCount > prevCount) {
            debugPrint('TransferForm: Detected new account creation, refreshing...');
            _loadAccounts();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    debugPrint('TransferForm: Loading accounts...');
    final getAccountsUseCase = ref.read(getAccountsProvider);
    final result = await getAccountsUseCase();

    if (result.isSuccess && mounted) {
      final accounts = result.dataOrNull ?? [];
      debugPrint('TransferForm: Loaded ${accounts.length} accounts');
      accounts.forEach((acc) => debugPrint('  - ${acc.id}: ${acc.name}'));

      // Pre-select source account if provided
      if (widget.sourceAccountId != null) {
        debugPrint('TransferForm: Looking for source account with ID: ${widget.sourceAccountId}');
        try {
          _sourceAccount = accounts.firstWhere(
            (account) => account.id == widget.sourceAccountId,
            orElse: () => accounts.first,
          );
          debugPrint('TransferForm: Found source account: ${_sourceAccount?.name ?? "NONE"}');
        } catch (e) {
          debugPrint('TransferForm: ERROR finding source account: $e');
          _sourceAccount = null;
        }
      }

      setState(() {});
    } else {
      debugPrint('TransferForm: Failed to load accounts: ${result.failureOrNull?.message}');
    }

    // Force refresh accounts after a short delay to catch newly added accounts
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && widget.sourceAccountId != null && _sourceAccount == null) {
        debugPrint('TransferForm: Retrying account load for source ID: ${widget.sourceAccountId}');
        _loadAccounts();
      }
    });
  }

  void _onSourceAccountSelected(Account? account) {
    setState(() {
      _sourceAccount = account;
      // Clear destination if it's the same as source
      if (_destinationAccount?.id == account?.id) {
        _destinationAccount = null;
      }
    });
  }

  void _onDestinationAccountSelected(Account? account) {
    setState(() {
      _destinationAccount = account;
    });
  }

  void _onAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    setState(() {
      _amount = amount;
    });
  }

  void _onFeeChanged(String value) {
    final fee = double.tryParse(value) ?? 0.0;
    setState(() {
      _fee = fee;
    });
  }

  Future<void> _processTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sourceAccount == null || _destinationAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both source and destination accounts')),
      );
      return;
    }

    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transfer amount')),
      );
      return;
    }

    // Check if source account has sufficient funds
    final requiredAmount = _amount + _fee;
    if (_sourceAccount!.currentBalance < requiredAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance in ${_sourceAccount!.name}. Available: \$${_sourceAccount!.currentBalance.toStringAsFixed(2)}, Required: \$${requiredAmount.toStringAsFixed(2)}'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use TransferMoney use case for cleaner API
      final transferMoneyUseCase = ref.read(transferMoneyProvider);
      final result = await transferMoneyUseCase(
        sourceAccount: _sourceAccount!,
        destinationAccount: _destinationAccount!,
        amount: _amount,
        fee: _fee > 0 ? _fee : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer of \$${_amount.toStringAsFixed(2)} completed successfully'),
            action: SnackBarAction(
              label: 'View Accounts',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
        widget.onTransferComplete?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failureOrNull?.message ?? 'Failed to process transfer'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while processing the transfer')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source Account Selector
          AccountSelector(
            label: 'From Account',
            selectedAccount: _sourceAccount,
            onAccountSelected: _onSourceAccountSelected,
            excludeAccountId: _destinationAccount?.id,
            showBalance: true,
          ),
          const SizedBox(height: 16),

          // Destination Account Selector
          AccountSelector(
            label: 'To Account',
            selectedAccount: _destinationAccount,
            onAccountSelected: _onDestinationAccountSelected,
            excludeAccountId: _sourceAccount?.id,
            showBalance: true,
          ),
          const SizedBox(height: 24),

          // Amount Input
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Transfer Amount',
              hintText: 'Enter amount to transfer',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter transfer amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
            onChanged: _onAmountChanged,
          ),
          const SizedBox(height: 16),

          // Transfer Fee Input (Optional)
          TextFormField(
            controller: _feeController,
            decoration: const InputDecoration(
              labelText: 'Transfer Fee (Optional)',
              hintText: 'Enter fee amount',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: _onFeeChanged,
          ),
          const SizedBox(height: 16),

          // Description Input
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Add a note for this transfer',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 32),

          // Transfer Summary
          if (_sourceAccount != null && _destinationAccount != null && _amount > 0)
            _buildTransferSummary(),

          const SizedBox(height: 24),

          // Transfer Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processTransfer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Transfer Money'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferSummary() {
    final totalDebit = _amount + _fee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('From', _sourceAccount!.displayName),
          _buildSummaryRow('To', _destinationAccount!.displayName),
          _buildSummaryRow('Amount', '\$${_amount.toStringAsFixed(2)}'),
          if (_fee > 0)
            _buildSummaryRow('Fee', '\$${_fee.toStringAsFixed(2)}'),
          const Divider(height: 16),
          _buildSummaryRow(
            'Total Debit',
            '\$${totalDebit.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}