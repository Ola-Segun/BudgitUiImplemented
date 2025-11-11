// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecurityEventImpl _$$SecurityEventImplFromJson(Map<String, dynamic> json) =>
    _$SecurityEventImpl(
      id: json['id'] as String,
      type: $enumDecode(_$SecurityEventTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      description: json['description'] as String,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      location: json['location'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      suspicious: json['suspicious'] as bool?,
    );

Map<String, dynamic> _$$SecurityEventImplToJson(_$SecurityEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SecurityEventTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
      'description': instance.description,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'deviceInfo': instance.deviceInfo,
      'location': instance.location,
      'metadata': instance.metadata,
      'suspicious': instance.suspicious,
    };

const _$SecurityEventTypeEnumMap = {
  SecurityEventType.loginAttempt: 'loginAttempt',
  SecurityEventType.loginSuccess: 'loginSuccess',
  SecurityEventType.loginFailure: 'loginFailure',
  SecurityEventType.deviceChange: 'deviceChange',
  SecurityEventType.passwordChange: 'passwordChange',
  SecurityEventType.twoFactorEnabled: 'twoFactorEnabled',
  SecurityEventType.twoFactorDisabled: 'twoFactorDisabled',
  SecurityEventType.dataExport: 'dataExport',
  SecurityEventType.dataImport: 'dataImport',
  SecurityEventType.settingsChange: 'settingsChange',
  SecurityEventType.accountDeletion: 'accountDeletion',
  SecurityEventType.suspiciousActivity: 'suspiciousActivity',
};
