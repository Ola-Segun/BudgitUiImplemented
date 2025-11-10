import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/haptic_feedback_utils.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';

/// Modern net worth card with gradient styling and animations
class ModernNetWorthCard extends StatelessWidget {
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;

  const ModernNetWorthCard({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = netWorth >= 0;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final gradient = isPositive
        ? AppColorsExtended.positiveGradient
        : AppColorsExtended.negativeGradient;

    return Semantics(
      label: 'Net worth card showing ${formatter.format(netWorth.abs())} ${isPositive ? 'positive' : 'negative'} net worth',
      hint: 'Displays total assets of ${formatter.format(totalAssets)} and liabilities of ${formatter.format(totalLiabilities)}',
      child: GestureDetector(
        onTap: () => HapticFeedbackUtils.medium(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isPositive
                        ? AppColorsExtended.positive
                        : AppColorsExtended.negative)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                        semanticLabel: 'Net worth wallet icon',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: Colors.white,
                            size: 16,
                            semanticLabel: isPositive ? 'Trending up icon' : 'Trending down icon',
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPositive ? 'Healthy' : 'Attention',
                            style: AppTypographyExtended.statusText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Net Worth
                Text(
                  'Net Worth',
                  style: AppTypographyExtended.accountLabel,
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(netWorth.abs()),
                  style: AppTypographyExtended.accountBalanceHero.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Assets & Liabilities
                Row(
                  children: [
                    Expanded(
                      child: _buildStatColumn(
                        'Assets',
                        totalAssets,
                        Icons.arrow_upward,
                        formatter,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildStatColumn(
                        'Liabilities',
                        totalLiabilities,
                        Icons.arrow_downward,
                        formatter,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    double amount,
    IconData icon,
    NumberFormat formatter,
  ) {
    return Semantics(
      label: '$label amount: ${formatter.format(amount)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withOpacity(0.8),
                  size: 14,
                  semanticLabel: label == 'Assets' ? 'Assets upward arrow' : 'Liabilities downward arrow',
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypographyExtended.accountType.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formatter.format(amount),
              style: AppTypographyExtended.accountBalanceSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}