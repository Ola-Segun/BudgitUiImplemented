import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/account.dart';
import '../widgets/modern_account_selector.dart';
import '../widgets/transfer_confirmation_dialog.dart';
import '../../presentation/providers/account_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Screen for transferring money between accounts
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({
    super.key,
    this.sourceAccountId,
  });

  final String? sourceAccountId;

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
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
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final getAccountsUseCase = ref.read(getAccountsProvider);
    final result = await getAccountsUseCase();

    if (result.isSuccess && mounted) {
      final accounts = result.dataOrNull ?? [];

      // Pre-select source account if provided
      if (widget.sourceAccountId != null) {
        _sourceAccount = accounts.firstWhere(
          (account) => account.id == widget.sourceAccountId,
          orElse: () => accounts.first,
        );
      }

      setState(() {});
    }
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

    // Show confirmation dialog
    final confirmed = await TransferConfirmationDialog.show(
      context: context,
      sourceAccount: _sourceAccount!,
      destinationAccount: _destinationAccount!,
      amount: _amount,
      fee: _fee,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create transfer transaction
      final transferTransaction = Transaction(
        id: 'transfer_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transfer to ${_destinationAccount!.name}',
        amount: _amount,
        type: TransactionType.transfer,
        date: DateTime.now(),
        categoryId: 'transfer', // Assuming transfer category exists
        accountId: _sourceAccount!.id,
        toAccountId: _destinationAccount!.id,
        transferFee: _fee > 0 ? _fee : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      // Process the transfer
      final addTransactionUseCase = ref.read(addTransactionProvider);
      final result = await addTransactionUseCase(transferTransaction);

      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer of \$${_amount.toStringAsFixed(2)} completed successfully'),
            action: SnackBarAction(
              label: 'View Accounts',
              onPressed: () => context.go('/more/accounts'),
            ),
          ),
        );
        context.go('/more/accounts');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Source Account Selector
              ModernAccountSelector(
                label: 'From Account',
                selectedAccount: _sourceAccount,
                onAccountSelected: _onSourceAccountSelected,
                excludeAccountId: _destinationAccount?.id,
                showBalance: true,
              ),
              const SizedBox(height: spacing_lg),

              // Destination Account Selector
              ModernAccountSelector(
                label: 'To Account',
                selectedAccount: _destinationAccount,
                onAccountSelected: _onDestinationAccountSelected,
                excludeAccountId: _sourceAccount?.id,
                showBalance: true,
              ),
              const SizedBox(height: 24),

              // Amount Display
              ModernAmountDisplay(
                amount: _amount,
                isEditable: true,
                onAmountChanged: (value) {
                  setState(() {
                    _amount = value;
                  });
                },
                onTap: () {
                  // TODO: Show numeric keyboard
                },
              ),
              const SizedBox(height: spacing_lg),

              // Transfer Fee Input (Optional)
              ModernTextField(
                label: 'Transfer Fee (Optional)',
                placeholder: 'Enter fee amount',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                onChanged: _onFeeChanged,
              ),
              const SizedBox(height: spacing_lg),

              // Description Input
              ModernTextField(
                label: 'Description (Optional)',
                placeholder: 'Add a note for this transfer',
                maxLength: 200,
                onChanged: (value) {
                  // Description is optional, no validation needed
                },
              ),
              const SizedBox(height: 32),

              // Transfer Summary
              if (_sourceAccount != null && _destinationAccount != null && _amount > 0)
                _buildTransferSummary(),

              const SizedBox(height: spacing_xl),

              // Slide to Transfer
              ModernSlideToConfirm(
                text: 'Slide to Transfer',
                onConfirmed: _isLoading ? null : _processTransfer,
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildTransferSummary() {
    final totalDebit = _amount + _fee;

    return Container(
      padding: const EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.primaryGray,
        borderRadius: BorderRadius.circular(radius_md),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Summary',
            style: ModernTypography.titleLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: spacing_md),
          _buildSummaryRow('From', _sourceAccount!.displayName),
          _buildSummaryRow('To', _destinationAccount!.displayName),
          _buildSummaryRow('Amount', '\$${_amount.toStringAsFixed(2)}'),
          if (_fee > 0)
            _buildSummaryRow('Fee', '\$${_fee.toStringAsFixed(2)}'),
          const Divider(height: spacing_lg),
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
      padding: const EdgeInsets.symmetric(vertical: spacing_xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? ModernTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                : ModernTypography.bodyLarge,
          ),
          Text(
            value,
            style: isTotal
                ? ModernTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ModernColors.accentGreen,
                  )
                : ModernTypography.bodyLarge,
          ),
        ],
      ),
    );
  }


}