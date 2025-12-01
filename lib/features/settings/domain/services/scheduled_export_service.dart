import '../../../../core/utils/logger.dart';
import '../repositories/settings_repository.dart';
import 'background_export_service.dart';

/// Service for managing scheduled exports
class ScheduledExportService {
  final SettingsRepository _settingsRepository;
  final BackgroundExportService _backgroundExportService;

  ScheduledExportService({
    required SettingsRepository settingsRepository,
    required BackgroundExportService backgroundExportService,
  })  : _settingsRepository = settingsRepository,
        _backgroundExportService = backgroundExportService;

  /// Enable scheduled export with specified frequency and format
  Future<void> enableScheduledExport({
    required String frequency,
    required String format,
  }) async {
    try {
      Logger.log('Enabling scheduled export: $frequency, format: $format');

      // Update settings
      await _settingsRepository.updateSetting('scheduledExportEnabled', true);
      await _settingsRepository.updateSetting('scheduledExportFrequency', frequency);
      await _settingsRepository.updateSetting('defaultExportFormat', format);

      // Schedule the background task
      await _backgroundExportService.scheduleRecurringExport(
        frequency: frequency,
        format: format,
      );

      Logger.log('Scheduled export enabled successfully');
    } catch (e) {
      Logger.log('Failed to enable scheduled export: $e');
      rethrow;
    }
  }

  /// Disable scheduled export
  Future<void> disableScheduledExport() async {
    try {
      Logger.log('Disabling scheduled export');

      // Cancel the background task
      await _backgroundExportService.cancelScheduledExport();

      // Update settings
      await _settingsRepository.updateSetting('scheduledExportEnabled', false);

      Logger.log('Scheduled export disabled successfully');
    } catch (e) {
      Logger.log('Failed to disable scheduled export: $e');
      rethrow;
    }
  }

  /// Update scheduled export settings
  Future<void> updateScheduledExport({
    required String frequency,
    required String format,
  }) async {
    try {
      Logger.log('Updating scheduled export: $frequency, format: $format');

      // Cancel existing task
      await _backgroundExportService.cancelScheduledExport();

      // Update settings
      await _settingsRepository.updateSetting('scheduledExportFrequency', frequency);
      await _settingsRepository.updateSetting('defaultExportFormat', format);

      // Schedule new task
      await _backgroundExportService.scheduleRecurringExport(
        frequency: frequency,
        format: format,
      );

      Logger.log('Scheduled export updated successfully');
    } catch (e) {
      Logger.log('Failed to update scheduled export: $e');
      rethrow;
    }
  }

  /// Get current scheduled export status
  Future<Map<String, dynamic>> getScheduledExportStatus() async {
    try {
      final settingsResult = await _settingsRepository.getSettings();
      if (settingsResult.isError) {
        return {
          'isEnabled': false,
          'frequency': null,
          'format': null,
          'error': settingsResult.failureOrNull?.message,
        };
      }

      final settings = settingsResult.dataOrNull!;
      final backgroundStatus = await _backgroundExportService.getScheduledExportStatus();

      return {
        'isEnabled': settings.scheduledExportEnabled,
        'frequency': settings.scheduledExportFrequency,
        'format': settings.defaultExportFormat,
        'backgroundStatus': backgroundStatus,
      };
    } catch (e) {
      Logger.log('Failed to get scheduled export status: $e');
      return {
        'isEnabled': false,
        'frequency': null,
        'format': null,
        'error': e.toString(),
      };
    }
  }

  /// Check if scheduled export is currently enabled
  Future<bool> isScheduledExportEnabled() async {
    try {
      final status = await getScheduledExportStatus();
      return status['isEnabled'] as bool? ?? false;
    } catch (e) {
      Logger.log('Failed to check if scheduled export is enabled: $e');
      return false;
    }
  }

  /// Get available export frequencies
  List<Map<String, String>> getAvailableFrequencies() {
    return [
      {'value': 'daily', 'label': 'Daily'},
      {'value': 'weekly', 'label': 'Weekly'},
      {'value': 'monthly', 'label': 'Monthly'},
      {'value': 'quarterly', 'label': 'Quarterly'},
    ];
  }

  /// Get available export formats
  List<Map<String, String>> getAvailableFormats() {
    return [
      {'value': 'json', 'label': 'JSON'},
      {'value': 'csv', 'label': 'CSV'},
      {'value': 'pdf', 'label': 'PDF'},
    ];
  }

  /// Get display name for frequency
  String getFrequencyDisplayName(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      default:
        return 'Monthly';
    }
  }

  /// Get display name for format
  String getFormatDisplayName(String format) {
    switch (format.toLowerCase()) {
      case 'json':
        return 'JSON';
      case 'csv':
        return 'CSV';
      case 'pdf':
        return 'PDF';
      default:
        return 'JSON';
    }
  }
}