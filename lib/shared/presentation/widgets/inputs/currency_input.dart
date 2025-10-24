import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/number_extensions.dart';
import 'app_text_field.dart';

/// Currency input component with automatic formatting
class CurrencyInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<double?>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;
  final double? initialValue;
  final String currencySymbol;

  const CurrencyInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.initialValue,
    this.currencySymbol = '\$',
  });

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // Set initial value if provided
    if (widget.initialValue != null) {
      _controller.text = _formatCurrency(widget.initialValue!);
    }

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      // When focused, show raw number for editing
      final numericValue = _parseCurrency(_controller.text);
      if (numericValue != null) {
        _controller.text = numericValue.toString();
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      }
    } else {
      // When unfocused, format as currency
      final numericValue = _parseCurrency(_controller.text);
      if (numericValue != null) {
        _controller.text = _formatCurrency(numericValue);
      }
    }
  }

  void _onTextChanged() {
    if (_hasFocus) {
      // While editing, allow only numeric input
      final text = _controller.text;
      if (text != _previousValue) {
        _previousValue = text;
        final numericValue = _parseCurrency(text);
        widget.onChanged?.call(numericValue);
      }
    }
  }

  double? _parseCurrency(String text) {
    // Remove currency symbol and any non-numeric characters except decimal point
    final cleaned = text.replaceAll(widget.currencySymbol, '').replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }

  String _formatCurrency(double value) {
    return '${widget.currencySymbol}${value.toCurrency().replaceAll('\$', '')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      focusNode: _focusNode,
      label: widget.label,
      hint: widget.hint ?? 'Enter amount',
      errorText: widget.errorText,
      helperText: widget.helperText,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onChanged: (value) {
        if (_hasFocus) {
          final numericValue = _parseCurrency(value);
          widget.onChanged?.call(numericValue);
        }
      },
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      autovalidateMode: widget.autovalidateMode,
      prefixText: _hasFocus ? widget.currencySymbol : null,
    );
  }
}