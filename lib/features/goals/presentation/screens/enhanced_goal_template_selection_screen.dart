import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_view.dart';
import '../theme/goals_theme_extended.dart';
import '../widgets/enhanced_goal_template_card.dart';
import '../widgets/create_goal_bottom_sheet.dart';
import '../../domain/entities/goal_template.dart';

/// Enhanced screen for selecting a goal template with modern UI
class EnhancedGoalTemplateSelectionScreen extends StatefulWidget {
  const EnhancedGoalTemplateSelectionScreen({super.key});

  @override
  State<EnhancedGoalTemplateSelectionScreen> createState() =>
      _EnhancedGoalTemplateSelectionScreenState();
}

class _EnhancedGoalTemplateSelectionScreenState
    extends State<EnhancedGoalTemplateSelectionScreen> {
  GoalTemplate? _selectedTemplate;
  String _selectedCategory = 'all';
  bool _isLoading = true;
  List<GoalTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);

    // Simulate loading for smoother UX
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _templates = GoalTemplates.all;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? _buildLoadingState()
          : _templates.isEmpty
              ? _buildEmptyState()
              : _buildContent(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.lightImpact();
          context.pop();
        },
      ),
      title: Text(
        'Choose Template',
        style: AppTypographyExtended.circularProgressPercentage.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (_selectedTemplate != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _navigateToGoalCreation(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: GoalsThemeExtended.goalPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing5),
            decoration: BoxDecoration(
              color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64,
              color: GoalsThemeExtended.goalPrimary,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),

          SizedBox(height: AppDimensions.spacing4),

          Text(
            'No Templates Available',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 24,
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),

          SizedBox(height: AppDimensions.spacing2),

          Text(
            'Templates will be available soon.\nTry creating a custom goal instead.',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 300.ms),

          SizedBox(height: AppDimensions.spacing5),

          ElevatedButton.icon(
            onPressed: () => _onCustomSelected(context),
            icon: const Icon(Icons.edit),
            label: const Text('Create Custom Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GoalsThemeExtended.goalPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideY(begin: 0.1, duration: 300.ms, delay: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final filteredTemplates = _getFilteredTemplates();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.screenPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Hero Header
          _buildHeroHeader(context),

          SizedBox(height: AppDimensions.sectionGap),

          // Category Filters
          _buildCategoryFilters(context),

          SizedBox(height: AppDimensions.sectionGap),

          // Template Count & Sort
          _buildTemplateCountBar(context, filteredTemplates.length),

          SizedBox(height: AppDimensions.spacing4),

          // Template Cards
          ...filteredTemplates.asMap().entries.map((entry) {
            final index = entry.key;
            final template = entry.value;
            return EnhancedGoalTemplateCard(
              template: template,
              isSelected: _selectedTemplate?.id == template.id,
              onTap: () {
                setState(() => _selectedTemplate = template);
                debugPrint('Template "${template.name}" selected');
                // Optional: Auto-navigate immediately or wait for Continue button
                // _navigateToGoalCreation(context);
              },
              animationDelay: Duration(milliseconds: 100 * index),
            );
          }),

          SizedBox(height: AppDimensions.spacing4),

          // Custom Goal Option
          _buildCustomGoalOption(context),

          SizedBox(height: AppDimensions.sectionGap),

          // Selected Template Details
          if (_selectedTemplate != null)
            _buildSelectedTemplateDetails(context),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
            GoalsThemeExtended.goalSecondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.track_changes,
              size: 28,
              color: GoalsThemeExtended.goalPrimary,
            ),
          ),

          SizedBox(height: AppDimensions.spacing3),

          // Title
          Text(
            'Choose Your Goal Template',
            style: AppTypographyExtended.circularProgressPercentage.copyWith(
              fontSize: 24,
            ),
          ),

          SizedBox(height: AppDimensions.spacing2),

          // Description
          Text(
            'Select a pre-built goal template that matches your financial objectives. Each template includes suggested amounts, timelines, and helpful tips to get you started.',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildCategoryFilters(BuildContext context) {
    final categories = [
      {
        'id': 'all',
        'name': 'All',
        'icon': Icons.apps,
        'count': GoalTemplates.all.length
      },
      {
        'id': 'popular',
        'name': 'Popular',
        'icon': Icons.star,
        'count': GoalTemplates.popular.length
      },
      {
        'id': 'quickStart',
        'name': 'Quick',
        'icon': Icons.speed,
        'count': GoalTemplates.quickStart.length
      },
      {
        'id': 'longTerm',
        'name': 'Long-term',
        'icon': Icons.trending_up,
        'count': GoalTemplates.longTerm.length
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category['id'];
          final color = isSelected
              ? GoalsThemeExtended.goalPrimary
              : AppColors.textSecondary;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = category['id'] as String);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1)
                        : AppColorsExtended.pillBgUnselected,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(
                      color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.3),
                      width: 2,
                    ) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${category['name']}',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: color,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${category['count']}',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 200.ms)
      .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildTemplateCountBar(BuildContext context, int count) {
    return Row(
      children: [
        Icon(
          Icons.format_list_bulleted,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$count ${count == 1 ? 'template' : 'templates'} available',
          style: AppTypographyExtended.metricLabel.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        // Optional: Sort button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorsExtended.pillBgUnselected,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Sort',
                style: AppTypographyExtended.metricLabel.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildCustomGoalOption(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GoalsThemeExtended.goalSecondary.withValues(alpha: 0.1),
            GoalsThemeExtended.goalPrimary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GoalsThemeExtended.goalSecondary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _onCustomSelected(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        GoalsThemeExtended.goalSecondary,
                        GoalsThemeExtended.goalPrimary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: GoalsThemeExtended.goalSecondary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppDimensions.spacing4),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Custom Goal',
                        style: AppTypographyExtended.statsValue.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Build your own goal from scratch with complete flexibility',
                        style: AppTypographyExtended.metricLabel.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Advanced users',
                          style: AppTypographyExtended.metricLabel.copyWith(
                            fontWeight: FontWeight.w600,
                            color: GoalsThemeExtended.goalPrimary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: GoalsThemeExtended.goalPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: 400.ms)
      .slideY(begin: 0.1, duration: 500.ms, delay: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildSelectedTemplateDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: GoalsThemeExtended.goalPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Template Details',
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          // Description
          Text(
            _selectedTemplate!.description,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),

          if (_selectedTemplate!.tips.isNotEmpty) ...[
            SizedBox(height: AppDimensions.spacing4),
            _buildTipsSection(context),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTipsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Helpful Tips',
          style: AppTypographyExtended.metricLabel.copyWith(
            fontWeight: FontWeight.w700,
            color: GoalsThemeExtended.goalPrimary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: AppDimensions.spacing3),
        ..._selectedTemplate!.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: GoalsThemeExtended.goalSuccess.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: GoalsThemeExtended.goalSuccess,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTypographyExtended.metricLabel.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
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

  void _navigateToGoalCreation(BuildContext context) {
    if (_selectedTemplate != null) {
      debugPrint('Showing bottom sheet with template: ${_selectedTemplate!.name}');
      CreateGoalBottomSheet.show(
        context,
        selectedTemplate: _selectedTemplate,
      );
    }
  }

  void _onCustomSelected(BuildContext context) {
    debugPrint('Custom goal selected, showing bottom sheet without template');
    CreateGoalBottomSheet.show(context);
  }
}