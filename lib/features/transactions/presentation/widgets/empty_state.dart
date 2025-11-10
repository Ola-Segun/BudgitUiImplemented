import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';


/// Widget for displaying empty state with friendly illustrations
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    this.lottieAsset,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;
  final String? lottieAsset;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  void _onActionPressed() {
    HapticFeedback.selectionClick();
    onAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration container with enhanced animations
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: lottieAsset != null
                  ? Lottie.asset(
                      lottieAsset!,
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    )
                  : Icon(
                      icon ?? Icons.inbox_outlined,
                      size: 70,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
            )
                .animate()
                .scale(begin: const Offset(0.6, 0.6), duration: const Duration(milliseconds: 600), curve: Curves.elasticOut)
                .fadeIn(duration: const Duration(milliseconds: 400))
                .then()
                .shimmer(duration: const Duration(milliseconds: 1500), delay: const Duration(milliseconds: 600))
                .then()
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: const Duration(milliseconds: 2000)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .slideY(begin: 0.3, duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 200))
                .fadeIn(duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 200))
                .then()
                .shimmer(duration: const Duration(milliseconds: 800), delay: const Duration(milliseconds: 800)),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .slideY(begin: 0.2, duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 400))
                .fadeIn(duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 400)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 4,
                ),
                child: Text(actionLabel!, style: AppTypography.button),
              )
                  .animate()
                  .slideY(begin: 0.2, duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 600))
                  .fadeIn(duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 600))
                  .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 300), delay: const Duration(milliseconds: 600))
                  .then()
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: const Duration(milliseconds: 1500)),
            ],
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 200))
      .slideY(begin: 0.05, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }
}