import 'package:flutter/material.dart';

/// Animation constants and utilities for the app
class AppAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

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