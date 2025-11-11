
/// Service for managing privacy mode functionality
class PrivacyModeService {
  static final PrivacyModeService _instance = PrivacyModeService._internal();
  factory PrivacyModeService() => _instance;
  PrivacyModeService._internal();

  bool _isPrivacyModeEnabled = false;
  bool _isGestureEnabled = true;

  /// Check if privacy mode is currently enabled
  bool get isPrivacyModeEnabled => _isPrivacyModeEnabled;

  /// Check if privacy gesture is enabled
  bool get isGestureEnabled => _isGestureEnabled;

  /// Enable or disable privacy mode
  void setPrivacyMode(bool enabled) {
    _isPrivacyModeEnabled = enabled;
  }

  /// Enable or disable privacy gesture
  void setGestureEnabled(bool enabled) {
    _isGestureEnabled = enabled;
  }

  /// Check if a three-finger double tap gesture should trigger privacy mode
  bool shouldTriggerPrivacyMode() {
    return _isGestureEnabled;
  }

  /// Toggle privacy mode
  void togglePrivacyMode() {
    _isPrivacyModeEnabled = !_isPrivacyModeEnabled;
  }

  /// Get obscured text representation
  String obscureText(String text) {
    if (!_isPrivacyModeEnabled) return text;
    return '•' * text.length;
  }

  /// Get obscured amount representation
  String obscureAmount(double amount, String currency) {
    if (!_isPrivacyModeEnabled) return '$currency${amount.toStringAsFixed(2)}';
    return '$currency••••••';
  }

  /// Temporarily reveal sensitive data
  Future<void> temporarilyReveal() async {
    if (!_isPrivacyModeEnabled) return;
    // Implementation for temporary reveal (e.g., for a few seconds)
    await Future.delayed(const Duration(seconds: 3));
  }
}