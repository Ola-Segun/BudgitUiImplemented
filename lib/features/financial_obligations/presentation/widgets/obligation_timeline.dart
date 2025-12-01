// lib/features/obligations/presentation/widgets/obligation_timeline.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/obligations_theme.dart';
import '../../domain/entities/financial_obligation.dart';

/// Visual timeline of upcoming obligations (next 30 days)
class ObligationTimeline extends StatelessWidget {
  const ObligationTimeline({
    super.key,
    required this.obligations,
    this.maxDays = 30,
  });

  final List<FinancialObligation> obligations;
  final int maxDays;

  @override
  Widget build(BuildContext context) {
    final upcomingObligations = obligations
        .where((o) => o.daysUntilNext >= 0 && o.daysUntilNext <= maxDays)
        .toList()
      ..sort((a, b) => a.nextDate.compareTo(b.nextDate));

    if (upcomingObligations.isEmpty) {
      return _buildEmptyTimeline();
    }

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // INCREASED from 8
                decoration: BoxDecoration(
                  gradient: LinearGradient( // ADDED gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsExtended.budgetTertiary.withValues(alpha: 0.15),
                      AppColorsExtended.budgetTertiary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12), // INCREASED from 8
                  boxShadow: [ // ADDED shadow
                    BoxShadow(
                      color: AppColorsExtended.budgetTertiary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.timeline,
                  size: 22, // INCREASED from 20
                  color: AppColorsExtended.budgetTertiary,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),
              Expanded(
                child: Text(
                  'Next 30 Days',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildTimelineLegend(),
            ],
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, duration: 400.ms),

          SizedBox(height: AppDimensions.spacing4),

          // Timeline visualization - FIXED overflow
          _buildTimelineVisualization(upcomingObligations),

          SizedBox(height: AppDimensions.spacing4),

          // Upcoming items list
          ...upcomingObligations.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TimelineObligationCard(
                obligation: obligation,
              ).animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 * index))
                .slideX(begin: 0.1, duration: 400.ms, delay: Duration(milliseconds: 100 * index)),
            );
          }),

          if (upcomingObligations.length > 5) ...[
            SizedBox(height: AppDimensions.spacing2),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to full timeline view
                },
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(
                  'View ${upcomingObligations.length - 5} More',
                  style: AppTypographyExtended.metricLabel.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColorsExtended.budgetPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineLegend() {
    return Wrap( // CHANGED from Row to prevent overflow
      spacing: 8,
      runSpacing: 4,
      children: [
        _LegendDot(color: const Color(0xFFEF4444), label: 'Bills'),
        _LegendDot(color: const Color(0xFF10B981), label: 'Income'),
      ],
    );
  }

Widget _buildTimelineVisualization(List<FinancialObligation> obligations) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Calculate usable width for timeline (excluding padding)
        const horizontalPadding = 16.0;
        final timelineWidth = width - (horizontalPadding * 2);

        return SizedBox(
          height: 80,
          child: Stack(
            children: [
              // Timeline base line
              Positioned(
                top: 40,
                left: horizontalPadding,
                right: horizontalPadding,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColorsExtended.pillBgUnselected,
                        AppColorsExtended.pillBgUnselected.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Today marker (at start of timeline)
              Positioned(
                top: 8,
                left: horizontalPadding - 7, // Center the 14px marker on the line start
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Today',
                      style: AppTypographyExtended.metricLabel.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColorsExtended.budgetPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColorsExtended.budgetPrimary,
                            AppColorsExtended.budgetPrimary.withValues(alpha: 0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsExtended.budgetPrimary.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut),
              ),

              // Obligation markers
              ...obligations.take(10).map((obligation) {
                // Calculate position along timeline (0 = today, maxDays = end)
                final daysRatio = (obligation.daysUntilNext / maxDays).clamp(0.0, 1.0);
                final markerX = horizontalPadding + (daysRatio * timelineWidth) - 6; // Center 12px marker
                
                return Positioned(
                  top: 34.5, // Center 12px marker on 3px line at top: 40 (40 - 6 + 1.5 = 35.5)
                  left: markerX.clamp(horizontalPadding - 6, width - horizontalPadding - 6),
                  child: _TimelineMarker(
                    obligation: obligation,
                  ).animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (obligation.daysUntilNext * 5)),
                    )
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (obligation.daysUntilNext * 5)),
                      curve: Curves.elasticOut,
                    ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        children: [
          Container( // ENHANCED icon container
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorsExtended.statusNormal.withValues(alpha: 0.15),
                  AppColorsExtended.statusNormal.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 48,
              color: AppColorsExtended.statusNormal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming obligations',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up for the next 30 days',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.easeOut),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, // INCREASED from 8
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient( // ADDED gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            shape: BoxShape.circle,
            boxShadow: [ // ADDED shadow
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypographyExtended.metricLabel.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({
    required this.obligation,
  });

  final FinancialObligation obligation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12, // INCREASED from 10
      height: 12,
      decoration: BoxDecoration(
        gradient: LinearGradient( // ADDED gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            obligation.typeColor,
            obligation.typeColor.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: obligation.typeColor.withValues(alpha: 0.5), // INCREASED from 0.4
            blurRadius: 8, // INCREASED from 6
            spreadRadius: 2, // INCREASED from 1
          ),
        ],
      ),
    );
  }
}

class _TimelineObligationCard extends StatelessWidget {
  const _TimelineObligationCard({
    required this.obligation,
  });

  final FinancialObligation obligation;

  @override
  Widget build(BuildContext context) {
    final isOverdue = obligation.isOverdue;
    final isDueToday = obligation.isDueToday;
    final isBill = obligation.type == ObligationType.bill;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          final route = isBill ? '/more/cash-flow/bills/${obligation.id}' : '/more/cash-flow/incomes/${obligation.id}';
          context.go(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(12),
            border: (isOverdue || isDueToday)
                ? Border.all(
                    color: obligation.urgency.color.withValues(alpha: 0.3),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Timeline indicator line - ENHANCED
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient( // ADDED gradient
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      obligation.typeColor,
                      obligation.typeColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: obligation.typeColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Obligation icon - ENHANCED
              Container(
                padding: const EdgeInsets.all(10), // INCREASED from 8
                decoration: BoxDecoration(
                  gradient: LinearGradient( // ADDED gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      obligation.typeColor.withValues(alpha: 0.15),
                      obligation.typeColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10), // INCREASED from 8
                  boxShadow: [ // ADDED shadow
                    BoxShadow(
                      color: obligation.typeColor.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  obligation.type.icon,
                  size: 20, // INCREASED from 18
                  color: obligation.typeColor,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Obligation details - FIXED overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      obligation.name,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700, // INCREASED from w600
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 12,
                          color: obligation.urgency.color,
                        ),
                        const SizedBox(width: 4),
                        Flexible( // ADDED to prevent overflow
                          child: Text(
                            _getStatusText(),
                            style: AppTypographyExtended.metricLabel.copyWith(
                              color: obligation.urgency.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount and type badge - ENHANCED
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox( // ADDED to prevent overflow
                    fit: BoxFit.scaleDown,
                    child: Text(
                      obligation.formattedAmount,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: obligation.typeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient( // ADDED gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          obligation.typeColor.withValues(alpha: 0.15),
                          obligation.typeColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all( // ADDED border
                        color: obligation.typeColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      obligation.type.displayName,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: obligation.typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (obligation.isOverdue) return Icons.error_outline;
    if (obligation.isDueToday) return Icons.warning_amber_rounded;
    if (obligation.isDueSoon) return Icons.access_time;
    return Icons.schedule;
  }

  String _getStatusText() {
    if (obligation.isOverdue) {
      return '${obligation.daysUntilNext.abs()}d overdue';
    } else if (obligation.isDueToday) {
      return 'Due today';
    } else if (obligation.daysUntilNext == 1) {
      return 'Tomorrow';
    } else {
      return 'In ${obligation.daysUntilNext}d';
    }
  }
}