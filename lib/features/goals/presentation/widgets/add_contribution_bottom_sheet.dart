import 'package:flutter/material.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../domain/entities/goal_contribution.dart';

/// Bottom sheet for adding contributions to a goal
class AddContributionBottomSheet extends StatefulWidget {
  const AddContributionBottomSheet({
    super.key,
    required this.goalId,
    required this.onSubmit,
  });

  final String goalId;
  final Future<void> Function(GoalContribution) onSubmit;

  @override
  State<AddContributionBottomSheet> createState() => _AddContributionBottomSheetState();
}

class _AddContributionBottomSheetState extends State<AddContributionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: spacing_md),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle,
                    color: ModernColors.accentGreen,
                  ),
                  const SizedBox(width: spacing_sm),
                  Text(
                    'Add Contribution',
                    style: ModernTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Amount Display (prominent)
            ModernAmountDisplay(
              amount: double.tryParse(_amountController.text) ?? 0.0,
              isEditable: true,
              onAmountChanged: (amount) {
                _amountController.text = amount.toStringAsFixed(2);
              },
              onTap: () {
                // Could show keyboard here
              },
            ),
            const SizedBox(height: spacing_lg),

            // Date picker
            ModernDateTimePicker(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              showTime: false,
            ),
            const SizedBox(height: spacing_md),

            // Note field (optional)
            ModernTextField(
              controller: _noteController,
              label: 'Note (Optional)',
              placeholder: 'Add a note about this contribution...',
              maxLength: 200,
            ),

            const SizedBox(height: spacing_xl),

            // Action Button
            ModernActionButton(
              text: 'Add Contribution',
              onPressed: _isLoading ? null : _submitContribution,
              isLoading: _isLoading,
            ),
            const SizedBox(height: spacing_lg),
          ],
        ),
      ),
    );
  }


  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final contribution = GoalContribution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: widget.goalId,
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      await widget.onSubmit(contribution);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribution added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add contribution: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}