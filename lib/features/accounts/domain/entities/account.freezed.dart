// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Account {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AccountType get type =>
      throw _privateConstructorUsedError; // Hybrid balance system
  double? get cachedBalance =>
      throw _privateConstructorUsedError; // Eager updated on transactions
  DateTime? get lastBalanceUpdate => throw _privateConstructorUsedError;
  double? get reconciledBalance =>
      throw _privateConstructorUsedError; // Calculated from transactions
  DateTime? get lastReconciliation =>
      throw _privateConstructorUsedError; // Backward compatibility - for migration
  double? get balance => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get institution => throw _privateConstructorUsedError;
  String? get accountNumber => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Type-specific fields
  double? get creditLimit =>
      throw _privateConstructorUsedError; // For credit cards
  double? get availableCredit =>
      throw _privateConstructorUsedError; // For credit cards
  double? get interestRate =>
      throw _privateConstructorUsedError; // For loans/investments
  double? get minimumPayment =>
      throw _privateConstructorUsedError; // For loans/credit cards
  DateTime? get dueDate =>
      throw _privateConstructorUsedError; // For loans/credit cards
  bool get isActive =>
      throw _privateConstructorUsedError; // Bank connection fields
  bool get isBankConnected => throw _privateConstructorUsedError;
  String? get bankConnectionId => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;
  BankConnectionStatus? get connectionStatus =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AccountCopyWith<Account> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) then) =
      _$AccountCopyWithImpl<$Res, Account>;
  @useResult
  $Res call(
      {String id,
      String name,
      AccountType type,
      double? cachedBalance,
      DateTime? lastBalanceUpdate,
      double? reconciledBalance,
      DateTime? lastReconciliation,
      double? balance,
      String? description,
      String? institution,
      String? accountNumber,
      String? currency,
      DateTime? createdAt,
      DateTime? updatedAt,
      double? creditLimit,
      double? availableCredit,
      double? interestRate,
      double? minimumPayment,
      DateTime? dueDate,
      bool isActive,
      bool isBankConnected,
      String? bankConnectionId,
      DateTime? lastSyncedAt,
      BankConnectionStatus? connectionStatus});
}

/// @nodoc
class _$AccountCopyWithImpl<$Res, $Val extends Account>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? cachedBalance = freezed,
    Object? lastBalanceUpdate = freezed,
    Object? reconciledBalance = freezed,
    Object? lastReconciliation = freezed,
    Object? balance = freezed,
    Object? description = freezed,
    Object? institution = freezed,
    Object? accountNumber = freezed,
    Object? currency = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? creditLimit = freezed,
    Object? availableCredit = freezed,
    Object? interestRate = freezed,
    Object? minimumPayment = freezed,
    Object? dueDate = freezed,
    Object? isActive = null,
    Object? isBankConnected = null,
    Object? bankConnectionId = freezed,
    Object? lastSyncedAt = freezed,
    Object? connectionStatus = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      cachedBalance: freezed == cachedBalance
          ? _value.cachedBalance
          : cachedBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      lastBalanceUpdate: freezed == lastBalanceUpdate
          ? _value.lastBalanceUpdate
          : lastBalanceUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reconciledBalance: freezed == reconciledBalance
          ? _value.reconciledBalance
          : reconciledBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      lastReconciliation: freezed == lastReconciliation
          ? _value.lastReconciliation
          : lastReconciliation // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      institution: freezed == institution
          ? _value.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creditLimit: freezed == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double?,
      availableCredit: freezed == availableCredit
          ? _value.availableCredit
          : availableCredit // ignore: cast_nullable_to_non_nullable
              as double?,
      interestRate: freezed == interestRate
          ? _value.interestRate
          : interestRate // ignore: cast_nullable_to_non_nullable
              as double?,
      minimumPayment: freezed == minimumPayment
          ? _value.minimumPayment
          : minimumPayment // ignore: cast_nullable_to_non_nullable
              as double?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isBankConnected: null == isBankConnected
          ? _value.isBankConnected
          : isBankConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      bankConnectionId: freezed == bankConnectionId
          ? _value.bankConnectionId
          : bankConnectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      connectionStatus: freezed == connectionStatus
          ? _value.connectionStatus
          : connectionStatus // ignore: cast_nullable_to_non_nullable
              as BankConnectionStatus?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountImplCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$$AccountImplCopyWith(
          _$AccountImpl value, $Res Function(_$AccountImpl) then) =
      __$$AccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      AccountType type,
      double? cachedBalance,
      DateTime? lastBalanceUpdate,
      double? reconciledBalance,
      DateTime? lastReconciliation,
      double? balance,
      String? description,
      String? institution,
      String? accountNumber,
      String? currency,
      DateTime? createdAt,
      DateTime? updatedAt,
      double? creditLimit,
      double? availableCredit,
      double? interestRate,
      double? minimumPayment,
      DateTime? dueDate,
      bool isActive,
      bool isBankConnected,
      String? bankConnectionId,
      DateTime? lastSyncedAt,
      BankConnectionStatus? connectionStatus});
}

/// @nodoc
class __$$AccountImplCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountImpl>
    implements _$$AccountImplCopyWith<$Res> {
  __$$AccountImplCopyWithImpl(
      _$AccountImpl _value, $Res Function(_$AccountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? cachedBalance = freezed,
    Object? lastBalanceUpdate = freezed,
    Object? reconciledBalance = freezed,
    Object? lastReconciliation = freezed,
    Object? balance = freezed,
    Object? description = freezed,
    Object? institution = freezed,
    Object? accountNumber = freezed,
    Object? currency = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? creditLimit = freezed,
    Object? availableCredit = freezed,
    Object? interestRate = freezed,
    Object? minimumPayment = freezed,
    Object? dueDate = freezed,
    Object? isActive = null,
    Object? isBankConnected = null,
    Object? bankConnectionId = freezed,
    Object? lastSyncedAt = freezed,
    Object? connectionStatus = freezed,
  }) {
    return _then(_$AccountImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      cachedBalance: freezed == cachedBalance
          ? _value.cachedBalance
          : cachedBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      lastBalanceUpdate: freezed == lastBalanceUpdate
          ? _value.lastBalanceUpdate
          : lastBalanceUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reconciledBalance: freezed == reconciledBalance
          ? _value.reconciledBalance
          : reconciledBalance // ignore: cast_nullable_to_non_nullable
              as double?,
      lastReconciliation: freezed == lastReconciliation
          ? _value.lastReconciliation
          : lastReconciliation // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      institution: freezed == institution
          ? _value.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creditLimit: freezed == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double?,
      availableCredit: freezed == availableCredit
          ? _value.availableCredit
          : availableCredit // ignore: cast_nullable_to_non_nullable
              as double?,
      interestRate: freezed == interestRate
          ? _value.interestRate
          : interestRate // ignore: cast_nullable_to_non_nullable
              as double?,
      minimumPayment: freezed == minimumPayment
          ? _value.minimumPayment
          : minimumPayment // ignore: cast_nullable_to_non_nullable
              as double?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isBankConnected: null == isBankConnected
          ? _value.isBankConnected
          : isBankConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      bankConnectionId: freezed == bankConnectionId
          ? _value.bankConnectionId
          : bankConnectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      connectionStatus: freezed == connectionStatus
          ? _value.connectionStatus
          : connectionStatus // ignore: cast_nullable_to_non_nullable
              as BankConnectionStatus?,
    ));
  }
}

/// @nodoc

class _$AccountImpl extends _Account {
  const _$AccountImpl(
      {required this.id,
      required this.name,
      required this.type,
      this.cachedBalance,
      this.lastBalanceUpdate,
      this.reconciledBalance,
      this.lastReconciliation,
      this.balance,
      this.description,
      this.institution,
      this.accountNumber,
      this.currency,
      this.createdAt,
      this.updatedAt,
      this.creditLimit,
      this.availableCredit,
      this.interestRate,
      this.minimumPayment,
      this.dueDate,
      this.isActive = true,
      this.isBankConnected = false,
      this.bankConnectionId,
      this.lastSyncedAt,
      this.connectionStatus})
      : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final AccountType type;
// Hybrid balance system
  @override
  final double? cachedBalance;
// Eager updated on transactions
  @override
  final DateTime? lastBalanceUpdate;
  @override
  final double? reconciledBalance;
// Calculated from transactions
  @override
  final DateTime? lastReconciliation;
// Backward compatibility - for migration
  @override
  final double? balance;
  @override
  final String? description;
  @override
  final String? institution;
  @override
  final String? accountNumber;
  @override
  final String? currency;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// Type-specific fields
  @override
  final double? creditLimit;
// For credit cards
  @override
  final double? availableCredit;
// For credit cards
  @override
  final double? interestRate;
// For loans/investments
  @override
  final double? minimumPayment;
// For loans/credit cards
  @override
  final DateTime? dueDate;
// For loans/credit cards
  @override
  @JsonKey()
  final bool isActive;
// Bank connection fields
  @override
  @JsonKey()
  final bool isBankConnected;
  @override
  final String? bankConnectionId;
  @override
  final DateTime? lastSyncedAt;
  @override
  final BankConnectionStatus? connectionStatus;

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, cachedBalance: $cachedBalance, lastBalanceUpdate: $lastBalanceUpdate, reconciledBalance: $reconciledBalance, lastReconciliation: $lastReconciliation, balance: $balance, description: $description, institution: $institution, accountNumber: $accountNumber, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt, creditLimit: $creditLimit, availableCredit: $availableCredit, interestRate: $interestRate, minimumPayment: $minimumPayment, dueDate: $dueDate, isActive: $isActive, isBankConnected: $isBankConnected, bankConnectionId: $bankConnectionId, lastSyncedAt: $lastSyncedAt, connectionStatus: $connectionStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.cachedBalance, cachedBalance) ||
                other.cachedBalance == cachedBalance) &&
            (identical(other.lastBalanceUpdate, lastBalanceUpdate) ||
                other.lastBalanceUpdate == lastBalanceUpdate) &&
            (identical(other.reconciledBalance, reconciledBalance) ||
                other.reconciledBalance == reconciledBalance) &&
            (identical(other.lastReconciliation, lastReconciliation) ||
                other.lastReconciliation == lastReconciliation) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.institution, institution) ||
                other.institution == institution) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.availableCredit, availableCredit) ||
                other.availableCredit == availableCredit) &&
            (identical(other.interestRate, interestRate) ||
                other.interestRate == interestRate) &&
            (identical(other.minimumPayment, minimumPayment) ||
                other.minimumPayment == minimumPayment) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isBankConnected, isBankConnected) ||
                other.isBankConnected == isBankConnected) &&
            (identical(other.bankConnectionId, bankConnectionId) ||
                other.bankConnectionId == bankConnectionId) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            (identical(other.connectionStatus, connectionStatus) ||
                other.connectionStatus == connectionStatus));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        type,
        cachedBalance,
        lastBalanceUpdate,
        reconciledBalance,
        lastReconciliation,
        balance,
        description,
        institution,
        accountNumber,
        currency,
        createdAt,
        updatedAt,
        creditLimit,
        availableCredit,
        interestRate,
        minimumPayment,
        dueDate,
        isActive,
        isBankConnected,
        bankConnectionId,
        lastSyncedAt,
        connectionStatus
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      __$$AccountImplCopyWithImpl<_$AccountImpl>(this, _$identity);
}

abstract class _Account extends Account {
  const factory _Account(
      {required final String id,
      required final String name,
      required final AccountType type,
      final double? cachedBalance,
      final DateTime? lastBalanceUpdate,
      final double? reconciledBalance,
      final DateTime? lastReconciliation,
      final double? balance,
      final String? description,
      final String? institution,
      final String? accountNumber,
      final String? currency,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final double? creditLimit,
      final double? availableCredit,
      final double? interestRate,
      final double? minimumPayment,
      final DateTime? dueDate,
      final bool isActive,
      final bool isBankConnected,
      final String? bankConnectionId,
      final DateTime? lastSyncedAt,
      final BankConnectionStatus? connectionStatus}) = _$AccountImpl;
  const _Account._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  AccountType get type;
  @override // Hybrid balance system
  double? get cachedBalance;
  @override // Eager updated on transactions
  DateTime? get lastBalanceUpdate;
  @override
  double? get reconciledBalance;
  @override // Calculated from transactions
  DateTime? get lastReconciliation;
  @override // Backward compatibility - for migration
  double? get balance;
  @override
  String? get description;
  @override
  String? get institution;
  @override
  String? get accountNumber;
  @override
  String? get currency;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override // Type-specific fields
  double? get creditLimit;
  @override // For credit cards
  double? get availableCredit;
  @override // For credit cards
  double? get interestRate;
  @override // For loans/investments
  double? get minimumPayment;
  @override // For loans/credit cards
  DateTime? get dueDate;
  @override // For loans/credit cards
  bool get isActive;
  @override // Bank connection fields
  bool get isBankConnected;
  @override
  String? get bankConnectionId;
  @override
  DateTime? get lastSyncedAt;
  @override
  BankConnectionStatus? get connectionStatus;
  @override
  @JsonKey(ignore: true)
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
