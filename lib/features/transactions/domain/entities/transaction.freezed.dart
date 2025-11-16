// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String? get accountId =>
      throw _privateConstructorUsedError; // Optional for transfers
  String? get toAccountId =>
      throw _privateConstructorUsedError; // Destination account for transfers
  double? get transferFee =>
      throw _privateConstructorUsedError; // Fee for transfers
  String? get description => throw _privateConstructorUsedError;
  String? get receiptUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get currencyCode =>
      throw _privateConstructorUsedError; // Currency code (USD, EUR, etc.)
  List<GoalContribution>? get goalAllocations =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      String title,
      double amount,
      TransactionType type,
      DateTime date,
      String categoryId,
      String? accountId,
      String? toAccountId,
      double? transferFee,
      String? description,
      String? receiptUrl,
      List<String> tags,
      String? currencyCode,
      List<GoalContribution>? goalAllocations});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? type = null,
    Object? date = null,
    Object? categoryId = null,
    Object? accountId = freezed,
    Object? toAccountId = freezed,
    Object? transferFee = freezed,
    Object? description = freezed,
    Object? receiptUrl = freezed,
    Object? tags = null,
    Object? currencyCode = freezed,
    Object? goalAllocations = freezed,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      toAccountId: freezed == toAccountId
          ? _value.toAccountId
          : toAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: freezed == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as double?,
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
      goalAllocations: freezed == goalAllocations
          ? _value.goalAllocations
          : goalAllocations // ignore: cast_nullable_to_non_nullable
              as List<GoalContribution>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double amount,
      TransactionType type,
      DateTime date,
      String categoryId,
      String? accountId,
      String? toAccountId,
      double? transferFee,
      String? description,
      String? receiptUrl,
      List<String> tags,
      String? currencyCode,
      List<GoalContribution>? goalAllocations});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? type = null,
    Object? date = null,
    Object? categoryId = null,
    Object? accountId = freezed,
    Object? toAccountId = freezed,
    Object? transferFee = freezed,
    Object? description = freezed,
    Object? receiptUrl = freezed,
    Object? tags = null,
    Object? currencyCode = freezed,
    Object? goalAllocations = freezed,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      toAccountId: freezed == toAccountId
          ? _value.toAccountId
          : toAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: freezed == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as double?,
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
      goalAllocations: freezed == goalAllocations
          ? _value._goalAllocations
          : goalAllocations // ignore: cast_nullable_to_non_nullable
              as List<GoalContribution>?,
    ));
  }
}

/// @nodoc

class _$TransactionImpl extends _Transaction {
  const _$TransactionImpl(
      {required this.id,
      required this.title,
      required this.amount,
      required this.type,
      required this.date,
      required this.categoryId,
      this.accountId,
      this.toAccountId,
      this.transferFee,
      this.description,
      this.receiptUrl,
      final List<String> tags = const [],
      this.currencyCode,
      final List<GoalContribution>? goalAllocations})
      : _tags = tags,
        _goalAllocations = goalAllocations,
        super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final double amount;
  @override
  final TransactionType type;
  @override
  final DateTime date;
  @override
  final String categoryId;
  @override
  final String? accountId;
// Optional for transfers
  @override
  final String? toAccountId;
// Destination account for transfers
  @override
  final double? transferFee;
// Fee for transfers
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
// Currency code (USD, EUR, etc.)
  final List<GoalContribution>? _goalAllocations;
// Currency code (USD, EUR, etc.)
  @override
  List<GoalContribution>? get goalAllocations {
    final value = _goalAllocations;
    if (value == null) return null;
    if (_goalAllocations is EqualUnmodifiableListView) return _goalAllocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, type: $type, date: $date, categoryId: $categoryId, accountId: $accountId, toAccountId: $toAccountId, transferFee: $transferFee, description: $description, receiptUrl: $receiptUrl, tags: $tags, currencyCode: $currencyCode, goalAllocations: $goalAllocations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.toAccountId, toAccountId) ||
                other.toAccountId == toAccountId) &&
            (identical(other.transferFee, transferFee) ||
                other.transferFee == transferFee) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.receiptUrl, receiptUrl) ||
                other.receiptUrl == receiptUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            const DeepCollectionEquality()
                .equals(other._goalAllocations, _goalAllocations));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      amount,
      type,
      date,
      categoryId,
      accountId,
      toAccountId,
      transferFee,
      description,
      receiptUrl,
      const DeepCollectionEquality().hash(_tags),
      currencyCode,
      const DeepCollectionEquality().hash(_goalAllocations));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);
}

abstract class _Transaction extends Transaction {
  const factory _Transaction(
      {required final String id,
      required final String title,
      required final double amount,
      required final TransactionType type,
      required final DateTime date,
      required final String categoryId,
      final String? accountId,
      final String? toAccountId,
      final double? transferFee,
      final String? description,
      final String? receiptUrl,
      final List<String> tags,
      final String? currencyCode,
      final List<GoalContribution>? goalAllocations}) = _$TransactionImpl;
  const _Transaction._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  double get amount;
  @override
  TransactionType get type;
  @override
  DateTime get date;
  @override
  String get categoryId;
  @override
  String? get accountId;
  @override // Optional for transfers
  String? get toAccountId;
  @override // Destination account for transfers
  double? get transferFee;
  @override // Fee for transfers
  String? get description;
  @override
  String? get receiptUrl;
  @override
  List<String> get tags;
  @override
  String? get currencyCode;
  @override // Currency code (USD, EUR, etc.)
  List<GoalContribution>? get goalAllocations;
  @override
  @JsonKey(ignore: true)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TransactionCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  int get color => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TransactionCategoryCopyWith<TransactionCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCategoryCopyWith<$Res> {
  factory $TransactionCategoryCopyWith(
          TransactionCategory value, $Res Function(TransactionCategory) then) =
      _$TransactionCategoryCopyWithImpl<$Res, TransactionCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      int color,
      TransactionType type,
      int order,
      bool isArchived,
      int usageCount});
}

/// @nodoc
class _$TransactionCategoryCopyWithImpl<$Res, $Val extends TransactionCategory>
    implements $TransactionCategoryCopyWith<$Res> {
  _$TransactionCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? type = null,
    Object? order = null,
    Object? isArchived = null,
    Object? usageCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionCategoryImplCopyWith<$Res>
    implements $TransactionCategoryCopyWith<$Res> {
  factory _$$TransactionCategoryImplCopyWith(_$TransactionCategoryImpl value,
          $Res Function(_$TransactionCategoryImpl) then) =
      __$$TransactionCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      int color,
      TransactionType type,
      int order,
      bool isArchived,
      int usageCount});
}

/// @nodoc
class __$$TransactionCategoryImplCopyWithImpl<$Res>
    extends _$TransactionCategoryCopyWithImpl<$Res, _$TransactionCategoryImpl>
    implements _$$TransactionCategoryImplCopyWith<$Res> {
  __$$TransactionCategoryImplCopyWithImpl(_$TransactionCategoryImpl _value,
      $Res Function(_$TransactionCategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? type = null,
    Object? order = null,
    Object? isArchived = null,
    Object? usageCount = null,
  }) {
    return _then(_$TransactionCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TransactionCategoryImpl extends _TransactionCategory {
  const _$TransactionCategoryImpl(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color,
      required this.type,
      this.order = 0,
      this.isArchived = false,
      this.usageCount = 0})
      : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  final int color;
  @override
  final TransactionType type;
  @override
  @JsonKey()
  final int order;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final int usageCount;

  @override
  String toString() {
    return 'TransactionCategory(id: $id, name: $name, icon: $icon, color: $color, type: $type, order: $order, isArchived: $isArchived, usageCount: $usageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, icon, color, type, order, isArchived, usageCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionCategoryImplCopyWith<_$TransactionCategoryImpl> get copyWith =>
      __$$TransactionCategoryImplCopyWithImpl<_$TransactionCategoryImpl>(
          this, _$identity);
}

abstract class _TransactionCategory extends TransactionCategory {
  const factory _TransactionCategory(
      {required final String id,
      required final String name,
      required final String icon,
      required final int color,
      required final TransactionType type,
      final int order,
      final bool isArchived,
      final int usageCount}) = _$TransactionCategoryImpl;
  const _TransactionCategory._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  int get color;
  @override
  TransactionType get type;
  @override
  int get order;
  @override
  bool get isArchived;
  @override
  int get usageCount;
  @override
  @JsonKey(ignore: true)
  _$$TransactionCategoryImplCopyWith<_$TransactionCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
