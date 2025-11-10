import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../form_tokens.dart';

/// A reusable toggle component for showing/hiding optional fields
/// with smooth animations and haptic feedback
class OptionalFieldsToggle extends StatefulWidget {
  const OptionalFieldsToggle({
    super.key,
    required this.onChanged,
    this.initialValue = false,
    this.label = 'Show optional fields',
  });

  final ValueChanged<bool> onChanged;
  final bool initialValue;
  final String label;

  @override
  State<OptionalFieldsToggle> createState() => _OptionalFieldsToggleState();
}

class _OptionalFieldsToggleState extends State<OptionalFieldsToggle> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialValue;
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onChanged(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
          padding: EdgeInsets.symmetric(
            horizontal: FormTokens.fieldPaddingH,
            vertical: FormTokens.fieldPaddingV,
          ),
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
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: DesignTokens.iconMd,
                color: ColorTokens.teal500,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: Text(
                  widget.label,
                  style: TypographyTokens.labelMd.copyWith(
                    color: ColorTokens.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: DesignTokens.durationNormal,
                child: Icon(
                  _isExpanded ? Icons.visibility_off : Icons.visibility,
                  key: ValueKey<bool>(_isExpanded),
                  size: DesignTokens.iconMd,
                  color: _isExpanded ? ColorTokens.textSecondary : ColorTokens.teal500,
                ),
              ).animate(target: _isExpanded ? 1 : 0)
                .rotate(begin: 0, end: 0.5, duration: DesignTokens.durationNormal),
            ],
          ),
        ),
      ),
    );
  }
}