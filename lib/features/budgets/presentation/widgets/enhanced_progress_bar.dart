import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Enhanced progress bar with animations, interactive elements, and detailed category views
class EnhancedProgressBar extends StatefulWidget {
  const EnhancedProgressBar({
    super.key,
    required this.spent,
    required this.budget,
    required this.categoryName,
    required this.color,
    this.icon,
    this.showDetails = true,
    this.onTap,
    this.animationDelay = Duration.zero,
    this.isInteractive = false,
  });

  final double spent;
  final double budget;
  final String categoryName;
  final Color color;
  final IconData? icon;
  final bool showDetails;
  final VoidCallback? onTap;
  final Duration animationDelay;
  final bool isInteractive;

  @override
  State<EnhancedProgressBar> createState() => _EnhancedProgressBarState();
}

class _EnhancedProgressBarState extends State<EnhancedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.spent / widget.budget).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    // Start animation after delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(EnhancedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spent != widget.spent || oldWidget.budget != widget.budget) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: (widget.spent / widget.budget).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.spent / widget.budget;
    final isOverBudget = progress > 1.0;
    final remaining = widget.budget - widget.spent;
    final percentage = (progress * 100).clamp(0.0, 100.0);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOverBudget
                      ? Colors.red.withValues(alpha: 0.3)
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: isOverBudget ? 2 : 1,
                ),
                boxShadow: widget.isInteractive && _glowAnimation.value > 0
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.1 * _glowAnimation.value),
                          blurRadius: 8 * _glowAnimation.value,
                          spreadRadius: 1 * _glowAnimation.value,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and category name
                  Row(
                    children: [
                      if (widget.icon != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 20,
                            color: widget.color,
                          ),
                        )
                      else
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.showDetails)
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0.0,
                                  end: percentage,
                                ),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                                builder: (context, animatedPercentage, child) {
                                  return Text(
                                    '${animatedPercentage.toStringAsFixed(1)}% used',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isOverBudget
                                              ? Colors.red
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      if (widget.isInteractive)
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Enhanced progress bar
                  Stack(
                    children: [
                      // Background track
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      // Progress fill with gradient
                      FractionallySizedBox(
                        widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isOverBudget
                                  ? [Colors.red, Colors.red.shade300]
                                  : [widget.color, widget.color.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: (isOverBudget ? Colors.red : widget.color)
                                    .withValues(alpha: 0.3 * _glowAnimation.value),
                                blurRadius: 4 * _glowAnimation.value,
                                spreadRadius: 1 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Overflow indicator
                      if (isOverBudget)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (widget.showDetails) ...[
                    const SizedBox(height: 12),

                    // Amount details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spent',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: widget.spent),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOut,
                              builder: (context, animatedSpent, child) {
                                return Text(
                                  '\$${animatedSpent.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isOverBudget ? Colors.red : widget.color,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              remaining >= 0 ? 'Remaining' : 'Over Budget',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: remaining.abs()),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOut,
                              builder: (context, animatedRemaining, child) {
                                return Text(
                                  '${remaining >= 0 ? '' : '+'}\$${animatedRemaining.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: remaining >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Budget amount
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Budget: \$${widget.budget.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ).animate()
        .fadeIn(duration: 400.ms, delay: widget.animationDelay)
        .slideX(begin: 0.1, duration: 400.ms, delay: widget.animationDelay);
  }
}