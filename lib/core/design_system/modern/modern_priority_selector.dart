import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// Priority levels for goals and tasks
enum PriorityLevel {
  low,
  medium,
  high,
  urgent,
}

/// ModernPrioritySelector Widget
/// Segmented control for priority selection with visual indicators
/// Color-coded priority levels with icons and labels
class ModernPrioritySelector extends StatefulWidget {
  final PriorityLevel? selectedPriority;
  final ValueChanged<PriorityLevel?>? onChanged;
  final bool enabled;
  final String? label;
  final double height;

  const ModernPrioritySelector({
    super.key,
    this.selectedPriority,
    this.onChanged,
    this.enabled = true,
    this.label,
    this.height = ModernSizes.buttonHeight,
  });

  @override
  State<ModernPrioritySelector> createState() => _ModernPrioritySelectorState();
}

class _ModernPrioritySelectorState extends State<ModernPrioritySelector>
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
      CurvedAnimation(parent: _animationController, curve: ModernCurves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ModernPrioritySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPriority != widget.selectedPriority) {
      _animationController.reset();
      _animationController.forward();
    }
  }


  int _getIndexFromPriority(PriorityLevel? priority) {
    if (priority == null) return -1;
    return PriorityLevel.values.indexOf(priority);
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return ModernColors.info; // Blue
      case PriorityLevel.medium:
        return ModernColors.warning; // Orange
      case PriorityLevel.high:
        return ModernColors.error; // Red
      case PriorityLevel.urgent:
        return ModernColors.error.withOpacity(0.8); // Darker red
    }
  }

  IconData _getPriorityIcon(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return Icons.arrow_downward;
      case PriorityLevel.medium:
        return Icons.remove;
      case PriorityLevel.high:
        return Icons.arrow_upward;
      case PriorityLevel.urgent:
        return Icons.priority_high;
    }
  }

  String _getPriorityLabel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.urgent:
        return 'Urgent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorities = PriorityLevel.values;
    final selectedIndex = _getIndexFromPriority(widget.selectedPriority);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: ModernTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: spacing_sm),
        ],
        Semantics(
          label: 'Priority selector',
          selected: true,
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.all(spacing_xs),
            decoration: BoxDecoration(
              color: ModernColors.primaryGray,
              borderRadius: BorderRadius.circular(radius_pill),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final segmentWidth = (constraints.maxWidth - (spacing_xs * 2)) / priorities.length;

                    return Stack(
                      children: [
                        // Background segments
                        Row(
                          children: List.generate(priorities.length, (index) {
                            final priority = priorities[index];
                            final isSelected = index == selectedIndex;

                            return Expanded(
                              child: GestureDetector(
                                onTap: widget.enabled && widget.onChanged != null ? () {
                                  HapticFeedback.lightImpact();
                                  widget.onChanged!(priority);
                                } : null,
                                child: Semantics(
                                  label: _getPriorityLabel(priority),
                                  selected: isSelected,
                                  button: true,
                                  child: Container(
                                    height: widget.height - spacing_xs * 2,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getPriorityIcon(priority),
                                          size: 16,
                                          color: isSelected
                                              ? _getPriorityColor(priority)
                                              : ModernColors.textSecondary,
                                        ),
                                        const SizedBox(width: spacing_xs),
                                        Text(
                                          _getPriorityLabel(priority),
                                          style: ModernTypography.labelMedium.copyWith(
                                            color: isSelected
                                                ? _getPriorityColor(priority)
                                                : ModernColors.textSecondary,
                                            fontWeight: isSelected
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
                          }),
                        ),
                        // Animated selection indicator
                        if (selectedIndex >= 0)
                          AnimatedPositioned(
                            duration: ModernAnimations.normal,
                            curve: ModernCurves.easeOut,
                            left: selectedIndex * segmentWidth + spacing_xs,
                            top: spacing_xs,
                            bottom: spacing_xs,
                            width: segmentWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ModernColors.lightBackground,
                                borderRadius: BorderRadius.circular(radius_pill - spacing_xs),
                                boxShadow: [ModernShadows.subtle],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}