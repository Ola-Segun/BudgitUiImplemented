import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';

class ExportDataDialog extends StatelessWidget {
  const ExportDataDialog({super.key});

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
              color: ColorTokens.withOpacity(ColorTokens.success500, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              Icons.download,
              color: ColorTokens.success500,
              size: DesignTokens.iconMd,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Text(
            'Export Data',
            style: TypographyTokens.heading5,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will export all your data including:',
            style: TypographyTokens.bodyMd,
          ),
          SizedBox(height: DesignTokens.spacing3),
          _buildFeatureItem('Transactions'),
          _buildFeatureItem('Budgets'),
          _buildFeatureItem('Goals'),
          _buildFeatureItem('Accounts'),
          _buildFeatureItem('Settings'),
          SizedBox(height: DesignTokens.spacing3),
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: ColorTokens.withOpacity(ColorTokens.info500, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ColorTokens.info500,
                  size: DesignTokens.iconSm,
                ),
                SizedBox(width: DesignTokens.spacing2),
                Expanded(
                  child: Text(
                    'Data will be saved as JSON file',
                    style: TypographyTokens.captionMd.copyWith(
                      color: ColorTokens.info500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ActionButtonPattern(
                label: 'Cancel',
                variant: ButtonVariant.secondary,
                size: ButtonSize.medium,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: DesignTokens.spacing2),
            Expanded(
              child: ActionButtonPattern(
                label: 'Export',
                variant: ButtonVariant.primary,
                size: ButtonSize.medium,
                gradient: ColorTokens.gradientSuccess,
                icon: Icons.download,
                onPressed: () {
                  // TODO: Implement export functionality
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Export completed'),
                      backgroundColor: ColorTokens.success500,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacing1),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: DesignTokens.iconSm,
            color: ColorTokens.success500,
          ),
          SizedBox(width: DesignTokens.spacing2),
          Text(text, style: TypographyTokens.bodyMd),
        ],
      ),
    );
  }
}