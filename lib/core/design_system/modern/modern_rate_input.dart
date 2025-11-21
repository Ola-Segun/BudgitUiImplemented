import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// ModernRateInput Widget
/// Compact input component for entering rates with inline label and percentage icon
/// Numeric keyboard integration, validation for percentage ranges
/// Smooth animations and haptic feedback
class ModernRateInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final ValueChanged<double?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final String? errorText;
  final double? initialValue;
  final int decimalPlaces;
  final double minValue;
  final double maxValue;

  const ModernRateInput({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.errorText,
    this.initialValue,
    this.decimalPlaces = 1,
    this.minValue = 0.0,
    this.maxValue = 100.0,
  });

  @override
  State<ModernRateInput> createState() => _ModernRateInputState();
}

class _ModernRateInputState extends State<ModernRateInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;
  bool _hasFocus = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(
      text: widget.initialValue != null
          ? widget.initialValue!.toStringAsFixed(widget.decimalPlaces)
          : '',
    );
    _focusNode = FocusNode();

    _animationController = AnimationController(
      duration: ModernAnimations.normal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: ModernCurves.easeOut),
    );

    _borderAnimation = Tween<double>(begin: 1.5, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: ModernCurves.easeOut),
    );

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ModernRateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController(
        text: widget.initialValue != null
            ? widget.initialValue!.toStringAsFixed(widget.decimalPlaces)
            : '',
      );
    }
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (_hasFocus) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    } else {
      _animationController.reverse();
    }
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) return null;

    final percentage = double.tryParse(value.replaceAll('%', '').trim());
    if (percentage == null) {
      return 'Please enter a valid percentage';
    }

    if (percentage < widget.minValue) {
      return 'Percentage must be at least ${widget.minValue.toStringAsFixed(1)}%';
    }

    if (percentage > widget.maxValue) {
      return 'Percentage cannot exceed ${widget.maxValue.toStringAsFixed(1)}%';
    }

    return null;
  }

  void _onTextChanged(String value) {
    // Remove any non-numeric characters except decimal point
    final cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');

    // Ensure only one decimal point
    final parts = cleanValue.split('.');
    final sanitizedValue = parts.length > 2
        ? '${parts[0]}.${parts.sublist(1).join()}'
        : cleanValue;

    if (sanitizedValue != value) {
      _controller.value = TextEditingValue(
        text: sanitizedValue,
        selection: TextSelection.collapsed(offset: sanitizedValue.length),
      );
    }

    final doubleValue = double.tryParse(sanitizedValue);
    widget.onChanged?.call(doubleValue);

    final validator = widget.validator ?? _defaultValidator;
    setState(() {
      _errorText = validator(sanitizedValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.errorText != null || _errorText != null
        ? ModernColors.error
        : _hasFocus
            ? ModernColors.accentGreen
            : ModernColors.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: '${widget.label} input',
          hint: 'Enter ${widget.label.toLowerCase()}',
          textField: true,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: ModernSizes.textFieldHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor,
                      width: _borderAnimation.value,
                    ),
                    borderRadius: BorderRadius.circular(radius_md),
                  ),
                  child: Row(
                    children: [
                      // Inline label with icon
                      Padding(
                        padding: const EdgeInsets.only(left: spacing_md),
                        child: Row(
                          children: [
                            Icon(
                              Icons.percent,
                              size: 20,
                              color: ModernColors.textSecondary,
                            ),
                            const SizedBox(width: spacing_sm),
                            Text(
                              widget.label,
                              style: ModernTypography.labelMedium.copyWith(
                                color: ModernColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Input field
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onTextChanged,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          enabled: widget.enabled,
                          style: ModernTypography.bodyLarge.copyWith(
                            color: widget.enabled ? ModernColors.textPrimary : ModernColors.textSecondary,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.${'0' * widget.decimalPlaces}',
                            hintStyle: ModernTypography.bodyLarge.copyWith(
                              color: ModernColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: spacing_md,
                              vertical: spacing_md,
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.errorText != null || _errorText != null) ...[
          const SizedBox(height: spacing_xs),
          Text(
            widget.errorText ?? _errorText ?? '',
            style: ModernTypography.labelSmall.copyWith(
              color: ModernColors.error,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
}