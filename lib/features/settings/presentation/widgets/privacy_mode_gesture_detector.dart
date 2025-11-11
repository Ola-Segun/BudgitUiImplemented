import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Widget that detects three-finger double tap gestures for privacy mode activation
class PrivacyModeGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPrivacyModeToggled;

  const PrivacyModeGestureDetector({
    super.key,
    required this.child,
    this.onPrivacyModeToggled,
  });

  @override
  State<PrivacyModeGestureDetector> createState() => _PrivacyModeGestureDetectorState();
}

class _PrivacyModeGestureDetectorState extends State<PrivacyModeGestureDetector> {
  DateTime? _lastTapTime;
  int _tapCount = 0;
  final int _currentPointerCount = 0;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _ThreeFingerTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<_ThreeFingerTapGestureRecognizer>(
          () => _ThreeFingerTapGestureRecognizer(),
          (_ThreeFingerTapGestureRecognizer instance) {
            instance.onThreeFingerTap = _handleThreeFingerTap;
          },
        ),
      },
      child: widget.child,
    );
  }

  void _handleThreeFingerTap() {
    final now = DateTime.now();

    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500) {
      // Double tap detected within time window
      // Import and use privacy service here to avoid circular dependency
      // For now, just call the callback
      widget.onPrivacyModeToggled?.call();
      _tapCount = 0;
    } else {
      _tapCount = 1;
    }

    _lastTapTime = now;

    // Reset tap count after timeout
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _tapCount == 1) {
        _tapCount = 0;
      }
    });
  }
}

/// Custom gesture recognizer for three-finger taps
class _ThreeFingerTapGestureRecognizer extends OneSequenceGestureRecognizer {
  GestureTapCallback? onThreeFingerTap;
  int _pointerCount = 0;

  @override
  void addPointer(PointerDownEvent event) {
    _pointerCount++;
    if (_pointerCount == 3 && onThreeFingerTap != null) {
      resolve(GestureDisposition.accepted);
      onThreeFingerTap!();
      _pointerCount = 0; // Reset for next gesture
    } else if (_pointerCount > 3) {
      resolve(GestureDisposition.rejected);
      _pointerCount = 0;
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent) {
      _pointerCount = 0;
    }
  }

  @override
  String get debugDescription => 'three finger tap';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointerCount = 0;
  }
}