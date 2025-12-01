import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../insights/domain/entities/insight.dart';
import '../../../insights/presentation/widgets/enhanced_spending_trends_chart.dart';
import '../../../insights/presentation/widgets/spending_insights_card.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';

class EnhancedInsightsCard extends StatefulWidget {
  const EnhancedInsightsCard({
    super.key,
    required this.insights,
  });

  final List<Insight> insights;

  @override
  State<EnhancedInsightsCard> createState() => _EnhancedInsightsCardState();
}

class _EnhancedInsightsCardState extends State<EnhancedInsightsCard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.insights.isEmpty) return const SizedBox.shrink();

    final currentInsight = widget.insights[_currentIndex];

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getInsightColor(currentInsight.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      size: 20,
                      color: _getInsightColor(currentInsight.type),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacing2),
                  Text(
                    'Insights',
                    style: AppTypographyExtended.statsValue.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousInsight,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.insights.length}',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextInsight,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                _InsightContent(
                  key: ValueKey(_currentIndex),
                  insight: currentInsight,
                ),
                if (widget.insights.any((insight) => insight.type == InsightType.spendingTrend)) ...[
                  SizedBox(height: AppDimensions.spacing4),
                  const EnhancedSpendingTrendsChart(height: 250),
                ],
                if (widget.insights.any((insight) => insight.type == InsightType.unusualActivity ||
                                                  insight.type == InsightType.spendingTrend)) ...[
                  SizedBox(height: AppDimensions.spacing4),
                  const SpendingInsightsCard(maxInsights: 3),
                ],
              ],
            ),
          ),

          if (widget.insights.length > 1) ...[
            SizedBox(height: AppDimensions.spacing3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.insights.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? _getInsightColor(currentInsight.type)
                        : AppColors.borderSubtle,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _nextInsight() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.insights.length;
    });
  }

  void _previousInsight() {
    if (!mounted) return;
    setState(() {
      _currentIndex = _currentIndex > 0 ? _currentIndex - 1 : widget.insights.length - 1;
    });
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.spendingTrend:
        return AppColorsExtended.budgetPrimary;
      case InsightType.budgetAlert:
        return AppColorsExtended.statusCritical;
      case InsightType.savingsOpportunity:
        return AppColorsExtended.statusNormal;
      case InsightType.unusualActivity:
        return AppColorsExtended.statusWarning;
      case InsightType.goalProgress:
        return AppColorsExtended.budgetSecondary;
      case InsightType.billReminder:
        return AppColorsExtended.statusWarning;
      case InsightType.categoryAnalysis:
        return AppColorsExtended.budgetTertiary;
      case InsightType.monthlySummary:
        return AppColors.primary;
      case InsightType.comparison:
        return AppColorsExtended.budgetPrimary;
      case InsightType.recommendation:
        return AppColorsExtended.budgetSecondary;
    }
  }
}

class _InsightContent extends StatelessWidget {
  const _InsightContent({
    super.key,
    required this.insight,
  });

  final Insight insight;

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.spendingTrend:
        return AppColorsExtended.budgetPrimary;
      case InsightType.budgetAlert:
        return AppColorsExtended.statusCritical;
      case InsightType.savingsOpportunity:
        return AppColorsExtended.statusNormal;
      case InsightType.unusualActivity:
        return AppColorsExtended.statusWarning;
      case InsightType.goalProgress:
        return AppColorsExtended.budgetSecondary;
      case InsightType.billReminder:
        return AppColorsExtended.statusWarning;
      case InsightType.categoryAnalysis:
        return AppColorsExtended.budgetTertiary;
      case InsightType.monthlySummary:
        return AppColors.primary;
      case InsightType.comparison:
        return AppColorsExtended.budgetPrimary;
      case InsightType.recommendation:
        return AppColorsExtended.budgetSecondary;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.spendingTrend:
        return Icons.trending_up;
      case InsightType.budgetAlert:
        return Icons.warning_amber_rounded;
      case InsightType.savingsOpportunity:
        return Icons.savings;
      case InsightType.unusualActivity:
        return Icons.error_outline;
      case InsightType.goalProgress:
        return Icons.flag;
      case InsightType.billReminder:
        return Icons.receipt;
      case InsightType.categoryAnalysis:
        return Icons.pie_chart;
      case InsightType.monthlySummary:
        return Icons.calendar_month;
      case InsightType.comparison:
        return Icons.compare_arrows;
      case InsightType.recommendation:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insightColor = _getInsightColor(insight.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            insightColor.withValues(alpha: 0.1),
            insightColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insightColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insightColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getInsightIcon(insight.type),
                  color: insightColor,
                  size: 18,
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Expanded(
                child: Text(
                  insight.title,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          Text(
            insight.message,
            style: AppTypographyExtended.metricLabel.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (insight.amount != null) ...[
            SizedBox(height: AppDimensions.spacing3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: insightColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: insightColor,
                  ),
                  const SizedBox(width: 4),
                  PrivacyModeAmount(
                    amount: insight.amount!,
                    currency: '\$',
                    style: AppTypographyExtended.statsValue.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: insightColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}