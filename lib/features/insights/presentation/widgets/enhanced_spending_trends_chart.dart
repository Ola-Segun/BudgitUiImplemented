import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Enhanced spending trends chart widget with actual data visualization
class EnhancedSpendingTrendsChart extends ConsumerWidget {
  const EnhancedSpendingTrendsChart({
    super.key,
    this.height = 300,
    this.showLegend = true,
  });

  final double height;
  final bool showLegend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconXxl,
                  height: AppSpacing.iconXxl,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.show_chart,
                    color: AppColors.info,
                    size: AppSpacing.iconLg,
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending Trends',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        'Track your spending patterns over time',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(AppSpacing.lg),
            SizedBox(
              height: height,
              child: _buildChart(),
            ),
            if (showLegend) ...[
              Gap(AppSpacing.md),
              _buildLegend(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Sample data - in real implementation, this would come from a provider
    final sampleData = _generateSampleData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 100,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 500,
        lineBarsData: [
          // Food & Dining trend
          LineChartBarData(
            spots: sampleData['food']!,
            isCurved: true,
            color: AppColors.error,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.error,
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.error.withValues(alpha: 0.1),
            ),
          ),
          // Transportation trend
          LineChartBarData(
            spots: sampleData['transport']!,
            isCurved: true,
            color: AppColors.warning,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.warning,
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.warning.withValues(alpha: 0.1),
            ),
          ),
          // Shopping trend
          LineChartBarData(
            spots: sampleData['shopping']!,
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.success,
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Food & Dining', AppColors.error),
        Gap(AppSpacing.lg),
        _buildLegendItem('Transportation', AppColors.warning),
        Gap(AppSpacing.lg),
        _buildLegendItem('Shopping', AppColors.success),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Gap(AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Map<String, List<FlSpot>> _generateSampleData() {
    // Sample data showing spending trends over 6 months
    return {
      'food': [
        FlSpot(0, 120),
        FlSpot(1, 135),
        FlSpot(2, 110),
        FlSpot(3, 145),
        FlSpot(4, 130),
        FlSpot(5, 125),
      ],
      'transport': [
        FlSpot(0, 80),
        FlSpot(1, 95),
        FlSpot(2, 85),
        FlSpot(3, 110),
        FlSpot(4, 90),
        FlSpot(5, 100),
      ],
      'shopping': [
        FlSpot(0, 200),
        FlSpot(1, 180),
        FlSpot(2, 220),
        FlSpot(3, 190),
        FlSpot(4, 210),
        FlSpot(5, 195),
      ],
    };
  }
}