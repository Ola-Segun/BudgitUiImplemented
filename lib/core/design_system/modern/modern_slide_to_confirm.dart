import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// ModernSlideToConfirm Widget
/// Slide-to-confirm interaction for important actions
/// Light gray background, Dark circle with chevron icon
/// Animated sliding, Haptic feedback, "Slide to Save" text
class ModernSlideToConfirm extends StatefulWidget {
  final String text;
  final VoidCallback? onConfirmed;
  final Future<bool> Function()? onSlideComplete;
  final double height;
  final Duration animationDuration;

  const ModernSlideToConfirm({
    super.key,
    this.text = 'Slide to Save',
    this.onConfirmed,
    this.onSlideComplete,
    this.height = 48.0,
    this.animationDuration = ModernAnimations.normal,
  });

  @override
  State<ModernSlideToConfirm> createState() => _ModernSlideToConfirmState();
}

class _ModernSlideToConfirmState extends State<ModernSlideToConfirm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_isConfirmed) return;
    setState(() {
      _isDragging = true;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isConfirmed || !_isDragging) return;

    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, context.size?.width ?? 300);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (_isConfirmed || !_isDragging) return;

    setState(() {
      _isDragging = false;
    });

    final maxWidth = context.size?.width ?? 300;
    final threshold = maxWidth * 0.6; // 60% threshold

    if (_dragPosition >= threshold) {
      // Check if slide should be confirmed
      bool shouldConfirm = true;
      if (widget.onSlideComplete != null) {
        shouldConfirm = await widget.onSlideComplete!();
      }

      if (shouldConfirm) {
        // Confirm action
        setState(() {
          _isConfirmed = true;
          _dragPosition = maxWidth;
        });

        HapticFeedback.heavyImpact();
        _animationController.forward().then((_) {
          widget.onConfirmed?.call();
        });
      } else {
        // Reset position
        setState(() {
          _dragPosition = 0.0;
        });
      }
    } else {
      // Reset position
      setState(() {
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.text,
      button: true,
      enabled: !_isConfirmed,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: ModernColors.primaryGray,
          borderRadius: BorderRadius.circular(radius_lg),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final handleSize = widget.height;

            return Stack(
              children: [
                // Background text
                Center(
                  child: Text(
                    _isConfirmed ? '✓ Confirmed' : widget.text,
                    style: ModernTypography.bodyLarge.copyWith(
                      color: _isConfirmed
                          ? ModernColors.accentGreen
                          : ModernColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Trail effect
                if (_dragPosition > 0 && !_isConfirmed)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: _dragPosition,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ModernColors.accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(radius_lg),
                      ),
                    ),
                  ),

                // Draggable handle
                Positioned(
                  left: _dragPosition.clamp(0, maxWidth - handleSize),
                  top: 0,
                  child: GestureDetector(
                    onHorizontalDragStart: _onHorizontalDragStart,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    child: AnimatedContainer(
                      duration: ModernAnimations.fast,
                      width: handleSize,
                      height: handleSize,
                      decoration: BoxDecoration(
                        color: _isConfirmed
                            ? ModernColors.accentGreen
                            : ModernColors.primaryBlack,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [ModernShadows.subtle],
                      ),
                      child: Center(
                        child: Icon(
                          _isConfirmed ? Icons.check : Icons.chevron_right,
                          color: ModernColors.lightBackground,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
