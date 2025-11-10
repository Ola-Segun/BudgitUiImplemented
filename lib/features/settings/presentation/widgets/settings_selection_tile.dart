import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';

class SettingsSelectionTile extends StatelessWidget {
  const SettingsSelectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: EdgeInsets.all(DesignTokens.spacing3),
          decoration: BoxDecoration(
            color: ColorTokens.surfaceSecondary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: ColorTokens.withOpacity(ColorTokens.teal500, 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: ColorTokens.teal500,
                  size: DesignTokens.iconMd,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TypographyTokens.bodyLg),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.teal500,
                        fontWeight: TypographyTokens.weightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ColorTokens.textSecondary,
                size: DesignTokens.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}