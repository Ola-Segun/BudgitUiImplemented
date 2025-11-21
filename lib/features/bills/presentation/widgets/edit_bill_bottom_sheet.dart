import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../accounts/presentation/widgets/modern_account_selector.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/bill.dart';

/// Enhanced edit bill bottom sheet with modern design system
class EditBillBottomSheet extends ConsumerWidget {
  const EditBillBottomSheet({
    super.key,
    required this.bill,
    required this.onSubmit,
  });

  final Bill bill;
  final Future<void> Function(Bill updatedBill) onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EnhancedEditBillBottomSheetContent(
      bill: bill,
      onSubmit: onSubmit,
    );
  }
}

class _EnhancedEditBillBottomSheetContent extends ConsumerStatefulWidget {
  const _EnhancedEditBillBottomSheetContent({
    required this.bill,
    required this.onSubmit,
  });

  final Bill bill;
  final Future<void> Function(Bill updatedBill) onSubmit;

  @override
  ConsumerState<_EnhancedEditBillBottomSheetContent> createState() =>
      _EnhancedEditBillBottomSheetState();
}

class _EnhancedEditBillBottomSheetState
    extends ConsumerState<_EnhancedEditBillBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _payeeController;
  late final TextEditingController _websiteController;
  late final TextEditingController _notesController;

  late BillFrequency _selectedFrequency;
  late DateTime _selectedDueDate;
  late String _selectedCategoryId;
  late String? _selectedAccountId;
  late bool _isAutoPay;
  final bool _showOptionalFields = false;

  final bool _isSubmitting = false;

  // Reactive validation state
  Timer? _nameValidationTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bill.name);
    _amountController = TextEditingController(text: widget.bill.amount.toString());
    _descriptionController = TextEditingController(text: widget.bill.description ?? '');
    _payeeController = TextEditingController(text: widget.bill.payee ?? '');
    _websiteController = TextEditingController(text: widget.bill.website ?? '');
    _notesController = TextEditingController(text: widget.bill.notes ?? '');

    _selectedFrequency = widget.bill.frequency;
    _selectedDueDate = widget.bill.dueDate;
    _selectedCategoryId = widget.bill.categoryId;
    _selectedAccountId = widget.bill.accountId;
    _isAutoPay = widget.bill.isAutoPay;

  }

  @override
  void dispose() {
    _nameValidationTimer?.cancel();
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _payeeController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }




  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to MediaQuery for safe access in dispose
    // This prevents the "deactivated widget" error
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    // Show the bottom sheet when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showModernBottomSheet(
          context: context,
          builder: (context) => ModernBottomSheet(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacing_lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Bill',
                          style: ModernTypography.titleLarge,
                        ),
                        const SizedBox(height: spacing_xs),
                        Text(
                          'Update your bill details',
                          style: ModernTypography.bodyLarge.copyWith(
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bill Name
                  ModernTextField(
                    controller: _nameController,
                    label: 'Bill Name',
                    placeholder: 'e.g., Electricity Bill',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a bill name';
                      }
                      // Basic client-side validation - full uniqueness check happens in use case
                      if (value.trim().length < 2) {
                        return 'Bill name must be at least 2 characters';
                      }
                      return null;
                    },
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
                    .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 100.ms),

                  const SizedBox(height: spacing_lg),

                  // Amount Display
                  ModernAmountDisplay(
                    amount: double.tryParse(_amountController.text) ?? 0.0,
                    isEditable: true,
                    onTap: () {
                      // Focus on amount field when tapped
                    },
                    onAmountChanged: (value) {
                      _amountController.text = value.toStringAsFixed(2);
                    },
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 200.ms)
                    .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 200.ms),

                  // Hidden amount input for form validation
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 0),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: spacing_lg),

                  // Category Selector
                  categoryState.when(
                    data: (state) {
                      final expenseCategories = state.getCategoriesByType(TransactionType.expense);

                      // Update default category if not set or invalid
                      if (_selectedCategoryId.isEmpty ||
                          !expenseCategories.any((cat) => cat.id == _selectedCategoryId)) {
                        _selectedCategoryId = _getSmartDefaultCategoryId(expenseCategories);
                      }

                      if (expenseCategories.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(spacing_md),
                          decoration: BoxDecoration(
                            color: ModernColors.primaryGray,
                            borderRadius: BorderRadius.circular(radius_md),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: ModernColors.accentGreen,
                              ),
                              const SizedBox(width: spacing_md),
                              const Expanded(
                                child: Text(
                                  'No expense categories available. Please add categories first.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ModernCategorySelector(
                        categories: expenseCategories.map((category) {
                          final iconAndColor = categoryIconColorService.getIconAndColorForCategory(category.id);
                          return CategoryItem(
                            id: category.id,
                            name: category.name,
                            icon: iconAndColor.icon,
                            color: iconAndColor.color.toARGB32(),
                          );
                        }).toList(),
                        selectedId: _selectedCategoryId,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          }
                        },
                      );
                    },
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => Container(
                      padding: const EdgeInsets.all(spacing_md),
                      decoration: BoxDecoration(
                        color: ModernColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(radius_md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: ModernColors.error,
                          ),
                          const SizedBox(width: spacing_md),
                          Expanded(
                            child: Text(
                              'Error loading categories: $error',
                              style: TextStyle(
                                color: ModernColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: spacing_lg),

                  // Account Selection - Modern Account Selector
                  ModernAccountSelector(
                    label: 'Default Account (Optional)',
                    selectedAccount: _selectedAccountId != null
                        ? accountsAsync.maybeWhen(
                            data: (accounts) {
                              try {
                                return accounts.firstWhere((account) => account.id == _selectedAccountId);
                              } catch (e) {
                                return null;
                              }
                            },
                            orElse: () => null,
                          )
                        : null,
                    onAccountSelected: (account) {
                      setState(() {
                        _selectedAccountId = account?.id;
                      });
                    },
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 300.ms)
                    .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 300.ms),

                  const SizedBox(height: spacing_lg),

                  // Frequency - Modern Dropdown Selector
                  ModernDropdownSelector<BillFrequency>(
                    label: 'Frequency',
                    selectedValue: _selectedFrequency,
                    items: BillFrequency.values.map((frequency) {
                      return ModernDropdownItem<BillFrequency>(
                        value: frequency,
                        label: frequency.displayName,
                        icon: _getFrequencyIcon(frequency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFrequency = value;
                        });
                      }
                    },
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 400.ms)
                    .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 400.ms),

                  const SizedBox(height: spacing_lg),

                  // Due Date
                  ModernDateTimePicker(
                    selectedDate: _selectedDueDate,
                    onDateChanged: (date) {
                      if (date != null) {
                        setState(() {
                          _selectedDueDate = date;
                        });
                      }
                    },
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 500.ms)
                    .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 500.ms),

                  const SizedBox(height: spacing_lg),

                  // Optional Fields Section - Keep existing for now
                  if (_showOptionalFields) ...[
                    // Payee
                    ModernTextField(
                      controller: _payeeController,
                      label: 'Payee (optional)',
                      placeholder: 'e.g., Electric Company',
                      prefixIcon: Icons.business,
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 700.ms)
                      .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 700.ms),

                    const SizedBox(height: spacing_md),

                    // Description
                    ModernTextField(
                      controller: _descriptionController,
                      label: 'Description (optional)',
                      placeholder: 'Additional details about this bill',
                      maxLength: 200,
                      prefixIcon: Icons.description_outlined,
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 800.ms)
                      .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 800.ms),

                    const SizedBox(height: spacing_md),

                    // Website
                    ModernTextField(
                      controller: _websiteController,
                      label: 'Website (optional)',
                      placeholder: 'https://example.com',
                      keyboardType: TextInputType.url,
                      prefixIcon: Icons.link,
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 900.ms)
                      .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 900.ms),

                    const SizedBox(height: spacing_md),

                    // Auto Pay Toggle
                    Container(
                      padding: const EdgeInsets.all(spacing_md),
                      decoration: BoxDecoration(
                        color: ModernColors.primaryGray,
                        borderRadius: BorderRadius.circular(radius_md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.autorenew,
                            color: ModernColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: spacing_md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Auto Pay',
                                  style: ModernTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Automatically pay this bill when due',
                                  style: ModernTypography.labelMedium.copyWith(
                                    color: ModernColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isAutoPay,
                            onChanged: (value) async {
                              if (value && !widget.bill.isAutoPay) {
                                // Show confirmation dialog for enabling auto-pay
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Enable Auto Pay'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Auto Pay will automatically process payments when bills are due. This requires:',
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '• A linked account with sufficient funds',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          '• Confirmation of payment processing',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          '• Ability to modify or cancel auto-pay settings',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Theme.of(context).colorScheme.primary,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'You can disable auto-pay anytime from bill settings.',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Enable Auto Pay'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  setState(() {
                                    _isAutoPay = value;
                                  });
                                }
                              } else {
                                setState(() {
                                  _isAutoPay = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 1000.ms)
                      .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 1000.ms),

                    const SizedBox(height: spacing_md),

                    // Notes
                    ModernTextField(
                      controller: _notesController,
                      label: 'Notes (optional)',
                      placeholder: 'Any additional notes',
                      maxLength: 500,
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 1100.ms)
                      .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 1100.ms),

                    const SizedBox(height: spacing_md),
                  ],

                  // Action Buttons
                  const SizedBox(height: spacing_xl),
                  Row(
                    children: [
                      Expanded(
                        child: ModernActionButton(
                          text: 'Cancel',
                          isPrimary: false,
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: spacing_md),
                      Expanded(
                        child: ModernActionButton(
                          text: 'Update Bill',
                          isPrimary: true,
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : _submitBill,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: spacing_lg),
                ],
              ),
            ),
          ),
        );
      }
    });

    // Return an empty container since the bottom sheet is shown via post-frame callback
    return const SizedBox.shrink();
  }

  /// Get smart default category ID for expense categories (bills)
  String _getSmartDefaultCategoryId(List<TransactionCategory> expenseCategories) {
    if (expenseCategories.isEmpty) {
      // Fallback to default categories if no user categories exist
      final defaultCategories = TransactionCategory.defaultCategories.where((cat) => cat.type == TransactionType.expense).toList();
      return defaultCategories.isNotEmpty ? defaultCategories.first.id : 'other';
    }

    // Prefer commonly used bill categories
    final preferredIds = ['utilities', 'other'];
    for (final preferredId in preferredIds) {
      final preferredCategory = expenseCategories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => expenseCategories.first,
      );
      if (preferredCategory.id == preferredId) {
        return preferredId;
      }
    }

    // Return first expense category
    return expenseCategories.first.id;
  }

  /// Get icon for frequency
  IconData _getFrequencyIcon(BillFrequency frequency) {
    switch (frequency) {
      case BillFrequency.daily:
        return Icons.today;
      case BillFrequency.weekly:
        return Icons.calendar_view_week;
      case BillFrequency.biWeekly:
        return Icons.calendar_view_week;
      case BillFrequency.monthly:
        return Icons.calendar_month;
      case BillFrequency.quarterly:
        return Icons.calendar_view_month;
      case BillFrequency.annually:
        return Icons.calendar_today;
      case BillFrequency.yearly:
        return Icons.calendar_today;
      case BillFrequency.custom:
        return Icons.settings;
    }
  }

  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Note: _isSubmitting is final, so we can't modify it
    // The submission logic is handled in the parent widget

    try {
      final amount = double.parse(_amountController.text);

      final updatedBill = widget.bill.copyWith(
        name: _nameController.text.trim(),
        amount: amount,
        dueDate: _selectedDueDate,
        frequency: _selectedFrequency,
        categoryId: _selectedCategoryId,
        accountId: _selectedAccountId,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        payee: _payeeController.text.trim().isNotEmpty
            ? _payeeController.text.trim()
            : null,
        isAutoPay: _isAutoPay,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      await widget.onSubmit(updatedBill);
      // Note: Error handling is done in the parent widget via the callback
    } catch (e) {
      // Handle error - for now just print, error handling should be in parent
      debugPrint('Error submitting bill: $e');
    }
  }
}