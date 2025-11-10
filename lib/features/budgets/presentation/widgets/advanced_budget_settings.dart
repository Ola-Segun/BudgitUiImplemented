import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';

/// Advanced budget settings widget with rollover options, alerts, and sharing
class AdvancedBudgetSettings extends StatefulWidget {
  const AdvancedBudgetSettings({
    super.key,
    this.initialRolloverEnabled = false,
    this.initialAlertThreshold = 80.0,
    this.initialSharingEnabled = false,
    this.onSettingsChanged,
  });

  final bool initialRolloverEnabled;
  final double initialAlertThreshold;
  final bool initialSharingEnabled;
  final Function(BudgetAdvancedSettings)? onSettingsChanged;

  @override
  State<AdvancedBudgetSettings> createState() => _AdvancedBudgetSettingsState();
}

class _AdvancedBudgetSettingsState extends State<AdvancedBudgetSettings> {
  late bool _rolloverEnabled;
  late double _alertThreshold;
  late bool _sharingEnabled;
  late TextEditingController _thresholdController;

  @override
  void initState() {
    super.initState();
    _rolloverEnabled = widget.initialRolloverEnabled;
    _alertThreshold = widget.initialAlertThreshold;
    _sharingEnabled = widget.initialSharingEnabled;
    _thresholdController = TextEditingController(text: _alertThreshold.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Advanced Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Rollover Settings
          _buildRolloverSection(),

          const SizedBox(height: 24),

          // Alert Settings
          _buildAlertSection(),

          const SizedBox(height: 24),

          // Sharing Settings
          _buildSharingSection(),
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildRolloverSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.autorenew,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Budget Rollover',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Automatically carry over unused budget amounts to the next period.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Rollover',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      'Unused funds will be added to next month\'s budget',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _rolloverEnabled,
                onChanged: (value) {
                  setState(() => _rolloverEnabled = value);
                  _notifySettingsChanged();
                },
                activeThumbColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Spending Alerts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Get notified when you approach or exceed your budget limits.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),

          // Alert Threshold Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alert Threshold',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_alertThreshold.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.secondary,
                  inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  thumbColor: Theme.of(context).colorScheme.secondary,
                  overlayColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: _alertThreshold,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      _alertThreshold = value;
                      _thresholdController.text = value.toStringAsFixed(0);
                    });
                    _notifySettingsChanged();
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '50%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '100%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Alert Types
          Text(
            'Alert Types',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          _buildAlertTypeOption(
            'Budget threshold reached',
            'Notify when spending reaches the threshold percentage',
            Icons.warning,
            Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildAlertTypeOption(
            'Category limit exceeded',
            'Alert when any category exceeds its budget',
            Icons.error,
            Colors.red,
          ),
          const SizedBox(height: 8),
          _buildAlertTypeOption(
            'Daily spending spike',
            'Warn about unusually high daily spending',
            Icons.trending_up,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeOption(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: true, // TODO: Make this configurable
            onChanged: (value) {
              // TODO: Handle alert type toggle
            },
            activeThumbColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildSharingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.share,
                size: 20,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Budget Sharing',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Share your budget progress with family members or accountability partners.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Sharing',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      'Allow others to view your budget progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _sharingEnabled,
                onChanged: (value) {
                  setState(() => _sharingEnabled = value);
                  _notifySettingsChanged();
                },
                activeThumbColor: Theme.of(context).colorScheme.tertiary,
              ),
            ],
          ),

          if (_sharingEnabled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group_add,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Shared with 0 people',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement sharing functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Invite People'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        foregroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _notifySettingsChanged() {
    final settings = BudgetAdvancedSettings(
      rolloverEnabled: _rolloverEnabled,
      alertThreshold: _alertThreshold,
      sharingEnabled: _sharingEnabled,
    );
    widget.onSettingsChanged?.call(settings);
  }
}

/// Data class for advanced budget settings
class BudgetAdvancedSettings {
  const BudgetAdvancedSettings({
    required this.rolloverEnabled,
    required this.alertThreshold,
    required this.sharingEnabled,
  });

  final bool rolloverEnabled;
  final double alertThreshold;
  final bool sharingEnabled;

  BudgetAdvancedSettings copyWith({
    bool? rolloverEnabled,
    double? alertThreshold,
    bool? sharingEnabled,
  }) {
    return BudgetAdvancedSettings(
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      sharingEnabled: sharingEnabled ?? this.sharingEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rolloverEnabled': rolloverEnabled,
      'alertThreshold': alertThreshold,
      'sharingEnabled': sharingEnabled,
    };
  }

  factory BudgetAdvancedSettings.fromJson(Map<String, dynamic> json) {
    return BudgetAdvancedSettings(
      rolloverEnabled: json['rolloverEnabled'] ?? false,
      alertThreshold: (json['alertThreshold'] ?? 80.0).toDouble(),
      sharingEnabled: json['sharingEnabled'] ?? false,
    );
  }
}