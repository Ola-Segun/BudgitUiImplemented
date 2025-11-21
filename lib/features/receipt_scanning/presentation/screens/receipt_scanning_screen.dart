import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/receipt_data.dart';
import '../providers/receipt_scanning_providers.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/camera_preview_widget.dart';

/// Screen for scanning receipts using camera
class ReceiptScanningScreen extends ConsumerStatefulWidget {
  const ReceiptScanningScreen({super.key});

  @override
  ConsumerState<ReceiptScanningScreen> createState() => _ReceiptScanningScreenState();
}

class _ReceiptScanningScreenState extends ConsumerState<ReceiptScanningScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptScanningProvider.notifier).initializeCamera();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for receipt data changes to navigate to review screen
    final state = ref.watch(receiptScanningProvider);
    if (state.receiptData != null && !state.isProcessing) {
      // Navigate to review screen and return result
      _navigateToReview(state.receiptData!);
    }
  }

  Future<void> _navigateToReview(ReceiptData receiptData) async {
    final result = await context.push('/review-receipt', extra: receiptData);
    if (result != null && mounted) {
      // Return the result to the caller
      context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptScanningProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            const CameraPreviewWidget(),

            // Receipt frame overlay
            const CameraOverlay(),

            // Top controls
            _buildTopControls(),

            // Bottom controls
            _buildBottomControls(),

            // Processing overlay
            if (state.isProcessing) _buildProcessingOverlay(),

            // Error overlay
            if (state.error != null) _buildErrorOverlay(state.error!),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
          ),

          // Flash toggle
          IconButton(
            onPressed: () {
              // TODO: Implement flash toggle
            },
            icon: const Icon(Icons.flash_off, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Position receipt within the frame',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              _buildActionButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onPressed: () {
                  ref.read(receiptScanningProvider.notifier).pickFromGallery();
                },
              ),

              // Capture button
              _buildCaptureButton(),

              // Auto-capture toggle
              _buildActionButton(
                icon: Icons.auto_awesome,
                label: 'Auto',
                onPressed: () {
                  // TODO: Toggle auto-capture
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 4),
          ),
          child: IconButton(
            onPressed: () {
              ref.read(receiptScanningProvider.notifier).captureReceipt();
            },
            icon: const Icon(Icons.camera, color: Colors.black, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Capture',
          style: AppTypography.caption.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Processing receipt...',
              style: AppTypography.headlineSmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'This will take a few seconds',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(String error) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: AppTypography.headlineSmall.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(receiptScanningProvider.notifier).clearError();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}