import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/budget_template.dart';

/// Interactive visual card for budget methods with previews and animations
class VisualBudgetMethodCard extends StatefulWidget {
  const VisualBudgetMethodCard({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
    this.showPreview = true,
  });

  final BudgetTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showPreview;

  @override
  State<VisualBudgetMethodCard> createState() => _VisualBudgetMethodCardState();
}

class _VisualBudgetMethodCardState extends State<VisualBudgetMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(VisualBudgetMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
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

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.template.color ?? 0xFF10B981);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2 * _glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Semantics(
                  label: '${widget.template.name} budget method. ${widget.template.description}. ${widget.template.categories.length} categories included.',
                  hint: 'Double tap to select this budget method',
                  button: true,
                  selected: widget.isSelected,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isSelected
                          ? [
                              color.withOpacity(0.15),
                              color.withOpacity(0.05),
                            ]
                          : [
                              Theme.of(context).colorScheme.surface,
                              Theme.of(context).colorScheme.surfaceContainerLowest,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isSelected
                          ? color.withOpacity(0.5)
                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      width: widget.isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon and title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getIconForTemplate(widget.template.id),
                              color: color,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.template.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: widget.isSelected
                                            ? color
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.template.categories.length} categories',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.isSelected)
                            Icon(
                              Icons.check_circle,
                              color: color,
                              size: 28,
                            ).animate()
                                .scale(begin: const Offset(0.5, 0.5), duration: 300.ms)
                                .fadeIn(duration: 300.ms),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        widget.template.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),

                      const SizedBox(height: 20),

                      // Preview visualization
                      if (widget.showPreview) _buildPreviewVisualization(context, color),

                      const SizedBox(height: 20),

                      // Category chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.template.categories.take(4).map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              category.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),

                      if (widget.template.categories.length > 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+${widget.template.categories.length - 4} more categories',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        );
        
      },
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildPreviewVisualization(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Allocation Preview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          ...widget.template.categories.take(3).map((category) {
            final percentage = (category.amount / widget.template.totalBudget) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIconForTemplate(String templateId) {
    switch (templateId) {
      case '50-30-20':
        return Icons.pie_chart;
      case 'zero-based':
        return Icons.calculate;
      case 'envelope':
        return Icons.mail;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
