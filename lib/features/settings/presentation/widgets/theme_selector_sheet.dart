import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../providers/settings_providers.dart';

class ThemeSelectorSheet extends ConsumerWidget {
  const ThemeSelectorSheet({super.key, required this.currentTheme});

  final ThemeMode currentTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'Choose Theme',
            style: TypographyTokens.heading4,
          ),
          SizedBox(height: DesignTokens.spacing5),

          ...ThemeMode.values.map((mode) => Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(settingsNotifierProvider.notifier)
                      .updateThemeMode(mode);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                child: Container(
                  padding: EdgeInsets.all(DesignTokens.spacing4),
                  decoration: BoxDecoration(
                    color: mode == currentTheme
                        ? ColorTokens.withOpacity(ColorTokens.teal500, 0.1)
                        : ColorTokens.surfaceSecondary,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(
                      color: mode == currentTheme
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
                            _getThemeColor(mode),
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                        child: Icon(
                          _getThemeIcon(mode),
                          color: _getThemeColor(mode),
                          size: DesignTokens.iconMd,
                        ),
                      ),
                      SizedBox(width: DesignTokens.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getThemeDisplayName(mode),
                              style: TypographyTokens.bodyLg.copyWith(
                                fontWeight: mode == currentTheme
                                    ? TypographyTokens.weightBold
                                    : TypographyTokens.weightRegular,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getThemeDescription(mode),
                              style: TypographyTokens.captionMd,
                            ),
                          ],
                        ),
                      ),
                      if (mode == currentTheme)
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

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.settings_suggest;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  Color _getThemeColor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return ColorTokens.purple600;
      case ThemeMode.light:
        return ColorTokens.warning500;
      case ThemeMode.dark:
        return ColorTokens.info500;
    }
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system settings';
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
    }
  }
}