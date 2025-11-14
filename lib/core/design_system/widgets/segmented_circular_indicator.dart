import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../widgets/crash_detector.dart';
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
///   centerTitle: 'Total',
///   showPercentages: true,
///   showCenterValue: true,
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
  bool _isDisposed = false; // Track disposal state

  void _onProgressAnimationStatus(AnimationStatus status) {
    debugPrint('SegmentedCircularIndicator: Progress animation status: $status, disposed: $_isDisposed, hashCode: $hashCode');
    if (status == AnimationStatus.completed && _isDisposed) {
      debugPrint('SegmentedCircularIndicator: WARNING - Progress animation completed after disposal');
    }
  }

  void _onInteractionAnimationStatus(AnimationStatus status) {
    debugPrint('SegmentedCircularIndicator: Interaction animation status: $status, disposed: $_isDisposed, hashCode: $hashCode');
    if (status == AnimationStatus.completed && _isDisposed) {
      debugPrint('SegmentedCircularIndicator: WARNING - Interaction animation completed after disposal');
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('SegmentedCircularIndicator: initState called - hashCode: $hashCode');

    try {
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

      // Add animation status listeners for debugging
      _progressController.addStatusListener(_onProgressAnimationStatus);
      _interactionController.addStatusListener(_onInteractionAnimationStatus);

      debugPrint('SegmentedCircularIndicator: Starting progress animation');
      _progressController.forward().catchError((error) {
        debugPrint('SegmentedCircularIndicator: ERROR - Failed to start progress animation: $error');
      });
    } catch (e, stackTrace) {
      debugPrint('SegmentedCircularIndicator: CRITICAL - Error in initState: $e');
      debugPrint('SegmentedCircularIndicator: Stack trace: $stackTrace');
      // Don't rethrow - let the widget continue with limited functionality
    }
  }

  @override
  void didUpdateWidget(SegmentedCircularIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments) {
      // Only reset if not disposed
      if (!_isDisposed && _progressController.isCompleted) {
        _progressController.reset();
        _progressController.forward();
      }
    }
  }

  @override
  void dispose() {
    debugPrint('SegmentedCircularIndicator: dispose called, _isDisposed: $_isDisposed, hashCode: $hashCode');

    try {
      _isDisposed = true;

      // Remove listeners first to prevent callbacks during disposal
      debugPrint('SegmentedCircularIndicator: Removing animation listeners');
      _progressController.removeStatusListener(_onProgressAnimationStatus);
      _interactionController.removeStatusListener(_onInteractionAnimationStatus);

      // Stop all animations safely
      if (_progressController.isAnimating) {
        debugPrint('SegmentedCircularIndicator: Stopping progress animation during disposal');
        _progressController.stop();
      }
      if (_interactionController.isAnimating) {
        debugPrint('SegmentedCircularIndicator: Stopping interaction animation during disposal');
        _interactionController.stop();
      }

      // Dispose in reverse order of creation
      debugPrint('SegmentedCircularIndicator: Disposing interaction controller');
      _interactionController.dispose();
      debugPrint('SegmentedCircularIndicator: Disposing progress controller');
      _progressController.dispose();

      debugPrint('SegmentedCircularIndicator: dispose completed successfully');
    } catch (e, stackTrace) {
      debugPrint('SegmentedCircularIndicator: CRITICAL - Error during dispose: $e');
      debugPrint('SegmentedCircularIndicator: Dispose stack trace: $stackTrace');
      // Don't rethrow during dispose
    }

    super.dispose();
  }

  double get _totalValue {
    return widget.segments.fold(0.0, (sum, segment) => sum + segment.value);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SegmentedCircularIndicator: Building with segments: ${widget.segments.length}, disposed: $_isDisposed, hashCode: $hashCode');

    if (_isDisposed) {
      debugPrint('SegmentedCircularIndicator: WARNING - Building while disposed');
      return SizedBox(width: widget.size, height: widget.size);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _interactionController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular segments with crash protection
              GestureDetector(
                onTapDown: (details) => _handleTapDown(details),
                onTapUp: (details) => _handleTapUp(),
                onTapCancel: () => _handleTapUp(),
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: SafeCustomPainter(
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
              ),

              // Center content - ensure proper centering
              Center(
                child: _buildCenterContent(),
              ),

              // Floating label for selected segment
              if (_selectedSegmentId != null && _labelPosition != null && widget.segments.isNotEmpty)
                _buildFloatingLabel(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterContent() {
    final selectedSegment = _selectedSegmentId != null && widget.segments.isNotEmpty
        ? widget.segments.firstWhere(
            (s) => s.id == _selectedSegmentId,
            orElse: () => widget.segments.first,
          )
        : null;

    return SizedBox(
      width: widget.size * 0.5,
      height: widget.size * 0.5,
      child: selectedSegment != null ? _buildSelectedSegmentInfo(selectedSegment) : _buildTotalInfo(),
    );
  }

  Widget _buildTotalInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        const SizedBox(height: 4),
        Text(
          widget.centerTitle,
          style: TypographyTokens.labelMd.copyWith(
            color: ColorTokens.textSecondary,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TypographyTokens.labelSm.copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                segment.label,
                style: TypographyTokens.captionMd.copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
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
    if (_selectedSegmentId == null || _labelPosition == null || widget.segments.isEmpty) {
      return const SizedBox.shrink();
    }

    final segment = widget.segments.firstWhere(
      (s) => s.id == _selectedSegmentId,
      orElse: () => widget.segments.first,
    );

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
    if (widget.segments.isEmpty) return;

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
    debugPrint('SegmentedCircularIndicator: _handleTapUp called, _isDisposed: $_isDisposed, mounted: $mounted, hashCode: $hashCode');

    if (_isDisposed || !mounted) {
      debugPrint('SegmentedCircularIndicator: Ignoring tap up - already disposed or not mounted');
      return; // Guard against disposed state
    }

    try {
      debugPrint('SegmentedCircularIndicator: Reversing interaction animation');
      _interactionController.reverse().catchError((error) {
        debugPrint('SegmentedCircularIndicator: ERROR - Failed to reverse interaction animation: $error');
      });

      Future.delayed(widget.interactionConfig.animationDuration, () {
        if (mounted && !_isDisposed) {
          debugPrint('SegmentedCircularIndicator: Clearing selection after animation delay');
          setState(() {
            _selectedSegmentId = null;
            _labelPosition = null;
          });
        } else {
          debugPrint('SegmentedCircularIndicator: Skipping state update - widget not mounted or disposed');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('SegmentedCircularIndicator: CRITICAL - Error in _handleTapUp: $e');
      debugPrint('SegmentedCircularIndicator: Tap up stack trace: $stackTrace');
    }
  }

  CircularSegment? _getSegmentAtPosition(Offset touchPoint, Offset center) {
    if (widget.segments.isEmpty) return null;

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

  // Cached Paint objects for performance - now instance-based to avoid static leaks
  final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _segmentPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _separatorPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.3)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  // Cached shaders to avoid recreating gradients on every frame - now instance-based
  final Map<String, Shader> _shaderCache = {};

  // Cached blur filters for glow effect - now instance-based
  final Map<double, MaskFilter> _blurCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    try {
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
    } catch (e, stackTrace) {
      debugPrint('SegmentedCircularPainter: Error in paint: $e');
      debugPrint('Stack trace: $stackTrace');
      // Draw a simple error indicator
      final center = Offset(size.width / 2, size.height / 2);
      final paint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, size.width / 4, paint);
    }
  }

  @override
  void dispose() {
    // Clear instance caches to prevent memory leaks
    _shaderCache.clear();
    _blurCache.clear();
    debugPrint('SegmentedCircularPainter: disposed and cleared caches');
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
    // Skip drawing if sweep angle is too small to avoid gradient issues
    if (sweepAngle < 0.01) return;

    final effectiveRadius = isSelected
        ? radius + (strokeWidth * (scaleAmount - 1.0) * interactionProgress / 2)
        : radius;

    final rect = Rect.fromCircle(center: center, radius: effectiveRadius);

    // Draw glow for selected segment using cached paint
    if (isSelected && interactionProgress > 0) {
      final blurIntensity = 8 * interactionProgress;
      final blurKey = blurIntensity;

      // Cache blur filter
      _blurCache[blurKey] ??= MaskFilter.blur(BlurStyle.normal, blurIntensity);

      _glowPaint
        ..color = segment.color.withValues(alpha: glowIntensity * interactionProgress)
        ..strokeWidth = strokeWidth + 12 * interactionProgress
        ..maskFilter = _blurCache[blurKey];

      canvas.drawArc(rect, startAngle, sweepAngle, false, _glowPaint);
    }

    // Draw segment with cached gradient shader
    final shaderKey = '${segment.id}_${startAngle.toStringAsFixed(3)}_${sweepAngle.toStringAsFixed(3)}_${rect.width.toStringAsFixed(1)}_${rect.height.toStringAsFixed(1)}';
    final cachedShader = _shaderCache[shaderKey];

    Shader shader;
    if (cachedShader != null) {
      shader = cachedShader;
    } else {
      try {
        // Ensure sweep angle is large enough for gradient
        final effectiveSweepAngle = math.max(sweepAngle, 0.1);
        final gradient = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + effectiveSweepAngle,
          colors: [
            segment.color,
            segment.color.withValues(alpha: 0.8),
            segment.color,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
        shader = gradient.createShader(rect);
        _shaderCache[shaderKey] = shader;
      } catch (e) {
        // Fallback to solid color if gradient fails
        debugPrint('SegmentedCircularPainter: Gradient creation failed for segment ${segment.id}, using solid color: $e');
        _segmentPaint
          ..shader = null
          ..color = segment.color;
        shader = _segmentPaint.shader ?? LinearGradient(colors: [segment.color, segment.color]).createShader(rect);
      }
    }

    _segmentPaint
      ..shader = shader
      ..strokeWidth = strokeWidth + (isSelected ? strokeWidth * 0.2 * interactionProgress : 0);

    canvas.drawArc(rect, startAngle, sweepAngle, false, _segmentPaint);

    // Draw separator lines between segments using cached paint
    if (sweepAngle < 2 * math.pi - 0.01) {
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

      canvas.drawLine(innerPoint, outerPoint, _separatorPaint);
    }
  }

  @override
  bool shouldRepaint(_SegmentedCircularPainter oldDelegate) {
    // Only repaint if properties that affect visual output have changed
    return oldDelegate.progress != progress ||
        oldDelegate.selectedSegmentId != selectedSegmentId ||
        oldDelegate.interactionProgress != interactionProgress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.scaleAmount != scaleAmount ||
        oldDelegate.glowIntensity != glowIntensity ||
        !_segmentsEqual(oldDelegate.segments, segments);
  }

  // Helper method to compare segments more efficiently
  bool _segmentsEqual(List<CircularSegment> oldSegments, List<CircularSegment> newSegments) {
    if (oldSegments.length != newSegments.length) return false;

    for (int i = 0; i < oldSegments.length; i++) {
      final old = oldSegments[i];
      final new_ = newSegments[i];
      if (old.id != new_.id ||
          old.value != new_.value ||
          old.color != new_.color ||
          old.label != new_.label) {
        return false;
      }
    }
    return true;
  }
}