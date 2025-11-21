import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../domain/entities/income_source.dart';
import '../providers/onboarding_providers.dart';

/// Bottom sheet for adding income sources during onboarding
class AddIncomeSourceBottomSheet extends ConsumerStatefulWidget {
  const AddIncomeSourceBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddIncomeSourceBottomSheet(),
    );
  }

  @override
  ConsumerState<AddIncomeSourceBottomSheet> createState() => _AddIncomeSourceBottomSheetState();
}

class _AddIncomeSourceBottomSheetState extends ConsumerState<AddIncomeSourceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  PayFrequency _selectedFrequency = PayFrequency.monthly;
  bool _isAddingIncome = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addIncomeSource() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAddingIncome = true);

    try {
      final amountText = _amountController.text.replaceAll('\$', '').replaceAll(',', '').trim();
      final amount = double.tryParse(amountText) ?? 0.0;

      if (amount <= 0) return;

      final incomeSource = IncomeSource(
        id: 'income_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        amount: amount,
        frequency: _selectedFrequency,
      );

      ref.read(onboardingNotifierProvider.notifier).addIncomeSource(incomeSource);

      // Clear form
      _nameController.clear();
      _amountController.clear();
      setState(() => _selectedFrequency = PayFrequency.monthly);

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingIncome = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: spacing_md),
            child: Row(
              children: [
                Text(
                  'Add Income Source',
                  style: ModernTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Income name
                ModernTextField(
                  controller: _nameController,
                  label: 'Income Source Name',
                  placeholder: 'e.g., Salary, Freelance, Business',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an income source name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: spacing_md),

                // Amount
                ModernTextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  label: 'Amount',
                  placeholder: '\$0.00',
                  prefixIcon: Icons.attach_money,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amountText = value.replaceAll('\$', '').replaceAll(',', '').trim();
                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: spacing_md),

                // Frequency
                ModernDropdownSelector<PayFrequency>(
                  label: 'Frequency',
                  selectedValue: _selectedFrequency,
                  items: PayFrequency.values.map((frequency) {
                    return ModernDropdownItem(
                      value: frequency,
                      label: frequency.displayName,
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFrequency = value);
                    }
                  },
                ),

                const SizedBox(height: spacing_xl),

                // Action Button
                ModernActionButton(
                  text: 'Add Income Source',
                  onPressed: _isAddingIncome ? null : _addIncomeSource,
                  isLoading: _isAddingIncome,
                ),
                const SizedBox(height: spacing_lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}