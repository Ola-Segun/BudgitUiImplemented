import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';

/// Bottom sheet for creating a new recurring income
class CreateRecurringIncomeBottomSheet extends ConsumerStatefulWidget {
  const CreateRecurringIncomeBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateRecurringIncomeBottomSheet(),
    );
  }

  @override
  ConsumerState<CreateRecurringIncomeBottomSheet> createState() => _CreateRecurringIncomeBottomSheetState();
}

class _CreateRecurringIncomeBottomSheetState extends ConsumerState<CreateRecurringIncomeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contentKey = GlobalKey();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payerController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  RecurringIncomeFrequency _selectedFrequency = RecurringIncomeFrequency.monthly;
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  String _selectedCategoryId = '';
  String? _selectedDefaultAccountId;
  bool _isVariableAmount = false;

  bool _isSubmitting = false;

  // Reactive validation state
  String? _nameValidationError;
  Timer? _nameValidationTimer;
  String _lastValidatedName = '';

  @override
  void initState() {
    super.initState();
    _setupNameValidationListener();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameValidationTimer?.cancel();
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _payerController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
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
      _nameValidationError = null;
    });

    // Debounce validation
    _nameValidationTimer = Timer(const Duration(milliseconds: 500), () {
      _validateIncomeName(name);
    });
  }

  Future<void> _validateIncomeName(String name) async {
    if (!mounted) return;

    try {
      final incomeState = ref.read(recurringIncomeNotifierProvider);
      final existingIncomes = incomeState.maybeWhen(
        loaded: (incomes, summary) => incomes,
        orElse: () => <RecurringIncome>[],
      );

      // Check for duplicates (case-insensitive)
      final isDuplicate = existingIncomes.any(
        (income) => income.name.trim().toLowerCase() == name.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _lastValidatedName = name;
          _nameValidationError = isDuplicate
              ? 'An income with this name already exists'
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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
                'CreateRecurringIncomeBottomSheet - Screen height: ${mediaQuery.size.height}, '
                'Content height: ${contentSize.height}, '
                'Available height: ${constraints.maxHeight}, '
                'Overflow amount: ${contentSize.height - constraints.maxHeight}, '
                'Keyboard height: ${mediaQuery.viewInsets.bottom}, '
                'View padding: ${mediaQuery.viewPadding.bottom}',
                name: 'CreateRecurringIncomeBottomSheet',
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
                      'Add Recurring Income',
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
                            // Amount Section
                            _buildAmountSection().animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 100))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 100)),
                            const SizedBox(height: 16),

                            // Category Selection
                            Consumer(
                              builder: (context, ref, child) {
                                final categoryState = ref.watch(categoryNotifierProvider);
                                final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

                                return categoryState.when(
                                  data: (state) {
                                    final incomeCategories = state.getCategoriesByType(TransactionType.income);

                                    // Update default category if not set or invalid
                                    if (_selectedCategoryId.isEmpty ||
                                        !incomeCategories.any((cat) => cat.id == _selectedCategoryId)) {
                                      _selectedCategoryId = _getSmartDefaultCategoryId(incomeCategories);
                                    }

                                    if (incomeCategories.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Text(
                                                'No income categories available. Please add categories first.',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    final categoryItems = incomeCategories.map((category) {
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
                                    height: 60,
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  error: (error, stack) => Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Error loading categories: $error',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
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

                                                        // Income Name with validation
                            ModernTextField(
                              controller: _nameController,
                              placeholder: 'e.g., Salary, Freelance Work',
                              prefixIcon: Icons.title,
                              errorText: _nameValidationError,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an income name';
                                }
                                if (value.trim().length < 2) {
                                  return 'Income name must be at least 2 characters';
                                }
                                return null;
                              },
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 200))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 200)),
                            const SizedBox(height: 16),

                            // Account Selection
                            _buildAccountSelection().animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 400))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 400)),
                            const SizedBox(height: 16),

                            // Frequency Selection
                            ModernToggleButton(
                              options: const ['Weekly', 'Monthly', 'Quarterly', 'Annually'],
                              selectedIndex: _getFrequencyIndex(_selectedFrequency),
                              onChanged: (index) {
                                setState(() {
                                  _selectedFrequency = _getFrequencyFromIndex(index);
                                });
                              },
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 500))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 500)),
                            const SizedBox(height: 16),

                            // Start Date
                            ModernDateTimePicker(
                              selectedDate: _selectedStartDate,
                              onDateChanged: (date) {
                                if (date != null) {
                                  setState(() {
                                    _selectedStartDate = date;
                                  });
                                }
                              },
                              showTime: false,
                            ).animate()
                              .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 600))
                              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 600)),
                            const SizedBox(height: 16),

                            // End Date (Optional)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ModernDateTimePicker(
                                  selectedDate: _selectedEndDate,
                                  onDateChanged: (date) {
                                    setState(() {
                                      _selectedEndDate = date;
                                    });
                                  },
                                  showTime: false,
                                ),
                                if (_selectedEndDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedEndDate = null;
                                        });
                                      },
                                      icon: const Icon(Icons.clear),
                                      label: const Text('Clear end date'),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Leave empty for indefinite income',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Payer
                            ModernTextField(
                              controller: _payerController,
                              label: '',
                              prefixIcon: Icons.business_outlined,
                              placeholder: 'Payer (optional)',
                            ),
                            const SizedBox(height: 16),

                            // Description
                            ModernTextField(
                              controller: _descriptionController,
                              label: '',
                              prefixIcon: Icons.description_outlined,
                              placeholder: 'Additional details (optional)',
                              maxLength: 200,
                            ),
                            const SizedBox(height: 16),

                            // Website
                            ModernTextField(
                              controller: _websiteController,
                              label: '',
                              prefixIcon: Icons.link,
                              placeholder: 'Website (optional) - e.g., https://example.com',
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 16),

                            // Notes
                            ModernTextField(
                              controller: _notesController,
                              label: '',
                              prefixIcon: Icons.note_outlined,
                              placeholder: 'Notes (optional)',
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
                text: 'Add Income',
                onPressed: _isSubmitting ? null : () {
                  developer.log('CreateRecurringIncomeBottomSheet: Add Income button pressed', name: 'CreateRecurringIncomeBottomSheet');
                  _submitIncome();
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

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variable Amount Toggle
        ModernToggleButton(
          options: const ['Fixed', 'Variable'],
          selectedIndex: _isVariableAmount ? 1 : 0,
          onChanged: (index) {
            setState(() {
              _isVariableAmount = index == 1;
              if (!_isVariableAmount) {
                _minAmountController.clear();
                _maxAmountController.clear();
              }
            });
          },
        ),
        const SizedBox(height: 16),

        if (_isVariableAmount) ...[
          // Min and Max Amount Fields
          Row(
            children: [
              Expanded(
                child: ModernTextField(
                  controller: _minAmountController,
                  prefixIcon: Icons.arrow_downward_outlined,
                  label: ' Min',
                  placeholder: '0.00',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (_isVariableAmount) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Invalid amount';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernTextField(
                  controller: _maxAmountController,
                  prefixIcon: Icons.arrow_upward_outlined,
                  label: ' Max',
                  placeholder: '0.00',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (_isVariableAmount) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Invalid amount';
                      }
                      final minAmount = double.tryParse(_minAmountController.text);
                      if (minAmount != null && amount <= minAmount) {
                        return 'Must be > min';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Expected Amount (for calculations)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],

        // Amount Display/Input
        ModernAmountDisplay(
          amount: double.tryParse(_amountController.text) ?? 0.0,
          isEditable: true,
          onAmountChanged: (amount) {
            developer.log('CreateRecurringIncomeBottomSheet: Amount changed to $amount', name: 'CreateRecurringIncomeBottomSheet');
            _amountController.text = amount.toStringAsFixed(2);
          },
          onValueChanged: (value) {
            developer.log('CreateRecurringIncomeBottomSheet: Amount value changed to $value', name: 'CreateRecurringIncomeBottomSheet');
            setState(() {
              _amountController.text = value;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          _isVariableAmount ? 'Expected Amount' : 'Amount',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildAccountSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final accountsAsync = ref.watch(filteredAccountsProvider);

        return accountsAsync.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No accounts available. You can still create the income and assign accounts later.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Smart default selection for creation
            if (_selectedDefaultAccountId == null) {
              final defaultAccount = accounts.firstWhere(
                (account) => account.type == AccountType.bankAccount && account.isActive,
                orElse: () => accounts.firstWhere(
                  (account) => account.isActive,
                  orElse: () => accounts.first,
                ),
              );
              _selectedDefaultAccountId = defaultAccount.id;
            }

            // Validate selected accounts exist
            if (_selectedDefaultAccountId != null &&
                !accounts.any((account) => account.id == _selectedDefaultAccountId)) {
              _selectedDefaultAccountId = null;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Default Account
                ModernDropdownSelector<String?>(
                  label: '',
                  placeholder: 'No default account',
                  selectedValue: _selectedDefaultAccountId,
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
                    setState(() => _selectedDefaultAccountId = value);
                  },
                ),

              ],
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Error loading accounts: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      },
    );
  }

  /// Get index for frequency in toggle button
  int _getFrequencyIndex(RecurringIncomeFrequency frequency) {
    switch (frequency) {
      case RecurringIncomeFrequency.weekly:
        return 0;
      case RecurringIncomeFrequency.monthly:
        return 1;
      case RecurringIncomeFrequency.quarterly:
        return 2;
      case RecurringIncomeFrequency.annually:
        return 3;
      default:
        return 1; // Default to monthly
    }
  }

  /// Get frequency from toggle button index
  RecurringIncomeFrequency _getFrequencyFromIndex(int index) {
    switch (index) {
      case 0:
        return RecurringIncomeFrequency.weekly;
      case 1:
        return RecurringIncomeFrequency.monthly;
      case 2:
        return RecurringIncomeFrequency.quarterly;
      case 3:
        return RecurringIncomeFrequency.annually;
      default:
        return RecurringIncomeFrequency.monthly;
    }
  }

  /// Get smart default category ID for income categories
  String _getSmartDefaultCategoryId(List<TransactionCategory> incomeCategories) {
    if (incomeCategories.isEmpty) {
      // Fallback to default categories if no user categories exist
      final defaultCategories = TransactionCategory.defaultCategories.where((cat) => cat.type == TransactionType.income).toList();
      return defaultCategories.isNotEmpty ? defaultCategories.first.id : 'other';
    }

    // Prefer commonly used income categories
    final preferredIds = ['salary', 'freelance', 'business', 'other'];
    for (final preferredId in preferredIds) {
      final preferredCategory = incomeCategories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => incomeCategories.first,
      );
      if (preferredCategory.id == preferredId) {
        return preferredId;
      }
    }

    // Return first income category
    return incomeCategories.first.id;
  }

  Future<void> _submitIncome() async {
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
      final amount = double.parse(_amountController.text);

      // Validate variable amount constraints
      double? minAmount;
      double? maxAmount;
      if (_isVariableAmount) {
        minAmount = double.tryParse(_minAmountController.text);
        maxAmount = double.tryParse(_maxAmountController.text);

        if (minAmount != null && maxAmount != null && minAmount >= maxAmount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Minimum amount must be less than maximum amount'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final income = RecurringIncome(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        amount: amount,
        startDate: _selectedStartDate,
        frequency: _selectedFrequency,
        categoryId: _selectedCategoryId,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        payer: _payerController.text.trim().isNotEmpty
            ? _payerController.text.trim()
            : null,
        endDate: _selectedEndDate,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        defaultAccountId: _selectedDefaultAccountId,
        allowedAccountIds: null,
        isVariableAmount: _isVariableAmount,
        minAmount: minAmount,
        maxAmount: maxAmount,
      );

      final success = await ref
          .read(recurringIncomeNotifierProvider.notifier)
          .createIncome(income);

      if (success && mounted) {
        // Invalidate dashboard to refresh data
        ref.invalidate(dashboardDataProvider);
        // Use a post-frame callback to ensure the widget is still mounted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recurring income added successfully')),
            );
            Navigator.pop(context);
          }
        });
      } else if (mounted) {
        // Get the error message from the state
        final incomeState = ref.read(recurringIncomeNotifierProvider);
        final errorMessage = incomeState.maybeWhen(
          error: (message, incomes, summary) => message,
          orElse: () => 'Failed to add recurring income',
        );

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}