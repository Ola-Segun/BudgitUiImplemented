// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ImportResult {
  List<Transaction> get transactions => throw _privateConstructorUsedError;
  List<TransactionCategory> get categories =>
      throw _privateConstructorUsedError;
  List<Account> get accounts => throw _privateConstructorUsedError;
  List<Budget> get budgets => throw _privateConstructorUsedError;
  List<Goal> get goals => throw _privateConstructorUsedError;
  List<ImportError> get errors => throw _privateConstructorUsedError;
  ImportSummary get summary => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ImportResultCopyWith<ImportResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportResultCopyWith<$Res> {
  factory $ImportResultCopyWith(
          ImportResult value, $Res Function(ImportResult) then) =
      _$ImportResultCopyWithImpl<$Res, ImportResult>;
  @useResult
  $Res call(
      {List<Transaction> transactions,
      List<TransactionCategory> categories,
      List<Account> accounts,
      List<Budget> budgets,
      List<Goal> goals,
      List<ImportError> errors,
      ImportSummary summary});

  $ImportSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ImportResultCopyWithImpl<$Res, $Val extends ImportResult>
    implements $ImportResultCopyWith<$Res> {
  _$ImportResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactions = null,
    Object? categories = null,
    Object? accounts = null,
    Object? budgets = null,
    Object? goals = null,
    Object? errors = null,
    Object? summary = null,
  }) {
    return _then(_value.copyWith(
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<TransactionCategory>,
      accounts: null == accounts
          ? _value.accounts
          : accounts // ignore: cast_nullable_to_non_nullable
              as List<Account>,
      budgets: null == budgets
          ? _value.budgets
          : budgets // ignore: cast_nullable_to_non_nullable
              as List<Budget>,
      goals: null == goals
          ? _value.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<Goal>,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ImportError>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ImportSummary,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ImportSummaryCopyWith<$Res> get summary {
    return $ImportSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ImportResultImplCopyWith<$Res>
    implements $ImportResultCopyWith<$Res> {
  factory _$$ImportResultImplCopyWith(
          _$ImportResultImpl value, $Res Function(_$ImportResultImpl) then) =
      __$$ImportResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Transaction> transactions,
      List<TransactionCategory> categories,
      List<Account> accounts,
      List<Budget> budgets,
      List<Goal> goals,
      List<ImportError> errors,
      ImportSummary summary});

  @override
  $ImportSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ImportResultImplCopyWithImpl<$Res>
    extends _$ImportResultCopyWithImpl<$Res, _$ImportResultImpl>
    implements _$$ImportResultImplCopyWith<$Res> {
  __$$ImportResultImplCopyWithImpl(
      _$ImportResultImpl _value, $Res Function(_$ImportResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactions = null,
    Object? categories = null,
    Object? accounts = null,
    Object? budgets = null,
    Object? goals = null,
    Object? errors = null,
    Object? summary = null,
  }) {
    return _then(_$ImportResultImpl(
      transactions: null == transactions
          ? _value._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<TransactionCategory>,
      accounts: null == accounts
          ? _value._accounts
          : accounts // ignore: cast_nullable_to_non_nullable
              as List<Account>,
      budgets: null == budgets
          ? _value._budgets
          : budgets // ignore: cast_nullable_to_non_nullable
              as List<Budget>,
      goals: null == goals
          ? _value._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<Goal>,
      errors: null == errors
          ? _value._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ImportError>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ImportSummary,
    ));
  }
}

/// @nodoc

class _$ImportResultImpl extends _ImportResult {
  const _$ImportResultImpl(
      {required final List<Transaction> transactions,
      required final List<TransactionCategory> categories,
      required final List<Account> accounts,
      required final List<Budget> budgets,
      required final List<Goal> goals,
      required final List<ImportError> errors,
      required this.summary})
      : _transactions = transactions,
        _categories = categories,
        _accounts = accounts,
        _budgets = budgets,
        _goals = goals,
        _errors = errors,
        super._();

  final List<Transaction> _transactions;
  @override
  List<Transaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  final List<TransactionCategory> _categories;
  @override
  List<TransactionCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<Account> _accounts;
  @override
  List<Account> get accounts {
    if (_accounts is EqualUnmodifiableListView) return _accounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accounts);
  }

  final List<Budget> _budgets;
  @override
  List<Budget> get budgets {
    if (_budgets is EqualUnmodifiableListView) return _budgets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_budgets);
  }

  final List<Goal> _goals;
  @override
  List<Goal> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  final List<ImportError> _errors;
  @override
  List<ImportError> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  final ImportSummary summary;

  @override
  String toString() {
    return 'ImportResult(transactions: $transactions, categories: $categories, accounts: $accounts, budgets: $budgets, goals: $goals, errors: $errors, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportResultImpl &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._accounts, _accounts) &&
            const DeepCollectionEquality().equals(other._budgets, _budgets) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_transactions),
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_accounts),
      const DeepCollectionEquality().hash(_budgets),
      const DeepCollectionEquality().hash(_goals),
      const DeepCollectionEquality().hash(_errors),
      summary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportResultImplCopyWith<_$ImportResultImpl> get copyWith =>
      __$$ImportResultImplCopyWithImpl<_$ImportResultImpl>(this, _$identity);
}

abstract class _ImportResult extends ImportResult {
  const factory _ImportResult(
      {required final List<Transaction> transactions,
      required final List<TransactionCategory> categories,
      required final List<Account> accounts,
      required final List<Budget> budgets,
      required final List<Goal> goals,
      required final List<ImportError> errors,
      required final ImportSummary summary}) = _$ImportResultImpl;
  const _ImportResult._() : super._();

  @override
  List<Transaction> get transactions;
  @override
  List<TransactionCategory> get categories;
  @override
  List<Account> get accounts;
  @override
  List<Budget> get budgets;
  @override
  List<Goal> get goals;
  @override
  List<ImportError> get errors;
  @override
  ImportSummary get summary;
  @override
  @JsonKey(ignore: true)
  _$$ImportResultImplCopyWith<_$ImportResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ImportSummary {
  int get transactionsImported => throw _privateConstructorUsedError;
  int get categoriesImported => throw _privateConstructorUsedError;
  int get accountsImported => throw _privateConstructorUsedError;
  int get budgetsImported => throw _privateConstructorUsedError;
  int get goalsImported => throw _privateConstructorUsedError;
  int get transactionsSkipped => throw _privateConstructorUsedError;
  int get categoriesSkipped => throw _privateConstructorUsedError;
  int get accountsSkipped => throw _privateConstructorUsedError;
  int get budgetsSkipped => throw _privateConstructorUsedError;
  int get goalsSkipped => throw _privateConstructorUsedError;
  int get errors => throw _privateConstructorUsedError;
  int get warnings => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ImportSummaryCopyWith<ImportSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportSummaryCopyWith<$Res> {
  factory $ImportSummaryCopyWith(
          ImportSummary value, $Res Function(ImportSummary) then) =
      _$ImportSummaryCopyWithImpl<$Res, ImportSummary>;
  @useResult
  $Res call(
      {int transactionsImported,
      int categoriesImported,
      int accountsImported,
      int budgetsImported,
      int goalsImported,
      int transactionsSkipped,
      int categoriesSkipped,
      int accountsSkipped,
      int budgetsSkipped,
      int goalsSkipped,
      int errors,
      int warnings});
}

/// @nodoc
class _$ImportSummaryCopyWithImpl<$Res, $Val extends ImportSummary>
    implements $ImportSummaryCopyWith<$Res> {
  _$ImportSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionsImported = null,
    Object? categoriesImported = null,
    Object? accountsImported = null,
    Object? budgetsImported = null,
    Object? goalsImported = null,
    Object? transactionsSkipped = null,
    Object? categoriesSkipped = null,
    Object? accountsSkipped = null,
    Object? budgetsSkipped = null,
    Object? goalsSkipped = null,
    Object? errors = null,
    Object? warnings = null,
  }) {
    return _then(_value.copyWith(
      transactionsImported: null == transactionsImported
          ? _value.transactionsImported
          : transactionsImported // ignore: cast_nullable_to_non_nullable
              as int,
      categoriesImported: null == categoriesImported
          ? _value.categoriesImported
          : categoriesImported // ignore: cast_nullable_to_non_nullable
              as int,
      accountsImported: null == accountsImported
          ? _value.accountsImported
          : accountsImported // ignore: cast_nullable_to_non_nullable
              as int,
      budgetsImported: null == budgetsImported
          ? _value.budgetsImported
          : budgetsImported // ignore: cast_nullable_to_non_nullable
              as int,
      goalsImported: null == goalsImported
          ? _value.goalsImported
          : goalsImported // ignore: cast_nullable_to_non_nullable
              as int,
      transactionsSkipped: null == transactionsSkipped
          ? _value.transactionsSkipped
          : transactionsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      categoriesSkipped: null == categoriesSkipped
          ? _value.categoriesSkipped
          : categoriesSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      accountsSkipped: null == accountsSkipped
          ? _value.accountsSkipped
          : accountsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      budgetsSkipped: null == budgetsSkipped
          ? _value.budgetsSkipped
          : budgetsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      goalsSkipped: null == goalsSkipped
          ? _value.goalsSkipped
          : goalsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as int,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImportSummaryImplCopyWith<$Res>
    implements $ImportSummaryCopyWith<$Res> {
  factory _$$ImportSummaryImplCopyWith(
          _$ImportSummaryImpl value, $Res Function(_$ImportSummaryImpl) then) =
      __$$ImportSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int transactionsImported,
      int categoriesImported,
      int accountsImported,
      int budgetsImported,
      int goalsImported,
      int transactionsSkipped,
      int categoriesSkipped,
      int accountsSkipped,
      int budgetsSkipped,
      int goalsSkipped,
      int errors,
      int warnings});
}

/// @nodoc
class __$$ImportSummaryImplCopyWithImpl<$Res>
    extends _$ImportSummaryCopyWithImpl<$Res, _$ImportSummaryImpl>
    implements _$$ImportSummaryImplCopyWith<$Res> {
  __$$ImportSummaryImplCopyWithImpl(
      _$ImportSummaryImpl _value, $Res Function(_$ImportSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionsImported = null,
    Object? categoriesImported = null,
    Object? accountsImported = null,
    Object? budgetsImported = null,
    Object? goalsImported = null,
    Object? transactionsSkipped = null,
    Object? categoriesSkipped = null,
    Object? accountsSkipped = null,
    Object? budgetsSkipped = null,
    Object? goalsSkipped = null,
    Object? errors = null,
    Object? warnings = null,
  }) {
    return _then(_$ImportSummaryImpl(
      transactionsImported: null == transactionsImported
          ? _value.transactionsImported
          : transactionsImported // ignore: cast_nullable_to_non_nullable
              as int,
      categoriesImported: null == categoriesImported
          ? _value.categoriesImported
          : categoriesImported // ignore: cast_nullable_to_non_nullable
              as int,
      accountsImported: null == accountsImported
          ? _value.accountsImported
          : accountsImported // ignore: cast_nullable_to_non_nullable
              as int,
      budgetsImported: null == budgetsImported
          ? _value.budgetsImported
          : budgetsImported // ignore: cast_nullable_to_non_nullable
              as int,
      goalsImported: null == goalsImported
          ? _value.goalsImported
          : goalsImported // ignore: cast_nullable_to_non_nullable
              as int,
      transactionsSkipped: null == transactionsSkipped
          ? _value.transactionsSkipped
          : transactionsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      categoriesSkipped: null == categoriesSkipped
          ? _value.categoriesSkipped
          : categoriesSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      accountsSkipped: null == accountsSkipped
          ? _value.accountsSkipped
          : accountsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      budgetsSkipped: null == budgetsSkipped
          ? _value.budgetsSkipped
          : budgetsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      goalsSkipped: null == goalsSkipped
          ? _value.goalsSkipped
          : goalsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as int,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ImportSummaryImpl extends _ImportSummary {
  const _$ImportSummaryImpl(
      {this.transactionsImported = 0,
      this.categoriesImported = 0,
      this.accountsImported = 0,
      this.budgetsImported = 0,
      this.goalsImported = 0,
      this.transactionsSkipped = 0,
      this.categoriesSkipped = 0,
      this.accountsSkipped = 0,
      this.budgetsSkipped = 0,
      this.goalsSkipped = 0,
      this.errors = 0,
      this.warnings = 0})
      : super._();

  @override
  @JsonKey()
  final int transactionsImported;
  @override
  @JsonKey()
  final int categoriesImported;
  @override
  @JsonKey()
  final int accountsImported;
  @override
  @JsonKey()
  final int budgetsImported;
  @override
  @JsonKey()
  final int goalsImported;
  @override
  @JsonKey()
  final int transactionsSkipped;
  @override
  @JsonKey()
  final int categoriesSkipped;
  @override
  @JsonKey()
  final int accountsSkipped;
  @override
  @JsonKey()
  final int budgetsSkipped;
  @override
  @JsonKey()
  final int goalsSkipped;
  @override
  @JsonKey()
  final int errors;
  @override
  @JsonKey()
  final int warnings;

  @override
  String toString() {
    return 'ImportSummary(transactionsImported: $transactionsImported, categoriesImported: $categoriesImported, accountsImported: $accountsImported, budgetsImported: $budgetsImported, goalsImported: $goalsImported, transactionsSkipped: $transactionsSkipped, categoriesSkipped: $categoriesSkipped, accountsSkipped: $accountsSkipped, budgetsSkipped: $budgetsSkipped, goalsSkipped: $goalsSkipped, errors: $errors, warnings: $warnings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportSummaryImpl &&
            (identical(other.transactionsImported, transactionsImported) ||
                other.transactionsImported == transactionsImported) &&
            (identical(other.categoriesImported, categoriesImported) ||
                other.categoriesImported == categoriesImported) &&
            (identical(other.accountsImported, accountsImported) ||
                other.accountsImported == accountsImported) &&
            (identical(other.budgetsImported, budgetsImported) ||
                other.budgetsImported == budgetsImported) &&
            (identical(other.goalsImported, goalsImported) ||
                other.goalsImported == goalsImported) &&
            (identical(other.transactionsSkipped, transactionsSkipped) ||
                other.transactionsSkipped == transactionsSkipped) &&
            (identical(other.categoriesSkipped, categoriesSkipped) ||
                other.categoriesSkipped == categoriesSkipped) &&
            (identical(other.accountsSkipped, accountsSkipped) ||
                other.accountsSkipped == accountsSkipped) &&
            (identical(other.budgetsSkipped, budgetsSkipped) ||
                other.budgetsSkipped == budgetsSkipped) &&
            (identical(other.goalsSkipped, goalsSkipped) ||
                other.goalsSkipped == goalsSkipped) &&
            (identical(other.errors, errors) || other.errors == errors) &&
            (identical(other.warnings, warnings) ||
                other.warnings == warnings));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      transactionsImported,
      categoriesImported,
      accountsImported,
      budgetsImported,
      goalsImported,
      transactionsSkipped,
      categoriesSkipped,
      accountsSkipped,
      budgetsSkipped,
      goalsSkipped,
      errors,
      warnings);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportSummaryImplCopyWith<_$ImportSummaryImpl> get copyWith =>
      __$$ImportSummaryImplCopyWithImpl<_$ImportSummaryImpl>(this, _$identity);
}

abstract class _ImportSummary extends ImportSummary {
  const factory _ImportSummary(
      {final int transactionsImported,
      final int categoriesImported,
      final int accountsImported,
      final int budgetsImported,
      final int goalsImported,
      final int transactionsSkipped,
      final int categoriesSkipped,
      final int accountsSkipped,
      final int budgetsSkipped,
      final int goalsSkipped,
      final int errors,
      final int warnings}) = _$ImportSummaryImpl;
  const _ImportSummary._() : super._();

  @override
  int get transactionsImported;
  @override
  int get categoriesImported;
  @override
  int get accountsImported;
  @override
  int get budgetsImported;
  @override
  int get goalsImported;
  @override
  int get transactionsSkipped;
  @override
  int get categoriesSkipped;
  @override
  int get accountsSkipped;
  @override
  int get budgetsSkipped;
  @override
  int get goalsSkipped;
  @override
  int get errors;
  @override
  int get warnings;
  @override
  @JsonKey(ignore: true)
  _$$ImportSummaryImplCopyWith<_$ImportSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
