import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';

class ImportDataDialog extends StatelessWidget {
  const ImportDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorTokens.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing2),
            decoration: BoxDecoration(
              color: ColorTokens.withOpacity(ColorTokens.info500, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              Icons.upload,
              color: ColorTokens.info500,
              size: DesignTokens.iconMd,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Text(
            'Import Data',
            style: TypographyTokens.heading5,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing5),
            decoration: BoxDecoration(
              color: ColorTokens.withOpacity(ColorTokens.info500, 0.05),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: ColorTokens.withOpacity(ColorTokens.info500, 0.2),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  size: 48,
                  color: ColorTokens.info500,
                ),
                SizedBox(height: DesignTokens.spacing3),
                Text(
                  'Coming Soon',
                  style: TypographyTokens.heading6.copyWith(
                    color: ColorTokens.info500,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing2),
                Text(
                  'Import functionality will be available in a future update',
                  style: TypographyTokens.bodyMd.copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ActionButtonPattern(
          label: 'OK',
          variant: ButtonVariant.primary,
          size: ButtonSize.medium,
          isFullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}