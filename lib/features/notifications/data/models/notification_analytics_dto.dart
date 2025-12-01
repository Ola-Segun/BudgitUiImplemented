import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notification_analytics.dart';

part 'notification_analytics_dto.g.dart';

/// Data Transfer Object for NotificationAnalytics entity
/// Used for serialization/deserialization with Hive and JSON
@HiveType(typeId: 201)
@JsonSerializable()
class NotificationAnalyticsDto {
  const NotificationAnalyticsDto({
    required this.id,
    required this.notificationId,
    required this.sentAt,
    this.readAt,
    this.clickedAt,
    this.actionTaken,
    this.metadata,
  });

  factory NotificationAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationAnalyticsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationAnalyticsDtoToJson(this);

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String notificationId;
  @HiveField(2)
  final DateTime sentAt;
  @HiveField(3)
  final DateTime? readAt;
  @HiveField(4)
  final DateTime? clickedAt;
  @HiveField(5)
  final String? actionTaken;
  @HiveField(6)
  final Map<String, dynamic>? metadata;

  /// Convert from domain entity
  factory NotificationAnalyticsDto.fromDomain(NotificationAnalytics analytics) {
    return NotificationAnalyticsDto(
      id: analytics.id,
      notificationId: analytics.notificationId,
      sentAt: analytics.sentAt,
      readAt: analytics.readAt,
      clickedAt: analytics.clickedAt,
      actionTaken: analytics.actionTaken,
      metadata: analytics.metadata,
    );
  }

  /// Convert to domain entity
  NotificationAnalytics toDomain() {
    return NotificationAnalytics(
      id: id,
      notificationId: notificationId,
      sentAt: sentAt,
      readAt: readAt,
      clickedAt: clickedAt,
      actionTaken: actionTaken,
      metadata: metadata,
    );
  }
}