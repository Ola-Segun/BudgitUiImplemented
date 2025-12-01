import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/components/enhanced_switch_field.dart';
import '../providers/notification_providers.dart';
import '../../domain/entities/notification_settings.dart';

/// Simplified notification settings screen
class MinimalNotificationSettingsScreen extends ConsumerWidget {
  const MinimalNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(notificationSettingsNotifierProvider);

    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: AppBar(
        backgroundColor: ColorTokens.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notification Settings',
          style: TypographyTokens.heading4.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: settingsState.when(
        data: (state) => _buildSettings(context, ref, state.settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading settings: $error'),
        ),
      ),
    );
  }

  Widget _buildSettings(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return ListView(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      children: [
        // Master Toggle
        _buildSection(
          'General',
          [
            EnhancedSwitchField(
              title: 'Enable Notifications',
              subtitle: 'Receive alerts for important events',
              value: settings.notificationsEnabled,
              onChanged: (value) {
                ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                  settings.copyWith(notificationsEnabled: value),
                );
              },
              icon: Icons.notifications,
              iconColor: ColorTokens.teal500,
            ),
          ],
        ),

        SizedBox(height: DesignTokens.sectionGapLg),

        // Type-specific settings (only show if notifications enabled)
        if (settings.notificationsEnabled) ...[
          _buildSection(
            'Notification Types',
            [
              EnhancedSwitchField(
                title: 'Budget Alerts',
                subtitle: 'Budget limits and spending warnings',
                value: settings.budgetAlertsEnabled,
                onChanged: (value) {
                  ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                    settings.copyWith(budgetAlertsEnabled: value),
                  );
                },
                icon: Icons.account_balance_wallet,
                iconColor: const Color(0xFFF59E0B),
              ),
              SizedBox(height: DesignTokens.spacing3),
              EnhancedSwitchField(
                title: 'Bill Reminders',
                subtitle: 'Upcoming and overdue bills',
                value: settings.billRemindersEnabled,
                onChanged: (value) {
                  ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                    settings.copyWith(billRemindersEnabled: value),
                  );
                },
                icon: Icons.receipt_long,
                iconColor: const Color(0xFF3B82F6),
              ),
              SizedBox(height: DesignTokens.spacing3),
              EnhancedSwitchField(
                title: 'Income Reminders',
                subtitle: 'Expected income notifications',
                value: settings.incomeRemindersEnabled,
                onChanged: (value) {
                  ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                    settings.copyWith(incomeRemindersEnabled: value),
                  );
                },
                icon: Icons.trending_up,
                iconColor: const Color(0xFF10B981),
              ),
            ],
          ),

          SizedBox(height: DesignTokens.sectionGapLg),

          // Quiet Hours
          _buildSection(
            'Quiet Hours',
            [
              EnhancedSwitchField(
                title: 'Enable Quiet Hours',
                subtitle: 'Silence notifications during specific times',
                value: settings.quietHoursEnabled,
                onChanged: (value) {
                  ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                    settings.copyWith(quietHoursEnabled: value),
                  );
                },
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF6366F1),
              ),

              if (settings.quietHoursEnabled) ...[
                SizedBox(height: DesignTokens.spacing3),
                _buildQuietHoursTime(context, ref, settings),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: DesignTokens.spacing2,
            bottom: DesignTokens.spacing2,
          ),
          child: Text(
            title,
            style: TypographyTokens.labelMd.copyWith(
              color: ColorTokens.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildQuietHoursTime(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorTokens.borderPrimary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeButton(
              context,
              'Start',
              settings.quietHoursStart,
              (time) {
                ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                  settings.copyWith(quietHoursStart: time),
                );
              },
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Icon(
            Icons.arrow_forward,
            size: 20,
            color: ColorTokens.textTertiary,
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: _buildTimeButton(
              context,
              'End',
              settings.quietHoursEnd,
              (time) {
                ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                  settings.copyWith(quietHoursEnd: time),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(
    BuildContext context,
    String label,
    String time,
    ValueChanged<String> onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TypographyTokens.captionSm.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              final timeOfDay = await showTimePicker(
                context: context,
                initialTime: _parseTime(time),
              );
              if (timeOfDay != null) {
                onTimeSelected(_formatTime(timeOfDay));
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing3,
                vertical: DesignTokens.spacing2,
              ),
              decoration: BoxDecoration(
                color: ColorTokens.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDisplayTime(time),
                    style: TypographyTokens.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: ColorTokens.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Handle parsing error
    }
    return const TimeOfDay(hour: 22, minute: 0);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDisplayTime(String timeString) {
    try {
      final time = _parseTime(timeString);
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timeString;
    }
  }
}