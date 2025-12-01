import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';

/// Privacy Policy screen with proper content and navigation
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Semantics(
          label: 'Privacy Policy screen',
          hint: 'Scroll to read the privacy policy',
          child: _buildContent(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorTokens.surfacePrimary,
      elevation: 0,
      title: Text(
        'Privacy Policy',
        style: TypographyTokens.heading4,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Go back',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last updated
          Container(
            padding: EdgeInsets.all(DesignTokens.cardPaddingMd),
            decoration: BoxDecoration(
              color: ColorTokens.surfacePrimary,
              borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
              boxShadow: DesignTokens.elevationLow,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: ColorTokens.success500,
                  size: DesignTokens.iconMd,
                ),
                SizedBox(width: DesignTokens.spacing3),
                Text(
                  'Last updated: November 24, 2025',
                  style: TypographyTokens.captionMd.copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

          SizedBox(height: DesignTokens.sectionGapLg),

          // Introduction
          _buildSection(
            title: '1. Introduction',
            content: 'At Budget Tracker, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            delay: 100,
          ),

          // Information We Collect
          _buildSection(
            title: '2. Information We Collect',
            content: 'We collect information you provide directly to us and information we obtain automatically when you use our app.',
            delay: 150,
          ),

          // Information You Provide
          _buildSection(
            title: '3. Information You Provide',
            content: '• Personal Information: Name, email address, phone number (optional)\n• Financial Data: Transaction amounts, categories, budgets, financial goals\n• App Usage Data: Settings preferences, feature usage patterns\n• Support Communications: Messages sent through in-app support features',
            delay: 200,
          ),

          // Automatically Collected Information
          _buildSection(
            title: '4. Automatically Collected Information',
            content: '• Device Information: Device type, operating system, app version\n• Usage Analytics: App usage patterns, feature interactions, crash reports\n• Performance Data: App performance metrics, error logs\n• Location Data: Only if explicitly granted permission for location-based features',
            delay: 250,
          ),

          // How We Use Your Information
          _buildSection(
            title: '5. How We Use Your Information',
            content: 'We use the collected information to:\n\n• Provide and maintain our financial tracking services\n• Process and analyze your financial data\n• Improve app functionality and user experience\n• Send important updates and security notifications\n• Provide customer support\n• Ensure app security and prevent fraud\n• Comply with legal obligations',
            delay: 300,
          ),

          // Data Storage and Security
          _buildSection(
            title: '6. Data Storage and Security',
            content: '• Local Storage: Most of your data is stored locally on your device\n• Cloud Backup: Optional cloud backup for data recovery\n• Encryption: All data is encrypted using industry-standard methods\n• Access Controls: Strict access controls and regular security audits\n• Data Retention: Data is retained only as long as necessary for service provision',
            delay: 350,
          ),

          // Data Sharing and Disclosure
          _buildSection(
            title: '7. Data Sharing and Disclosure',
            content: 'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With your explicit consent\n• To comply with legal obligations\n• To protect our rights and prevent fraud\n• In connection with a business transfer\n• With service providers who assist our operations (under strict confidentiality agreements)',
            delay: 400,
          ),

          // Third-Party Services
          _buildSection(
            title: '8. Third-Party Services',
            content: 'Our app may integrate with third-party services such as:\n\n• Bank connections for transaction import\n• Cloud storage providers for backup\n• Analytics services for app improvement\n• Payment processors for in-app purchases\n\nEach third-party service has its own privacy policy, and we encourage you to review them.',
            delay: 450,
          ),

          // Your Rights and Choices
          _buildSection(
            title: '9. Your Rights and Choices',
            content: 'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Delete your account and data\n• Export your data\n• Opt out of non-essential communications\n• Disable analytics collection\n• Control location permissions\n• Withdraw consent for data processing',
            delay: 500,
          ),

          // Data Deletion and Account Closure
          _buildSection(
            title: '10. Data Deletion and Account Closure',
            content: 'You can delete your account and all associated data at any time through the app settings. Upon deletion:\n\n• All personal data will be permanently removed\n• Financial data will be erased from our servers\n• Local data on your device will remain until you uninstall the app\n• Some anonymized analytics data may be retained for service improvement',
            delay: 550,
          ),

          // Children\'s Privacy
          _buildSection(
            title: '11. Children\'s Privacy',
            content: 'Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information.',
            delay: 600,
          ),

          // International Data Transfers
          _buildSection(
            title: '12. International Data Transfers',
            content: 'Your information may be transferred to and processed in countries other than your own. We ensure that such transfers comply with applicable data protection laws and implement appropriate safeguards to protect your information.',
            delay: 650,
          ),

          // Changes to This Policy
          _buildSection(
            title: '13. Changes to This Privacy Policy',
            content: 'We may update this Privacy Policy from time to time. We will notify you of any changes by:\n\n• Posting the new Privacy Policy within the app\n• Sending you a notification\n• Requiring you to accept the updated policy\n\nYour continued use of the app after changes constitutes acceptance of the new policy.',
            delay: 700,
          ),

          // Contact Us
          _buildSection(
            title: '14. Contact Us',
            content: 'If you have any questions about this Privacy Policy or our data practices, please contact us:\n\n• Through the in-app support feature\n• Email: privacy@budgettracker.com\n• Response time: Within 30 days\n\nWe are committed to addressing your privacy concerns promptly.',
            delay: 750,
          ),

          SizedBox(height: DesignTokens.sectionGapXl),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required int delay,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignTokens.sectionGapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TypographyTokens.heading6,
          ),
          SizedBox(height: DesignTokens.spacing3),
          Text(
            content,
            style: TypographyTokens.bodyMd.copyWith(
              color: ColorTokens.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: delay))
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: delay));
  }
}