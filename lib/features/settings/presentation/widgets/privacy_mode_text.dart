import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

/// Widget that automatically obscures sensitive text when privacy mode is active
class PrivacyModeText extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyService = ref.watch(privacyModeServiceProvider);
    final shouldObscure = privacyService.shouldObscureSensitiveData();

    if (shouldObscure) {
      // When obscured, show a fixed-width container to prevent layout shifts
      return SizedBox(
        width: 60, // Fixed width to prevent layout shifts
        child: Text(
          obscuredText ?? '••••',
          style: style,
          textAlign: textAlign ?? TextAlign.start,
          maxLines: maxLines,
          overflow: overflow ?? TextOverflow.ellipsis,
        ),
      );
    } else {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
  }
}

/// Widget that automatically obscures sensitive amounts when privacy mode is active
class PrivacyModeAmount extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyService = ref.watch(privacyModeServiceProvider);
    final shouldObscure = privacyService.shouldObscureSensitiveData();

    if (shouldObscure) {
      // When obscured, show a fixed-width container to prevent layout shifts
      // Use a width that accommodates typical currency amounts
      return SizedBox(
        width: 80, // Fixed width to prevent layout shifts
        child: Text(
          '••••••',
          style: style,
          textAlign: textAlign ?? TextAlign.end,
        ),
      );
    } else {
      final displayText = privacyService.obscureAmount(amount, currency);
      return Text(
        displayText,
        style: style,
        textAlign: textAlign,
      );
    }
  }
}

/// Widget that provides temporary reveal functionality for sensitive data
class PrivacyModeReveal extends ConsumerStatefulWidget {
  final Widget child;
  final Duration revealDuration;

  const PrivacyModeReveal({
    super.key,
    required this.child,
    this.revealDuration = const Duration(seconds: 3),
  });

  @override
  ConsumerState<PrivacyModeReveal> createState() => _PrivacyModeRevealState();
}

class _PrivacyModeRevealState extends ConsumerState<PrivacyModeReveal> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final privacyService = ref.watch(privacyModeServiceProvider);

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