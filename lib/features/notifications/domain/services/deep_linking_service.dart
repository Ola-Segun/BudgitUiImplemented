import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/navigation/navigation_service.dart';

/// Service for handling deep linking navigation from notifications
class DeepLinkingService {
  DeepLinkingService(this._navigationService);

  final NavigationService _navigationService;

  final StreamController<String> _navigationController =
      StreamController<String>.broadcast();

  /// Stream of navigation requests from deep links
  Stream<String> get navigationRequests => _navigationController.stream;

  /// Handle deep link URL and extract navigation information
  Future<Result<NavigationAction>> handleDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);

      switch (uri.scheme) {
        case 'budget':
          return _handleBudgetDeepLink(uri);
        case 'bill':
          return _handleBillDeepLink(uri);
        case 'goal':
          return _handleGoalDeepLink(uri);
        case 'account':
          return _handleAccountDeepLink(uri);
        case 'transaction':
          return _handleTransactionDeepLink(uri);
        case 'settings':
          return _handleSettingsDeepLink(uri);
        default:
          return Result.error(Failure.unknown('Unsupported deep link scheme: ${uri.scheme}'));
      }
    } catch (e) {
      return Result.error(Failure.unknown('Failed to parse deep link: $e'));
    }
  }

  /// Handle budget-related deep links
  Result<NavigationAction> _handleBudgetDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return Result.success(NavigationAction(
        route: '/budgets',
        arguments: null,
      ));
    }

    switch (pathSegments[0]) {
      case 'details':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/budget-details',
            arguments: {'budgetId': pathSegments[1]},
          ));
        }
        break;
      case 'create':
        return Result.success(NavigationAction(
          route: '/create-budget',
          arguments: null,
        ));
      case 'categories':
        return Result.success(NavigationAction(
          route: '/budget-categories',
          arguments: null,
        ));
    }

    return Result.error(Failure.unknown('Invalid budget deep link path'));
  }

  /// Handle bill-related deep links
  Result<NavigationAction> _handleBillDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return Result.success(NavigationAction(
        route: '/bills',
        arguments: null,
      ));
    }

    switch (pathSegments[0]) {
      case 'details':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/bill-details',
            arguments: {'billId': pathSegments[1]},
          ));
        }
        break;
      case 'pay':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/pay-bill',
            arguments: {'billId': pathSegments[1]},
          ));
        }
        break;
      case 'create':
        return Result.success(NavigationAction(
          route: '/create-bill',
          arguments: null,
        ));
    }

    return Result.error(Failure.unknown('Invalid bill deep link path'));
  }

  /// Handle goal-related deep links
  Result<NavigationAction> _handleGoalDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return Result.success(NavigationAction(
        route: '/goals',
        arguments: null,
      ));
    }

    switch (pathSegments[0]) {
      case 'details':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/goal-details',
            arguments: {'goalId': pathSegments[1]},
          ));
        }
        break;
      case 'create':
        return Result.success(NavigationAction(
          route: '/create-goal',
          arguments: null,
        ));
      case 'contribute':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/goal-contribution',
            arguments: {'goalId': pathSegments[1]},
          ));
        }
        break;
    }

    return Result.error(Failure.unknown('Invalid goal deep link path'));
  }

  /// Handle account-related deep links
  Result<NavigationAction> _handleAccountDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return Result.success(NavigationAction(
        route: '/accounts',
        arguments: null,
      ));
    }

    switch (pathSegments[0]) {
      case 'details':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/account-details',
            arguments: {'accountId': pathSegments[1]},
          ));
        }
        break;
      case 'create':
        return Result.success(NavigationAction(
          route: '/create-account',
          arguments: null,
        ));
      case 'sync':
        return Result.success(NavigationAction(
          route: '/account-sync',
          arguments: null,
        ));
    }

    return Result.error(Failure.unknown('Invalid account deep link path'));
  }

  /// Handle transaction-related deep links
  Result<NavigationAction> _handleTransactionDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return Result.success(NavigationAction(
        route: '/transactions',
        arguments: null,
      ));
    }

    switch (pathSegments[0]) {
      case 'details':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/transaction-details',
            arguments: {'transactionId': pathSegments[1]},
          ));
        }
        break;
      case 'create':
        return Result.success(NavigationAction(
          route: '/create-transaction',
          arguments: null,
        ));
      case 'split':
        if (pathSegments.length > 1) {
          return Result.success(NavigationAction(
            route: '/split-transaction',
            arguments: {'transactionId': pathSegments[1]},
          ));
        }
        break;
    }

    return Result.error(Failure.unknown('Invalid transaction deep link path'));
  }

  /// Handle settings-related deep links
  Result<NavigationAction> _handleSettingsDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return Result.success(NavigationAction(
        route: '/settings',
        arguments: null,
      ));
    }

    switch (pathSegments[0]) {
      case 'notifications':
        return Result.success(NavigationAction(
          route: '/notification-settings',
          arguments: null,
        ));
      case 'backup':
        return Result.success(NavigationAction(
          route: '/backup-settings',
          arguments: null,
        ));
      case 'export':
        return Result.success(NavigationAction(
          route: '/export-settings',
          arguments: null,
        ));
      case 'security':
        return Result.success(NavigationAction(
          route: '/security-settings',
          arguments: null,
        ));
      case 'profile':
        return Result.success(NavigationAction(
          route: '/profile-settings',
          arguments: null,
        ));
    }

    return Result.error(Failure.unknown('Invalid settings deep link path'));
  }

  /// Navigate to the specified route with arguments
  void navigateTo(NavigationAction action) {
    _navigationController.add(action.route);
    // Use navigation service for actual navigation
    _navigationService.handleDeepLinkAction(action);
  }

  /// Dispose of resources
  void dispose() {
    _navigationController.close();
  }
}

/// Represents a navigation action from a deep link
class NavigationAction {
  const NavigationAction({
    required this.route,
    this.arguments,
  });

  final String route;
  final Map<String, dynamic>? arguments;

  @override
  String toString() {
    return 'NavigationAction(route: $route, arguments: $arguments)';
  }
}