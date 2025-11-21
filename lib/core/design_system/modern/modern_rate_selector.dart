import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// ModernRateSelector Widget
/// Horizontal scrollable selector for predefined rates (5%, 10%, 15%, etc.)
/// Pill-shaped buttons with selected state highlighting
/// Includes custom rate option
class ModernRateSelector extends StatefulWidget {
  final List<double> predefinedRates;
  final double? selectedRate;
  final ValueChanged<double?> onRateSelected;
  final VoidCallback? onCustomSelected;
  final String customLabel;

  const ModernRateSelector({
    super.key,
    this.predefinedRates = const [5.0, 10.0, 15.0, 20.0, 25.0, 30.0],
    this.selectedRate,
    required this.onRateSelected,
    this.onCustomSelected,
    this.customLabel = 'Custom',
  });

  @override
  State<ModernRateSelector> createState() => _ModernRateSelectorState();
}

class _ModernRateSelectorState extends State<ModernRateSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: ModernCurves.easeOut),
    );
  }

  void _onRateTap(double rate) {
    HapticFeedback.lightImpact();
    widget.onRateSelected(rate);
    _animationController.forward().then((_) => _animationController.reverse());
  }

  void _onCustomTap() {
    HapticFeedback.mediumImpact();
    widget.onCustomSelected?.call();
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rate selector',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: spacing_md),
        child: Row(
          children: [
            // Predefined rate buttons
            ...widget.predefinedRates.map((rate) {
              final isSelected = widget.selectedRate == rate;
              return _RatePillButton(
                label: '${rate.toStringAsFixed(0)}%',
                isSelected: isSelected,
                onTap: () => _onRateTap(rate),
              );
            }),
            const SizedBox(width: spacing_md),
            // Custom rate button
            _RatePillButton(
              label: widget.customLabel,
              isSelected: false,
              isCustom: true,
              onTap: _onCustomTap,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _RatePillButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isCustom;
  final VoidCallback onTap;

  const _RatePillButton({
    super.key,
    required this.label,
    required this.isSelected,
    this.isCustom = false,
    required this.onTap,
  });

  @override
  State<_RatePillButton> createState() => _RatePillButtonState();
}

class _RatePillButtonState extends State<_RatePillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: ModernCurves.easeOut),
    );
  }

  void _onTap() {
    _animationController.forward().then((_) => _animationController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            child: Semantics(
              label: widget.label,
              button: true,
              selected: widget.isSelected,
              child: Container(
                margin: const EdgeInsets.only(right: spacing_sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: spacing_lg,
                  vertical: spacing_md,
                ),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? ModernColors.accentGreen
                      : ModernColors.primaryGray,
                  borderRadius: BorderRadius.circular(radius_pill),
                  boxShadow: widget.isSelected
                      ? [ModernShadows.subtle]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isCustom) ...[
                      Icon(
                        Icons.add,
                        size: 16,
                        color: ModernColors.textSecondary,
                      ),
                      const SizedBox(width: spacing_xs),
                    ],
                    Text(
                      widget.label,
                      style: ModernTypography.bodyLarge.copyWith(
                        color: widget.isSelected
                            ? ModernColors.lightBackground
                            : ModernColors.textPrimary,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}