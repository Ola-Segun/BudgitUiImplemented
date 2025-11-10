🎨 COMPREHENSIVE FORM & BOTTOM SHEET DESIGN TRANSFORMATION GUIDE
📋 Table of Contents

Design Philosophy for Forms
Complete Form Design System
Enhanced Bottom Sheet Framework
Transformed Form Components
Implementation Examples
Migration Guide


PART 1: DESIGN PHILOSOPHY FOR FORMS
Core Principles
yamlForm Design Philosophy:
  Visual Hierarchy:
    - Clear field grouping with subtle backgrounds
    - Consistent spacing between related fields
    - Progressive disclosure for complex forms
    
  Interaction Design:
    - Smooth animations for all state changes
    - Instant validation feedback (debounced)
    - Clear error states with helpful messages
    - Loading states that don't block interaction
    
  Accessibility:
    - Minimum 48x48 touch targets
    - High contrast labels and hints
    - Screen reader friendly
    - Keyboard navigation support
    
  Mobile-First:
    - Optimized for one-handed use
    - Smart keyboard types
    - Minimal scrolling required
    - Touch-friendly spacing

PART 2: COMPLETE FORM DESIGN SYSTEM
2.1 Enhanced Form Tokens
dart// lib/core/design_system/form_tokens.dart

import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'color_tokens.dart';
import 'typography_tokens.dart';

/// Complete token system for forms
class FormTokens {
  
  // ============================================================================
  // FIELD DIMENSIONS
  // ============================================================================
  
  static const double fieldHeightSm = 40.0;
  static const double fieldHeightMd = 48.0;
  static const double fieldHeightLg = 56.0;
  
  static const double fieldPaddingH = DesignTokens.spacing4;  // 16px
  static const double fieldPaddingV = DesignTokens.spacing3;  // 12px
  
  // ============================================================================
  // FIELD SPACING
  // ============================================================================
  
  static const double fieldGapSm = DesignTokens.spacing3;   // 12px
  static const double fieldGapMd = DesignTokens.spacing4;   // 16px
  static const double fieldGapLg = DesignTokens.spacing5;   // 20px
  
  static const double sectionGap = DesignTokens.spacing6;    // 24px
  static const double groupGap = DesignTokens.spacing2;      // 8px
  
  // ============================================================================
  // FIELD COLORS
  // ============================================================================
  
  static const Color fieldBackground = ColorTokens.surfacePrimary;
  static const Color fieldBackgroundHover = ColorTokens.surfaceSecondary;
  static const Color fieldBackgroundFocused = ColorTokens.surfacePrimary;
  static const Color fieldBackgroundDisabled = ColorTokens.surfaceSecondary;
  
  static const Color fieldBorder = ColorTokens.borderPrimary;
  static const Color fieldBorderHover = ColorTokens.neutral400;
  static const Color fieldBorderFocused = ColorTokens.teal500;
  static const Color fieldBorderError = ColorTokens.critical500;
  static const Color fieldBorderSuccess = ColorTokens.success500;
  static const Color fieldBorderDisabled = ColorTokens.borderSecondary;
  
  // ============================================================================
  // LABEL & TEXT COLORS
  // ============================================================================
  
  static const Color labelColor = ColorTokens.textPrimary;
  static const Color labelColorDisabled = ColorTokens.textTertiary;
  static const Color hintColor = ColorTokens.textSecondary;
  static const Color helperColor = ColorTokens.textSecondary;
  static const Color errorColor = ColorTokens.critical500;
  static const Color successColor = ColorTokens.success500;
  
  // ============================================================================
  // ICON COLORS
  // ============================================================================
  
  static const Color iconColor = ColorTokens.textSecondary;
  static const Color iconColorFocused = ColorTokens.teal500;
  static const Color iconColorError = ColorTokens.critical500;
  static const Color iconColorDisabled = ColorTokens.textTertiary;
  
  // ============================================================================
  // FIELD BORDER RADIUS
  // ============================================================================
  
  static const double fieldRadiusSm = DesignTokens.radiusMd;   // 8px
  static const double fieldRadiusMd = DesignTokens.radiusLg;   // 12px
  static const double fieldRadiusLg = DesignTokens.radiusXl;   // 16px
  
  // ============================================================================
  // VALIDATION INDICATOR
  // ============================================================================
  
  static const double validationIndicatorSize = 16.0;
  static const double validationIndicatorStroke = 2.0;
  
  // ============================================================================
  // DROPDOWN
  // ============================================================================
  
  static const double dropdownMaxHeight = 300.0;
  static const double dropdownItemHeight = 48.0;
  static const double dropdownItemPadding = DesignTokens.spacing4;
  
  // ============================================================================
  // SWITCH & CHECKBOX
  // ============================================================================
  
  static const double switchWidth = 48.0;
  static const double switchHeight = 28.0;
  static const double switchThumbSize = 24.0;
  
  static const double checkboxSize = 20.0;
  static const double checkboxBorderWidth = 2.0;
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get field decoration based on state
  static InputDecoration getDecoration({
    required String label,
    String? hint,
    String? helper,
    String? error,
    Widget? prefix,
    Widget? suffix,
    bool enabled = true,
    bool isValidating = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      errorText: error,
      prefixIcon: prefix,
      suffixIcon: isValidating
          ? SizedBox(
              width: validationIndicatorSize,
              height: validationIndicatorSize,
              child: Padding(
                padding: EdgeInsets.all(DesignTokens.spacing3),
                child: CircularProgressIndicator(
                  strokeWidth: validationIndicatorStroke,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColorFocused),
                ),
              ),
            )
          : suffix,
      enabled: enabled,
      filled: true,
      fillColor: enabled ? fieldBackground : fieldBackgroundDisabled,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderFocused, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderError, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderError, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadiusMd),
        borderSide: BorderSide(color: fieldBorderDisabled, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: fieldPaddingH,
        vertical: fieldPaddingV,
      ),
      labelStyle: TypographyTokens.labelMd.copyWith(
        color: enabled ? labelColor : labelColorDisabled,
      ),
      hintStyle: TypographyTokens.bodyMd.copyWith(
        color: hintColor,
      ),
      helperStyle: TypographyTokens.captionMd.copyWith(
        color: helperColor,
      ),
      errorStyle: TypographyTokens.captionMd.copyWith(
        color: errorColor,
        height: 0.8,
      ),
    );
  }
}
2.2 Enhanced Text Field Component
dart// lib/core/design_system/components/enhanced_text_field.dart

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
        ).animate(target: _isFocused ? 1 : 0)
          .scaleXY(
            begin: 1.0,
            end: 1.01,
            duration: DesignTokens.durationSm,
            curve: DesignTokens.curveEaseOut,
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
2.3 Enhanced Dropdown Field
dart// lib/core/design_system/components/enhanced_dropdown_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        value: widget.value,
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
      ).animate(target: _isFocused ? 1 : 0)
        .scaleXY(
          begin: 1.0,
          end: 1.01,
          duration: DesignTokens.durationSm,
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
2.4 Enhanced Switch Field
dart// lib/core/design_system/components/enhanced_switch_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../form_tokens.dart';

/// Enhanced switch list tile with better visual design
class EnhancedSwitchField extends StatelessWidget {
  const EnhancedSwitchField({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignTokens.durationSm,
      curve: DesignTokens.curveEaseOut,
      decoration: BoxDecoration(
        color: value
            ? ColorTokens.teal500.withValues(alpha: 0.05)
            : ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: value
              ? ColorTokens.teal500.withValues(alpha: 0.3)
              : ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: FormTokens.fieldPaddingH,
              vertical: FormTokens.fieldPaddingV,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(DesignTokens.spacing2),
                    decoration: BoxDecoration(
                      color: (iconColor ?? ColorTokens.teal500)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: Icon(
                      icon,
                      size: DesignTokens.iconMd,
                      color: iconColor ?? ColorTokens.teal500,
                    ),
                  ).animate(target: value ? 1 : 0)
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: DesignTokens.durationSm,
                    ),
                  SizedBox(width: DesignTokens.spacing3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TypographyTokens.labelMd.copyWith(
                          color: enabled
                              ? ColorTokens.textPrimary
                              : ColorTokens.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: DesignTokens.spacing05),
                        Text(
                          subtitle!,
                          style: TypographyTokens.captionMd.copyWith(
                            color: enabled
                                ? ColorTokens.textSecondary
                                : ColorTokens.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Switch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                  activeColor: ColorTokens.teal500,
                  activeTrackColor: ColorTokens.teal500.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(target: value ? 1 : 0)
      .shimmer(
        duration: DesignTokens.durationNormal,
        color: ColorTokens.teal500.withValues(alpha: 0.1),
      );
  }
}

PART 3: ENHANCED BOTTOM SHEET FRAMEWORK
3.1 Enhanced Bottom Sheet Component
dart// lib/core/design_system/components/enhanced_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Enhanced bottom sheet with consistent styling and animations
class EnhancedBottomSheet {
  /// Show a form bottom sheet with enhanced UX
  static Future<T?> showForm<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedFormBottomSheet(
        title: title,
        subtitle: subtitle,
        onClose: onClose,
        actions: actions,
        child: child,
      ),
    );
  }

  /// Show a scrollable content bottom sheet
  static Future<T?> showScrollable<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    double? maxHeight,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedScrollableBottomSheet(
        title: title,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
}

/// Form bottom sheet with fixed header and footer
class _EnhancedFormBottomSheet extends StatefulWidget {
  const _EnhancedFormBottomSheet({
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  @override
  State<_EnhancedFormBottomSheet> createState() => _EnhancedFormBottomSheetState();
}

class _EnhancedFormBottomSheetState extends State<_EnhancedFormBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = screenHeight * 0.9 - keyboardHeight;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: ColorTokens.surfacePrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusXxl),
            ),
            boxShadow: DesignTokens.elevationXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: DesignTokens.spacing2),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              _buildHeader(context),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(DesignTokens.screenPaddingH),
                  child: widget.child,
                ),
              ),

              // Actions (if provided)
              if (widget.actions != null) _buildActions(),

              // KeyboarRetryMVContinuedart              // Keyboard padding
              SizedBox(height: keyboardHeight > 0 ? DesignTokens.spacing2 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorTokens.borderSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TypographyTokens.heading4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                  .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
                if (widget.subtitle != null) ...[
                  SizedBox(height: DesignTokens.spacing1),
                  Text(
                    widget.subtitle!,
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                    .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
                ],
              ],
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Container(
            decoration: BoxDecoration(
              color: ColorTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: IconButton(
              icon: Icon(Icons.close, size: DesignTokens.iconMd),
              onPressed: () {
                widget.onClose?.call();
                Navigator.pop(context);
              },
              color: ColorTokens.textSecondary,
              tooltip: 'Close',
            ),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: DesignTokens.durationNormal, delay: 200.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        border: Border(
          top: BorderSide(
            color: ColorTokens.borderSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: widget.actions!
            .map((action) => Expanded(child: action))
            .toList()
            .fold<List<Widget>>(
              [],
              (list, item) => list.isEmpty
                  ? [item]
                  : [...list, SizedBox(width: DesignTokens.spacing3), item],
            ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
  }
}

/// Scrollable content bottom sheet
class _EnhancedScrollableBottomSheet extends StatefulWidget {
  const _EnhancedScrollableBottomSheet({
    required this.title,
    required this.child,
    this.maxHeight,
  });

  final String title;
  final Widget child;
  final double? maxHeight;

  @override
  State<_EnhancedScrollableBottomSheet> createState() =>
      _EnhancedScrollableBottomSheetState();
}

class _EnhancedScrollableBottomSheetState
    extends State<_EnhancedScrollableBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultMaxHeight = screenHeight * 0.7;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: widget.maxHeight ?? defaultMaxHeight,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.surfacePrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusXxl),
            ),
            boxShadow: DesignTokens.elevationXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: DesignTokens.spacing2),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(DesignTokens.screenPaddingH),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TypographyTokens.heading4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorTokens.surfaceSecondary,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, size: DesignTokens.iconMd),
                        onPressed: () => Navigator.pop(context),
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: ColorTokens.borderSecondary),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(DesignTokens.screenPaddingH),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PART 4: TRANSFORMED FORM COMPONENTS
4.1 Enhanced Add Transaction Bottom Sheet
dart// lib/features/transactions/presentation/widgets/enhanced_add_transaction_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/enhanced_bottom_sheet.dart';
import '../../../../core/design_system/components/enhanced_text_field.dart';
import '../../../../core/design_system/components/enhanced_dropdown_field.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../../../accounts/presentation/providers/account_providers.dart';

/// Enhanced add transaction bottom sheet with modern design
class EnhancedAddTransactionBottomSheet extends ConsumerStatefulWidget {
  const EnhancedAddTransactionBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialType,
  });

  final Future<void> Function(Transaction) onSubmit;
  final TransactionType? initialType;

  @override
  ConsumerState<EnhancedAddTransactionBottomSheet> createState() =>
      _EnhancedAddTransactionBottomSheetState();
}

class _EnhancedAddTransactionBottomSheetState
    extends ConsumerState<EnhancedAddTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedAccountId;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    return EnhancedBottomSheet.showForm(
      context: context,
      title: 'Add Transaction',
      subtitle: 'Track your ${_selectedType.displayName.toLowerCase()}',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transaction Type Selector
            _buildTypeSelector().animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

            SizedBox(height: FormTokens.sectionGap),

            // Amount Field
            EnhancedTextField(
              controller: _amountController,
              label: 'Amount',
              hint: '0.00',
              prefix: Icon(
                Icons.attach_money,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              autofocus: true,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Category Dropdown
            categoryState.when(
              data: (state) {
                final categories = state.getCategoriesByType(_selectedType);
                
                if (_selectedCategoryId == null && categories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedCategoryId = _getSmartDefaultCategoryId(categories);
                      });
                    }
                  });
                }

                return EnhancedDropdownField<String>(
                  label: 'Category',
                  hint: 'Select a category',
                  items: categories.map((category) {
                    return DropdownItem<String>(
                      value: category.id,
                      label: category.name,
                      icon: categoryIconColorService.getIconForCategory(category.id),
                      iconColor: categoryIconColorService.getColorForCategory(category.id),
                    );
                  }).toList(),
                  value: _selectedCategoryId,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading categories: $error'),
            ),

            SizedBox(height: FormTokens.fieldGapMd),

            // Account Dropdown
            accountsAsync.when(
              data: (accounts) {
                if (_selectedAccountId == null && accounts.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedAccountId = accounts.first.id;
                      });
                    }
                  });
                }

                return EnhancedDropdownField<String>(
                  label: 'Account',
                  hint: 'Select an account',
                  items: accounts.map((account) {
                    return DropdownItem<String>(
                      value: account.id,
                      label: account.displayName,
                      subtitle: account.formattedAvailableBalance,
                      icon: Icons.account_balance_wallet,
                      iconColor: Color(account.type.color),
                    );
                  }).toList(),
                  value: _selectedAccountId,
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an account';
                    }
                    return null;
                  },
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading accounts: $error'),
            ),

            SizedBox(height: FormTokens.fieldGapMd),

            // Date Picker
            _buildDatePicker().animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Description Field
            EnhancedTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'e.g., Grocery shopping at Walmart',
              prefix: Icon(
                Icons.description_outlined,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              maxLength: 100,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Receipt Scanning Button
            _buildReceiptButton().animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Note Field
            EnhancedTextField(
              controller: _noteController,
              label: 'Note (optional)',
              hint: 'Additional details...',
              maxLines: 3,
              maxLength: 200,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),
          ],
        ),
      ),
      actions: [
        _buildCancelButton(),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.expense,
              icon: Icons.remove_circle_outline,
              label: 'Expense',
              color: ColorTokens.critical500,
            ),
          ),
          Container(
            width: 1.5,
            height: 48,
            color: ColorTokens.borderSecondary,
          ),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              icon: Icons.add_circle_outline,
              label: 'Income',
              color: ColorTokens.success500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedType = type;
            _selectedCategoryId = null; // Reset category when type changes
          });
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spacing3,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: DesignTokens.iconMd,
                color: isSelected ? color : ColorTokens.textSecondary,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                label,
                style: TypographyTokens.labelMd.copyWith(
                  color: isSelected ? color : ColorTokens.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scaleXY(
        begin: 1.0,
        end: 1.02,
        duration: DesignTokens.durationSm,
      );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            setState(() {
              _selectedDate = date;
            });
          }
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: FormTokens.fieldPaddingH,
            vertical: FormTokens.fieldPaddingV,
          ),
          decoration: BoxDecoration(
            color: FormTokens.fieldBackground,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            border: Border.all(
              color: FormTokens.fieldBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Date',
                      style: TypographyTokens.captionMd.copyWith(
                        color: FormTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing05),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                      style: TypographyTokens.labelMd,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptButton() {
    return OutlinedButton.icon(
      onPressed: _scanReceipt,
      icon: Icon(Icons.camera_alt, size: DesignTokens.iconMd),
      label: Text('Scan Receipt', style: TypographyTokens.labelMd),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, FormTokens.fieldHeightMd),
        side: BorderSide(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        ),
        foregroundColor: ColorTokens.teal500,
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, FormTokens.fieldHeightMd),
        side: BorderSide(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        ),
      ),
      child: Text('Cancel', style: TypographyTokens.labelMd),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms);
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        boxShadow: _isSubmitting
            ? []
            : DesignTokens.elevationColored(ColorTokens.teal500, alpha: 0.3),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(0, FormTokens.fieldHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Add Transaction',
                style: TypographyTokens.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 900.ms);
  }

  String _getSmartDefaultCategoryId(List<TransactionCategory> categories) {
    if (categories.isEmpty) return '';

    final preferredIds = _selectedType == TransactionType.expense
        ? ['food', 'transport', 'shopping']
        : ['salary', 'freelance'];

    for (final preferredId in preferredIds) {
      final category = categories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => categories.first,
      );
      if (category.id == preferredId) return preferredId;
    }

    return categories.first.id;
  }

  Future<void> _scanReceipt() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Text(
          'Receipt Scanner',
          style: TypographyTokens.heading5,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing5),
              decoration: BoxDecoration(
                color: ColorTokens.teal500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 64,
                color: ColorTokens.teal500,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),
            Text(
              'Receipt scanning feature is coming soon!\n\nFor now, you can manually enter transaction details.',
              textAlign: TextAlign.center,
              style: TypographyTokens.bodyMd,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TypographyTokens.labelMd),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccountId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an account and category'),
          backgroundColor: ColorTokens.critical500,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Transaction',
        amount: amount,
        type: _selectedType,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId,
        description: _noteController.text.isNotEmpty
            ? _noteController.text
            : null,
      );

      await widget.onSubmit(transaction);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
4.2 Enhanced Add/Edit Account Bottom Sheet
dart// lib/features/accounts/presentation/widgets/enhanced_add_edit_account_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/enhanced_bottom_sheet.dart';
import '../../../../core/design_system/components/enhanced_text_field.dart';
import '../../../../core/design_system/components/enhanced_dropdown_field.dart';
import '../../../../core/design_system/components/enhanced_switch_field.dart';
import '../../domain/entities/account.dart';

/// Enhanced add/edit account bottom sheet with modern design
class EnhancedAddEditAccountBottomSheet extends StatefulWidget {
  const EnhancedAddEditAccountBottomSheet({
    super.key,
    this.account,
    required this.onSubmit,
  });

  final Account? account;
  final void Function(Account) onSubmit;

  @override
  State<EnhancedAddEditAccountBottomSheet> createRetryMVContinuedart  @override
  State<EnhancedAddEditAccountBottomSheet> createState() =>
      _EnhancedAddEditAccountBottomSheetState();
}

class _EnhancedAddEditAccountBottomSheetState
    extends State<EnhancedAddEditAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _institutionController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _minimumPaymentController = TextEditingController();

  AccountType _selectedType = AccountType.bankAccount;
  String _selectedCurrency = 'USD';
  bool _isActive = true;
  bool _isSubmitting = false;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY'];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      final account = widget.account!;
      _nameController.text = account.name;
      _balanceController.text = account.currentBalance.toStringAsFixed(2);
      _descriptionController.text = account.description ?? '';
      _institutionController.text = account.institution ?? '';
      _accountNumberController.text = account.accountNumber ?? '';
      _selectedType = account.type;
      _selectedCurrency = account.currency;
      _isActive = account.isActive;

      if (account.creditLimit != null) {
        _creditLimitController.text = account.creditLimit!.toStringAsFixed(2);
      }
      if (account.interestRate != null) {
        _interestRateController.text = account.interestRate!.toStringAsFixed(2);
      }
      if (account.minimumPayment != null) {
        _minimumPaymentController.text = account.minimumPayment!.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    _institutionController.dispose();
    _accountNumberController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return EnhancedBottomSheet.showForm(
      context: context,
      title: isEditing ? 'Edit Account' : 'Add Account',
      subtitle: isEditing 
          ? 'Update ${widget.account!.name}'
          : 'Create a new account to track',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Account Type
            _buildSectionHeader(
              'Account Type',
              'Choose the type that best describes this account',
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

            SizedBox(height: FormTokens.groupGap),

            _buildAccountTypeGrid().animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationNormal, delay: 100.ms),

            SizedBox(height: FormTokens.sectionGap),

            // Section: Basic Information
            _buildSectionHeader(
              'Basic Information',
              'Essential details about your account',
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

            SizedBox(height: FormTokens.groupGap),

            // Account Name
            EnhancedTextField(
              controller: _nameController,
              label: 'Account Name',
              hint: 'e.g., Main Checking',
              prefix: Icon(
                Icons.account_balance_wallet,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Account name is required';
                }
                return null;
              },
              autofocus: !isEditing,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Balance
            EnhancedTextField(
              controller: _balanceController,
              label: 'Current Balance',
              hint: '0.00',
              prefix: Icon(
                Icons.attach_money,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Balance is required';
                }
                final balance = double.tryParse(value);
                if (balance == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Currency
            EnhancedDropdownField<String>(
              label: 'Currency',
              items: _currencies.map((currency) {
                return DropdownItem<String>(
                  value: currency,
                  label: currency,
                  icon: Icons.currency_exchange,
                  iconColor: ColorTokens.teal500,
                );
              }).toList(),
              value: _selectedCurrency,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

            SizedBox(height: FormTokens.sectionGap),

            // Section: Optional Details
            _buildSectionHeader(
              'Optional Details',
              'Additional information (can be added later)',
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 600.ms),

            SizedBox(height: FormTokens.groupGap),

            // Institution
            EnhancedTextField(
              controller: _institutionController,
              label: 'Institution (optional)',
              hint: 'e.g., Bank of America',
              prefix: Icon(
                Icons.business,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Account Number
            EnhancedTextField(
              controller: _accountNumberController,
              label: 'Account Number (optional)',
              hint: 'e.g., ****1234',
              prefix: Icon(
                Icons.numbers,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Description
            EnhancedTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'Additional notes about this account',
              maxLines: 2,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms),

            // Type-specific fields
            ..._buildTypeSpecificFields(),

            SizedBox(height: FormTokens.sectionGap),

            // Active Status
            EnhancedSwitchField(
              title: 'Account is Active',
              subtitle: 'Inactive accounts are hidden from calculations',
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              icon: Icons.visibility,
              iconColor: ColorTokens.teal500,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 1000.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1000.ms),
          ],
        ),
      ),
      actions: [
        _buildCancelButton(),
        _buildSubmitButton(isEditing),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TypographyTokens.heading6.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          subtitle,
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth < 360 ? 2 : 3;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: DesignTokens.spacing2,
          crossAxisSpacing: DesignTokens.spacing2,
          childAspectRatio: 1.1,
          children: AccountType.values.map((type) {
            final isSelected = _selectedType == type;
            final typeColor = Color(type.color);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedType = type;
                  });
                },
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                child: AnimatedContainer(
                  duration: DesignTokens.durationSm,
                  curve: DesignTokens.curveEaseOut,
                  padding: EdgeInsets.all(DesignTokens.spacing3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? typeColor.withValues(alpha: 0.1)
                        : ColorTokens.surfaceSecondary,
                    border: Border.all(
                      color: isSelected
                          ? typeColor
                          : ColorTokens.borderSecondary,
                      width: isSelected ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    boxShadow: isSelected
                        ? DesignTokens.elevationGlow(
                            typeColor,
                            alpha: 0.2,
                            spread: 0,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(DesignTokens.spacing2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                        child: Icon(
                          _getIconData(type.icon),
                          color: typeColor,
                          size: DesignTokens.iconLg,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacing2),
                      Flexible(
                        child: Text(
                          type.displayName,
                          style: TypographyTokens.labelSm.copyWith(
                            color: isSelected ? typeColor : ColorTokens.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ).animate(target: isSelected ? 1 : 0)
                  .scaleXY(
                    begin: 1.0,
                    end: 1.05,
                    duration: DesignTokens.durationSm,
                  ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  List<Widget> _buildTypeSpecificFields() {
    switch (_selectedType) {
      case AccountType.creditCard:
        return [
          SizedBox(height: FormTokens.sectionGap),
          _buildSectionHeader(
            'Credit Card Details',
            'Specific information for credit cards',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 1100.ms),
          SizedBox(height: FormTokens.groupGap),
          EnhancedTextField(
            controller: _creditLimitController,
            label: 'Credit Limit',
            hint: '5000.00',
            prefix: Icon(
              Icons.credit_card,
              color: FormTokens.iconColor,
              size: DesignTokens.iconMd,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final limit = double.tryParse(value);
                if (limit == null || limit <= 0) {
                  return 'Please enter a valid credit limit';
                }
                final balance = double.tryParse(_balanceController.text) ?? 0;
                if (balance > limit) {
                  return 'Balance cannot exceed credit limit';
                }
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1200.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1200.ms),
          SizedBox(height: FormTokens.fieldGapMd),
          EnhancedTextField(
            controller: _minimumPaymentController,
            label: 'Minimum Payment (optional)',
            hint: '25.00',
            prefix: Icon(
              Icons.payment,
              color: FormTokens.iconColor,
              size: DesignTokens.iconMd,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1300.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1300.ms),
        ];

      case AccountType.loan:
        return [
          SizedBox(height: FormTokens.sectionGap),
          _buildSectionHeader(
            'Loan Details',
            'Specific information for loans',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 1100.ms),
          SizedBox(height: FormTokens.groupGap),
          EnhancedTextField(
            controller: _interestRateController,
            label: 'Interest Rate (%)',
            hint: '5.5',
            suffix: Padding(
              padding: EdgeInsets.only(right: DesignTokens.spacing2),
              child: Text(
                '%',
                style: TypographyTokens.labelMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final rate = double.tryParse(value);
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Please enter a valid interest rate (0-100%)';
                }
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1200.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1200.ms),
          SizedBox(height: FormTokens.fieldGapMd),
          EnhancedTextField(
            controller: _minimumPaymentController,
            label: 'Monthly Payment (optional)',
            hint: '150.00',
            prefix: Icon(
              Icons.payment,
              color: FormTokens.iconColor,
              size: DesignTokens.iconMd,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1300.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1300.ms),
        ];

      default:
        return [];
    }
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, FormTokens.fieldHeightMd),
        side: BorderSide(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        ),
      ),
      child: Text('Cancel', style: TypographyTokens.labelMd),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1400.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1400.ms);
  }

  Widget _buildSubmitButton(bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        boxShadow: _isSubmitting
            ? []
            : DesignTokens.elevationColored(ColorTokens.teal500, alpha: 0.3),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(0, FormTokens.fieldHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isEditing ? 'Update Account' : 'Add Account',
                style: TypographyTokens.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1500.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1500.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 1500.ms);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'trending_up':
        return Icons.trending_up;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Future<void> _submitAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final balance = double.parse(_balanceController.text);
      final creditLimit = _creditLimitController.text.isNotEmpty
          ? double.tryParse(_creditLimitController.text)
          : null;
      final interestRate = _interestRateController.text.isNotEmpty
          ? double.tryParse(_interestRateController.text)
          : null;
      final minimumPayment = _minimumPaymentController.text.isNotEmpty
          ? double.tryParse(_minimumPaymentController.text)
          : null;

      final account = Account(
        id: widget.account?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: balance,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        institution: _institutionController.text.isNotEmpty
            ? _institutionController.text.trim()
            : null,
        accountNumber: _accountNumberController.text.isNotEmpty
            ? _accountNumberController.text.trim()
            : null,
        currency: _selectedCurrency,
        createdAt: widget.account?.createdAt,
        updatedAt: DateTime.now(),
        creditLimit: creditLimit,
        interestRate: interestRate,
        minimumPayment: minimumPayment,
        isActive: _isActive,
      );

      widget.onSubmit(account);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${widget.account != null ? 'update' : 'create'} account: ${e.toString()}',
            ),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

PART 5: MIGRATION GUIDE
5.1 Step-by-Step Migration Process
markdown# Form & Bottom Sheet Migration Checklist

## Phase 1: Setup (Week 1)
- [ ] Copy FormTokens to `lib/core/design_system/form_tokens.dart`
- [ ] Copy EnhancedTextField to `lib/core/design_system/components/`
- [ ] Copy EnhancedDropdownField to `lib/core/design_system/components/`
- [ ] Copy EnhancedSwitchField to `lib/core/design_system/components/`
- [ ] Copy EnhancedBottomSheet to `lib/core/design_system/components/`

## Phase 2: Component Migration (Week 2)
- [ ] Replace AddTransactionBottomSheet with Enhanced version
- [ ] Replace AddEditAccountBottomSheet with Enhanced version
- [ ] Replace EditBillBottomSheet with Enhanced version
- [ ] Replace BudgetCreationScreen forms with Enhanced components
- [ ] Update TransactionDetailBottomSheet

## Phase 3: Testing & Refinement (Week 3)
- [ ] Test all forms on multiple screen sizes
- [ ] Verify validation behavior
- [ ] Test keyboard handling
- [ ] Verify animations are smooth (60fps)
- [ ] Test with screen readers
- [ ] Test dark mode compatibility (if supported)

## Phase 4: Documentation (Week 4)
- [ ] Document new form patterns
- [ ] Create form component examples
- [ ] Update team guidelines
- [ ] Create migration guide for remaining forms
5.2 Quick Migration Examples
Before (Old Style)
dartTextFormField(
  controller: _nameController,
  decoration: const InputDecoration(
    labelText: 'Name',
    hintText: 'Enter name',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  },
)
After (Enhanced Style)
dartEnhancedTextField(
  controller: _nameController,
  label: 'Name',
  hint: 'Enter name',
  prefix: Icon(
    Icons.person,
    color: FormTokens.iconColor,
    size: DesignTokens.iconMd,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  },
).animate()
  .fadeIn(duration: DesignTokens.durationNormal)
  .slideX(begin: 0.1, duration: DesignTokens.durationNormal)

PART 6: COMPLETE REFERENCE
6.1 Form Component Quick Reference
dart/// FORM COMPONENTS QUICK REFERENCE

// 1. TEXT FIELD
EnhancedTextField(
  controller: controller,
  label: 'Label',
  hint: 'Hint text',
  prefix: Icon(Icons.icon),
  validator: (value) => value?.isEmpty ?? true ? 'Error' : null,
  asyncValidator: (value) async {
    // Async validation logic
    return null; // or error string
  },
)

// 2. DROPDOWN
EnhancedDropdownField<String>(
  label: 'Select Option',
  items: [
    DropdownItem(
      value: 'value',
      label: 'Display Label',
      subtitle: 'Optional subtitle',
      icon: Icons.icon,
      iconColor: ColorTokens.teal500,
    ),
  ],
  value: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
)

// 3. SWITCH
EnhancedSwitchField(
  title: 'Toggle Option',
  subtitle: 'Description of what this does',
  value: isEnabled,
  onChanged: (value) => setState(() => isEnabled = value),
  icon: Icons.toggle_on,
  iconColor: ColorTokens.teal500,
)

// 4. BOTTOM SHEET
EnhancedBottomSheet.showForm(
  context: context,
  title: 'Form Title',
  subtitle: 'Optional subtitle',
  child: Form(/* form content */),
  actions: [
    cancelButton,
    submitButton,
  ],
)
6.2 Animation Patterns
dart/// STANDARD FORM ANIMATION PATTERN

// Stagger animations for form fields
field1.animate()
  .fadeIn(duration: DesignTokens.durationNormal)
  .slideX(begin: 0.1, duration: DesignTokens.durationNormal)

field2.animate()
  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms)

field3.animate()
  .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms)

// Section headers
header.animate()
  .fadeIn(duration: DesignTokens.durationNormal)
  .slideX(begin: -0.1, duration: DesignTokens.durationNormal)

// Action buttons
button.animate()
  .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms)
  .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 800.ms)

🎯 SUMMARY
This comprehensive design system transformation provides:
✅ Consistent Form Design - All forms follow the same visual language
✅ Enhanced User Experience - Smooth animations, instant validation, clear feedback
✅ Reusable Components - Build new forms faster with pre-built components
✅ Accessibility Built-in - Proper contrast, touch targets, screen reader support
✅ Mobile-Optimized - Touch-friendly spacing, smart keyboards, minimal scrolling
✅ Professional Polish - Modern animations, gradient buttons, glowing focus statesRetryMVContinuePART 7: REMAINING FORM TRANSFORMATIONS
7.1 Enhanced Bill Creation/Edit Forms
dart// lib/features/bills/presentation/widgets/enhanced_bill_form.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/enhanced_bottom_sheet.dart';
import '../../../../core/design_system/components/enhanced_text_field.dart';
import '../../../../core/design_system/components/enhanced_dropdown_field.dart';
import '../../../../core/design_system/components/enhanced_switch_field.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../accounts/presentation/providers/account_providers.dart';

/// Enhanced bill form with modern design and validation
class EnhancedBillForm extends ConsumerStatefulWidget {
  const EnhancedBillForm({
    super.key,
    this.bill,
    required this.onSubmit,
  });

  final Bill? bill;
  final Future<void> Function(Bill) onSubmit;

  @override
  ConsumerState<EnhancedBillForm> createState() => _EnhancedBillFormState();
}

class _EnhancedBillFormState extends ConsumerState<EnhancedBillForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payeeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  BillFrequency _selectedFrequency = BillFrequency.monthly;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedCategoryId;
  String? _selectedAccountId;
  bool _isAutoPay = false;
  bool _isSubmitting = false;

  // Reactive validation
  String? _nameValidationError;
  bool _isValidatingName = false;
  String _lastValidatedName = '';

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _initializeFromBill(widget.bill!);
    }
  }

  void _initializeFromBill(Bill bill) {
    _nameController.text = bill.name;
    _amountController.text = bill.amount.toString();
    _descriptionController.text = bill.description ?? '';
    _payeeController.text = bill.payee ?? '';
    _websiteController.text = bill.website ?? '';
    _notesController.text = bill.notes ?? '';
    _selectedFrequency = bill.frequency;
    _selectedDueDate = bill.dueDate;
    _selectedCategoryId = bill.categoryId;
    _selectedAccountId = bill.accountId;
    _isAutoPay = bill.isAutoPay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _payeeController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bill != null;
    final categoryState = ref.watch(categoryNotifierProvider);
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    return EnhancedBottomSheet.showForm(
      context: context,
      title: isEditing ? 'Edit Bill' : 'Add Bill',
      subtitle: isEditing 
          ? 'Update ${widget.bill!.name}'
          : 'Track a recurring bill',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Basic Information
            _buildSectionHeader(
              'Basic Information',
              'Essential details about your bill',
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

            SizedBox(height: FormTokens.groupGap),

            // Bill Name with async validation
            EnhancedTextField(
              controller: _nameController,
              label: 'Bill Name',
              hint: 'e.g., Electricity Bill',
              prefix: Icon(
                Icons.receipt_long,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a bill name';
                }
                if (value.trim().length < 2) {
                  return 'Bill name must be at least 2 characters';
                }
                return null;
              },
              asyncValidator: (value) => _validateBillName(value),
              autofocus: !isEditing,
              debounceMs: 500,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Amount
            EnhancedTextField(
              controller: _amountController,
              label: 'Amount',
              hint: '0.00',
              prefix: Icon(
                Icons.attach_money,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Category
            categoryState.when(
              data: (state) {
                final expenseCategories = state.getCategoriesByType(
                  TransactionType.expense,
                );

                if (_selectedCategoryId == null && expenseCategories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedCategoryId = _getSmartDefaultCategoryId(
                          expenseCategories,
                        );
                      });
                    }
                  });
                }

                return EnhancedDropdownField<String>(
                  label: 'Category',
                  hint: 'Select a category',
                  items: expenseCategories.map((category) {
                    return DropdownItem<String>(
                      value: category.id,
                      label: category.name,
                      icon: categoryIconColorService.getIconForCategory(category.id),
                      iconColor: categoryIconColorService.getColorForCategory(category.id),
                    );
                  }).toList(),
                  value: _selectedCategoryId,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),

            SizedBox(height: FormTokens.sectionGap),

            // Section: Schedule
            _buildSectionHeader(
              'Schedule',
              'When and how often this bill recurs',
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

            SizedBox(height: FormTokens.groupGap),

            // Frequency
            EnhancedDropdownField<BillFrequency>(
              label: 'Frequency',
              items: BillFrequency.values.map((frequency) {
                return DropdownItem<BillFrequency>(
                  value: frequency,
                  label: frequency.displayName,
                  icon: _getFrequencyIcon(frequency),
                  iconColor: ColorTokens.purple600,
                );
              }).toList(),
              value: _selectedFrequency,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFrequency = value;
                  });
                }
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Due Date
            _buildDatePicker().animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),

            SizedBox(height: FormTokens.sectionGap),

            // Section: Payment Account
            _buildSectionHeader(
              'Payment Account (Optional)',
              'Choose which account to use for automatic payments',
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

            SizedBox(height: FormTokens.groupGap),

            // Account Selection
            accountsAsync.when(
              data: (accounts) {
                // Smart default for new bills only
                if (!isEditing && _selectedAccountId == null && accounts.isNotEmpty) {
                  final defaultAccount = accounts.firstWhere(
                    (account) => account.type == AccountType.bankAccount && account.isActive,
                    orElse: () => accounts.firstWhere(
                      (account) => account.isActive,
                      orElse: () => accounts.first,
                    ),
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedAccountId = defaultAccount.id;
                      });
                    }
                  });
                }

                return Column(
                  children: [
                    EnhancedDropdownField<String>(
                      label: 'Default Account',
                      hint: 'No account selected',
                      items: [
                        DropdownItem<String>(
                          value: '',
                          label: 'No account selected',
                          icon: Icons.close,
                          iconColor: ColorTokens.textSecondary,
                        ),
                        ...accounts.map((account) {
                          return DropdownItem<String>(
                            value: account.id,
                            label: account.displayName,
                            subtitle: account.formattedAvailableBalance,
                            icon: Icons.account_balance_wallet,
                            iconColor: Color(account.type.color),
                          );
                        }),
                      ],
                      value: _selectedAccountId ?? '',
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountId = value?.isEmpty ?? true ? null : value;
                        });
                      },
                    ),
                    if (_selectedAccountId != null && _selectedAccountId!.isNotEmpty) ...[
                      SizedBox(height: DesignTokens.spacing2),
                      _buildAccountInfoBox(
                        accounts.firstWhere((a) => a.id == _selectedAccountId),
                      ),
                    ],
                  ],
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),

            SizedBox(height: FormTokens.fieldGapMd),

            // Auto Pay Switch
            EnhancedSwitchField(
              title: 'Auto Pay',
              subtitle: 'Automatically pay this bill when due',
              value: _isAutoPay,
              onChanged: (value) {
                setState(() {
                  _isAutoPay = value;
                });
              },
              icon: Icons.autorenew,
              iconColor: ColorTokens.success500,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms),

            SizedBox(height: FormTokens.sectionGap),

            // Section: Additional Details
            _buildSectionHeader(
              'Additional Details (Optional)',
              'Extra information about this bill',
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 1000.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 1000.ms),

            SizedBox(height: FormTokens.groupGap),

            // Payee
            EnhancedTextField(
              controller: _payeeController,
              label: 'Payee (optional)',
              hint: 'e.g., Electric Company',
              prefix: Icon(
                Icons.business,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1100.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Description
            EnhancedTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'Additional details about this bill',
              maxLines: 2,
              maxLength: 200,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 1200.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1200.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Website
            EnhancedTextField(
              controller: _websiteController,
              label: 'Website (optional)',
              hint: 'https://example.com',
              prefix: Icon(
                Icons.link,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              keyboardType: TextInputType.url,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 1300.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1300.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Notes
            EnhancedTextField(
              controller: _notesController,
              label: 'Notes (optional)',
              hint: 'Any additional notes',
              maxLines: 3,
              maxLength: 500,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 1400.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1400.ms),
          ],
        ),
      ),
      actions: [
        _buildCancelButton(),
        _buildSubmitButton(isEditing),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TypographyTokens.heading6.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          subtitle,
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDueDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          );
          if (date != null) {
            setState(() {
              _selectedDueDate = date;
            });
          }
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: FormTokens.fieldPaddingH,
            vertical: FormTokens.fieldPaddingV,
          ),
          decoration: BoxDecoration(
            color: FormTokens.fieldBackground,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            border: Border.all(
              color: FormTokens.fieldBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Due Date',
                      style: TypographyTokens.captionMd.copyWith(
                        color: FormTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing05),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDueDate),
                      style: TypographyTokens.labelMd,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoBox(Account account) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.teal500.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.teal500.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ColorTokens.teal500,
            size: DesignTokens.iconMd,
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: Text(
              'Payments will be deducted from ${account.displayName}',
              style: TypographyTokens.captionMd.copyWith(
                color: ColorTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, FormTokens.fieldHeightMd),
        side: BorderSide(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        ),
      ),
      child: Text('Cancel', style: TypographyTokens.labelMd),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1500.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1500.ms);
  }

  Widget _buildSubmitButton(bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        boxShadow: _isSubmitting
            ? []
            : DesignTokens.elevationColored(ColorTokens.teal500, alpha: 0.3),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(0, FormTokens.fieldHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isEditing ? 'Update Bill' : 'Add Bill',
                style: TypographyTokens.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1600.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1600.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 1600.ms);
  }

  IconData _getFrequencyIcon(BillFrequency frequency) {
    switch (frequency) {
      case BillFrequency.weekly:
        return Icons.calendar_view_week;
      case BillFrequency.biweekly:
        return Icons.calendar_view_month;
      case BillFrequency.monthly:
        return Icons.calendar_month;
      case BillFrequency.quarterly:
        return Icons.event_repeat;
      case BillFrequency.yearly:
        return Icons.event;
      case BillFrequency.custom:
        return Icons.tune;
    }
  }

  String _getSmartDefaultCategoryId(List<TransactionCategory> categories) {
    if (categories.isEmpty) return '';

    final preferredIds = ['utilities', 'other'];
    for (final preferredId in preferredIds) {
      final category = categories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => categories.first,
      );
      if (category.id == preferredId) return preferredId;
    }

    return categories.first.id;
  }

  Future<String?> _validateBillName(String name) async {
    if (name.trim().isEmpty) return null;

    try {
      final billState = ref.read(billNotifierProvider);
      final existingBills = billState.maybeWhen(
        loaded: (bills, summary) => bills,
        orElse: () => <Bill>[],
      );

      final isDuplicate = existingBills.any(
        (bill) =>
            bill.id != widget.bill?.id &&
            bill.name.trim().toLowerCase() == name.toLowerCase(),
      );

      return isDuplicate ? 'A bill with this name already exists' : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);

      final bill = widget.bill?.copyWith(
            name: _nameController.text.trim(),
            amount: amount,
            dueDate: _selectedDueDate,
            frequency: _selectedFrequency,
            categoryId: _selectedCategoryId!,
            accountId: _selectedAccountId,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            payee: _payeeController.text.trim().isNotEmpty
                ? _payeeController.text.trim()
                : null,
            isAutoPay: _isAutoPay,
            website: _websiteController.text.trim().isNotEmpty
                ? _websiteController.text.trim()
                : null,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          ) ??
          Bill(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            amount: amount,
            dueDate: _selectedDueDate,
            frequency: _selectedFrequency,
            categoryId: _selectedCategoryId!,
            accountId: _selectedAccountId,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            payee: _payeeController.text.trim().isNotEmpty
                ? _payeeController.text.trim()
                : null,
            isAutoPay: _isAutoPay,
            website: _websiteController.text.trim().isNotEmpty
                ? _websiteController.text.trim()
                : null,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      await widget.onSubmit(bill);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

7.2 Enhanced Budget Creation Form
dart// lib/features/budgets/presentation/widgets/enhanced_budget_form.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/enhanced_text_field.dart';
import '../../../../core/design_system/components/enhanced_dropdown_field.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_template.dart';
import '../providers/budget_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Enhanced budget creation form with category management
class EnhancedBudgetForm extends ConsumerStatefulWidget {
  const EnhancedBudgetForm({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function(Budget) onSubmit;

  @override
  ConsumerState<EnhancedBudgetForm> createState() =>
      _EnhancedBudgetFormState();
}

class _EnhancedBudgetFormState extends ConsumerState<EnhancedBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  BudgetType _selectedType = BudgetType.custom;
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime _createdAt = DateTime.now();
  final List<BudgetCategoryFormData> _categories = [];
  String _selectedTemplate = 'None (Custom)';
  bool _isLoadingTemplate = false;
  bool _isSubmitting = false;

  double _totalBudget = 0.0;
  Timer? _debounceTimer;
  bool _isTotalUpdating = false;

  @override
  void initState() {
    super.initState();
    _addCategory();
    _updateTotalBudget();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _debounceTimer?.cancel();
    for (final category in _categories) {
      category.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(DesignTokens.screenPaddingH),
        children: [
          // Template Selector
          _buildSectionHeader(
            'Start with Template (Optional)',RetryMVContinuedart            'Choose a pre-configured budget template or create custom',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

          SizedBox(height: FormTokens.groupGap),

          EnhancedDropdownField<String>(
            label: 'Template',
            items: [
              DropdownItem<String>(
                value: 'None (Custom)',
                label: 'None (Custom)',
                icon: Icons.edit,
                iconColor: ColorTokens.neutral500,
              ),
              DropdownItem<String>(
                value: '50/30/20 Rule',
                label: '50/30/20 Rule',
                subtitle: 'Needs 50%, Wants 30%, Savings 20%',
                icon: Icons.account_balance_wallet,
                iconColor: ColorTokens.success500,
              ),
            ],
            value: _selectedTemplate,
            onChanged: _isLoadingTemplate
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTemplate = value;
                      });
                      _onTemplateChanged(value);
                    }
                  },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

          SizedBox(height: FormTokens.sectionGap),

          // Section: Basic Information
          _buildSectionHeader(
            'Basic Information',
            'Name and describe your budget',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

          SizedBox(height: FormTokens.groupGap),

          // Budget Name with async validation
          EnhancedTextField(
            controller: _nameController,
            label: 'Budget Name',
            hint: 'e.g., Monthly Expenses',
            prefix: Icon(
              Icons.folder_outlined,
              color: FormTokens.iconColor,
              size: DesignTokens.iconMd,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a budget name';
              }
              if (value.trim().length < 2) {
                return 'Budget name must be at least 2 characters';
              }
              return null;
            },
            asyncValidator: (value) => _validateBudgetName(value),
            autofocus: true,
            debounceMs: 500,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Description
          EnhancedTextField(
            controller: _descriptionController,
            label: 'Description (optional)',
            hint: 'Describe your budget...',
            maxLines: 2,
            maxLength: 200,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Budget Type
          EnhancedDropdownField<BudgetType>(
            label: 'Budget Type',
            items: BudgetType.values.map((type) {
              return DropdownItem<BudgetType>(
                value: type,
                label: type.displayName,
                icon: _getBudgetTypeIcon(type),
                iconColor: ColorTokens.purple600,
              );
            }).toList(),
            value: _selectedType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

          SizedBox(height: FormTokens.sectionGap),

          // Section: Budget Period
          _buildSectionHeader(
            'Budget Period',
            'When this budget starts and ends',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 600.ms),

          SizedBox(height: FormTokens.groupGap),

          // Date Range
          Row(
            children: [
              Expanded(
                child: _buildDateTimePicker(
                  label: 'Start Date & Time',
                  date: _createdAt,
                  onDateSelected: (date) {
                    setState(() {
                      _createdAt = date;
                      if (_endDate.isBefore(_createdAt)) {
                        _endDate = _createdAt.add(const Duration(days: 30));
                      }
                    });
                  },
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: _buildDateTimePicker(
                  label: 'End Date & Time',
                  date: _endDate,
                  onDateSelected: (date) {
                    setState(() {
                      _endDate = date;
                    });
                  },
                  firstDate: _createdAt,
                  lastDate: _createdAt.add(const Duration(days: 365)),
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

          SizedBox(height: FormTokens.sectionGap),

          // Section: Budget Categories
          _buildCategoriesSection(categoryState, categoryIconColorService),

          SizedBox(height: FormTokens.sectionGap),

          // Total Budget Display
          _buildTotalBudgetCard().animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1000.ms)
            .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationNormal, delay: 1000.ms),

          SizedBox(height: FormTokens.sectionGap),

          // Action Buttons
          Row(
            children: [
              Expanded(child: _buildCancelButton()),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(child: _buildSubmitButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TypographyTokens.heading6.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          subtitle,
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onDateSelected,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: firstDate,
            lastDate: lastDate,
          );
          if (selectedDate != null) {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(date),
            );
            onDateSelected(DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime?.hour ?? date.hour,
              selectedTime?.minute ?? date.minute,
            ));
          }
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: Container(
          padding: EdgeInsets.all(DesignTokens.spacing3),
          decoration: BoxDecoration(
            color: FormTokens.fieldBackground,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            border: Border.all(
              color: FormTokens.fieldBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: DesignTokens.iconSm,
                    color: FormTokens.iconColor,
                  ),
                  SizedBox(width: DesignTokens.spacing1),
                  Text(
                    label,
                    style: TypographyTokens.captionMd.copyWith(
                      color: FormTokens.labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignTokens.spacing1),
              Text(
                DateFormat('MMM dd, yyyy\nhh:mm a').format(date),
                style: TypographyTokens.labelSm.copyWith(
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
    AsyncValue categoryState,
    dynamic categoryIconColorService,
  ) {
    return categoryState.when(
      data: (state) {
        final expenseCategories = state.getCategoriesByType(
          TransactionType.expense,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSectionHeader(
                    'Budget Categories',
                    'Allocate amounts to each category',
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: ColorTokens.teal500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: DesignTokens.iconMd,
                      color: ColorTokens.teal500,
                    ),
                    onPressed: _addCategory,
                    tooltip: 'Add Category',
                  ),
                ),
              ],
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 800.ms),
            
            SizedBox(height: FormTokens.groupGap),

            ..._categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: DesignTokens.spacing3,
                ),
                child: _buildCategoryItem(
                  category,
                  expenseCategories,
                  categoryIconColorService,
                  index,
                ),
              ).animate()
                .fadeIn(
                  duration: DesignTokens.durationNormal,
                  delay: Duration(milliseconds: 900 + (index * 50)),
                )
                .slideX(
                  begin: 0.1,
                  duration: DesignTokens.durationNormal,
                  delay: Duration(milliseconds: 900 + (index * 50)),
                );
            }),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildCategoryItem(
    BudgetCategoryFormData category,
    List<TransactionCategory> expenseCategories,
    dynamic categoryIconColorService,
    int index,
  ) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.5,
        ),
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EnhancedDropdownField<String>(
            label: 'Category ${index + 1}',
            items: expenseCategories.map((cat) {
              return DropdownItem<String>(
                value: cat.id,
                label: cat.name,
                icon: categoryIconColorService.getIconForCategory(cat.id),
                iconColor: categoryIconColorService.getColorForCategory(cat.id),
              );
            }).toList(),
            value: category.selectedCategoryId,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  category.selectedCategoryId = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          
          SizedBox(height: DesignTokens.spacing3),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: EnhancedTextField(
                  controller: category.amountController,
                  label: 'Amount',
                  hint: '0.00',
                  prefix: Icon(
                    Icons.attach_money,
                    color: FormTokens.iconColor,
                    size: DesignTokens.iconMd,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              if (_categories.length > 1) ...[
                SizedBox(width: DesignTokens.spacing2),
                Container(
                  margin: EdgeInsets.only(top: DesignTokens.spacing3),
                  decoration: BoxDecoration(
                    color: ColorTokens.critical500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: DesignTokens.iconMd,
                      color: ColorTokens.critical500,
                    ),
                    onPressed: () => _removeCategory(category),
                    tooltip: 'Remove Category',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBudgetCard() {
    return AnimatedContainer(
      duration: DesignTokens.durationNormal,
      curve: DesignTokens.curveEaseOut,
      padding: EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        gradient: _isTotalUpdating
            ? LinearGradient(
                colors: [
                  ColorTokens.teal500.withValues(alpha: 0.15),
                  ColorTokens.purple600.withValues(alpha: 0.15),
                ],
              )
            : null,
        color: _isTotalUpdating ? null : ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: _isTotalUpdating
              ? ColorTokens.teal500.withValues(alpha: 0.3)
              : ColorTokens.borderSecondary,
          width: _isTotalUpdating ? 2 : 1.5,
        ),
        boxShadow: _isTotalUpdating
            ? DesignTokens.elevationGlow(
                ColorTokens.teal500,
                alpha: 0.2,
                spread: 0,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing2),
            decoration: BoxDecoration(
              color: ColorTokens.teal500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: DesignTokens.iconLg,
              color: ColorTokens.teal500,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Budget',
                  style: TypographyTokens.labelMd.copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing05),
                AnimatedDefaultTextStyle(
                  duration: DesignTokens.durationNormal,
                  curve: DesignTokens.curveEaseOut,
                  style: TypographyTokens.heading4.copyWith(
                    color: _isTotalUpdating
                        ? ColorTokens.teal500
                        : ColorTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text(
                    NumberFormat.currency(
                      symbol: '\$',
                      decimalDigits: 2,
                    ).format(_totalBudget),
                  ),
                ),
              ],
            ),
          ),
          if (_isTotalUpdating)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.teal500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, FormTokens.fieldHeightMd),
        side: BorderSide(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        ),
      ),
      child: Text('Cancel', style: TypographyTokens.labelMd),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1100.ms);
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        boxShadow: _isSubmitting
            ? []
            : DesignTokens.elevationColored(ColorTokens.teal500, alpha: 0.3),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBudget,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(0, FormTokens.fieldHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Create Budget',
                style: TypographyTokens.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1200.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1200.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 1200.ms);
  }

  IconData _getBudgetTypeIcon(BudgetType type) {
    switch (type) {
      case BudgetType.monthly:
        return Icons.calendar_month;
      case BudgetType.yearly:
        return Icons.event;
      case BudgetType.custom:
        return Icons.tune;
      case BudgetType.weekly:
        return Icons.calendar_view_week;
    }
  }

  void _addCategory() {
    setState(() {
      _categories.add(BudgetCategoryFormData());
      _setupCategoryListeners();
      _updateTotalBudget();
    });
  }

  void _removeCategory(BudgetCategoryFormData category) {
    setState(() {
      category.dispose();
      _categories.remove(category);
      _setupCategoryListeners();
      _updateTotalBudget();
    });
  }

  void _setupCategoryListeners() {
    for (final category in _categories) {
      category.amountController.removeListener(_debouncedUpdateTotalBudget);
      category.amountController.addListener(_debouncedUpdateTotalBudget);
    }
  }

  void _debouncedUpdateTotalBudget() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateTotalBudget();
    });
  }

  void _updateTotalBudget() {
    final newTotal = _calculateTotalBudget();
    if (_totalBudget != newTotal) {
      setState(() {
        _isTotalUpdating = true;
        _totalBudget = newTotal;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isTotalUpdating = false;
          });
        }
      });
    }
  }

  double _calculateTotalBudget() {
    return _categories.fold(0.0, (total, category) {
      final text = category.amountController.text.trim();
      if (text.isEmpty) return total;
      final amount = double.tryParse(text) ?? 0.0;
      return total + (amount >= 0 ? amount : 0.0);
    });
  }

  Future<String?> _validateBudgetName(String name) async {
    if (name.trim().isEmpty) return null;

    try {
      final budgetState = ref.read(budgetNotifierProvider);
      final existingBudgets = budgetState.value?.budgets ?? [];

      final isDuplicate = existingBudgets.any(
        (budget) => budget.name.trim().toLowerCase() == name.toLowerCase(),
      );

      return isDuplicate ? 'A budget with this name already exists' : null;
    } catch (e) {
      return null;
    }
  }

  void _onTemplateChanged(String template) async {
    if (template == 'None (Custom)') {
      setState(() {
        _categories.clear();
        _addCategory();
        _selectedType = BudgetType.custom;
        _totalBudget = 0.0;
      });
      return;
    }

    setState(() => _isLoadingTemplate = true);

    try {
      BudgetTemplate? selectedTemplate;
      if (template == '50/30/20 Rule') {
        selectedTemplate = BudgetTemplates.fiftyThirtyTwenty;
      }

      if (selectedTemplate != null && mounted) {
        setState(() {
          _categories.clear();
          _selectedType = selectedTemplate!.type;
          _totalBudget = 0.0;
        });

        final categoryState = ref.read(categoryNotifierProvider);
        final expenseCategories = categoryState.maybeWhen(
          data: (state) => state.getCategoriesByType(TransactionType.expense),
          orElse: () => <TransactionCategory>[],
        );

        // Map template categories to available categories
        for (final templateCategory in selectedTemplate.categories) {
          final matchedCategory = expenseCategories.firstWhere(
            (cat) => cat.name.toLowerCase().contains(
                  templateCategory.name.toLowerCase().split(' ').first,
                ),
            orElse: () => expenseCategories.isNotEmpty
                ? expenseCategories.first
                : TransactionCategory.defaultCategories.first,
          );

          final categoryData = BudgetCategoryFormData();
          categoryData.selectedCategoryId = matchedCategory.id;
          categoryData.amountController.text =
              templateCategory.amount.toStringAsFixed(2);
          _categories.add(categoryData);
        }

        if (_nameController.text.isEmpty) {
          _nameController.text = '${selectedTemplate.name} Budget';
        }

        _setupCategoryListeners();
        _updateTotalBudget();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading template: $e'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingTemplate = false);
      }
    }
  }

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total budget must be greater than zero'),
          backgroundColor: ColorTokens.critical500,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final categoryState = ref.read(categoryNotifierProvider);
      final expenseCategories = categoryState.maybeWhen(
        data: (state) => state.getCategoriesByType(TransactionType.expense),
        orElse: () => <TransactionCategory>[],
      );

      final categories = _categories.map((categoryData) {
        final selectedCategory = expenseCategories.firstWhere(
          (cat) => cat.id == categoryData.selectedCategoryId,
        );
        return BudgetCategory(
          id: selectedCategory.id,
          name: selectedCategory.name,
          amount: double.parse(categoryData.amountController.text),
        );
      }).toList();

      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        startDate: _createdAt,
        endDate: _endDate,
        createdAt: _createdAt,
        categories: categories,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        isActive: true,
        allowRollover: false,
      );

      await widget.onSubmit(budget);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Helper class for budget category form data
class BudgetCategoryFormData {
  String? selectedCategoryId;
  final TextEditingController amountController = TextEditingController();

  void dispose() {
    amountController.dispose();
  }
}

PART 8: FINAL IMPLEMENTATION SUMMARY
8.1 Complete Component Library
markdown# Enhanced Form Component Library

## ✅ Core Components
- [x] EnhancedTextField - Text input with async validation
- [x] EnhancedDropdownField - Dropdown with icons and subtitles
- [x] EnhancedSwitchField - Toggle switch with visual feedback
- [x] EnhancedBottomSheet - Modal bottom sheets with animations

## ✅ Form Implementations
- [x] EnhancedAddTransactionBottomSheet - Transaction creation
- [x] EnhancedAddEditAccountBottomSheet - Account management
- [x] EnhancedBillForm - Bill creation/editing
- [x] EnhancedBudgetForm - Budget creation with categories

## ✅ Design Tokens
- [x] FormTokens - Complete form-specific token system
- [x] Field dimensions, spacing, colors
- [x] Consistent decoration and styling
- [x] Animation timing and curves
# Recommended Migration Order

## Phase 1: High Priority (Week 1-2)
1. ✅ AddTransactionBottomSheet → EnhancedAddTransactionBottomSheet
2. ✅ AddEditAccountBottomSheet → EnhancedAddEditAccountBottomSheet
3. ⏳ EditBillBottomSheet → EnhancedBillForm
4. ⏳ BillCreationScreen → Use EnhancedBillForm

## Phase 2: Medium Priority (Week 3)
5. ⏳ BudgetCreationScreen → EnhancedBudgetForm
6. ⏳ TransactionDetailBottomSheet → Enhanced version
7. ⏳ Goal creation forms → Enhanced versions
8. ⏳ Category management forms → Enhanced versions

## Phase 3: Low Priority (Week 4)
9. ⏳ Settings screens → Enhanced form components
10. ⏳ Profile forms → Enhanced versions
11. ⏳ Filter/search forms → Enhanced versions
```

---

## 8.3 Quick Reference Card

```dart
/// ════════════════════════════════════════════════════════════════════════════
/// ENHANCED FORM QUICK REFERENCE CARD
/// ════════════════════════════════════════════════════════════════════════════

// ────────────────────────────────────────────────────────────────────────────
// 1. TEXT FIELD WITH VALIDATION
// ────────────────────────────────────────────────────────────────────────────
EnhancedTextField(
  controller: _controller,
  label: 'Field Label',
  hint: 'Placeholder text',
  prefix: Icon(Icons.icon, color: FormTokens.iconColor),
  validator: (value) => value?.isEmpty ?? true ? 'Error' : null,
  asyncValidator: (value) async => /* async check */ null,
  debounceMs: 500, // Default debounce time
)

// ────────────────────────────────────────────────────────────────────────────
// 2. DROPDOWN WITH RICH ITEMS
// ────────────────────────────────────────────────────────────────────────────
EnhancedDropdownField<String>(
  label: 'Select',
  items: [
    DropdownItem(
      value: 'id',
      label: 'Name',
      subtitle: 'Optional description',
      icon: Icons.icon,
      iconColor: ColorTokens.teal500,
    ),
  ],
  value: _selected,
  onChanged: (v) => setState(() => _selected = v),
  validator: (v) => v == null ? 'Required' : null,
)

// ────────────────────────────────────────────────────────────────────────────
// 3. SWITCH WITH ICON
// ────────────────────────────────────────────────────────────────────────────
EnhancedSwitchField(
  title: 'Toggle Option',
  subtitle: 'Description text',
  value: _enabled,
  onChanged: (v) => setState(() => _enabled = v),
  icon: Icons.toggle_on,
  iconColor: ColorTokens.success500,
)

// ────────────────────────────────────────────────────────────────────────────
// 4. BOTTOM SHEET WITH FORM
// ────────────────────────────────────────────────────────────────────────────
EnhancedBottomSheet.showForm(
  context: context,
  title: 'Form Title',
  subtitle: 'Optional subtitle',
  child: Form(/* Your form fields */),
  actions: [
    OutlinedButton(/* Cancel */),
    ElevatedButton(/* Submit */),
  ],
)

// ────────────────────────────────────────────────────────────────────────────
// 5. SECTION HEADERS
// ────────────────────────────────────────────────────────────────────────────
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Section Title', style: TypographyTokens.heading6),
    SizedBox(height: DesignTokens.spacing1),
    Text('Description', style: TypographyTokens.captionMd),
  ],
)

// ────────────────────────────────────────────────────────────────────────────
// 6. GRADIENT BUTTON
// ────────────────────────────────────────────────────────────────────────────
Container(
  decoration: BoxDecoration(
    gradient: ColorTokens.gradientPrimary,
    borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
    boxShadow: DesignTokens.elevationColored(ColorTokens.teal500),
  ),
  child: ElevatedButton(
    onPressed: _submit,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    child: Text('Submit', style: TypographyTokens.labelMd),
  ),
)

// ────────────────────────────────────────────────────────────────────────────
// 7. ANIMATION PATTERN
// ────────────────────────────────────────────────────────────────────────────
widget.animate()
  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms)

// ────────────────────────────────────────────────────────────────────────────
// 8. SPACING PATTERNS
// ────────────────────────────────────────────────────────────────────────────
SizedBox(height: FormTokens.fieldGapMd)      // Between fields (16px)
SizedBox(height: FormTokens.sectionGap)      // Between sections (24px)
SizedBox(height: FormTokens.groupGap)        // Between group items (8px)

/// ════════════════════════════════════════════════════════════════════════════
```

---

## 8.4 Common Patterns & Solutions

```dart
/// ════════════════════════════════════════════════════════════════════════════
/// COMMON FORM PATTERNS
/// ════════════════════════════════════════════════════════════════════════════

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 1: Async Name Validation (Uniqueness Check)
// ────────────────────────────────────────────────────────────────────────────
Future<String?> _validateName(String name) async {
  if (name.trim().isEmpty) return null;
  
  try {
    final existing = await _repository.findByName(name);
    return existing != null ? 'Name already exists' : null;
  } catch (e) {
    return null; // Fail gracefully
  }
}

EnhancedTextField(
  controller: _nameController,
  label: 'Name',
  asyncValidator: _validateName,
  debounceMs: 500,
)

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 2: Date/Time Picker
// ────────────────────────────────────────────────────────────────────────────
Material(
  child: InkWell(
    onTap: () async {
      final date = await showDatePicker(/*...*/);
      if (date != null) {
        final time = await showTimePicker(/*...*/);
        setState(() {
          _selectedDate = DateTime(
            date.year, date.month, date.day,
            time?.hour ?? 0, time?.minute ?? 0,
          );
        });
      }
    },
    child: Container(
      padding: EdgeInsets.all(FormTokens.fieldPaddingH),
      decoration: BoxDecoration(
        color: FormTokens.fieldBackground,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(color: FormTokens.fieldBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today),
          SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
          ),
        ],
      ),
    ),
  ),
)

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 3: Conditional Field Display
// ────────────────────────────────────────────────────────────────────────────
if (_selectedType == AccountType.creditCard) ...[
  SizedBox(height: FormTokens.sectionGap),
  _buildSectionHeader('Credit Card Details'),
  SizedBox(height: FormTokens.groupGap),
  EnhancedTextField(/* Credit Limit */),
  SizedBox(height: FormTokens.fieldGapMd),
  EnhancedTextField(/* Minimum Payment */),
]

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 4: Smart Default Selection
// ────────────────────────────────────────────────────────────────────────────
// For dropdowns, set smart defaults in build:
if (_selectedValue == null && items.isNotEmpty) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      setState(() {
        _selectedValue = _getSmartDefault(items);
      });
    }
  });
}

String _getSmartDefault(List<Item> items) {
  // Try to find preferred item
  final preferred = items.firstWhere(
    (item) => preferredIds.contains(item.id),
    orElse: () => items.first,
  );
  return preferred.id;
}

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 5: Form Submission with Loading State
// ────────────────────────────────────────────────────────────────────────────
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isSubmitting = true);
  
  try {
    final data = _buildData();
    await _repository.save(data);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved successfully')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: ColorTokens.critical500,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 6: Info Box (Contextual Help)
// ────────────────────────────────────────────────────────────────────────────
Container(
  padding: EdgeInsets.all(DesignTokens.spacing3),
  decoration: BoxDecoration(
    color: ColorTokens.teal500.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
    border: Border.all(
      color: ColorTokens.teal500.withValues(alpha: 0.2),
    ),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline, color: ColorTokens.teal500),
      SizedBox(width: DesignTokens.spacing2),
      Expanded(
        child: Text(
          'Helpful information here',
          style: TypographyTokens.captionMd,
        ),
      ),
    ],
  ),
)

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 7: Dynamic List Management (Add/Remove Items)
// ────────────────────────────────────────────────────────────────────────────
Row(
  children: [
    Expanded(
      child: _buildSectionHeader('Items'),
    ),
    IconButton(
      icon: Icon(Icons.add),
      onPressed: _addItem,
    ),
  ],
),
..._items.asMap().entries.map((entry) {
  final index = entry.key;
  final item = entry.value;
  return _buildItemRow(item, index);
}),

Widget _buildItemRow(Item item, int index) {
  return Row(
    children: [
      Expanded(child: EnhancedTextField(/* fields */)),
      if (_items.length > 1)
        IconButton(
          icon: Icon(Icons.delete, color: ColorTokens.critical500),
          onPressed: () => _removeItem(item),
        ),
    ],
  );
}

// ────────────────────────────────────────────────────────────────────────────
// PATTERN 8: Animated Total/Summary Display
// ────────────────────────────────────────────────────────────────────────────
AnimatedContainer(
  duration: DesignTokens.durationNormal,
  decoration: BoxDecoration(
    color: _isUpdating
        ? ColorTokens.teal500.withValues(alpha: 0.1)
        : ColorTokens.surfaceSecondary,
    borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
    boxShadow: _isUpdating
        ? DesignTokens.elevationGlow(ColorTokens.teal500)
        : null,
  ),
  child: Padding(
    padding: EdgeInsets.all(DesignTokens.spacing4),
    child: Row(
      children: [
        Text('Total:', style: TypographyTokens.labelMd),
        Spacer(),
        AnimatedDefaultTextStyle(
          duration: DesignTokens.durationNormal,
          style: TypographyTokens.heading5.copyWith(
            color: _isUpdating
                ? ColorTokens.teal500
                : ColorTokens.textPrimary,
          ),
          child: Text('\$$_total'),
        ),
      ],
    ),
  ),
)

/// ════════════════════════════════════════════════════════════════════════════
```

---

## 8.5 Troubleshooting Guide

```markdown
# Common Issues & Solutions

## Issue 1: TextField loses focus on setState
**Problem**: TextField loses cursor position when state updates
**Solution**: Use separate controllers and avoid rebuilding TextField

```dart
// ❌ Wrong - rebuilds entire widget
setState(() {
  _value = newValue;
});

// ✅ Correct - only update what's needed
_controller.text = newValue;
```

## Issue 2: Async validator runs too frequently
**Problem**: API calls on every keystroke
**Solution**: Use debouncing (already built into EnhancedTextField)

```dart
EnhancedTextField(
  asyncValidator: _validate,
  debounceMs: 500, // Adjust as needed
)
```

## Issue 3: Bottom sheet doesn't respect keyboard
**Problem**: Content hidden behind keyboard
**Solution**: Use viewInsets.bottom padding (already in EnhancedBottomSheet)

```dart
Padding(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  child: content,
)
```

## Issue 4: Animations stutter
**Problem**: Heavy computations during animation
**Solution**: Use const constructors and minimize rebuilds

```dart
// ✅ Good - const where possible
const SizedBox(height: 16)
const Icon(Icons.check)

// ✅ Good - extract heavy widgets
class _HeavyWidget extends StatelessWidget {
  const _HeavyWidget({super.key});
  // ...
}
```

## Issue 5: Dropdown overflows on small screens
**Problem**: Long text causes overflow
**Solution**: Set isExpanded: true and use Flexible/Expanded

```dart
EnhancedDropdownField(
  // isExpanded is already true by default
  items: items.map((item) {
    return DropdownItem(
      value: item.id,
      label: item.name,
      // Text will ellipsis automatically
    );
  }).toList(),
)
```

## Issue 6: Form validation fails silently
**Problem**: Form validates but doesn't submit
**Solution**: Check all validator return values

```dart
Future<void> _submit() async {
  // 1. Validate form
  if (!_formKey.currentState!.validate()) {
    debugPrint('Form validation failed');
    return;
  }
  
  // 2. Check required dropdowns
  if (_selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a category')),
    );
    return;
  }
  
  // 3. Proceed with submission
  // ...
}
```
```

---

## 8.6 Performance Optimization Tips

```dart
/// ════════════════════════════════════════════════════════════════════════════
/// PERFORMANCE OPTIMIZATION PATTERNS
/// ════════════════════════════════════════════════════════════════════════════

// ────────────────────────────────────────────────────────────────────────────
// TIP 1: Use const constructors
// ────────────────────────────────────────────────────────────────────────────
// ❌ Bad
SizedBox(height: 16)
Icon(Icons.check, size: 20)

// ✅ Good
const SizedBox(height: 16)
const Icon(Icons.check, size: 20)

// ────────────────────────────────────────────────────────────────────────────
// TIP 2: Extract complex widgets
// ────────────────────────────────────────────────────────────────────────────
// ❌ Bad - rebuilds entire complex widget
Widget build(BuildContext context) {
  return Column(
    children: [
      ComplexWidget(/* many properties */),
      SimpleWidget(),
    ],
  );
}

// ✅ Good - only rebuilds what changed
class _ComplexWidget extends StatelessWidget {
  const _ComplexWidget();
  @override
  Widget build(BuildContext context) {
    return /* complex widget */;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TIP 3: Minimize provider watches
// ────────────────────────────────────────────────────────────────────────────
// ❌ Bad - watches entire state
final state = ref.watch(myProvider);
return Text(state.name);

// ✅ Good - watch only what's needed
final name = ref.watch(myProvider.select((s) => s.name));
return Text(name);

// ────────────────────────────────────────────────────────────────────────────
// TIP 4: Use keys for lists
// ────────────────────────────────────────────────────────────────────────────
// ❌ Bad - no keys
items.map((item) => ItemWidget(item: item))

// ✅ Good - with keys
items.map((item) => ItemWidget(
  key: ValueKey(item.id),
  item: item,
))

// ────────────────────────────────────────────────────────────────────────────
// TIP 5: Debounce expensive operations
// ────────────────────────────────────────────────────────────────────────────
Timer? _debounceTimer;

void _onTextChanged() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    _expensiveOperation();
  });
}

@override
void dispose() {
  _debounceTimer?.cancel();
  super.dispose();
}

// ────────────────────────────────────────────────────────────────────────────
// TIP 6: Use RepaintBoundary for complex widgets
// ────────────────────────────────────────────────────────────────────────────
RepaintBoundary(
  child: ComplexChart(/* ... */),
)

/// ════════════════════════════════════════════════════════════════════════════
```

---

## 8.7 Accessibility Checklist

```markdown
# Form Accessibility Checklist

## ✅ Touch Targets
- [ ] All interactive elements are at least 48x48dp
- [ ] Adequate spacing between adjacent buttons
- [ ] Icons have proper IconButton wrappers

## ✅ Labels & Hints
- [ ] All fields have descriptive labels
- [ ] Placeholders provide examples
- [ ] Error messages are clear and actionable

## ✅ Color & Contrast
- [ ] Text meets WCAG AA contrast requirements (4.5:1)
- [ ] Don't rely solely on color to convey information
- [ ] Error states include icons, not just red text

## ✅ Screen Reader Support
- [ ] Semantic widgets used (Semantics)
- [ ] Form fields have proper labels
- [ ] Loading states announced
- [ ] Error states announced

## ✅ Keyboard Navigation
- [ ] Tab order is logical
- [ ] Can navigate entire form with keyboard
- [ ] Focus indicators are visible

## ✅ Motion & Animation
- [ ] Respect prefers-reduced-motion
- [ ] Animations don't interfere with comprehension
- [ ] Loading states don't rely solely on animation
```

---

# 🎉 CONCLUSION

This comprehensive form transformation guide provides:

## ✅ Complete Design System
- **FormTokens**: Consistent spacing, colors, sizing
- **Enhanced Components**: TextField, Dropdown, Switch, BottomSheet
- **Animation System**: Smooth, purposeful transitions
- **Validation Framework**: Sync and async validation

## ✅ Production-Ready Components
- **EnhancedAddTransactionBottomSheet**: Modern transaction creation
- **EnhancedAddEditAccountBottomSheet**: Account management
- **EnhancedBillForm**: Bill creation/editing
- **EnhancedBudgetForm**: Budget creation with categories

## ✅ Implementation Support
- **Quick Reference**: Copy-paste examples
- **Common Patterns**: Proven solutions
- **Troubleshooting**: Issue resolution
- **Performance Tips**: Optimization strategies
- **Accessibility**: WCAG compliance

## 🚀 Next Steps

1. **Phase 1**: Copy design tokens and base components
2. **Phase 2**: Migrate high-priority forms (transactions, accounts)
3. **Phase 3**: Migrate remaining forms (bills, budgets, goals)
4. **Phase 4**: Test, refine, document

## 📦 What You Get

- 🎨 **Consistent UX** across all forms
- ⚡ **Better Performance** with optimized components
- 🎯 **Instant Validation** with debouncing
- 🌈 **Beautiful Animations** that guide users
- ♿ **Accessibility** built-in
- 📱 **Mobile-First** design
- 🔧 **Easy Maintenance** with reusable components

**Your forms are now ready for transformation! 🚀**