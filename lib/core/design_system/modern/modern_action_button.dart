import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// ModernActionButton Widget
/// Primary and secondary action buttons
/// Height: 56px, Border radius: 16px
/// Primary: Black background, white text
/// Secondary: Light gray background, black text
/// Full width by default, Loading state support
class ModernActionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double height;
  final Duration minimumPressDuration;

  const ModernActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 48.0,
    this.minimumPressDuration = Duration.zero,
  });

  @override
  State<ModernActionButton> createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  DateTime? _tapDownTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: ModernCurves.easeOut),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _tapDownTime = DateTime.now();
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading && widget.onPressed != null) {
      _tapDownTime = null;
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (!widget.isLoading && widget.onPressed != null) {
      final pressDuration = _tapDownTime != null 
          ? DateTime.now().difference(_tapDownTime!) 
          : Duration.zero;
      
      debugPrint('ModernActionButton: Button tapped, text: ${widget.text}, '
          'pressDuration: ${pressDuration.inMilliseconds}ms, '
          'minimum: ${widget.minimumPressDuration.inMilliseconds}ms');
      
      if (pressDuration >= widget.minimumPressDuration) {
        HapticFeedback.lightImpact();
        widget.onPressed!();
      } else {
        debugPrint('ModernActionButton: Button tap ignored due to short press duration');
      }
      _tapDownTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isPrimary
        ? ModernColors.primaryBlack
        : ModernColors.primaryGray;

    final textColor = widget.isPrimary
        ? ModernColors.lightBackground
        : ModernColors.primaryBlack;

    final isEnabled = !widget.isLoading && widget.onPressed != null;

    return Semantics(
      label: widget.text,
      button: true,
      enabled: isEnabled,
      child: GestureDetector(
        // FIXED: Only provide callbacks when button is enabled
        onTapDown: isEnabled ? _onTapDown : null,
        onTapUp: isEnabled ? _onTapUp : null,
        onTapCancel: isEnabled ? _onTapCancel : null,
        onTap: isEnabled ? _handleTap : null,
        // Add behavior to make sure taps don't pass through
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.isFullWidth ? double.infinity : null,
                height: widget.height,
                constraints: widget.isFullWidth
                    ? null
                    : const BoxConstraints(minWidth: 120),
                decoration: BoxDecoration(
                  color: isEnabled 
                      ? backgroundColor 
                      : ModernColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(radius_lg),
                ),
                padding: const EdgeInsets.symmetric(horizontal: spacing_lg),
                child: Row(
                  mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      ),
                      const SizedBox(width: spacing_sm),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 20,
                        color: textColor,
                      ),
                      const SizedBox(width: spacing_sm),
                    ],
                    Text(
                      widget.text,
                      style: ModernTypography.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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