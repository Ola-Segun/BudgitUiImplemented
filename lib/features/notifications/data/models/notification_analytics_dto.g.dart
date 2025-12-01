// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_analytics_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationAnalyticsDtoAdapter
    extends TypeAdapter<NotificationAnalyticsDto> {
  @override
  final int typeId = 201;

  @override
  NotificationAnalyticsDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationAnalyticsDto(
      id: fields[0] as String,
      notificationId: fields[1] as String,
      sentAt: fields[2] as DateTime,
      readAt: fields[3] as DateTime?,
      clickedAt: fields[4] as DateTime?,
      actionTaken: fields[5] as String?,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationAnalyticsDto obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.notificationId)
      ..writeByte(2)
      ..write(obj.sentAt)
      ..writeByte(3)
      ..write(obj.readAt)
      ..writeByte(4)
      ..write(obj.clickedAt)
      ..writeByte(5)
      ..write(obj.actionTaken)
      ..writeByte(6)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationAnalyticsDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationAnalyticsDto _$NotificationAnalyticsDtoFromJson(
        Map<String, dynamic> json) =>
    NotificationAnalyticsDto(
      id: json['id'] as String,
      notificationId: json['notificationId'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      clickedAt: json['clickedAt'] == null
          ? null
          : DateTime.parse(json['clickedAt'] as String),
      actionTaken: json['actionTaken'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationAnalyticsDtoToJson(
        NotificationAnalyticsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notificationId': instance.notificationId,
      'sentAt': instance.sentAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'clickedAt': instance.clickedAt?.toIso8601String(),
      'actionTaken': instance.actionTaken,
      'metadata': instance.metadata,
    };
