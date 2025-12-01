import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';
import '../theme/income_theme_extended.dart';
import '../../domain/entities/recurring_income.dart';

class IncomeMetricCards extends ConsumerWidget {
  const IncomeMetricCards({
    super.key,
    required this.summary,
  });

  final RecurringIncomesSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _IncomeMetricCard(
            title: 'Expected',
            value: summary.expectedAmount,
            icon: Icons.schedule,
            color: IncomeThemeExtended.incomeSecondary,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _IncomeMetricCard(
            title: 'Received',
            value: summary.receivedThisMonth,
            icon: Icons.check_circle,
            color: IncomeThemeExtended.statusReceived,
            subtitle: 'This Month',
          ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms),
        ),
      ],
    );
  }
}

class _IncomeMetricCard extends ConsumerStatefulWidget {
  const _IncomeMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String subtitle;

  @override
  ConsumerState<_IncomeMetricCard> createState() => _IncomeMetricCardState();
}

class _IncomeMetricCardState extends ConsumerState<_IncomeMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return PrivacyModeAmount(
                amount: _animation.value,
                currency: '\$',
                style: AppTypographyExtended.metricPercentage.copyWith(
                  color: widget.color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          Text(
            widget.title,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}