import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/budget_template.dart';
import '../widgets/visual_budget_method_card.dart';

/// Enhanced screen for selecting a budget template with visual method cards
class BudgetTemplateSelectionScreen extends StatefulWidget {
  const BudgetTemplateSelectionScreen({super.key});

  @override
  State<BudgetTemplateSelectionScreen> createState() => _BudgetTemplateSelectionScreenState();
}

class _BudgetTemplateSelectionScreenState extends State<BudgetTemplateSelectionScreen> {
  BudgetTemplate? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Budget Method'),
        actions: [
          if (_selectedTemplate != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedTemplate),
              child: const Text('Continue'),
            ),
        ],
      ),
      body: ListView(
        padding: AppTheme.screenPaddingAll,
        children: [
          // Enhanced header with animation
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Your Budgeting Method',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a proven budgeting method that matches your financial goals and lifestyle. Each method includes pre-configured categories and spending guidelines.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, duration: 600.ms),

          const SizedBox(height: 32),

          // Visual method cards
          ...BudgetTemplates.all.map((template) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: VisualBudgetMethodCard(
                  template: template,
                  isSelected: _selectedTemplate?.id == template.id,
                  onTap: () => setState(() => _selectedTemplate = template),
                ),
              )),

          const SizedBox(height: 24),

          // Custom option with enhanced styling
          _buildCustomOption(context),

          const SizedBox(height: 32),

          // Method comparison section
          if (_selectedTemplate != null) _buildMethodDetails(context),
        ],
      ),
    );
  }

  Widget _buildMethodDetails(BuildContext context) {
    if (_selectedTemplate == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Method Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getMethodExplanation(_selectedTemplate!.id),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 16),
          _buildProsAndCons(context),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms);
  }

  String _getMethodExplanation(String templateId) {
    switch (templateId) {
      case '50-30-20':
        return 'The 50/30/20 rule divides your income into three categories: 50% for needs (essentials like housing and food), 30% for wants (discretionary spending), and 20% for savings and debt repayment. This method provides a simple framework for balanced spending.';
      case 'zero-based':
        return 'Zero-based budgeting assigns every dollar of income to a specific job. Income minus expenses equals zero. This method gives you complete control over your money and helps identify areas for improvement.';
      case 'envelope':
        return 'The envelope system uses physical or digital envelopes for each spending category. Once an envelope is empty, spending in that category stops until the next budgeting period. This method helps control overspending through visual limits.';
      default:
        return '';
    }
  }

  Widget _buildProsAndCons(BuildContext context) {
    final prosAndCons = _getProsAndConsData(_selectedTemplate!.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.thumb_up, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pros',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...prosAndCons['pros']!.map((pro) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: Theme.of(context).textTheme.bodySmall),
                  Expanded(
                    child: Text(
                      pro,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.thumb_down, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Considerations',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...prosAndCons['cons']!.map((con) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: Theme.of(context).textTheme.bodySmall),
                  Expanded(
                    child: Text(
                      con,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Map<String, List<String>> _getProsAndConsData(String templateId) {
    switch (templateId) {
      case '50-30-20':
        return {
          'pros': [
            'Simple and easy to understand',
            'Provides balanced approach to spending',
            'Good starting point for beginners',
            'Flexible within each category',
          ],
          'cons': [
            'May not work for all income levels',
            'Doesn\'t account for irregular expenses',
            'Less detailed tracking of specific categories',
          ],
        };
      case 'zero-based':
        return {
          'pros': [
            'Complete control over every dollar',
            'Helps identify spending patterns',
            'Flexible for changing financial goals',
            'Great for debt reduction',
          ],
          'cons': [
            'Time-consuming to set up',
            'Requires frequent adjustments',
            'Can be overwhelming for beginners',
          ],
        };
      case 'envelope':
        return {
          'pros': [
            'Visual spending limits are clear',
            'Prevents overspending effectively',
            'Good for variable income',
            'Easy to understand and follow',
          ],
          'cons': [
            'Requires discipline to stop spending',
            'Less flexible for unexpected expenses',
            'Physical system can be cumbersome',
          ],
        };
      default:
        return {'pros': [], 'cons': []};
    }
  }

  Widget _buildCustomOption(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCustomSelected(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Custom Budget',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Build your own budget from scratch with complete flexibility',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Advanced users',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.1, duration: 500.ms, delay: 300.ms);
  }

  void _onCustomSelected(BuildContext context) {
    // Navigate back with null to indicate custom budget creation
    Navigator.pop(context, null);
  }
}