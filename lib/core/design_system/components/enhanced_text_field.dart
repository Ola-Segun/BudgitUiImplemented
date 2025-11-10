import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../form_tokens.dart';

/// Enhanced text field with built-in validation, animations, and loading states
class EnhancedTextField extends StatefulWidget {
  const EnhancedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.helper,
    this.prefix,
    this.suffix,
    this.validator,
    this.asyncValidator,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.debounceMs = 500,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helper;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final Future<String?> Function(String)? asyncValidator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int debounceMs;

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  String? _validationError;
  bool _isValidating = false;
  Timer? _debounceTimer;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    if (widget.asyncValidator != null) {
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    final text = widget.controller.text;

    if (text.isEmpty) {
      setState(() {
        _validationError = null;
        _isValidating = false;
      });
      _debounceTimer?.cancel();
      return;
    }

    _debounceTimer?.cancel();
    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    _debounceTimer = Timer(Duration(milliseconds: widget.debounceMs), () {
      _runAsyncValidation(text);
    });
  }

  Future<void> _runAsyncValidation(String text) async {
    if (!mounted) return;

    try {
      final error = await widget.asyncValidator!(text);
      if (mounted) {
        setState(() {
          _isValidating = false;
          _validationError = error;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _validationError = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            boxShadow: _isFocused
                ? DesignTokens.elevationGlow(
                    ColorTokens.teal500,
                    alpha: 0.15,
                    spread: 0,
                  )
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: FormTokens.getDecoration(
              label: widget.label,
              hint: widget.hint,
              helper: widget.helper,
              error: _validationError,
              prefix: widget.prefix,
              suffix: widget.suffix,
              enabled: widget.enabled,
              isValidating: _isValidating,
            ),
            validator: widget.validator,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            style: TypographyTokens.bodyMd,
          ),
        ),

        // Instant validation feedback
        if (_validationError != null)
          Padding(
            padding: EdgeInsets.only(
              top: DesignTokens.spacing1,
              left: FormTokens.fieldPaddingH,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: FormTokens.errorColor,
                  size: 14,
                ),
                SizedBox(width: DesignTokens.spacing1),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: TypographyTokens.captionMd.copyWith(
                      color: FormTokens.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
              .fadeIn(duration: DesignTokens.durationSm)
              .slideX(begin: -0.1, duration: DesignTokens.durationSm),
          ),
      ],
    );
  }
}