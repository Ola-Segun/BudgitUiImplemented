import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/import_result.dart';
import 'import_result_dialog.dart';

class ImportDataDialog extends ConsumerStatefulWidget {
  const ImportDataDialog({super.key});

  @override
  ConsumerState<ImportDataDialog> createState() => _ImportDataDialogState();
}

class _ImportDataDialogState extends ConsumerState<ImportDataDialog> {
  File? _selectedFile;
  bool _isImporting = false;
  String? _errorMessage;
  String? _successMessage;

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
          // File selection area
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing4),
            decoration: BoxDecoration(
              color: ColorTokens.withOpacity(ColorTokens.info500, 0.05),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: _selectedFile != null
                    ? ColorTokens.withOpacity(ColorTokens.success500, 0.3)
                    : ColorTokens.withOpacity(ColorTokens.info500, 0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedFile != null ? Icons.file_present : Icons.file_upload_outlined,
                  size: 48,
                  color: _selectedFile != null ? ColorTokens.success500 : ColorTokens.info500,
                ),
                SizedBox(height: DesignTokens.spacing3),
                if (_selectedFile == null) ...[
                  Text(
                    'Select a file to import',
                    style: TypographyTokens.heading6.copyWith(
                      color: ColorTokens.info500,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing2),
                  Text(
                    'Supported formats: CSV, JSON',
                    style: TypographyTokens.bodySm.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    'Selected file:',
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing1),
                  Text(
                    _selectedFile!.path.split(Platform.pathSeparator).last,
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.textPrimary,
                      fontWeight: TypographyTokens.weightSemiBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignTokens.spacing2),
                  Text(
                    '${(_selectedFile!.lengthSync() / 1024).round()} KB',
                    style: TypographyTokens.bodySm.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: DesignTokens.spacing4),

          // Select file button
          if (!_isImporting)
            ActionButtonPattern(
              label: _selectedFile == null ? 'Select File' : 'Change File',
              variant: ButtonVariant.secondary,
              size: ButtonSize.medium,
              isFullWidth: true,
              onPressed: _selectFile,
            ),

          // Import options
          if (_selectedFile != null && !_isImporting) ...[
            SizedBox(height: DesignTokens.spacing3),
            _buildImportOptions(),
          ],

          // Loading indicator
          if (_isImporting) ...[
            SizedBox(height: DesignTokens.spacing3),
            const LoadingView(message: 'Importing data...'),
          ],

          // Error message
          if (_errorMessage != null) ...[
            SizedBox(height: DesignTokens.spacing3),
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.critical500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: ColorTokens.withOpacity(ColorTokens.critical500, 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: ColorTokens.critical500,
                    size: 20,
                  ),
                  SizedBox(width: DesignTokens.spacing2),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TypographyTokens.bodySm.copyWith(
                        color: ColorTokens.critical500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success message
          if (_successMessage != null) ...[
            SizedBox(height: DesignTokens.spacing3),
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.success500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: ColorTokens.withOpacity(ColorTokens.success500, 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: ColorTokens.success500,
                    size: 20,
                  ),
                  SizedBox(width: DesignTokens.spacing2),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: TypographyTokens.bodySm.copyWith(
                        color: ColorTokens.success500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TypographyTokens.labelMd.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
        ),

        // Import button
        if (_selectedFile != null && !_isImporting)
          ActionButtonPattern(
            label: 'Import',
            variant: ButtonVariant.primary,
            size: ButtonSize.medium,
            onPressed: _importData,
          ),
      ],
    );
  }

  Widget _buildImportOptions() {
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
            'Import Options',
            style: TypographyTokens.bodyMd.copyWith(
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),

          // Skip errors option
          Row(
            children: [
              Checkbox(
                value: true, // Default to skip errors
                onChanged: (value) {
                  // TODO: Implement option state management
                },
              ),
              Expanded(
                child: Text(
                  'Skip errors and continue import',
                  style: TypographyTokens.bodySm,
                ),
              ),
            ],
          ),

          // Update existing option
          Row(
            children: [
              Checkbox(
                value: false, // Default to not update existing
                onChanged: (value) {
                  // TODO: Implement option state management
                },
              ),
              Expanded(
                child: Text(
                  'Update existing records',
                  style: TypographyTokens.bodySm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        setState(() {
          _selectedFile = file;
          _errorMessage = null;
          _successMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select file: ${e.toString()}';
      });
    }
  }

  Future<void> _importData() async {
    if (_selectedFile == null) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // TODO: Implement actual import logic
      // For now, just simulate import
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isImporting = false;
        _successMessage = 'Data imported successfully! Check the results below.';
      });

      // Show import results dialog
      _showImportResults();

    } catch (e) {
      setState(() {
        _isImporting = false;
        _errorMessage = 'Import failed: ${e.toString()}';
      });
    }
  }

  void _showImportResults() {
    // Create a mock result for demonstration
    // TODO: Replace with actual import result
    final mockResult = ImportResult(
      transactions: [],
      categories: [],
      accounts: [],
      budgets: [],
      goals: [],
      errors: [],
      summary: ImportSummary(
        transactionsImported: 5,
        categoriesImported: 3,
        accountsImported: 2,
        budgetsImported: 1,
        goalsImported: 0,
        transactionsSkipped: 0,
        categoriesSkipped: 1,
        accountsSkipped: 0,
        budgetsSkipped: 0,
        goalsSkipped: 0,
        errors: 0,
        warnings: 1,
      ),
    );

    Navigator.pop(context); // Close import dialog

    showDialog(
      context: context,
      builder: (context) => ImportResultDialog(result: mockResult),
    );
  }
}