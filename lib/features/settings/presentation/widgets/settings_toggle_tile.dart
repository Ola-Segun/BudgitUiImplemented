import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';

class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TypographyTokens.bodyLg.copyWith(
                    color: enabled
                        ? ColorTokens.textPrimary
                        : ColorTokens.textDisabled,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TypographyTokens.captionMd.copyWith(
                    color: enabled
                        ? ColorTokens.textSecondary
                        : ColorTokens.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Switch(
            value: value,
            onChanged: enabled
                ? (val) {
                    HapticFeedback.selectionClick();
                    onChanged(val);
                  }
                : null,
            activeThumbColor: ColorTokens.teal500,
          ),
        ],
      ),
    );
  }
}