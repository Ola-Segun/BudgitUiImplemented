import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../theme/goals_theme_extended.dart';
import '../../domain/entities/goal_template.dart';

/// Enhanced card widget for displaying goal template information
class EnhancedGoalTemplateCard extends StatefulWidget {
  const EnhancedGoalTemplateCard({
    super.key,
    required this.template,
    this.isSelected = false,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final GoalTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<EnhancedGoalTemplateCard> createState() => _EnhancedGoalTemplateCardState();
}

class _EnhancedGoalTemplateCardState extends State<EnhancedGoalTemplateCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final templateColor = GoalsThemeExtended.getTemplateColor(widget.template.icon);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GoalsThemeExtended.cardBorderRadius),
            border: Border.all(
              color: widget.isSelected
                  ? templateColor
                  : AppColors.borderSubtle,
              width: widget.isSelected
                  ? GoalsThemeExtended.selectedBorderWidth
                  : GoalsThemeExtended.unselectedBorderWidth,
            ),
            boxShadow: widget.isSelected
                ? [GoalsThemeExtended.getSelectedCardShadow(context, templateColor)]
                : [GoalsThemeExtended.getCardShadow(context)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(GoalsThemeExtended.cardBorderRadius),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(GoalsThemeExtended.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(context, templateColor),

                    SizedBox(height: AppDimensions.spacing4),

                    // Description
                    _buildDescription(context),

                    SizedBox(height: AppDimensions.spacing4),

                    // Detail Chips Row
                    _buildDetailChips(context, templateColor),

                    // Optional: First tip preview
                    if (widget.template.tips.isNotEmpty) ...[
                      SizedBox(height: AppDimensions.spacing4),
                      _buildTipPreview(context, templateColor),
                    ],

                    // Selection indicator at bottom
                    if (widget.isSelected) ...[
                      SizedBox(height: AppDimensions.spacing3),
                      _buildSelectionIndicator(context, templateColor),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: widget.animationDelay)
      .slideX(begin: 0.05, duration: 400.ms, delay: widget.animationDelay, curve: Curves.easeOutCubic);
  }

  Widget _buildHeader(BuildContext context, Color templateColor) {
    return Row(
      children: [
        // Template Icon with Gradient
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                templateColor,
                templateColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: templateColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getIconData(widget.template.icon),
            color: Colors.white,
            size: 26,
          ),
        ),

        SizedBox(width: AppDimensions.spacing3),

        // Title and Category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.template.name,
                style: AppTypographyExtended.statsValue.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: templateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getCategoryName(widget.template),
                  style: AppTypographyExtended.metricLabel.copyWith(
                    color: templateColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selection Checkmark
        if (widget.isSelected)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: templateColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: templateColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            ),
          ).animate()
            .scale(duration: 300.ms, curve: Curves.elasticOut),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      widget.template.description,
      style: AppTypographyExtended.metricLabel.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDetailChips(BuildContext context, Color templateColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDetailChip(
          context,
          '\$${widget.template.suggestedAmount.toStringAsFixed(0)}',
          Icons.attach_money,
          templateColor,
        ),
        _buildDetailChip(
          context,
          '${widget.template.suggestedMonths}mo',
          Icons.schedule,
          templateColor,
        ),
        _buildDetailChip(
          context,
          '\$${widget.template.monthlyContribution.toStringAsFixed(0)}/mo',
          Icons.trending_up,
          AppColorsExtended.statusNormal,
        ),
      ],
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsExtended.pillBgUnselected,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypographyExtended.metricLabel.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipPreview(BuildContext context, Color templateColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: templateColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: templateColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: templateColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.template.tips.first,
              style: AppTypographyExtended.metricLabel.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator(BuildContext context, Color templateColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            templateColor.withValues(alpha: 0.1),
            templateColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: templateColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Template Selected',
            style: AppTypographyExtended.metricLabel.copyWith(
              color: templateColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, duration: 300.ms, curve: Curves.elasticOut);
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

  String _getCategoryName(GoalTemplate template) {
    // Determine category based on suggested months
    if (template.suggestedMonths <= 6) {
      return 'QUICK START';
    } else if (template.suggestedMonths <= 12) {
      return 'MID-TERM';
    } else {
      return 'LONG-TERM';
    }
  }
}