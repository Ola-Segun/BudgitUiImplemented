import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../providers/settings_providers.dart';

class DateFormatSelectorSheet extends ConsumerWidget {
  const DateFormatSelectorSheet({super.key, required this.currentFormat});

  final String currentFormat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = [
      DateFormatInfo('MM/dd/yyyy', 'US Format', '12/31/2024'),
      DateFormatInfo('dd/MM/yyyy', 'European Format', '31/12/2024'),
      DateFormatInfo('yyyy-MM-dd', 'ISO Format', '2024-12-31'),
      DateFormatInfo('MMM dd, yyyy', 'Long Format', 'Dec 31, 2024'),
      DateFormatInfo('dd MMM yyyy', 'Alternative', '31 Dec 2024'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.all(DesignTokens.spacing5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ColorTokens.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: DesignTokens.spacing5),

          Text(
            'Choose Date Format',
            style: TypographyTokens.heading4,
          ),
          SizedBox(height: DesignTokens.spacing5),

          ...formats.map((format) => Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(settingsNotifierProvider.notifier)
                      .updateSetting('dateFormat', format.pattern);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                child: Container(
                  padding: EdgeInsets.all(DesignTokens.spacing4),
                  decoration: BoxDecoration(
                    color: format.pattern == currentFormat
                        ? ColorTokens.withOpacity(ColorTokens.teal500, 0.1)
                        : ColorTokens.surfaceSecondary,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(
                      color: format.pattern == currentFormat
                          ? ColorTokens.teal500
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(DesignTokens.spacing2),
                        decoration: BoxDecoration(
                          color: ColorTokens.withOpacity(
                            ColorTokens.teal500,
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: ColorTokens.teal500,
                          size: DesignTokens.iconMd,
                        ),
                      ),
                      SizedBox(width: DesignTokens.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              format.name,
                              style: TypographyTokens.bodyLg.copyWith(
                                fontWeight: format.pattern == currentFormat
                                    ? TypographyTokens.weightBold
                                    : TypographyTokens.weightRegular,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              format.example,
                              style: TypographyTokens.captionMd.copyWith(
                                color: format.pattern == currentFormat
                                    ? ColorTokens.teal500
                                    : ColorTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (format.pattern == currentFormat)
                        Icon(
                          Icons.check_circle,
                          color: ColorTokens.teal500,
                          size: DesignTokens.iconMd,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class DateFormatInfo {
  final String pattern;
  final String name;
  final String example;

  DateFormatInfo(this.pattern, this.name, this.example);
}