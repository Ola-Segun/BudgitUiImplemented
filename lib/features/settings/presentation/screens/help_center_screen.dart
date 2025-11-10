import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';

/// Help Center screen with FAQs, contact support, and feedback
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: DesignTokens.curveEaseOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I add a new transaction?',
      answer: 'Tap the "+" button on the home screen or transaction list. Fill in the amount, category, and description, then save.',
    ),
    FAQItem(
      question: 'How do I create a budget?',
      answer: 'Go to the Budgets tab, tap "Add Budget", select a category, set your budget amount and time period.',
    ),
    FAQItem(
      question: 'How do I track my goals?',
      answer: 'Navigate to the Goals tab, create a new goal with target amount and deadline. Add contributions regularly to track progress.',
    ),
    FAQItem(
      question: 'How do I manage my accounts?',
      answer: 'Go to More > Accounts to view, add, or edit your bank accounts and cards.',
    ),
    FAQItem(
      question: 'How do I scan receipts?',
      answer: 'Tap the camera button on the home screen or use "Scan Receipt" from quick actions to automatically extract transaction data.',
    ),
    FAQItem(
      question: 'How do I view spending insights?',
      answer: 'Check the Insights section on the home screen or visit More > Insights for detailed spending analysis.',
    ),
    FAQItem(
      question: 'How do I export my data?',
      answer: 'Go to Settings > Data Management to export transactions, budgets, or goals as CSV or PDF files.',
    ),
    FAQItem(
      question: 'How do I set up bill reminders?',
      answer: 'Add recurring bills in the Bills section. Set due dates and amounts to receive timely reminders.',
    ),
  ];

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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            // Simulate refresh
            await Future.delayed(const Duration(seconds: 1));
          },
          color: ColorTokens.teal500,
          child: ListView(
            padding: EdgeInsets.all(DesignTokens.screenPaddingH),
            children: [
              // Quick Actions
              _buildQuickActions(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Frequently Asked Questions
              _buildFAQSection(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Contact Support
              _buildContactSupport(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

              SizedBox(height: DesignTokens.sectionGapLg),

              // App Information
              _buildAppInfo(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

              SizedBox(height: DesignTokens.spacing8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Help',
              style: TypographyTokens.heading5,
            ),
            SizedBox(height: DesignTokens.spacing4),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.help_outline,
                    label: 'User Guide',
                    color: ColorTokens.info500,
                    onPressed: () => _showUserGuide(context),
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.feedback,
                    label: 'Send Feedback',
                    color: ColorTokens.success500,
                    onPressed: () => _showFeedbackSheet(context),
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 50.ms),
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacing3),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.bug_report,
                    label: 'Report Issue',
                    color: ColorTokens.warning500,
                    onPressed: () => _showReportIssueSheet(context),
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.chat,
                    label: 'Live Chat',
                    color: ColorTokens.teal500,
                    onPressed: () => _startLiveChat(context),
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: TypographyTokens.heading5,
            ),
            SizedBox(height: DesignTokens.spacing4),
            ..._faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
                child: _buildFAQItem(context, faq).animate()
                  .fadeIn(
                    duration: DesignTokens.durationNormal,
                    delay: Duration(milliseconds: 50 * index),
                  )
                  .slideY(
                    begin: 0.1,
                    duration: DesignTokens.durationNormal,
                    delay: Duration(milliseconds: 50 * index),
                  ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, FAQItem faq) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: ColorTokens.neutral200,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: TypographyTokens.bodyLg.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          trailing: Icon(
            Icons.expand_more,
            color: ColorTokens.textSecondary,
            size: DesignTokens.iconMd,
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing4,
                vertical: DesignTokens.spacing3,
              ),
              child: Text(
                faq.answer,
                style: TypographyTokens.bodyMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupport(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Support',
              style: TypographyTokens.heading5,
            ),
            SizedBox(height: DesignTokens.spacing4),
            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@budgettracker.com',
              color: ColorTokens.info500,
              onTap: () => _sendEmail(),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

            Divider(
              height: DesignTokens.spacing4,
              thickness: 1,
              color: ColorTokens.neutral200,
            ),

            _buildContactOption(
              context,
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: '+1 (555) 123-4567',
              color: ColorTokens.success500,
              onTap: () => _makePhoneCall(),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),

            Divider(
              height: DesignTokens.spacing4,
              thickness: 1,
              color: ColorTokens.neutral200,
            ),

            _buildContactOption(
              context,
              icon: Icons.forum,
              title: 'Community Forum',
              subtitle: 'Get help from other users',
              color: ColorTokens.warning500,
              onTap: () => _openForum(),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing2),
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
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TypographyTokens.bodyLg.copyWith(
                        fontWeight: TypographyTokens.weightSemiBold,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing1),
                    Text(
                      subtitle,
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ColorTokens.textSecondary,
                size: DesignTokens.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Budget Tracker',
              style: TypographyTokens.heading5,
            ),
            SizedBox(height: DesignTokens.spacing4),
            _buildInfoRow('Version', '1.0.0').animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

            _buildInfoRow('Last Updated', 'October 2024').animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),

            SizedBox(height: DesignTokens.spacing4),

            Row(
              children: [
                Expanded(
                  child: _buildLinkButton(
                    context,
                    'Terms of Service',
                    ColorTokens.info500,
                    () {},
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: _buildLinkButton(
                    context,
                    'Privacy Policy',
                    ColorTokens.success500,
                    () {},
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TypographyTokens.bodyMd.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: TypographyTokens.bodyMd.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spacing3,
            horizontal: DesignTokens.spacing2,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.withOpacity(color, 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: ColorTokens.withOpacity(color, 0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TypographyTokens.labelMd.copyWith(
              color: color,
              fontWeight: TypographyTokens.weightSemiBold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Guide'),
        content: const Text(
          'A comprehensive user guide is coming soon! In the meantime, '
          'explore the app and use the FAQ section above for help.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      child: _FeedbackSheet(),
    );
  }

  void _showReportIssueSheet(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      child: _ReportIssueSheet(),
    );
  }

  void _startLiveChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Live chat support is currently unavailable. Please use email support or check back later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _sendEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Support'),
        content: const Text(
          'Email support is not yet implemented. Please check back later or use the feedback form.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Support'),
        content: const Text(
          'Phone support is not yet available. Please use email support or the feedback form.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openForum() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community Forum'),
        content: const Text(
          'Community forum is coming soon! In the meantime, use the feedback form to share your thoughts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spacing4,
            horizontal: DesignTokens.spacing3,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.withOpacity(color, 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: ColorTokens.withOpacity(color, 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: DesignTokens.iconMd,
                ),
              ),
              SizedBox(height: DesignTokens.spacing2),
              Text(
                label,
                style: TypographyTokens.labelSm.copyWith(
                  color: color,
                  fontWeight: TypographyTokens.weightSemiBold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  const FAQItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class _FeedbackSheet extends StatefulWidget {
  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _controller = TextEditingController();
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send Feedback',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'How would you rate your experience?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tell us what you think...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _submitFeedback,
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitFeedback() {
    final feedback = _controller.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    // In a real app, this would send feedback to a server
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your ${_rating > 0 ? "$_rating-star " : ""}feedback!'),
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ReportIssueSheet extends StatefulWidget {
  @override
  State<_ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<_ReportIssueSheet> {
  final _controller = TextEditingController();
  String _issueType = 'Bug Report';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report an Issue',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _issueType,
            decoration: const InputDecoration(
              labelText: 'Issue Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Bug Report', child: Text('Bug Report')),
              DropdownMenuItem(value: 'Feature Request', child: Text('Feature Request')),
              DropdownMenuItem(value: 'Performance Issue', child: Text('Performance Issue')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) => setState(() => _issueType = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe the issue...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _submitIssue,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitIssue() {
    final issue = _controller.text.trim();
    if (issue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    // In a real app, this would send the issue report to a server
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_issueType submitted successfully!'),
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}