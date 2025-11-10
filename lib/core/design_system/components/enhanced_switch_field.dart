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
                  activeThumbColor: ColorTokens.teal500,
                  activeTrackColor: ColorTokens.teal500.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}