import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';

class ReportBugBottomSheet extends StatefulWidget {
  const ReportBugBottomSheet({super.key});

  @override
  State<ReportBugBottomSheet> createState() => _ReportBugBottomSheetState();
}

class _ReportBugBottomSheetState extends State<ReportBugBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _severity = 'Medium';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorTokens.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: DesignTokens.spacing5),

            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: ColorTokens.withOpacity(ColorTokens.critical500, 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    Icons.bug_report,
                    color: ColorTokens.critical500,
                    size: DesignTokens.iconMd,
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Text(
                  'Report a Bug',
                  style: TypographyTokens.heading4,
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacing5),

            // Severity Selection
            Text(
              'Severity Level',
              style: TypographyTokens.labelMd,
            ),
            SizedBox(height: DesignTokens.spacing2),
            Row(
              children: ['Low', 'Medium', 'High', 'Critical'].map((severity) {
                final isSelected = _severity == severity;
                final color = _getSeverityColor(severity);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: severity != 'Critical' ? DesignTokens.spacing2 : 0,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _severity = severity;
                          });
                          HapticFeedback.selectionClick();
                        },
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: DesignTokens.spacing2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorTokens.withOpacity(color, 0.1)
                                : ColorTokens.surfaceSecondary,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            severity,
                            style: TypographyTokens.labelSm.copyWith(
                              color: isSelected ? color : ColorTokens.textPrimary,
                              fontWeight: isSelected
                                  ? TypographyTokens.weightBold
                                  : TypographyTokens.weightRegular,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: DesignTokens.spacing5),

            // Bug Title
            Text(
              'Bug Title',
              style: TypographyTokens.labelMd,
            ),
            SizedBox(height: DesignTokens.spacing2),
            Container(
              decoration: BoxDecoration(
                color: ColorTokens.surfaceSecondary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Brief description of the issue',
                  hintStyle: TypographyTokens.bodyMd.copyWith(
                    color: ColorTokens.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(DesignTokens.spacing3),
                ),
                style: TypographyTokens.bodyMd,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),

            // Bug Description
            Text(
              'Detailed Description',
              style: TypographyTokens.labelMd,
            ),
            SizedBox(height: DesignTokens.spacing2),
            Container(
              decoration: BoxDecoration(
                color: ColorTokens.surfaceSecondary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 6,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: 'Steps to reproduce:\n1. \n2. \n3. \n\nExpected behavior:\n\nActual behavior:',
                  hintStyle: TypographyTokens.bodyMd.copyWith(
                    color: ColorTokens.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(DesignTokens.spacing3),
                  counterStyle: TypographyTokens.captionSm,
                ),
                style: TypographyTokens.bodyMd,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),

            // Info Box
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
                      'Screenshots and device info will be automatically included',
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.info500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DesignTokens.spacing5),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ActionButtonPattern(
                    label: 'Cancel',
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: ActionButtonPattern(
                    label: 'Submit',
                    variant: ButtonVariant.danger,
                    size: ButtonSize.large,
                    icon: Icons.send,
                    onPressed: _submitBugReport,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Low':
        return ColorTokens.success500;
      case 'Medium':
        return ColorTokens.warning500;
      case 'High':
        return ColorTokens.critical500;
      case 'Critical':
        return ColorTokens.critical600;
      default:
        return ColorTokens.neutral500;
    }
  }

  void _submitBugReport() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: ColorTokens.warning500,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bug report ($_severity) submitted successfully'),
        backgroundColor: ColorTokens.success500,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}