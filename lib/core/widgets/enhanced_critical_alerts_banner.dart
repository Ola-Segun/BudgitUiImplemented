// lib/core/widgets/enhanced_critical_alerts_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extended.dart';
import '../theme/app_typography_extended.dart';
import '../theme/app_dimensions.dart';

/// Enhanced critical alerts banner with modern design and dismissable feature
class EnhancedCriticalAlertsBanner extends ConsumerStatefulWidget {
  const EnhancedCriticalAlertsBanner({super.key});

  @override
  ConsumerState<EnhancedCriticalAlertsBanner> createState() => _EnhancedCriticalAlertsBannerState();
}

class _EnhancedCriticalAlertsBannerState extends ConsumerState<EnhancedCriticalAlertsBanner> {
  final Set<String> _dismissedAlerts = {};
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDismissedAlerts();
  }

  Future<void> _loadDismissedAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getStringList('dismissed_critical_alerts') ?? [];
      if (mounted) {
        setState(() {
          _dismissedAlerts.addAll(dismissed);
        });
      }
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> _dismissAlert(String alertId) async {
    HapticFeedback.lightImpact();
    setState(() {
      _dismissedAlerts.add(alertId);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('dismissed_critical_alerts', _dismissedAlerts.toList());
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> _dismissAll(List<AppNotification> alerts) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _dismissedAlerts.addAll(alerts.map((a) => a.id));
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('dismissed_critical_alerts', _dismissedAlerts.toList());
    } catch (e) {
      // Fail silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(currentNotificationsProvider);

    return notificationsAsync.when(
      data: (notifications) {
        final criticalAlerts = _getCriticalAlerts(notifications)
            .where((alert) => !_dismissedAlerts.contains(alert.id))
            .toList();

        if (criticalAlerts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.spacing2,
          ),
          child: _buildAlertCard(criticalAlerts),
        ).animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: -0.2, duration: 400.ms, curve: Curves.easeOutCubic);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAlertCard(List<AppNotification> alerts) {
    final primaryAlert = alerts.first;
    final alertColor = _getAlertColor(primaryAlert.priority);
    final hasMultiple = alerts.length > 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            alertColor.withValues(alpha: 0.08),
            alertColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasMultiple
              ? () {
                  HapticFeedback.selectionClick();
                  setState(() => _isExpanded = !_isExpanded);
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary Alert Row
                Row(
                  children: [
                    // Alert Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            alertColor.withValues(alpha: 0.2),
                            alertColor.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: alertColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getPriorityIcon(primaryAlert.priority),
                        color: alertColor,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing3),

                    // Alert Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  primaryAlert.title,
                                  style: AppTypographyExtended.metricLabel.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasMultiple) ...[
                                SizedBox(width: AppDimensions.spacing1),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: alertColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${alerts.length - 1}',
                                    style: AppTypographyExtended.metricLabel.copyWith(
                                      color: alertColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (primaryAlert.message.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              primaryAlert.message,
                              style: AppTypographyExtended.metricLabel.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.3,
                              ),
                              maxLines: _isExpanded ? null : 1,
                              overflow: _isExpanded ? null : TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacing2),

                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasMultiple)
                          _ActionButton(
                            icon: _isExpanded 
                                ? Icons.keyboard_arrow_up 
                                : Icons.keyboard_arrow_down,
                            color: alertColor,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _isExpanded = !_isExpanded);
                            },
                            tooltip: _isExpanded ? 'Collapse' : 'Expand',
                          ),
                        if (hasMultiple) const SizedBox(width: 4),
                        _ActionButton(
                          icon: Icons.close,
                          color: alertColor,
                          onPressed: () => _dismissAlert(primaryAlert.id),
                          tooltip: 'Dismiss',
                        ),
                      ],
                    ),
                  ],
                ),

                // Expanded Alerts (if multiple)
                if (_isExpanded && hasMultiple) ...[
                  SizedBox(height: AppDimensions.spacing2),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          alertColor.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing2),
                  ...alerts.skip(1).map((alert) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildAdditionalAlert(alert, alertColor),
                      )),
                  SizedBox(height: AppDimensions.spacing2),
                  _buildDismissAllButton(alerts, alertColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalAlert(AppNotification alert, Color alertColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getPriorityIcon(alert.priority),
            color: alertColor,
            size: 14,
          ),
          SizedBox(width: AppDimensions.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  alert.title,
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (alert.message.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: AppTypographyExtended.metricLabel.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spacing2),
          _ActionButton(
            icon: Icons.close,
            color: alertColor,
            size: 16,
            onPressed: () => _dismissAlert(alert.id),
            tooltip: 'Dismiss',
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildDismissAllButton(List<AppNotification> alerts, Color alertColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _dismissAll(alerts),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: alertColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: alertColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: alertColor,
              ),
              SizedBox(width: AppDimensions.spacing2),
              Text(
                'Dismiss All (${alerts.length})',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: alertColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.elasticOut);
  }

  List<AppNotification> _getCriticalAlerts(List<AppNotification> notifications) {
    return notifications.where((notification) {
      final priority = notification.priority ?? NotificationPriority.medium;
      return priority == NotificationPriority.high ||
             priority == NotificationPriority.critical;
    }).toList();
  }

  Color _getAlertColor(NotificationPriority? priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return AppColorsExtended.statusCritical;
      case NotificationPriority.high:
        return AppColorsExtended.statusWarning;
      default:
        return AppColorsExtended.statusWarning;
    }
  }

  IconData _getPriorityIcon(NotificationPriority? priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Icons.error_outline;
      case NotificationPriority.high:
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }
}

/// Compact action button for alerts
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.size = 18,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: size,
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
        color: color,
      ),
    );
  }
}