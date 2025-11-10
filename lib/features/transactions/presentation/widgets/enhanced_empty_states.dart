// lib/features/transactions/presentation/widgets/enhanced_empty_states.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';

class EnhancedEmptyTransactionsState extends StatelessWidget {
  const EnhancedEmptyTransactionsState({
    super.key,
    required this.onAddTransaction,
  });

  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/animations/empty_transactions.json',
              fit: BoxFit.contain,
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),

          SizedBox(height: AppDimensions.spacing4),

          // Title
          Text(
            'No transactions yet',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms),

          SizedBox(height: AppDimensions.spacing2),

          // Subtitle
          Text(
            'Start tracking your finances by\nadding your first transaction',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 300.ms),

          SizedBox(height: AppDimensions.spacing5),

          // Action Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorsExtended.budgetPrimary,
                  AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddTransaction,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: AppDimensions.spacing2),
                      Text(
                        'Add Transaction',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }
}

class EnhancedNoMatchesState extends StatelessWidget {
  const EnhancedNoMatchesState({
    super.key,
    required this.onClearFilters,
  });

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation
          SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/animations/empty_transactions.json',
              fit: BoxFit.contain,
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),

          SizedBox(height: AppDimensions.spacing4),

          // Title
          Text(
            'No matching transactions',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms),

          SizedBox(height: AppDimensions.spacing2),

          // Subtitle
          Text(
            'Try adjusting your search\nor clearing the filters',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 300.ms),

          SizedBox(height: AppDimensions.spacing5),

          // Action Button
          OutlinedButton.icon(
            onPressed: onClearFilters,
            icon: Icon(
              Icons.clear,
              size: 18,
              color: AppColorsExtended.statusWarning,
            ),
            label: Text(
              'Clear Filters',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColorsExtended.statusWarning,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              side: BorderSide(color: AppColorsExtended.statusWarning),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }
}