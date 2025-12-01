
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/settings_providers.dart';
import 'formatting_service.dart';

/// Service for managing privacy mode functionality
class PrivacyModeService {
  const PrivacyModeService(this._ref);

  final Ref _ref;

  /// Check if privacy mode is currently enabled
  bool get isPrivacyModeEnabled {
    final settings = _ref.read(currentSettingsProvider);
    return settings?.privacyModeEnabled ?? false;
  }

  /// Check if privacy gesture is enabled
  bool get isGestureEnabled {
    final settings = _ref.read(currentSettingsProvider);
    return settings?.privacyModeGestureEnabled ?? true;
  }

  /// Check if a three-finger double tap gesture should trigger privacy mode
  bool shouldTriggerPrivacyMode() {
    return isGestureEnabled;
  }

  /// Toggle privacy mode
  Future<void> togglePrivacyMode() async {
    final currentEnabled = isPrivacyModeEnabled;
    await _ref.read(settingsNotifierProvider.notifier).updateSetting('privacyModeEnabled', !currentEnabled);
  }

  /// Enable or disable privacy mode
  Future<void> setPrivacyMode(bool enabled) async {
    await _ref.read(settingsNotifierProvider.notifier).updateSetting('privacyModeEnabled', enabled);
  }

  /// Enable or disable privacy gesture
  Future<void> setGestureEnabled(bool enabled) async {
    await _ref.read(settingsNotifierProvider.notifier).updateSetting('privacyModeGestureEnabled', enabled);
  }

  /// Check if sensitive data should be obscured
  bool shouldObscureSensitiveData() {
    return isPrivacyModeEnabled;
  }

  /// Get obscured text representation
  String obscureText(String text) {
    if (!shouldObscureSensitiveData()) return text;
    return '•' * text.length;
  }

  /// Get obscured amount representation
  String obscureAmount(double amount, String currency) {
    if (!shouldObscureSensitiveData()) {
      // Use formatting service for proper currency formatting
      final formattingService = FormattingService(_ref);
      return formattingService.formatCurrency(amount, currencyCode: currency);
    }
    return '$currency••••••';
  }

  /// Temporarily reveal sensitive data
  Future<void> temporarilyReveal() async {
    if (!shouldObscureSensitiveData()) return;
    // Implementation for temporary reveal (e.g., for a few seconds)
    await Future.delayed(const Duration(seconds: 3));
  }
}