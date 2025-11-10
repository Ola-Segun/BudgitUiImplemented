import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';

class SettingsSliderTile extends StatelessWidget {
  const SettingsSliderTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ],
          ),
          SizedBox(height: DesignTokens.spacing2),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: ColorTokens.teal500,
              inactiveTrackColor: ColorTokens.neutral300,
              thumbColor: ColorTokens.teal500,
              overlayColor: ColorTokens.withOpacity(ColorTokens.teal500, 0.2),
              valueIndicatorColor: ColorTokens.teal500,
              valueIndicatorTextStyle: TypographyTokens.labelSm.copyWith(
                color: Colors.white,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.toInt().toString(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}