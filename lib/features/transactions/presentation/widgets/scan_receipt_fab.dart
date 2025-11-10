import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';


/// Floating Action Button for scanning receipts
class ScanReceiptFAB extends StatelessWidget {
  const ScanReceiptFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go('/scan-receipt'),
      tooltip: 'Scan receipt',
      child: const Icon(Icons.camera_alt),
    ).animate()
      .scale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
      )
      .fadeIn(duration: const Duration(milliseconds: 200));
  }
}