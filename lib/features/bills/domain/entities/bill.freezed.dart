// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Bill {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  BillFrequency get frequency => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get payee =>
      throw _privateConstructorUsedError; // ═══ ACCOUNT RELATIONSHIP ═══
  String? get defaultAccountId =>
      throw _privateConstructorUsedError; // Primary account for payments
  List<String>? get allowedAccountIds =>
      throw _privateConstructorUsedError; // Alternative accounts for payments
  String? get accountId =>
      throw _privateConstructorUsedError; // Legacy field for backward compatibility
  bool get isAutoPay => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;
  DateTime? get lastPaidDate => throw _privateConstructorUsedError;
  DateTime? get nextDueDate => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  BillDifficulty get cancellationDifficulty =>
      throw _privateConstructorUsedError;
  DateTime? get lastPriceIncrease => throw _privateConstructorUsedError;
  List<BillPayment> get paymentHistory =>
      throw _privateConstructorUsedError; // ═══ VARIABLE AMOUNT SUPPORT ═══
  bool get isVariableAmount => throw _privateConstructorUsedError;
  double? get minAmount => throw _privateConstructorUsedError;
  double? get maxAmount =>
      throw _privateConstructorUsedError; // ═══ CURRENCY SUPPORT ═══
  String? get currencyCode =>
      throw _privateConstructorUsedError; // ═══ RECURRING FLEXIBILITY ═══
  List<RecurringPaymentRule> get recurringPaymentRules =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BillCopyWith<Bill> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillCopyWith<$Res> {
  factory $BillCopyWith(Bill value, $Res Function(Bill) then) =
      _$BillCopyWithImpl<$Res, Bill>;
  @useResult
  $Res call(
      {String id,
      String name,
      double amount,
      DateTime dueDate,
      BillFrequency frequency,
      String categoryId,
      String? description,
      String? payee,
      String? defaultAccountId,
      List<String>? allowedAccountIds,
      String? accountId,
      bool isAutoPay,
      bool isPaid,
      DateTime? lastPaidDate,
      DateTime? nextDueDate,
      String? website,
      String? notes,
      BillDifficulty cancellationDifficulty,
      DateTime? lastPriceIncrease,
      List<BillPayment> paymentHistory,
      bool isVariableAmount,
      double? minAmount,
      double? maxAmount,
      String? currencyCode,
      List<RecurringPaymentRule> recurringPaymentRules});
}

/// @nodoc
class _$BillCopyWithImpl<$Res, $Val extends Bill>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? dueDate = null,
    Object? frequency = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? payee = freezed,
    Object? defaultAccountId = freezed,
    Object? allowedAccountIds = freezed,
    Object? accountId = freezed,
    Object? isAutoPay = null,
    Object? isPaid = null,
    Object? lastPaidDate = freezed,
    Object? nextDueDate = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? cancellationDifficulty = null,
    Object? lastPriceIncrease = freezed,
    Object? paymentHistory = null,
    Object? isVariableAmount = null,
    Object? minAmount = freezed,
    Object? maxAmount = freezed,
    Object? currencyCode = freezed,
    Object? recurringPaymentRules = null,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as BillFrequency,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      payee: freezed == payee
          ? _value.payee
          : payee // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultAccountId: freezed == defaultAccountId
          ? _value.defaultAccountId
          : defaultAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      allowedAccountIds: freezed == allowedAccountIds
          ? _value.allowedAccountIds
          : allowedAccountIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoPay: null == isAutoPay
          ? _value.isAutoPay
          : isAutoPay // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPaidDate: freezed == lastPaidDate
          ? _value.lastPaidDate
          : lastPaidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationDifficulty: null == cancellationDifficulty
          ? _value.cancellationDifficulty
          : cancellationDifficulty // ignore: cast_nullable_to_non_nullable
              as BillDifficulty,
      lastPriceIncrease: freezed == lastPriceIncrease
          ? _value.lastPriceIncrease
          : lastPriceIncrease // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentHistory: null == paymentHistory
          ? _value.paymentHistory
          : paymentHistory // ignore: cast_nullable_to_non_nullable
              as List<BillPayment>,
      isVariableAmount: null == isVariableAmount
          ? _value.isVariableAmount
          : isVariableAmount // ignore: cast_nullable_to_non_nullable
              as bool,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxAmount: freezed == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      recurringPaymentRules: null == recurringPaymentRules
          ? _value.recurringPaymentRules
          : recurringPaymentRules // ignore: cast_nullable_to_non_nullable
              as List<RecurringPaymentRule>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BillImplCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$$BillImplCopyWith(
          _$BillImpl value, $Res Function(_$BillImpl) then) =
      __$$BillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double amount,
      DateTime dueDate,
      BillFrequency frequency,
      String categoryId,
      String? description,
      String? payee,
      String? defaultAccountId,
      List<String>? allowedAccountIds,
      String? accountId,
      bool isAutoPay,
      bool isPaid,
      DateTime? lastPaidDate,
      DateTime? nextDueDate,
      String? website,
      String? notes,
      BillDifficulty cancellationDifficulty,
      DateTime? lastPriceIncrease,
      List<BillPayment> paymentHistory,
      bool isVariableAmount,
      double? minAmount,
      double? maxAmount,
      String? currencyCode,
      List<RecurringPaymentRule> recurringPaymentRules});
}

/// @nodoc
class __$$BillImplCopyWithImpl<$Res>
    extends _$BillCopyWithImpl<$Res, _$BillImpl>
    implements _$$BillImplCopyWith<$Res> {
  __$$BillImplCopyWithImpl(_$BillImpl _value, $Res Function(_$BillImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? dueDate = null,
    Object? frequency = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? payee = freezed,
    Object? defaultAccountId = freezed,
    Object? allowedAccountIds = freezed,
    Object? accountId = freezed,
    Object? isAutoPay = null,
    Object? isPaid = null,
    Object? lastPaidDate = freezed,
    Object? nextDueDate = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? cancellationDifficulty = null,
    Object? lastPriceIncrease = freezed,
    Object? paymentHistory = null,
    Object? isVariableAmount = null,
    Object? minAmount = freezed,
    Object? maxAmount = freezed,
    Object? currencyCode = freezed,
    Object? recurringPaymentRules = null,
  }) {
    return _then(_$BillImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as BillFrequency,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      payee: freezed == payee
          ? _value.payee
          : payee // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultAccountId: freezed == defaultAccountId
          ? _value.defaultAccountId
          : defaultAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      allowedAccountIds: freezed == allowedAccountIds
          ? _value._allowedAccountIds
          : allowedAccountIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoPay: null == isAutoPay
          ? _value.isAutoPay
          : isAutoPay // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPaidDate: freezed == lastPaidDate
          ? _value.lastPaidDate
          : lastPaidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationDifficulty: null == cancellationDifficulty
          ? _value.cancellationDifficulty
          : cancellationDifficulty // ignore: cast_nullable_to_non_nullable
              as BillDifficulty,
      lastPriceIncrease: freezed == lastPriceIncrease
          ? _value.lastPriceIncrease
          : lastPriceIncrease // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentHistory: null == paymentHistory
          ? _value._paymentHistory
          : paymentHistory // ignore: cast_nullable_to_non_nullable
              as List<BillPayment>,
      isVariableAmount: null == isVariableAmount
          ? _value.isVariableAmount
          : isVariableAmount // ignore: cast_nullable_to_non_nullable
              as bool,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxAmount: freezed == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      recurringPaymentRules: null == recurringPaymentRules
          ? _value._recurringPaymentRules
          : recurringPaymentRules // ignore: cast_nullable_to_non_nullable
              as List<RecurringPaymentRule>,
    ));
  }
}

/// @nodoc

class _$BillImpl extends _Bill {
  const _$BillImpl(
      {required this.id,
      required this.name,
      required this.amount,
      required this.dueDate,
      required this.frequency,
      required this.categoryId,
      this.description,
      this.payee,
      this.defaultAccountId,
      final List<String>? allowedAccountIds,
      this.accountId,
      this.isAutoPay = false,
      this.isPaid = false,
      this.lastPaidDate,
      this.nextDueDate,
      this.website,
      this.notes,
      this.cancellationDifficulty = BillDifficulty.easy,
      this.lastPriceIncrease,
      final List<BillPayment> paymentHistory = const [],
      this.isVariableAmount = false,
      this.minAmount,
      this.maxAmount,
      this.currencyCode,
      final List<RecurringPaymentRule> recurringPaymentRules = const []})
      : _allowedAccountIds = allowedAccountIds,
        _paymentHistory = paymentHistory,
        _recurringPaymentRules = recurringPaymentRules,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final double amount;
  @override
  final DateTime dueDate;
  @override
  final BillFrequency frequency;
  @override
  final String categoryId;
  @override
  final String? description;
  @override
  final String? payee;
// ═══ ACCOUNT RELATIONSHIP ═══
  @override
  final String? defaultAccountId;
// Primary account for payments
  final List<String>? _allowedAccountIds;
// Primary account for payments
  @override
  List<String>? get allowedAccountIds {
    final value = _allowedAccountIds;
    if (value == null) return null;
    if (_allowedAccountIds is EqualUnmodifiableListView)
      return _allowedAccountIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Alternative accounts for payments
  @override
  final String? accountId;
// Legacy field for backward compatibility
  @override
  @JsonKey()
  final bool isAutoPay;
  @override
  @JsonKey()
  final bool isPaid;
  @override
  final DateTime? lastPaidDate;
  @override
  final DateTime? nextDueDate;
  @override
  final String? website;
  @override
  final String? notes;
  @override
  @JsonKey()
  final BillDifficulty cancellationDifficulty;
  @override
  final DateTime? lastPriceIncrease;
  final List<BillPayment> _paymentHistory;
  @override
  @JsonKey()
  List<BillPayment> get paymentHistory {
    if (_paymentHistory is EqualUnmodifiableListView) return _paymentHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paymentHistory);
  }

// ═══ VARIABLE AMOUNT SUPPORT ═══
  @override
  @JsonKey()
  final bool isVariableAmount;
  @override
  final double? minAmount;
  @override
  final double? maxAmount;
// ═══ CURRENCY SUPPORT ═══
  @override
  final String? currencyCode;
// ═══ RECURRING FLEXIBILITY ═══
  final List<RecurringPaymentRule> _recurringPaymentRules;
// ═══ RECURRING FLEXIBILITY ═══
  @override
  @JsonKey()
  List<RecurringPaymentRule> get recurringPaymentRules {
    if (_recurringPaymentRules is EqualUnmodifiableListView)
      return _recurringPaymentRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recurringPaymentRules);
  }

  @override
  String toString() {
    return 'Bill(id: $id, name: $name, amount: $amount, dueDate: $dueDate, frequency: $frequency, categoryId: $categoryId, description: $description, payee: $payee, defaultAccountId: $defaultAccountId, allowedAccountIds: $allowedAccountIds, accountId: $accountId, isAutoPay: $isAutoPay, isPaid: $isPaid, lastPaidDate: $lastPaidDate, nextDueDate: $nextDueDate, website: $website, notes: $notes, cancellationDifficulty: $cancellationDifficulty, lastPriceIncrease: $lastPriceIncrease, paymentHistory: $paymentHistory, isVariableAmount: $isVariableAmount, minAmount: $minAmount, maxAmount: $maxAmount, currencyCode: $currencyCode, recurringPaymentRules: $recurringPaymentRules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.payee, payee) || other.payee == payee) &&
            (identical(other.defaultAccountId, defaultAccountId) ||
                other.defaultAccountId == defaultAccountId) &&
            const DeepCollectionEquality()
                .equals(other._allowedAccountIds, _allowedAccountIds) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.isAutoPay, isAutoPay) ||
                other.isAutoPay == isAutoPay) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.lastPaidDate, lastPaidDate) ||
                other.lastPaidDate == lastPaidDate) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.cancellationDifficulty, cancellationDifficulty) ||
                other.cancellationDifficulty == cancellationDifficulty) &&
            (identical(other.lastPriceIncrease, lastPriceIncrease) ||
                other.lastPriceIncrease == lastPriceIncrease) &&
            const DeepCollectionEquality()
                .equals(other._paymentHistory, _paymentHistory) &&
            (identical(other.isVariableAmount, isVariableAmount) ||
                other.isVariableAmount == isVariableAmount) &&
            (identical(other.minAmount, minAmount) ||
                other.minAmount == minAmount) &&
            (identical(other.maxAmount, maxAmount) ||
                other.maxAmount == maxAmount) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            const DeepCollectionEquality()
                .equals(other._recurringPaymentRules, _recurringPaymentRules));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        amount,
        dueDate,
        frequency,
        categoryId,
        description,
        payee,
        defaultAccountId,
        const DeepCollectionEquality().hash(_allowedAccountIds),
        accountId,
        isAutoPay,
        isPaid,
        lastPaidDate,
        nextDueDate,
        website,
        notes,
        cancellationDifficulty,
        lastPriceIncrease,
        const DeepCollectionEquality().hash(_paymentHistory),
        isVariableAmount,
        minAmount,
        maxAmount,
        currencyCode,
        const DeepCollectionEquality().hash(_recurringPaymentRules)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      __$$BillImplCopyWithImpl<_$BillImpl>(this, _$identity);
}

abstract class _Bill extends Bill {
  const factory _Bill(
      {required final String id,
      required final String name,
      required final double amount,
      required final DateTime dueDate,
      required final BillFrequency frequency,
      required final String categoryId,
      final String? description,
      final String? payee,
      final String? defaultAccountId,
      final List<String>? allowedAccountIds,
      final String? accountId,
      final bool isAutoPay,
      final bool isPaid,
      final DateTime? lastPaidDate,
      final DateTime? nextDueDate,
      final String? website,
      final String? notes,
      final BillDifficulty cancellationDifficulty,
      final DateTime? lastPriceIncrease,
      final List<BillPayment> paymentHistory,
      final bool isVariableAmount,
      final double? minAmount,
      final double? maxAmount,
      final String? currencyCode,
      final List<RecurringPaymentRule> recurringPaymentRules}) = _$BillImpl;
  const _Bill._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  double get amount;
  @override
  DateTime get dueDate;
  @override
  BillFrequency get frequency;
  @override
  String get categoryId;
  @override
  String? get description;
  @override
  String? get payee;
  @override // ═══ ACCOUNT RELATIONSHIP ═══
  String? get defaultAccountId;
  @override // Primary account for payments
  List<String>? get allowedAccountIds;
  @override // Alternative accounts for payments
  String? get accountId;
  @override // Legacy field for backward compatibility
  bool get isAutoPay;
  @override
  bool get isPaid;
  @override
  DateTime? get lastPaidDate;
  @override
  DateTime? get nextDueDate;
  @override
  String? get website;
  @override
  String? get notes;
  @override
  BillDifficulty get cancellationDifficulty;
  @override
  DateTime? get lastPriceIncrease;
  @override
  List<BillPayment> get paymentHistory;
  @override // ═══ VARIABLE AMOUNT SUPPORT ═══
  bool get isVariableAmount;
  @override
  double? get minAmount;
  @override
  double? get maxAmount;
  @override // ═══ CURRENCY SUPPORT ═══
  String? get currencyCode;
  @override // ═══ RECURRING FLEXIBILITY ═══
  List<RecurringPaymentRule> get recurringPaymentRules;
  @override
  @JsonKey(ignore: true)
  _$$BillImplCopyWith<_$BillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BillPayment {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get paymentDate => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  PaymentMethod get method => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BillPaymentCopyWith<BillPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillPaymentCopyWith<$Res> {
  factory $BillPaymentCopyWith(
          BillPayment value, $Res Function(BillPayment) then) =
      _$BillPaymentCopyWithImpl<$Res, BillPayment>;
  @useResult
  $Res call(
      {String id,
      double amount,
      DateTime paymentDate,
      String? transactionId,
      String? notes,
      PaymentMethod method});
}

/// @nodoc
class _$BillPaymentCopyWithImpl<$Res, $Val extends BillPayment>
    implements $BillPaymentCopyWith<$Res> {
  _$BillPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? transactionId = freezed,
    Object? notes = freezed,
    Object? method = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BillPaymentImplCopyWith<$Res>
    implements $BillPaymentCopyWith<$Res> {
  factory _$$BillPaymentImplCopyWith(
          _$BillPaymentImpl value, $Res Function(_$BillPaymentImpl) then) =
      __$$BillPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      DateTime paymentDate,
      String? transactionId,
      String? notes,
      PaymentMethod method});
}

/// @nodoc
class __$$BillPaymentImplCopyWithImpl<$Res>
    extends _$BillPaymentCopyWithImpl<$Res, _$BillPaymentImpl>
    implements _$$BillPaymentImplCopyWith<$Res> {
  __$$BillPaymentImplCopyWithImpl(
      _$BillPaymentImpl _value, $Res Function(_$BillPaymentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? transactionId = freezed,
    Object? notes = freezed,
    Object? method = null,
  }) {
    return _then(_$BillPaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
    ));
  }
}

/// @nodoc

class _$BillPaymentImpl extends _BillPayment {
  const _$BillPaymentImpl(
      {required this.id,
      required this.amount,
      required this.paymentDate,
      this.transactionId,
      this.notes,
      this.method = PaymentMethod.other})
      : super._();

  @override
  final String id;
  @override
  final double amount;
  @override
  final DateTime paymentDate;
  @override
  final String? transactionId;
  @override
  final String? notes;
  @override
  @JsonKey()
  final PaymentMethod method;

  @override
  String toString() {
    return 'BillPayment(id: $id, amount: $amount, paymentDate: $paymentDate, transactionId: $transactionId, notes: $notes, method: $method)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.method, method) || other.method == method));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, amount, paymentDate, transactionId, notes, method);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BillPaymentImplCopyWith<_$BillPaymentImpl> get copyWith =>
      __$$BillPaymentImplCopyWithImpl<_$BillPaymentImpl>(this, _$identity);
}

abstract class _BillPayment extends BillPayment {
  const factory _BillPayment(
      {required final String id,
      required final double amount,
      required final DateTime paymentDate,
      final String? transactionId,
      final String? notes,
      final PaymentMethod method}) = _$BillPaymentImpl;
  const _BillPayment._() : super._();

  @override
  String get id;
  @override
  double get amount;
  @override
  DateTime get paymentDate;
  @override
  String? get transactionId;
  @override
  String? get notes;
  @override
  PaymentMethod get method;
  @override
  @JsonKey(ignore: true)
  _$$BillPaymentImplCopyWith<_$BillPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecurringPaymentRule {
  String get id => throw _privateConstructorUsedError;
  int get instanceNumber =>
      throw _privateConstructorUsedError; // Which occurrence (1st, 2nd, etc.)
  String? get accountId =>
      throw _privateConstructorUsedError; // Specific account for this instance
  double? get amount =>
      throw _privateConstructorUsedError; // Specific amount for this instance (overrides bill amount)
  String? get notes => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RecurringPaymentRuleCopyWith<RecurringPaymentRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringPaymentRuleCopyWith<$Res> {
  factory $RecurringPaymentRuleCopyWith(RecurringPaymentRule value,
          $Res Function(RecurringPaymentRule) then) =
      _$RecurringPaymentRuleCopyWithImpl<$Res, RecurringPaymentRule>;
  @useResult
  $Res call(
      {String id,
      int instanceNumber,
      String? accountId,
      double? amount,
      String? notes,
      bool isEnabled});
}

/// @nodoc
class _$RecurringPaymentRuleCopyWithImpl<$Res,
        $Val extends RecurringPaymentRule>
    implements $RecurringPaymentRuleCopyWith<$Res> {
  _$RecurringPaymentRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? instanceNumber = null,
    Object? accountId = freezed,
    Object? amount = freezed,
    Object? notes = freezed,
    Object? isEnabled = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      instanceNumber: null == instanceNumber
          ? _value.instanceNumber
          : instanceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecurringPaymentRuleImplCopyWith<$Res>
    implements $RecurringPaymentRuleCopyWith<$Res> {
  factory _$$RecurringPaymentRuleImplCopyWith(_$RecurringPaymentRuleImpl value,
          $Res Function(_$RecurringPaymentRuleImpl) then) =
      __$$RecurringPaymentRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int instanceNumber,
      String? accountId,
      double? amount,
      String? notes,
      bool isEnabled});
}

/// @nodoc
class __$$RecurringPaymentRuleImplCopyWithImpl<$Res>
    extends _$RecurringPaymentRuleCopyWithImpl<$Res, _$RecurringPaymentRuleImpl>
    implements _$$RecurringPaymentRuleImplCopyWith<$Res> {
  __$$RecurringPaymentRuleImplCopyWithImpl(_$RecurringPaymentRuleImpl _value,
      $Res Function(_$RecurringPaymentRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? instanceNumber = null,
    Object? accountId = freezed,
    Object? amount = freezed,
    Object? notes = freezed,
    Object? isEnabled = null,
  }) {
    return _then(_$RecurringPaymentRuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      instanceNumber: null == instanceNumber
          ? _value.instanceNumber
          : instanceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$RecurringPaymentRuleImpl extends _RecurringPaymentRule {
  const _$RecurringPaymentRuleImpl(
      {required this.id,
      required this.instanceNumber,
      this.accountId,
      this.amount,
      this.notes,
      this.isEnabled = true})
      : super._();

  @override
  final String id;
  @override
  final int instanceNumber;
// Which occurrence (1st, 2nd, etc.)
  @override
  final String? accountId;
// Specific account for this instance
  @override
  final double? amount;
// Specific amount for this instance (overrides bill amount)
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isEnabled;

  @override
  String toString() {
    return 'RecurringPaymentRule(id: $id, instanceNumber: $instanceNumber, accountId: $accountId, amount: $amount, notes: $notes, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringPaymentRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.instanceNumber, instanceNumber) ||
                other.instanceNumber == instanceNumber) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, instanceNumber, accountId, amount, notes, isEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringPaymentRuleImplCopyWith<_$RecurringPaymentRuleImpl>
      get copyWith =>
          __$$RecurringPaymentRuleImplCopyWithImpl<_$RecurringPaymentRuleImpl>(
              this, _$identity);
}

abstract class _RecurringPaymentRule extends RecurringPaymentRule {
  const factory _RecurringPaymentRule(
      {required final String id,
      required final int instanceNumber,
      final String? accountId,
      final double? amount,
      final String? notes,
      final bool isEnabled}) = _$RecurringPaymentRuleImpl;
  const _RecurringPaymentRule._() : super._();

  @override
  String get id;
  @override
  int get instanceNumber;
  @override // Which occurrence (1st, 2nd, etc.)
  String? get accountId;
  @override // Specific account for this instance
  double? get amount;
  @override // Specific amount for this instance (overrides bill amount)
  String? get notes;
  @override
  bool get isEnabled;
  @override
  @JsonKey(ignore: true)
  _$$RecurringPaymentRuleImplCopyWith<_$RecurringPaymentRuleImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BillStatus {
  Bill get bill => throw _privateConstructorUsedError;
  int get daysUntilDue => throw _privateConstructorUsedError;
  bool get isOverdue => throw _privateConstructorUsedError;
  bool get isDueSoon => throw _privateConstructorUsedError;
  bool get isDueToday => throw _privateConstructorUsedError;
  BillUrgency get urgency => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BillStatusCopyWith<BillStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillStatusCopyWith<$Res> {
  factory $BillStatusCopyWith(
          BillStatus value, $Res Function(BillStatus) then) =
      _$BillStatusCopyWithImpl<$Res, BillStatus>;
  @useResult
  $Res call(
      {Bill bill,
      int daysUntilDue,
      bool isOverdue,
      bool isDueSoon,
      bool isDueToday,
      BillUrgency urgency});

  $BillCopyWith<$Res> get bill;
}

/// @nodoc
class _$BillStatusCopyWithImpl<$Res, $Val extends BillStatus>
    implements $BillStatusCopyWith<$Res> {
  _$BillStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bill = null,
    Object? daysUntilDue = null,
    Object? isOverdue = null,
    Object? isDueSoon = null,
    Object? isDueToday = null,
    Object? urgency = null,
  }) {
    return _then(_value.copyWith(
      bill: null == bill
          ? _value.bill
          : bill // ignore: cast_nullable_to_non_nullable
              as Bill,
      daysUntilDue: null == daysUntilDue
          ? _value.daysUntilDue
          : daysUntilDue // ignore: cast_nullable_to_non_nullable
              as int,
      isOverdue: null == isOverdue
          ? _value.isOverdue
          : isOverdue // ignore: cast_nullable_to_non_nullable
              as bool,
      isDueSoon: null == isDueSoon
          ? _value.isDueSoon
          : isDueSoon // ignore: cast_nullable_to_non_nullable
              as bool,
      isDueToday: null == isDueToday
          ? _value.isDueToday
          : isDueToday // ignore: cast_nullable_to_non_nullable
              as bool,
      urgency: null == urgency
          ? _value.urgency
          : urgency // ignore: cast_nullable_to_non_nullable
              as BillUrgency,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BillCopyWith<$Res> get bill {
    return $BillCopyWith<$Res>(_value.bill, (value) {
      return _then(_value.copyWith(bill: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BillStatusImplCopyWith<$Res>
    implements $BillStatusCopyWith<$Res> {
  factory _$$BillStatusImplCopyWith(
          _$BillStatusImpl value, $Res Function(_$BillStatusImpl) then) =
      __$$BillStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Bill bill,
      int daysUntilDue,
      bool isOverdue,
      bool isDueSoon,
      bool isDueToday,
      BillUrgency urgency});

  @override
  $BillCopyWith<$Res> get bill;
}

/// @nodoc
class __$$BillStatusImplCopyWithImpl<$Res>
    extends _$BillStatusCopyWithImpl<$Res, _$BillStatusImpl>
    implements _$$BillStatusImplCopyWith<$Res> {
  __$$BillStatusImplCopyWithImpl(
      _$BillStatusImpl _value, $Res Function(_$BillStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bill = null,
    Object? daysUntilDue = null,
    Object? isOverdue = null,
    Object? isDueSoon = null,
    Object? isDueToday = null,
    Object? urgency = null,
  }) {
    return _then(_$BillStatusImpl(
      bill: null == bill
          ? _value.bill
          : bill // ignore: cast_nullable_to_non_nullable
              as Bill,
      daysUntilDue: null == daysUntilDue
          ? _value.daysUntilDue
          : daysUntilDue // ignore: cast_nullable_to_non_nullable
              as int,
      isOverdue: null == isOverdue
          ? _value.isOverdue
          : isOverdue // ignore: cast_nullable_to_non_nullable
              as bool,
      isDueSoon: null == isDueSoon
          ? _value.isDueSoon
          : isDueSoon // ignore: cast_nullable_to_non_nullable
              as bool,
      isDueToday: null == isDueToday
          ? _value.isDueToday
          : isDueToday // ignore: cast_nullable_to_non_nullable
              as bool,
      urgency: null == urgency
          ? _value.urgency
          : urgency // ignore: cast_nullable_to_non_nullable
              as BillUrgency,
    ));
  }
}

/// @nodoc

class _$BillStatusImpl extends _BillStatus {
  const _$BillStatusImpl(
      {required this.bill,
      required this.daysUntilDue,
      required this.isOverdue,
      required this.isDueSoon,
      required this.isDueToday,
      required this.urgency})
      : super._();

  @override
  final Bill bill;
  @override
  final int daysUntilDue;
  @override
  final bool isOverdue;
  @override
  final bool isDueSoon;
  @override
  final bool isDueToday;
  @override
  final BillUrgency urgency;

  @override
  String toString() {
    return 'BillStatus(bill: $bill, daysUntilDue: $daysUntilDue, isOverdue: $isOverdue, isDueSoon: $isDueSoon, isDueToday: $isDueToday, urgency: $urgency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillStatusImpl &&
            (identical(other.bill, bill) || other.bill == bill) &&
            (identical(other.daysUntilDue, daysUntilDue) ||
                other.daysUntilDue == daysUntilDue) &&
            (identical(other.isOverdue, isOverdue) ||
                other.isOverdue == isOverdue) &&
            (identical(other.isDueSoon, isDueSoon) ||
                other.isDueSoon == isDueSoon) &&
            (identical(other.isDueToday, isDueToday) ||
                other.isDueToday == isDueToday) &&
            (identical(other.urgency, urgency) || other.urgency == urgency));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bill, daysUntilDue, isOverdue,
      isDueSoon, isDueToday, urgency);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BillStatusImplCopyWith<_$BillStatusImpl> get copyWith =>
      __$$BillStatusImplCopyWithImpl<_$BillStatusImpl>(this, _$identity);
}

abstract class _BillStatus extends BillStatus {
  const factory _BillStatus(
      {required final Bill bill,
      required final int daysUntilDue,
      required final bool isOverdue,
      required final bool isDueSoon,
      required final bool isDueToday,
      required final BillUrgency urgency}) = _$BillStatusImpl;
  const _BillStatus._() : super._();

  @override
  Bill get bill;
  @override
  int get daysUntilDue;
  @override
  bool get isOverdue;
  @override
  bool get isDueSoon;
  @override
  bool get isDueToday;
  @override
  BillUrgency get urgency;
  @override
  @JsonKey(ignore: true)
  _$$BillStatusImplCopyWith<_$BillStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  BillFrequency get frequency => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get payee =>
      throw _privateConstructorUsedError; // ═══ ACCOUNT RELATIONSHIP ═══
  String? get defaultAccountId =>
      throw _privateConstructorUsedError; // Primary account for payments
  List<String>? get allowedAccountIds =>
      throw _privateConstructorUsedError; // Alternative accounts for payments
  String? get accountId =>
      throw _privateConstructorUsedError; // Legacy field for backward compatibility
  bool get isAutoPay => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;
  DateTime? get lastPaidDate => throw _privateConstructorUsedError;
  DateTime? get nextDueDate => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  BillDifficulty get cancellationDifficulty =>
      throw _privateConstructorUsedError;
  DateTime? get lastPriceIncrease => throw _privateConstructorUsedError;
  List<BillPayment> get paymentHistory =>
      throw _privateConstructorUsedError; // ═══ VARIABLE AMOUNT SUPPORT ═══
  bool get isVariableAmount => throw _privateConstructorUsedError;
  double? get minAmount => throw _privateConstructorUsedError;
  double? get maxAmount =>
      throw _privateConstructorUsedError; // ═══ CURRENCY SUPPORT ═══
  String? get currencyCode =>
      throw _privateConstructorUsedError; // ═══ RECURRING FLEXIBILITY ═══
  List<RecurringPaymentRule> get recurringPaymentRules =>
      throw _privateConstructorUsedError; // Subscription-specific fields
  bool get isCancelled => throw _privateConstructorUsedError;
  DateTime? get cancellationDate => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  List<String> get alternativeProviders => throw _privateConstructorUsedError;
  DateTime? get trialEndDate => throw _privateConstructorUsedError;
  bool get hasFreeTrial => throw _privateConstructorUsedError;
  DateTime? get lastUsedDate => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
          Subscription value, $Res Function(Subscription) then) =
      _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call(
      {String id,
      String name,
      double amount,
      DateTime dueDate,
      BillFrequency frequency,
      String categoryId,
      String? description,
      String? payee,
      String? defaultAccountId,
      List<String>? allowedAccountIds,
      String? accountId,
      bool isAutoPay,
      bool isPaid,
      DateTime? lastPaidDate,
      DateTime? nextDueDate,
      String? website,
      String? notes,
      BillDifficulty cancellationDifficulty,
      DateTime? lastPriceIncrease,
      List<BillPayment> paymentHistory,
      bool isVariableAmount,
      double? minAmount,
      double? maxAmount,
      String? currencyCode,
      List<RecurringPaymentRule> recurringPaymentRules,
      bool isCancelled,
      DateTime? cancellationDate,
      String? cancellationReason,
      List<String> alternativeProviders,
      DateTime? trialEndDate,
      bool hasFreeTrial,
      DateTime? lastUsedDate});
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? dueDate = null,
    Object? frequency = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? payee = freezed,
    Object? defaultAccountId = freezed,
    Object? allowedAccountIds = freezed,
    Object? accountId = freezed,
    Object? isAutoPay = null,
    Object? isPaid = null,
    Object? lastPaidDate = freezed,
    Object? nextDueDate = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? cancellationDifficulty = null,
    Object? lastPriceIncrease = freezed,
    Object? paymentHistory = null,
    Object? isVariableAmount = null,
    Object? minAmount = freezed,
    Object? maxAmount = freezed,
    Object? currencyCode = freezed,
    Object? recurringPaymentRules = null,
    Object? isCancelled = null,
    Object? cancellationDate = freezed,
    Object? cancellationReason = freezed,
    Object? alternativeProviders = null,
    Object? trialEndDate = freezed,
    Object? hasFreeTrial = null,
    Object? lastUsedDate = freezed,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as BillFrequency,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      payee: freezed == payee
          ? _value.payee
          : payee // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultAccountId: freezed == defaultAccountId
          ? _value.defaultAccountId
          : defaultAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      allowedAccountIds: freezed == allowedAccountIds
          ? _value.allowedAccountIds
          : allowedAccountIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoPay: null == isAutoPay
          ? _value.isAutoPay
          : isAutoPay // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPaidDate: freezed == lastPaidDate
          ? _value.lastPaidDate
          : lastPaidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationDifficulty: null == cancellationDifficulty
          ? _value.cancellationDifficulty
          : cancellationDifficulty // ignore: cast_nullable_to_non_nullable
              as BillDifficulty,
      lastPriceIncrease: freezed == lastPriceIncrease
          ? _value.lastPriceIncrease
          : lastPriceIncrease // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentHistory: null == paymentHistory
          ? _value.paymentHistory
          : paymentHistory // ignore: cast_nullable_to_non_nullable
              as List<BillPayment>,
      isVariableAmount: null == isVariableAmount
          ? _value.isVariableAmount
          : isVariableAmount // ignore: cast_nullable_to_non_nullable
              as bool,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxAmount: freezed == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      recurringPaymentRules: null == recurringPaymentRules
          ? _value.recurringPaymentRules
          : recurringPaymentRules // ignore: cast_nullable_to_non_nullable
              as List<RecurringPaymentRule>,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      cancellationDate: freezed == cancellationDate
          ? _value.cancellationDate
          : cancellationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      alternativeProviders: null == alternativeProviders
          ? _value.alternativeProviders
          : alternativeProviders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trialEndDate: freezed == trialEndDate
          ? _value.trialEndDate
          : trialEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasFreeTrial: null == hasFreeTrial
          ? _value.hasFreeTrial
          : hasFreeTrial // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUsedDate: freezed == lastUsedDate
          ? _value.lastUsedDate
          : lastUsedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
          _$SubscriptionImpl value, $Res Function(_$SubscriptionImpl) then) =
      __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double amount,
      DateTime dueDate,
      BillFrequency frequency,
      String categoryId,
      String? description,
      String? payee,
      String? defaultAccountId,
      List<String>? allowedAccountIds,
      String? accountId,
      bool isAutoPay,
      bool isPaid,
      DateTime? lastPaidDate,
      DateTime? nextDueDate,
      String? website,
      String? notes,
      BillDifficulty cancellationDifficulty,
      DateTime? lastPriceIncrease,
      List<BillPayment> paymentHistory,
      bool isVariableAmount,
      double? minAmount,
      double? maxAmount,
      String? currencyCode,
      List<RecurringPaymentRule> recurringPaymentRules,
      bool isCancelled,
      DateTime? cancellationDate,
      String? cancellationReason,
      List<String> alternativeProviders,
      DateTime? trialEndDate,
      bool hasFreeTrial,
      DateTime? lastUsedDate});
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
      _$SubscriptionImpl _value, $Res Function(_$SubscriptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? dueDate = null,
    Object? frequency = null,
    Object? categoryId = null,
    Object? description = freezed,
    Object? payee = freezed,
    Object? defaultAccountId = freezed,
    Object? allowedAccountIds = freezed,
    Object? accountId = freezed,
    Object? isAutoPay = null,
    Object? isPaid = null,
    Object? lastPaidDate = freezed,
    Object? nextDueDate = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? cancellationDifficulty = null,
    Object? lastPriceIncrease = freezed,
    Object? paymentHistory = null,
    Object? isVariableAmount = null,
    Object? minAmount = freezed,
    Object? maxAmount = freezed,
    Object? currencyCode = freezed,
    Object? recurringPaymentRules = null,
    Object? isCancelled = null,
    Object? cancellationDate = freezed,
    Object? cancellationReason = freezed,
    Object? alternativeProviders = null,
    Object? trialEndDate = freezed,
    Object? hasFreeTrial = null,
    Object? lastUsedDate = freezed,
  }) {
    return _then(_$SubscriptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as BillFrequency,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      payee: freezed == payee
          ? _value.payee
          : payee // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultAccountId: freezed == defaultAccountId
          ? _value.defaultAccountId
          : defaultAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      allowedAccountIds: freezed == allowedAccountIds
          ? _value._allowedAccountIds
          : allowedAccountIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoPay: null == isAutoPay
          ? _value.isAutoPay
          : isAutoPay // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPaidDate: freezed == lastPaidDate
          ? _value.lastPaidDate
          : lastPaidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationDifficulty: null == cancellationDifficulty
          ? _value.cancellationDifficulty
          : cancellationDifficulty // ignore: cast_nullable_to_non_nullable
              as BillDifficulty,
      lastPriceIncrease: freezed == lastPriceIncrease
          ? _value.lastPriceIncrease
          : lastPriceIncrease // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentHistory: null == paymentHistory
          ? _value._paymentHistory
          : paymentHistory // ignore: cast_nullable_to_non_nullable
              as List<BillPayment>,
      isVariableAmount: null == isVariableAmount
          ? _value.isVariableAmount
          : isVariableAmount // ignore: cast_nullable_to_non_nullable
              as bool,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxAmount: freezed == maxAmount
          ? _value.maxAmount
          : maxAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      currencyCode: freezed == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String?,
      recurringPaymentRules: null == recurringPaymentRules
          ? _value._recurringPaymentRules
          : recurringPaymentRules // ignore: cast_nullable_to_non_nullable
              as List<RecurringPaymentRule>,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      cancellationDate: freezed == cancellationDate
          ? _value.cancellationDate
          : cancellationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      alternativeProviders: null == alternativeProviders
          ? _value._alternativeProviders
          : alternativeProviders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trialEndDate: freezed == trialEndDate
          ? _value.trialEndDate
          : trialEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasFreeTrial: null == hasFreeTrial
          ? _value.hasFreeTrial
          : hasFreeTrial // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUsedDate: freezed == lastUsedDate
          ? _value.lastUsedDate
          : lastUsedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$SubscriptionImpl extends _Subscription {
  const _$SubscriptionImpl(
      {required this.id,
      required this.name,
      required this.amount,
      required this.dueDate,
      required this.frequency,
      required this.categoryId,
      this.description,
      this.payee,
      this.defaultAccountId,
      final List<String>? allowedAccountIds,
      this.accountId,
      this.isAutoPay = false,
      this.isPaid = false,
      this.lastPaidDate,
      this.nextDueDate,
      this.website,
      this.notes,
      this.cancellationDifficulty = BillDifficulty.easy,
      this.lastPriceIncrease,
      final List<BillPayment> paymentHistory = const [],
      this.isVariableAmount = false,
      this.minAmount,
      this.maxAmount,
      this.currencyCode,
      final List<RecurringPaymentRule> recurringPaymentRules = const [],
      this.isCancelled = false,
      this.cancellationDate,
      this.cancellationReason,
      final List<String> alternativeProviders = const [],
      this.trialEndDate,
      this.hasFreeTrial = false,
      this.lastUsedDate})
      : _allowedAccountIds = allowedAccountIds,
        _paymentHistory = paymentHistory,
        _recurringPaymentRules = recurringPaymentRules,
        _alternativeProviders = alternativeProviders,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final double amount;
  @override
  final DateTime dueDate;
  @override
  final BillFrequency frequency;
  @override
  final String categoryId;
  @override
  final String? description;
  @override
  final String? payee;
// ═══ ACCOUNT RELATIONSHIP ═══
  @override
  final String? defaultAccountId;
// Primary account for payments
  final List<String>? _allowedAccountIds;
// Primary account for payments
  @override
  List<String>? get allowedAccountIds {
    final value = _allowedAccountIds;
    if (value == null) return null;
    if (_allowedAccountIds is EqualUnmodifiableListView)
      return _allowedAccountIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Alternative accounts for payments
  @override
  final String? accountId;
// Legacy field for backward compatibility
  @override
  @JsonKey()
  final bool isAutoPay;
  @override
  @JsonKey()
  final bool isPaid;
  @override
  final DateTime? lastPaidDate;
  @override
  final DateTime? nextDueDate;
  @override
  final String? website;
  @override
  final String? notes;
  @override
  @JsonKey()
  final BillDifficulty cancellationDifficulty;
  @override
  final DateTime? lastPriceIncrease;
  final List<BillPayment> _paymentHistory;
  @override
  @JsonKey()
  List<BillPayment> get paymentHistory {
    if (_paymentHistory is EqualUnmodifiableListView) return _paymentHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paymentHistory);
  }

// ═══ VARIABLE AMOUNT SUPPORT ═══
  @override
  @JsonKey()
  final bool isVariableAmount;
  @override
  final double? minAmount;
  @override
  final double? maxAmount;
// ═══ CURRENCY SUPPORT ═══
  @override
  final String? currencyCode;
// ═══ RECURRING FLEXIBILITY ═══
  final List<RecurringPaymentRule> _recurringPaymentRules;
// ═══ RECURRING FLEXIBILITY ═══
  @override
  @JsonKey()
  List<RecurringPaymentRule> get recurringPaymentRules {
    if (_recurringPaymentRules is EqualUnmodifiableListView)
      return _recurringPaymentRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recurringPaymentRules);
  }

// Subscription-specific fields
  @override
  @JsonKey()
  final bool isCancelled;
  @override
  final DateTime? cancellationDate;
  @override
  final String? cancellationReason;
  final List<String> _alternativeProviders;
  @override
  @JsonKey()
  List<String> get alternativeProviders {
    if (_alternativeProviders is EqualUnmodifiableListView)
      return _alternativeProviders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternativeProviders);
  }

  @override
  final DateTime? trialEndDate;
  @override
  @JsonKey()
  final bool hasFreeTrial;
  @override
  final DateTime? lastUsedDate;

  @override
  String toString() {
    return 'Subscription(id: $id, name: $name, amount: $amount, dueDate: $dueDate, frequency: $frequency, categoryId: $categoryId, description: $description, payee: $payee, defaultAccountId: $defaultAccountId, allowedAccountIds: $allowedAccountIds, accountId: $accountId, isAutoPay: $isAutoPay, isPaid: $isPaid, lastPaidDate: $lastPaidDate, nextDueDate: $nextDueDate, website: $website, notes: $notes, cancellationDifficulty: $cancellationDifficulty, lastPriceIncrease: $lastPriceIncrease, paymentHistory: $paymentHistory, isVariableAmount: $isVariableAmount, minAmount: $minAmount, maxAmount: $maxAmount, currencyCode: $currencyCode, recurringPaymentRules: $recurringPaymentRules, isCancelled: $isCancelled, cancellationDate: $cancellationDate, cancellationReason: $cancellationReason, alternativeProviders: $alternativeProviders, trialEndDate: $trialEndDate, hasFreeTrial: $hasFreeTrial, lastUsedDate: $lastUsedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.payee, payee) || other.payee == payee) &&
            (identical(other.defaultAccountId, defaultAccountId) ||
                other.defaultAccountId == defaultAccountId) &&
            const DeepCollectionEquality()
                .equals(other._allowedAccountIds, _allowedAccountIds) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.isAutoPay, isAutoPay) ||
                other.isAutoPay == isAutoPay) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.lastPaidDate, lastPaidDate) ||
                other.lastPaidDate == lastPaidDate) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.cancellationDifficulty, cancellationDifficulty) ||
                other.cancellationDifficulty == cancellationDifficulty) &&
            (identical(other.lastPriceIncrease, lastPriceIncrease) ||
                other.lastPriceIncrease == lastPriceIncrease) &&
            const DeepCollectionEquality()
                .equals(other._paymentHistory, _paymentHistory) &&
            (identical(other.isVariableAmount, isVariableAmount) ||
                other.isVariableAmount == isVariableAmount) &&
            (identical(other.minAmount, minAmount) ||
                other.minAmount == minAmount) &&
            (identical(other.maxAmount, maxAmount) ||
                other.maxAmount == maxAmount) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            const DeepCollectionEquality()
                .equals(other._recurringPaymentRules, _recurringPaymentRules) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled) &&
            (identical(other.cancellationDate, cancellationDate) ||
                other.cancellationDate == cancellationDate) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            const DeepCollectionEquality()
                .equals(other._alternativeProviders, _alternativeProviders) &&
            (identical(other.trialEndDate, trialEndDate) ||
                other.trialEndDate == trialEndDate) &&
            (identical(other.hasFreeTrial, hasFreeTrial) ||
                other.hasFreeTrial == hasFreeTrial) &&
            (identical(other.lastUsedDate, lastUsedDate) ||
                other.lastUsedDate == lastUsedDate));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        amount,
        dueDate,
        frequency,
        categoryId,
        description,
        payee,
        defaultAccountId,
        const DeepCollectionEquality().hash(_allowedAccountIds),
        accountId,
        isAutoPay,
        isPaid,
        lastPaidDate,
        nextDueDate,
        website,
        notes,
        cancellationDifficulty,
        lastPriceIncrease,
        const DeepCollectionEquality().hash(_paymentHistory),
        isVariableAmount,
        minAmount,
        maxAmount,
        currencyCode,
        const DeepCollectionEquality().hash(_recurringPaymentRules),
        isCancelled,
        cancellationDate,
        cancellationReason,
        const DeepCollectionEquality().hash(_alternativeProviders),
        trialEndDate,
        hasFreeTrial,
        lastUsedDate
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);
}

abstract class _Subscription extends Subscription {
  const factory _Subscription(
      {required final String id,
      required final String name,
      required final double amount,
      required final DateTime dueDate,
      required final BillFrequency frequency,
      required final String categoryId,
      final String? description,
      final String? payee,
      final String? defaultAccountId,
      final List<String>? allowedAccountIds,
      final String? accountId,
      final bool isAutoPay,
      final bool isPaid,
      final DateTime? lastPaidDate,
      final DateTime? nextDueDate,
      final String? website,
      final String? notes,
      final BillDifficulty cancellationDifficulty,
      final DateTime? lastPriceIncrease,
      final List<BillPayment> paymentHistory,
      final bool isVariableAmount,
      final double? minAmount,
      final double? maxAmount,
      final String? currencyCode,
      final List<RecurringPaymentRule> recurringPaymentRules,
      final bool isCancelled,
      final DateTime? cancellationDate,
      final String? cancellationReason,
      final List<String> alternativeProviders,
      final DateTime? trialEndDate,
      final bool hasFreeTrial,
      final DateTime? lastUsedDate}) = _$SubscriptionImpl;
  const _Subscription._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  double get amount;
  @override
  DateTime get dueDate;
  @override
  BillFrequency get frequency;
  @override
  String get categoryId;
  @override
  String? get description;
  @override
  String? get payee;
  @override // ═══ ACCOUNT RELATIONSHIP ═══
  String? get defaultAccountId;
  @override // Primary account for payments
  List<String>? get allowedAccountIds;
  @override // Alternative accounts for payments
  String? get accountId;
  @override // Legacy field for backward compatibility
  bool get isAutoPay;
  @override
  bool get isPaid;
  @override
  DateTime? get lastPaidDate;
  @override
  DateTime? get nextDueDate;
  @override
  String? get website;
  @override
  String? get notes;
  @override
  BillDifficulty get cancellationDifficulty;
  @override
  DateTime? get lastPriceIncrease;
  @override
  List<BillPayment> get paymentHistory;
  @override // ═══ VARIABLE AMOUNT SUPPORT ═══
  bool get isVariableAmount;
  @override
  double? get minAmount;
  @override
  double? get maxAmount;
  @override // ═══ CURRENCY SUPPORT ═══
  String? get currencyCode;
  @override // ═══ RECURRING FLEXIBILITY ═══
  List<RecurringPaymentRule> get recurringPaymentRules;
  @override // Subscription-specific fields
  bool get isCancelled;
  @override
  DateTime? get cancellationDate;
  @override
  String? get cancellationReason;
  @override
  List<String> get alternativeProviders;
  @override
  DateTime? get trialEndDate;
  @override
  bool get hasFreeTrial;
  @override
  DateTime? get lastUsedDate;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BillsSummary {
  int get totalBills => throw _privateConstructorUsedError;
  int get paidThisMonth => throw _privateConstructorUsedError;
  int get dueThisMonth => throw _privateConstructorUsedError;
  int get overdue => throw _privateConstructorUsedError;
  double get totalMonthlyAmount => throw _privateConstructorUsedError;
  double get paidAmount => throw _privateConstructorUsedError;
  double get remainingAmount => throw _privateConstructorUsedError;
  List<BillStatus> get upcomingBills => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BillsSummaryCopyWith<BillsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillsSummaryCopyWith<$Res> {
  factory $BillsSummaryCopyWith(
          BillsSummary value, $Res Function(BillsSummary) then) =
      _$BillsSummaryCopyWithImpl<$Res, BillsSummary>;
  @useResult
  $Res call(
      {int totalBills,
      int paidThisMonth,
      int dueThisMonth,
      int overdue,
      double totalMonthlyAmount,
      double paidAmount,
      double remainingAmount,
      List<BillStatus> upcomingBills});
}

/// @nodoc
class _$BillsSummaryCopyWithImpl<$Res, $Val extends BillsSummary>
    implements $BillsSummaryCopyWith<$Res> {
  _$BillsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBills = null,
    Object? paidThisMonth = null,
    Object? dueThisMonth = null,
    Object? overdue = null,
    Object? totalMonthlyAmount = null,
    Object? paidAmount = null,
    Object? remainingAmount = null,
    Object? upcomingBills = null,
  }) {
    return _then(_value.copyWith(
      totalBills: null == totalBills
          ? _value.totalBills
          : totalBills // ignore: cast_nullable_to_non_nullable
              as int,
      paidThisMonth: null == paidThisMonth
          ? _value.paidThisMonth
          : paidThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      dueThisMonth: null == dueThisMonth
          ? _value.dueThisMonth
          : dueThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      overdue: null == overdue
          ? _value.overdue
          : overdue // ignore: cast_nullable_to_non_nullable
              as int,
      totalMonthlyAmount: null == totalMonthlyAmount
          ? _value.totalMonthlyAmount
          : totalMonthlyAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double,
      remainingAmount: null == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as double,
      upcomingBills: null == upcomingBills
          ? _value.upcomingBills
          : upcomingBills // ignore: cast_nullable_to_non_nullable
              as List<BillStatus>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BillsSummaryImplCopyWith<$Res>
    implements $BillsSummaryCopyWith<$Res> {
  factory _$$BillsSummaryImplCopyWith(
          _$BillsSummaryImpl value, $Res Function(_$BillsSummaryImpl) then) =
      __$$BillsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalBills,
      int paidThisMonth,
      int dueThisMonth,
      int overdue,
      double totalMonthlyAmount,
      double paidAmount,
      double remainingAmount,
      List<BillStatus> upcomingBills});
}

/// @nodoc
class __$$BillsSummaryImplCopyWithImpl<$Res>
    extends _$BillsSummaryCopyWithImpl<$Res, _$BillsSummaryImpl>
    implements _$$BillsSummaryImplCopyWith<$Res> {
  __$$BillsSummaryImplCopyWithImpl(
      _$BillsSummaryImpl _value, $Res Function(_$BillsSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBills = null,
    Object? paidThisMonth = null,
    Object? dueThisMonth = null,
    Object? overdue = null,
    Object? totalMonthlyAmount = null,
    Object? paidAmount = null,
    Object? remainingAmount = null,
    Object? upcomingBills = null,
  }) {
    return _then(_$BillsSummaryImpl(
      totalBills: null == totalBills
          ? _value.totalBills
          : totalBills // ignore: cast_nullable_to_non_nullable
              as int,
      paidThisMonth: null == paidThisMonth
          ? _value.paidThisMonth
          : paidThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      dueThisMonth: null == dueThisMonth
          ? _value.dueThisMonth
          : dueThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      overdue: null == overdue
          ? _value.overdue
          : overdue // ignore: cast_nullable_to_non_nullable
              as int,
      totalMonthlyAmount: null == totalMonthlyAmount
          ? _value.totalMonthlyAmount
          : totalMonthlyAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double,
      remainingAmount: null == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as double,
      upcomingBills: null == upcomingBills
          ? _value._upcomingBills
          : upcomingBills // ignore: cast_nullable_to_non_nullable
              as List<BillStatus>,
    ));
  }
}

/// @nodoc

class _$BillsSummaryImpl extends _BillsSummary {
  const _$BillsSummaryImpl(
      {required this.totalBills,
      required this.paidThisMonth,
      required this.dueThisMonth,
      required this.overdue,
      required this.totalMonthlyAmount,
      required this.paidAmount,
      required this.remainingAmount,
      required final List<BillStatus> upcomingBills})
      : _upcomingBills = upcomingBills,
        super._();

  @override
  final int totalBills;
  @override
  final int paidThisMonth;
  @override
  final int dueThisMonth;
  @override
  final int overdue;
  @override
  final double totalMonthlyAmount;
  @override
  final double paidAmount;
  @override
  final double remainingAmount;
  final List<BillStatus> _upcomingBills;
  @override
  List<BillStatus> get upcomingBills {
    if (_upcomingBills is EqualUnmodifiableListView) return _upcomingBills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcomingBills);
  }

  @override
  String toString() {
    return 'BillsSummary(totalBills: $totalBills, paidThisMonth: $paidThisMonth, dueThisMonth: $dueThisMonth, overdue: $overdue, totalMonthlyAmount: $totalMonthlyAmount, paidAmount: $paidAmount, remainingAmount: $remainingAmount, upcomingBills: $upcomingBills)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillsSummaryImpl &&
            (identical(other.totalBills, totalBills) ||
                other.totalBills == totalBills) &&
            (identical(other.paidThisMonth, paidThisMonth) ||
                other.paidThisMonth == paidThisMonth) &&
            (identical(other.dueThisMonth, dueThisMonth) ||
                other.dueThisMonth == dueThisMonth) &&
            (identical(other.overdue, overdue) || other.overdue == overdue) &&
            (identical(other.totalMonthlyAmount, totalMonthlyAmount) ||
                other.totalMonthlyAmount == totalMonthlyAmount) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.remainingAmount, remainingAmount) ||
                other.remainingAmount == remainingAmount) &&
            const DeepCollectionEquality()
                .equals(other._upcomingBills, _upcomingBills));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalBills,
      paidThisMonth,
      dueThisMonth,
      overdue,
      totalMonthlyAmount,
      paidAmount,
      remainingAmount,
      const DeepCollectionEquality().hash(_upcomingBills));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BillsSummaryImplCopyWith<_$BillsSummaryImpl> get copyWith =>
      __$$BillsSummaryImplCopyWithImpl<_$BillsSummaryImpl>(this, _$identity);
}

abstract class _BillsSummary extends BillsSummary {
  const factory _BillsSummary(
      {required final int totalBills,
      required final int paidThisMonth,
      required final int dueThisMonth,
      required final int overdue,
      required final double totalMonthlyAmount,
      required final double paidAmount,
      required final double remainingAmount,
      required final List<BillStatus> upcomingBills}) = _$BillsSummaryImpl;
  const _BillsSummary._() : super._();

  @override
  int get totalBills;
  @override
  int get paidThisMonth;
  @override
  int get dueThisMonth;
  @override
  int get overdue;
  @override
  double get totalMonthlyAmount;
  @override
  double get paidAmount;
  @override
  double get remainingAmount;
  @override
  List<BillStatus> get upcomingBills;
  @override
  @JsonKey(ignore: true)
  _$$BillsSummaryImplCopyWith<_$BillsSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
