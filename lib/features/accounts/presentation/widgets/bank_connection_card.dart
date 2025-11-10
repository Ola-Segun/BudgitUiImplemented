import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/presentation/widgets/cards/modern_bank_connection_card.dart';

/// Card widget for bank connection management
/// Updated to use the modern design system
class BankConnectionCard extends ConsumerWidget {
  const BankConnectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModernBankConnectionCard(
      onTap: () => _navigateToBankConnection(context),
    );
  }

  void _navigateToBankConnection(BuildContext context) {
    // Navigate to bank connection management screen
    context.go('/more/accounts/bank-connection');
  }
}