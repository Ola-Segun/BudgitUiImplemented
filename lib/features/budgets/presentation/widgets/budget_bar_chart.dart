import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import 'dart:math' as math;

/// An interactive bar chart for displaying weekly/monthly budget trends.
/// Features tooltips, animations, and gradient bars with customizable data.
class BudgetBarChart extends StatefulWidget {
  const BudgetBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.period,
    this.height = 240,
    this.showTooltip = true,
  });

  /// Chart data points
  final List<BudgetChartData> data;

  /// Chart title
  final String title;

  /// Period label (e.g., "Last Week", "Past Year")
  final String period;

  /// Chart height (height of the bar area only, not including header/labels)
  final double height;

  /// Whether to show interactive tooltips
  final bool showTooltip;

  @override
  State<BudgetBarChart> createState() => _BudgetBarChartState();
}

class _BudgetBarChartState extends State<BudgetBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredIndex;
  Offset? _tooltipPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getMaxValue() {
    if (widget.data.isEmpty) return 100;
    final max = widget.data.map((d) => d.value).reduce(math.max);
    return max == 0 ? 100 : max;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = _getMaxValue();

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTypographyExtended.statsValue.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.period.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColorsExtended.pillBgUnselected,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.period,
                          style: AppTypographyExtended.chartLabel.copyWith(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Total amount display
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(
                widget.data.fold(0.0, (sum, item) => sum + item.value),
              ),
              style: AppTypographyExtended.circularProgressPercentage.copyWith(
                color: AppColorsExtended.budgetPrimary,
                fontSize: 24,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Chart and labels container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chart area with fixed height
                SizedBox(
                  height: widget.height,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: _BudgetBarChartPainter(
                                  data: widget.data,
                                  maxValue: maxValue,
                                  animationValue: _animation.value,
                                  hoveredIndex: _hoveredIndex,
                                ),
                              );
                            },
                          ),

                          // Interactive overlay
                          if (widget.showTooltip)
                            GestureDetector(
                              onTapDown: (details) => _handleTap(details.localPosition, constraints.maxWidth, constraints.maxHeight),
                              onPanUpdate: (details) => _handlePan(details.localPosition, constraints.maxWidth, constraints.maxHeight),
                              onPanEnd: (_) => _clearTooltip(),
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),

                          // Tooltip
                          if (_hoveredIndex != null && _tooltipPosition != null && widget.showTooltip)
                            Positioned(
                              left: _tooltipPosition!.dx,
                              top: _tooltipPosition!.dy,
                              child: _ChartTooltip(
                                data: widget.data[_hoveredIndex!],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // X-axis labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.data.asMap().entries.map((entry) {
                    return Expanded(
                      child: Text(
                        entry.value.label,
                        style: AppTypographyExtended.chartLabel,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _handleTap(Offset position, double width, double height) {
    if (widget.data.isEmpty) return;
    
    final barWidth = width / widget.data.length;
    final index = (position.dx / barWidth).floor().clamp(0, widget.data.length - 1);

    setState(() {
      _hoveredIndex = index;
      final tooltipX = (position.dx - 40).clamp(0.0, width - 80);
      final tooltipY = (position.dy - 60).clamp(0.0, height - 40);
      _tooltipPosition = Offset(tooltipX, tooltipY);
    });
  }

  void _handlePan(Offset position, double width, double height) {
    _handleTap(position, width, height);
  }

  void _clearTooltip() {
    setState(() {
      _hoveredIndex = null;
      _tooltipPosition = null;
    });
  }
}

/// Data model for budget chart entries
class BudgetChartData {
  const BudgetChartData({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;
}

class _BudgetBarChartPainter extends CustomPainter {
  _BudgetBarChartPainter({
    required this.data,
    required this.maxValue,
    required this.animationValue,
    this.hoveredIndex,
  });

  final List<BudgetChartData> data;
  final double maxValue;
  final double animationValue;
  final int? hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue == 0) return;

    final chartHeight = size.height;
    final chartWidth = size.width;
    
    // Calculate bar dimensions with proper spacing
    final totalGapWidth = (data.length - 1) * 8.0;
    final barWidth = (chartWidth - totalGapWidth) / data.length;
    final maxBarHeight = chartHeight * 0.85; // Use 85% of height for bars

    // Draw Y-axis grid lines
    final gridPaint = Paint()
      ..color = AppColorsExtended.chartAxisLine.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = chartHeight - (i * chartHeight / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );
    }

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final barData = data[i];
      final x = i * (barWidth + 8);
      
      // Calculate bar height
      final normalizedHeight = (barData.value / maxValue) * maxBarHeight;
      final animatedHeight = normalizedHeight * animationValue;
      final y = chartHeight - animatedHeight;

      final isHovered = hoveredIndex == i;
      final barColor = barData.color ?? AppColorsExtended.budgetPrimary;

      // Skip if bar is too small
      if (animatedHeight < 2) continue;

      // Draw bar shadow
      final shadowPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 1, y + 1, barWidth, animatedHeight),
            const Radius.circular(6),
          ),
        );

      canvas.drawShadow(
        shadowPath,
        Colors.black.withValues(alpha: 0.1),
        isHovered ? 6 : 3,
        false,
      );

      // Draw bar with gradient
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, animatedHeight),
        const Radius.circular(6),
      );

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          barColor,
          barColor.withValues(alpha: 0.7),
        ],
      );

      final barPaint = Paint()
        ..shader = gradient.createShader(rect.outerRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, barPaint);

      // Highlight effect on hover
      if (isHovered) {
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rect, highlightPaint);
        
        // Draw highlight border
        final borderPaint = Paint()
          ..color = barColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rect, borderPaint);
      }

      // Draw value cap (top highlight)
      if (animatedHeight > 6) {
        final capRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, 3),
          const Radius.circular(2),
        );
        
        final capPaint = Paint()
          ..color = barColor.withValues(alpha: 1.0)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(capRect, capPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_BudgetBarChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.data != data;
  }
}

class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({required this.data});

  final BudgetChartData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorsExtended.chartTooltipBg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(data.value),
        style: AppTypographyExtended.chartTooltip,
      ),
    );
  }
}