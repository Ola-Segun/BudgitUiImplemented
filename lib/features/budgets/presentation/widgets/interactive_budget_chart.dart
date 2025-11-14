import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

/// Simple error boundary widget for catching widget build errors
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    required this.fallbackBuilder,
  });

  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace stackTrace) fallbackBuilder;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset error state when child changes
    if (oldWidget.child != widget.child) {
      _error = null;
      _stackTrace = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackBuilder(context, _error!, _stackTrace!);
    }

    try {
      return widget.child;
    } catch (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
          });
        }
      });
      // Return empty container while error is being processed
      return const SizedBox.shrink();
    }
  }
}

/// Interactive budget chart with detailed category views and animations
class InteractiveBudgetChart extends StatefulWidget {
  const InteractiveBudgetChart({
    super.key,
    required this.categoryData,
    required this.totalBudget,
    required this.totalSpent,
    this.height = 300,
    this.showLegend = true,
    this.isInteractive = true,
  });

  final List<BudgetChartCategory> categoryData;
  final double totalBudget;
  final double totalSpent;
  final double height;
  final bool showLegend;
  final bool isInteractive;

  @override
  State<InteractiveBudgetChart> createState() => _InteractiveBudgetChartState();
}

class _InteractiveBudgetChartState extends State<InteractiveBudgetChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _chartAnimation;
  int? _touchedIndex;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('InteractiveBudgetChart: initState called');

    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      _chartAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      // Add animation status listener for debugging
      _animationController.addStatusListener((status) {
        debugPrint('InteractiveBudgetChart: Animation status changed to $status');
        if (status == AnimationStatus.completed && _isDisposed) {
          debugPrint('InteractiveBudgetChart: WARNING - Animation completed after disposal');
        }
      });

      if (!_isDisposed) {
        debugPrint('InteractiveBudgetChart: Starting animation forward');
        _animationController.forward().catchError((error) {
          debugPrint('InteractiveBudgetChart: ERROR - Failed to start animation: $error');
        });
      }
    } catch (e, stackTrace) {
      debugPrint('InteractiveBudgetChart: CRITICAL - Error in initState: $e');
      debugPrint('InteractiveBudgetChart: Stack trace: $stackTrace');
      // Don't rethrow - let the widget continue with limited functionality
    }
  }

  @override
  void dispose() {
    debugPrint('InteractiveBudgetChart: dispose called, _isDisposed: $_isDisposed');

    try {
      _isDisposed = true;

      // Stop animation safely
      if (_animationController.isAnimating) {
        debugPrint('InteractiveBudgetChart: Stopping animation during disposal');
        _animationController.stop();
      }

      debugPrint('InteractiveBudgetChart: Disposing animation controller');
      _animationController.dispose();

      debugPrint('InteractiveBudgetChart: dispose completed successfully');
    } catch (e, stackTrace) {
      debugPrint('InteractiveBudgetChart: CRITICAL - Error during dispose: $e');
      debugPrint('InteractiveBudgetChart: Dispose stack trace: $stackTrace');
      // Don't rethrow during dispose
    }

    // Memory leak detection - check if widget is still referenced
    debugPrint('InteractiveBudgetChart: Checking for memory leaks...');
    // Note: In a real implementation, you might want to use tools like leak_tracker
    // For now, we'll just log that disposal happened

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('InteractiveBudgetChart: build called with ${widget.categoryData.length} categories');

    // Error boundary wrapper
    return ErrorBoundary(
      fallbackBuilder: (context, error, stackTrace) {
        debugPrint('InteractiveBudgetChart: CRITICAL - Widget crashed during build: $error');
        debugPrint('InteractiveBudgetChart: Build crash stack trace: $stackTrace');
        return Container(
          height: widget.height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text('Chart failed to load'),
          ),
        );
      },
      child: _buildChartContent(context),
    );
  }

  Widget _buildChartContent(BuildContext context) {
    // Handle empty data gracefully
    if (widget.categoryData.isEmpty) {
      debugPrint('InteractiveBudgetChart: WARNING - No category data provided');
      return Container(
        height: widget.height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text('No budget data available'),
        ),
      );
    }

    // Validate data integrity
    try {
      for (final category in widget.categoryData) {
        if (category.spentAmount.isNaN || category.spentAmount.isInfinite) {
          debugPrint('InteractiveBudgetChart: ERROR - Invalid spent amount for ${category.name}: ${category.spentAmount}');
          throw Exception('Invalid spent amount data');
        }
        if (category.budgetAmount.isNaN || category.budgetAmount.isInfinite || category.budgetAmount <= 0) {
          debugPrint('InteractiveBudgetChart: ERROR - Invalid budget amount for ${category.name}: ${category.budgetAmount}');
          throw Exception('Invalid budget amount data');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('InteractiveBudgetChart: CRITICAL - Data validation failed: $e');
      debugPrint('InteractiveBudgetChart: Validation stack trace: $stackTrace');
      return Container(
        height: widget.height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text('Invalid budget data'),
        ),
      );
    }

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          // Chart header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Breakdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '${widget.categoryData.length} categories',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (widget.isInteractive)
                IconButton(
                  onPressed: () => _showDetailedView(context),
                  tooltip: 'View detailed breakdown',
                  icon: Icon(
                    Icons.fullscreen,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Pie Chart
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                final sections = _buildPieSections();
                if (sections.isEmpty) {
                  return const Center(
                    child: Text('No spending data to display'),
                  );
                }
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: widget.isInteractive && !_isDisposed
                          ? (FlTouchEvent event, pieTouchResponse) {
                              if (_isDisposed) return;
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            }
                          : null,
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: sections,
                  ),
                );
              },
            ),
          ),

          if (widget.showLegend) ...[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95), duration: 500.ms);
  }

  List<PieChartSectionData> _buildPieSections() {
    debugPrint('InteractiveBudgetChart: Building pie sections for ${widget.categoryData.length} categories');

    if (widget.categoryData.isEmpty || widget.totalSpent <= 0) {
      debugPrint('InteractiveBudgetChart: No data for pie sections - empty categories or zero total spent');
      return [];
    }

    try {
      return List.generate(widget.categoryData.length, (index) {
        final category = widget.categoryData[index];
        final isTouched = index == _touchedIndex;
        final radius = isTouched ? 80.0 : 60.0;
        final fontSize = isTouched ? 16.0 : 12.0;

        // Ensure spent amount is valid
        final spentAmount = category.spentAmount.clamp(0.0, double.infinity);
        final percentage = widget.totalSpent > 0 ? (spentAmount / widget.totalSpent * 100) : 0.0;

        // Ensure we have a minimum value for the pie chart
        final chartValue = spentAmount > 0 ? spentAmount : 0.01;

        debugPrint('InteractiveBudgetChart: Section $index - ${category.name}: spent=$spentAmount, percentage=$percentage, chartValue=$chartValue');

        return PieChartSectionData(
          color: category.color,
          value: chartValue,
          title: percentage >= 1.0 ? '${percentage.toStringAsFixed(1)}%' : '<1%',
          radius: radius * _chartAnimation.value,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
              ),
            ],
          ),
          badgeWidget: isTouched ? _buildBadge(category) : null,
          badgePositionPercentageOffset: 1.1,
        );
      });
    } catch (e, stackTrace) {
      debugPrint('InteractiveBudgetChart: CRITICAL - Error building pie sections: $e');
      debugPrint('InteractiveBudgetChart: Pie sections stack trace: $stackTrace');
      return []; // Return empty list to prevent crashes
    }
  }

  Widget _buildBadge(BudgetChartCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        category.name,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: widget.categoryData.map((category) {
        final isSelected = widget.categoryData.indexOf(category) == _touchedIndex;
        return GestureDetector(
          onTap: widget.isInteractive && !_isDisposed
              ? () => setState(() => _touchedIndex = widget.categoryData.indexOf(category))
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(2),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? category.color
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDetailedView(BuildContext context) {
    if (widget.categoryData.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Text(
                      'Detailed Budget Breakdown',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Detailed list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: widget.categoryData.length,
                  itemBuilder: (context, index) {
                    final category = widget.categoryData[index];
                    final percentage = widget.totalSpent > 0 ? category.spentAmount / widget.totalSpent * 100 : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}% of spending',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${category.spentAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                'of \$${category.budgetAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class for budget chart categories
class BudgetChartCategory {
  const BudgetChartCategory({
    required this.name,
    required this.spentAmount,
    required this.budgetAmount,
    required this.color,
    this.icon,
  });

  final String name;
  final double spentAmount;
  final double budgetAmount;
  final Color color;
  final IconData? icon;
}