import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/features/accounts/domain/entities/account.dart';

void main() {
  group('Account Entity', () {
    final testDate = DateTime(2025, 10, 2, 14, 30);
    final testAccount = Account(
      id: 'test-id',
      name: 'Test Account',
      type: AccountType.bankAccount,
      balance: 1000.0,
      description: 'Test description',
      institution: 'Test Bank',
      accountNumber: '123456789',
      currency: null,
      createdAt: testDate,
      updatedAt: testDate,
      creditLimit: 5000.0,
      availableCredit: 4000.0,
      interestRate: 5.5,
      minimumPayment: 50.0,
      dueDate: testDate.add(const Duration(days: 30)),
      isActive: true,
    );

    test('should create account with all fields', () {
      expect(testAccount.id, 'test-id');
      expect(testAccount.name, 'Test Account');
      expect(testAccount.type, AccountType.bankAccount);
      expect(testAccount.balance, 1000.0);
      expect(testAccount.description, 'Test description');
      expect(testAccount.institution, 'Test Bank');
      expect(testAccount.accountNumber, '123456789');
      expect(testAccount.currency, null);
      expect(testAccount.createdAt, testDate);
      expect(testAccount.updatedAt, testDate);
      expect(testAccount.creditLimit, 5000.0);
      expect(testAccount.availableCredit, 4000.0);
      expect(testAccount.interestRate, 5.5);
      expect(testAccount.minimumPayment, 50.0);
      expect(testAccount.dueDate, testDate.add(const Duration(days: 30)));
      expect(testAccount.isActive, true);
    });

    test('should create account with minimal fields', () {
      final minimalAccount = Account(
        id: 'minimal-id',
        name: 'Minimal Account',
        type: AccountType.manualAccount,
        balance: 500.0,
      );

      expect(minimalAccount.id, 'minimal-id');
      expect(minimalAccount.name, 'Minimal Account');
      expect(minimalAccount.type, AccountType.manualAccount);
      expect(minimalAccount.balance, 500.0);
      expect(minimalAccount.currency, null); // default
      expect(minimalAccount.isActive, true); // default
      expect(minimalAccount.description, null);
      expect(minimalAccount.institution, null);
      expect(minimalAccount.accountNumber, null);
      expect(minimalAccount.createdAt, null);
      expect(minimalAccount.updatedAt, null);
      expect(minimalAccount.creditLimit, null);
      expect(minimalAccount.availableCredit, null);
      expect(minimalAccount.interestRate, null);
      expect(minimalAccount.minimumPayment, null);
      expect(minimalAccount.dueDate, null);
    });

    test('isAsset should return true for asset accounts', () {
      final bankAccount = testAccount.copyWith(type: AccountType.bankAccount);
      final investmentAccount = testAccount.copyWith(type: AccountType.investment);
      final manualAccount = testAccount.copyWith(type: AccountType.manualAccount);

      expect(bankAccount.isAsset, true);
      expect(investmentAccount.isAsset, true);
      expect(manualAccount.isAsset, true);
    });

    test('isLiability should return true for liability accounts', () {
      final creditCard = testAccount.copyWith(type: AccountType.creditCard);
      final loan = testAccount.copyWith(type: AccountType.loan);

      expect(creditCard.isLiability, true);
      expect(loan.isLiability, true);
    });

    test('currentBalance should return cachedBalance when available', () {
      final accountWithCached = testAccount.copyWith(
        cachedBalance: 1500.0,
        balance: 1000.0, // legacy field
      );
      expect(accountWithCached.currentBalance, 1500.0);
    });

    test('currentBalance should fallback to balance when cachedBalance is null', () {
      final accountWithLegacy = testAccount.copyWith(
        cachedBalance: null,
        balance: 1000.0,
      );
      expect(accountWithLegacy.currentBalance, 1000.0);
    });

    test('currentBalance should return zero when both cachedBalance and balance are null', () {
      final accountWithoutBalance = testAccount.copyWith(
        cachedBalance: null,
        balance: null,
      );
      expect(accountWithoutBalance.currentBalance, 0.0);
    });

    test('currentBalance should handle negative balances', () {
      final negativeCached = testAccount.copyWith(cachedBalance: -500.0);
      expect(negativeCached.currentBalance, -500.0);

      final negativeLegacy = testAccount.copyWith(
        cachedBalance: null,
        balance: -300.0,
      );
      expect(negativeLegacy.currentBalance, -300.0);
    });

    test('availableBalance should return balance for non-credit cards', () {
      final bankAccount = testAccount.copyWith(type: AccountType.bankAccount);
      expect(bankAccount.availableBalance, 1000.0);
    });

    test('availableBalance should return credit limit minus balance for credit cards', () {
      final creditCard = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 1000.0,
        creditLimit: 5000.0,
      );
      expect(creditCard.availableBalance, 4000.0);
    });

    test('utilizationRate should return null for non-credit cards', () {
      final bankAccount = testAccount.copyWith(type: AccountType.bankAccount);
      expect(bankAccount.utilizationRate, null);
    });

    test('utilizationRate should calculate correctly for credit cards', () {
      final creditCard = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 1000.0,
        creditLimit: 5000.0,
      );
      expect(creditCard.utilizationRate, 0.2); // 1000/5000

      final maxUtilization = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 5000.0,
        creditLimit: 5000.0,
      );
      expect(maxUtilization.utilizationRate, 1.0);

      final overLimit = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 6000.0,
        creditLimit: 5000.0,
      );
      expect(overLimit.utilizationRate, 1.0); // clamped
    });

    test('isOverdrawn should return true for negative bank account balance', () {
      final overdrawn = testAccount.copyWith(
        type: AccountType.bankAccount,
        balance: -100.0,
      );
      expect(overdrawn.isOverdrawn, true);

      final positive = testAccount.copyWith(
        type: AccountType.bankAccount,
        balance: 100.0,
      );
      expect(positive.isOverdrawn, false);
    });

    test('isOverLimit should return true for credit cards over limit', () {
      final overLimit = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 6000.0,
        creditLimit: 5000.0,
      );
      expect(overLimit.isOverLimit, true);

      final underLimit = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 4000.0,
        creditLimit: 5000.0,
      );
      expect(underLimit.isOverLimit, false);
    });

    test('displayName should include institution when available', () {
      expect(testAccount.displayName, 'Test Account (Test Bank)');
    });

    test('displayName should be just name when no institution', () {
      final noInstitution = testAccount.copyWith(institution: null);
      expect(noInstitution.displayName, 'Test Account');
    });

    test('formattedBalance should format correctly for assets', () {
      final assetAccount = testAccount.copyWith(type: AccountType.bankAccount);
      expect(assetAccount.formattedBalance, 'USD 1000.00');
    });

    test('formattedBalance should format correctly for liabilities', () {
      final liabilityAccount = testAccount.copyWith(
        type: AccountType.loan,
        balance: 5000.0,
      );
      expect(liabilityAccount.formattedBalance, '-USD 5000.00');
    });

    test('formattedAvailableBalance should format correctly', () {
      expect(testAccount.formattedAvailableBalance, 'USD 1000.00');
    });

    test('copyWith should create new instance with updated fields', () {
      final updated = testAccount.copyWith(
        name: 'Updated Name',
        balance: 1500.0,
      );

      expect(updated.name, 'Updated Name');
      expect(updated.balance, 1500.0);
      expect(updated.id, testAccount.id); // unchanged
      expect(updated.type, testAccount.type); // unchanged
    });

    group('Balance Validation and Reconciliation', () {
      test('needsReconciliation should return false when balances are not available', () {
        final noBalances = testAccount.copyWith(
          cachedBalance: null,
          reconciledBalance: null,
        );
        expect(noBalances.needsReconciliation, false);

        final onlyCached = testAccount.copyWith(
          cachedBalance: 1000.0,
          reconciledBalance: null,
        );
        expect(onlyCached.needsReconciliation, false);

        final onlyReconciled = testAccount.copyWith(
          cachedBalance: null,
          reconciledBalance: 1000.0,
        );
        expect(onlyReconciled.needsReconciliation, false);
      });

      test('needsReconciliation should return true when discrepancy exists', () {
        final needsReconciliation = testAccount.copyWith(
          cachedBalance: 1000.0,
          reconciledBalance: 950.0,
        );
        expect(needsReconciliation.needsReconciliation, true);

        final largeDiscrepancy = testAccount.copyWith(
          cachedBalance: 1000.0,
          reconciledBalance: 900.0,
        );
        expect(largeDiscrepancy.needsReconciliation, true);
      });

      test('needsReconciliation should return false when balances match within tolerance', () {
        final matches = testAccount.copyWith(
          cachedBalance: 1000.0,
          reconciledBalance: 1000.01, // within 0.01 tolerance
        );
        expect(matches.needsReconciliation, false);

        final exactMatch = testAccount.copyWith(
          cachedBalance: 1000.0,
          reconciledBalance: 1000.0,
        );
        expect(exactMatch.needsReconciliation, false);
      });

      test('balanceDiscrepancy should return null when balances are not available', () {
        final noBalances = testAccount.copyWith(
          cachedBalance: null,
          reconciledBalance: null,
        );
        expect(noBalances.balanceDiscrepancy, null);
      });

      test('balanceDiscrepancy should return correct discrepancy amount', () {
        final positiveDiscrepancy = testAccount.copyWith(
          cachedBalance: 1050.0,
          reconciledBalance: 1000.0,
        );
        expect(positiveDiscrepancy.balanceDiscrepancy, 50.0);

        final negativeDiscrepancy = testAccount.copyWith(
          cachedBalance: 950.0,
          reconciledBalance: 1000.0,
        );
        expect(negativeDiscrepancy.balanceDiscrepancy, -50.0);
      });

      test('isValidBalance should return true for valid balances', () {
        final validAccount = testAccount.copyWith(
          cachedBalance: 1000.0,
          reconciledBalance: 950.0,
        );
        expect(validAccount.isValidBalance, true);
      });

      test('isValidBalance should return false for NaN cachedBalance', () {
        final invalidAccount = testAccount.copyWith(
          cachedBalance: double.nan,
        );
        expect(invalidAccount.isValidBalance, false);
      });

      test('isValidBalance should return false for infinite cachedBalance', () {
        final invalidAccount = testAccount.copyWith(
          cachedBalance: double.infinity,
        );
        expect(invalidAccount.isValidBalance, false);
      });

      test('isValidBalance should return false for NaN reconciledBalance', () {
        final invalidAccount = testAccount.copyWith(
          reconciledBalance: double.nan,
        );
        expect(invalidAccount.isValidBalance, false);
      });

      test('isValidBalance should return false for infinite reconciledBalance', () {
        final invalidAccount = testAccount.copyWith(
          reconciledBalance: double.infinity,
        );
        expect(invalidAccount.isValidBalance, false);
      });

      test('isValidBalance should return false when cachedBalance and balance disagree', () {
        final invalidAccount = testAccount.copyWith(
          cachedBalance: 1000.0,
          balance: 950.0, // different from cachedBalance
        );
        expect(invalidAccount.isValidBalance, false);
      });

      test('isValidBalance should return true when cachedBalance and balance match', () {
        final validAccount = testAccount.copyWith(
          cachedBalance: 1000.0,
          balance: 1000.0,
        );
        expect(validAccount.isValidBalance, true);
      });

      test('isValidBalance should handle null balances gracefully', () {
        final nullBalances = testAccount.copyWith(
          cachedBalance: null,
          reconciledBalance: null,
          balance: null,
        );
        expect(nullBalances.isValidBalance, true);
      });
    });
  });

  group('AccountType Enum', () {
    test('bankAccount should have correct properties', () {
      expect(AccountType.bankAccount.displayName, 'Bank Account');
      expect(AccountType.bankAccount.icon, 'account_balance');
      expect(AccountType.bankAccount.color, 0xFF10B981);
      expect(AccountType.bankAccount.isAsset, true);
      expect(AccountType.bankAccount.isLiability, false);
    });

    test('creditCard should have correct properties', () {
      expect(AccountType.creditCard.displayName, 'Credit Card');
      expect(AccountType.creditCard.icon, 'credit_card');
      expect(AccountType.creditCard.color, 0xFF3B82F6);
      expect(AccountType.creditCard.isAsset, false);
      expect(AccountType.creditCard.isLiability, true);
    });

    test('loan should have correct properties', () {
      expect(AccountType.loan.displayName, 'Loan');
      expect(AccountType.loan.icon, 'account_balance_wallet');
      expect(AccountType.loan.color, 0xFFEF4444);
      expect(AccountType.loan.isAsset, false);
      expect(AccountType.loan.isLiability, true);
    });

    test('investment should have correct properties', () {
      expect(AccountType.investment.displayName, 'Investment');
      expect(AccountType.investment.icon, 'trending_up');
      expect(AccountType.investment.color, 0xFF8B5CF6);
      expect(AccountType.investment.isAsset, true);
      expect(AccountType.investment.isLiability, false);
    });

    test('manualAccount should have correct properties', () {
      expect(AccountType.manualAccount.displayName, 'Manual Account');
      expect(AccountType.manualAccount.icon, 'edit');
      expect(AccountType.manualAccount.color, 0xFF64748B);
      expect(AccountType.manualAccount.isAsset, true);
      expect(AccountType.manualAccount.isLiability, false);
    });
  });
}