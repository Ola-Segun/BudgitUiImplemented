import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/widgets/privacy_mode_text.dart';
import '../../domain/entities/account.dart';
import '../../presentation/providers/account_providers.dart';

/// Widget for selecting an account from a list
class AccountSelector extends ConsumerStatefulWidget {
  const AccountSelector({
    super.key,
    required this.label,
    required this.selectedAccount,
    required this.onAccountSelected,
    this.excludeAccountId,
    this.showBalance = true,
  });

  final String label;
  final Account? selectedAccount;
  final Function(Account?) onAccountSelected;
  final String? excludeAccountId;
  final bool showBalance;

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector> {
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();

    // Listen for account creation events to refresh the account list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(accountNotifierProvider, (previous, next) {
        if (next is AsyncData && previous is AsyncData) {
          final prevCount = (previous as AsyncData).value?.accounts.length ?? 0;
          final newCount = (next as AsyncData).value?.accounts.length ?? 0;
          if (newCount > prevCount) {
            debugPrint('AccountSelector: Detected new account creation, refreshing...');
            _loadAccounts();
          }
        }
      });
    });
  }

  Future<void> _loadAccounts() async {
    debugPrint('AccountSelector: Loading accounts...');
    setState(() {
      _isLoading = true;
    });

    final getAccountsUseCase = ref.read(getAccountsProvider);
    final result = await getAccountsUseCase();

    if (result.isSuccess && mounted) {
      final accounts = result.dataOrNull ?? [];
      debugPrint('AccountSelector: Loaded ${accounts.length} accounts');
      for (var acc in accounts) {
        debugPrint('  - ${acc.id}: ${acc.name}');
      }
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } else {
      debugPrint('AccountSelector: Failed to load accounts: ${result.failureOrNull?.message}');
      setState(() {
        _isLoading = false;
      });
    }

    // Force refresh accounts after a short delay to catch newly added accounts
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _accounts.isEmpty) {
        debugPrint('AccountSelector: Retrying account load due to empty list');
        _loadAccounts();
      }
    });
  }

  Future<void> _showAccountSelectionDialog() async {
    final availableAccounts = _accounts.where((account) {
      return widget.excludeAccountId == null || account.id != widget.excludeAccountId;
    }).toList();

    final selectedAccount = await showDialog<Account>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${widget.label.toLowerCase()}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableAccounts.length,
            itemBuilder: (context, index) {
              final account = availableAccounts[index];
              return ListTile(
                leading: Icon(
                  _getAccountIcon(account.type),
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(account.displayName),
                subtitle: widget.showBalance
                    ? PrivacyModeAmount(
                        amount: account.currentBalance,
                        currency: account.currency ?? 'USD',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.start,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(account),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedAccount != null) {
      widget.onAccountSelected(selectedAccount);
    }
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.loan:
        return Icons.account_balance_wallet;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.manualAccount:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isLoading ? null : _showAccountSelectionDialog,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  widget.selectedAccount != null
                      ? _getAccountIcon(widget.selectedAccount!.type)
                      : Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoading
                      ? const Text('Loading accounts...')
                      : Text(
                          widget.selectedAccount?.displayName ?? 'Select account',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                ),
                if (widget.selectedAccount != null && widget.showBalance)
                  PrivacyModeAmount(
                    amount: widget.selectedAccount!.currentBalance,
                    currency: widget.selectedAccount!.currency ?? 'USD',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}