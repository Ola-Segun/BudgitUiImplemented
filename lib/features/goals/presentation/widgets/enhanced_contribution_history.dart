import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography.dart';
import '../theme/goals_theme_extended.dart';
import '../widgets/enhanced_contribution_card.dart';

/// Enhanced Contribution History - Reusable component using transaction tile patterns
class EnhancedContributionHistory extends StatelessWidget {
  const EnhancedContributionHistory({
    super.key,
    required this.contributionsAsync,
    this.onViewAll,
  });

  final AsyncValue<List<dynamic>> contributionsAsync;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history,
                  size: 20,
                  color: GoalsThemeExtended.goalPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Contribution History',
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTypography.bodyMedium.copyWith(
                      color: GoalsThemeExtended.goalPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          contributionsAsync.when(
            data: (contributions) {
              if (contributions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contributions yet',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start contributing to reach your goal',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final recentContributions = contributions.take(10).toList();
              return Column(
                children: recentContributions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final contribution = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < recentContributions.length - 1 ? 12 : 0,
                    ),
                    child: EnhancedContributionCard(
                      contribution: contribution,
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: (100 * index).toInt()))
                      .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: (100 * index).toInt())),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load contributions',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 700.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 700.ms);
  }
}