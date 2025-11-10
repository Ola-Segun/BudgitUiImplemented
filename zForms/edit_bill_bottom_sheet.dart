import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/enhanced_bottom_sheet.dart';
import '../../../../core/design_system/components/enhanced_text_field.dart';
import '../../../../core/design_system/components/enhanced_dropdown_field.dart';
import '../../../../core/design_system/components/enhanced_switch_field.dart';
import '../../../../core/design_system/components/category_button_selector.dart';
import '../../../../core/design_system/components/optional_fields_toggle.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';

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
  bool _showOptionalFields = false;

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

    // Show the bottom sheet when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        EnhancedBottomSheet.showForm(
          context: context,
          title: 'Edit Bill',
          subtitle: 'Update your bill details',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Optional Fields Toggle
                OptionalFieldsToggle(
                  onChanged: (show) {
                    setState(() {
                      _showOptionalFields = show;
                    });
                  },
                  label: 'Show optional fields',
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

                SizedBox(height: FormTokens.sectionGap),

                // Bill Name
                EnhancedTextField(
                  controller: _nameController,
                  label: 'Bill Name',
                  hint: 'e.g., Electricity Bill',
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
                  autofocus: true,
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

                SizedBox(height: FormTokens.fieldGapMd),

                // Amount
                EnhancedTextField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '0.00',
                  prefix: Icon(
                    Icons.attach_money,
                    color: FormTokens.iconColor,
                    size: DesignTokens.iconMd,
                  ),
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
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

                SizedBox(height: FormTokens.fieldGapMd),

                // Category
                categoryState.when(
                  data: (state) {
                    final categories = state.getCategoriesByType(TransactionType.expense); // Bills can use expense categories

                    return CategoryButtonSelector(
                      categories: categories,
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: (value) {
                        if (value != null) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        }
                      },
                      categoryIconColorService: categoryIconColorService,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                      .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms);
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error loading categories: $error'),
                ),

                SizedBox(height: FormTokens.fieldGapMd),

                // Account Selection
                accountsAsync.when(
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorTokens.surfaceTertiary,
                          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: ColorTokens.teal500,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No accounts available. You can still edit the bill and assign an account later.',
                                style: TextStyle(
                                  color: ColorTokens.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Validate selected account ID exists
                    if (_selectedAccountId != null &&
                        !accounts.any((account) => account.id == _selectedAccountId)) {
                      _selectedAccountId = null;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EnhancedDropdownField<String?>(
                          label: 'Default Account (Optional)',
                          hint: 'Select an account',
                          items: [
                            DropdownItem<String?>(
                              value: null,
                              label: 'No account selected',
                            ),
                            ...accounts.map((account) {
                              return DropdownItem<String?>(
                                value: account.id,
                                label: account.displayName,
                                subtitle: account.formattedAvailableBalance,
                                icon: Icons.account_balance_wallet,
                                iconColor: Color(account.type.color),
                              );
                            }),
                          ],
                          value: _selectedAccountId,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedAccountId = value);
                          },
                          helper: 'Account to use for automatic payments',
                        ).animate()
                          .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                          .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),
                        // Only show info message if an account is actually selected
                        if (_selectedAccountId != null) ...[
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              // Find the selected account safely
                              final selectedAccount = accounts.firstWhere(
                                (account) => account.id == _selectedAccountId,
                              );

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ColorTokens.surfaceTertiary,
                                  borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: ColorTokens.teal500,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Payments will be deducted from ${selectedAccount.displayName}',
                                        style: TextStyle(
                                          color: ColorTokens.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.critical500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
                    ),
                    child: Text(
                      'Error loading accounts: $error',
                      style: TextStyle(color: ColorTokens.critical500),
                    ),
                  ),
                ),

                SizedBox(height: FormTokens.fieldGapMd),

                // Frequency
                EnhancedDropdownField<BillFrequency>(
                  label: 'Frequency',
                  items: BillFrequency.values.map((frequency) {
                    return DropdownItem<BillFrequency>(
                      value: frequency,
                      label: frequency.displayName,
                      icon: Icons.repeat,
                      iconColor: ColorTokens.teal500,
                    );
                  }).toList(),
                  value: _selectedFrequency,
                  onChanged: (value) {
                    if (value != null) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedFrequency = value;
                      });
                    }
                  },
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

                SizedBox(height: FormTokens.fieldGapMd),

                // Due Date
                _buildDatePicker().animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                  .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

                SizedBox(height: FormTokens.fieldGapMd),

                // Optional Fields Section
                if (_showOptionalFields) ...[
                  // Payee
                  EnhancedTextField(
                    controller: _payeeController,
                    label: 'Payee (optional)',
                    hint: 'e.g., Electric Company',
                    prefix: Icon(
                      Icons.business,
                      color: FormTokens.iconColor,
                      size: DesignTokens.iconMd,
                    ),
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
                    .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

                  SizedBox(height: FormTokens.fieldGapMd),

                  // Description
                  EnhancedTextField(
                    controller: _descriptionController,
                    label: 'Description (optional)',
                    hint: 'Additional details about this bill',
                    prefix: Icon(
                      Icons.description_outlined,
                      color: FormTokens.iconColor,
                      size: DesignTokens.iconMd,
                    ),
                    maxLength: 200,
                    maxLines: 2,
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
                    .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms),

                  SizedBox(height: FormTokens.fieldGapMd),

                  // Website
                  EnhancedTextField(
                    controller: _websiteController,
                    label: 'Website (optional)',
                    hint: 'https://example.com',
                    prefix: Icon(
                      Icons.link,
                      color: FormTokens.iconColor,
                      size: DesignTokens.iconMd,
                    ),
                    keyboardType: TextInputType.url,
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
                    .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms),

                  SizedBox(height: FormTokens.fieldGapMd),

                  // Auto Pay
                  EnhancedSwitchField(
                    title: 'Auto Pay',
                    subtitle: 'Automatically pay this bill when due',
                    value: _isAutoPay,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isAutoPay = value;
                      });
                    },
                    icon: Icons.autorenew,
                    iconColor: ColorTokens.teal500,
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 1000.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1000.ms),

                  SizedBox(height: FormTokens.fieldGapMd),

                  // Notes
                  EnhancedTextField(
                    controller: _notesController,
                    label: 'Notes (optional)',
                    hint: 'Any additional notes',
                    maxLines: 3,
                    maxLength: 500,
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
                    .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1100.ms),

                  SizedBox(height: FormTokens.fieldGapMd),
                ],
              ],
            ),
          ),
          actions: [
            _buildCancelButton(),
            _buildUpdateButton(),
          ],
        );
      }
    });

    // Return an empty container since the bottom sheet is shown via post-frame callback
    return const SizedBox.shrink();
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDueDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          );
          if (date != null) {
            setState(() {
              _selectedDueDate = date;
            });
          }
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: FormTokens.fieldPaddingH,
            vertical: FormTokens.fieldPaddingV,
          ),
          decoration: BoxDecoration(
            color: FormTokens.fieldBackground,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
            border: Border.all(
              color: FormTokens.fieldBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Due Date',
                      style: TypographyTokens.captionMd.copyWith(
                        color: FormTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing05),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDueDate),
                      style: TypographyTokens.labelMd,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: DesignTokens.iconMd,
                color: FormTokens.iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, FormTokens.fieldHeightMd),
        side: BorderSide(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        ),
      ),
      child: Text('Cancel', style: TypographyTokens.labelMd),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1100.ms);
  }

  Widget _buildUpdateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        boxShadow: _isSubmitting
            ? []
            : DesignTokens.elevationColored(ColorTokens.teal500, alpha: 0.3),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(0, FormTokens.fieldHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Update Bill',
                style: TypographyTokens.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 1300.ms : 700.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 1300.ms : 700.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: _showOptionalFields ? 1300.ms : 700.ms);
  }

  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Validate selected account if one is chosen
      if (_selectedAccountId != null) {
        final accountsAsync = ref.read(filteredAccountsProvider);
        final accounts = accountsAsync.maybeWhen(
          data: (data) => data,
          orElse: () => <Account>[],
        );

        final selectedAccount = accounts.firstWhere(
          (account) => account.id == _selectedAccountId,
        );

        if (!selectedAccount.isActive) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selected account is inactive. Please select a different account.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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