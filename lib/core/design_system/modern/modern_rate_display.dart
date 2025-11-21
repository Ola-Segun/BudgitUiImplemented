import 'package:flutter/material.dart';
import 'modern_design_constants.dart';

/// ModernRateDisplay Widget
/// Compact component for displaying rates (interest rates, budget rates, etc.)
/// Gray background (#F5F5F5), Icon prefix (percentage symbol), Inline label
/// Compact height (48px), Formatted percentage display
class ModernRateDisplay extends StatelessWidget {
  final double rate;
  final String label;
  final int decimalPlaces;
  final String rateSymbol;

  const ModernRateDisplay({
    super.key,
    required this.rate,
    required this.label,
    this.decimalPlaces = 2,
    this.rateSymbol = '%',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label rate display',
      value: '${rate.toStringAsFixed(decimalPlaces)}$rateSymbol',
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: spacing_md),
        decoration: BoxDecoration(
          color: ModernColors.primaryGray,
          borderRadius: BorderRadius.circular(radius_md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.percent,
              size: 20,
              color: ModernColors.textSecondary,
            ),
            const SizedBox(width: spacing_sm),
            Text(
              label,
              style: ModernTypography.labelMedium.copyWith(
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(width: spacing_sm),
            Text(
              '${rate.toStringAsFixed(decimalPlaces)}$rateSymbol',
              style: ModernTypography.bodyLarge.copyWith(
                color: ModernColors.primaryBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}