import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/cards/modern_net_worth_card.dart';

/// Card displaying net worth information
/// Updated to use the modern design system
class NetWorthCard extends StatelessWidget {
  const NetWorthCard({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
  });

  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;

  @override
  Widget build(BuildContext context) {
    return ModernNetWorthCard(
      netWorth: netWorth,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
    );
  }
}