import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/widgets/privacy_mode_text.dart';
import '../../domain/entities/account.dart';

/// Widget for displaying account balance information
class AccountBalanceCard extends ConsumerWidget {
  const AccountBalanceCard({
    super.key,
    required this.account,
  });

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Name and Type
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(account.type.color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(account.type.icon),
                    color: Color(account.type.color),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        account.type.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Balance Information
            Row(
              children: [
                Expanded(
                  child: _buildBalanceSection(
                    context,
                    ref,
                    'Current Balance',
                    account.currentBalance.abs(),
                    account.currency ?? 'USD',
                    account.isLiability
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                if (account.availableBalance != account.currentBalance) ...[
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildBalanceSection(
                      context,
                      ref,
                      account.type == AccountType.creditCard
                          ? 'Available Credit'
                          : 'Available Balance',
                      account.availableBalance.abs(),
                      account.currency ?? 'USD',
                      account.availableBalance >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ],
            ),

            // Type-specific information
            if (account.type == AccountType.creditCard && account.utilizationRate != null) ...[
              const SizedBox(height: 16),
              _buildUtilizationIndicator(context, account.utilizationRate!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection(
    BuildContext context,
    WidgetRef ref,
    String label,
    double amount,
    String currency,
    Color amountColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        PrivacyModeAmount(
          amount: amount,
          currency: currency,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildUtilizationIndicator(BuildContext context, double utilizationRate) {
    final percentage = (utilizationRate * 100).round();
    final isHighUtilization = utilizationRate > 0.3; // 30% threshold

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Credit Utilization',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isHighUtilization
                        ? Colors.orange
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: utilizationRate.clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            isHighUtilization ? Colors.orange : Colors.green,
          ),
        ),
        if (isHighUtilization) ...[
          const SizedBox(height: 4),
          Text(
            'High utilization may affect your credit score',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontSize: 12,
                ),
          ),
        ],
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'trending_up':
        return Icons.trending_up;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.account_balance_wallet;
    }
  }
}