import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import 'app_card.dart';

/// Balance card with gradient background for displaying financial amounts
class BalanceCard extends StatefulWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final IconData? icon;
  final Color? gradientStart;
  final Color? gradientEnd;
  final VoidCallback? onTap;
  final bool showGradient;
  final EdgeInsets? padding;

  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.icon,
    this.gradientStart,
    this.gradientEnd,
    this.onTap,
    this.showGradient = true,
    this.padding,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceHidden = false;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceHidden = !_isBalanceHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: AppCardElevation.medium,
      padding: EdgeInsets.all(AppDimensions.cardPaddingLarge),
      backgroundColor: widget.showGradient ? null : AppColors.surface,
      borderRadius: AppDimensions.cardBorderRadius,
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.cardPadding,
          vertical: AppDimensions.spacing2,
        ),
        decoration: widget.showGradient ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.gradientStart ?? AppColors.primary,
              widget.gradientEnd ?? AppColors.primaryDark,
            ],
          ),
          borderRadius: AppDimensions.cardBorderRadius,
        ) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, and toggle button
            Row(
              children: [
                if (widget.icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.showGradient ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.showGradient ? Colors.white : AppColors.primary,
                      size: AppDimensions.iconMd,
                    ),
                  ).animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, delay: 100.ms, curve: Curves.elasticOut),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: widget.showGradient
                            ? AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              )
                            : AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                      ).animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideX(begin: 0.1, duration: 400.ms, delay: 200.ms, curve: Curves.easeOutCubic),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: widget.showGradient
                              ? AppTypography.caption.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                )
                              : AppTypography.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                        ).animate()
                          .fadeIn(duration: 300.ms, delay: 300.ms),
                      ],
                    ],
                  ),
                ),
                // Toggle button
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.showGradient ? Colors.white.withOpacity(0.2) : AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: InkWell(
                    onTap: _toggleBalanceVisibility,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isBalanceHidden ? Icons.visibility_off : Icons.visibility,
                          size: 16,
                          color: widget.showGradient ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isBalanceHidden ? 'Show' : 'Hide',
                          style: AppTypography.caption.copyWith(
                            color: widget.showGradient ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 300.ms, delay: 150.ms),
              ],
            ),

            const SizedBox(height: 16),

            // Amount display with instant toggle
            Text(
              _isBalanceHidden ? '••••••' : widget.amount,
              style: widget.showGradient
                  ? AppTypography.currencyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )
                  : AppTypography.currencyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
            ).animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.2, duration: 500.ms, delay: 400.ms, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(0.9, 0.9), duration: 500.ms, delay: 400.ms),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}