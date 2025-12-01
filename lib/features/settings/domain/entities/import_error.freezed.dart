// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ImportError {
  ImportErrorType get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  int get lineNumber => throw _privateConstructorUsedError;
  String? get field => throw _privateConstructorUsedError;
  String? get value => throw _privateConstructorUsedError;
  String? get suggestion => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ImportErrorCopyWith<ImportError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportErrorCopyWith<$Res> {
  factory $ImportErrorCopyWith(
          ImportError value, $Res Function(ImportError) then) =
      _$ImportErrorCopyWithImpl<$Res, ImportError>;
  @useResult
  $Res call(
      {ImportErrorType type,
      String message,
      int lineNumber,
      String? field,
      String? value,
      String? suggestion});
}

/// @nodoc
class _$ImportErrorCopyWithImpl<$Res, $Val extends ImportError>
    implements $ImportErrorCopyWith<$Res> {
  _$ImportErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? lineNumber = null,
    Object? field = freezed,
    Object? value = freezed,
    Object? suggestion = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ImportErrorType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      lineNumber: null == lineNumber
          ? _value.lineNumber
          : lineNumber // ignore: cast_nullable_to_non_nullable
              as int,
      field: freezed == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String?,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestion: freezed == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImportErrorImplCopyWith<$Res>
    implements $ImportErrorCopyWith<$Res> {
  factory _$$ImportErrorImplCopyWith(
          _$ImportErrorImpl value, $Res Function(_$ImportErrorImpl) then) =
      __$$ImportErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ImportErrorType type,
      String message,
      int lineNumber,
      String? field,
      String? value,
      String? suggestion});
}

/// @nodoc
class __$$ImportErrorImplCopyWithImpl<$Res>
    extends _$ImportErrorCopyWithImpl<$Res, _$ImportErrorImpl>
    implements _$$ImportErrorImplCopyWith<$Res> {
  __$$ImportErrorImplCopyWithImpl(
      _$ImportErrorImpl _value, $Res Function(_$ImportErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? lineNumber = null,
    Object? field = freezed,
    Object? value = freezed,
    Object? suggestion = freezed,
  }) {
    return _then(_$ImportErrorImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ImportErrorType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      lineNumber: null == lineNumber
          ? _value.lineNumber
          : lineNumber // ignore: cast_nullable_to_non_nullable
              as int,
      field: freezed == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String?,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestion: freezed == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ImportErrorImpl extends _ImportError {
  const _$ImportErrorImpl(
      {required this.type,
      required this.message,
      required this.lineNumber,
      this.field,
      this.value,
      this.suggestion})
      : super._();

  @override
  final ImportErrorType type;
  @override
  final String message;
  @override
  final int lineNumber;
  @override
  final String? field;
  @override
  final String? value;
  @override
  final String? suggestion;

  @override
  String toString() {
    return 'ImportError(type: $type, message: $message, lineNumber: $lineNumber, field: $field, value: $value, suggestion: $suggestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportErrorImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.lineNumber, lineNumber) ||
                other.lineNumber == lineNumber) &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.suggestion, suggestion) ||
                other.suggestion == suggestion));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, type, message, lineNumber, field, value, suggestion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportErrorImplCopyWith<_$ImportErrorImpl> get copyWith =>
      __$$ImportErrorImplCopyWithImpl<_$ImportErrorImpl>(this, _$identity);
}

abstract class _ImportError extends ImportError {
  const factory _ImportError(
      {required final ImportErrorType type,
      required final String message,
      required final int lineNumber,
      final String? field,
      final String? value,
      final String? suggestion}) = _$ImportErrorImpl;
  const _ImportError._() : super._();

  @override
  ImportErrorType get type;
  @override
  String get message;
  @override
  int get lineNumber;
  @override
  String? get field;
  @override
  String? get value;
  @override
  String? get suggestion;
  @override
  @JsonKey(ignore: true)
  _$$ImportErrorImplCopyWith<_$ImportErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
