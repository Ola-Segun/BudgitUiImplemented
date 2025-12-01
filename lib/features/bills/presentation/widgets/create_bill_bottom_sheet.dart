import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/error/failures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../domain/entities/bill.dart';
import '../../domain/usecases/validate_bill_account.dart';
import '../providers/bill_providers.dart';

/// Bottom sheet for creating a new bill
class CreateBillBottomSheet extends ConsumerStatefulWidget {
  const CreateBillBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateBillBottomSheet(),
    );
  }

  @override
  ConsumerState<CreateBillBottomSheet> createState() => _CreateBillBottomSheetState();
}

class _CreateBillBottomSheetState extends ConsumerState<CreateBillBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contentKey = GlobalKey();
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
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Diagnostic logging to monitor screen height, content height, and overflow amounts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final contentSize = _contentKey.currentContext?.size;
            final mediaQuery = MediaQuery.of(context);
            if (contentSize != null) {
              developer.log(
                'CreateBillBottomSheet - Screen height: ${mediaQuery.size.height}, '
                'Content height: ${contentSize.height}, '
                'Available height: ${constraints.maxHeight}, '
                'Overflow amount: ${contentSize.height - constraints.maxHeight}, '
                'Keyboard height: ${mediaQuery.viewInsets.bottom}, '
                'View padding: ${mediaQuery.viewPadding.bottom}',
                name: 'CreateBillBottomSheet',
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
                      'Add Bill',
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
                    key: _contentKey,
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
                              onAmountChanged: (value) {
                                developer.log('CreateBillBottomSheet: Amount changed to $value', name: 'CreateBillBottomSheet');
                                _amountController.text = value.toStringAsFixed(2);
                              },
                              onValueChanged: (value) {
                                developer.log('CreateBillBottomSheet: Amount value changed to $value', name: 'CreateBillBottomSheet');
                                setState(() {
                                  _amountController.text = value;
                                });
                              },
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 100))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 100)),
                            const SizedBox(height: spacing_lg),


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
                                        color: iconAndColor.color.toARGB32(),
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
                                );
                              },
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 300))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 300)),
                            const SizedBox(height: 16),

                            // Account Selection
                            Consumer(
                              builder: (context, ref, child) {
                                final accountsAsync = ref.watch(filteredAccountsProvider);

                                return accountsAsync.when(
                                  data: (accounts) {
                                    return ModernDropdownSelector<String?>(
                                      label: '',
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
                                        developer.log('CreateBillBottomSheet: Account changed to $value', name: 'CreateBillBottomSheet');
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
                                );
                              },
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 400))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 400)),
                            const SizedBox(height: 16),

                            // Frequency
                            ModernToggleButton(
                              options: const ['Weekly', 'Monthly', 'Quarterly', 'Annually'],
                              selectedIndex: _getFrequencyIndex(_selectedFrequency),
                              onChanged: (index) {
                                developer.log('CreateBillBottomSheet: Frequency changed to index $index', name: 'CreateBillBottomSheet');
                                setState(() {
                                  _selectedFrequency = _getFrequencyFromIndex(index);
                                });
                              },
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 500))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 500)),
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
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 600))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 600)),
                            const SizedBox(height: 16),

                            // Bill Name
                            ModernTextField(
                              controller: _nameController,
                              placeholder: 'e.g., Electricity Bill',
                              prefixIcon: Icons.title,
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
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 200))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 200)),
                            const SizedBox(height: spacing_lg),

                            // Optional Fields Section
                            // Payee
                            ModernTextField(
                              controller: _payeeController,
                              label: '',
                              placeholder: 'Payee (optional)',
                              prefixIcon: Icons.business,
                            ),
                            const SizedBox(height: spacing_md),

                            // Description
                            ModernTextField(
                              controller: _descriptionController,
                              label: '',
                              placeholder: 'Description (optional)',
                              maxLength: 200,
                              prefixIcon: Icons.description_outlined,
                            ),
                            const SizedBox(height: spacing_md),

                            // Website
                            ModernTextField(
                              controller: _websiteController,
                              label: '',
                              placeholder: 'Website (optional) - e.g., https://example.com',
                              keyboardType: TextInputType.url,
                              prefixIcon: Icons.link,
                            ),
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
                              label: '',
                              prefixIcon: Icons.note,
                              placeholder: 'Any additional notes (optional)',
                              maxLength: 500,
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Action Button
              ModernActionButton(
                text: 'Add Bill',
                onPressed: _isSubmitting ? null : () {
                  developer.log('CreateBillBottomSheet: Add Bill button pressed', name: 'CreateBillBottomSheet');
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
    developer.log('CreateBillBottomSheet: _submitBill called', name: 'CreateBillBottomSheet');

    if (!_formKey.currentState!.validate()) {
      developer.log('CreateBillBottomSheet: Form validation failed', name: 'CreateBillBottomSheet');
      return;
    }

    // Check for instant validation error
    if (_nameValidationError != null) {
      developer.log('CreateBillBottomSheet: Name validation error: $_nameValidationError', name: 'CreateBillBottomSheet');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_nameValidationError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    developer.log('CreateBillBottomSheet: Setting _isSubmitting = true', name: 'CreateBillBottomSheet');
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