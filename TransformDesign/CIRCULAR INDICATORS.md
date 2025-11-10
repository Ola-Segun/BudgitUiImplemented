🎯 COMPREHENSIVE GUIDE: INTERACTIVE SEGMENTED CIRCULAR INDICATORS
📋 TABLE OF CONTENTS

Core Segmented Circular Indicator
Enhanced Interactive Features
Category Management System
Integration Patterns
Usage Examples
Migration Guide


PART 1: CORE SEGMENTED CIRCULAR INDICATOR
1.1 Segment Data Model
dart// lib/core/design_system/models/circular_segment.dart

import 'package:flutter/material.dart';

/// Represents a single segment in the circular indicator
class CircularSegment {
  const CircularSegment({
    required this.id,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.category,
  });

  final String id;
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final String? category;

  /// Calculate percentage of total
  double getPercentage(double total) {
    return total > 0 ? (value / total) : 0.0;
  }

  /// Get sweep angle in radians
  double getSweepAngle(double total) {
    return getPercentage(total) * 2 * 3.141592653589793;
  }

  CircularSegment copyWith({
    String? id,
    String? label,
    double? value,
    Color? color,
    IconData? icon,
    String? category,
  }) {
    return CircularSegment(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      category: category ?? this.category,
    );
  }
}

/// Configuration for segment interaction
class SegmentInteractionConfig {
  const SegmentInteractionConfig({
    this.scaleOnTap = 1.08,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showLabelOnTap = true,
    this.hapticFeedback = true,
    this.glowIntensity = 0.4,
  });

  final double scaleOnTap;
  final Duration animationDuration;
  final bool showLabelOnTap;
  final bool hapticFeedback;
  final double glowIntensity;
}
1.2 Segmented Circular Indicator Widget
dart// lib/core/design_system/widgets/segmented_circular_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../models/circular_segment.dart';

/// Interactive segmented circular indicator with category breakdown
/// 
/// Features:
/// - Multi-segment visualization
/// - Interactive segment selection
/// - Animated transitions
/// - Category labels and icons
/// - Smooth scaling on tap
/// - Center summary display
/// 
/// Usage:
/// ```dart
/// SegmentedCircularIndicator(
///   segments: [
///     CircularSegment(
///       id: 'food',
///       label: 'Food',
///       value: 450,
///       color: ColorTokens.warning500,
///       icon: Icons.restaurant,
///       category: 'Food & Dining',
///     ),
///     CircularSegment(
///       id: 'transport',
///       label: 'Transport',
///       value: 250,
///       color: ColorTokens.info500,
///       icon: Icons.directions_car,
///       category: 'Transportation',
///     ),
///   ],
///   size: 240,
///   strokeWidth: 24,
///   onSegmentTap: (segment) => print('Tapped: ${segment.label}'),
/// )
/// ```
class SegmentedCircularIndicator extends StatefulWidget {
  const SegmentedCircularIndicator({
    super.key,
    required this.segments,
    this.size = 240,
    this.strokeWidth = 24,
    this.centerTitle = 'Total',
    this.showPercentages = true,
    this.showCenterValue = true,
    this.onSegmentTap,
    this.onSegmentLongPress,
    this.interactionConfig = const SegmentInteractionConfig(),
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  final List<CircularSegment> segments;
  final double size;
  final double strokeWidth;
  final String centerTitle;
  final bool showPercentages;
  final bool showCenterValue;
  final ValueChanged<CircularSegment>? onSegmentTap;
  final ValueChanged<CircularSegment>? onSegmentLongPress;
  final SegmentInteractionConfig interactionConfig;
  final Duration animationDuration;

  @override
  State<SegmentedCircularIndicator> createState() => _SegmentedCircularIndicatorState();
}

class _SegmentedCircularIndicatorState extends State<SegmentedCircularIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _interactionController;
  late Animation<double> _progressAnimation;
  
  String? _selectedSegmentId;
  Offset? _labelPosition;

  @override
  void initState() {
    super.initState();
    
    // Progress animation (initial load)
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    // Interaction animation (tap/hover)
    _interactionController = AnimationController(
      duration: widget.interactionConfig.animationDuration,
      vsync: this,
    );
    
    _progressController.forward();
  }

  @override
  void didUpdateWidget(SegmentedCircularIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments) {
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  double get _totalValue {
    return widget.segments.fold(0.0, (sum, segment) => sum + segment.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _interactionController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular segments
              GestureDetector(
                onTapDown: (details) => _handleTapDown(details),
                onTapUp: (details) => _handleTapUp(),
                onTapCancel: () => _handleTapUp(),
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _SegmentedCircularPainter(
                    segments: widget.segments,
                    progress: _progressAnimation.value,
                    selectedSegmentId: _selectedSegmentId,
                    interactionProgress: _interactionController.value,
                    strokeWidth: widget.strokeWidth,
                    scaleAmount: widget.interactionConfig.scaleOnTap,
                    glowIntensity: widget.interactionConfig.glowIntensity,
                  ),
                ),
              ),
              
              // Center content
              _buildCenterContent(),
              
              // Floating label for selected segment
              if (_selectedSegmentId != null && _labelPosition != null)
                _buildFloatingLabel(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterContent() {
    final selectedSegment = _selectedSegmentId != null
        ? widget.segments.firstWhere(
            (s) => s.id == _selectedSegmentId,
            orElse: () => widget.segments.first,
          )
        : null;

    if (selectedSegment != null) {
      return _buildSelectedSegmentInfo(selectedSegment);
    }

    return _buildTotalInfo();
  }

  Widget _buildTotalInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showCenterValue)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: _totalValue),
            duration: widget.animationDuration,
            builder: (context, value, child) {
              return Text(
                '\$${value.toInt()}',
                style: TypographyTokens.numericXl.copyWith(
                  fontSize: 36,
                  color: ColorTokens.textPrimary,
                ),
              );
            },
          ),
        const SizedBox(height: 4),
        Text(
          widget.centerTitle,
          style: TypographyTokens.labelMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSegmentInfo(CircularSegment segment) {
    final percentage = segment.getPercentage(_totalValue);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: segment.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  segment.icon,
                  size: DesignTokens.iconLg,
                  color: segment.color,
                ),
              ),
              SizedBox(height: DesignTokens.spacing2),
              Text(
                '\$${segment.value.toInt()}',
                style: TypographyTokens.numericLg.copyWith(
                  color: segment.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TypographyTokens.labelSm.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                segment.label,
                style: TypographyTokens.captionMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingLabel() {
    final segment = widget.segments.firstWhere((s) => s.id == _selectedSegmentId);
    
    return Positioned(
      left: _labelPosition!.dx - 40,
      top: _labelPosition!.dy - 40,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing3,
                vertical: DesignTokens.spacing2,
              ),
              decoration: BoxDecoration(
                color: segment.color,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: segment.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    segment.icon,
                    size: DesignTokens.iconSm,
                    color: ColorTokens.textInverse,
                  ),
                  SizedBox(width: DesignTokens.spacing1),
                  Text(
                    segment.label,
                    style: TypographyTokens.labelSm.copyWith(
                      color: ColorTokens.textInverse,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final touchPoint = details.localPosition;
    final segment = _getSegmentAtPosition(touchPoint, center);
    
    if (segment != null) {
      if (widget.interactionConfig.hapticFeedback) {
        HapticFeedback.selectionClick();
      }
      
      setState(() {
        _selectedSegmentId = segment.id;
        _labelPosition = _calculateLabelPosition(touchPoint, center);
      });
      
      _interactionController.forward();
      widget.onSegmentTap?.call(segment);
    }
  }

  void _handleTapUp() {
    _interactionController.reverse();
    
    Future.delayed(widget.interactionConfig.animationDuration, () {
      if (mounted) {
        setState(() {
          _selectedSegmentId = null;
          _labelPosition = null;
        });
      }
    });
  }

  CircularSegment? _getSegmentAtPosition(Offset touchPoint, Offset center) {
    final dx = touchPoint.dx - center.dx;
    final dy = touchPoint.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Check if touch is within ring
    final innerRadius = (widget.size - widget.strokeWidth) / 2 - widget.strokeWidth;
    final outerRadius = widget.size / 2;
    
    if (distance < innerRadius || distance > outerRadius) {
      return null;
    }
    
    // Calculate angle
    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    
    // Find segment at angle
    double currentAngle = 0;
    for (final segment in widget.segments) {
      final sweepAngle = segment.getSweepAngle(_totalValue);
      if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
        return segment;
      }
      currentAngle += sweepAngle;
    }
    
    return null;
  }

  Offset _calculateLabelPosition(Offset touchPoint, Offset center) {
    final dx = touchPoint.dx - center.dx;
    final dy = touchPoint.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    if (distance == 0) return touchPoint;
    
    final labelDistance = widget.size / 2 + 20;
    final normalizedDx = dx / distance;
    final normalizedDy = dy / distance;
    
    return Offset(
      center.dx + normalizedDx * labelDistance,
      center.dy + normalizedDy * labelDistance,
    );
  }
}

/// Custom painter for segmented circular indicator
class _SegmentedCircularPainter extends CustomPainter {
  _SegmentedCircularPainter({
    required this.segments,
    required this.progress,
    required this.selectedSegmentId,
    required this.interactionProgress,
    required this.strokeWidth,
    required this.scaleAmount,
    required this.glowIntensity,
  });

  final List<CircularSegment> segments;
  final double progress;
  final String? selectedSegmentId;
  final double interactionProgress;
  final double strokeWidth;
  final double scaleAmount;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final totalValue = segments.fold(0.0, (sum, s) => sum + s.value);
    
    if (totalValue == 0) return;
    
    double startAngle = -math.pi / 2;
    
    for (final segment in segments) {
      final sweepAngle = segment.getSweepAngle(totalValue) * progress;
      final isSelected = segment.id == selectedSegmentId;
      
      _drawSegment(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle,
        segment,
        isSelected,
      );
      
      startAngle += sweepAngle;
    }
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    CircularSegment segment,
    bool isSelected,
  ) {
    final effectiveRadius = isSelected
        ? radius + (strokeWidth * (scaleAmount - 1.0) * interactionProgress / 2)
        : radius;
    
    final rect = Rect.fromCircle(center: center, radius: effectiveRadius);
    
    // Draw glow for selected segment
    if (isSelected && interactionProgress > 0) {
      final glowPaint = Paint()
        ..color = segment.color.withValues(alpha: glowIntensity * interactionProgress)
        ..strokeWidth = strokeWidth + 12 * interactionProgress
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          8 * interactionProgress,
        );
      
      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    }
    
    // Draw segment with gradient
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [
        segment.color,
        segment.color.withValues(alpha: 0.8),
        segment.color,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final segmentPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth + (isSelected ? strokeWidth * 0.2 * interactionProgress : 0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, segmentPaint);
    
    // Draw separator lines between segments
    if (sweepAngle < 2 * math.pi - 0.01) {
      final separatorPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final endAngle = startAngle + sweepAngle;
      final innerRadius = effectiveRadius - strokeWidth / 2;
      final outerRadius = effectiveRadius + strokeWidth / 2;
      
      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(endAngle),
        center.dy + innerRadius * math.sin(endAngle),
      );
      
      final outerPoint = Offset(
        center.dx + outerRadius * math.cos(endAngle),
        center.dy + outerRadius * math.sin(endAngle),
      );
      
      canvas.drawLine(innerPoint, outerPoint, separatorPaint);
    }
  }

  @override
  bool shouldRepaint(_SegmentedCircularPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedSegmentId != selectedSegmentId ||
        oldDelegate.interactionProgress != interactionProgress ||
        oldDelegate.segments != segments;
  }
}

PART 2: ENHANCED INTERACTIVE FEATURES
2.1 Segment Legend Widget
dart// lib/core/design_system/widgets/segment_legend.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../models/circular_segment.dart';

/// Legend display for circular segments
/// 
/// Usage:
/// ```dart
/// SegmentLegend(
///   segments: segments,
///   totalValue: 1000,
///   selectedSegmentId: 'food',
///   onSegmentTap: (segment) => setState(() => selected = segment.id),
/// )
/// ```
class SegmentLegend extends StatelessWidget {
  const SegmentLegend({
    super.key,
    required this.segments,
    required this.totalValue,
    this.selectedSegmentId,
    this.onSegmentTap,
    this.showPercentages = true,
    this.showValues = true,
    this.compact = false,
  });

  final List<CircularSegment> segments;
  final double totalValue;
  final String? selectedSegmentId;
  final ValueChanged<CircularSegment>? onSegmentTap;
  final bool showPercentages;
  final bool showValues;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isSelected = segment.id == selectedSegmentId;
        
        return _buildLegendItem(segment, index, isSelected);
      }).toList(),
    );
  }

  Widget _buildLegendItem(CircularSegment segment, int index, bool isSelected) {
    final percentage = segment.getPercentage(totalValue);
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: compact ? DesignTokens.spacing2 : DesignTokens.spacing3,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSegmentTap != null ? () => onSegmentTap!(segment) : null,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: AnimatedContainer(
            duration: DesignTokens.durationSm,
            padding: EdgeInsets.all(compact ? DesignTokens.spacing2 : DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: isSelected
                  ? segment.color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: isSelected
                  ? Border.all(color: segment.color, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                // Color indicator
                AnimatedContainer(
                  duration: DesignTokens.durationSm,
                  width: compact ? 12 : 16,
                  height: compact ? 12 : 16,
                  decoration: BoxDecoration(
                    color: segment.color,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: segment.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(width: compact ? DesignTokens.spacing2 : DesignTokens.spacing3),
                
                // Icon
                Container(
                  padding: EdgeInsets.all(compact ? DesignTokens.spacing1 : DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: segment.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Icon(
                    segment.icon,
                    size: compact ? DesignTokens.iconSm : DesignTokens.iconMd,
                    color: segment.color,
                  ),
                ),
                SizedBox(width: compact ? DesignTokens.spacing2 : DesignTokens.spacing3),
                
                // Label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.label,
                        style: (compact
                            ? TypographyTokens.bodySm
                            : TypographyTokens.bodyMd
                        ).copyWith(
                          fontWeight: isSelected
                              ? TypographyTokens.weightSemiBold
                              : TypographyTokens.weightRegular,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (segment.category != null && !compact) ...[
                        const SizedBox(height: 2),
                        Text(
                          segment.category!,
                          style: TypographyTokens.captionSm.copyWith(
                            color: ColorTokens.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Values
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showValues)
                      Text(
                        '\$${segment.value.toInt()}',
                        style: (compact
                            ? TypographyTokens.labelSm
                            : TypographyTokens.labelMd
                        ).copyWith(
                          color: segment.color,
                          fontWeight: TypographyTokens.weightBold,
                        ),
                      ),
                    if (showPercentages) ...[
                      if (showValues) const SizedBox(height: 2),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: TypographyTokens.captionSm.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate()
        .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 50 * index))
        .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 50 * index)),
    );
  }
}
2.2 Complete Interactive Card Pattern
dart// lib/core/design_system/patterns/segmented_indicator_card_pattern.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../models/circular_segment.dart';
import '../widgets/segmented_circular_indicator.dart';
import '../widgets/segment_legend.dart';

/// Complete card with segmented circular indicator and legend
/// 
/// Usage:
/// ```dart
/// SegmentedIndicatorCardPattern(
///   title: 'Spending Breakdown',
///   segments: categorySegments,
///   onViewAll: () => navigateToCategoryDetails(),
/// )
/// ```
class SegmentedIndicatorCardPattern extends StatefulWidget {
  const SegmentedIndicatorCardPattern({
    super.key,
    required this.title,
    required this.segments,
    this.subtitle,
    this.icon = Icons.pie_chart,
    this.iconColor,
    this.centerTitle = 'Total',
    this.onViewAll,
    this.onSegmentTap,
    this.showLegend = true,
    this.compactLegend = false,
    this.indicatorSize = 240,
  });

  final String title;
  final List<CircularSegment> segments;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final String centerTitle;
  final VoidCallback? onViewAll;
  final ValueChanged<CircularSegment>? onSegmentTap;
  final bool showLegend;
  final bool compactLegend;
  final double indicatorSize;

  @override
  State<SegmentedIndicatorCardPattern> createState() =>
      _SegmentedIndicatorCardPatternState();
}

class _SegmentedIndicatorCardPatternState
    extends State<SegmentedIndicatorCardPattern> {
  String? _selectedSegmentId;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ?? ColorTokens.teal500;
    final totalValue = widget.segments.fold(0.0, (sum, s) => sum + s.value);

    return Container(
      padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: ColorTokens.withOpacity(effectiveIconColor, 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  widget.icon,
                  size: DesignTokens.iconMd,
                  color: effectiveIconColor,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TypographyTokens.heading6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,RetrySContinuedart                        style: TypographyTokens.captionMd.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.onViewAll != null) ...[
                SizedBox(width: DesignTokens.spacing2),
                TextButton(
                  onPressed: widget.onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: effectiveIconColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing3,
                      vertical: DesignTokens.spacing2,
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: TypographyTokens.labelSm,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: DesignTokens.spacing5),

          // Circular Indicator
          Center(
            child: SegmentedCircularIndicator(
              segments: widget.segments,
              size: widget.indicatorSize,
              strokeWidth: 24,
              centerTitle: widget.centerTitle,
              onSegmentTap: (segment) {
                setState(() {
                  _selectedSegmentId = segment.id;
                });
                widget.onSegmentTap?.call(segment);
              },
            ),
          ),

          if (widget.showLegend) ...[
            SizedBox(height: DesignTokens.spacing5),
            
            // Legend
            SegmentLegend(
              segments: widget.segments,
              totalValue: totalValue,
              selectedSegmentId: _selectedSegmentId,
              compact: widget.compactLegend,
              onSegmentTap: (segment) {
                setState(() {
                  _selectedSegmentId = segment.id;
                });
                widget.onSegmentTap?.call(segment);
              },
            ),
          ],
        ],
      ),
    );
  }
}

PART 3: CATEGORY MANAGEMENT SYSTEM
3.1 Category Data Provider
dart// lib/features/categories/domain/entities/category.dart

import 'package:flutter/material.dart';

/// Transaction category with visual properties
class TransactionCategory {
  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.parentId,
    this.type = CategoryType.expense,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? parentId;
  final CategoryType type;

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
      parentId: json['parentId'] as String?,
      type: CategoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CategoryType.expense,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'parentId': parentId,
      'type': type.name,
    };
  }
}

enum CategoryType {
  income,
  expense,
  transfer,
}

// lib/features/categories/data/default_categories.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../domain/entities/category.dart';

/// Default categories with consistent design system colors
class DefaultCategories {
  static final List<TransactionCategory> expenseCategories = [
    TransactionCategory(
      id: 'food_dining',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: AppColorsExtended.categoryOrange,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'transportation',
      name: 'Transportation',
      icon: Icons.directions_car,
      color: AppColorsExtended.categoryBlue,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: AppColorsExtended.categoryPink,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: AppColorsExtended.categoryPurple,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.bolt,
      color: AppColorsExtended.categoryYellow,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'healthcare',
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: AppColorsExtended.categoryRed,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      color: AppColorsExtended.categoryIndigo,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'personal_care',
      name: 'Personal Care',
      icon: Icons.spa,
      color: AppColorsExtended.categoryTeal,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'housing',
      name: 'Housing',
      icon: Icons.home,
      color: AppColorsExtended.categoryBrown,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'other_expense',
      name: 'Other',
      icon: Icons.more_horiz,
      color: AppColorsExtended.categoryGray,
      type: CategoryType.expense,
    ),
  ];

  static final List<TransactionCategory> incomeCategories = [
    TransactionCategory(
      id: 'salary',
      name: 'Salary',
      icon: Icons.payments,
      color: AppColorsExtended.categoryGreen,
      type: CategoryType.income,
    ),
    TransactionCategory(
      id: 'business',
      name: 'Business',
      icon: Icons.business_center,
      color: AppColorsExtended.categoryBlue,
      type: CategoryType.income,
    ),
    TransactionCategory(
      id: 'investment',
      name: 'Investment',
      icon: Icons.trending_up,
      color: AppColorsExtended.categoryPurple,
      type: CategoryType.income,
    ),
    TransactionCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.work,
      color: AppColorsExtended.categoryOrange,
      type: CategoryType.income,
    ),
    TransactionCategory(
      id: 'rental',
      name: 'Rental',
      icon: Icons.apartment,
      color: AppColorsExtended.categoryTeal,
      type: CategoryType.income,
    ),
    TransactionCategory(
      id: 'other_income',
      name: 'Other',
      icon: Icons.more_horiz,
      color: AppColorsExtended.categoryGray,
      type: CategoryType.income,
    ),
  ];

  static TransactionCategory? getCategoryById(String id) {
    try {
      return [...expenseCategories, ...incomeCategories]
          .firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<TransactionCategory> getCategoriesByType(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return expenseCategories;
      case CategoryType.income:
        return incomeCategories;
      case CategoryType.transfer:
        return [];
    }
  }
}
3.2 Category Color Extensions
dart// lib/core/theme/app_colors_extended.dart (additions)

import 'package:flutter/material.dart';

class AppColorsExtended {
  // ... existing colors ...

  // Category-specific colors (matching design system)
  static const Color categoryOrange = Color(0xFFF59E0B);  // Food, Freelance
  static const Color categoryBlue = Color(0xFF3B82F6);     // Transport, Business
  static const Color categoryPink = Color(0xFFEC4899);     // Shopping
  static const Color categoryPurple = Color(0xFF8B5CF6);   // Entertainment, Investment
  static const Color categoryYellow = Color(0xFFEAB308);   // Utilities
  static const Color categoryRed = Color(0xFFEF4444);      // Healthcare
  static const Color categoryIndigo = Color(0xFF6366F1);   // Education
  static const Color categoryTeal = Color(0xFF14B8A6);     // Personal Care, Rental
  static const Color categoryGreen = Color(0xFF10B981);    // Salary (success)
  static const Color categoryBrown = Color(0xFF92400E);    // Housing
  static const Color categoryGray = Color(0xFF6B7280);     // Other

  /// Get category color palette (lighter shades for backgrounds)
  static Color getCategoryLightColor(Color baseColor) {
    return baseColor.withValues(alpha: 0.1);
  }

  /// Get contrasting text color for category
  static Color getCategoryTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? const Color(0xFF111827)
        : const Color(0xFFFFFFFF);
  }
}

PART 4: INTEGRATION PATTERNS
4.1 Transaction Category Breakdown Provider
dart// lib/features/transactions/presentation/providers/category_breakdown_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../../core/design_system/models/circular_segment.dart';
import '../../../categories/data/default_categories.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_providers.dart';

/// Provider for category breakdown segments
final categoryBreakdownProvider = Provider.family<List<CircularSegment>, CategoryBreakdownParams>(
  (ref, params) {
    final transactions = ref.watch(transactionNotifierProvider).value ?? [];
    
    // Filter transactions by type and date range
    final filteredTransactions = transactions.where((t) {
      final isCorrectType = params.type == null || t.type == params.type;
      final isInDateRange = params.startDate == null ||
          (t.date.isAfter(params.startDate!) &&
              t.date.isBefore(params.endDate ?? DateTime.now()));
      return isCorrectType && isInDateRange;
    }).toList();

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (final transaction in filteredTransactions) {
      final categoryId = transaction.categoryId ?? 'other';
      categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + transaction.amount;
    }

    // Sort by amount descending
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top N categories
    final topCategories = sortedEntries.take(params.maxCategories ?? 10).toList();
    
    // Group remaining as "Other"
    final otherTotal = sortedEntries
        .skip(params.maxCategories ?? 10)
        .fold(0.0, (sum, entry) => sum + entry.value);

    // Convert to segments
    final List<CircularSegment> segments = [];
    
    for (final entry in topCategories) {
      final category = DefaultCategories.getCategoryById(entry.key);
      if (category != null) {
        segments.add(CircularSegment(
          id: category.id,
          label: category.name,
          value: entry.value,
          color: category.color,
          icon: category.icon,
          category: category.name,
        ));
      }
    }

    // Add "Other" if needed
    if (otherTotal > 0) {
      segments.add(CircularSegment(
        id: 'other',
        label: 'Other',
        value: otherTotal,
        color: AppColorsExtended.categoryGray,
        icon: Icons.more_horiz,
        category: 'Other Categories',
      ));
    }

    return segments;
  },
);

class CategoryBreakdownParams {
  const CategoryBreakdownParams({
    this.type,
    this.startDate,
    this.endDate,
    this.maxCategories = 8,
  });

  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxCategories;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryBreakdownParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          maxCategories == other.maxCategories;

  @override
  int get hashCode =>
      type.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      maxCategories.hashCode;
}
4.2 Budget Category Breakdown Provider
dart// lib/features/budgets/presentation/providers/budget_category_breakdown_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/models/circular_segment.dart';
import '../../../categories/data/default_categories.dart';
import 'budget_providers.dart';

/// Provider for budget category breakdown
final budgetCategoryBreakdownProvider = Provider.family<List<CircularSegment>, String>(
  (ref, budgetId) {
    final budget = ref.watch(budgetByIdProvider(budgetId)).value;
    
    if (budget == null) return [];

    // Get category spending
    final categorySpending = budget.categorySpending ?? {};
    
    // Sort by amount
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Convert to segments
    return sortedEntries.map((entry) {
      final category = DefaultCategories.getCategoryById(entry.key);
      return CircularSegment(
        id: entry.key,
        label: category?.name ?? 'Unknown',
        value: entry.value,
        color: category?.color ?? AppColorsExtended.categoryGray,
        icon: category?.icon ?? Icons.category,
        category: category?.name,
      );
    }).toList();
  },
);
4.3 Dashboard Integration Widget
dart// lib/features/dashboard/presentation/widgets/enhanced_category_breakdown_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/patterns/segmented_indicator_card_pattern.dart';
import '../../../../core/design_system/models/circular_segment.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../transactions/presentation/providers/category_breakdown_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';

/// Enhanced category breakdown widget for dashboard
class EnhancedCategoryBreakdownWidget extends ConsumerStatefulWidget {
  const EnhancedCategoryBreakdownWidget({
    super.key,
    this.type = TransactionType.expense,
    this.startDate,
    this.endDate,
    this.onViewAll,
  });

  final TransactionType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback? onViewAll;

  @override
  ConsumerState<EnhancedCategoryBreakdownWidget> createState() =>
      _EnhancedCategoryBreakdownWidgetState();
}

class _EnhancedCategoryBreakdownWidgetState
    extends ConsumerState<EnhancedCategoryBreakdownWidget> {
  
  @override
  Widget build(BuildContext context) {
    final params = CategoryBreakdownParams(
      type: widget.type,
      startDate: widget.startDate,
      endDate: widget.endDate,
      maxCategories: 8,
    );

    final segments = ref.watch(categoryBreakdownProvider(params));

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = widget.type == TransactionType.expense
        ? 'Spending by Category'
        : 'Income by Category';

    final subtitle = _getSubtitle();

    return SegmentedIndicatorCardPattern(
      title: title,
      subtitle: subtitle,
      segments: segments,
      icon: Icons.pie_chart_outline,
      iconColor: widget.type == TransactionType.expense
          ? AppColorsExtended.categoryOrange
          : AppColorsExtended.categoryGreen,
      centerTitle: 'Total',
      onViewAll: widget.onViewAll,
      onSegmentTap: (segment) {
        _showCategoryDetails(segment);
      },
      showLegend: true,
      compactLegend: false,
      indicatorSize: 220,
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 400))
      .slideY(begin: 0.1, duration: const Duration(milliseconds: 400));
  }

  String _getSubtitle() {
    if (widget.startDate != null && widget.endDate != null) {
      final start = widget.startDate!;
      final end = widget.endDate!;
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
    return 'This month';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  void _showCategoryDetails(CircularSegment segment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryDetailsSheet(
        segment: segment,
        type: widget.type,
        startDate: widget.startDate,
        endDate: widget.endDate,
      ),
    );
  }
}

/// Bottom sheet showing category transaction details
class _CategoryDetailsSheet extends ConsumerWidget {
  const _CategoryDetailsSheet({
    required this.segment,
    required this.type,
    this.startDate,
    this.endDate,
  });

  final CircularSegment segment;
  final TransactionType type;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: segment.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    segment.icon,
                    size: 28,
                    color: segment.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${segment.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: segment.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Transaction list
          Expanded(
            child: _buildTransactionList(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(WidgetRef ref) {
    final transactions = ref.watch(transactionNotifierProvider).value ?? [];
    
    final filteredTransactions = transactions.where((t) {
      final matchesCategory = t.categoryId == segment.id;
      final matchesType = t.type == type;
      final matchesDate = startDate == null ||
          (t.date.isAfter(startDate!) &&
              t.date.isBefore(endDate ?? DateTime.now()));
      return matchesCategory && matchesType && matchesDate;
    }).toList();

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Text('No transactions found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _TransactionTile(transaction: transaction);
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

PART 5: USAGE EXAMPLES
5.1 Dashboard Integration
dart// lib/features/dashboard/presentation/screens/home_dashboard_screen_enhanced.dart (additions)

// Add this to the existing dashboard content:

// Category Breakdown (Expenses)
EnhancedCategoryBreakdownWidget(
  type: TransactionType.expense,
  startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
  endDate: DateTime.now(),
  onViewAll: () {
    // Navigate to category analysis screen
  },
).animate()
  .fadeIn(duration: 400.ms, delay: 1300.ms)
  .slideY(begin: 0.1, duration: 400.ms, delay: 1300.ms),

SizedBox(height: AppDimensions.sectionGap),

// Category Breakdown (Income) - optional
EnhancedCategoryBreakdownWidget(
  type: TransactionType.income,
  startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
  endDate: DateTime.now(),
  onViewAll: () {
    // Navigate to income analysis screen
  },
).animate()
  .fadeIn(duration: 400.ms, delay: 1400.ms)
  .slideY(begin: 0.1, duration: 400.ms, delay: 1400.ms),
5.2 Budget Detail Screen Integration
dart// lib/features/budgets/presentation/widgets/budget_category_breakdown_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/patterns/segmented_indicator_card_pattern.dart';
import '../providers/budget_category_breakdown_provider.dart';

/// Budget category breakdown card
class BudgetCategoryBreakdownCard extends ConsumerWidget {
  const BudgetCategoryBreakdownCard({
    super.key,
    required this.budgetId,
  });

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segments = ref.watch(budgetCategoryBreakdownProvider(budgetId));

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return SegmentedIndicatorCardPattern(
      title: 'Spending by Category',
      subtitle: 'Within this budget',
      segments: segments,
      icon: Icons.pie_chart,
      centerTitle: 'Spent',
      showLegend: true,
      compactLegend: true,
      indicatorSize: 200,
      onSegmentTap: (segment) {
        // Show category detail
        _showCategoryTransactions(context, segment);
      },
    );
  }

  void _showCategoryTransactions(BuildContext context, segment) {
    // TODO: Implement category transaction view
  }
}
5.3 Standalone Category Analysis Screen
dart// lib/features/analytics/presentation/screens/category_analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/design_system/patterns/segmented_indicator_card_pattern.dart';
import '../../../../core/design_system/templates/base_screen_template.dart';
import '../../../transactions/presentation/providers/category_breakdown_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';

/// Dedicated screen for category analysis
class CategoryAnalysisScreen extends ConsumerStatefulWidget {
  const CategoryAnalysisScreen({super.key});

  @override
  ConsumerState<CategoryAnalysisScreen> createState() =>
      _CategoryAnalysisScreenState();
}

class _CategoryAnalysisScreenState
    extends ConsumerState<CategoryAnalysisScreen> {
  TransactionType _selectedType = TransactionType.expense;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final params = CategoryBreakdownParams(
      type: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      maxCategories: 10,
    );

    final segments = ref.watch(categoryBreakdownProvider(params));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Category Analysis'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            children: [
              // Type Selector
              _buildTypeSelector(),
              SizedBox(height: AppDimensions.sectionGap),

              // Main Chart
              SegmentedIndicatorCardPattern(
                title: _selectedType == TransactionType.expense
                    ? 'Expense Breakdown'
                    : 'Income Breakdown',
                subtitle: _getDateRangeText(),
                segments: segments,
                icon: Icons.donut_large,
                centerTitle: 'Total',
                showLegend: true,
                compactLegend: false,
                indicatorSize: 260,
                onSegmentTap: (segment) {
                  _showSegmentDetails(segment);
                },
              ).animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),

              SizedBox(height: AppDimensions.sectionGap),

              // Insights
              _buildInsights(segments),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              'Expenses',
              TransactionType.expense,
              Icons.trending_down,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              'Income',
              TransactionType.income,
              Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type, IconData icon) {
    final isSelected = _selectedType == type;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: () => setState(() => _selectedType = type),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  label,RetrySContinuedart                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsights(List<CircularSegment> segments) {
    if (segments.isEmpty) return const SizedBox.shrink();

    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    final topSegment = segments.first;
    final topPercentage = topSegment.getPercentage(total);

    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPaddingLg),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.trending_up,
            color: topSegment.color,
            title: 'Top Category',
            description:
                '${topSegment.label} accounts for ${(topPercentage * 100).toInt()}% of your ${_selectedType.name}',
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.category,
            color: Colors.purple,
            title: 'Diversity',
            description: 'You have ${segments.length} active categories',
          ),
          if (segments.length > 1) ...[
            const SizedBox(height: 12),
            _buildInsightItem(
              icon: Icons.compare_arrows,
              color: Colors.orange,
              title: 'Comparison',
              description:
                  'Your second largest category is ${segments[1].label} at \$${segments[1].value.toInt()}',
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 200.ms)
      .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildInsightItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    if (_startDate.month == _endDate.month &&
        _startDate.year == _endDate.year) {
      return '${months[_startDate.month - 1]} ${_startDate.year}';
    }
    
    return '${months[_startDate.month - 1]} ${_startDate.day} - ${months[_endDate.month - 1]} ${_endDate.day}';
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showSegmentDetails(CircularSegment segment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryDetailsSheet(
        segment: segment,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }
}
5.4 Budget Screen Integration
dart// lib/features/budgets/presentation/screens/budget_detail_screen.dart (additions)

// Add this after the existing budget progress section:

SizedBox(height: AppDimensions.sectionGap),

// Category Breakdown
BudgetCategoryBreakdownCard(
  budgetId: budget.id,
).animate()
  .fadeIn(duration: 400.ms, delay: 600.ms)
  .slideY(begin: 0.1, duration: 400.ms, delay: 600.ms),

PART 6: MIGRATION GUIDE
6.1 Replacing Existing Circular Indicators
dart/// MIGRATION GUIDE: Transform Simple Circular Indicator to Segmented

// ============================================================================
// BEFORE: Simple Circular Budget Indicator
// ============================================================================

CircularBudgetIndicator(
  percentage: 0.75,
  spent: 750,
  total: 1000,
  size: 220,
  strokeWidth: 22,
)

// ============================================================================
// AFTER: Segmented Circular Indicator with Categories
// ============================================================================

// Step 1: Prepare segment data
final segments = [
  CircularSegment(
    id: 'food',
    label: 'Food',
    value: 300,
    color: AppColorsExtended.categoryOrange,
    icon: Icons.restaurant,
    category: 'Food & Dining',
  ),
  CircularSegment(
    id: 'transport',
    label: 'Transport',
    value: 200,
    color: AppColorsExtended.categoryBlue,
    icon: Icons.directions_car,
    category: 'Transportation',
  ),
  CircularSegment(
    id: 'shopping',
    label: 'Shopping',
    value: 150,
    color: AppColorsExtended.categoryPink,
    icon: Icons.shopping_bag,
    category: 'Shopping',
  ),
  CircularSegment(
    id: 'other',
    label: 'Other',
    value: 100,
    color: AppColorsExtended.categoryGray,
    icon: Icons.more_horiz,
    category: 'Other',
  ),
];

// Step 2: Use segmented indicator
SegmentedCircularIndicator(
  segments: segments,
  size: 220,
  strokeWidth: 22,
  centerTitle: 'Spent',
  onSegmentTap: (segment) {
    print('Tapped: ${segment.label}');
  },
)

// Step 3: Add legend (optional)
SizedBox(height: 16),
SegmentLegend(
  segments: segments,
  totalValue: 750,
  showPercentages: true,
  showValues: true,
)
6.2 Step-by-Step Migration Process
dart/// COMPLETE MIGRATION PROCESS

// ============================================================================
// STEP 1: Add Dependencies
// ============================================================================

// pubspec.yaml
dependencies:
  flutter_animate: ^4.3.0
  intl: ^0.18.0

// ============================================================================
// STEP 2: Copy Design System Files
// ============================================================================

/*
Create these files:
- lib/core/design_system/models/circular_segment.dart
- lib/core/design_system/widgets/segmented_circular_indicator.dart
- lib/core/design_system/widgets/segment_legend.dart
- lib/core/design_system/patterns/segmented_indicator_card_pattern.dart
- lib/features/categories/domain/entities/category.dart
- lib/features/categories/data/default_categories.dart
*/

// ============================================================================
// STEP 3: Update Color Tokens
// ============================================================================

// lib/core/theme/app_colors_extended.dart
class AppColorsExtended {
  // Add category colors
  static const Color categoryOrange = Color(0xFFF59E0B);
  static const Color categoryBlue = Color(0xFF3B82F6);
  static const Color categoryPink = Color(0xFFEC4899);
  static const Color categoryPurple = Color(0xFF8B5CF6);
  static const Color categoryYellow = Color(0xFFEAB308);
  static const Color categoryRed = Color(0xFFEF4444);
  static const Color categoryIndigo = Color(0xFF6366F1);
  static const Color categoryTeal = Color(0xFF14B8A6);
  static const Color categoryGreen = Color(0xFF10B981);
  static const Color categoryBrown = Color(0xFF92400E);
  static const Color categoryGray = Color(0xFF6B7280);
}

// ============================================================================
// STEP 4: Create Category Breakdown Provider
// ============================================================================

// lib/features/transactions/presentation/providers/category_breakdown_provider.dart
final categoryBreakdownProvider = Provider.family<List<CircularSegment>, CategoryBreakdownParams>(
  (ref, params) {
    // Implementation from Part 4.1
  },
);

// ============================================================================
// STEP 5: Update Transaction Model
// ============================================================================

// lib/features/transactions/domain/entities/transaction.dart
class Transaction {
  // Add categoryId field
  final String? categoryId;
  
  // Update constructor
  const Transaction({
    // ... existing fields
    this.categoryId,
  });
  
  // Update copyWith
  Transaction copyWith({
    // ... existing fields
    String? categoryId,
  }) {
    return Transaction(
      // ... existing copies
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

// ============================================================================
// STEP 6: Update Dashboard Screen
// ============================================================================

// lib/features/dashboard/presentation/screens/home_dashboard_screen_enhanced.dart

// Replace existing financial overview with:
EnhancedCategoryBreakdownWidget(
  type: TransactionType.expense,
  startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
  endDate: DateTime.now(),
  onViewAll: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryAnalysisScreen(),
      ),
    );
  },
)

// ============================================================================
// STEP 7: Update Budget Detail Screen
// ============================================================================

// lib/features/budgets/presentation/screens/budget_detail_screen.dart

// Add after progress section:
BudgetCategoryBreakdownCard(
  budgetId: budget.id,
)

// ============================================================================
// STEP 8: Test Migration
// ============================================================================

/*
Test checklist:
✓ Segments display correctly
✓ Colors match design system
✓ Tap interaction works
✓ Animations are smooth
✓ Legend updates on selection
✓ Category details show
✓ Empty states handled
✓ Performance is acceptable
*/
6.3 Backward Compatibility
dart/// Maintain backward compatibility with existing CircularBudgetIndicator

// ============================================================================
// Option 1: Adapter Pattern
// ============================================================================

class CircularBudgetIndicatorAdapter extends StatelessWidget {
  const CircularBudgetIndicatorAdapter({
    super.key,
    required this.percentage,
    required this.spent,
    required this.total,
    this.categoryBreakdown,
    this.size = 200,
    this.strokeWidth = 20,
  });

  final double percentage;
  final double spent;
  final double total;
  final Map<String, double>? categoryBreakdown;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    // If no category breakdown, use old indicator
    if (categoryBreakdown == null || categoryBreakdown!.isEmpty) {
      return CircularBudgetIndicator(
        percentage: percentage,
        spent: spent,
        total: total,
        size: size,
        strokeWidth: strokeWidth,
      );
    }

    // Convert to segments
    final segments = _convertToSegments(categoryBreakdown!);

    // Use new segmented indicator
    return SegmentedCircularIndicator(
      segments: segments,
      size: size,
      strokeWidth: strokeWidth,
      centerTitle: 'Spent',
    );
  }

  List<CircularSegment> _convertToSegments(Map<String, double> breakdown) {
    return breakdown.entries.map((entry) {
      final category = DefaultCategories.getCategoryById(entry.key);
      return CircularSegment(
        id: entry.key,
        label: category?.name ?? entry.key,
        value: entry.value,
        color: category?.color ?? AppColorsExtended.categoryGray,
        icon: category?.icon ?? Icons.category,
        category: category?.name,
      );
    }).toList();
  }
}

// ============================================================================
// Option 2: Feature Flag
// ============================================================================

class FeatureFlags {
  static const bool useSegmentedIndicators = true;
}

Widget buildBudgetIndicator() {
  if (FeatureFlags.useSegmentedIndicators) {
    return SegmentedCircularIndicator(/* ... */);
  } else {
    return CircularBudgetIndicator(/* ... */);
  }
}
6.4 Testing Strategy
dart/// Comprehensive testing approach

// ============================================================================
// Unit Tests
// ============================================================================

// test/core/design_system/models/circular_segment_test.dart
void main() {
  group('CircularSegment', () {
    test('calculates percentage correctly', () {
      final segment = CircularSegment(
        id: 'test',
        label: 'Test',
        value: 250,
        color: Colors.blue,
        icon: Icons.test,
      );

      expect(segment.getPercentage(1000), 0.25);
    });

    test('handles zero total', () {
      final segment = CircularSegment(
        id: 'test',
        label: 'Test',
        value: 250,
        color: Colors.blue,
        icon: Icons.test,
      );

      expect(segment.getPercentage(0), 0.0);
    });

    test('calculates sweep angle correctly', () {
      final segment = CircularSegment(
        id: 'test',
        label: 'Test',
        value: 500,
        color: Colors.blue,
        icon: Icons.test,
      );

      final sweepAngle = segment.getSweepAngle(1000);
      expect(sweepAngle, closeTo(3.141592653589793, 0.001)); // π radians = 180°
    });
  });
}

// ============================================================================
// Widget Tests
// ============================================================================

// test/core/design_system/widgets/segmented_circular_indicator_test.dart
void main() {
  group('SegmentedCircularIndicator', () {
    testWidgets('displays segments correctly', (tester) async {
      final segments = [
        CircularSegment(
          id: 'test1',
          label: 'Test 1',
          value: 100,
          color: Colors.blue,
          icon: Icons.test,
        ),
        CircularSegment(
          id: 'test2',
          label: 'Test 2',
          value: 200,
          color: Colors.red,
          icon: Icons.test,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedCircularIndicator(
              segments: segments,
            ),
          ),
        ),
      );

      expect(find.byType(SegmentedCircularIndicator), findsOneWidget);
    });

    testWidgets('handles tap interaction', (tester) async {
      CircularSegment? tappedSegment;
      
      final segments = [
        CircularSegment(
          id: 'test',
          label: 'Test',
          value: 100,
          color: Colors.blue,
          icon: Icons.test,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedCircularIndicator(
              segments: segments,
              onSegmentTap: (segment) => tappedSegment = segment,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SegmentedCircularIndicator));
      await tester.pumpAndSettle();

      expect(tappedSegment, isNotNull);
    });
  });
}

// ============================================================================
// Integration Tests
// ============================================================================

// integration_test/category_breakdown_test.dart
void main() {
  group('Category Breakdown Integration', () {
    testWidgets('displays category breakdown in dashboard', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.byType(SegmentedCircularIndicator), findsWidgets);
    });

    testWidgets('tapping segment shows details', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap on category breakdown
      await tester.tap(find.byType(SegmentedCircularIndicator).first);
      await tester.pumpAndSettle();

      // Verify details sheet appears
      expect(find.text('Transactions'), findsOneWidget);
    });
  });
}

// ============================================================================
// Performance Tests
// ============================================================================

void performanceTest() {
  // Test with large number of segments
  final segments = List.generate(
    20,
    (i) => CircularSegment(
      id: 'test_$i',
      label: 'Test $i',
      value: 100 + i * 10,
      color: Colors.primaries[i % Colors.primaries.length],
      icon: Icons.category,
    ),
  );

  // Measure render time
  final stopwatch = Stopwatch()..start();
  
  runApp(MaterialApp(
    home: Scaffold(
      body: SegmentedCircularIndicator(segments: segments),
    ),
  ));
  
  stopwatch.stop();
  print('Render time: ${stopwatch.elapsedMilliseconds}ms');
  
  // Should render in under 100ms
  assert(stopwatch.elapsedMilliseconds < 100);
}

PART 7: ADVANCED FEATURES
7.1 Animated Segment Transitions
dart// lib/core/design_system/widgets/animated_segmented_indicator.dart

/// Segmented indicator with smooth data transitions
class AnimatedSegmentedIndicator extends StatefulWidget {
  const AnimatedSegmentedIndicator({
    super.key,
    required this.segments,
    this.duration = const Duration(milliseconds: 800),
    this.size = 240,
    this.strokeWidth = 24,
  });

  final List<CircularSegment> segments;
  final Duration duration;
  final double size;
  final double strokeWidth;

  @override
  State<AnimatedSegmentedIndicator> createState() =>
      _AnimatedSegmentedIndicatorState();
}

class _AnimatedSegmentedIndicatorState extends State<AnimatedSegmentedIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<CircularSegment> _previousSegments = [];
  List<CircularSegment> _currentSegments = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _currentSegments = widget.segments;
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedSegmentedIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments) {
      setState(() {
        _previousSegments = oldWidget.segments;
        _currentSegments = widget.segments;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final interpolatedSegments = _interpolateSegments(
          _previousSegments,
          _currentSegments,
          _controller.value,
        );

        return SegmentedCircularIndicator(
          segments: interpolatedSegments,
          size: widget.size,
          strokeWidth: widget.strokeWidth,
        );
      },
    );
  }

  List<CircularSegment> _interpolateSegments(
    List<CircularSegment> from,
    List<CircularSegment> to,
    double t,
  ) {
    if (from.isEmpty) return to;
    if (to.isEmpty) return from;

    // Simple interpolation - in production, implement proper morphing
    return to.map((toSegment) {
      final fromSegment = from.firstWhere(
        (s) => s.id == toSegment.id,
        orElse: () => toSegment.copyWith(value: 0),
      );

      return toSegment.copyWith(
        value: fromSegment.value + (toSegment.value - fromSegment.value) * t,
      );
    }).toList();
  }
}
7.2 Comparison Mode
dart// lib/core/design_system/widgets/comparison_segmented_indicator.dart

/// Side-by-side comparison of two periods
class ComparisonSegmentedIndicator extends StatelessWidget {
  const ComparisonSegmentedIndicator({
    super.key,
    required this.currentSegments,
    required this.previousSegments,
    required this.currentLabel,
    required this.previousLabel,
  });

  final List<CircularSegment> currentSegments;
  final List<CircularSegment> previousSegments;
  final String currentLabel;
  final String previousLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                previousLabel,
                style: TypographyTokens.labelMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
              SizedBox(height: DesignTokens.spacing3),
              SegmentedCircularIndicator(
                segments: previousSegments,
                size: 180,
                strokeWidth: 18,
              ),
            ],
          ),
        ),
        SizedBox(width: DesignTokens.spacing4),
        Expanded(
          child: Column(
            children: [
              Text(
                currentLabel,
                style: TypographyTokens.labelMd.copyWith(
                  color: ColorTokens.textPrimary,
                  fontWeight: TypographyTokens.weightBold,
                ),
              ),
              SizedBox(height: DesignTokens.spacing3),
              SegmentedCircularIndicator(
                segments: currentSegments,
                size: 180,
                strokeWidth: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

📋 IMPLEMENTATION CHECKLIST
markdown# Segmented Circular Indicator Implementation Checklist

## Phase 1: Core Components (Week 1)
- [ ] Copy CircularSegment model
- [ ] Implement SegmentedCircularIndicator widget
- [ ] Implement SegmentLegend widget
- [ ] Create SegmentedIndicatorCardPattern
- [ ] Add category colors to theme
- [ ] Test basic rendering and interactions

## Phase 2: Category System (Week 2)
- [ ] Create TransactionCategory entity
- [ ] Implement DefaultCategories
- [ ] Add categoryId to Transaction model
- [ ] Update database schema
- [ ] Migrate existing transactions
- [ ] Create category selection UI

## Phase 3: Data Integration (Week 3)
- [ ] Create categoryBreakdownProvider
- [ ] Create budgetCategoryBreakdownProvider
- [ ] Implement EnhancedCategoryBreakdownWidget
- [ ] Add to dashboard
- [ ] Add to budget detail screen
- [ ] Test data accuracy

## Phase 4: Advanced Features (Week 4)
- [ ] Implement CategoryAnalysisScreen
- [ ] Add comparison mode
- [ ] Add animated transitions
- [ ] Implement category details sheet
- [ ] Add insights generation
- [ ] Polish animations

## Phase 5: Testing & Optimization (Week 5)
- [ ] Write unit tests
- [ ] Write widget tests
- [ ] Write integration tests
- [ ] Performance profiling
- [ ] Accessibility audit
- [ ] Bug fixes

## Phase 6: Documentation & Rollout
- [ ] Update user documentation
- [ ] Create migration guide for team
- [ ] Deploy to staging
- [ ] User testing
- [ ] Deploy to production
- [ ] Monitor performance

🎯 SUMMARY
This comprehensive guide provides:

Complete segmented circular indicator system with interactive tap, scaling, and label display
Category management system with default categories and color coding
Data providers for automatic category breakdown calculation
Integration patterns for dashboard, budgets, and analytics
Migration guide to transform existing indicators
Advanced features like comparisons and animations
Testing strategy for quality assurance

The system is:

✅ Design-system compliant - Uses all established tokens
✅ Performant - Optimized rendering and animations
✅ Interactive - Rich user interactions with feedback
✅ Accessible - Proper semantics and touch targets
✅ Scalable - Easy to extend and maintain
✅ Reusable - Works across all app sections

All components follow your existing design aesthetics while adding powerful category visualization capabilities!RetryClaude can make mistakes. Please double-check responses.