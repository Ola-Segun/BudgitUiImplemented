import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';

/// Modern account card with gradient styling and animations
class ModernAccountCard extends StatelessWidget {
  final String accountId;
  final String name;
  final String type;
  final double balance;
  final Color color;
  final String? iconName;
  final double? utilizationRate;
  final VoidCallback? onTap;

  const ModernAccountCard({
    super.key,
    required this.accountId,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    this.iconName,
    this.utilizationRate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              HapticFeedback.mediumImpact();
              onTap!();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Semantics(
            label: 'Account $name, $type, balance ${formatter.format(balance.abs())}, ${isPositive ? 'positive' : 'negative'}',
            hint: 'Tap to view account details',
            button: true,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and type
                  Row(
                    children: [
                      // Account icon with gradient background
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color, color.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(iconName ?? 'account_balance_wallet'),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTypographyExtended.accountName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              type,
                              style: AppTypographyExtended.accountType,
                            ),
                          ],
                        ),
                      ),
                      // Chevron icon
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Balance
                  Text(
                    formatter.format(balance.abs()),
                    style: AppTypographyExtended.accountBalance.copyWith(
                      color: isPositive
                          ? AppColorsExtended.positive
                          : AppColorsExtended.negative,
                    ),
                  ),

                  // Utilization bar for credit cards
                  if (utilizationRate != null) ...[
                    const SizedBox(height: 12),
                    _buildUtilizationBar(utilizationRate!),
                  ],

                  // Account type indicator and status badge
                  const SizedBox(height: 12),
                  _buildAccountIndicators(),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildAccountIndicators() {
    return Row(
      children: [
        // Account type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            type,
            style: AppTypographyExtended.accountType.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: balance >= 0 ? AppColorsExtended.positive.withOpacity(0.1) : AppColorsExtended.negative.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            balance >= 0 ? 'Active' : 'Overdrawn',
            style: AppTypographyExtended.accountType.copyWith(
              color: balance >= 0 ? AppColorsExtended.positive : AppColorsExtended.negative,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilizationBar(double rate) {
    final percentage = (rate * 100).round();
    final color = _getUtilizationColor(rate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Utilization',
              style: AppTypographyExtended.accountType,
            ),
            Text(
              '$percentage%',
              style: AppTypographyExtended.accountType.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: rate.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getUtilizationColor(double rate) {
    if (rate > 0.7) return AppColorsExtended.statusCritical;
    if (rate > 0.5) return AppColorsExtended.warning;
    return AppColorsExtended.positive;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'trending_up':
        return Icons.trending_up;
      case 'checking':
        return Icons.account_balance_wallet;
      case 'investment':
        return Icons.trending_up;
      case 'loan':
        return Icons.account_balance;
      case 'mortgage':
        return Icons.home;
      default:
        return Icons.account_balance_wallet;
    }
  }
}