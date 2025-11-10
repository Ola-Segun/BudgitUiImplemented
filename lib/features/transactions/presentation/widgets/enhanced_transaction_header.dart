// lib/features/transactions/presentation/widgets/enhanced_transaction_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';

class EnhancedTransactionHeader extends ConsumerWidget {
  const EnhancedTransactionHeader({
    super.key,
    required this.onFilterPressed,
    required this.onSearchChanged,
    this.hasActiveFilters = false,
  });

  final VoidCallback onFilterPressed;
  final ValueChanged<String> onSearchChanged;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Filter Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: AppTypographyExtended.circularProgressPercentage.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? AppColorsExtended.budgetPrimary.withValues(alpha: 0.1)
                          : AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: hasActiveFilters
                            ? AppColorsExtended.budgetPrimary
                            : AppColors.textSecondary,
                      ),
                      onPressed: onFilterPressed,
                      tooltip: 'Filter',
                    ),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColorsExtended.budgetPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColorsExtended.pillBgUnselected,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: AppTypographyExtended.metricLabel.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}