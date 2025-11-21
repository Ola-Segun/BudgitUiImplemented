import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// ModernTextField Widget
/// Clean, minimal text input with icon prefix
/// Height: 56px, Border: 1px solid #E5E5EA, Border radius: 12px
/// Padding: 16px horizontal, Icon prefix (optional): 24x24px, gray
/// Placeholder: #8E8E93, Text: #1A1A1A, 17pt
class ModernTextField extends StatefulWidget {
  final String? placeholder;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool enabled;
  final String? label;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

  const ModernTextField({
    super.key,
    this.placeholder,
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.focusNode,
    this.initialValue,
    this.enabled = true,
    this.label,
    this.errorText,
    this.inputFormatters,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: widget.label ?? widget.placeholder,
          hint: widget.placeholder,
          textField: true,
          child: Container(
            height: ModernSizes.textFieldHeight,
            decoration: BoxDecoration(
              color: ModernColors.primaryGray,
              borderRadius: BorderRadius.circular(radius_md),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: spacing_md),
                    child: Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: spacing_sm),
                ],
                if (widget.label != null) ...[
                  Text(
                    widget.label!,
                    style: ModernTypography.labelMedium.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: spacing_sm),
                ],
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                      if (widget.validator != null) {
                        setState(() {
                          _errorText = widget.validator!(value);
                        });
                      }
                    },
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    maxLength: widget.maxLength,
                    inputFormatters: widget.inputFormatters,
                    enabled: widget.enabled,
                    style: ModernTypography.bodyLarge.copyWith(
                      color: widget.enabled ? ModernColors.textPrimary : ModernColors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
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
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
}