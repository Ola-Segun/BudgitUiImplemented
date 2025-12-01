import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_settings.dart';
import '../states/notification_settings_state.dart';

class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettingsState>> {
  NotificationSettingsNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // TODO: Load settings from repository
      // For now, use default settings
      state = AsyncValue.data(NotificationSettingsState.initial());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    state = state.whenData((currentState) => currentState.copyWith(settings: newSettings));

    try {
      // TODO: Save settings to repository
      // For now, just update in memory
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetToDefaults() async {
    final defaultSettings = NotificationSettingsState.initial().settings;
    await updateSettings(defaultSettings);
  }
}