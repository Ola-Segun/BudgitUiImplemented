import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// Data class for icon toggle button options
class IconToggleOption {
  final String label;
  final IconData icon;
  final Color color;
  final String value;

  const IconToggleOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
  });
}

/// ModernIconToggleButton Widget
/// Pill-style segmented control with icons and labels
/// Light gray background (#F5F5F5), White selected state with shadow
/// Rounded pill shape, Smooth animation, Equal width segments
class ModernIconToggleButton extends StatefulWidget {
  final List<IconToggleOption> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final double height;

  const ModernIconToggleButton({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.height = 64.0,
  });

  @override
  State<ModernIconToggleButton> createState() => _ModernIconToggleButtonState();
}

class _ModernIconToggleButtonState extends State<ModernIconToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernAnimations.normal,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: ModernCurves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ModernIconToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Toggle options',
      selected: true,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(
            horizontal: spacing_sm, vertical: spacing_xs),
        decoration: BoxDecoration(
          color: ModernColors.primaryGray,
          borderRadius: BorderRadius.circular(radius_pill),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final segmentWidth =
                    constraints.maxWidth / widget.options.length;

                return Stack(
                  children: [
                    // Animated selection indicator (rendered first, at the bottom)
                    AnimatedPositioned(
                      duration: ModernAnimations.normal,
                      curve: ModernCurves.easeOut,
                      left: widget.options
                              .indexWhere((opt) => opt.value == widget.selectedValue) *
                          segmentWidth,
                      top: spacing_xs,
                      bottom: spacing_xs,
                      width: segmentWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ModernColors.lightBackground,
                          borderRadius:
                              BorderRadius.circular(radius_pill - spacing_xs),
                          boxShadow: [ModernShadows.subtle],
                        ),
                      ),
                    ),
                    // Icon and text segments (rendered second, on top)
                    Row(
                      children: List.generate(widget.options.length, (index) {
                        final option = widget.options[index];
                        final isSelected = option.value == widget.selectedValue;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onChanged(option.value);
                            },
                            child: Semantics(
                              label: option.label,
                              selected: isSelected,
                              button: true,
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      option.icon,
                                      size: 20,
                                      color: isSelected
                                          ? ModernColors.primaryBlack
                                          : option.color,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option.label,
                                      style: ModernTypography.labelSmall.copyWith(
                                        color: isSelected
                                            ? ModernColors.primaryBlack
                                            : ModernColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
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