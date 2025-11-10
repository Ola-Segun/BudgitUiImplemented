import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animation constants and utilities for the app
class AppAnimations {
  // Duration constants - optimized for performance
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // Curve constants
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // Common animation curves
  static const Curve pageTransition = Curves.easeInOutCubic;
  static const Curve buttonPress = Curves.easeInOut;
  static const Curve fadeIn = Curves.easeIn;
  static const Curve scaleIn = Curves.elasticOut;

  // Animation values
  static const double scalePressed = 0.95;
  static const double scaleHover = 1.02;
  static const double opacityDisabled = 0.5;

  // ═══════════════════════════════════════════════════════════
  // ACCOUNT UI ANIMATION PRESETS
  // ═══════════════════════════════════════════════════════════

  /// Fade in + slide up animation for cards
  static Widget fadeInSlideUp({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return child.animate()
      .fadeIn(duration: duration, delay: delay)
      .slideY(begin: 0.2, duration: duration, delay: delay, curve: Curves.easeOut);
  }

  /// Staggered list animation for multiple items
  static Widget staggeredFadeIn({
    required Widget child,
    required int index,
    Duration baseDelay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    final delay = baseDelay + Duration(milliseconds: index * 50);
    return fadeInSlideUp(child: child, delay: delay, duration: duration);
  }

  /// Scale and fade animation for hero elements
  static Widget heroScaleIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return child.animate()
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0),
             duration: duration, delay: delay, curve: Curves.elasticOut)
      .fadeIn(duration: duration, delay: delay);
  }

  /// Pulsing animation for indicators
  static Widget pulsingIndicator({
    required Widget child,
    Duration period = const Duration(milliseconds: 1500),
  }) {
    return child.animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.1, 1.1),
      duration: period,
      curve: Curves.easeInOut,
    );
  }

  /// Bounce in animation for action buttons
  static Widget bounceIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return child.animate()
      .scale(begin: const Offset(0.3, 0.3), end: const Offset(1.1, 1.1),
             duration: duration ~/ 2, delay: delay, curve: Curves.elasticOut)
      .then()
      .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0),
             duration: duration ~/ 2, curve: Curves.easeOut);
  }

  // Page transition builder
  static Widget pageTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  // Fade transition builder
  static Widget fadeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  // Scale transition builder
  static Widget scaleTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }

  // Combined slide and fade transition
  static Widget slideFadeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.1, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);
    var fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

  // Shared axis transition (horizontal)
  static Widget sharedAxisTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    var fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

  // Fade through transition
  static Widget fadeThroughTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  // Container transform transition
  static Widget containerTransformTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    var scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    var fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
}

/// Extension methods for animations
extension AnimationExtensions on Widget {
  /// Adds a fade in animation
  Widget fadeIn({
    Duration duration = AppAnimations.normal,
    Curve curve = AppAnimations.fadeIn,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  /// Adds a scale animation
  Widget scaleIn({
    Duration duration = AppAnimations.normal,
    Curve curve = AppAnimations.scaleIn,
  }) {
    return AnimatedScale(
      scale: 1.0,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  /// Adds a slide in animation
  Widget slideIn({
    Duration duration = AppAnimations.normal,
    Curve curve = AppAnimations.pageTransition,
    Offset begin = const Offset(0.0, 0.1),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: this,
    );
  }

  /// Adds a press animation effect
  Widget pressEffect({
    Duration duration = AppAnimations.fast,
    double scale = AppAnimations.scalePressed,
  }) {
    return _PressEffect(
      duration: duration,
      scale: scale,
      child: this,
    );
  }

  /// Adds fade in slide up animation
  Widget fadeInSlideUp({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return AppAnimations.fadeInSlideUp(
      child: this,
      delay: delay,
      duration: duration,
    );
  }

  /// Adds staggered animation for list items
  Widget staggeredFadeIn({
    required int index,
    Duration baseDelay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return AppAnimations.staggeredFadeIn(
      child: this,
      index: index,
      baseDelay: baseDelay,
      duration: duration,
    );
  }

  /// Adds hero scale in animation
  Widget heroScaleIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return AppAnimations.heroScaleIn(
      child: this,
      delay: delay,
      duration: duration,
    );
  }

  /// Adds pulsing animation
  Widget pulsing({
    Duration period = const Duration(milliseconds: 1500),
  }) {
    return AppAnimations.pulsingIndicator(
      child: this,
      period: period,
    );
  }

  /// Adds bounce in animation
  Widget bounceIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return AppAnimations.bounceIn(
      child: this,
      delay: delay,
      duration: duration,
    );
  }
}

/// Press effect widget for buttons
class _PressEffect extends StatefulWidget {
  const _PressEffect({
    required this.child,
    required this.duration,
    required this.scale,
  });

  final Widget child;
  final Duration duration;
  final double scale;

  @override
  State<_PressEffect> createState() => _PressEffectState();
}

class _PressEffectState extends State<_PressEffect> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: AppAnimations.buttonPress,
        child: widget.child,
      ),
    );
  }
}