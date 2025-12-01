import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/logger.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

/// Background export service using WorkManager for scheduled exports
class BackgroundExportService {
  static const String _exportTaskName = 'scheduled_data_export';
  static const String _exportFrequencyKey = 'export_frequency';
  static const String _exportFormatKey = 'export_format';

  final SettingsRepository _settingsRepository;

  BackgroundExportService({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  /// Initialize the background service
  static Future<void> initialize() async {
    // WorkManager is not supported on web, so skip initialization
    if (kIsWeb) {
      Logger.log('BackgroundExportService: Skipping WorkManager initialization on web platform');
      return;
    }

    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );
  }

  /// Callback dispatcher for WorkManager
  @pragma('vm:entry-point')
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        Logger.log('Background export task started: $task');

        final frequency = inputData?[_exportFrequencyKey] as String?;
        final format = inputData?[_exportFormatKey] as String?;

        if (frequency == null || format == null) {
          Logger.log('Missing required parameters for export task');
          return false;
        }

        // For background execution, we'll use a simplified approach
        // In a real app, you'd initialize proper repositories
        final success = await _performBackgroundExport(frequency, format);

        Logger.log('Background export task completed: $success');
        return success;
      } catch (e, stackTrace) {
        Logger.log('Background export task failed: $e\n$stackTrace');
        return false;
      }
    });
  }

  /// Perform background export (static method for WorkManager)
  static Future<bool> _performBackgroundExport(String frequency, String format) async {
    try {
      Logger.log('Performing background export: $frequency, format: $format');

      // For now, create a simple export file
      // In a real implementation, this would use the full data export service
      final exportData = '''
{
  "exportType": "scheduled",
  "frequency": "$frequency",
  "format": "$format",
  "exportedAt": "${DateTime.now().toIso8601String()}",
  "note": "This is a placeholder export. Full implementation needed."
}
''';

      final filePath = await _saveBackgroundExportToFile(exportData, format, frequency);
      Logger.log('Background export saved to: $filePath');

      return true;
    } catch (e, stackTrace) {
      Logger.log('Background export failed: $e\n$stackTrace');
      return false;
    }
  }

  /// Save background export to file (static method)
  static Future<String> _saveBackgroundExportToFile(
    String exportData,
    String format,
    String frequency,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final fileName = 'scheduled_export_${frequency}_$timestamp.$format';
      final filePath = '${directory.path}/exports/$fileName';

      // Ensure exports directory exists
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final file = File(filePath);
      await file.writeAsString(exportData);

      Logger.log('Background export saved to: $filePath');
      return filePath;
    } catch (e) {
      Logger.log('Failed to save background export file: $e');
      rethrow;
    }
  }

  /// Schedule recurring export based on frequency
  Future<void> scheduleRecurringExport({
    required String frequency,
    required String format,
  }) async {
    // WorkManager is not supported on web
    if (kIsWeb) {
      Logger.log('BackgroundExportService: Cannot schedule recurring export on web platform');
      return;
    }

    try {
      // Cancel any existing scheduled export
      await cancelScheduledExport();

      // Calculate next execution time based on frequency
      final nextExecution = _calculateNextExecutionTime(frequency);

      // Register the periodic task
      await Workmanager().registerPeriodicTask(
        _exportTaskName,
        _exportTaskName,
        frequency: _getWorkManagerFrequency(frequency),
        initialDelay: nextExecution.difference(DateTime.now()),
        inputData: {
          _exportFrequencyKey: frequency,
          _exportFormatKey: format,
        },
        constraints: Constraints(
          networkType: NetworkType.connected, // Require network for export
          requiresBatteryNotLow: true,
          requiresDeviceIdle: false,
          requiresStorageNotLow: true,
        ),
      );

      Logger.log('Scheduled recurring export: $frequency, next execution: $nextExecution');
    } catch (e) {
      Logger.log('Failed to schedule recurring export: $e');
      rethrow;
    }
  }

  /// Cancel scheduled export
  Future<void> cancelScheduledExport() async {
    // WorkManager is not supported on web
    if (kIsWeb) {
      Logger.log('BackgroundExportService: Cannot cancel scheduled export on web platform');
      return;
    }

    try {
      await Workmanager().cancelByUniqueName(_exportTaskName);
      Logger.log('Cancelled scheduled export');
    } catch (e) {
      Logger.log('Failed to cancel scheduled export: $e');
      rethrow;
    }
  }

  /// Perform the actual scheduled export
  Future<bool> _performScheduledExport({
    required String frequency,
    required String format,
  }) async {
    try {
      Logger.log('Performing scheduled export: $frequency, format: $format');

      // Use the settings repository export functionality
      final exportResult = await _settingsRepository.exportData(
        _parseExportFormat(format),
      );

      if (exportResult.isError) {
        Logger.log('Export failed: ${exportResult.failureOrNull}');
        return false;
      }

      final exportData = exportResult.dataOrNull!;
      if (exportData.isEmpty) {
        Logger.log('No data to export');
        return false;
      }

      // Save to file
      final filePath = await _saveExportToFile(exportData, format, frequency);

      // Handle the exported file
      await _handleExportedFile(filePath, format);

      Logger.log('Scheduled export completed successfully');
      return true;
    } catch (e, stackTrace) {
      Logger.log('Scheduled export failed: $e\n$stackTrace');
      return false;
    }
  }

  /// Calculate next execution time based on frequency
  DateTime _calculateNextExecutionTime(String frequency) {
    final now = DateTime.now();

    switch (frequency.toLowerCase()) {
      case 'daily':
        return DateTime(now.year, now.month, now.day + 1, 2, 0, 0); // 2 AM tomorrow

      case 'weekly':
        final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
        return DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 2, 0, 0);

      case 'monthly':
        final nextMonth = DateTime(now.year, now.month + 1, 1, 2, 0, 0);
        return nextMonth;

      case 'quarterly':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final nextQuarterStart = currentQuarter == 4
            ? DateTime(now.year + 1, 1, 1, 2, 0, 0)
            : DateTime(now.year, (currentQuarter * 3) + 1, 1, 2, 0, 0);
        return nextQuarterStart;

      default:
        return DateTime(now.year, now.month, now.day + 1, 2, 0, 0);
    }
  }

  /// Get WorkManager frequency based on our frequency string
  Duration _getWorkManagerFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return const Duration(days: 1);
      case 'weekly':
        return const Duration(days: 7);
      case 'monthly':
        return const Duration(days: 30);
      case 'quarterly':
        return const Duration(days: 90);
      default:
        return const Duration(days: 1);
    }
  }

  /// Parse export format string to enum
  DataExportType _parseExportFormat(String format) {
    switch (format.toLowerCase()) {
      case 'csv':
        return DataExportType.csv;
      case 'json':
        return DataExportType.json;
      case 'pdf':
        return DataExportType.pdf;
      default:
        return DataExportType.json;
    }
  }

  /// Save export data to file
  Future<String> _saveExportToFile(
    String exportData,
    String format,
    String frequency,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final fileName = 'budget_export_${frequency}_$timestamp.$format';
      final filePath = '${directory.path}/exports/$fileName';

      // Ensure exports directory exists
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final file = File(filePath);
      await file.writeAsString(exportData);

      Logger.log('Export saved to: $filePath');
      return filePath;
    } catch (e) {
      Logger.log('Failed to save export file: $e');
      rethrow;
    }
  }

  /// Handle the exported file (share or save)
  Future<void> _handleExportedFile(String filePath, String format) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        // For background execution, we'll just log the file location
        // In a real app, you might want to upload to cloud storage
        // or send via email based on user preferences
        Logger.log('Export file ready: $filePath');

        // You could add logic here to:
        // - Upload to cloud storage (Google Drive, Dropbox, etc.)
        // - Send via email
        // - Save to external storage
      }
    } catch (e) {
      Logger.log('Failed to handle exported file: $e');
    }
  }

  /// Get scheduled export status
  Future<Map<String, dynamic>> getScheduledExportStatus() async {
    try {
      // For now, return a simplified status
      // In a real implementation, you might store this in shared preferences
      // or use WorkManager's query capabilities if available
      return {
        'isScheduled': false, // TODO: Implement proper status checking
        'nextExecution': null,
        'frequency': null,
        'format': null,
        'note': 'Status checking not yet implemented',
      };
    } catch (e) {
      Logger.log('Failed to get scheduled export status: $e');
      return {
        'isScheduled': false,
        'nextExecution': null,
        'frequency': null,
        'format': null,
      };
    }
  }
}