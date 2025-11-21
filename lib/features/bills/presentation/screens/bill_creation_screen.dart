import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/error/failures.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../accounts/presentation/widgets/modern_account_selector.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../domain/entities/bill.dart';
import '../../domain/usecases/validate_bill_account.dart';
import '../providers/bill_providers.dart';

/// Screen for creating a new bill
class BillCreationScreen extends ConsumerStatefulWidget {
  const BillCreationScreen({super.key});

  @override
  ConsumerState<BillCreationScreen> createState() => _BillCreationScreenState();
}

class _BillCreationScreenState extends ConsumerState<BillCreationScreen> {
   final _formKey = GlobalKey<FormState>();
   final _nameController = TextEditingController();
   final _amountController = TextEditingController();
   final _descriptionController = TextEditingController();
   final _payeeController = TextEditingController();
   final _websiteController = TextEditingController();
   final _notesController = TextEditingController();

   BillFrequency _selectedFrequency = BillFrequency.monthly;
   DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
   String _selectedCategoryId = ''; // Will be set dynamically
   String? _selectedAccountId;
   bool _isAutoPay = false;

   bool _isSubmitting = false;

   // Reactive validation state
   String? _nameValidationError;
   bool _isValidatingName = false;
   Timer? _nameValidationTimer;
   String _lastValidatedName = '';

  @override
  void initState() {
    super.initState();
    _setupNameValidationListener();
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

  void _setupNameValidationListener() {
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();

    // Clear validation error if name is empty
    if (name.isEmpty) {
      setState(() {
        _nameValidationError = null;
        _isValidatingName = false;
      });
      _nameValidationTimer?.cancel();
      return;
    }

    // Don't validate if name hasn't changed
    if (name == _lastValidatedName) {
      return;
    }

    // Cancel previous timer
    _nameValidationTimer?.cancel();

    // Set validating state
    setState(() {
      _isValidatingName = true;
      _nameValidationError = null;
    });

    // Debounce validation
    _nameValidationTimer = Timer(const Duration(milliseconds: 500), () {
      _validateBillName(name);
    });
  }

  Future<void> _validateBillName(String name) async {
    if (!mounted) return;

    try {
      final billState = ref.read(billNotifierProvider);
      final existingBills = billState.maybeWhen(
        loaded: (bills, summary) => bills,
        orElse: () => <Bill>[],
      );

      // Check for duplicates (case-insensitive)
      final isDuplicate = existingBills.any(
        (bill) => bill.name.trim().toLowerCase() == name.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _isValidatingName = false;
          _lastValidatedName = name;
          _nameValidationError = isDuplicate
              ? 'A bill with this name already exists'
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingName = false;
          _nameValidationError = null; // Clear error on failure
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to MediaQuery for safe access in dispose
    // This prevents the "deactivated widget" error
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bill'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: AppTheme.screenPaddingAll,
              children: [
                // Bill Name
                ModernTextField(
                  controller: _nameController,
                  label: 'Bill Name',
                  placeholder: 'e.g., Electricity Bill',
                  errorText: _nameValidationError,
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
                ),
                const SizedBox(height: spacing_lg),

                // Amount Display
                ModernAmountDisplay(
                  amount: double.tryParse(_amountController.text) ?? 0.0,
                  isEditable: true,
                  onTap: () {
                    // Focus on amount field when tapped
                    // Implementation would show keyboard or picker
                  },
                  onAmountChanged: (value) {
                    _amountController.text = value.toStringAsFixed(2);
                  },
                ),
                const SizedBox(height: spacing_lg),

                // Amount Input (hidden but functional)
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
                  style: const TextStyle(fontSize: 0), // Hidden
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            const SizedBox(height: 16),

                // Category Selector
                Consumer(
                  builder: (context, ref, child) {
                    final categoryState = ref.watch(categoryNotifierProvider);
                    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

                    return categoryState.when(
                      data: (state) {
                        final expenseCategories = state.getCategoriesByType(TransactionType.expense);

                        // Update default category if not set or invalid
                        if (_selectedCategoryId.isEmpty ||
                            !expenseCategories.any((cat) => cat.id == _selectedCategoryId)) {
                          _selectedCategoryId = _getSmartDefaultCategoryId(expenseCategories);
                        }

                        if (expenseCategories.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
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

                        final categoryItems = expenseCategories.map((category) {
                          final iconAndColor = categoryIconColorService.getIconAndColorForCategory(category.id);
                          return CategoryItem(
                            id: category.id,
                            name: category.name,
                            icon: iconAndColor.icon,
                            color: iconAndColor.color.value,
                          );
                        }).toList();

                        return ModernCategorySelector(
                          categories: categoryItems,
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ModernColors.error.withOpacity(0.1),
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
                    );
                  },
                ),
            const SizedBox(height: 16),

            // Account Selection
// Replace the entire Account Selection Consumer widget in BOTH files with this:

// Account Selection - Modern Account Selector
ModernAccountSelector(
  label: 'Default Account (Optional)',
  selectedAccount: _selectedAccountId != null
      ? ref.watch(filteredAccountsProvider).maybeWhen(
          data: (accounts) => accounts.firstWhere(
            (account) => account.id == _selectedAccountId,
            orElse: () => null as Account,
          ),
          orElse: () => null,
        )
      : null,
  onAccountSelected: (account) {
    setState(() {
      _selectedAccountId = account?.id;
    });
  },
),
            const SizedBox(height: 16),

                // Frequency
                ModernDropdownSelector<BillFrequency>(
                  label: 'Frequency',
                  selectedValue: _selectedFrequency,
                  items: BillFrequency.values.map((frequency) {
                    return ModernDropdownItem(
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
                ),
            const SizedBox(height: 16),

                // Due Date Picker
                ModernDateTimePicker(
                  selectedDate: _selectedDueDate,
                  onDateChanged: (date) {
                    if (date != null) {
                      setState(() {
                        _selectedDueDate = date;
                      });
                    }
                  },
                ),
            const SizedBox(height: 16),

                // Optional Fields Section
                // Payee
                ModernTextField(
                  controller: _payeeController,
                  label: 'Payee (optional)',
                  placeholder: 'e.g., Electric Company',
                  prefixIcon: Icons.business,
                ),
                const SizedBox(height: spacing_md),

                // Description
                ModernTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  placeholder: 'Additional details about this bill',
                  maxLength: 200,
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: spacing_md),

                // Website
                ModernTextField(
                  controller: _websiteController,
                  label: 'Website (optional)',
                  placeholder: 'https://example.com',
                  keyboardType: TextInputType.url,
                  prefixIcon: Icons.link,
                ),
                const SizedBox(height: spacing_md),

                // Auto Pay Toggle
                // Keep existing auto-pay logic but modernize the UI
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
                          if (value) {
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
                ),
                const SizedBox(height: spacing_md),

                // Notes
                ModernTextField(
                  controller: _notesController,
                  label: 'Notes (optional)',
                  placeholder: 'Any additional notes',
                  maxLength: 500,
                ),

            const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ModernActionButton(
                        text: 'Cancel',
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: spacing_md),
                    Expanded(
                      child: ModernActionButton(
                        text: 'Add Bill',
                        onPressed: _isSubmitting ? null : _submitBill,
                        isLoading: _isSubmitting,
                      ),
                    ),
                  ],
                ),
          ],
        ),
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

// In your _submitBill method, replace the createBill call section with this:

Future<void> _submitBill() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // Check for instant validation error
  if (_nameValidationError != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_nameValidationError!),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final billAmount = double.parse(_amountController.text);

    // Validate selected account if one is chosen
    if (_selectedAccountId != null) {
      final accountRepository = ref.read(core_providers.accountRepositoryProvider);
      final validateAccount = ValidateBillAccount(accountRepository);
      final accountValidation = await validateAccount(_selectedAccountId, billAmount);

      if (accountValidation.isError) {
        final failure = accountValidation.failureOrNull!;

        String errorMessage = failure.message;
        if (failure is ValidationFailure) {
          final errors = failure.errors;
          if (errors.containsKey('accountId')) {
            errorMessage = errors['accountId']!;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    }

    final amount = double.parse(_amountController.text);

    final bill = Bill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

    final success = await ref
        .read(billNotifierProvider.notifier)
        .createBill(bill);

    if (success && mounted) {
      // Invalidate dashboard to refresh data
      ref.invalidate(dashboardDataProvider);
      // Use a post-frame callback to ensure the widget is still mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill added successfully')),
          );
          Navigator.pop(context);
        }
      });
    } else if (mounted) {
      // Get the error message from the state
      final billState = ref.read(billNotifierProvider);
      final errorMessage = billState.maybeWhen(
        error: (message, bills, summary) => message ?? 'Failed to add bill',
        orElse: () => 'Failed to add bill',
      );

      // IMPORTANT: Clear the error state by reloading bills
      // This prevents the error from persisting when navigating back
      await ref.read(billNotifierProvider.notifier).clearError();

      // Use a post-frame callback to ensure the widget is still mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
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