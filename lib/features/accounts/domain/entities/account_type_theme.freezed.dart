// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_type_theme.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AccountTypeTheme {
  String get accountType =>
      throw _privateConstructorUsedError; // AccountType enum name
  String get displayName => throw _privateConstructorUsedError;
  String get iconName =>
      throw _privateConstructorUsedError; // Material icon name
  int get colorValue => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AccountTypeThemeCopyWith<AccountTypeTheme> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountTypeThemeCopyWith<$Res> {
  factory $AccountTypeThemeCopyWith(
          AccountTypeTheme value, $Res Function(AccountTypeTheme) then) =
      _$AccountTypeThemeCopyWithImpl<$Res, AccountTypeTheme>;
  @useResult
  $Res call(
      {String accountType,
      String displayName,
      String iconName,
      int colorValue});
}

/// @nodoc
class _$AccountTypeThemeCopyWithImpl<$Res, $Val extends AccountTypeTheme>
    implements $AccountTypeThemeCopyWith<$Res> {
  _$AccountTypeThemeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountType = null,
    Object? displayName = null,
    Object? iconName = null,
    Object? colorValue = null,
  }) {
    return _then(_value.copyWith(
      accountType: null == accountType
          ? _value.accountType
          : accountType // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: null == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountTypeThemeImplCopyWith<$Res>
    implements $AccountTypeThemeCopyWith<$Res> {
  factory _$$AccountTypeThemeImplCopyWith(_$AccountTypeThemeImpl value,
          $Res Function(_$AccountTypeThemeImpl) then) =
      __$$AccountTypeThemeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accountType,
      String displayName,
      String iconName,
      int colorValue});
}

/// @nodoc
class __$$AccountTypeThemeImplCopyWithImpl<$Res>
    extends _$AccountTypeThemeCopyWithImpl<$Res, _$AccountTypeThemeImpl>
    implements _$$AccountTypeThemeImplCopyWith<$Res> {
  __$$AccountTypeThemeImplCopyWithImpl(_$AccountTypeThemeImpl _value,
      $Res Function(_$AccountTypeThemeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountType = null,
    Object? displayName = null,
    Object? iconName = null,
    Object? colorValue = null,
  }) {
    return _then(_$AccountTypeThemeImpl(
      accountType: null == accountType
          ? _value.accountType
          : accountType // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      iconName: null == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: null == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AccountTypeThemeImpl extends _AccountTypeTheme {
  const _$AccountTypeThemeImpl(
      {required this.accountType,
      required this.displayName,
      required this.iconName,
      required this.colorValue})
      : super._();

  @override
  final String accountType;
// AccountType enum name
  @override
  final String displayName;
  @override
  final String iconName;
// Material icon name
  @override
  final int colorValue;

  @override
  String toString() {
    return 'AccountTypeTheme(accountType: $accountType, displayName: $displayName, iconName: $iconName, colorValue: $colorValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountTypeThemeImpl &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, accountType, displayName, iconName, colorValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountTypeThemeImplCopyWith<_$AccountTypeThemeImpl> get copyWith =>
      __$$AccountTypeThemeImplCopyWithImpl<_$AccountTypeThemeImpl>(
          this, _$identity);
}

abstract class _AccountTypeTheme extends AccountTypeTheme {
  const factory _AccountTypeTheme(
      {required final String accountType,
      required final String displayName,
      required final String iconName,
      required final int colorValue}) = _$AccountTypeThemeImpl;
  const _AccountTypeTheme._() : super._();

  @override
  String get accountType;
  @override // AccountType enum name
  String get displayName;
  @override
  String get iconName;
  @override // Material icon name
  int get colorValue;
  @override
  @JsonKey(ignore: true)
  _$$AccountTypeThemeImplCopyWith<_$AccountTypeThemeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
