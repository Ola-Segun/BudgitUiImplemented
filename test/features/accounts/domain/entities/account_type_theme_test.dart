import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/features/accounts/domain/entities/account_type_theme.dart';

void main() {
  group('AccountTypeTheme Entity', () {
    test('should create AccountTypeTheme with all fields', () {
      // Arrange
      const accountType = 'bankAccount';
      const displayName = 'Bank Account';
      const iconName = 'account_balance';
      const colorValue = 0xFF10B981;

      // Act
      final theme = AccountTypeTheme(
        accountType: accountType,
        displayName: displayName,
        iconName: iconName,
        colorValue: colorValue,
      );

      // Assert
      expect(theme.accountType, accountType);
      expect(theme.displayName, displayName);
      expect(theme.iconName, iconName);
      expect(theme.colorValue, colorValue);
      expect(theme.color, const Color(0xFF10B981));
      expect(theme.iconData, Icons.account_balance);
    });

    test('should support copyWith', () {
      // Arrange
      final original = AccountTypeTheme(
        accountType: 'bankAccount',
        displayName: 'Bank Account',
        iconName: 'account_balance',
        colorValue: 0xFF10B981,
      );

      // Act
      final updated = original.copyWith(
        displayName: 'My Bank Account',
        colorValue: 0xFF3B82F6,
      );

      // Assert
      expect(updated.accountType, original.accountType);
      expect(updated.displayName, 'My Bank Account');
      expect(updated.iconName, original.iconName);
      expect(updated.colorValue, 0xFF3B82F6);
      expect(updated.color, const Color(0xFF3B82F6));
    });

    test('should support equality', () {
      // Arrange
      final theme1 = AccountTypeTheme(
        accountType: 'bankAccount',
        displayName: 'Bank Account',
        iconName: 'account_balance',
        colorValue: 0xFF10B981,
      );

      final theme2 = AccountTypeTheme(
        accountType: 'bankAccount',
        displayName: 'Bank Account',
        iconName: 'account_balance',
        colorValue: 0xFF10B981,
      );

      final theme3 = theme1.copyWith(displayName: 'Different Name');

      // Assert
      expect(theme1, theme2);
      expect(theme1, isNot(theme3));
    });

    test('should provide default themes for all account types', () {
      // Assert
      expect(AccountTypeTheme.defaultThemes.length, 5);
      expect(AccountTypeTheme.defaultThemes.containsKey('bankAccount'), true);
      expect(AccountTypeTheme.defaultThemes.containsKey('creditCard'), true);
      expect(AccountTypeTheme.defaultThemes.containsKey('loan'), true);
      expect(AccountTypeTheme.defaultThemes.containsKey('investment'), true);
      expect(AccountTypeTheme.defaultThemes.containsKey('manualAccount'), true);
    });

    test('should return correct default theme for account type', () {
      // Act & Assert
      final bankTheme = AccountTypeTheme.defaultThemeFor('bankAccount');
      expect(bankTheme.accountType, 'bankAccount');
      expect(bankTheme.displayName, 'Bank Account');
      expect(bankTheme.iconName, 'account_balance');
      expect(bankTheme.colorValue, 0xFF10B981);

      final creditCardTheme = AccountTypeTheme.defaultThemeFor('creditCard');
      expect(creditCardTheme.accountType, 'creditCard');
      expect(creditCardTheme.displayName, 'Credit Card');
      expect(creditCardTheme.iconName, 'credit_card');
      expect(creditCardTheme.colorValue, 0xFF3B82F6);

      // Test fallback for unknown account type
      final unknownTheme = AccountTypeTheme.defaultThemeFor('unknown');
      expect(unknownTheme.accountType, 'bankAccount'); // Should fallback to bankAccount
    });

    test('should convert color value to Color object', () {
      // Arrange
      const colorValue = 0xFF10B981;
      final theme = AccountTypeTheme(
        accountType: 'test',
        displayName: 'Test',
        iconName: 'test',
        colorValue: colorValue,
      );

      // Act & Assert
      expect(theme.color, const Color(0xFF10B981));
    });

    test('should convert icon name to IconData', () {
      // Test some common icons
      final accountBalanceTheme = AccountTypeTheme(
        accountType: 'test',
        displayName: 'Test',
        iconName: 'account_balance',
        colorValue: 0xFF000000,
      );
      expect(accountBalanceTheme.iconData, Icons.account_balance);

      final creditCardTheme = AccountTypeTheme(
        accountType: 'test',
        displayName: 'Test',
        iconName: 'credit_card',
        colorValue: 0xFF000000,
      );
      expect(creditCardTheme.iconData, Icons.credit_card);

      final editTheme = AccountTypeTheme(
        accountType: 'test',
        displayName: 'Test',
        iconName: 'edit',
        colorValue: 0xFF000000,
      );
      expect(editTheme.iconData, Icons.edit);

      // Test fallback for unknown icon
      final unknownTheme = AccountTypeTheme(
        accountType: 'test',
        displayName: 'Test',
        iconName: 'unknown_icon_xyz',
        colorValue: 0xFF000000,
      );
      expect(unknownTheme.iconData, Icons.account_balance); // Should fallback to account_balance
    });
  });
}