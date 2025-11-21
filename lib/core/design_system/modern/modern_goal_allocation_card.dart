import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// Goal Allocation Item Model
class GoalAllocationItem {
  final String id;
  final String title;
  final double allocatedAmount;
  final double totalAmount;
  final IconData icon;
  final int color;

  const GoalAllocationItem({
    required this.id,
    required this.title,
    required this.allocatedAmount,
    required this.totalAmount,
    required this.icon,
    required this.color,
  });

  double get progress => totalAmount > 0 ? allocatedAmount / totalAmount : 0.0;
}

/// ModernGoalAllocationCard Widget
/// Compact goal allocation selector with modern design
/// Gray background (#F5F5F5), inline label with icon prefix
/// Compact height (~48px), supports multiple selection
/// Haptic feedback and smooth animations
class ModernGoalAllocationCard extends StatefulWidget {
  final GoalAllocationItem goal;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;
  final bool showProgress;

  const ModernGoalAllocationCard({
    super.key,
    required this.goal,
    this.isSelected = false,
    this.onSelectionChanged,
    this.showProgress = true,
  });

  @override
  State<ModernGoalAllocationCard> createState() => _ModernGoalAllocationCardState();
}

class _ModernGoalAllocationCardState extends State<ModernGoalAllocationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernAnimations.normal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _backgroundAnimation = ColorTween(
      begin: ModernColors.primaryGray,
      end: ModernColors.accentGreen.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isSelected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModernGoalAllocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onSelectionChanged?.call(!widget.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.goal.title} goal, ${(widget.goal.progress * 100).toInt()}% complete',
      value: widget.isSelected ? 'selected' : 'not selected',
      button: true,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 48, // Compact height like other form fields
                padding: const EdgeInsets.symmetric(horizontal: spacing_md, vertical: spacing_sm),
                decoration: BoxDecoration(
                  color: _backgroundAnimation.value ?? ModernColors.primaryGray,
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Row(
                  children: [
                    // Icon prefix
                    Icon(
                      widget.goal.icon,
                      size: 20,
                      color: widget.isSelected ? ModernColors.accentGreen : ModernColors.textSecondary,
                    ),
                    const SizedBox(width: spacing_sm),

                    // Goal title
                    Expanded(
                      child: Text(
                        widget.goal.title,
                        style: ModernTypography.bodyLarge.copyWith(
                          color: ModernColors.textPrimary,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Progress info
                    if (widget.showProgress) ...[
                      const SizedBox(width: spacing_sm),
                      Text(
                        '${(widget.goal.progress * 100).toInt()}%',
                        style: ModernTypography.labelMedium.copyWith(
                          color: widget.isSelected ? ModernColors.accentGreen : ModernColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    // Selection indicator
                    const SizedBox(width: spacing_sm),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSelected ? ModernColors.accentGreen : ModernColors.lightSurface,
                        border: Border.all(
                          color: widget.isSelected ? ModernColors.accentGreen : ModernColors.borderColor,
                          width: 2,
                        ),
                      ),
                      child: widget.isSelected
                          ? const Icon(Icons.check, size: 12, color: ModernColors.lightBackground)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
