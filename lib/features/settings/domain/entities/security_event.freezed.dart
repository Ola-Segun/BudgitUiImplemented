// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SecurityEvent _$SecurityEventFromJson(Map<String, dynamic> json) {
  return _SecurityEvent.fromJson(json);
}

/// @nodoc
mixin _$SecurityEvent {
  String get id => throw _privateConstructorUsedError;
  SecurityEventType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get userAgent => throw _privateConstructorUsedError;
  String? get deviceInfo => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool? get suspicious => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SecurityEventCopyWith<SecurityEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityEventCopyWith<$Res> {
  factory $SecurityEventCopyWith(
          SecurityEvent value, $Res Function(SecurityEvent) then) =
      _$SecurityEventCopyWithImpl<$Res, SecurityEvent>;
  @useResult
  $Res call(
      {String id,
      SecurityEventType type,
      DateTime timestamp,
      String userId,
      String description,
      String? ipAddress,
      String? userAgent,
      String? deviceInfo,
      String? location,
      Map<String, dynamic>? metadata,
      bool? suspicious});
}

/// @nodoc
class _$SecurityEventCopyWithImpl<$Res, $Val extends SecurityEvent>
    implements $SecurityEventCopyWith<$Res> {
  _$SecurityEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? userId = null,
    Object? description = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? deviceInfo = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
    Object? suspicious = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SecurityEventType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      suspicious: freezed == suspicious
          ? _value.suspicious
          : suspicious // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SecurityEventImplCopyWith<$Res>
    implements $SecurityEventCopyWith<$Res> {
  factory _$$SecurityEventImplCopyWith(
          _$SecurityEventImpl value, $Res Function(_$SecurityEventImpl) then) =
      __$$SecurityEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SecurityEventType type,
      DateTime timestamp,
      String userId,
      String description,
      String? ipAddress,
      String? userAgent,
      String? deviceInfo,
      String? location,
      Map<String, dynamic>? metadata,
      bool? suspicious});
}

/// @nodoc
class __$$SecurityEventImplCopyWithImpl<$Res>
    extends _$SecurityEventCopyWithImpl<$Res, _$SecurityEventImpl>
    implements _$$SecurityEventImplCopyWith<$Res> {
  __$$SecurityEventImplCopyWithImpl(
      _$SecurityEventImpl _value, $Res Function(_$SecurityEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? userId = null,
    Object? description = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? deviceInfo = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
    Object? suspicious = freezed,
  }) {
    return _then(_$SecurityEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SecurityEventType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      suspicious: freezed == suspicious
          ? _value.suspicious
          : suspicious // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityEventImpl implements _SecurityEvent {
  const _$SecurityEventImpl(
      {required this.id,
      required this.type,
      required this.timestamp,
      required this.userId,
      required this.description,
      this.ipAddress,
      this.userAgent,
      this.deviceInfo,
      this.location,
      final Map<String, dynamic>? metadata,
      this.suspicious})
      : _metadata = metadata;

  factory _$SecurityEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityEventImplFromJson(json);

  @override
  final String id;
  @override
  final SecurityEventType type;
  @override
  final DateTime timestamp;
  @override
  final String userId;
  @override
  final String description;
  @override
  final String? ipAddress;
  @override
  final String? userAgent;
  @override
  final String? deviceInfo;
  @override
  final String? location;
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
  final bool? suspicious;

  @override
  String toString() {
    return 'SecurityEvent(id: $id, type: $type, timestamp: $timestamp, userId: $userId, description: $description, ipAddress: $ipAddress, userAgent: $userAgent, deviceInfo: $deviceInfo, location: $location, metadata: $metadata, suspicious: $suspicious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.suspicious, suspicious) ||
                other.suspicious == suspicious));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      timestamp,
      userId,
      description,
      ipAddress,
      userAgent,
      deviceInfo,
      location,
      const DeepCollectionEquality().hash(_metadata),
      suspicious);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityEventImplCopyWith<_$SecurityEventImpl> get copyWith =>
      __$$SecurityEventImplCopyWithImpl<_$SecurityEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityEventImplToJson(
      this,
    );
  }
}

abstract class _SecurityEvent implements SecurityEvent {
  const factory _SecurityEvent(
      {required final String id,
      required final SecurityEventType type,
      required final DateTime timestamp,
      required final String userId,
      required final String description,
      final String? ipAddress,
      final String? userAgent,
      final String? deviceInfo,
      final String? location,
      final Map<String, dynamic>? metadata,
      final bool? suspicious}) = _$SecurityEventImpl;

  factory _SecurityEvent.fromJson(Map<String, dynamic> json) =
      _$SecurityEventImpl.fromJson;

  @override
  String get id;
  @override
  SecurityEventType get type;
  @override
  DateTime get timestamp;
  @override
  String get userId;
  @override
  String get description;
  @override
  String? get ipAddress;
  @override
  String? get userAgent;
  @override
  String? get deviceInfo;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get metadata;
  @override
  bool? get suspicious;
  @override
  @JsonKey(ignore: true)
  _$$SecurityEventImplCopyWith<_$SecurityEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
