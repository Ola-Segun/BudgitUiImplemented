import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  int _rating = 0;
  String _feedbackType = 'General';

  @override
  void dispose() {
    _controller.dispose();
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
                    color: ColorTokens.withOpacity(ColorTokens.success500, 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    Icons.feedback,
                    color: ColorTokens.success500,
                    size: DesignTokens.iconMd,
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Text(
                  'Send Feedback',
                  style: TypographyTokens.heading4,
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacing5),

            // Feedback Type
            Text(
              'Feedback Type',
              style: TypographyTokens.labelMd,
            ),
            SizedBox(height: DesignTokens.spacing2),
            Wrap(
              spacing: DesignTokens.spacing2,
              children: ['General', 'Feature Request', 'Improvement'].map((type) {
                final isSelected = _feedbackType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _feedbackType = type;
                    });
                    HapticFeedback.selectionClick();
                  },
                  backgroundColor: ColorTokens.surfaceSecondary,
                  selectedColor: ColorTokens.withOpacity(ColorTokens.success500, 0.2),
                  labelStyle: TypographyTokens.labelSm.copyWith(
                    color: isSelected ? ColorTokens.success500 : ColorTokens.textPrimary,
                    fontWeight: isSelected
                        ? TypographyTokens.weightSemiBold
                        : TypographyTokens.weightRegular,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? ColorTokens.success500
                        : ColorTokens.neutral300,
                    width: 1,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: DesignTokens.spacing5),

            // Rating
            Text(
              'How would you rate your experience?',
              style: TypographyTokens.labelMd,
            ),
            SizedBox(height: DesignTokens.spacing3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? ColorTokens.warning500 : ColorTokens.neutral300,
                    size: DesignTokens.iconXl,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                    HapticFeedback.selectionClick();
                  },
                );
              }),
            ),
            SizedBox(height: DesignTokens.spacing4),

            // Feedback Text
            Text(
              'Tell us what you think',
              style: TypographyTokens.labelMd,
            ),
            SizedBox(height: DesignTokens.spacing2),
            Container(
              decoration: BoxDecoration(
                color: ColorTokens.surfaceSecondary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts, suggestions, or ideas...',
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
                    label: 'Send',
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    gradient: ColorTokens.gradientSuccess,
                    icon: Icons.send,
                    onPressed: _submitFeedback,
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

  void _submitFeedback() {
    final feedback = _controller.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your feedback'),
          backgroundColor: ColorTokens.warning500,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _rating > 0
              ? 'Thank you for your $_rating-star feedback!'
              : 'Thank you for your feedback!',
        ),
        backgroundColor: ColorTokens.success500,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}