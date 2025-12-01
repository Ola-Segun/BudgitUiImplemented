import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_error.freezed.dart';

/// Error that occurred during import operation
@freezed
class ImportError with _$ImportError {
  const factory ImportError({
    required ImportErrorType type,
    required String message,
    required int lineNumber,
    String? field,
    String? value,
    String? suggestion,
  }) = _ImportError;

  const ImportError._();

  /// Create a validation error
  factory ImportError.validation({
    required String message,
    required int lineNumber,
    String? field,
    String? value,
    String? suggestion,
  }) => ImportError(
        type: ImportErrorType.validationError,
        message: message,
        lineNumber: lineNumber,
        field: field,
        value: value,
        suggestion: suggestion,
      );

  /// Create a parsing error
  factory ImportError.parsing({
    required String message,
    required int lineNumber,
    String? suggestion,
  }) => ImportError(
        type: ImportErrorType.parsingError,
        message: message,
        lineNumber: lineNumber,
        suggestion: suggestion,
      );

  /// Create a conflict error
  factory ImportError.conflict({
    required String message,
    required int lineNumber,
    String? field,
    String? existingValue,
    String? newValue,
    String? suggestion,
  }) => ImportError(
        type: ImportErrorType.conflictError,
        message: message,
        lineNumber: lineNumber,
        field: field,
        value: '$existingValue -> $newValue',
        suggestion: suggestion,
      );
}

/// Types of import errors
enum ImportErrorType {
  /// File format not supported
  unsupportedFormat,

  /// Error reading the file
  fileReadError,

  /// File is empty
  emptyFile,

  /// Error parsing file content
  parsingError,

  /// Data validation error
  validationError,

  /// Data conflict with existing data
  conflictError,

  /// Unknown data type in file
  unknownDataType,

  /// Missing required field
  missingRequiredField,

  /// Invalid data format
  invalidDataFormat,

  /// Duplicate data found
  duplicateData,

  /// Reference to non-existent data
  referenceError;

  /// Check if this error type is considered an error (not just warning)
  bool get isError => [
        unsupportedFormat,
        fileReadError,
        emptyFile,
        parsingError,
        validationError,
        conflictError,
        unknownDataType,
        missingRequiredField,
        invalidDataFormat,
        referenceError,
      ].contains(this);

  /// Check if this error type is considered a warning
  bool get isWarning => [
        duplicateData,
      ].contains(this);

  /// Get user-friendly description
  String get description {
    switch (this) {
      case unsupportedFormat:
        return 'Unsupported file format';
      case fileReadError:
        return 'File read error';
      case emptyFile:
        return 'Empty file';
      case parsingError:
        return 'Parsing error';
      case validationError:
        return 'Validation error';
      case conflictError:
        return 'Data conflict';
      case unknownDataType:
        return 'Unknown data type';
      case missingRequiredField:
        return 'Missing required field';
      case invalidDataFormat:
        return 'Invalid data format';
      case duplicateData:
        return 'Duplicate data';
      case referenceError:
        return 'Reference error';
    }
  }

  /// Get severity level
  int get severity {
    switch (this) {
      case unsupportedFormat:
      case fileReadError:
      case emptyFile:
        return 5; // Critical
      case parsingError:
      case unknownDataType:
        return 4; // High
      case validationError:
      case missingRequiredField:
      case invalidDataFormat:
      case referenceError:
        return 3; // Medium
      case conflictError:
        return 2; // Low
      case duplicateData:
        return 1; // Warning
    }
  }
}