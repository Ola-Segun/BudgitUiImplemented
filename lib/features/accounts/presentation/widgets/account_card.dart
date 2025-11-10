import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/presentation/widgets/cards/modern_account_card.dart';
import '../../domain/entities/account.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account_type_theme.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// Modern AccountCard with enhanced features
/// Transforms the AccountCard to ModernAccountCard according to specifications:
/// - Gradient icon backgrounds with teal/green or purple gradients
/// - Color-coded balances (green for positive, red for negative)
/// - Credit utilization bars for credit cards with progress indicators
/// - Smooth entrance animations and micro-interactions
/// - Modern card styling with 16-24px border radius and subtle shadows
/// - Haptic feedback on interactions
/// - Accessibility features with semantic labels
/// - Account type indicators and status badges
/// - Support for different account types (checking, savings, credit cards, investments)
class AccountCard extends ConsumerWidget {
  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('AccountCard: Building for account ${account.name}, balance: ${account.balance}, cachedBalance: ${account.cachedBalance}, currentBalance: ${account.currentBalance}, formattedBalance: ${account.formattedBalance}');

    // Get custom themes from settings
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final customThemes = settingsAsync.maybeWhen(
      data: (settingsState) => settingsState.settings.accountTypeThemes.cast<String, AccountTypeTheme>(),
      orElse: () => <String, AccountTypeTheme>{},
    );

    // Extract account data for modern card with enhanced features
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final balance = account.currentBalance ?? account.balance ?? 0.0;
    final utilizationRate = account.type == AccountType.creditCard && account.creditLimit != null
        ? (account.currentBalance ?? 0) / account.creditLimit!
        : null;

    // Use themed color and icon
    final theme = account.type.getTheme(customThemes);
    final color = theme.color;
    final iconName = theme.iconName;

    return ModernAccountCard(
      accountId: account.id,
      name: account.displayName,
      type: account.type.displayName,
      balance: balance,
      color: color,
      iconName: iconName,
      utilizationRate: utilizationRate,
      onTap: onTap,
    );
  }
}