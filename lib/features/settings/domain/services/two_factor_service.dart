import 'dart:math';

/// Service for managing two-factor authentication functionality
class TwoFactorService {
  static final TwoFactorService _instance = TwoFactorService._internal();
  factory TwoFactorService() => _instance;
  TwoFactorService._internal();

  bool _isEnabled = false;
  String _method = '';
  final List<String> _backupCodes = [];

  /// Check if 2FA is enabled
  bool get isEnabled => _isEnabled;

  /// Get current 2FA method
  String get method => _method;

  /// Get backup codes
  List<String> get backupCodes => List.unmodifiable(_backupCodes);

  /// Enable 2FA with specified method
  void enable2FA(String method) {
    _isEnabled = true;
    _method = method;
    _generateBackupCodes();
  }

  /// Disable 2FA
  void disable2FA() {
    _isEnabled = false;
    _method = '';
    _backupCodes.clear();
  }

  /// Generate backup codes
  void _generateBackupCodes() {
    _backupCodes.clear();
    final random = Random();
    for (int i = 0; i < 10; i++) {
      final code = List.generate(8, (_) => random.nextInt(10)).join();
      _backupCodes.add(code);
    }
  }

  /// Validate backup code
  bool validateBackupCode(String code) {
    if (_backupCodes.contains(code)) {
      _backupCodes.remove(code);
      return true;
    }
    return false;
  }

  /// Regenerate backup codes
  void regenerateBackupCodes() {
    _generateBackupCodes();
  }

  /// Check if backup codes need regeneration
  bool get needsBackupCodeRegeneration => _backupCodes.length < 5;

  /// Get remaining backup codes count
  int get remainingBackupCodes => _backupCodes.length;

  /// Generate TOTP secret key
  String generateTOTPSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generate QR code URL for TOTP setup
  String generateQRCodeURL(String secret, String email) {
    final issuer = 'BudgetTracker';
    final accountName = email;
    return 'otpauth://totp/$issuer:$accountName?secret=$secret&issuer=$issuer';
  }

  /// Generate backup codes (returns list of plain text codes)
  List<String> generateBackupCodes() {
    _generateBackupCodes();
    return List.from(_backupCodes);
  }

  /// Hash backup codes for storage
  List<String> hashBackupCodes(List<String> codes) {
    // In a real implementation, you would hash these codes
    // For now, just return the codes as-is for demonstration
    return codes;
  }

  /// Send verification code via SMS
  Future<bool> sendSMSCode(String phoneNumber) async {
    // Simulate SMS sending
    await Future.delayed(const Duration(seconds: 2));
    return true; // Assume success for testing
  }

  /// Send verification code via Email
  Future<bool> sendEmailCode(String email) async {
    // Simulate email sending
    await Future.delayed(const Duration(seconds: 2));
    return true; // Assume success for testing
  }

  /// Verify code
  bool verifyCode(String code) {
    // Simple verification - in real app, this would validate against sent code
    return code.length == 6 && int.tryParse(code) != null;
  }

  /// Get 2FA status information
  Map<String, dynamic> getStatus() {
    return {
      'enabled': _isEnabled,
      'method': _method,
      'backupCodesCount': _backupCodes.length,
      'needsRegeneration': needsBackupCodeRegeneration,
    };
  }
}