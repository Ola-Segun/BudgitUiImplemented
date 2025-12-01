import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/design_system/models/circular_segment.dart';
import '../../../../core/design_system/widgets/segmented_circular_indicator.dart';
import '../../../../core/widgets/crash_detector.dart';
import '../../../settings/presentation/widgets/formatting_widgets.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/budget.dart' as budget_entity;
import '../../domain/models/aggregated_category.dart';

/// Enhanced category breakdown with segmented circular indicator
/// Matches Home/Transaction design aesthetics
class BudgetCategoryBreakdownEnhanced extends ConsumerStatefulWidget {
  const BudgetCategoryBreakdownEnhanced({
    super.key,
    required this.budget,
    required this.budgetStatus,
  });

  final budget_entity.Budget budget;
  final budget_entity.BudgetStatus budgetStatus;

  @override
  ConsumerState<BudgetCategoryBreakdownEnhanced> createState() =>
      _BudgetCategoryBreakdownEnhancedState();
}

class _BudgetCategoryBreakdownEnhancedState
    extends ConsumerState<BudgetCategoryBreakdownEnhanced> {
  String? _selectedCategoryId;
  List<CircularSegment>? _cachedSegments;

  @override
  void didUpdateWidget(BudgetCategoryBreakdownEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only invalidate cache if budget status actually changed
    if (oldWidget.budgetStatus != widget.budgetStatus) {
      _cachedSegments = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BudgetCategoryBreakdownEnhanced: Building with ${widget.budgetStatus.categoryStatuses.length} category statuses');

    try {
      // Validate input data
      if (widget.budgetStatus.totalBudget.isNaN || widget.budgetStatus.totalBudget.isInfinite) {
        debugPrint('BudgetCategoryBreakdownEnhanced: ERROR - Invalid total budget: ${widget.budgetStatus.totalBudget}');
        return _buildErrorState('Invalid budget amount data');
      }

      if (widget.budgetStatus.totalSpent.isNaN || widget.budgetStatus.totalSpent.isInfinite) {
        debugPrint('BudgetCategoryBreakdownEnhanced: ERROR - Invalid total spent: ${widget.budgetStatus.totalSpent}');
        return _buildErrorState('Invalid spending data');
      }

      // Read providers ONCE at start of build
      final categoryNotifier = ref.read(categoryNotifierProvider.notifier);
      final categoryIconColorService = ref.read(categoryIconColorServiceProvider);

      // Use cached segments or compute once
      _cachedSegments ??= _buildSegments(
        widget.budgetStatus.categoryStatuses,
        categoryNotifier,
        categoryIconColorService,
      );

      final segments = _cachedSegments!;

      debugPrint('BudgetCategoryBreakdownEnhanced: Generated ${segments.length} segments');

      if (segments.isEmpty) {
        debugPrint('BudgetCategoryBreakdownEnhanced: No segments, showing empty state');
        return _buildEmptyState();
      }

      return _buildContent(segments);
    } catch (e, stackTrace) {
      debugPrint('BudgetCategoryBreakdownEnhanced: CRITICAL - Error in build: $e');
      debugPrint('BudgetCategoryBreakdownEnhanced: Stack trace: $stackTrace');
      return _buildErrorState(e);
    }
  }

  Widget _buildContent(List<CircularSegment> segments) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient icon
          _buildHeader(),
          SizedBox(height: AppDimensions.spacing5),

          // Main segmented circular indicator with crash protection
          RepaintBoundary(
            child: Center(
              child: CrashBoundary(
                onCrash: (crash) {
                  debugPrint('BudgetCategoryBreakdownEnhanced: SegmentedCircularIndicator crashed: ${crash.message}');
                },
                child: SegmentedCircularIndicator(
                  segments: segments,
                  size: 240,
                  strokeWidth: 26,
                  centerTitle: 'Budget',
                  showPercentages: true,
                  showCenterValue: true,
                  onSegmentTap: (segment) {
                    setState(() {
                      _selectedCategoryId = segment.id;
                    });
                    _showCategoryDetails(segment);
                  },
                  interactionConfig: const SegmentInteractionConfig(
                    scaleOnTap: 1.12,
                    animationDuration: Duration(milliseconds: 350),
                    showLabelOnTap: true,
                    hapticFeedback: true,
                    glowIntensity: 0.5,
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.elasticOut,
                ),
            ),
          ),

          SizedBox(height: AppDimensions.spacing5),

          // Enhanced legend with interactive cards
          _buildEnhancedLegend(segments),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 300.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 300.ms);
  }


  Widget _buildHeader() {
    return Row(
      children: [
        // Gradient icon container
        Container(
          padding: EdgeInsets.all(AppDimensions.spacing2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorsExtended.budgetSecondary,
                AppColorsExtended.budgetSecondary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.donut_large,
            size: AppDimensions.iconMd,
            color: Colors.white,
          ),
        ),
        SizedBox(width: AppDimensions.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category Breakdown',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.budgetStatus.categoryStatuses.length} categories',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // View all button with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorsExtended.budgetPrimary.withValues(alpha: 0.1),
                AppColorsExtended.budgetPrimary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: TextButton(
            onPressed: () {
              // Navigate to detailed view
            },
            child: Text(
              'Details',
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColorsExtended.budgetPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.1, duration: 400.ms);
  }

  Widget _buildEnhancedLegend(List<CircularSegment> segments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section divider with label
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.borderSubtle,
                      AppColors.borderSubtle.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing3),
              child: Text(
                'SPENDING BY CATEGORY',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.borderSubtle.withValues(alpha: 0.0),
                      AppColors.borderSubtle,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing4),

        // Interactive category cards (instead of simple legend)
        ...segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final isSelected = segment.id == _selectedCategoryId;

          return Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacing3),
            child: _EnhancedCategoryCard(
              segment: segment,
              totalBudget: widget.budgetStatus.totalBudget,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategoryId = segment.id;
                });
                _showCategoryDetails(segment);
              },
            ).animate()
              .fadeIn(
                duration: 400.ms,
                delay: Duration(milliseconds: 300 + (index * 80)),
              )
              .slideX(
                begin: 0.1,
                duration: 400.ms,
                delay: Duration(milliseconds: 300 + (index * 80)),
              ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
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
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: AppColorsExtended.budgetSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pie_chart_outline,
              size: 56,
              color: AppColorsExtended.budgetSecondary,
            ),
          ),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'No spending data available',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 16,
            ),
          ),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            'Start spending to see your\ncategory breakdown',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
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
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'Failed to load category breakdown',
            style: AppTypographyExtended.statsValue.copyWith(
              fontSize: 16,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: AppDimensions.spacing2),
          Text(
            error.toString(),
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<CircularSegment> _buildSegments(
    List<budget_entity.CategoryStatus> categoryStatuses,
    dynamic categoryNotifier,
    dynamic categoryIconColorService,
  ) {
    try {
      debugPrint('BudgetCategoryBreakdownEnhanced: Building segments from ${categoryStatuses.length} category statuses');

      // Aggregate duplicate categories
      final aggregatedCategories = <String, AggregatedCategory>{};

      for (final categoryStatus in categoryStatuses) {
        if (categoryStatus.categoryId.isEmpty) {
          debugPrint('BudgetCategoryBreakdownEnhanced: WARNING - categoryStatus with null/empty ID found, skipping');
          continue;
        }

        // Validate numeric values
        final spent = (categoryStatus.spent ?? 0.0).clamp(0.0, double.infinity);
        final budget = (categoryStatus.budget ?? 0.0).clamp(0.0, double.infinity);

        // Values are now clamped above, so no need for additional checks

        debugPrint('BudgetCategoryBreakdownEnhanced: Processing category ${categoryStatus.categoryId}, spent: $spent, budget: $budget');
        final categoryId = categoryStatus.categoryId;
        if (aggregatedCategories.containsKey(categoryId)) {
          final existing = aggregatedCategories[categoryId]!;
          aggregatedCategories[categoryId] = AggregatedCategory(
            categoryId: categoryId,
            totalSpent: existing.totalSpent + spent,
            totalBudget: existing.totalBudget + budget,
            status: categoryStatus.status.index > existing.status
                ? categoryStatus.status.index
                : existing.status,
          );
        } else {
          aggregatedCategories[categoryId] = AggregatedCategory(
            categoryId: categoryId,
            totalSpent: spent,
            totalBudget: budget,
            status: categoryStatus.status.index ?? 0,
          );
        }
      }

      debugPrint('BudgetCategoryBreakdownEnhanced: Aggregated ${aggregatedCategories.length} categories');

      // Convert to segments
      final segments = aggregatedCategories.entries.map((entry) {
        debugPrint('BudgetCategoryBreakdownEnhanced: Converting category ${entry.value.categoryId} to segment');

        try {
          final transactionCategory =
              categoryNotifier.getCategoryById(entry.value.categoryId);
          final displayName = transactionCategory?.name ?? 'Unknown';
          final displayIcon = transactionCategory != null
              ? categoryIconColorService.getIconForCategory(transactionCategory.id)
              : Icons.category;
          final displayColor = transactionCategory != null
              ? categoryIconColorService.getColorForCategory(transactionCategory.id)
              : AppColors.primary;

          // Validate final values (already clamped above)
          final finalSpent = entry.value.totalSpent;

          debugPrint('BudgetCategoryBreakdownEnhanced: Segment created - name: $displayName, spent: $finalSpent');

          return CircularSegment(
            id: entry.value.categoryId,
            label: displayName,
            value: finalSpent,
            color: displayColor,
            icon: displayIcon,
            category: displayName,
            budget: entry.value.totalBudget,
          );
        } catch (e, stackTrace) {
          debugPrint('BudgetCategoryBreakdownEnhanced: Error creating segment for ${entry.value.categoryId}: $e');
          debugPrint('BudgetCategoryBreakdownEnhanced: Segment creation stack trace: $stackTrace');
          // Return a fallback segment
          return CircularSegment(
            id: entry.value.categoryId,
            label: 'Unknown',
            value: 0.0,
            color: AppColors.primary,
            icon: Icons.category,
            category: 'Unknown',
            budget: entry.value.totalBudget,
          );
        }
      }).toList()
        ..sort((a, b) => b.value.compareTo(a.value)); // Sort by spending

      debugPrint('BudgetCategoryBreakdownEnhanced: Final segments count: ${segments.length}');
      return segments;
    } catch (e, stackTrace) {
      debugPrint('BudgetCategoryBreakdownEnhanced: CRITICAL - Error building segments: $e');
      debugPrint('BudgetCategoryBreakdownEnhanced: Segments stack trace: $stackTrace');
      // Return empty list on error - will trigger empty state UI
      return [];
    }
  }

  void _showCategoryDetails(CircularSegment segment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryDetailsSheet(
        segment: segment,
        budget: widget.budget,
        budgetStatus: widget.budgetStatus,
      ),
    );
  }
}

/// Enhanced category card with trend and status
class _EnhancedCategoryCard extends StatelessWidget {
  const _EnhancedCategoryCard({
    required this.segment,
    required this.totalBudget,
    required this.isSelected,
    required this.onTap,
  });

  final CircularSegment segment;
  final double totalBudget;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = segment.value / segment.budget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.all(AppDimensions.spacing3),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      segment.color.withValues(alpha: 0.15),
                      segment.color.withValues(alpha: 0.08),
                    ],
                  )
                : null,
            color: isSelected ? null : AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: isSelected
                ? Border.all(
                    color: segment.color.withValues(alpha: 0.4),
                    width: 2,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: segment.color.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Animated icon with gradient background
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.all(
                  isSelected ? AppDimensions.spacing3 : AppDimensions.spacing2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      segment.color,
                      segment.color.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: segment.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  segment.icon,
                  size: isSelected ? 24 : 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppDimensions.spacing3),

              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.label,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Mini progress bar
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.borderSubtle,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      segment.color,
                                      segment.color.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: segment.color
                                                .withValues(alpha: 0.4),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacing2),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: segment.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: AppDimensions.spacing2),

              // Amount with trend
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PrivacyModeAmount(
                    amount: segment.value,
                    currency: '\$',
                    style: AppTypographyExtended.statsValue.copyWith(
                      fontSize: 16,
                      color: segment.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Status indicator
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: segment.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          segment.value > segment.budget
                              ? Icons.warning
                              : Icons.check_rounded,
                          size: 10,
                          color: segment.value > segment.budget
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          segment.value > segment.budget ? 'Over' : 'OK',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: segment.value > segment.budget
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Chevron indicator
              SizedBox(width: AppDimensions.spacing2),
              AnimatedRotation(
                duration: const Duration(milliseconds: 250),
                turns: isSelected ? 0.25 : 0,
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isSelected
                      ? segment.color
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category details bottom sheet
class _CategoryDetailsSheet extends StatelessWidget {
  const _CategoryDetailsSheet({
    required this.segment,
    required this.budget,
    required this.budgetStatus,
  });

  final CircularSegment segment;
  final budget_entity.Budget budget;
  final budget_entity.BudgetStatus budgetStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: AppDimensions.spacing3),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacing3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        segment.color,
                        segment.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: segment.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    segment.icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.label,
                        style: AppTypographyExtended.circularProgressPercentage
                            .copyWith(
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      PrivacyModeAmount(
                        amount: segment.value,
                        currency: '\$',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: segment.color,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  iconSize: 24,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content (transactions, insights, etc.)
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.spacing5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats grid
                  _buildStatsGrid(segment),
                  SizedBox(height: AppDimensions.spacing5),

                  // Progress visualization
                  _buildProgressSection(segment),
                  SizedBox(height: AppDimensions.spacing5),

                  // Transactions list placeholder
                  Text(
                    'Recent Transactions',
                    style: AppTypographyExtended.statsValue.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing3),
                  Container(
                    padding: EdgeInsets.all(AppDimensions.spacing4),
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Center(
                      child: Text(
                        'Transactions will be shown here',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(CircularSegment segment) {

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Spent',
            segment: segment,
            icon: Icons.trending_up,
            color: segment.color,
            isSpent: true,
          ),
        ),
        SizedBox(width: AppDimensions.spacing3),
        Expanded(
          child: _StatCard(
            label: 'Budget',
            segment: segment,
            icon: Icons.account_balance_wallet,
            color: AppColors.textSecondary,
            isSpent: false,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(CircularSegment segment) {
    final percentage = segment.value / segment.budget;

    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            segment.color.withValues(alpha: 0.1),
            segment.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: segment.color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTypographyExtended.metricLabel.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 18,
                  color: segment.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing3),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(segment.color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends ConsumerWidget {
  const _StatCard({
    required this.label,
    required this.segment,
    required this.icon,
    required this.color,
    required this.isSpent,
  });

  final String label;
  final CircularSegment segment;
  final IconData icon;
  final Color color;
  final bool isSpent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing3),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.borderSubtle,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: AppDimensions.spacing2),
          isSpent
              ? PrivacyModeAmount(
                  amount: segment.value,
                  currency: '\$',
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 18,
                    color: color,
                  ),
                )
              : SettingsCurrencyText(
                  amount: segment.budget,
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 18,
                    color: color,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
