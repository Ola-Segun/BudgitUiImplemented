import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform-specific crash handling for Android emulators and devices
class PlatformCrashHandler {
  static final PlatformCrashHandler _instance = PlatformCrashHandler._internal();
  factory PlatformCrashHandler() => _instance;
  PlatformCrashHandler._internal();

  static const MethodChannel _platformChannel = MethodChannel('com.budgettracker.platform_crash');
  final StreamController<PlatformCrashReport> _crashController = StreamController<PlatformCrashReport>.broadcast();

  Stream<PlatformCrashReport> get crashStream => _crashController.stream;

  bool _isInitialized = false;
  Timer? _healthCheckTimer;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Setup platform-specific crash detection
      if (Platform.isAndroid) {
        await _setupAndroidCrashHandling();
      } else if (Platform.isIOS) {
        await _setupIOSCrashHandling();
      }

      // Start health monitoring
      _startHealthMonitoring();

      _isInitialized = true;
      debugPrint('PlatformCrashHandler: Initialized for ${Platform.operatingSystem}');
    } catch (e) {
      debugPrint('PlatformCrashHandler: Failed to initialize: $e');
    }
  }

  Future<void> _setupAndroidCrashHandling() async {
    try {
      // Setup method channel for native Android crash detection
      _platformChannel.setMethodCallHandler(_handlePlatformCrash);

      // Configure emulator-specific handling
      final isEmulator = await _detectAndroidEmulator();
      if (isEmulator) {
        await _configureEmulatorHandling();
      }

      // Setup ANR detection
      await _setupANRDetection();

      // Setup memory pressure handling
      await _setupMemoryPressureHandling();

    } catch (e) {
      debugPrint('PlatformCrashHandler: Android setup failed: $e');
    }
  }

  Future<void> _setupIOSCrashHandling() async {
    try {
      _platformChannel.setMethodCallHandler(_handlePlatformCrash);
      // iOS-specific crash handling setup
    } catch (e) {
      debugPrint('PlatformCrashHandler: iOS setup failed: $e');
    }
  }

  Future<bool> _detectAndroidEmulator() async {
    try {
      // Multiple methods to detect Android emulator
      final result = await _platformChannel.invokeMethod('isEmulator');
      return result == true;
    } catch (e) {
      // Fallback detection methods
      return _fallbackEmulatorDetection();
    }
  }

  bool _fallbackEmulatorDetection() {
    // Check common emulator indicators
    final brand = Platform.environment['BRAND']?.toLowerCase() ?? '';
    final device = Platform.environment['DEVICE']?.toLowerCase() ?? '';
    final model = Platform.environment['MODEL']?.toLowerCase() ?? '';

    return brand.contains('generic') ||
           device.contains('emulator') ||
           model.contains('sdk') ||
           model.contains('emulator');
  }

  Future<void> _configureEmulatorHandling() async {
    try {
      // Configure special handling for emulators
      await _platformChannel.invokeMethod('configureEmulatorMode', {
        'aggressiveGc': true,
        'memoryThreshold': 50 * 1024 * 1024, // 50MB
        'frameDropThreshold': 30, // fps
      });

      debugPrint('PlatformCrashHandler: Configured emulator-specific handling');
    } catch (e) {
      debugPrint('PlatformCrashHandler: Failed to configure emulator handling: $e');
    }
  }

  Future<void> _setupANRDetection() async {
    try {
      await _platformChannel.invokeMethod('setupANRDetection', {
        'timeoutMs': 5000, // 5 seconds
        'checkIntervalMs': 1000, // 1 second
      });
    } catch (e) {
      debugPrint('PlatformCrashHandler: ANR detection setup failed: $e');
    }
  }

  Future<void> _setupMemoryPressureHandling() async {
    try {
      await _platformChannel.invokeMethod('setupMemoryPressureHandling', {
        'warningThreshold': 100 * 1024 * 1024, // 100MB
        'criticalThreshold': 150 * 1024 * 1024, // 150MB
      });
    } catch (e) {
      debugPrint('PlatformCrashHandler: Memory pressure handling setup failed: $e');
    }
  }

  Future<dynamic> _handlePlatformCrash(MethodCall call) async {
    switch (call.method) {
      case 'onANRDetected':
        final report = PlatformCrashReport(
          type: PlatformCrashType.anr,
          message: 'Application Not Responding detected',
          timestamp: DateTime.now(),
          platformData: call.arguments as Map<dynamic, dynamic>?,
        );
        _crashController.add(report);
        break;

      case 'onMemoryPressure':
        final data = call.arguments as Map<dynamic, dynamic>;
        final report = PlatformCrashReport(
          type: PlatformCrashType.memoryPressure,
          message: 'Memory pressure: ${data['availableMemory']} MB available',
          timestamp: DateTime.now(),
          platformData: data,
        );
        _crashController.add(report);
        break;

      case 'onEmulatorIssue':
        final data = call.arguments as Map<dynamic, dynamic>;
        final report = PlatformCrashReport(
          type: PlatformCrashType.emulatorIssue,
          message: 'Emulator-specific issue: ${data['issue']}',
          timestamp: DateTime.now(),
          platformData: data,
        );
        _crashController.add(report);
        break;

      case 'onNativeCrash':
        final data = call.arguments as Map<dynamic, dynamic>;
        final report = PlatformCrashReport(
          type: PlatformCrashType.nativeCrash,
          message: data['message'] as String? ?? 'Native crash',
          timestamp: DateTime.now(),
          platformData: data,
        );
        _crashController.add(report);
        break;
    }
  }

  void _startHealthMonitoring() {
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        // Perform health checks
        await _performHealthCheck();
      } catch (e) {
        debugPrint('PlatformCrashHandler: Health check failed: $e');
      }
    });
  }

  Future<void> _performHealthCheck() async {
    try {
      final result = await _platformChannel.invokeMethod('healthCheck');
      final healthData = result as Map<dynamic, dynamic>;

      // Check for concerning health metrics
      final memoryUsage = healthData['memoryUsage'] as int?;
      final frameDrops = healthData['frameDrops'] as int?;

      if (memoryUsage != null && memoryUsage > 200 * 1024 * 1024) { // 200MB
        final report = PlatformCrashReport(
          type: PlatformCrashType.memoryPressure,
          message: 'High memory usage detected: ${memoryUsage ~/ (1024 * 1024)} MB',
          timestamp: DateTime.now(),
          platformData: healthData,
        );
        _crashController.add(report);
      }

      if (frameDrops != null && frameDrops > 50) {
        final report = PlatformCrashReport(
          type: PlatformCrashType.performanceIssue,
          message: 'High frame drops detected: $frameDrops',
          timestamp: DateTime.now(),
          platformData: healthData,
        );
        _crashController.add(report);
      }

    } catch (e) {
      debugPrint('PlatformCrashHandler: Health check invocation failed: $e');
    }
  }

  /// Force garbage collection (useful for memory pressure testing)
  Future<void> forceGC() async {
    try {
      await _platformChannel.invokeMethod('forceGC');
    } catch (e) {
      debugPrint('PlatformCrashHandler: Force GC failed: $e');
    }
  }

  /// Get platform-specific diagnostics
  Future<Map<String, dynamic>> getDiagnostics() async {
    try {
      final result = await _platformChannel.invokeMethod('getDiagnostics');
      return result as Map<String, dynamic>;
    } catch (e) {
      debugPrint('PlatformCrashHandler: Failed to get diagnostics: $e');
      return {};
    }
  }

  void dispose() {
    _healthCheckTimer?.cancel();
    _crashController.close();
    _isInitialized = false;
  }
}

/// Platform-specific crash report
class PlatformCrashReport {
  final PlatformCrashType type;
  final String message;
  final DateTime timestamp;
  final Map<dynamic, dynamic>? platformData;

  PlatformCrashReport({
    required this.type,
    required this.message,
    required this.timestamp,
    this.platformData,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'platformData': platformData,
  };
}

/// Types of platform-specific crashes/issues
enum PlatformCrashType {
  anr,
  memoryPressure,
  emulatorIssue,
  nativeCrash,
  performanceIssue,
}