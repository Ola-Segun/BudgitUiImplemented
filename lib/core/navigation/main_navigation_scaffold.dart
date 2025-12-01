import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';

/// Main navigation scaffold with bottom tab bar
class MainNavigationScaffold extends ConsumerStatefulWidget {
  const MainNavigationScaffold({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = ['/', '/transactions', '/budgets', '/goals', '/more/accounts'];

  @override
  ConsumerState<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends ConsumerState<MainNavigationScaffold> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // Check in order from most specific to least specific
    if (location.startsWith('/more/accounts')) return 4;
    if (location.startsWith('/more')) return 4;
    if (location.startsWith('/goals')) return 3;
    if (location.startsWith('/budgets')) return 2;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/')) return 0;
    return 0; // Default to home
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index != _previousIndex) {
      _animationController.forward().then((_) => _animationController.reverse());
    }
    _previousIndex = index;
    context.go(MainNavigationScaffold._routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          _buildNavigationBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            index: 0,
            currentIndex: currentIndex,
            badgeCount: 0, // Home doesn't need badge
          ),
          _buildNavigationBarItem(
            icon: Icons.credit_card_outlined,
            activeIcon: Icons.credit_card,
            label: 'Transactions',
            index: 1,
            currentIndex: currentIndex,
            badgeCount: 0, // Transactions don't need badge
          ),
          _buildNavigationBarItem(
            icon: Icons.pie_chart_outline,
            activeIcon: Icons.pie_chart,
            label: 'Budgets',
            index: 2,
            currentIndex: currentIndex,
            badgeCount: 0, // Budgets don't need badge
          ),
          _buildNavigationBarItem(
            icon: Icons.flag_outlined,
            activeIcon: Icons.flag,
            label: 'Goals',
            index: 3,
            currentIndex: currentIndex,
            badgeCount: 0, // Goals don't need badge
          ),
          _buildNavigationBarItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Wallet',
            index: 4,
            currentIndex: currentIndex,
            badgeCount: unreadCount, // Wallet/More tab shows notification badge
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
    required int badgeCount,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: currentIndex == index ? _scaleAnimation.value : 1.0,
                child: Icon(icon, size: 24),
              );
            },
          ),
          if (badgeCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      activeIcon: Icon(activeIcon, size: 24),
      label: label,
    );
  }
}