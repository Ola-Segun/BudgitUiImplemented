import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// ModernToggleButton Widget
/// Segmented control for binary choices
/// Light gray background (#F5F5F5), White selected state
/// Rounded pill shape, Smooth animation, Equal width segments
class ModernToggleButton extends StatefulWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final EdgeInsets padding;

  const ModernToggleButton({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 48.0,
    this.padding = const EdgeInsets.symmetric(
        horizontal: spacing_sm, vertical: spacing_xs),
  });

  @override
  State<ModernToggleButton> createState() => _ModernToggleButtonState();
}

class _ModernToggleButtonState extends State<ModernToggleButton>
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
  void didUpdateWidget(ModernToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
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
        padding: widget.padding,
        decoration: BoxDecoration(
          color: ModernColors.primaryGray,
          borderRadius: BorderRadius.circular(radius_pill),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // FIX: Check if we have valid width constraints
                final maxWidth = constraints.maxWidth;
                if (!maxWidth.isFinite || maxWidth <= 0) {
                  // Fallback: Return a simple row without positioned elements
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = index == widget.selectedIndex;
                      
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onChanged(index);
                        },
                        child: Semantics(
                          label: option,
                          selected: isSelected,
                          button: true,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: spacing_md,
                              vertical: spacing_xs,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ModernColors.lightBackground
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(radius_pill - spacing_xs),
                              boxShadow: isSelected ? [ModernShadows.subtle] : null,
                            ),
                            child: Text(
                              option,
                              style: ModernTypography.bodyLarge.copyWith(
                                color: isSelected
                                    ? ModernColors.primaryBlack
                                    : ModernColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }

                final segmentWidth = maxWidth / widget.options.length;

                return Stack(
                  children: [
                    // Animated selection indicator (rendered first, at the bottom)
                    AnimatedPositioned(
                      duration: ModernAnimations.normal,
                      curve: ModernCurves.easeOut,
                      left: widget.selectedIndex * segmentWidth,
                      top: widget.padding.top,
                      bottom: widget.padding.bottom,
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
                    // Text segments (rendered second, on top)
                    Row(
                      children: List.generate(widget.options.length, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onChanged(index);
                            },
                            child: Semantics(
                              label: widget.options[index],
                              selected: index == widget.selectedIndex,
                              button: true,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  widget.options[index],
                                  style: ModernTypography.bodyLarge.copyWith(
                                    color: index == widget.selectedIndex
                                        ? ModernColors.primaryBlack
                                        : ModernColors.textSecondary,
                                    fontWeight: index == widget.selectedIndex
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
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