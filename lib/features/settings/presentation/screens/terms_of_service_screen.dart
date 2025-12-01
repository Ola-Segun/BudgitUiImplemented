import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';

/// Terms of Service screen with proper content and navigation
class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen>
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
          label: 'Terms of Service screen',
          hint: 'Scroll to read the terms of service',
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
        'Terms of Service',
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
                  Icons.update,
                  color: ColorTokens.info500,
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
            content: 'Welcome to Budget Tracker. These Terms of Service ("Terms") govern your use of our mobile application and related services. By using our app, you agree to be bound by these Terms.',
            delay: 100,
          ),

          // Acceptance of Terms
          _buildSection(
            title: '2. Acceptance of Terms',
            content: 'By downloading, installing, or using the Budget Tracker app, you acknowledge that you have read, understood, and agree to be bound by these Terms. If you do not agree to these Terms, please do not use our app.',
            delay: 150,
          ),

          // Description of Service
          _buildSection(
            title: '3. Description of Service',
            content: 'Budget Tracker is a personal finance management application that helps users track expenses, manage budgets, monitor financial goals, and analyze spending patterns. Our service includes:\n\n• Expense and income tracking\n• Budget creation and monitoring\n• Financial goal setting\n• Transaction categorization\n• Financial reports and analytics\n• Data import/export functionality',
            delay: 200,
          ),

          // User Accounts
          _buildSection(
            title: '4. User Accounts',
            content: 'While our app operates primarily offline, certain features may require account creation. You are responsible for:\n\n• Maintaining the confidentiality of your account information\n• All activities that occur under your account\n• Providing accurate and up-to-date information\n• Notifying us immediately of any unauthorized use',
            delay: 250,
          ),

          // Privacy and Data
          _buildSection(
            title: '5. Privacy and Data Protection',
            content: 'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information. By using our app, you also agree to our Privacy Policy.',
            delay: 300,
          ),

          // User Conduct
          _buildSection(
            title: '6. User Conduct',
            content: 'You agree to use the app only for lawful purposes and in accordance with these Terms. You must not:\n\n• Use the app for any illegal or unauthorized purpose\n• Attempt to gain unauthorized access to our systems\n• Interfere with or disrupt the app\'s functionality\n• Use the app to transmit harmful or malicious content\n• Violate any applicable laws or regulations',
            delay: 350,
          ),

          // Intellectual Property
          _buildSection(
            title: '7. Intellectual Property',
            content: 'The Budget Tracker app and its original content, features, and functionality are owned by us and are protected by copyright, trademark, and other intellectual property laws. You may not copy, modify, distribute, or create derivative works without our prior written consent.',
            delay: 400,
          ),

          // Data Ownership
          _buildSection(
            title: '8. Data Ownership and Rights',
            content: 'You retain ownership of your financial data entered into the app. However, by using our service, you grant us a limited license to process and store this data as necessary to provide our services. We do not sell or share your personal financial data with third parties.',
            delay: 450,
          ),

          // Service Availability
          _buildSection(
            title: '9. Service Availability',
            content: 'While we strive to provide continuous service, we do not guarantee that the app will be available at all times. We reserve the right to modify, suspend, or discontinue the service with or without notice.',
            delay: 500,
          ),

          // Limitation of Liability
          _buildSection(
            title: '10. Limitation of Liability',
            content: 'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the app.',
            delay: 550,
          ),

          // Termination
          _buildSection(
            title: '11. Termination',
            content: 'We reserve the right to terminate or suspend your access to our service immediately, without prior notice, for any reason, including breach of these Terms.',
            delay: 600,
          ),

          // Changes to Terms
          _buildSection(
            title: '12. Changes to Terms',
            content: 'We reserve the right to modify these Terms at any time. We will notify users of significant changes through the app or other reasonable means. Continued use of the app after changes constitutes acceptance of the new Terms.',
            delay: 650,
          ),

          // Contact Information
          _buildSection(
            title: '13. Contact Us',
            content: 'If you have any questions about these Terms, please contact us through the app\'s support features or email us at support@budgettracker.com.',
            delay: 700,
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