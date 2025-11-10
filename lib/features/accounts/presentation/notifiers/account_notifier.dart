import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/account.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_accounts.dart';
import '../../domain/usecases/get_account_balance.dart';
import '../../domain/usecases/update_account.dart';
import '../states/account_state.dart';

/// State notifier for account management
class AccountNotifier extends StateNotifier<AsyncValue<AccountState>> {
  final GetAccounts _getAccounts;
  final CreateAccount _createAccount;
  final UpdateAccount _updateAccount;
  final DeleteAccount _deleteAccount;
  final GetAccountBalance _getAccountBalance;

  bool _isDisposed = false;

  AccountNotifier({
    required GetAccounts getAccounts,
    required CreateAccount createAccount,
    required UpdateAccount updateAccount,
    required DeleteAccount deleteAccount,
    required GetAccountBalance getAccountBalance,
  })  : _getAccounts = getAccounts,
        _createAccount = createAccount,
        _updateAccount = updateAccount,
        _deleteAccount = deleteAccount,
        _getAccountBalance = getAccountBalance,
        super(const AsyncValue.loading()) {
    loadAccounts();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Check if notifier is disposed
  bool get isDisposed => _isDisposed;

  /// Load all accounts and balance information
  Future<void> loadAccounts() async {
    if (_isDisposed) return;

    debugPrint('AccountNotifier: Loading accounts...');
    state = const AsyncValue.loading();

    // Load accounts
    final accountsResult = await _getAccounts();

    // Load balance information
    final totalBalanceResult = await _getAccountBalance.getTotalBalance();
    final netWorthResult = await _getAccountBalance.getNetWorth();

    if (_isDisposed) return;

    accountsResult.when(
      success: (accounts) {
        debugPrint('AccountNotifier: Loaded ${accounts.length} accounts');
        for (var acc in accounts) {
          debugPrint('  - ${acc.id}: ${acc.name}');
        }
        final totalBalance = totalBalanceResult.getOrDefault(0.0);
        final netWorth = netWorthResult.getOrDefault(0.0);

        if (!_isDisposed) {
          state = AsyncValue.data(AccountState(
            accounts: accounts,
            totalBalance: totalBalance,
            netWorth: netWorth,
          ));
        }
      },
      error: (failure) {
        debugPrint('AccountNotifier: Failed to load accounts: ${failure.message}');
        if (!_isDisposed) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        }
      },
    );
  }

  /// Create a new account
  Future<bool> createAccount(Account account) async {
    if (_isDisposed) return false;

    final currentState = state.value;
    if (currentState == null) return false;

    // Set loading state
    if (!_isDisposed) {
      state = AsyncValue.data(currentState.copyWith(isLoading: true));
    }

    final result = await _createAccount(account);

    if (_isDisposed) return false;

    return result.when(
      success: (createdAccount) {
        if (_isDisposed) return false;

        debugPrint('AccountNotifier: Created account: ${createdAccount.id} - ${createdAccount.name}');

        // Update with server response
        final updatedAccounts = [createdAccount, ...currentState.accounts];
        final newTotalBalance = currentState.totalBalance + createdAccount.currentBalance;
        final newNetWorth = createdAccount.isAsset
            ? currentState.netWorth + createdAccount.currentBalance
            : currentState.netWorth - createdAccount.currentBalance;

        if (!_isDisposed) {
          state = AsyncValue.data(currentState.copyWith(
            accounts: updatedAccounts,
            totalBalance: newTotalBalance,
            netWorth: newNetWorth,
            isLoading: false,
          ));
        }
        return true;
      },
      error: (failure) {
        debugPrint('AccountNotifier: Failed to create account: ${failure.message}');
        if (_isDisposed) return false;

        // Revert to original state with error
        if (!_isDisposed) {
          state = AsyncValue.data(currentState.copyWith(
            isLoading: false,
            error: failure.message,
          ));
        }
        return false;
      },
    );
  }

  /// Update an existing account
  Future<bool> updateAccount(Account account) async {
    if (_isDisposed) return false;

    final currentState = state.value;
    if (currentState == null) return false;

    final oldAccount = currentState.accounts.firstWhere(
      (a) => a.id == account.id,
      orElse: () => account,
    );

    final result = await _updateAccount(account);

    if (_isDisposed) return false;

    return result.when(
      success: (updatedAccount) {
        if (_isDisposed) return false;

        final updatedAccounts = currentState.accounts.map((a) {
          return a.id == account.id ? updatedAccount : a;
        }).toList();

        // Recalculate balances
        final balanceDiff = updatedAccount.currentBalance - oldAccount.currentBalance;
        final netWorthDiff = updatedAccount.isAsset
            ? (oldAccount.isAsset ? balanceDiff : updatedAccount.currentBalance - (-oldAccount.currentBalance))
            : (oldAccount.isLiability ? -balanceDiff : -updatedAccount.currentBalance - oldAccount.currentBalance);

        if (!_isDisposed) {
          state = AsyncValue.data(currentState.copyWith(
            accounts: updatedAccounts,
            totalBalance: currentState.totalBalance + balanceDiff,
            netWorth: currentState.netWorth + netWorthDiff,
          ));
        }
        return true;
      },
      error: (failure) {
        if (_isDisposed) return false;

        if (!_isDisposed) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        }
        return false;
      },
    );
  }

  /// Delete an account
  Future<bool> deleteAccount(String accountId) async {
    if (_isDisposed) return false;

    final currentState = state.value;
    if (currentState == null) return false;

    final accountToDelete = currentState.accounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => throw Exception('Account not found'),
    );

    final result = await _deleteAccount(accountId);

    if (_isDisposed) return false;

    return result.when(
      success: (_) {
        if (_isDisposed) return false;

        final updatedAccounts = currentState.accounts
            .where((a) => a.id != accountId)
            .toList();

        // Update balances
        final newTotalBalance = currentState.totalBalance - accountToDelete.currentBalance;
        final newNetWorth = accountToDelete.isAsset
            ? currentState.netWorth - accountToDelete.currentBalance
            : currentState.netWorth + accountToDelete.currentBalance;

        if (!_isDisposed) {
          state = AsyncValue.data(currentState.copyWith(
            accounts: updatedAccounts,
            totalBalance: newTotalBalance,
            netWorth: newNetWorth,
          ));
        }
        return true;
      },
      error: (failure) {
        if (_isDisposed) return false;

        if (!_isDisposed) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        }
        return false;
      },
    );
  }

  /// Search accounts
  void searchAccounts(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query));
  }

  /// Filter by account type
  void filterByType(AccountType? type) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(filterType: type));
  }

  /// Clear search
  void clearSearch() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: null));
  }

  /// Clear filter
  void clearFilter() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(filterType: null));
  }

  /// Refresh balances
  Future<void> refreshBalances() async {
    if (_isDisposed) return;

    final currentState = state.value;
    if (currentState == null) return;

    final totalBalanceResult = await _getAccountBalance.getTotalBalance();
    final netWorthResult = await _getAccountBalance.getNetWorth();

    if (_isDisposed) return;

    final totalBalance = totalBalanceResult.getOrDefault(currentState.totalBalance);
    final netWorth = netWorthResult.getOrDefault(currentState.netWorth);

    if (!_isDisposed) {
      state = AsyncValue.data(currentState.copyWith(
        totalBalance: totalBalance,
        netWorth: netWorth,
      ));
    }
  }
}