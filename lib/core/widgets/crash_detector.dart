import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive crash detection and error boundary system
class CrashDetector {
  static final CrashDetector _instance = CrashDetector._internal();
  factory CrashDetector() => _instance;
  CrashDetector._internal();

  final StreamController<CrashReport> _crashController = StreamController<CrashReport>.broadcast();
  Stream<CrashReport> get crashStream => _crashController.stream;

  Timer? _memoryMonitorTimer;
  Timer? _performanceMonitorTimer;
  bool _isMonitoring = false;

  // Platform-specific crash handlers
  static const MethodChannel _platformChannel = MethodChannel('com.budgettracker.crash');

  Future<void> initialize() async {
    if (_isMonitoring) return;

    _isMonitoring = true;

    // Setup Flutter error handling
    FlutterError.onError = _handleFlutterError;

    // Setup platform-specific crash detection
    await _setupPlatformCrashDetection();

    // Start memory monitoring
    _startMemoryMonitoring();

    // Start performance monitoring
    _startPerformanceMonitoring();

    debugPrint('CrashDetector: Initialized comprehensive crash detection');
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    final crashReport = CrashReport(
      type: CrashType.flutterError,
      message: details.exceptionAsString(),
      stackTrace: details.stack.toString(),
      timestamp: DateTime.now(),
      platformInfo: _getPlatformInfo(),
      memoryInfo: _getMemoryInfo(),
    );

    _crashController.add(crashReport);
    debugPrint('CrashDetector: Flutter error detected: ${crashReport.message}');
  }

  Future<void> _setupPlatformCrashDetection() async {
    try {
      if (Platform.isAndroid) {
        await _setupAndroidCrashDetection();
      } else if (Platform.isIOS) {
        await _setupIOSCrashDetection();
      }
    } catch (e) {
      debugPrint('CrashDetector: Failed to setup platform crash detection: $e');
    }
  }

  Future<void> _setupAndroidCrashDetection() async {
    try {
      // Setup Android-specific crash detection
      // Check for emulator-specific issues based on common emulator properties
      final isEmulator = _detectEmulator();

      if (isEmulator) {
        debugPrint('CrashDetector: Running on Android emulator - enabling enhanced monitoring');
        // Enable more aggressive monitoring for emulators
        _startEmulatorSpecificMonitoring();
      }

      // Setup method channel for native crash detection
      _platformChannel.setMethodCallHandler(_handlePlatformCrash);

    } catch (e) {
      debugPrint('CrashDetector: Android crash detection setup failed: $e');
    }
  }

  bool _detectEmulator() {
    // Simple emulator detection based on common patterns
    final model = Platform.environment['MODEL'] ?? '';
    final manufacturer = Platform.environment['MANUFACTURER'] ?? '';
    final brand = Platform.environment['BRAND'] ?? '';

    return model.toLowerCase().contains('emulator') ||
           model.toLowerCase().contains('sdk') ||
           manufacturer.toLowerCase().contains('google') ||
           brand.toLowerCase().contains('generic');
  }

  Future<void> _setupIOSCrashDetection() async {
    try {
      // Setup iOS-specific crash detection
      _platformChannel.setMethodCallHandler(_handlePlatformCrash);
    } catch (e) {
      debugPrint('CrashDetector: iOS crash detection setup failed: $e');
    }
  }

  Future<dynamic> _handlePlatformCrash(MethodCall call) async {
    switch (call.method) {
      case 'onNativeCrash':
        final crashData = call.arguments as Map<dynamic, dynamic>;
        final crashReport = CrashReport(
          type: CrashType.nativeCrash,
          message: crashData['message'] as String? ?? 'Native crash',
          stackTrace: crashData['stackTrace'] as String? ?? '',
          timestamp: DateTime.now(),
          platformInfo: _getPlatformInfo(),
          memoryInfo: _getMemoryInfo(),
          additionalData: crashData.cast<String, dynamic>(),
        );
        _crashController.add(crashReport);
        break;
      case 'onMemoryWarning':
        final memoryData = call.arguments as Map<dynamic, dynamic>;
        final crashReport = CrashReport(
          type: CrashType.memoryWarning,
          message: 'Memory warning: ${memoryData['availableMemory']} MB available',
          timestamp: DateTime.now(),
          platformInfo: _getPlatformInfo(),
          memoryInfo: _getMemoryInfo(),
          additionalData: memoryData.cast<String, dynamic>(),
        );
        _crashController.add(crashReport);
        break;
    }
  }

  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Check memory usage
      // Note: In Flutter, we can't directly access memory info,
      // but we can monitor for signs of memory pressure
      _checkMemoryPressure();
    });
  }

  void _startPerformanceMonitoring() {
    _performanceMonitorTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Monitor performance metrics
      _checkPerformanceMetrics();
    });
  }

  void _startEmulatorSpecificMonitoring() {
    // Additional monitoring for Android emulators
    Timer.periodic(const Duration(seconds: 10), (timer) {
      // Check for emulator-specific issues
      _checkEmulatorIssues();
    });
  }

  void _checkMemoryPressure() {
    // Monitor for memory-related issues
    // This is a simplified check - in production, you'd use platform channels
    // to get actual memory information
  }

  void _checkPerformanceMetrics() {
    // Monitor frame drops, long operations, etc.
  }

  void _checkEmulatorIssues() {
    // Check for common emulator issues like:
    // - Graphics rendering problems
    // - Memory constraints
    // - Network issues
  }

  Map<String, dynamic> _getPlatformInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isEmulator': false, // Would need platform-specific detection
      'deviceModel': 'Unknown', // Would need device_info_plus
    };
  }

  Map<String, dynamic> _getMemoryInfo() {
    return {
      'availableMemory': 'Unknown', // Would need platform-specific APIs
      'totalMemory': 'Unknown',
      'usedMemory': 'Unknown',
    };
  }

  void dispose() {
    _isMonitoring = false;
    _memoryMonitorTimer?.cancel();
    _performanceMonitorTimer?.cancel();
    _crashController.close();
  }
}

/// Crash report data structure
class CrashReport {
  final CrashType type;
  final String message;
  final String stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic> platformInfo;
  final Map<String, dynamic> memoryInfo;
  final Map<String, dynamic>? additionalData;

  CrashReport({
    required this.type,
    required this.message,
    this.stackTrace = '',
    required this.timestamp,
    required this.platformInfo,
    required this.memoryInfo,
    this.additionalData,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'message': message,
    'stackTrace': stackTrace,
    'timestamp': timestamp.toIso8601String(),
    'platformInfo': platformInfo,
    'memoryInfo': memoryInfo,
    'additionalData': additionalData,
  };
}

/// Types of crashes we can detect
enum CrashType {
  flutterError,
  nativeCrash,
  memoryWarning,
  performanceIssue,
  renderingError,
}

/// Error boundary widget that catches and reports crashes
class CrashBoundary extends StatefulWidget {
  const CrashBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
    this.onCrash,
  });

  final Widget child;
  final Widget Function(BuildContext, CrashReport)? fallbackBuilder;
  final void Function(CrashReport)? onCrash;

  @override
  State<CrashBoundary> createState() => _CrashBoundaryState();
}

class _CrashBoundaryState extends State<CrashBoundary> {
  CrashReport? _lastCrash;

  @override
  void initState() {
    super.initState();
    CrashDetector().crashStream.listen(_handleCrash);
  }

  void _handleCrash(CrashReport report) {
    if (mounted) {
      setState(() {
        _lastCrash = report;
      });
      widget.onCrash?.call(report);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lastCrash != null && widget.fallbackBuilder != null) {
      return widget.fallbackBuilder!(context, _lastCrash!);
    }

    return widget.child;
  }
}

/// CustomPainter error boundary
class SafeCustomPainter extends CustomPainter {
  final CustomPainter painter;
  final Widget? errorWidget;

  SafeCustomPainter({
    required this.painter,
    this.errorWidget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      painter.paint(canvas, size);
    } catch (e, stackTrace) {
      debugPrint('SafeCustomPainter: Error in painter: $e');
      debugPrint('Stack trace: $stackTrace');

      // Report crash
      final crashReport = CrashReport(
        type: CrashType.renderingError,
        message: 'CustomPainter crash: $e',
        stackTrace: stackTrace.toString(),
        timestamp: DateTime.now(),
        platformInfo: CrashDetector()._getPlatformInfo(),
        memoryInfo: CrashDetector()._getMemoryInfo(),
      );

      CrashDetector()._crashController.add(crashReport);

      // Draw error indicator
      final paint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Offset.zero & size, paint);

      final errorPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(Offset.zero, Offset(size.width, size.height), errorPaint);
      canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), errorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is SafeCustomPainter) {
      return painter.shouldRepaint(oldDelegate.painter);
    }
    return true;
  }

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}