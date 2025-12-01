import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/goal_template.dart';

/// Card widget for displaying goal template information
@Deprecated('Use EnhancedGoalTemplateCard instead')
class GoalTemplateCard extends StatelessWidget {
  final GoalTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showPreview;

  const GoalTemplateCard({
    super.key,
    required this.template,
    this.isSelected = false,
    required this.onTap,
    this.showPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint('GoalTemplateCard: Template "${template.name}" tapped, isSelected: $isSelected');
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and selection indicator
                Row(
                  children: [
                    // Template icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: template.color != null
                            ? Color(template.color!)
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(template.icon),
                        color: template.color != null
                            ? Colors.white
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and selection
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          if (isSelected)
                            Text(
                              'Selected',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    // Selection indicator
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  template.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Template details
                Row(
                  children: [
                    _buildDetailChip(
                      context,
                      '\$${template.suggestedAmount.toStringAsFixed(0)}',
                      Icons.attach_money,
                    ),
                    const SizedBox(width: 12),
                    _buildDetailChip(
                      context,
                      '${template.suggestedMonths} months',
                      Icons.schedule,
                    ),
                    const SizedBox(width: 12),
                    _buildDetailChip(
                      context,
                      '\$${(template.monthlyContribution).toStringAsFixed(0)}/month',
                      Icons.trending_up,
                    ),
                  ],
                ),

                if (showPreview && template.tips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  // Preview tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            template.tips.first,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, duration: 400.ms);
  }

  Widget _buildDetailChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'security':
        return Icons.security;
      case 'beach_access':
        return Icons.beach_access;
      case 'home':
        return Icons.home;
      case 'credit_card_off':
        return Icons.credit_card_off;
      case 'directions_car':
        return Icons.directions_car;
      case 'school':
        return Icons.school;
      case 'account_balance':
        return Icons.account_balance;
      case 'trending_up':
        return Icons.trending_up;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.star;
    }
  }
}