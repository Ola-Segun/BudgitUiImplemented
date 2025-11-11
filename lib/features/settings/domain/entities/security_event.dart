import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_event.freezed.dart';
part 'security_event.g.dart';

/// Types of security events that can be tracked
enum SecurityEventType {
  loginAttempt,
  loginSuccess,
  loginFailure,
  deviceChange,
  passwordChange,
  twoFactorEnabled,
  twoFactorDisabled,
  dataExport,
  dataImport,
  settingsChange,
  accountDeletion,
  suspiciousActivity,
}

/// Security event entity for tracking user activities
@freezed
class SecurityEvent with _$SecurityEvent {
  const factory SecurityEvent({
    required String id,
    required SecurityEventType type,
    required DateTime timestamp,
    required String userId,
    required String description,
    String? ipAddress,
    String? userAgent,
    String? deviceInfo,
    String? location,
    Map<String, dynamic>? metadata,
    bool? suspicious,
  }) = _SecurityEvent;

  factory SecurityEvent.fromJson(Map<String, dynamic> json) =>
      _$SecurityEventFromJson(json);

  /// Create a login attempt event
  factory SecurityEvent.loginAttempt({
    required String userId,
    required bool successful,
    String? ipAddress,
    String? deviceInfo,
    String? location,
  }) {
    return SecurityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: successful ? SecurityEventType.loginSuccess : SecurityEventType.loginFailure,
      timestamp: DateTime.now(),
      userId: userId,
      description: successful ? 'Successful login' : 'Failed login attempt',
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
      location: location,
      suspicious: !successful,
    );
  }

  /// Create a device change event
  factory SecurityEvent.deviceChange({
    required String userId,
    required String oldDevice,
    required String newDevice,
    String? ipAddress,
    String? location,
  }) {
    return SecurityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SecurityEventType.deviceChange,
      timestamp: DateTime.now(),
      userId: userId,
      description: 'Device changed from $oldDevice to $newDevice',
      ipAddress: ipAddress,
      location: location,
      metadata: {
        'oldDevice': oldDevice,
        'newDevice': newDevice,
      },
    );
  }

  /// Create a data export event
  factory SecurityEvent.dataExport({
    required String userId,
    required String exportType,
    required int recordCount,
    String? ipAddress,
    String? deviceInfo,
  }) {
    return SecurityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SecurityEventType.dataExport,
      timestamp: DateTime.now(),
      userId: userId,
      description: 'Data exported: $exportType ($recordCount records)',
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
      metadata: {
        'exportType': exportType,
        'recordCount': recordCount,
      },
    );
  }

  /// Create a settings change event
  factory SecurityEvent.settingsChange({
    required String userId,
    required String settingName,
    required String oldValue,
    required String newValue,
    String? ipAddress,
  }) {
    return SecurityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SecurityEventType.settingsChange,
      timestamp: DateTime.now(),
      userId: userId,
      description: 'Setting changed: $settingName',
      ipAddress: ipAddress,
      metadata: {
        'settingName': settingName,
        'oldValue': oldValue,
        'newValue': newValue,
      },
    );
  }

  /// Create a suspicious activity event
  factory SecurityEvent.suspiciousActivity({
    required String userId,
    required String activity,
    required String reason,
    String? ipAddress,
    String? location,
  }) {
    return SecurityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SecurityEventType.suspiciousActivity,
      timestamp: DateTime.now(),
      userId: userId,
      description: 'Suspicious activity: $activity',
      ipAddress: ipAddress,
      location: location,
      suspicious: true,
      metadata: {
        'activity': activity,
        'reason': reason,
      },
    );
  }
}