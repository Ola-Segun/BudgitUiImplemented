import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/budget.dart' as budget_entity;

/// An enhanced budget card with visual improvements, progress indicators, and trend data.
/// Shows budget health, spending progress, and mini trend indicators.
class EnhancedBudgetCard extends StatelessWidget {
  const EnhancedBudgetCard({
    super.key,
    required this.budget,
    this.status,
    this.onTap,
  });

  /// Budget data
  final budget_entity.Budget budget;

  /// Budget status (optional)
  final budget_entity.BudgetStatus? status;

  /// Tap callback
  final VoidCallback? onTap;

  Color _getHealthColor(budget_entity.BudgetHealth health) {
    switch (health) {
      case budget_entity.BudgetHealth.healthy:
        return AppColorsExtended.statusNormal;
      case budget_entity.BudgetHealth.warning:
        return AppColorsExtended.statusWarning;
      case budget_entity.BudgetHealth.critical:
        return AppColorsExtended.statusCritical;
      case budget_entity.BudgetHealth.overBudget:
        return AppColorsExtended.statusOverBudget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = status != null ? status!.totalSpent / status!.totalBudget : 0.0;
    final health = status?.overallHealth ?? budget_entity.BudgetHealth.healthy;
    final healthColor = _getHealthColor(health);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 48), // Ensure minimum touch target height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: health == budget_entity.BudgetHealth.overBudget
                  ? healthColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 2,
            ),
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
              // Header Row
              Row(
                children: [
                  // Budget Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getBudgetIcon(budget.type),
                      size: 16,
                      color: healthColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Budget Name & Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          budget.type.displayName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mini Trend Indicator
                  if (status != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: MiniTrendIndicator(
                        values: _generateTrendData(status!),
                        color: healthColor,
                      ),
                    ),

                  // Arrow
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: const Color(0xFF6B7280),
                      size: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Section
              if (status != null) ...[
                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColorsExtended.pillBgUnselected,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              healthColor,
                              healthColor.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: healthColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Amount Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Spent
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spent',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                              .format(status!.totalSpent),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: healthColor,
                          ),
                        ),
                      ],
                    ),

                    // Progress Percentage
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: healthColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: healthColor,
                        ),
                      ),
                    ),

                    // Budget
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Budget',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                              .format(status!.totalBudget),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Footer Info
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${status!.daysRemaining} days left',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (status!.remainingAmount >= 0)
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 14,
                            color: AppColorsExtended.statusNormal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${status!.remainingAmount.toStringAsFixed(0)} left',
                            style: AppTypography.caption.copyWith(
                              color: AppColorsExtended.statusNormal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: AppColorsExtended.statusOverBudget,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${(-status!.remainingAmount).toStringAsFixed(0)} over',
                            style: AppTypography.caption.copyWith(
                              color: AppColorsExtended.statusOverBudget,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No spending data available',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBudgetIcon(budget_entity.BudgetType type) {
    switch (type) {
      case budget_entity.BudgetType.zeroBased:
        return Icons.account_balance_wallet;
      case budget_entity.BudgetType.fiftyThirtyTwenty:
        return Icons.pie_chart;
      case budget_entity.BudgetType.envelope:
        return Icons.mail;
      case budget_entity.BudgetType.custom:
        return Icons.tune;
    }
  }

  List<double> _generateTrendData(budget_entity.BudgetStatus status) {
    // Generate mock trend data - replace with actual historical data
    final values = <double>[];
    final dailyAverage = status.totalSpent / 7;

    for (int i = 0; i < 7; i++) {
      final variance = (i * 0.2) - 0.6;
      values.add((dailyAverage * (1 + variance)).clamp(0, double.infinity));
    }

    return values;
  }
}

/// Mini trend indicator widget for showing spending patterns
class MiniTrendIndicator extends StatelessWidget {
  const MiniTrendIndicator({
    super.key,
    required this.values,
    this.color,
    this.height = 24,
    this.width = 60,
  });

  final List<double> values;
  final Color? color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      size: Size(width, height),
      painter: _MiniTrendPainter(
        values: values,
        color: color ?? AppColorsExtended.budgetPrimary,
      ),
    );
  }
}

class _MiniTrendPainter extends CustomPainter {
  _MiniTrendPainter({
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    if (range == 0) return;

    final path = Path();
    final stepX = size.width / (values.length - 1);

    // Calculate points
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedValue = (values[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    // Draw gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(_MiniTrendPainter oldDelegate) => false;
}