import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';

class ClearDataDialog extends StatelessWidget {
  const ClearDataDialog({super.key});

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
              color: ColorTokens.withOpacity(ColorTokens.critical500, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              Icons.delete_forever,
              color: ColorTokens.critical500,
              size: DesignTokens.iconMd,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Text(
            'Clear All Data',
            style: TypographyTokens.heading5,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: ColorTokens.withOpacity(ColorTokens.critical500, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: ColorTokens.withOpacity(ColorTokens.critical500, 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: ColorTokens.critical500,
                  size: DesignTokens.iconMd,
                ),
                SizedBox(width: DesignTokens.spacing2),
                Expanded(
                  child: Text(
                    'This action cannot be undone!',
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.critical500,
                      fontWeight: TypographyTokens.weightBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignTokens.spacing4),
          Text(
            'This will permanently delete:',
            style: TypographyTokens.bodyMd,
          ),
          SizedBox(height: DesignTokens.spacing2),
          _buildWarningItem('All transactions'),
          _buildWarningItem('All budgets'),
          _buildWarningItem('All goals'),
          _buildWarningItem('All accounts'),
          _buildWarningItem('All settings'),
          SizedBox(height: DesignTokens.spacing3),
          Text(
            'Make sure to export your data first if you want to keep a backup.',
            style: TypographyTokens.captionMd.copyWith(
              color: ColorTokens.textSecondary,
              fontStyle: FontStyle.italic,
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
                label: 'Delete All',
                variant: ButtonVariant.danger,
                size: ButtonSize.medium,
                icon: Icons.delete_forever,
                onPressed: () {
                  // TODO: Implement clear data functionality
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All data cleared successfully'),
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

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacing1),
      child: Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            size: DesignTokens.iconSm,
            color: ColorTokens.critical500,
          ),
          SizedBox(width: DesignTokens.spacing2),
          Text(text, style: TypographyTokens.bodyMd),
        ],
      ),
    );
  }
}