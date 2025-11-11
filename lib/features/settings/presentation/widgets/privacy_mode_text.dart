import 'package:flutter/material.dart';
import '../domain/services/privacy_mode_service.dart';

/// Widget that automatically obscures sensitive text when privacy mode is active
class PrivacyModeText extends StatelessWidget {
  final String text;
  final String? obscuredText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const PrivacyModeText({
    super.key,
    required this.text,
    this.obscuredText,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final privacyService = PrivacyModeService();
    final shouldObscure = privacyService.shouldObscureSensitiveData();
    final displayText = shouldObscure ? (obscuredText ?? '••••') : text;

    return Text(
      displayText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Widget that automatically obscures sensitive amounts when privacy mode is active
class PrivacyModeAmount extends StatelessWidget {
  final double amount;
  final String currency;
  final TextStyle? style;
  final TextAlign? textAlign;

  const PrivacyModeAmount({
    super.key,
    required this.amount,
    this.currency = '\$',
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final privacyService = PrivacyModeService();
    final displayText = privacyService.obscureAmount(amount, currency: currency);

    return Text(
      displayText,
      style: style,
      textAlign: textAlign,
    );
  }
}

/// Widget that provides temporary reveal functionality for sensitive data
class PrivacyModeReveal extends StatefulWidget {
  final Widget child;
  final Duration revealDuration;

  const PrivacyModeReveal({
    super.key,
    required this.child,
    this.revealDuration = const Duration(seconds: 3),
  });

  @override
  State<PrivacyModeReveal> createState() => _PrivacyModeRevealState();
}

class _PrivacyModeRevealState extends State<PrivacyModeReveal> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final privacyService = PrivacyModeService();

    if (!privacyService.shouldObscureSensitiveData()) {
      return widget.child;
    }

    return GestureDetector(
      onTap: _toggleReveal,
      child: widget.child,
    );
  }

  void _toggleReveal() {
    setState(() {
      _isRevealed = !_isRevealed;
    });

    if (_isRevealed) {
      Future.delayed(widget.revealDuration, () {
        if (mounted) {
          setState(() {
            _isRevealed = false;
          });
        }
      });
    }
  }
}