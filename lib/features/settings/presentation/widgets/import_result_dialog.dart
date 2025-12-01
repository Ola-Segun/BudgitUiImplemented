import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../domain/entities/import_result.dart';
import '../../domain/entities/import_error.dart';

class ImportResultDialog extends StatelessWidget {
  const ImportResultDialog({
    super.key,
    required this.result,
  });

  final ImportResult result;

  @override
  Widget build(BuildContext context) {
    final hasErrors = result.hasErrors;
    final hasWarnings = result.hasWarnings;

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
              color: hasErrors
                  ? ColorTokens.withOpacity(ColorTokens.critical500, 0.1)
                  : ColorTokens.withOpacity(ColorTokens.success500, 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              hasErrors ? Icons.warning : Icons.check_circle,
              color: hasErrors ? ColorTokens.critical500 : ColorTokens.success500,
              size: DesignTokens.iconMd,
            ),
          ),
          SizedBox(width: DesignTokens.spacing3),
          Text(
            hasErrors ? 'Import Completed with Issues' : 'Import Successful',
            style: TypographyTokens.heading5,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            _buildSummarySection(),

            SizedBox(height: DesignTokens.spacing4),

            // Errors and warnings
            if (result.errors.isNotEmpty) ...[
              _buildErrorsSection(),
              SizedBox(height: DesignTokens.spacing4),
            ],

            // Detailed breakdown
            _buildDetailedBreakdown(),
          ],
        ),
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

  Widget _buildSummarySection() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import Summary',
            style: TypographyTokens.bodyMd.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),

          // Total items
          _buildSummaryRow(
            'Total Items Processed',
            result.summary.totalProcessed.toString(),
          ),

          // Successfully imported
          _buildSummaryRow(
            'Successfully Imported',
            result.summary.totalImported.toString(),
            color: ColorTokens.success500,
          ),

          // Skipped
          if (result.summary.totalSkipped > 0)
            _buildSummaryRow(
              'Skipped',
              result.summary.totalSkipped.toString(),
              color: ColorTokens.warning500,
            ),

          // Errors
          if (result.summary.errors > 0)
            _buildSummaryRow(
              'Errors',
              result.summary.errors.toString(),
              color: ColorTokens.critical500,
            ),

          // Warnings
          if (result.summary.warnings > 0)
            _buildSummaryRow(
              'Warnings',
              result.summary.warnings.toString(),
              color: ColorTokens.warning500,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TypographyTokens.bodySm,
          ),
          Text(
            value,
            style: TypographyTokens.bodySm.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsSection() {
    final errorErrors = result.errorErrors;
    final warningErrors = result.warningErrors;

    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.withOpacity(ColorTokens.critical500, 0.05),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: ColorTokens.withOpacity(ColorTokens.critical500, 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: ColorTokens.critical500,
                size: 20,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                'Issues Found',
                style: TypographyTokens.bodyMd.copyWith(
                  fontWeight: TypographyTokens.weightSemiBold,
                  color: ColorTokens.critical500,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacing2),

          // Show first few errors
          ...errorErrors.take(3).map((error) => _buildErrorItem(error, isError: true)),
          if (errorErrors.length > 3)
            Text(
              '... and ${errorErrors.length - 3} more errors',
              style: TypographyTokens.bodySm.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),

          // Show warnings if any
          if (warningErrors.isNotEmpty) ...[
            SizedBox(height: DesignTokens.spacing2),
            ...warningErrors.take(2).map((error) => _buildErrorItem(error, isError: false)),
            if (warningErrors.length > 2)
              Text(
                '... and ${warningErrors.length - 2} more warnings',
                style: TypographyTokens.bodySm.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorItem(ImportError error, {required bool isError}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error : Icons.warning,
            color: isError ? ColorTokens.critical500 : ColorTokens.warning500,
            size: 16,
          ),
          SizedBox(width: DesignTokens.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.message,
                  style: TypographyTokens.bodySm.copyWith(
                    color: isError ? ColorTokens.critical500 : ColorTokens.warning500,
                  ),
                ),
                if (error.lineNumber > 0)
                  Text(
                    'Line ${error.lineNumber}',
                    style: TypographyTokens.labelSm.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                if (error.suggestion != null)
                  Text(
                    'Suggestion: ${error.suggestion}',
                    style: TypographyTokens.labelSm.copyWith(
                      color: ColorTokens.info500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Breakdown',
            style: TypographyTokens.bodyMd.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),

          // Transactions
          _buildDetailRow('Transactions', result.summary.transactionsImported, result.summary.transactionsSkipped),

          // Categories
          _buildDetailRow('Categories', result.summary.categoriesImported, result.summary.categoriesSkipped),

          // Accounts
          _buildDetailRow('Accounts', result.summary.accountsImported, result.summary.accountsSkipped),

          // Budgets
          _buildDetailRow('Budgets', result.summary.budgetsImported, result.summary.budgetsSkipped),

          // Goals
          _buildDetailRow('Goals', result.summary.goalsImported, result.summary.goalsSkipped),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String type, int imported, int skipped) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              type,
              style: TypographyTokens.bodySm,
            ),
          ),
          if (imported > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing2,
                vertical: DesignTokens.spacing1,
              ),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.success500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Text(
                '+$imported',
                style: TypographyTokens.labelSm.copyWith(
                  color: ColorTokens.success500,
                  fontWeight: TypographyTokens.weightSemiBold,
                ),
              ),
            ),
          if (skipped > 0) ...[
            SizedBox(width: DesignTokens.spacing2),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing2,
                vertical: DesignTokens.spacing1,
              ),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.warning500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Text(
                '~$skipped',
                style: TypographyTokens.labelSm.copyWith(
                  color: ColorTokens.warning500,
                  fontWeight: TypographyTokens.weightSemiBold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}