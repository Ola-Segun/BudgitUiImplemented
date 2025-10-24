import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main navigation scaffold with bottom tab bar
class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = ['/', '/transactions', '/budgets', '/goals', '/more/accounts'];

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> with TickerProviderStateMixin {
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

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: currentIndex == 0 ? _scaleAnimation.value : 1.0,
                  child: const Icon(Icons.home_outlined, size: 24),
                );
              },
            ),
            activeIcon: const Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: currentIndex == 1 ? _scaleAnimation.value : 1.0,
                  child: const Icon(Icons.credit_card_outlined, size: 24),
                );
              },
            ),
            activeIcon: const Icon(Icons.credit_card, size: 24),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: currentIndex == 2 ? _scaleAnimation.value : 1.0,
                  child: const Icon(Icons.pie_chart_outline, size: 24),
                );
              },
            ),
            activeIcon: const Icon(Icons.pie_chart, size: 24),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: currentIndex == 3 ? _scaleAnimation.value : 1.0,
                  child: const Icon(Icons.flag_outlined, size: 24),
                );
              },
            ),
            activeIcon: const Icon(Icons.flag, size: 24),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: currentIndex == 4 ? _scaleAnimation.value : 1.0,
                  child: const Icon(Icons.account_balance_wallet_outlined, size: 24),
                );
              },
            ),
            activeIcon: const Icon(Icons.account_balance_wallet, size: 24),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}