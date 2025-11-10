import 'package:flutter/material.dart';

import '../theme/app_animations.dart';

/// Utility class for consistent bottom sheet presentation with animations
class AppBottomSheet {
  /// Show a bottom sheet with consistent styling and animations
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Duration? transitionDuration,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: elevation ?? 0,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
      builder: (context) => _AnimatedBottomSheetContent(child: child),
    );
  }
}

/// Animated content wrapper for bottom sheet
class _AnimatedBottomSheetContent extends StatefulWidget {
  const _AnimatedBottomSheetContent({required this.child});

  final Widget child;

  @override
  State<_AnimatedBottomSheetContent> createState() => _AnimatedBottomSheetContentState();
}

class _AnimatedBottomSheetContentState extends State<_AnimatedBottomSheetContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.fadeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.pageTransition,
    ));

    // Start animation after a short delay to ensure bottom sheet is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}