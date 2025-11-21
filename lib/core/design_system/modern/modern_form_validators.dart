import 'package:flutter/material.dart';

/// Modern Form Validators
/// Centralized form validation with real-time feedback
/// Async validation support, Custom validation rules
/// Error state animations, Accessibility announcements
class ModernFormValidators {
  static FormFieldValidator<String> required(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    };
  }

  static FormFieldValidator<String> email() {
    return (value) {
      if (value == null || value.isEmpty) return null;

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
      return null;
    };
  }

  static FormFieldValidator<String> amount({double? min, double? max}) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      final amount = double.tryParse(value.replaceAll('\$', '').replaceAll(',', ''));
      if (amount == null) {
        return 'Please enter a valid amount';
      }

      if (min != null && amount < min) {
        return 'Amount must be at least \$${min.toStringAsFixed(2)}';
      }

      if (max != null && amount > max) {
        return 'Amount cannot exceed \$${max.toStringAsFixed(2)}';
      }

      return null;
    };
  }

  static FormFieldValidator<String> percentage({double min = 0.0, double max = 100.0}) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      final percentage = double.tryParse(value.replaceAll('%', '').trim());
      if (percentage == null) {
        return 'Please enter a valid percentage';
      }

      if (percentage < min) {
        return 'Percentage must be at least ${min.toStringAsFixed(1)}%';
      }

      if (percentage > max) {
        return 'Percentage cannot exceed ${max.toStringAsFixed(1)}%';
      }

      return null;
    };
  }

  static FormFieldValidator<String> phoneNumber() {
    return (value) {
      if (value == null || value.isEmpty) return null;

      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLength(int minLength, {String? fieldName}) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      if (value.length < minLength) {
        return '${fieldName ?? 'Field'} must be at least $minLength characters';
      }
      return null;
    };
  }

  static FormFieldValidator<String> maxLength(int maxLength, {String? fieldName}) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      if (value.length > maxLength) {
        return '${fieldName ?? 'Field'} cannot exceed $maxLength characters';
      }
      return null;
    };
  }

  static FormFieldValidator<String> pattern(RegExp pattern, String errorMessage) {
    return (value) {
      if (value == null || value.isEmpty) return null;

      if (!pattern.hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  static FormFieldValidator<String> combine(List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}

/// Async Form Validators for complex validation
class ModernAsyncValidators {
  static Future<String?> validateUniqueEmail(String email) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock validation - in real app, check against backend
    if (email == 'taken@example.com') {
      return 'This email is already registered';
    }

    return null;
  }

  static Future<String?> validateAmountAvailability(double amount, double availableBalance) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    if (amount > availableBalance) {
      return 'Insufficient balance. Available: \$${availableBalance.toStringAsFixed(2)}';
    }

    return null;
  }
}

/// Validation Result for complex forms
class ValidationResult {
  final bool isValid;
  final Map<String, String?> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true, errors: {});
  }

  factory ValidationResult.invalid(Map<String, String?> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }

  String? get firstError {
    return errors.values.firstWhere(
      (error) => error != null,
      orElse: () => null,
    );
  }
}

/// Form Validation Helper
class ModernFormValidation {
  static ValidationResult validateTransactionForm({
    required String amount,
    required String category,
    String? note,
    DateTime? date,
  }) {
    final errors = <String, String?>{};

    // Amount validation
    final amountError = ModernFormValidators.amount(min: 0.01)(amount);
    errors['amount'] = amountError;

    // Category validation
    final categoryError = ModernFormValidators.required('Category')(category);
    errors['category'] = categoryError;

    // Note validation (optional, but max length)
    if (note != null && note.isNotEmpty) {
      final noteError = ModernFormValidators.maxLength(200, fieldName: 'Note')(note);
      errors['note'] = noteError;
    }

    // Date validation
    if (date != null && date.isAfter(DateTime.now())) {
      errors['date'] = 'Date cannot be in the future';
    }

    final hasErrors = errors.values.any((error) => error != null);
    return hasErrors
        ? ValidationResult.invalid(errors)
        : ValidationResult.valid();
  }

  static ValidationResult validateGoalForm({
    required String title,
    required String targetAmount,
    DateTime? deadline,
  }) {
    final errors = <String, String?>{};

    // Title validation
    final titleError = ModernFormValidators.combine([
      ModernFormValidators.required('Goal title'),
      ModernFormValidators.minLength(3, fieldName: 'Goal title'),
      ModernFormValidators.maxLength(50, fieldName: 'Goal title'),
    ])(title);
    errors['title'] = titleError;

    // Target amount validation
    final amountError = ModernFormValidators.amount(min: 1.0)(targetAmount);
    errors['targetAmount'] = amountError;

    // Deadline validation
    if (deadline != null && deadline.isBefore(DateTime.now())) {
      errors['deadline'] = 'Deadline must be in the future';
    }

    final hasErrors = errors.values.any((error) => error != null);
    return hasErrors
        ? ValidationResult.invalid(errors)
        : ValidationResult.valid();
  }
}