// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationAnalytics {
  String get id => throw _privateConstructorUsedError;
  String get notificationId => throw _privateConstructorUsedError;
  DateTime get sentAt => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime? get clickedAt => throw _privateConstructorUsedError;
  String? get actionTaken => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationAnalyticsCopyWith<NotificationAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationAnalyticsCopyWith<$Res> {
  factory $NotificationAnalyticsCopyWith(NotificationAnalytics value,
          $Res Function(NotificationAnalytics) then) =
      _$NotificationAnalyticsCopyWithImpl<$Res, NotificationAnalytics>;
  @useResult
  $Res call(
      {String id,
      String notificationId,
      DateTime sentAt,
      DateTime? readAt,
      DateTime? clickedAt,
      String? actionTaken,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$NotificationAnalyticsCopyWithImpl<$Res,
        $Val extends NotificationAnalytics>
    implements $NotificationAnalyticsCopyWith<$Res> {
  _$NotificationAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notificationId = null,
    Object? sentAt = null,
    Object? readAt = freezed,
    Object? clickedAt = freezed,
    Object? actionTaken = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      notificationId: null == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      clickedAt: freezed == clickedAt
          ? _value.clickedAt
          : clickedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actionTaken: freezed == actionTaken
          ? _value.actionTaken
          : actionTaken // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationAnalyticsImplCopyWith<$Res>
    implements $NotificationAnalyticsCopyWith<$Res> {
  factory _$$NotificationAnalyticsImplCopyWith(
          _$NotificationAnalyticsImpl value,
          $Res Function(_$NotificationAnalyticsImpl) then) =
      __$$NotificationAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String notificationId,
      DateTime sentAt,
      DateTime? readAt,
      DateTime? clickedAt,
      String? actionTaken,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$NotificationAnalyticsImplCopyWithImpl<$Res>
    extends _$NotificationAnalyticsCopyWithImpl<$Res,
        _$NotificationAnalyticsImpl>
    implements _$$NotificationAnalyticsImplCopyWith<$Res> {
  __$$NotificationAnalyticsImplCopyWithImpl(_$NotificationAnalyticsImpl _value,
      $Res Function(_$NotificationAnalyticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notificationId = null,
    Object? sentAt = null,
    Object? readAt = freezed,
    Object? clickedAt = freezed,
    Object? actionTaken = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$NotificationAnalyticsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      notificationId: null == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      clickedAt: freezed == clickedAt
          ? _value.clickedAt
          : clickedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actionTaken: freezed == actionTaken
          ? _value.actionTaken
          : actionTaken // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$NotificationAnalyticsImpl extends _NotificationAnalytics {
  const _$NotificationAnalyticsImpl(
      {required this.id,
      required this.notificationId,
      required this.sentAt,
      this.readAt,
      this.clickedAt,
      this.actionTaken,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  @override
  final String id;
  @override
  final String notificationId;
  @override
  final DateTime sentAt;
  @override
  final DateTime? readAt;
  @override
  final DateTime? clickedAt;
  @override
  final String? actionTaken;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationAnalytics(id: $id, notificationId: $notificationId, sentAt: $sentAt, readAt: $readAt, clickedAt: $clickedAt, actionTaken: $actionTaken, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationAnalyticsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.clickedAt, clickedAt) ||
                other.clickedAt == clickedAt) &&
            (identical(other.actionTaken, actionTaken) ||
                other.actionTaken == actionTaken) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      notificationId,
      sentAt,
      readAt,
      clickedAt,
      actionTaken,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationAnalyticsImplCopyWith<_$NotificationAnalyticsImpl>
      get copyWith => __$$NotificationAnalyticsImplCopyWithImpl<
          _$NotificationAnalyticsImpl>(this, _$identity);
}

abstract class _NotificationAnalytics extends NotificationAnalytics {
  const factory _NotificationAnalytics(
      {required final String id,
      required final String notificationId,
      required final DateTime sentAt,
      final DateTime? readAt,
      final DateTime? clickedAt,
      final String? actionTaken,
      final Map<String, dynamic>? metadata}) = _$NotificationAnalyticsImpl;
  const _NotificationAnalytics._() : super._();

  @override
  String get id;
  @override
  String get notificationId;
  @override
  DateTime get sentAt;
  @override
  DateTime? get readAt;
  @override
  DateTime? get clickedAt;
  @override
  String? get actionTaken;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$NotificationAnalyticsImplCopyWith<_$NotificationAnalyticsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
