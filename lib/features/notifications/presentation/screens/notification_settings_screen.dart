import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/notification_analytics.dart';
import '../providers/notification_providers.dart';

@Deprecated('Use MinimalNotificationSettingsScreen instead')
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsStateAsync = ref.watch(notificationSettingsNotifierProvider);

    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: AppBar(
        backgroundColor: ColorTokens.surfacePrimary,
        elevation: 0,
        title: Text(
          'Notification Settings',
          style: TypographyTokens.heading3,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorTokens.teal500,
          unselectedLabelColor: ColorTokens.textSecondary,
          labelStyle: TypographyTokens.labelMd.copyWith(
            fontWeight: TypographyTokens.weightBold,
          ),
          unselectedLabelStyle: TypographyTokens.labelMd,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: ColorTokens.teal500,
              width: 3,
            ),
            insets: EdgeInsets.symmetric(horizontal: DesignTokens.spacing6),
          ),
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Channels'),
          ],
        ),
      ),
      body: settingsStateAsync.when(
        data: (settingsState) => TabBarView(
          controller: _tabController,
          children: [
            _GeneralSettingsTab(settings: settingsState.settings),
            _ChannelSettingsTab(settings: settingsState.settings),
          ],
        ),
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(notificationSettingsNotifierProvider),
        ),
      ),
    );
  }
}

class _GeneralSettingsTab extends ConsumerWidget {
  const _GeneralSettingsTab({required this.settings});

  final NotificationSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master toggle
          _SettingsSection(
            title: 'General',
            children: [
              _MasterNotificationToggle(settings: settings),
              const SizedBox(height: 16),
              _QuietHoursSection(settings: settings),
              const SizedBox(height: 16),
              _GlobalFrequencySelector(settings: settings),
            ],
          ),

          const SizedBox(height: 24),

          // Quick toggles
          _SettingsSection(
            title: 'Notification Types',
            children: [
              _NotificationTypeToggle(
                title: 'Budget Alerts',
                subtitle: 'Get notified about budget limits and spending',
                value: settings.budgetAlertsEnabled,
                onChanged: (value) => _updateSettings(
                  ref,
                  settings.copyWith(budgetAlertsEnabled: value),
                ),
              ),
              _NotificationTypeToggle(
                title: 'Bill Reminders',
                subtitle: 'Reminders for upcoming and overdue bills',
                value: settings.billRemindersEnabled,
                onChanged: (value) => _updateSettings(
                  ref,
                  settings.copyWith(billRemindersEnabled: value),
                ),
              ),
              _NotificationTypeToggle(
                title: 'Income Reminders',
                subtitle: 'Reminders for expected income',
                value: settings.incomeRemindersEnabled,
                onChanged: (value) => _updateSettings(
                  ref,
                  settings.copyWith(incomeRemindersEnabled: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateSettings(WidgetRef ref, NotificationSettings newSettings) {
    ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(newSettings);
  }
}

class _ChannelSettingsTab extends ConsumerWidget {
  const _ChannelSettingsTab({required this.settings});

  final NotificationSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: NotificationChannel.values.map((channel) {
          final channelSettings = settings.channelSettings[channel] ??
              ChannelNotificationSettings(
                enabled: true,
                frequency: 'immediate',
                soundEnabled: true,
                vibrationEnabled: true,
              );

          return Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.spacing4),
            child: _ChannelSettingsCard(
              channel: channel,
              channelSettings: channelSettings,
              onSettingsChanged: (newChannelSettings) {
                final updatedChannelSettings = Map<NotificationChannel, ChannelNotificationSettings>.from(
                  settings.channelSettings,
                );
                updatedChannelSettings[channel] = newChannelSettings;

                ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                  settings.copyWith(channelSettings: updatedChannelSettings),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MasterNotificationToggle extends ConsumerWidget {
  const _MasterNotificationToggle({required this.settings});

  final NotificationSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: settings.notificationsEnabled
            ? ColorTokens.withOpacity(ColorTokens.success500, 0.1)
            : ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: settings.notificationsEnabled
              ? ColorTokens.success500
              : ColorTokens.neutral300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            settings.notificationsEnabled
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: settings.notificationsEnabled
                ? ColorTokens.success500
                : ColorTokens.neutral500,
            size: DesignTokens.iconMd,
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: TypographyTokens.bodyLg.copyWith(
                    fontWeight: TypographyTokens.weightSemiBold,
                  ),
                ),
                Text(
                  'Receive notifications for important events',
                  style: TypographyTokens.captionMd.copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: settings.notificationsEnabled,
            onChanged: (value) => ref
                .read(notificationSettingsNotifierProvider.notifier)
                .updateSettings(settings.copyWith(notificationsEnabled: value)),
            activeColor: ColorTokens.teal500,
          ),
        ],
      ),
    );
  }
}

class _QuietHoursSection extends ConsumerWidget {
  const _QuietHoursSection({required this.settings});

  final NotificationSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.nightlight,
              color: ColorTokens.teal500,
              size: DesignTokens.iconMd,
            ),
            SizedBox(width: DesignTokens.spacing2),
            Text(
              'Quiet Hours',
              style: TypographyTokens.bodyLg.copyWith(
                fontWeight: TypographyTokens.weightSemiBold,
              ),
            ),
            const Spacer(),
            Switch(
              value: settings.quietHoursEnabled,
              onChanged: (value) => ref
                  .read(notificationSettingsNotifierProvider.notifier)
                  .updateSettings(settings.copyWith(quietHoursEnabled: value)),
              activeColor: ColorTokens.teal500,
            ),
          ],
        ),
        if (settings.quietHoursEnabled) ...[
          SizedBox(height: DesignTokens.spacing3),
          Row(
            children: [
              Expanded(
                child: _TimePickerField(
                  label: 'Start Time',
                  time: settings.quietHoursStart,
                  onTimeChanged: (time) => ref
                      .read(notificationSettingsNotifierProvider.notifier)
                      .updateSettings(settings.copyWith(quietHoursStart: time)),
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: _TimePickerField(
                  label: 'End Time',
                  time: settings.quietHoursEnd,
                  onTimeChanged: (time) => ref
                      .read(notificationSettingsNotifierProvider.notifier)
                      .updateSettings(settings.copyWith(quietHoursEnd: time)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GlobalFrequencySelector extends ConsumerWidget {
  const _GlobalFrequencySelector({required this.settings});

  final NotificationSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Frequency',
          style: TypographyTokens.bodyLg.copyWith(
            fontWeight: TypographyTokens.weightSemiBold,
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Wrap(
          spacing: DesignTokens.spacing2,
          runSpacing: DesignTokens.spacing2,
          children: ['immediate', 'hourly', 'daily', 'weekly'].map((frequency) {
            final isSelected = settings.notificationFrequency == frequency;
            return ChoiceChip(
              label: Text(_formatFrequency(frequency)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(notificationSettingsNotifierProvider.notifier).updateSettings(
                        settings.copyWith(notificationFrequency: frequency),
                      );
                }
              },
              selectedColor: ColorTokens.teal500,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatFrequency(String frequency) {
    switch (frequency) {
      case 'immediate':
        return 'Immediate';
      case 'hourly':
        return 'Hourly';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      default:
        return frequency;
    }
  }
}

class _NotificationTypeToggle extends StatelessWidget {
  const _NotificationTypeToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: TypographyTokens.bodyMd),
      subtitle: Text(subtitle, style: TypographyTokens.captionMd),
      value: value,
      onChanged: onChanged,
      activeColor: ColorTokens.teal500,
    );
  }
}

class _ChannelSettingsCard extends StatefulWidget {
  const _ChannelSettingsCard({
    required this.channel,
    required this.channelSettings,
    required this.onSettingsChanged,
  });

  final NotificationChannel channel;
  final ChannelNotificationSettings channelSettings;
  final ValueChanged<ChannelNotificationSettings> onSettingsChanged;

  @override
  State<_ChannelSettingsCard> createState() => _ChannelSettingsCardState();
}

class _ChannelSettingsCardState extends State<_ChannelSettingsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * _animation.value),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              padding: EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                color: ColorTokens.surfacePrimary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: ColorTokens.neutral300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getChannelIcon(widget.channel),
                        color: _getChannelColor(widget.channel),
                        size: DesignTokens.iconMd,
                      ),
                      SizedBox(width: DesignTokens.spacing2),
                      Text(
                        _getChannelName(widget.channel),
                        style: TypographyTokens.bodyLg.copyWith(
                          fontWeight: TypographyTokens.weightSemiBold,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: widget.channelSettings.enabled,
                        onChanged: (value) {
                          widget.onSettingsChanged(
                            widget.channelSettings.copyWith(enabled: value),
                          );
                        },
                        activeColor: ColorTokens.teal500,
                      ),
                    ],
                  ),
                  if (widget.channelSettings.enabled) ...[
                    SizedBox(height: DesignTokens.spacing3),
                    _ChannelControls(
                      channelSettings: widget.channelSettings,
                      onSettingsChanged: widget.onSettingsChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getChannelIcon(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.budget:
        return Icons.account_balance_wallet;
      case NotificationChannel.bills:
        return Icons.receipt_long;
      case NotificationChannel.goals:
        return Icons.flag;
      case NotificationChannel.accounts:
        return Icons.account_balance;
      case NotificationChannel.system:
        return Icons.settings;
    }
  }

  Color _getChannelColor(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.budget:
        return ColorTokens.warning500;
      case NotificationChannel.bills:
        return ColorTokens.info500;
      case NotificationChannel.goals:
        return ColorTokens.success500;
      case NotificationChannel.accounts:
        return ColorTokens.critical500;
      case NotificationChannel.system:
        return ColorTokens.purple600;
    }
  }

  String _getChannelName(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.budget:
        return 'Budget';
      case NotificationChannel.bills:
        return 'Bills & Income';
      case NotificationChannel.goals:
        return 'Goals';
      case NotificationChannel.accounts:
        return 'Accounts';
      case NotificationChannel.system:
        return 'System';
    }
  }
}

class _ChannelControls extends StatelessWidget {
  const _ChannelControls({
    required this.channelSettings,
    required this.onSettingsChanged,
  });

  final ChannelNotificationSettings channelSettings;
  final ValueChanged<ChannelNotificationSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Frequency selector
        Row(
          children: [
            Text(
              'Frequency:',
              style: TypographyTokens.bodyMd.copyWith(
                fontWeight: TypographyTokens.weightMedium,
              ),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: channelSettings.frequency,
              items: ['immediate', 'hourly', 'daily', 'weekly']
                  .map((frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(_formatFrequency(frequency)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onSettingsChanged(
                    channelSettings.copyWith(frequency: value),
                  );
                }
              },
              underline: Container(),
              style: TypographyTokens.bodyMd,
            ),
          ],
        ),
        SizedBox(height: DesignTokens.spacing2),

        // Sound and vibration toggles
        Row(
          children: [
            Expanded(
              child: _ControlToggle(
                icon: Icons.volume_up,
                label: 'Sound',
                value: channelSettings.soundEnabled,
                onChanged: (value) => onSettingsChanged(
                  channelSettings.copyWith(soundEnabled: value),
                ),
              ),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(
              child: _ControlToggle(
                icon: Icons.vibration,
                label: 'Vibration',
                value: channelSettings.vibrationEnabled,
                onChanged: (value) => onSettingsChanged(
                  channelSettings.copyWith(vibrationEnabled: value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatFrequency(String frequency) {
    switch (frequency) {
      case 'immediate':
        return 'Immediate';
      case 'hourly':
        return 'Hourly';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      default:
        return frequency;
    }
  }
}

class _ControlToggle extends StatelessWidget {
  const _ControlToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing2,
          vertical: DesignTokens.spacing1,
        ),
        decoration: BoxDecoration(
          color: value
              ? ColorTokens.withOpacity(ColorTokens.teal500, 0.1)
              : ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          border: Border.all(
            color: value ? ColorTokens.teal500 : ColorTokens.neutral300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: DesignTokens.iconSm,
              color: value ? ColorTokens.teal500 : ColorTokens.neutral500,
            ),
            SizedBox(width: DesignTokens.spacing1),
            Text(
              label,
              style: TypographyTokens.captionMd.copyWith(
                color: value ? ColorTokens.teal500 : ColorTokens.textSecondary,
                fontWeight: value ? TypographyTokens.weightMedium : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onTimeChanged,
  });

  final String label;
  final String time;
  final ValueChanged<String> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        InkWell(
          onTap: () async {
            final timeOfDay = await showTimePicker(
              context: context,
              initialTime: _parseTime(time),
            );
            if (timeOfDay != null) {
              onTimeChanged(_formatTime(timeOfDay));
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing2,
              vertical: DesignTokens.spacing2,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: ColorTokens.neutral300),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: DesignTokens.iconSm,
                  color: ColorTokens.teal500,
                ),
                SizedBox(width: DesignTokens.spacing1),
                Text(
                  _formatDisplayTime(time),
                  style: TypographyTokens.bodyMd,
                ),
              ],
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
    return const TimeOfDay(hour: 22, minute: 0); // Default to 10 PM
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TypographyTokens.heading4.copyWith(
            color: ColorTokens.teal500,
          ),
        ),
        SizedBox(height: DesignTokens.spacing3),
        ...children,
      ],
    );
  }
}