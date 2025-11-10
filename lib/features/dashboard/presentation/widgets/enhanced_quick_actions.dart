import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';

class EnhancedQuickActions extends StatelessWidget {
  const EnhancedQuickActions({
    super.key,
    required this.onIncomePressed,
    required this.onExpensePressed,
    required this.onTransferPressed,
  });

  final VoidCallback onIncomePressed;
  final VoidCallback onExpensePressed;
  final VoidCallback onTransferPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
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
                  color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  size: 20,
                  color: AppColorsExtended.budgetPrimary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'Quick Actions',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_downward,
                  label: 'Income',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.statusNormal,
                      AppColorsExtended.statusNormal.withValues(alpha: 0.8),
                    ],
                  ),
                  onPressed: onIncomePressed,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 100.ms, curve: Curves.elasticOut),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_upward,
                  label: 'Expense',
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.statusCritical,
                      AppColorsExtended.statusCritical.withValues(alpha: 0.8),
                    ],
                  ),
                  onPressed: onExpensePressed,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms, curve: Curves.elasticOut),
              ),
              // SizedBox(width: AppDimensions.spacing3),
              // Expanded(
              //   child: _QuickActionButton(
              //     icon: Icons.swap_horiz,
              //     label: 'Transfer',
              //     gradient: LinearGradient(
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //       colors: [
              //         AppColorsExtended.budgetSecondary,
              //         AppColorsExtended.budgetSecondary.withValues(alpha: 0.8),
              //       ],
              //     ),
              //     onPressed: onTransferPressed,
              //   ).animate()
              //     .fadeIn(duration: 400.ms, delay: 300.ms)
              //     .slideY(begin: 0.2, duration: 400.ms, delay: 300.ms, curve: Curves.elasticOut),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: gradient.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12.0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Text(
                label,
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}