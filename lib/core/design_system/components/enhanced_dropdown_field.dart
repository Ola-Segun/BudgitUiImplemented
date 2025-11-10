import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../form_tokens.dart';

/// Enhanced dropdown with better UX and animations
class EnhancedDropdownField<T> extends StatefulWidget {
  const EnhancedDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.helper,
    this.validator,
    this.enabled = true,
    this.itemBuilder,
    this.selectedItemBuilder,
  });

  final String label;
  final List<DropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? helper;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget Function(DropdownItem<T>)? itemBuilder;
  final Widget Function(DropdownItem<T>)? selectedItemBuilder;

  @override
  State<EnhancedDropdownField<T>> createState() => _EnhancedDropdownFieldState<T>();
}

class _EnhancedDropdownFieldState<T> extends State<EnhancedDropdownField<T>> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
      child: DropdownButtonFormField<T>(
        initialValue: widget.value,
        focusNode: _focusNode,
        decoration: FormTokens.getDecoration(
          label: widget.label,
          hint: widget.hint,
          helper: widget.helper,
          enabled: widget.enabled,
        ),
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: _isFocused
              ? FormTokens.iconColorFocused
              : FormTokens.iconColor,
        ),
        selectedItemBuilder: widget.selectedItemBuilder != null
            ? (BuildContext context) {
                return widget.items.map((item) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: widget.selectedItemBuilder!(item),
                  );
                }).toList();
              }
            : null,
        items: widget.items.map((item) {
          return DropdownMenuItem<T>(
            value: item.value,
            child: widget.itemBuilder?.call(item) ?? _buildDefaultItem(item),
          );
        }).toList(),
        onChanged: widget.enabled ? widget.onChanged : null,
        validator: widget.validator,
        style: TypographyTokens.bodyMd,
        dropdownColor: ColorTokens.surfacePrimary,
        menuMaxHeight: FormTokens.dropdownMaxHeight,
      ),
    );
  }

  Widget _buildDefaultItem(DropdownItem<T> item) {
    return Row(
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: DesignTokens.iconMd,
            color: item.iconColor ?? ColorTokens.teal500,
          ),
          SizedBox(width: DesignTokens.spacing2),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: TypographyTokens.labelMd,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (item.subtitle != null) ...[
                SizedBox(height: DesignTokens.spacing05),
                Text(
                  item.subtitle!,
                  style: TypographyTokens.captionMd.copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Data class for dropdown items
class DropdownItem<T> {
  const DropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconColor,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
}