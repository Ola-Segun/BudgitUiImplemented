import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../design_system/color_tokens.dart';
import '../design_system/typography_tokens.dart';

/// Badge showing unread notification count
class NotificationBadge extends ConsumerWidget {
  const NotificationBadge({
    super.key,
    this.size = 20,
  });

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        color: ColorTokens.critical500,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.critical500.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          unreadCount > 99 ? '99+' : '$unreadCount',
          style: TypographyTokens.captionSm.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.5,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Usage in navigation bar:
///
/// Stack(
///   clipBehavior: Clip.none,
///   children: [
///     IconButton(
///       icon: Icon(Icons.notifications_outlined),
///       onPressed: () => context.go('/notifications'),
///     ),
///     Positioned(
///       right: 8,
///       top: 8,
///       child: NotificationBadge(),
///     ),
///   ],
/// )