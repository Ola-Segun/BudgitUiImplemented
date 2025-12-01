import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/design_tokens.dart';
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
  final bool _showOptionalFields = true;

  bool _isSubmitting = false;

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

    return ModernBottomSheet(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Diagnostic logging to monitor screen height, content height, and overflow amounts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final contentSize = context.findRenderObject()?.semanticBounds.size;
            final mediaQuery = MediaQuery.of(context);
            if (contentSize != null) {
              developer.log(
                'EditBillBottomSheet - Screen height: ${mediaQuery.size.height}, '
                'Content height: ${contentSize.height}, '
                'Available height: ${constraints.maxHeight}, '
                'Overflow amount: ${contentSize.height - constraints.maxHeight}, '
                'Keyboard height: ${mediaQuery.viewInsets.bottom}, '
                'View padding: ${mediaQuery.viewPadding.bottom}',
                name: 'EditBillBottomSheet',
              );
            }
          });

          return Column(
            children: [
              // Fixed Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: spacing_md),
                child: Row(
                  children: [
                    Text(
                      'Edit Bill',
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

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
                  child: Column(
                    children: [
                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                  // Amount Display
                  ModernAmountDisplay(
                    amount: double.tryParse(_amountController.text) ?? 0.0,
                    isEditable: true,
                    onTap: () {
                      developer.log('EditBillBottomSheet: Amount display tapped', name: 'EditBillBottomSheet');
                      // Focus on amount field when tapped
                    },
                    onAmountChanged: (value) {
                      developer.log('EditBillBottomSheet: Amount changed to $value', name: 'EditBillBottomSheet');
                      _amountController.text = value.toStringAsFixed(2);
                    },
                    onValueChanged: (value) {
                      developer.log('EditBillBottomSheet: Amount value changed to $value', name: 'EditBillBottomSheet');
                      setState(() {
                        _amountController.text = value;
                      });
                    },
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

                  const SizedBox(height: spacing_lg),

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
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),


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

                  // Account Selection
                  accountsAsync.when(
                    data: (accounts) {
                      return ModernDropdownSelector<String?>(
                        label: 'Default Account (Optional)',
                        placeholder: 'No default account',
                        selectedValue: _selectedAccountId,
                        items: [
                          ModernDropdownItem(
                            value: null,
                            label: 'No default account',
                          ),
                          ...accounts.map((account) {
                            return ModernDropdownItem(
                              value: account.id,
                              label: '${account.displayName} (${account.formattedAvailableBalance})',
                              icon: Icons.account_balance_wallet,
                              color: Color(account.type.color),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountId = value;
                          });
                        },
                      );
                    },
                    loading: () => const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ModernColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(radius_md),
                      ),
                      child: Text(
                        'Error loading accounts: $error',
                        style: TextStyle(color: ModernColors.error),
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 300.ms)
                    .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 300.ms),

                  const SizedBox(height: spacing_lg),

                  // Frequency
                  ModernToggleButton(
                    options: const ['Weekly', 'Monthly', 'Quarterly', 'Annually'],
                    selectedIndex: _getFrequencyIndex(_selectedFrequency),
                    onChanged: (index) {
                      setState(() {
                        _selectedFrequency = _getFrequencyFromIndex(index);
                      });
                    },
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 400.ms)
                    .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 400.ms),

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
                    .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 500.ms),

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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Action Button
              ModernActionButton(
                text: 'Update Bill',
                onPressed: _isSubmitting ? null : () {
                  developer.log('EditBillBottomSheet: Update Bill button pressed', name: 'EditBillBottomSheet');
                  _submitBill();
                },
                isLoading: _isSubmitting,
                minimumPressDuration: const Duration(milliseconds: 100),
              ),
              const SizedBox(height: spacing_lg),
            ],
          );
        },
      ),
    );
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

  /// Get index for frequency in toggle button
  int _getFrequencyIndex(BillFrequency frequency) {
    switch (frequency) {
      case BillFrequency.weekly:
        return 0;
      case BillFrequency.monthly:
        return 1;
      case BillFrequency.quarterly:
        return 2;
      case BillFrequency.annually:
      case BillFrequency.yearly:
        return 3;
      default:
        return 1; // Default to monthly
    }
  }

  /// Get frequency from toggle button index
  BillFrequency _getFrequencyFromIndex(int index) {
    switch (index) {
      case 0:
        return BillFrequency.weekly;
      case 1:
        return BillFrequency.monthly;
      case 2:
        return BillFrequency.quarterly;
      case 3:
        return BillFrequency.annually;
      default:
        return BillFrequency.monthly;
    }
  }


  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

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
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}