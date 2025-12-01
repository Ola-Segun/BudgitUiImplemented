import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/notification.dart';

class NotificationActionHandler {
  /// Handle notification tap and navigate to appropriate screen
  static void handleNotificationAction(
    BuildContext context,
    AppNotification notification,
  ) {
    if (notification.actionUrl == null) return;

    final uri = Uri.tryParse(notification.actionUrl!);
    if (uri == null) return;

    // Parse the action URL and navigate
    switch (uri.scheme) {
      case 'app':
        _handleAppDeepLink(context, uri);
        break;

      case 'http':
      case 'https':
        _handleWebLink(context, uri);
        break;

      default:
        _showUnsupportedLinkError(context);
    }
  }

  static void _handleAppDeepLink(BuildContext context, Uri uri) {
    // Parse internal app links
    // Format: app://[feature]/[action]?params

    switch (uri.host) {
      case 'budget':
        _handleBudgetAction(context, uri);
        break;

      case 'bill':
        _handleBillAction(context, uri);
        break;

      case 'goal':
        _handleGoalAction(context, uri);
        break;

      case 'transaction':
        _handleTransactionAction(context, uri);
        break;

      case 'account':
        _handleAccountAction(context, uri);
        break;

      default:
        context.go('/');
    }
  }

  static void _handleBudgetAction(BuildContext context, Uri uri) {
    final budgetId = uri.queryParameters['id'];

    if (budgetId != null) {
      context.go('/budgets/$budgetId');
    } else {
      context.go('/budgets');
    }
  }

  static void _handleBillAction(BuildContext context, Uri uri) {
    final billId = uri.queryParameters['id'];

    if (billId != null) {
      context.go('/bills/$billId');
    } else {
      context.go('/bills');
    }
  }

  static void _handleGoalAction(BuildContext context, Uri uri) {
    final goalId = uri.queryParameters['id'];

    if (goalId != null) {
      context.go('/goals/$goalId');
    } else {
      context.go('/goals');
    }
  }

  static void _handleTransactionAction(BuildContext context, Uri uri) {
    final transactionId = uri.queryParameters['id'];

    if (transactionId != null) {
      context.go('/transactions/$transactionId');
    } else {
      context.go('/transactions');
    }
  }

  static void _handleAccountAction(BuildContext context, Uri uri) {
    final accountId = uri.queryParameters['id'];

    if (accountId != null) {
      context.go('/accounts/$accountId');
    } else {
      context.go('/accounts');
    }
  }

  static void _handleWebLink(BuildContext context, Uri uri) {
    // Open web links in browser or in-app webview
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${uri.toString()}'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
    );
  }

  static void _showUnsupportedLinkError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open this notification'),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
  }
}