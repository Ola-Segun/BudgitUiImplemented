import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/info_card_pattern.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../../../core/design_system/patterns/empty_state_pattern.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/report_bug_bottom_sheet.dart';

// Accessibility utilities
class AccessibilityUtils {
  // Ensure minimum touch target size (48x48dp)
  static const double minTouchTargetSize = 48.0;

  // Check if color meets contrast requirements
  static bool meetsContrastRatio(Color foreground, Color background) {
    // Simple luminance calculation for contrast checking
    double getLuminance(Color color) {
      final r = color.r / 255.0;
      final g = color.g / 255.0;
      final b = color.b / 255.0;
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    final fgLuminance = getLuminance(foreground);
    final bgLuminance = getLuminance(background);
    final contrast = (fgLuminance > bgLuminance)
        ? (fgLuminance + 0.05) / (bgLuminance + 0.05)
        : (bgLuminance + 0.05) / (fgLuminance + 0.05);

    return contrast >= 4.5;
  }

  // Get accessible text color based on background
  static Color getAccessibleTextColor(Color background) {
    return ColorTokens.isLight(background)
        ? ColorTokens.textPrimary
        : ColorTokens.textInverse;
  }
}

class HelpCenterScreenEnhanced extends StatefulWidget {
  const HelpCenterScreenEnhanced({super.key});

  @override
  State<HelpCenterScreenEnhanced> createState() => _HelpCenterScreenEnhancedState();
}

class _HelpCenterScreenEnhancedState extends State<HelpCenterScreenEnhanced> {
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredFAQs = [];

  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I add a new transaction?',
      answer: 'Tap the "+" button on the home screen or transaction list. Fill in the amount, category, and description, then save.',
      category: 'Transactions',
      icon: Icons.receipt_long,
    ),
    FAQItem(
      question: 'How do I create a budget?',
      answer: 'Go to the Budgets tab, tap "Add Budget", select a category, set your budget amount and time period.',
      category: 'Budgets',
      icon: Icons.account_balance_wallet,
    ),
    FAQItem(
      question: 'How do I track my goals?',
      answer: 'Navigate to the Goals tab, create a new goal with target amount and deadline. Add contributions regularly to track progress.',
      category: 'Goals',
      icon: Icons.flag,
    ),
    FAQItem(
      question: 'How do I manage my accounts?',
      answer: 'Go to More > Accounts to view, add, or edit your bank accounts and cards.',
      category: 'Accounts',
      icon: Icons.account_balance,
    ),
    FAQItem(
      question: 'How do I scan receipts?',
      answer: 'Tap the camera button on the home screen or use "Scan Receipt" from quick actions to automatically extract transaction data.',
      category: 'Transactions',
      icon: Icons.camera_alt,
    ),
    FAQItem(
      question: 'How do I view spending insights?',
      answer: 'Check the Insights section on the home screen or visit More > Insights for detailed spending analysis.',
      category: 'Insights',
      icon: Icons.insights,
    ),
    FAQItem(
      question: 'How do I export my data?',
      answer: 'Go to Settings > Data Management to export transactions, budgets, or goals as CSV or PDF files.',
      category: 'Settings',
      icon: Icons.download,
    ),
    FAQItem(
      question: 'How do I set up bill reminders?',
      answer: 'Add recurring bills in the Bills section. Set due dates and amounts to receive timely reminders.',
      category: 'Bills',
      icon: Icons.notifications,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredFAQs = _faqs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _faqs;
      } else {
        _filteredFAQs = _faqs.where((faq) {
          return faq.question.toLowerCase().contains(query.toLowerCase()) ||
              faq.answer.toLowerCase().contains(query.toLowerCase()) ||
              faq.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: AppBar(
        backgroundColor: ColorTokens.surfacePrimary,
        elevation: 0,
        title: Text(
          'Help & Support',
          style: TypographyTokens.heading3,
        ),
      ),
      body: Semantics(
        label: 'Help and support screen',
        hint: 'Scroll to view help topics, FAQs, and contact options',
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DesignTokens.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Semantics(
                label: 'Search help topics',
                hint: 'Type to search for help articles and FAQs',
                child: _buildSearchBar().animate()
                  .fadeIn(duration: DesignTokens.durationNormal)
                  .slideY(begin: -0.1, duration: DesignTokens.durationNormal),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Quick Actions
              Semantics(
                label: 'Quick help actions',
                child: _buildQuickActions().animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Popular Topics
              Semantics(
                label: 'Popular help topics',
                child: _buildPopularTopics().animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // FAQs
              Semantics(
                label: 'Frequently asked questions',
                child: _buildFAQSection().animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Contact Support
              Semantics(
                label: 'Contact support options',
                child: _buildContactSupport().animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterFAQs,
        decoration: InputDecoration(
          hintText: 'Search for help...',
          hintStyle: TypographyTokens.bodyMd.copyWith(
            color: ColorTokens.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: ColorTokens.textSecondary,
            size: DesignTokens.iconMd,
            semanticLabel: 'Search icon',
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Semantics(
                  button: true,
                  label: 'Clear search',
                  hint: 'Double tap to clear search text',
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: ColorTokens.textSecondary,
                      size: DesignTokens.iconMd,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _filterFAQs('');
                    },
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing4,
            vertical: DesignTokens.spacing3,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return InfoCardPattern(
      title: 'Quick Help',
      icon: Icons.flash_on,
      iconColor: ColorTokens.warning500,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'Live chat support',
                hint: 'Double tap to start live chat with support',
                child: _QuickActionCard(
                  icon: Icons.chat_bubble_outline,
                  label: 'Live Chat',
                  gradient: ColorTokens.gradientPrimary,
                  onTap: () => _startLiveChat(),
                ),
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Email support',
                hint: 'Double tap to send email to support team',
                child: _QuickActionCard(
                  icon: Icons.email_outlined,
                  label: 'Email Us',
                  gradient: ColorTokens.gradientSecondary,
                  onTap: () => _sendEmail(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: DesignTokens.spacing3),
        Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'Send feedback',
                hint: 'Double tap to provide app feedback',
                child: _QuickActionCard(
                  icon: Icons.feedback_outlined,
                  label: 'Feedback',
                  gradient: LinearGradient(
                    colors: [ColorTokens.success500, ColorTokens.success600],
                  ),
                  onTap: () => _showFeedbackSheet(),
                ),
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Report bug',
                hint: 'Double tap to report a bug or issue',
                child: _QuickActionCard(
                  icon: Icons.bug_report_outlined,
                  label: 'Report Bug',
                  gradient: LinearGradient(
                    colors: [ColorTokens.critical500, ColorTokens.critical600],
                  ),
                  onTap: () => _showReportBugSheet(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPopularTopics() {
    final topics = [
      TopicInfo('Getting Started', Icons.rocket_launch, ColorTokens.success500),
      TopicInfo('Transactions', Icons.receipt_long, ColorTokens.teal500),
      TopicInfo('Budgets', Icons.account_balance_wallet, ColorTokens.purple600),
      TopicInfo('Security', Icons.security, ColorTokens.critical500),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: TypographyTokens.heading5,
          semanticsLabel: 'Popular help topics section',
        ),
        SizedBox(height: DesignTokens.spacing4),
        Wrap(
          spacing: DesignTokens.spacing3,
          runSpacing: DesignTokens.spacing3,
          children: topics.map((topic) => Semantics(
            button: true,
            label: '${topic.label} topic',
            hint: 'Double tap to filter FAQs by ${topic.label}',
            child: _TopicChip(
              label: topic.label,
              icon: topic.icon,
              color: topic.color,
              onTap: () => _filterByTopic(topic.label),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return InfoCardPattern(
      title: 'Frequently Asked Questions',
      icon: Icons.help_outline,
      iconColor: ColorTokens.info500,
      children: _filteredFAQs.isEmpty
          ? [
              Padding(
                padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing8),
                child: EmptyStatePattern(
                  icon: Icons.search_off,
                  iconColor: ColorTokens.neutral500,
                  title: 'No results found',
                  description: 'Try adjusting your search',
                ),
              ),
            ]
          : _filteredFAQs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _filteredFAQs.length - 1
                      ? DesignTokens.spacing2
                      : 0,
                ),
                child: _FAQExpansionTile(faq: faq),
              );
            }).toList(),
    );
  }

  Widget _buildContactSupport() {
    return InfoCardPattern(
      title: 'Still Need Help?',
      icon: Icons.support_agent,
      iconColor: ColorTokens.teal500,
      children: [
        Semantics(
          button: true,
          label: 'Email support option',
          hint: 'Double tap to send email to support team',
          child: _ContactOption(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@budgettracker.com',
            color: ColorTokens.teal500,
            onTap: () => _sendEmail(),
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Semantics(
          button: true,
          label: 'Phone support option',
          hint: 'Double tap to call support hotline',
          child: _ContactOption(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+1 (555) 123-4567',
            color: ColorTokens.purple600,
            onTap: () => _makePhoneCall(),
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Semantics(
          button: true,
          label: 'Community forum option',
          hint: 'Double tap to open community forum',
          child: _ContactOption(
            icon: Icons.forum,
            title: 'Community Forum',
            subtitle: 'Join the discussion',
            color: ColorTokens.info500,
            onTap: () => _openForum(),
          ),
        ),
        SizedBox(height: DesignTokens.spacing4),
        Semantics(
          button: true,
          label: 'Visit help center button',
          hint: 'Double tap to open full help center website',
          child: ActionButtonPattern(
            label: 'Visit Help Center',
            icon: Icons.open_in_new,
            variant: ButtonVariant.secondary,
            size: ButtonSize.large,
            isFullWidth: true,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  void _filterByTopic(String topic) {
    _searchController.text = topic;
    _filterFAQs(topic);
  }

  void _startLiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Row(
          children: [
            Icon(Icons.chat_bubble, color: ColorTokens.teal500),
            SizedBox(width: DesignTokens.spacing2),
            const Text('Live Chat'),
          ],
        ),
        content: const Text(
          'Live chat support is currently unavailable. Please use email support or check back later.',
        ),
        actions: [
          ActionButtonPattern(
            label: 'OK',
            variant: ButtonVariant.primary,
            size: ButtonSize.medium,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _sendEmail() {
    // TODO: Implement email functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening email client...'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }

  void _showFeedbackSheet() {
    AppBottomSheet.show(
      context: context,
      child: FeedbackBottomSheet(),
    );
  }

  void _showReportBugSheet() {
    AppBottomSheet.show(
      context: context,
      child: ReportBugBottomSheet(),
    );
  }

  void _makePhoneCall() {
    // TODO: Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening phone dialer...'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }

  void _openForum() {
    // TODO: Implement forum navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening community forum...'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AccessibilityUtils.minTouchTargetSize,
          ),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              boxShadow: DesignTokens.elevationColored(
                gradient.colors.first,
                alpha: 0.3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: DesignTokens.iconLg,
                    semanticLabel: '$label icon',
                  ),
                ),
                SizedBox(height: DesignTokens.spacing2),
                Text(
                  label,
                  style: TypographyTokens.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: TypographyTokens.weightBold,
                  ),
                  semanticsLabel: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing3,
            vertical: DesignTokens.spacing2,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.withOpacity(color, 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
            border: Border.all(
              color: ColorTokens.withOpacity(color, 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: DesignTokens.iconSm,
                color: color,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                label,
                style: TypographyTokens.labelSm.copyWith(
                  color: color,
                  fontWeight: TypographyTokens.weightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQExpansionTile extends StatefulWidget {
  const _FAQExpansionTile({required this.faq});

  final FAQItem faq;

  @override
  State<_FAQExpansionTile> createState() => _FAQExpansionTileState();
}

class _FAQExpansionTileState extends State<_FAQExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isExpanded
            ? ColorTokens.withOpacity(ColorTokens.teal500, 0.05)
            : ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: _isExpanded
              ? ColorTokens.withOpacity(ColorTokens.teal500, 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(DesignTokens.spacing3),
          childrenPadding: EdgeInsets.only(
            left: DesignTokens.spacing3,
            right: DesignTokens.spacing3,
            bottom: DesignTokens.spacing3,
          ),
          leading: Container(
            padding: EdgeInsets.all(DesignTokens.spacing2),
            decoration: BoxDecoration(
              color: ColorTokens.withOpacity(ColorTokens.teal500, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              widget.faq.icon,
              size: DesignTokens.iconMd,
              color: ColorTokens.teal500,
            ),
          ),
          title: Text(
            widget.faq.question,
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.all(DesignTokens.spacing1),
            decoration: BoxDecoration(
              color: _isExpanded
                  ? ColorTokens.withOpacity(ColorTokens.teal500, 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: _isExpanded ? ColorTokens.teal500 : ColorTokens.textSecondary,
            ),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
            if (expanded) {
              HapticFeedback.selectionClick();
            }
          },
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                color: ColorTokens.surfacePrimary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.faq.answer,
                    style: TypographyTokens.bodyMd.copyWith(
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing2,
                          vertical: DesignTokens.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: ColorTokens.withOpacity(ColorTokens.info500, 0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Text(
                          widget.faq.category,
                          style: TypographyTokens.captionMd.copyWith(
                            color: ColorTokens.info500,
                            fontWeight: TypographyTokens.weightSemiBold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Was this helpful?',
                            style: TypographyTokens.captionMd,
                          ),
                          SizedBox(width: DesignTokens.spacing2),
                          IconButton(
                            icon: Icon(Icons.thumb_up_outlined, size: DesignTokens.iconSm),
                            onPressed: () => _markHelpful(true),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          SizedBox(width: DesignTokens.spacing1),
                          IconButton(
                            icon: Icon(Icons.thumb_down_outlined, size: DesignTokens.iconSm),
                            onPressed: () => _markHelpful(false),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markHelpful(bool helpful) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(helpful ? 'Thanks for your feedback!' : 'We\'ll improve this answer'),
        duration: const Duration(seconds: 2),
        backgroundColor: helpful ? ColorTokens.success500 : ColorTokens.warning500,
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AccessibilityUtils.minTouchTargetSize,
          ),
          child: Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: ColorTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: ColorTokens.withOpacity(color, 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: DesignTokens.iconMd,
                    semanticLabel: '$title icon',
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TypographyTokens.bodyLg, semanticsLabel: title),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TypographyTokens.captionMd.copyWith(
                          color: color,
                        ),
                        semanticsLabel: subtitle,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: ColorTokens.textSecondary,
                  size: DesignTokens.iconMd,
                  semanticLabel: 'Navigate to $title',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;
  final IconData icon;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    required this.icon,
  });
}

class TopicInfo {
  final String label;
  final IconData icon;
  final Color color;

  TopicInfo(this.label, this.icon, this.color);
}