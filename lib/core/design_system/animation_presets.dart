import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'design_tokens.dart';

/// Reusable animation presets for consistent motion
class AnimationPresets {

  // ============================================================================
  // ENTRANCE ANIMATIONS
  // ============================================================================

  /// Fade in from transparent
  static List<Effect> fadeIn({
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: curve ?? DesignTokens.curveEaseOut,
      ),
    ];
  }

  /// Fade in and slide up
  static List<Effect> fadeInSlideUp({
    Duration? duration,
    Duration? delay,
    double distance = 0.1,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: Offset(0, distance),
        end: Offset.zero,
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }

  /// Fade in and slide from left
  static List<Effect> fadeInSlideLeft({
    Duration? duration,
    Duration? delay,
    double distance = 0.1,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: Offset(-distance, 0),
        end: Offset.zero,
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }

  /// Fade in and slide from right
  static List<Effect> fadeInSlideRight({
    Duration? duration,
    Duration? delay,
    double distance = 0.1,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      SlideEffect(
        begin: Offset(distance, 0),
        end: Offset.zero,
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }

  /// Fade in and scale (bounce effect)
  static List<Effect> fadeInScale({
    Duration? duration,
    Duration? delay,
    Offset? begin,
  }) {
    return [
      FadeEffect(
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
      ),
      ScaleEffect(
        begin: begin ?? const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: duration ?? DesignTokens.durationNormal,
        delay: delay ?? Duration.zero,
        curve: DesignTokens.curveElastic,
      ),
    ];
  }

  // ============================================================================
  // STAGGERED LIST ANIMATIONS
  // ============================================================================

  /// Staggered fade in for list items
  static List<Effect> staggeredFadeIn({
    required int index,
    int baseDelayMs = 100,
    Duration? duration,
  }) {
    return fadeIn(
      duration: duration,
      delay: Duration(milliseconds: baseDelayMs * index),
    );
  }

  /// Staggered fade in and slide for list items
  static List<Effect> staggeredFadeInSlide({
    required int index,
    int baseDelayMs = 100,
    Duration? duration,
    bool fromRight = true,
  }) {
    return fromRight
        ? fadeInSlideRight(
            duration: duration,
            delay: Duration(milliseconds: baseDelayMs * index),
          )
        : fadeInSlideLeft(
            duration: duration,
            delay: Duration(milliseconds: baseDelayMs * index),
          );
  }

  // ============================================================================
  // HOVER/INTERACTION ANIMATIONS
  // ============================================================================

  /// Scale up on hover
  static List<Effect> hoverScale({
    double scale = 1.05,
    Duration? duration,
  }) {
    return [
      ScaleEffect(
        begin: const Offset(1.0, 1.0),
        end: Offset(scale, scale),
        duration: duration ?? DesignTokens.durationSm,
        curve: DesignTokens.curveEaseOut,
      ),
    ];
  }

  /// Shimmer effect for loading states
  static List<Effect> shimmer({
    Duration? duration,
    Color? color,
  }) {
    return [
      ShimmerEffect(
        duration: duration ?? const Duration(seconds: 2),
        color: color ?? Colors.white.withValues(alpha: 0.3),
      ),
    ];
  }

  // ============================================================================
  // PAGE TRANSITION ANIMATIONS
  // ============================================================================

  /// Slide transition for page navigation
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.up:
        begin = const Offset(0, 1);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.left:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-1, 0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: DesignTokens.curveEaseOut,
      )),
      child: child,
    );
  }

  /// Fade transition for page navigation
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Scale transition for modals
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: DesignTokens.curveElastic,
      ),
      child: child,
    );
  }

  // ============================================================================
  // SPECIAL EFFECTS
  // ============================================================================

  /// Pulse effect for notifications/badges
  static List<Effect> pulse({
    Duration? duration,
    int repeat = 1,
  }) {
    return [
      ScaleEffect(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.1, 1.1),
        duration: duration ?? const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    ];
  }

  /// Shake effect for errors
  static List<Effect> shake({
    Duration? duration,
    double intensity = 10.0,
  }) {
    return [
      ShakeEffect(
        duration: duration ?? const Duration(milliseconds: 500),
        hz: 4,
        offset: Offset(intensity, 0),
      ),
    ];
  }

  /// Glow effect for emphasis
  static BoxDecoration glowDecoration({
    required Color color,
    double blur = 12.0,
    double spread = 2.0,
  }) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ],
    );
  }
}

enum SlideDirection {
  up,
  down,
  left,
  right,
}