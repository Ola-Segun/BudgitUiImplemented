import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal.dart';

/// Enhanced Goal Timeline Card - Reusable component showing goal timeline with progress visualization
class EnhancedGoalTimelineCard extends StatelessWidget {
  const EnhancedGoalTimelineCard({
    super.key,
    required this.goal,
  });

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = goal.deadline.difference(goal.createdAt).inDays;
    final elapsedDays = now.difference(goal.createdAt).inDays;
    final timeProgress = (elapsedDays / totalDays).clamp(0.0, 1.0);

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GoalsThemeExtended.goalSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timeline,
                  size: 20,
                  color: GoalsThemeExtended.goalSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Goal Timeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timeline visualization
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                // Background track
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Progress track
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: timeProgress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GoalsThemeExtended.goalPrimary,
                            GoalsThemeExtended.goalSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ).animate()
                      .scaleX(
                        duration: 1000.ms,
                        curve: Curves.easeOutCubic,
                        begin: 0.0,
                        end: 1.0,
                      ),
                  ),
                ),

                // Start marker
                _buildTimelineMarker(
                  context,
                  0.0,
                  'Started',
                  DateFormat('MMM dd').format(goal.createdAt),
                  Icons.flag,
                  GoalsThemeExtended.goalSuccess,
                  true,
                ),

                // Current position marker
                if (!goal.isCompleted && timeProgress < 1.0)
                  _buildTimelineMarker(
                    context,
                    timeProgress,
                    'Today',
                    DateFormat('MMM dd').format(now),
                    Icons.circle,
                    GoalsThemeExtended.goalPrimary,
                    true,
                  ),

                // End marker
                _buildTimelineMarker(
                  context,
                  1.0,
                  goal.isCompleted ? 'Completed' : 'Target',
                  DateFormat('MMM dd').format(goal.deadline),
                  goal.isCompleted ? Icons.check_circle : Icons.flag_outlined,
                  goal.isCompleted
                      ? GoalsThemeExtended.goalSuccess
                      : goal.isOverdue
                          ? GoalsThemeExtended.goalWarning
                          : GoalsThemeExtended.goalSecondary,
                  goal.isCompleted,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimelineStat(
                context,
                'Days Elapsed',
                '$elapsedDays',
                Icons.history,
                GoalsThemeExtended.goalPrimary,
              ),
              _buildVerticalDivider(),
              _buildTimelineStat(
                context,
                goal.isOverdue ? 'Days Overdue' : 'Days Left',
                '${goal.daysRemaining.abs()}',
                goal.isOverdue ? Icons.warning : Icons.schedule,
                goal.isOverdue
                    ? GoalsThemeExtended.goalWarning
                    : GoalsThemeExtended.goalSecondary,
              ),
              _buildVerticalDivider(),
              _buildTimelineStat(
                context,
                'Total Days',
                '$totalDays',
                Icons.calendar_today,
                const Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 400.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms);
  }

  Widget _buildTimelineMarker(
    BuildContext context,
    double position,
    String label,
    String date,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Positioned(
      left: position == 0.0
          ? 0
          : position == 1.0
              ? null
              : MediaQuery.of(context).size.width * position - 60,
      right: position == 1.0 ? 0 : null,
      top: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date label
          Text(
            date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? color : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),

          // Status label
          Text(
            label,
            style: AppTypographyExtended.datePillLabel.copyWith(
              color: isActive ? color : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),

          // Icon marker
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? color : AppColorsExtended.pillBgUnselected,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ).animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 200 + (position * 100).toInt()))
        .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, delay: Duration(milliseconds: 200 + (position * 100).toInt())),
    );
  }

  Widget _buildTimelineStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypographyExtended.statsValue.copyWith(
              color: color,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypographyExtended.statsLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColorsExtended.pillBgUnselected,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}