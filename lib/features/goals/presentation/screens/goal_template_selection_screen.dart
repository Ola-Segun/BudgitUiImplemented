import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/goal_template.dart';
import '../widgets/goal_template_card.dart';

/// Screen for selecting a goal template with visual template cards
class GoalTemplateSelectionScreen extends StatefulWidget {
  const GoalTemplateSelectionScreen({super.key});

  @override
  State<GoalTemplateSelectionScreen> createState() => _GoalTemplateSelectionScreenState();
}

class _GoalTemplateSelectionScreenState extends State<GoalTemplateSelectionScreen> {
  GoalTemplate? _selectedTemplate;
  String _selectedCategory = 'all'; // 'all', 'popular', 'quickStart', 'longTerm'

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GoalTemplate>>(
      future: _loadTemplates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        } else {
          final templates = _filterTemplates(snapshot.data!);
          return _buildContent(templates);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Goal Template')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading templates...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Goal Template')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load templates'),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Goal Template')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No templates available'),
            const SizedBox(height: 8),
            const Text(
              'Templates will be available soon',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<GoalTemplate> templates) {
    final filteredTemplates = _getFilteredTemplates();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Goal Template'),
        actions: [
          if (_selectedTemplate != null)
            TextButton(
              onPressed: () => _navigateToGoalCreation(context),
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
                  Icons.track_changes,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Your Goal Template',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a pre-built goal template that matches your financial objectives. Each template includes suggested amounts, timelines, and helpful tips to get you started.',
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

          const SizedBox(height: 24),

          // Category filter chips
          _buildCategoryFilters(context),

          const SizedBox(height: 24),

          // Template count
          Text(
            '${templates.length} ${templates.length == 1 ? 'template' : 'templates'} available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: 16),

          // Template cards
          ...templates.map((template) => GoalTemplateCard(
                template: template,
                isSelected: _selectedTemplate?.id == template.id,
                onTap: () {
                  setState(() => _selectedTemplate = template);
                  debugPrint('GoalTemplateSelectionScreen: Template "${template.name}" selected');
                  // Auto-navigate to goal creation when template is selected
                  _navigateToGoalCreation(context);
                },
              )),

          const SizedBox(height: 24),

          // Custom goal option
          _buildCustomGoalOption(context),

          const SizedBox(height: 32),

          // Template details section
          if (_selectedTemplate != null) _buildTemplateDetails(context),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    final categories = [
      {'id': 'all', 'name': 'All Templates', 'count': GoalTemplates.all.length},
      {'id': 'popular', 'name': 'Popular', 'count': GoalTemplates.popular.length},
      {'id': 'quickStart', 'name': 'Quick Start (≤6 months)', 'count': GoalTemplates.quickStart.length},
      {'id': 'longTerm', 'name': 'Long Term (≥12 months)', 'count': GoalTemplates.longTerm.length},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category['id'];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${category['name']} (${category['count']})'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category['id'] as String);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<GoalTemplate> _getFilteredTemplates() {
    switch (_selectedCategory) {
      case 'popular':
        return GoalTemplates.popular;
      case 'quickStart':
        return GoalTemplates.quickStart;
      case 'longTerm':
        return GoalTemplates.longTerm;
      default:
        return GoalTemplates.all;
    }
  }

  Widget _buildCustomGoalOption(BuildContext context) {
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
                        'Create Custom Goal',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Build your own goal from scratch with complete flexibility',
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

  Widget _buildTemplateDetails(BuildContext context) {
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
                'Template Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTemplate!.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 16),
          _buildTipsSection(context),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildTipsSection(BuildContext context) {
    if (_selectedTemplate!.tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Helpful Tips',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        ..._selectedTemplate!.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Future<List<GoalTemplate>> _loadTemplates() async {
    // Simulate loading delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    return GoalTemplates.all;
  }

  List<GoalTemplate> _filterTemplates(List<GoalTemplate> templates) {
    return _getFilteredTemplates();
  }

  void _navigateToGoalCreation(BuildContext context) {
    if (_selectedTemplate != null) {
      // Navigate to goal creation with the selected template
      debugPrint('GoalTemplateSelectionScreen: Navigating to /goals/add with template: ${_selectedTemplate!.name}');
      context.push('/goals/add', extra: _selectedTemplate);
    } else {
      debugPrint('GoalTemplateSelectionScreen: No template selected, navigating without template');
      context.go('/goals/add');
    }
  }

  void _onCustomSelected(BuildContext context) {
    // Navigate to goal creation without a template
    debugPrint('GoalTemplateSelectionScreen: Custom goal selected, navigating to /goals/add without template');
    context.go('/goals/add');
  }
}