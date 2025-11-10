import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import 'package:budget_tracker/features/accounts/domain/entities/account.dart';
import 'package:budget_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:budget_tracker/features/accounts/domain/usecases/create_account.dart';

import 'create_account_test.mocks.dart';

@GenerateMocks([AccountRepository])

void main() {
  late CreateAccount useCase;
  late MockAccountRepository mockRepository;

  setUp(() {
    mockRepository = MockAccountRepository();
    useCase = CreateAccount(mockRepository);
  });

  setUpAll(() {
    provideDummy<Result<Account>>(Result.error(Failure.unknown('Dummy error')));
  });

  group('CreateAccount Use Case', () {
    final testAccount = Account(
      id: 'test-id',
      name: 'Test Account',
      type: AccountType.bankAccount,
      balance: 1000.0,
      description: 'Test description',
      institution: 'Test Bank',
      currency: null,
    );

    test('should create account successfully', () async {
      // Arrange
      when(mockRepository.add(any))
          .thenAnswer((invocation) async => Result.success(invocation.positionalArguments[0] as Account));

      // Act
      final result = await useCase(testAccount);

      // Assert
      expect(result, isA<Success<Account>>());
      result.when(
        success: (account) {
          expect(account.name, testAccount.name);
          expect(account.type, testAccount.type);
          expect(account.balance, testAccount.balance);
          expect(account.createdAt, isNotNull);
          expect(account.updatedAt, isNotNull);
        },
        error: (_) => fail('Should not error'),
      );
      verify(mockRepository.add(any)).called(1);
    });

    test('should return validation error for empty name', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(name: '');

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('name'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should return validation error for NaN balance', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(balance: double.nan);

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('balance'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should return validation error for infinite balance', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(balance: double.infinity);

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('balance'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should return validation error for credit card without credit limit', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(
        type: AccountType.creditCard,
        creditLimit: null,
      );

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Credit limit'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should return validation error for credit card with zero credit limit', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(
        type: AccountType.creditCard,
        creditLimit: 0,
      );

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Credit limit'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should return validation error for credit card balance exceeding limit', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 6000.0,
        creditLimit: 5000.0,
      );

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('exceed'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should return validation error for invalid interest rate on loan', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(
        type: AccountType.loan,
        interestRate: 150.0, // Over 100%
      );

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Interest rate'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should return validation error for negative interest rate on loan', () async {
      // Arrange
      final invalidAccount = testAccount.copyWith(
        type: AccountType.loan,
        interestRate: -5.0,
      );

      // Act
      final result = await useCase(invalidAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Interest rate'));
        },
      );
      verifyNever(mockRepository.add(any));
    });

    test('should handle repository failure', () async {
      // Arrange
      when(mockRepository.add(any))
          .thenAnswer((_) async => Result.error(Failure.cache('Database error')));

      // Act
      final result = await useCase(testAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<CacheFailure>());
        },
      );
    });

    test('should handle unknown errors', () async {
      // Arrange
      when(mockRepository.add(any))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(testAccount);

      // Assert
      expect(result, isA<Error<Account>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<UnknownFailure>());
        },
      );
    });

    test('should accept valid credit card account', () async {
      // Arrange
      final creditCard = testAccount.copyWith(
        type: AccountType.creditCard,
        balance: 1000.0,
        creditLimit: 5000.0,
      );
      when(mockRepository.add(any))
          .thenAnswer((invocation) async => Result.success(invocation.positionalArguments[0] as Account));

      // Act
      final result = await useCase(creditCard);

      // Assert
      expect(result, isA<Success<Account>>());
      verify(mockRepository.add(any)).called(1);
    });

    test('should accept valid loan account', () async {
      // Arrange
      final loan = testAccount.copyWith(
        type: AccountType.loan,
        balance: 10000.0,
        interestRate: 5.5,
        minimumPayment: 200.0,
      );
      when(mockRepository.add(any))
          .thenAnswer((invocation) async => Result.success(invocation.positionalArguments[0] as Account));

      // Act
      final result = await useCase(loan);

      // Assert
      expect(result, isA<Success<Account>>());
      verify(mockRepository.add(any)).called(1);
    });

    test('should accept account with all optional fields', () async {
      // Arrange
      final detailedAccount = testAccount.copyWith(
        description: 'Detailed account',
        institution: 'Bank Corp',
        accountNumber: '123456789',
        currency: 'EUR',
        creditLimit: 10000.0,
        availableCredit: 9000.0,
        interestRate: 3.5,
        minimumPayment: 100.0,
        dueDate: DateTime(2025, 11, 1),
        isActive: false,
      );
      when(mockRepository.add(any))
          .thenAnswer((invocation) async => Result.success(invocation.positionalArguments[0] as Account));

      // Act
      final result = await useCase(detailedAccount);

      // Assert
      expect(result, isA<Success<Account>>());
      verify(mockRepository.add(any)).called(1);
    });
  });
}