import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../../../core/design_system/patterns/info_card_pattern.dart';
import '../providers/settings_providers.dart';
import '../../domain/services/two_factor_service.dart';

/// Two-Factor Authentication setup screen
class TwoFactorSetupScreen extends ConsumerStatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  ConsumerState<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends ConsumerState<TwoFactorSetupScreen> {
  String _selectedMethod = '';
  bool _isLoading = false;
  String? _secretKey;
  String? _qrCodeUrl;
  List<String> _backupCodes = [];
  final TwoFactorService _twoFactorService = TwoFactorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: AppBar(
        backgroundColor: ColorTokens.surfacePrimary,
        elevation: 0,
        title: Text(
          'Two-Factor Authentication',
          style: TypographyTokens.heading4,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status
            InfoCardPattern(
              title: 'Current Status',
              icon: Icons.security,
              iconColor: ColorTokens.success500,
              children: [
                Text(
                  'Two-factor authentication is currently disabled.',
                  style: TypographyTokens.bodyMd,
                ),
                SizedBox(height: DesignTokens.spacing2),
                Text(
                  'Add an extra layer of security to your account by requiring a second form of verification.',
                  style: TypographyTokens.bodySm.copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: DesignTokens.sectionGapLg),

            // Method Selection
            InfoCardPattern(
              title: 'Choose Authentication Method',
              icon: Icons.smartphone,
              iconColor: ColorTokens.info500,
              children: [
                _buildMethodOption(
                  'Authenticator App',
                  'Use an authenticator app like Google Authenticator or Authy',
                  Icons.apps,
                  'authenticator',
                ),
                SizedBox(height: DesignTokens.spacing3),
                _buildMethodOption(
                  'SMS',
                  'Receive verification codes via SMS',
                  Icons.sms,
                  'sms',
                ),
                SizedBox(height: DesignTokens.spacing3),
                _buildMethodOption(
                  'Email',
                  'Receive verification codes via email',
                  Icons.email,
                  'email',
                ),
              ],
            ),

            if (_selectedMethod.isNotEmpty) ...[
              SizedBox(height: DesignTokens.sectionGapLg),
              _buildSetupFlow(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String title, String subtitle, IconData icon, String method) {
    final isSelected = _selectedMethod == method;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectMethod(method),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: EdgeInsets.all(DesignTokens.spacing3),
          decoration: BoxDecoration(
            color: isSelected ? ColorTokens.withOpacity(ColorTokens.teal500, 0.1) : ColorTokens.surfaceSecondary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: isSelected ? ColorTokens.teal500 : Colors.transparent,
              width: 2,
            ),
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
                    Text(title, style: TypographyTokens.bodyLg),
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
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: ColorTokens.teal500,
                  size: DesignTokens.iconMd,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupFlow() {
    switch (_selectedMethod) {
      case 'authenticator':
        return _buildAuthenticatorSetup();
      case 'sms':
        return _buildSmsSetup();
      case 'email':
        return _buildEmailSetup();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAuthenticatorSetup() {
    return InfoCardPattern(
      title: 'Setup Authenticator App',
      icon: Icons.qr_code,
      iconColor: ColorTokens.warning500,
      children: [
        Text(
          '1. Install an authenticator app (Google Authenticator, Authy, etc.)',
          style: TypographyTokens.bodyMd,
        ),
        SizedBox(height: DesignTokens.spacing2),
        Text(
          '2. Scan the QR code below with your authenticator app:',
          style: TypographyTokens.bodyMd,
        ),
        SizedBox(height: DesignTokens.spacing3),

        // QR Code placeholder
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('QR Code\nPlaceholder'),
                SizedBox(height: DesignTokens.spacing2),
                Text(
                  'Secret: ${_secretKey ?? 'N/A'}',
                  style: TypographyTokens.captionMd,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: DesignTokens.spacing3),

        // Backup Codes Section
        Container(
          padding: EdgeInsets.all(DesignTokens.spacing3),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceSecondary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backup Codes',
                style: TypographyTokens.bodyLg.copyWith(
                  fontWeight: TypographyTokens.weightSemiBold,
                ),
              ),
              SizedBox(height: DesignTokens.spacing2),
              Text(
                'Save these codes in a safe place. You can use them to access your account if you lose your device.',
                style: TypographyTokens.captionMd,
              ),
              SizedBox(height: DesignTokens.spacing2),
              Wrap(
                spacing: DesignTokens.spacing2,
                runSpacing: DesignTokens.spacing2,
                children: _backupCodes.map((code) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing2,
                    vertical: DesignTokens.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.surfacePrimary,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    border: Border.all(color: ColorTokens.textSecondary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    code,
                    style: TypographyTokens.captionMd.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: TypographyTokens.weightSemiBold,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),

        SizedBox(height: DesignTokens.spacing3),
        Text(
          '3. Enter the 6-digit code from your app:',
          style: TypographyTokens.bodyMd,
        ),
        SizedBox(height: DesignTokens.spacing2),

        TextField(
          decoration: InputDecoration(
            hintText: '000000',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TypographyTokens.heading3,
        ),

        SizedBox(height: DesignTokens.spacing4),

        Row(
          children: [
            Expanded(
              child: ActionButtonPattern(
                label: 'Cancel',
                variant: ButtonVariant.secondary,
                onPressed: _cancelSetup,
              ),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(
              child: ActionButtonPattern(
                label: 'Verify & Enable',
                variant: ButtonVariant.primary,
                onPressed: _verifyAndEnable,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmsSetup() {
    return InfoCardPattern(
      title: 'Setup SMS Authentication',
      icon: Icons.sms,
      iconColor: ColorTokens.success500,
      children: [
        Text(
          'Enter your phone number to receive verification codes:',
          style: TypographyTokens.bodyMd,
        ),
        SizedBox(height: DesignTokens.spacing3),

        TextField(
          decoration: InputDecoration(
            hintText: '+1 (555) 123-4567',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),

        SizedBox(height: DesignTokens.spacing3),

        Text(
          'We will send a verification code to this number.',
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),

        SizedBox(height: DesignTokens.spacing4),

        Row(
          children: [
            Expanded(
              child: ActionButtonPattern(
                label: 'Cancel',
                variant: ButtonVariant.secondary,
                onPressed: _cancelSetup,
              ),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(
              child: ActionButtonPattern(
                label: 'Send Code',
                variant: ButtonVariant.primary,
                onPressed: _sendVerificationCode,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailSetup() {
    return InfoCardPattern(
      title: 'Setup Email Authentication',
      icon: Icons.email,
      iconColor: ColorTokens.info500,
      children: [
        Text(
          'Enter your email address to receive verification codes:',
          style: TypographyTokens.bodyMd,
        ),
        SizedBox(height: DesignTokens.spacing3),

        TextField(
          decoration: InputDecoration(
            hintText: 'your.email@example.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: DesignTokens.spacing3),

        Text(
          'We will send a verification code to this email address.',
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),

        SizedBox(height: DesignTokens.spacing4),

        Row(
          children: [
            Expanded(
              child: ActionButtonPattern(
                label: 'Cancel',
                variant: ButtonVariant.secondary,
                onPressed: _cancelSetup,
              ),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(
              child: ActionButtonPattern(
                label: 'Send Code',
                variant: ButtonVariant.primary,
                onPressed: _sendVerificationCode,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectMethod(String method) {
    setState(() {
      _selectedMethod = method;
      if (method == 'authenticator') {
        _secretKey = _twoFactorService.generateTOTPSecret();
        _qrCodeUrl = _twoFactorService.generateQRCodeURL(_secretKey!, 'user@example.com');
        _backupCodes = _twoFactorService.generateBackupCodes();
      }
    });
  }

  void _cancelSetup() {
    setState(() {
      _selectedMethod = '';
      _secretKey = null;
      _qrCodeUrl = null;
    });
  }

  void _sendVerificationCode() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show verification code input
        _showVerificationCodeDialog();
      }
    });
  }

  void _verifyAndEnable() {
    setState(() {
      _isLoading = true;
    });

    // Simulate verification
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Update settings with backup codes
        final hashedBackupCodes = _twoFactorService.hashBackupCodes(_backupCodes);
        ref.read(settingsNotifierProvider.notifier).updateSetting('twoFactorEnabled', true);
        ref.read(settingsNotifierProvider.notifier).updateSetting('twoFactorMethod', _selectedMethod);
        ref.read(settingsNotifierProvider.notifier).updateSetting('backupCodes', hashedBackupCodes);

        // Show success and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Two-factor authentication enabled successfully!')),
        );

        Navigator.pop(context);
      }
    });
  }

  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit code sent to your device:'),
            SizedBox(height: DesignTokens.spacing3),
            TextField(
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TypographyTokens.heading3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyAndEnable();
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}