import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../../../core/design_system/patterns/info_card_pattern.dart';
import '../providers/settings_providers.dart';
import '../../domain/services/two_factor_service.dart';

/// Two-Factor Authentication recovery screen
class TwoFactorRecoveryScreen extends ConsumerStatefulWidget {
  const TwoFactorRecoveryScreen({super.key});

  @override
  ConsumerState<TwoFactorRecoveryScreen> createState() => _TwoFactorRecoveryScreenState();
}

class _TwoFactorRecoveryScreenState extends ConsumerState<TwoFactorRecoveryScreen> {
  final TextEditingController _backupCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final TwoFactorService _twoFactorService = TwoFactorService();

  @override
  void dispose() {
    _backupCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: AppBar(
        backgroundColor: ColorTokens.surfacePrimary,
        elevation: 0,
        title: Text(
          'Recover Account',
          style: TypographyTokens.heading4,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recovery Info
            InfoCardPattern(
              title: 'Account Recovery',
              icon: Icons.lock_open,
              iconColor: ColorTokens.warning500,
              children: [
                Text(
                  'Enter one of your backup codes to regain access to your account.',
                  style: TypographyTokens.bodyMd,
                ),
                SizedBox(height: DesignTokens.spacing2),
                Text(
                  'Backup codes were provided when you set up two-factor authentication. Each code can only be used once.',
                  style: TypographyTokens.captionMd.copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Backup Code Input
            InfoCardPattern(
              title: 'Enter Backup Code',
              icon: Icons.vpn_key,
              iconColor: ColorTokens.info500,
              children: [
                TextField(
                  controller: _backupCodeController,
                  decoration: InputDecoration(
                    hintText: 'Enter backup code (e.g., ABCD-1234)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    errorText: _errorMessage,
                    prefixIcon: const Icon(Icons.security),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
                    LengthLimitingTextInputFormatter(12), // Allow for dashes
                  ],
                ),

                SizedBox(height: DesignTokens.spacing3),

                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(DesignTokens.spacing2),
                    decoration: BoxDecoration(
                      color: ColorTokens.withOpacity(ColorTokens.critical500, 0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(color: ColorTokens.critical500.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: ColorTokens.critical500,
                          size: DesignTokens.iconMd,
                        ),
                        SizedBox(width: DesignTokens.spacing2),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TypographyTokens.captionMd.copyWith(
                              color: ColorTokens.critical500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: DesignTokens.spacing4),

                Row(
                  children: [
                    Expanded(
                      child: ActionButtonPattern(
                        label: 'Cancel',
                        variant: ButtonVariant.secondary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: DesignTokens.spacing2),
                    Expanded(
                      child: ActionButtonPattern(
                        label: 'Recover Access',
                        variant: ButtonVariant.primary,
                        onPressed: _verifyBackupCode,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Alternative Recovery Options
            InfoCardPattern(
              title: 'Alternative Recovery',
              icon: Icons.help_outline,
              iconColor: ColorTokens.neutral500,
              children: [
                Text(
                  'If you don\'t have your backup codes:',
                  style: TypographyTokens.bodyMd.copyWith(
                    fontWeight: TypographyTokens.weightSemiBold,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing2),

                _buildRecoveryOption(
                  'Contact Support',
                  'Contact our support team for account recovery assistance',
                  Icons.support_agent,
                  () => _showSupportDialog(),
                ),

                SizedBox(height: DesignTokens.spacing2),

                _buildRecoveryOption(
                  'Reset 2FA',
                  'Temporarily disable 2FA (requires identity verification)',
                  Icons.refresh,
                  () => _showResetDialog(),
                ),

                SizedBox(height: DesignTokens.spacing2),

                Text(
                  'Note: Account recovery may take 24-48 hours and requires additional verification.',
                  style: TypographyTokens.captionMd.copyWith(
                    color: ColorTokens.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
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
                  color: ColorTokens.withOpacity(ColorTokens.teal500, 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(icon, color: ColorTokens.teal500, size: DesignTokens.iconMd),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TypographyTokens.bodyMd),
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

  void _verifyBackupCode() async {
    final code = _backupCodeController.text.trim().toUpperCase().replaceAll('-', '');

    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a backup code';
      });
      return;
    }

    if (code.length != 8) {
      setState(() {
        _errorMessage = 'Backup code must be 8 characters long';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current settings to access hashed backup codes
      final settingsAsync = ref.read(settingsNotifierProvider);
      final settings = settingsAsync.value?.settings;

      if (settings == null || !settings.twoFactorEnabled) {
        setState(() {
          _errorMessage = 'Two-factor authentication is not enabled';
          _isLoading = false;
        });
        return;
      }

      final isValid = _twoFactorService.validateBackupCode(code);

      if (isValid) {
        // Success - navigate to main app
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account recovered successfully!')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        setState(() {
          _errorMessage = 'Invalid backup code. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorTokens.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing2),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.info500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                Icons.support_agent,
                color: ColorTokens.info500,
                size: DesignTokens.iconMd,
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Text(
              'Contact Support',
              style: TypographyTokens.heading5,
            ),
          ],
        ),
        content: Text(
          'Please email support@budgettracker.com with your account email address and a description of your recovery request. Include any additional verification information you can provide.',
          style: TypographyTokens.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Copy support email to clipboard
              Clipboard.setData(const ClipboardData(text: 'support@budgettracker.com'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support email copied to clipboard')),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Copy Email',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.teal500,
                fontWeight: TypographyTokens.weightSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorTokens.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing2),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.warning500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                Icons.refresh,
                color: ColorTokens.warning500,
                size: DesignTokens.iconMd,
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Text(
              'Reset 2FA',
              style: TypographyTokens.heading5,
            ),
          ],
        ),
        content: Text(
          'This will temporarily disable two-factor authentication for your account. You will need to provide additional identity verification and re-enable 2FA after recovery.\n\nThis process may take 24-48 hours.',
          style: TypographyTokens.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to identity verification flow
              _startIdentityVerification();
            },
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.warning500,
            ),
            child: Text(
              'Start Reset',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.warning500,
                fontWeight: TypographyTokens.weightSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startIdentityVerification() {
    // Placeholder for identity verification flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Identity verification flow not yet implemented')),
    );
  }
}