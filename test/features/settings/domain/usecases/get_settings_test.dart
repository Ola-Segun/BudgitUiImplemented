import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import 'package:budget_tracker/features/settings/domain/entities/settings.dart';
import 'package:budget_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:budget_tracker/features/settings/domain/usecases/get_settings.dart';

@GenerateMocks([SettingsRepository])
import 'get_settings_test.mocks.dart';

void main() {
  late GetSettings useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetSettings(mockRepository);

    // Provide dummy values for Mockito
    provideDummy<Result<AppSettings>>(Result.error(Failure.unknown('dummy')));
  });

  group('GetSettings Use Case', () {
    final testSettings = AppSettings(
      themeMode: ThemeMode.dark,
      currencyCode: 'EUR',
      dateFormat: 'dd/MM/yyyy',
      notificationsEnabled: false,
      budgetAlertsEnabled: true,
      billRemindersEnabled: true,
      incomeRemindersEnabled: true,
      budgetAlertThreshold: 85,
      billReminderDays: 5,
      incomeReminderDays: 1,
      biometricEnabled: true,
      autoBackupEnabled: false,
      languageCode: 'de',
      isFirstTime: false,
      appVersion: '1.1.0',
    );

    test('should return settings when repository succeeds', () async {
      // Arrange
      when(mockRepository.getSettings())
          .thenAnswer((_) async => Result.success(testSettings));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Success<AppSettings>>());
      result.when(
        success: (settings) {
          expect(settings, testSettings);
          expect(settings.themeMode, ThemeMode.dark);
          expect(settings.currencyCode, 'EUR');
        },
        error: (_) => fail('Should not fail'),
      );
      verify(mockRepository.getSettings()).called(1);
    });

    test('should return default settings when repository returns default', () async {
      // Arrange
      final defaultSettings = AppSettings.defaultSettings();
      when(mockRepository.getSettings())
          .thenAnswer((_) async => Result.success(defaultSettings));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Success<AppSettings>>());
      result.when(
        success: (settings) {
          expect(settings, defaultSettings);
          expect(settings.themeMode, ThemeMode.system);
          expect(settings.currencyCode, 'USD');
          expect(settings.isFirstTime, true);
        },
        error: (_) => fail('Should not fail'),
      );
    });

    test('should return cache failure when repository fails', () async {
      // Arrange
      when(mockRepository.getSettings())
          .thenAnswer((_) async => Result.error(Failure.cache('Database error')));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Error<AppSettings>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<CacheFailure>());
        },
      );
    });

    test('should handle repository exceptions', () async {
      // Arrange
      when(mockRepository.getSettings()).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Error<AppSettings>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<UnknownFailure>());
          expect(failure.message, contains('Failed to get settings'));
        },
      );
    });

    test('should handle repository exceptions properly', () async {
      // Arrange
      when(mockRepository.getSettings()).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Error<AppSettings>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        error: (failure) {
          expect(failure, isA<UnknownFailure>());
        },
      );
    });
  });
}