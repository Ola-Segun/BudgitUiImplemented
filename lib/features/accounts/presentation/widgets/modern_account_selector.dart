import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';

/// Modern Account Selector Widget
/// Card-based account selection with balance display
/// Rounded corners, subtle shadows, icon + text layout
class ModernAccountSelector extends ConsumerStatefulWidget {
  const ModernAccountSelector({
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
  ConsumerState<ModernAccountSelector> createState() => _ModernAccountSelectorState();
}

class _ModernAccountSelectorState extends ConsumerState<ModernAccountSelector> {
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
            debugPrint('ModernAccountSelector: Detected new account creation, refreshing...');
            _loadAccounts();
          }
        }
      });
    });
  }

  Future<void> _loadAccounts() async {
    debugPrint('ModernAccountSelector: Loading accounts...');
    setState(() {
      _isLoading = true;
    });

    final getAccountsUseCase = ref.read(getAccountsProvider);
    final result = await getAccountsUseCase();

    if (result.isSuccess && mounted) {
      final accounts = result.dataOrNull ?? [];
      debugPrint('ModernAccountSelector: Loaded ${accounts.length} accounts');
      for (var acc in accounts) {
        debugPrint('  - ${acc.id}: ${acc.name}');
      }
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } else {
      debugPrint('ModernAccountSelector: Failed to load accounts: ${result.failureOrNull?.message}');
      setState(() {
        _isLoading = false;
      });
    }

    // Force refresh accounts after a short delay to catch newly added accounts
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _accounts.isEmpty) {
        debugPrint('ModernAccountSelector: Retrying account load due to empty list');
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select ${widget.label.toLowerCase()}',
                style: ModernTypography.titleLarge,
              ),
              const SizedBox(height: spacing_lg),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (availableAccounts.isEmpty)
                Center(
                  child: Text(
                    'No accounts available',
                    style: ModernTypography.bodyLarge.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableAccounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: spacing_sm),
                  itemBuilder: (context, index) {
                    final account = availableAccounts[index];
                    return _buildAccountCard(account, isDialog: true);
                  },
                ),
              const SizedBox(height: spacing_lg),
              Row(
                children: [
                  Expanded(
                    child: ModernActionButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  Widget _buildAccountCard(Account account, {bool isDialog = false}) {
    final isSelected = account.id == widget.selectedAccount?.id;

    return Semantics(
      button: true,
      selected: isSelected,
      label: account.displayName,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (isDialog) {
            Navigator.of(context).pop(account);
          } else {
            widget.onAccountSelected(account);
          }
        },
        child: AnimatedContainer(
          duration: ModernAnimations.fast,
          padding: const EdgeInsets.all(spacing_md),
          decoration: BoxDecoration(
            color: isSelected ? ModernColors.accentGreen.withOpacity(0.1) : ModernColors.lightBackground,
            border: Border.all(
              color: isSelected ? ModernColors.accentGreen : ModernColors.borderColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(radius_md),
            boxShadow: isSelected ? [ModernShadows.subtle] : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ModernColors.primaryGray,
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  color: ModernColors.primaryBlack,
                  size: 24,
                ),
              ),
              const SizedBox(width: spacing_md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style: ModernTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    if (widget.showBalance) ...[
                      const SizedBox(height: spacing_xs),
                      PrivacyModeAmount(
                        amount: account.currentBalance,
                        currency: account.currency ?? 'USD',
                        style: ModernTypography.labelMedium.copyWith(
                          color: ModernColors.textSecondary,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: ModernColors.accentGreen,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: ModernTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: spacing_sm),
        if (_isLoading)
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: ModernColors.primaryGray,
              borderRadius: BorderRadius.circular(radius_md),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (widget.selectedAccount != null)
          _buildAccountCard(widget.selectedAccount!)
        else
          GestureDetector(
            onTap: _showAccountSelectionDialog,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: ModernColors.primaryGray,
                border: Border.all(color: ModernColors.borderColor),
                borderRadius: BorderRadius.circular(radius_md),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: ModernColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: spacing_sm),
                    Text(
                      'Select account',
                      style: ModernTypography.bodyLarge.copyWith(
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}