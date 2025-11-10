import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../animation_presets.dart';

/// Wrapper widget that applies consistent animations
///
/// Usage:
/// ```dart
/// AnimatedContainerPattern(
///   index: 0,
///   animationType: AnimationType.fadeInSlideUp,
///   child: YourWidget(),
/// )
/// ```
class AnimatedContainerPattern extends StatelessWidget {
  const AnimatedContainerPattern({
    super.key,
    required this.child,
    this.index = 0,
    this.animationType = AnimationType.fadeInSlideUp,
    this.baseDelayMs = 100,
    this.duration,
  });

  final Widget child;
  final int index;
  final AnimationType animationType;
  final int baseDelayMs;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    List<Effect> effects;

    switch (animationType) {
      case AnimationType.fadeIn:
        effects = AnimationPresets.fadeIn(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInSlideUp:
        effects = AnimationPresets.fadeInSlideUp(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInSlideLeft:
        effects = AnimationPresets.fadeInSlideLeft(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInSlideRight:
        effects = AnimationPresets.fadeInSlideRight(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.fadeInScale:
        effects = AnimationPresets.fadeInScale(
          duration: duration,
          delay: Duration(milliseconds: baseDelayMs * index),
        );
        break;
      case AnimationType.staggeredFadeInSlide:
        effects = AnimationPresets.staggeredFadeInSlide(
          index: index,
          baseDelayMs: baseDelayMs,
          duration: duration,
        );
        break;
      case AnimationType.none:
        return child;
    }

    return Animate(
      effects: effects,
      child: child,
    );
  }
}

enum AnimationType {
  none,
  fadeIn,
  fadeInSlideUp,
  fadeInSlideLeft,
  fadeInSlideRight,
  fadeInScale,
  staggeredFadeInSlide,
}