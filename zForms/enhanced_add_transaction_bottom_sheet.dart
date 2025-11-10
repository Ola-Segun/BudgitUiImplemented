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
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../recurring_transactions/domain/entities/recurring_transaction.dart';

/// Enhanced add transaction bottom sheet with modern design
class EnhancedAddTransactionBottomSheet extends ConsumerWidget {
  const EnhancedAddTransactionBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialType,
  });

  final Future<void> Function(Transaction) onSubmit;
  final TransactionType? initialType;

  // Static flag to prevent multiple instances
  static bool _isShowing = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EnhancedAddTransactionBottomSheetContent(
      onSubmit: onSubmit,
      initialType: initialType,
    );
  }

  /// Static method to show the enhanced add transaction bottom sheet
  /// Prevents multiple instances from being shown simultaneously
  static Future<T?> show<T>({
    required BuildContext context,
    required Future<void> Function(Transaction) onSubmit,
    TransactionType? initialType,
  }) async {
    // Prevent showing multiple instances
    if (_isShowing) {
      return null;
    }

    _isShowing = true;

    try {
      return await EnhancedBottomSheet.showForm<T>(
        context: context,
        title: 'Add Transaction',
        subtitle: initialType != null ? 'Track your ${initialType.displayName.toLowerCase()}' : 'Track your transaction',
        child: EnhancedAddTransactionBottomSheet(
          onSubmit: onSubmit,
          initialType: initialType,
        ),
        actions: const [], // Actions are handled within the form
        onClose: () {
          _isShowing = false;
        },
      );
    } finally {
      // Always reset the flag when the bottom sheet closes, regardless of how it was dismissed
      _isShowing = false;
    }
  }
}

class _EnhancedAddTransactionBottomSheetContent extends ConsumerStatefulWidget {
  const _EnhancedAddTransactionBottomSheetContent({
    required this.onSubmit,
    this.initialType,
  });

  final Future<void> Function(Transaction) onSubmit;
  final TransactionType? initialType;

  @override
  ConsumerState<_EnhancedAddTransactionBottomSheetContent> createState() =>
      _EnhancedAddTransactionBottomSheetState();
}

class _EnhancedAddTransactionBottomSheetState
    extends ConsumerState<_EnhancedAddTransactionBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedAccountId;

  bool _isSubmitting = false;
  bool _showOptionalFields = false;
  bool _isRecurring = false;

  // Recurring transaction fields
  RecurrenceType _selectedRecurrenceType = RecurrenceType.monthly;
  int _recurrenceValue = 1;
  DateTime? _recurringEndDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure we have valid defaults when dependencies change
    _ensureValidDefaults();
  }

  void _ensureValidDefaults() {
    final categoryState = ref.watch(categoryNotifierProvider);
    final accountsAsync = ref.watch(filteredAccountsProvider);

    categoryState.whenData((state) {
      final categories = state.getCategoriesByType(_selectedType);
      if (_selectedCategoryId == null && categories.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedCategoryId = _getSmartDefaultCategoryId(categories);
            });
          }
        });
      }
    });

    accountsAsync.whenData((accounts) {
      if (_selectedAccountId == null && accounts.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedAccountId = accounts.first.id;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryNotifierProvider);
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    return Form(
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

          // Transaction Type Selector
          _buildTypeSelector().animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

          SizedBox(height: FormTokens.sectionGap),

          // Amount Field
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
            autofocus: true,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

          SizedBox(height: FormTokens.fieldGapMd),

          // Category Selection
          categoryState.when(
            data: (state) {
              final categories = state.getCategoriesByType(_selectedType);

              return CategoryButtonSelector(
                categories: categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                categoryIconColorService: categoryIconColorService,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading categories: $error'),
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Account Dropdown
          accountsAsync.when(
            data: (accounts) {
              return EnhancedDropdownField<String>(
                label: 'Account',
                hint: 'Select an account',
                items: accounts.map((account) {
                  return DropdownItem<String>(
                    value: account.id,
                    label: account.displayName,
                    subtitle: account.formattedAvailableBalance,
                    icon: Icons.account_balance_wallet,
                    iconColor: Color(account.type.color),
                  );
                }).toList(),
                value: _selectedAccountId,
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
                selectedItemBuilder: (item) => Text(
                  item.label,
                  style: TypographyTokens.bodyMd,
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an account';
                  }
                  return null;
                },
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms);
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading accounts: $error'),
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Optional Fields Section
          if (_showOptionalFields) ...[
            // Date Picker
            _buildDatePicker().animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Description Field
            EnhancedTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'e.g., Grocery shopping at Walmart',
              prefix: Icon(
                Icons.description_outlined,
                color: FormTokens.iconColor,
                size: DesignTokens.iconMd,
              ),
              maxLength: 100,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Receipt Scanning Button
            _buildReceiptButton().animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

            SizedBox(height: FormTokens.fieldGapMd),

            // Note Field
            EnhancedTextField(
              controller: _noteController,
              label: 'Note (optional)',
              hint: 'Additional details...',
              maxLines: 3,
              maxLength: 200,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
              .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms),

            SizedBox(height: FormTokens.fieldGapMd),
          ],

          SizedBox(height: FormTokens.fieldGapMd),

          // Recurring Transaction Toggle
          EnhancedSwitchField(
            title: 'Make this a recurring transaction',
            subtitle: 'Automatically create this transaction on a schedule',
            value: _isRecurring,
            onChanged: (value) {
              setState(() {
                _isRecurring = value;
              });
            },
            icon: Icons.repeat,
            iconColor: ColorTokens.teal500,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 800.ms : 500.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 800.ms : 500.ms),

          // Recurring Setup Section
          if (_isRecurring) ...[
            SizedBox(height: FormTokens.sectionGap),
            _buildRecurringSetupSection(),
          ],

          SizedBox(height: FormTokens.fieldGapMd),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitTransaction,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, FormTokens.fieldHeightMd),
              backgroundColor: ColorTokens.teal500,
              foregroundColor: ColorTokens.surfacePrimary,
              disabledBackgroundColor: ColorTokens.teal500.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: DesignTokens.iconMd,
                    width: DesignTokens.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.surfacePrimary),
                    ),
                  )
                : Text(
                    _isRecurring ? 'Create Recurring Transaction' : 'Add Transaction',
                    style: TypographyTokens.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 900.ms : 500.ms)
            .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: _showOptionalFields ? 900.ms : 500.ms),

          // Extra bottom padding to ensure button visibility
          SizedBox(height: FormTokens.sectionGap),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.expense,
              icon: Icons.remove_circle_outline,
              label: 'Expense',
              color: ColorTokens.critical500,
            ),
          ),
          Container(
            width: 1.5,
            height: 48,
            color: ColorTokens.borderSecondary,
          ),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              icon: Icons.add_circle_outline,
              label: 'Income',
              color: ColorTokens.success500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedType = type;
            _selectedCategoryId = null; // Reset category when type changes
          });
        },
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        child: AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spacing3,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: DesignTokens.iconMd,
                color: isSelected ? color : ColorTokens.textSecondary,
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                label,
                style: TypographyTokens.labelMd.copyWith(
                  color: isSelected ? color : ColorTokens.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scaleXY(
        begin: 1.0,
        end: 1.02,
        duration: DesignTokens.durationSm,
      );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            setState(() {
              _selectedDate = date;
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
                      'Date',
                      style: TypographyTokens.captionMd.copyWith(
                        color: FormTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing05),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
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

  Widget _buildReceiptButton() {
    return OutlinedButton.icon(
      onPressed: _scanReceipt,
      icon: Icon(Icons.camera_alt, size: DesignTokens.iconMd),
      label: Text('Scan Receipt', style: TypographyTokens.labelMd),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, FormTokens.fieldHeightMd),
        side: BorderSide(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        ),
        foregroundColor: ColorTokens.teal500,
      ),
    );
  }

  Widget _buildRecurringSetupSection() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.borderSecondary,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: ColorTokens.teal500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  Icons.repeat,
                  size: DesignTokens.iconMd,
                  color: ColorTokens.teal500,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recurring Setup',
                      style: TypographyTokens.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing05),
                    Text(
                      'Configure how often this transaction repeats',
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Recurrence Type Selector
          EnhancedDropdownField<RecurrenceType>(
            label: 'Repeat',
            hint: 'Select frequency',
            items: RecurrenceType.values.map((type) {
              return DropdownItem<RecurrenceType>(
                value: type,
                label: type.displayName,
                icon: _getRecurrenceIcon(type),
                iconColor: ColorTokens.teal500,
              );
            }).toList(),
            value: _selectedRecurrenceType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRecurrenceType = value;
                });
              }
            },
          ),

          SizedBox(height: FormTokens.fieldGapMd),

          // Recurrence Value (for non-daily)
          if (_selectedRecurrenceType != RecurrenceType.daily) ...[
            EnhancedTextField(
              controller: TextEditingController(text: _recurrenceValue.toString()),
              label: 'Every',
              hint: '1',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final num = int.tryParse(value);
                if (num == null || num < 1) {
                  return 'Must be at least 1';
                }
                return null;
              },
              onChanged: (value) {
                final num = int.tryParse(value ?? '1');
                if (num != null && num > 0) {
                  setState(() {
                    _recurrenceValue = num;
                  });
                }
              },
            ),
            SizedBox(height: FormTokens.fieldGapMd),
          ],

          // End Date (Optional)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _recurringEndDate ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (date != null) {
                  setState(() {
                    _recurringEndDate = date;
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
                            'End Date (optional)',
                            style: TypographyTokens.captionMd.copyWith(
                              color: FormTokens.labelColor,
                            ),
                          ),
                          SizedBox(height: DesignTokens.spacing05),
                          Text(
                            _recurringEndDate != null
                                ? DateFormat('MMM dd, yyyy').format(_recurringEndDate!)
                                : 'No end date',
                            style: TypographyTokens.labelMd.copyWith(
                              color: _recurringEndDate != null
                                  ? ColorTokens.textPrimary
                                  : ColorTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_recurringEndDate != null)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: DesignTokens.iconSm,
                          color: ColorTokens.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _recurringEndDate = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        size: DesignTokens.iconMd,
                        color: FormTokens.iconColor,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Preview
          SizedBox(height: FormTokens.fieldGapMd),
          Container(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: ColorTokens.teal500.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: ColorTokens.teal500.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: DesignTokens.iconSm,
                  color: ColorTokens.teal500,
                ),
                SizedBox(width: DesignTokens.spacing2),
                Expanded(
                  child: Text(
                    'Next: ${_getNextDueDatePreview()}',
                    style: TypographyTokens.captionMd.copyWith(
                      color: ColorTokens.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal);
  }

  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.calendar_view_week;
      case RecurrenceType.monthly:
        return Icons.calendar_month;
      case RecurrenceType.yearly:
        return Icons.event;
    }
  }

  String _getNextDueDatePreview() {
    try {
      final mockTransaction = RecurringTransaction(
        id: 'preview',
        title: 'Preview',
        amount: 0,
        recurrenceType: _selectedRecurrenceType,
        recurrenceValue: _recurrenceValue,
        startDate: DateTime.now(),
        endDate: _recurringEndDate,
        categoryId: '',
        accountId: '',
      );

      final nextDate = mockTransaction.calculateNextDueDate(DateTime.now());
      if (nextDate != null) {
        return DateFormat('MMM dd, yyyy').format(nextDate);
      }
    } catch (e) {
      // Ignore errors in preview
    }
    return 'Invalid configuration';
  }


  String _getSmartDefaultCategoryId(List<TransactionCategory> categories) {
    if (categories.isEmpty) return '';

    final preferredIds = _selectedType == TransactionType.expense
        ? ['food', 'transport', 'shopping']
        : ['salary', 'freelance'];

    for (final preferredId in preferredIds) {
      final category = categories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => categories.first,
      );
      if (category.id == preferredId) return preferredId;
    }

    return categories.first.id;
  }

  Future<void> _scanReceipt() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Text(
          'Receipt Scanner',
          style: TypographyTokens.heading5,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing5),
              decoration: BoxDecoration(
                color: ColorTokens.teal500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 64,
                color: ColorTokens.teal500,
              ),
            ),
            SizedBox(height: DesignTokens.spacing4),
            Text(
              'Receipt scanning feature is coming soon!\n\nFor now, you can manually enter transaction details.',
              textAlign: TextAlign.center,
              style: TypographyTokens.bodyMd,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TypographyTokens.labelMd),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccountId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an account and category'),
          backgroundColor: ColorTokens.critical500,
        ),
      );
      return;
    }

    // Additional validation for recurring transactions
    if (_isRecurring) {
      if (_recurrenceValue < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recurrence value must be at least 1'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
        return;
      }

      if (_recurringEndDate != null && _recurringEndDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('End date must be in the future'),
            backgroundColor: ColorTokens.critical500,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);

      if (_isRecurring) {
        // Create recurring transaction
        final recurringTransaction = RecurringTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Recurring Transaction',
          amount: amount,
          recurrenceType: _selectedRecurrenceType,
          recurrenceValue: _recurrenceValue,
          startDate: _selectedDate,
          endDate: _recurringEndDate,
          categoryId: _selectedCategoryId!,
          accountId: _selectedAccountId!,
          description: _noteController.text.isNotEmpty
              ? _noteController.text
              : null,
        );

        // TODO: Integrate with recurring transaction repository
        // For now, create a regular transaction as placeholder
        final transaction = Transaction(
          id: recurringTransaction.id,
          title: recurringTransaction.title,
          amount: recurringTransaction.amount,
          type: _selectedType,
          date: _selectedDate,
          categoryId: _selectedCategoryId!,
          accountId: _selectedAccountId!,
          description: _noteController.text.isNotEmpty
              ? _noteController.text
              : null,
        );

        await widget.onSubmit(transaction);
      } else {
        // Create regular transaction
        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Transaction',
          amount: amount,
          type: _selectedType,
          date: _selectedDate,
          categoryId: _selectedCategoryId!,
          accountId: _selectedAccountId!,
          description: _noteController.text.isNotEmpty
              ? _noteController.text
              : null,
        );

        await widget.onSubmit(transaction);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ColorTokens.critical500,
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