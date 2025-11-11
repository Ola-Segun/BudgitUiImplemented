import '../entities/security_event.dart';

/// Service for monitoring and logging security events
class SecurityMonitoringService {
  static final SecurityMonitoringService _instance = SecurityMonitoringService._internal();
  factory SecurityMonitoringService() => _instance;
  SecurityMonitoringService._internal();

  final List<SecurityEvent> _events = [];
  static const int _maxEvents = 1000; // Keep last 1000 events

  /// Get all security events
  List<SecurityEvent> get events => List.unmodifiable(_events);

  /// Get events by type
  List<SecurityEvent> getEventsByType(SecurityEventType type) {
    return _events.where((event) => event.type == type).toList();
  }

  /// Get recent events (last N events)
  List<SecurityEvent> getRecentEvents({int count = 50}) {
    final startIndex = _events.length > count ? _events.length - count : 0;
    return _events.sublist(startIndex);
  }

  /// Get suspicious events
  List<SecurityEvent> getSuspiciousEvents() {
    return _events.where((event) => event.suspicious == true).toList();
  }

  /// Log a security event
  void logEvent(SecurityEvent event) {
    _events.add(event);

    // Maintain max events limit
    if (_events.length > _maxEvents) {
      _events.removeAt(0);
    }

    // In a real app, this would also persist to storage
    _persistEvent(event);
  }

  /// Log login attempt
  void logLoginAttempt({
    required String userId,
    required bool successful,
    String? ipAddress,
    String? deviceInfo,
    String? location,
  }) {
    final event = SecurityEvent.loginAttempt(
      userId: userId,
      successful: successful,
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
      location: location,
    );
    logEvent(event);
  }

  /// Log device change
  void logDeviceChange({
    required String userId,
    required String oldDevice,
    required String newDevice,
    String? ipAddress,
    String? location,
  }) {
    final event = SecurityEvent.deviceChange(
      userId: userId,
      oldDevice: oldDevice,
      newDevice: newDevice,
      ipAddress: ipAddress,
      location: location,
    );
    logEvent(event);
  }

  /// Log data export
  void logDataExport({
    required String userId,
    required String exportType,
    required int recordCount,
    String? ipAddress,
    String? deviceInfo,
  }) {
    final event = SecurityEvent.dataExport(
      userId: userId,
      exportType: exportType,
      recordCount: recordCount,
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
    );
    logEvent(event);
  }

  /// Log settings change
  void logSettingsChange({
    required String userId,
    required String settingName,
    required String oldValue,
    required String newValue,
    String? ipAddress,
  }) {
    final event = SecurityEvent.settingsChange(
      userId: userId,
      settingName: settingName,
      oldValue: oldValue,
      newValue: newValue,
      ipAddress: ipAddress,
    );
    logEvent(event);
  }

  /// Log suspicious activity
  void logSuspiciousActivity({
    required String userId,
    required String activity,
    required String reason,
    String? ipAddress,
    String? location,
  }) {
    final event = SecurityEvent.suspiciousActivity(
      userId: userId,
      activity: activity,
      reason: reason,
      ipAddress: ipAddress,
      location: location,
    );
    logEvent(event);
  }

  /// Check for suspicious patterns
  List<String> checkForSuspiciousPatterns(String userId) {
    final userEvents = _events.where((event) => event.userId == userId).toList();
    final warnings = <String>[];

    // Check for multiple failed login attempts
    final recentFailures = userEvents
        .where((event) =>
            event.type == SecurityEventType.loginFailure &&
            event.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
        .length;

    if (recentFailures >= 5) {
      warnings.add('Multiple failed login attempts detected');
    }

    // Check for logins from different locations
    final recentLocations = userEvents
        .where((event) =>
            event.type == SecurityEventType.loginSuccess &&
            event.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24))))
        .map((event) => event.location)
        .where((location) => location != null)
        .toSet();

    if (recentLocations.length > 3) {
      warnings.add('Logins from multiple locations detected');
    }

    // Check for frequent data exports
    final recentExports = userEvents
        .where((event) =>
            event.type == SecurityEventType.dataExport &&
            event.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24))))
        .length;

    if (recentExports >= 3) {
      warnings.add('Frequent data exports detected');
    }

    return warnings;
  }

  /// Clear old events (older than specified days)
  void clearOldEvents({int daysToKeep = 90}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    _events.removeWhere((event) => event.timestamp.isBefore(cutoffDate));
  }

  /// Export events for analysis
  List<Map<String, dynamic>> exportEvents({
    DateTime? startDate,
    DateTime? endDate,
    SecurityEventType? eventType,
  }) {
    var filteredEvents = _events;

    if (startDate != null) {
      filteredEvents = filteredEvents.where((event) => event.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filteredEvents = filteredEvents.where((event) => event.timestamp.isBefore(endDate)).toList();
    }

    if (eventType != null) {
      filteredEvents = filteredEvents.where((event) => event.type == eventType).toList();
    }

    return filteredEvents.map((event) => event.toJson()).toList();
  }

  /// Persist event to storage (placeholder implementation)
  void _persistEvent(SecurityEvent event) {
    // In a real implementation, this would save to a database or file
    // For now, events are kept in memory only
  }

  /// Load events from storage (placeholder implementation)
  void loadEvents() {
    // In a real implementation, this would load from a database or file
    // For now, events are kept in memory only
  }
}