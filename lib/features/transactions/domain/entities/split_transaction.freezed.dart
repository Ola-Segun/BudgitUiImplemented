// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'split_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TransactionSplit {
  String get categoryId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TransactionSplitCopyWith<TransactionSplit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionSplitCopyWith<$Res> {
  factory $TransactionSplitCopyWith(
          TransactionSplit value, $Res Function(TransactionSplit) then) =
      _$TransactionSplitCopyWithImpl<$Res, TransactionSplit>;
  @useResult
  $Res call(
      {String categoryId,
      double amount,
      double percentage,
      String? description});
}

/// @nodoc
class _$TransactionSplitCopyWithImpl<$Res, $Val extends TransactionSplit>
    implements $TransactionSplitCopyWith<$Res> {
  _$TransactionSplitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? amount = null,
    Object? percentage = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionSplitImplCopyWith<$Res>
    implements $TransactionSplitCopyWith<$Res> {
  factory _$$TransactionSplitImplCopyWith(_$TransactionSplitImpl value,
          $Res Function(_$TransactionSplitImpl) then) =
      __$$TransactionSplitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String categoryId,
      double amount,
      double percentage,
      String? description});
}

/// @nodoc
class __$$TransactionSplitImplCopyWithImpl<$Res>
    extends _$TransactionSplitCopyWithImpl<$Res, _$TransactionSplitImpl>
    implements _$$TransactionSplitImplCopyWith<$Res> {
  __$$TransactionSplitImplCopyWithImpl(_$TransactionSplitImpl _value,
      $Res Function(_$TransactionSplitImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? amount = null,
    Object? percentage = null,
    Object? description = freezed,
  }) {
    return _then(_$TransactionSplitImpl(
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TransactionSplitImpl extends _TransactionSplit {
  const _$TransactionSplitImpl(
      {required this.categoryId,
      required this.amount,
      required this.percentage,
      this.description})
      : super._();

  @override
  final String categoryId;
  @override
  final double amount;
  @override
  final double percentage;
  @override
  final String? description;

  @override
  String toString() {
    return 'TransactionSplit(categoryId: $categoryId, amount: $amount, percentage: $percentage, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionSplitImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, categoryId, amount, percentage, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionSplitImplCopyWith<_$TransactionSplitImpl> get copyWith =>
      __$$TransactionSplitImplCopyWithImpl<_$TransactionSplitImpl>(
          this, _$identity);
}

abstract class _TransactionSplit extends TransactionSplit {
  const factory _TransactionSplit(
      {required final String categoryId,
      required final double amount,
      required final double percentage,
      final String? description}) = _$TransactionSplitImpl;
  const _TransactionSplit._() : super._();

  @override
  String get categoryId;
  @override
  double get amount;
  @override
  double get percentage;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$TransactionSplitImplCopyWith<_$TransactionSplitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SplitTransaction {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  List<TransactionSplit> get splits => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get receiptUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get currencyCode => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SplitTransactionCopyWith<SplitTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplitTransactionCopyWith<$Res> {
  factory $SplitTransactionCopyWith(
          SplitTransaction value, $Res Function(SplitTransaction) then) =
      _$SplitTransactionCopyWithImpl<$Res, SplitTransaction>;
  @useResult
  $Res call(
      {String id,
      String title,
      double totalAmount,
      TransactionType type,
      DateTime date,
      String accountId,
      List<TransactionSplit> splits,
      String? description,
      String? receiptUrl,
      List<String> tags,
      String? currencyCode});
}

/// @nodoc
class _$SplitTransactionCopyWithImpl<$Res, $Val extends SplitTransaction>
    implements $SplitTransactionCopyWith<$Res> {
  _$SplitTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? totalAmount = null,
    Object? type = null,
    Object? date = null,
    Object? accountId = null,
    Object? splits = null,
    Object? description = freezed,
    Object? receiptUrl = freezed,
    Object? tags = null,
    Object? currencyCode = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      splits: null == splits
          ? _value.splits
          : splits // ignore: cast_nullable_to_non_nullable
              as List<TransactionSplit>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SplitTransactionImplCopyWith<$Res>
    implements $SplitTransactionCopyWith<$Res> {
  factory _$$SplitTransactionImplCopyWith(_$SplitTransactionImpl value,
          $Res Function(_$SplitTransactionImpl) then) =
      __$$SplitTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double totalAmount,
      TransactionType type,
      DateTime date,
      String accountId,
      List<TransactionSplit> splits,
      String? description,
      String? receiptUrl,
      List<String> tags,
      String? currencyCode});
}

/// @nodoc
class __$$SplitTransactionImplCopyWithImpl<$Res>
    extends _$SplitTransactionCopyWithImpl<$Res, _$SplitTransactionImpl>
    implements _$$SplitTransactionImplCopyWith<$Res> {
  __$$SplitTransactionImplCopyWithImpl(_$SplitTransactionImpl _value,
      $Res Function(_$SplitTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? totalAmount = null,
    Object? type = null,
    Object? date = null,
    Object? accountId = null,
    Object? splits = null,
    Object? description = freezed,
    Object? receiptUrl = freezed,
    Object? tags = null,
    Object? currencyCode = freezed,
  }) {
    return _then(_$SplitTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      splits: null == splits
          ? _value._splits
          : splits // ignore: cast_nullable_to_non_nullable
              as List<TransactionSplit>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SplitTransactionImpl extends _SplitTransaction {
  const _$SplitTransactionImpl(
      {required this.id,
      required this.title,
      required this.totalAmount,
      required this.type,
      required this.date,
      required this.accountId,
      required final List<TransactionSplit> splits,
      this.description,
      this.receiptUrl,
      final List<String> tags = const [],
      this.currencyCode})
      : _splits = splits,
        _tags = tags,
        super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final double totalAmount;
  @override
  final TransactionType type;
  @override
  final DateTime date;
  @override
  final String accountId;
  final List<TransactionSplit> _splits;
  @override
  List<TransactionSplit> get splits {
    if (_splits is EqualUnmodifiableListView) return _splits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splits);
  }

  @override
  final String? description;
  @override
  final String? receiptUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? currencyCode;

  @override
  String toString() {
    return 'SplitTransaction(id: $id, title: $title, totalAmount: $totalAmount, type: $type, date: $date, accountId: $accountId, splits: $splits, description: $description, receiptUrl: $receiptUrl, tags: $tags, currencyCode: $currencyCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplitTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            const DeepCollectionEquality().equals(other._splits, _splits) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.receiptUrl, receiptUrl) ||
                other.receiptUrl == receiptUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      totalAmount,
      type,
      date,
      accountId,
      const DeepCollectionEquality().hash(_splits),
      description,
      receiptUrl,
      const DeepCollectionEquality().hash(_tags),
      currencyCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SplitTransactionImplCopyWith<_$SplitTransactionImpl> get copyWith =>
      __$$SplitTransactionImplCopyWithImpl<_$SplitTransactionImpl>(
          this, _$identity);
}

abstract class _SplitTransaction extends SplitTransaction {
  const factory _SplitTransaction(
      {required final String id,
      required final String title,
      required final double totalAmount,
      required final TransactionType type,
      required final DateTime date,
      required final String accountId,
      required final List<TransactionSplit> splits,
      final String? description,
      final String? receiptUrl,
      final List<String> tags,
      final String? currencyCode}) = _$SplitTransactionImpl;
  const _SplitTransaction._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  double get totalAmount;
  @override
  TransactionType get type;
  @override
  DateTime get date;
  @override
  String get accountId;
  @override
  List<TransactionSplit> get splits;
  @override
  String? get description;
  @override
  String? get receiptUrl;
  @override
  List<String> get tags;
  @override
  String? get currencyCode;
  @override
  @JsonKey(ignore: true)
  _$$SplitTransactionImplCopyWith<_$SplitTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
