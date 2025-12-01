import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notification.dart';

part 'notification_dto.g.dart';

/// Data Transfer Object for Notification entity
/// Used for serialization/deserialization with Hive and JSON
@HiveType(typeId: 200)
@JsonSerializable()
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.scheduledFor,
    this.isRead,
    this.actionUrl,
    this.metadata,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String message;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final String priority;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime? scheduledFor;
  @HiveField(7)
  final bool? isRead;
  @HiveField(8)
  final String? actionUrl;
  @HiveField(9)
  final Map<String, dynamic>? metadata;

  /// Convert from domain entity
  factory NotificationDto.fromDomain(AppNotification notification) {
    return NotificationDto(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: notification.type.name,
      priority: notification.priority.name,
      createdAt: notification.createdAt,
      scheduledFor: notification.scheduledFor,
      isRead: notification.isRead,
      actionUrl: notification.actionUrl,
      metadata: notification.metadata,
    );
  }

  /// Convert to domain entity
  AppNotification toDomain() {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: _parseNotificationType(type),
      priority: _parseNotificationPriority(priority),
      createdAt: createdAt,
      scheduledFor: scheduledFor,
      isRead: isRead,
      actionUrl: actionUrl,
      metadata: metadata,
    );
  }

  static NotificationType _parseNotificationType(String typeString) {
    return NotificationType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => NotificationType.custom,
    );
  }

  static NotificationPriority _parseNotificationPriority(String priorityString) {
    return NotificationPriority.values.firstWhere(
      (e) => e.name == priorityString,
      orElse: () => NotificationPriority.low,
    );
  }
}