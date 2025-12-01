import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/domain/services/deep_linking_service.dart';

/// Service for handling navigation throughout the app
class NavigationService {
  NavigationService(this._router);

  final GoRouter _router;

  /// Navigate to a specific route
  void navigateTo(String route, {Map<String, dynamic>? arguments}) {
    _router.go(route, extra: arguments);
  }

  /// Navigate to a route with replacement
  void navigateToReplacement(String route, {Map<String, dynamic>? arguments}) {
    _router.go(route, extra: arguments);
  }

  /// Push a route onto the stack
  void push(String route, {Map<String, dynamic>? arguments}) {
    _router.push(route, extra: arguments);
  }

  /// Pop the current route
  void pop() {
    _router.pop();
  }

  /// Handle deep link navigation action
  void handleDeepLinkAction(NavigationAction action) {
    try {
      navigateTo(action.route, arguments: action.arguments);
    } catch (e) {
      // Fallback to home if navigation fails
      navigateTo('/');
      debugPrint('Failed to navigate to deep link: ${action.route}, error: $e');
    }
  }

  /// Navigate to budget details
  void navigateToBudgetDetails(String budgetId) {
    navigateTo('/budgets/$budgetId');
  }

  /// Navigate to transaction details
  void navigateToTransactionDetails(String transactionId) {
    navigateTo('/transactions/$transactionId');
  }

  /// Navigate to goal details
  void navigateToGoalDetails(String goalId) {
    navigateTo('/goals/$goalId');
  }

  /// Navigate to account details
  void navigateToAccountDetails(String accountId) {
    navigateTo('/more/accounts/$accountId');
  }

  /// Navigate to bill details
  void navigateToBillDetails(String billId) {
    navigateTo('/more/bills/$billId');
  }

  /// Navigate to notification settings
  void navigateToNotificationSettings() {
    navigateTo('/more/settings/notifications');
  }

  /// Navigate to settings
  void navigateToSettings() {
    navigateTo('/more/settings');
  }

  /// Navigate to home
  void navigateToHome() {
    navigateTo('/');
  }

  /// Check if a route can be navigated to
  bool canNavigateTo(String route) {
    try {
      _router.go(route);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current route
  String? get currentRoute {
    return _router.routerDelegate.currentConfiguration.uri.toString();
  }

  /// Listen to route changes
  Stream<String> get routeChanges {
    // Note: GoRouter doesn't provide a direct stream for route changes
    // This would need to be implemented with a custom stream controller
    // For now, return an empty stream
    return const Stream<String>.empty();
  }
}