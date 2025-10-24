import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/error/failures.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';

/// Screen for editing an existing recurring income
class RecurringIncomeEditingScreen extends ConsumerStatefulWidget {
  const RecurringIncomeEditingScreen({
    super.key,
    required this.incomeId,
  });

  final String incomeId;

  @override
  ConsumerState<RecurringIncomeEditingScreen> createState() => _RecurringIncomeEditingScreenState();
}

class _RecurringIncomeEditingScreenState extends ConsumerState<RecurringIncomeEditingScreen> {
  final _formKey = GlobalKey<FormState>();
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
  List<String> _selectedAllowedAccountIds = [];
  bool _isVariableAmount = false;

  bool _isSubmitting = false;
  bool _isLoading = true;
  RecurringIncome? _originalIncome;

  // Reactive validation state
  String? _nameValidationError;
  bool _isValidatingName = false;
  Timer? _nameValidationTimer;
  String _lastValidatedName = '';

  @override
  void initState() {
    super.initState();
    _setupNameValidationListener();
    _loadIncome();
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
        _isValidatingName = false;
      });
      _nameValidationTimer?.cancel();
      return;
    }

    // Don't validate if name hasn't changed from original
    if (name == _originalIncome?.name) {
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
      _validateIncomeName(name);
    });
  }

  Future<void> _loadIncome() async {
    try {
      final incomeState = ref.read(recurringIncomeNotifierProvider);
      final incomes = incomeState.maybeWhen(
        loaded: (incomes, summary) => incomes,
        orElse: () => <RecurringIncome>[],
      );

      final income = incomes.firstWhere(
        (inc) => inc.id == widget.incomeId,
        orElse: () => throw Exception('Income not found'),
      );

      _originalIncome = income;
      _populateFormFields(income);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading income: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _populateFormFields(RecurringIncome income) {
    _nameController.text = income.name;
    _amountController.text = income.amount.toStringAsFixed(2);
    _descriptionController.text = income.description ?? '';
    _payerController.text = income.payer ?? '';
    _websiteController.text = income.website ?? '';
    _notesController.text = income.notes ?? '';

    _selectedFrequency = income.frequency;
    _selectedStartDate = income.startDate;
    _selectedEndDate = income.endDate;
    _selectedCategoryId = income.categoryId;
    _selectedDefaultAccountId = income.defaultAccountId;
    _selectedAllowedAccountIds = income.allowedAccountIds ?? [];
    _isVariableAmount = income.isVariableAmount;

    if (_isVariableAmount) {
      _minAmountController.text = income.minAmount?.toStringAsFixed(2) ?? '';
      _maxAmountController.text = income.maxAmount?.toStringAsFixed(2) ?? '';
    }
  }

  Future<void> _validateIncomeName(String name) async {
    if (!mounted) return;

    try {
      final incomeState = ref.read(recurringIncomeNotifierProvider);
      final existingIncomes = incomeState.maybeWhen(
        loaded: (incomes, summary) => incomes,
        orElse: () => <RecurringIncome>[],
      );

      // Check for duplicates (case-insensitive), excluding current income
      final isDuplicate = existingIncomes.any(
        (income) => income.id != widget.incomeId &&
                   income.name.trim().toLowerCase() == name.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _isValidatingName = false;
          _lastValidatedName = name;
          _nameValidationError = isDuplicate
              ? 'An income with this name already exists'
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Recurring Income'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recurring Income'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Delete Income',
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: AppTheme.screenPaddingAll,
              children: [
                // Income Name with validation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Income Name',
                        hintText: 'e.g., Salary, Freelance Work',
                        errorStyle: const TextStyle(height: 0.8),
                        errorBorder: (_nameValidationError != null)
                            ? OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        focusedErrorBorder: (_nameValidationError != null)
                            ? OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        suffixIcon: _isValidatingName
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an income name';
                        }
                        if (value.trim().length < 2) {
                          return 'Income name must be at least 2 characters';
                        }
                        return null;
                      },
                      autofocus: false,
                    ),
                    // Show instant validation feedback
                    if (_nameValidationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _nameValidationError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount Section
                _buildAmountSection(),
                const SizedBox(height: 16),

                // Category Selection
                Consumer(
                  builder: (context, ref, child) {
                    final categoryState = ref.watch(categoryNotifierProvider);
                    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

                    return categoryState.when(
                      data: (state) {
                        final incomeCategories = state.getCategoriesByType(TransactionType.income);

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

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: incomeCategories.map((category) {
                            final iconAndColor = categoryIconColorService.getIconAndColorForCategory(category.id);
                            return DropdownMenuItem(
                              value: category.id,
                              child: Row(
                                children: [
                                  Icon(iconAndColor.icon, size: 20, color: iconAndColor.color),
                                  const SizedBox(width: 8),
                                  Text(category.name),
                                ],
                              ),
                            );
                          }).toList(),
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
                ),
                const SizedBox(height: 16),

                // Account Selection
                _buildAccountSelection(),
                const SizedBox(height: 16),

                // Frequency Selection
                DropdownButtonFormField<RecurringIncomeFrequency>(
                  initialValue: _selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                  ),
                  items: RecurringIncomeFrequency.values.map((frequency) {
                    return DropdownMenuItem(
                      value: frequency,
                      child: Text(frequency.displayName),
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

                // Start Date
                InkWell(
                  onTap: () async {
                    if (!mounted) return;
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedStartDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null && mounted) {
                      setState(() {
                        _selectedStartDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM dd, yyyy').format(_selectedStartDate)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // End Date (Optional)
                InkWell(
                  onTap: () async {
                    if (!mounted) return;
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedEndDate ?? _selectedStartDate.add(const Duration(days: 365)),
                      firstDate: _selectedStartDate,
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (date != null && mounted) {
                      setState(() {
                        _selectedEndDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date (Optional)',
                      helperText: 'Leave empty for indefinite income',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedEndDate != null
                            ? DateFormat('MMM dd, yyyy').format(_selectedEndDate!)
                            : 'No end date'),
                        Row(
                          children: [
                            if (_selectedEndDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedEndDate = null;
                                  });
                                },
                              ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payer
                TextFormField(
                  controller: _payerController,
                  decoration: const InputDecoration(
                    labelText: 'Payer (optional)',
                    hintText: 'e.g., Employer Name, Client',
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Additional details about this income',
                  ),
                  maxLength: 200,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Website
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website (optional)',
                    hintText: 'https://example.com',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Any additional notes',
                  ),
                  maxLength: 500,
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () {
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitIncome,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update Income'),
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

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variable Amount Toggle
        SwitchListTile(
          title: const Text('Variable Amount'),
          subtitle: const Text('Income amount varies each period'),
          value: _isVariableAmount,
          onChanged: (value) {
            setState(() {
              _isVariableAmount = value;
              if (!value) {
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
                child: TextFormField(
                  controller: _minAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Min Amount',
                    prefixText: '\$',
                    hintText: '0.00',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                child: TextFormField(
                  controller: _maxAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Max Amount',
                    prefixText: '\$',
                    hintText: '0.00',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

        // Fixed Amount Field
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: _isVariableAmount ? 'Expected Amount' : 'Amount',
            prefixText: '\$',
            hintText: '0.00',
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
                        'No accounts available. You can still edit the income and assign accounts later.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Validate selected accounts exist
            if (_selectedDefaultAccountId != null &&
                !accounts.any((account) => account.id == _selectedDefaultAccountId)) {
              _selectedDefaultAccountId = null;
            }
            _selectedAllowedAccountIds.removeWhere(
              (id) => !accounts.any((account) => account.id == id),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Default Account
                DropdownButtonFormField<String>(
                  initialValue: _selectedDefaultAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Default Account (Optional)',
                    border: OutlineInputBorder(),
                    helperText: 'Primary account for deposits',
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return [
                      const Text('No default account'),
                      ...accounts.map((account) {
                        return Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Color(account.type.color),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                account.displayName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }),
                    ];
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No default account'),
                    ),
                    ...accounts.map((account) {
                      return DropdownMenuItem<String>(
                        value: account.id,
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Color(account.type.color),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    account.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    account.formattedAvailableBalance,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDefaultAccountId = value);
                  },
                ),

                // Allowed Accounts (Multi-select)
                const SizedBox(height: 16),
                Text(
                  'Allowed Accounts (Optional)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: accounts.map((account) {
                    final isSelected = _selectedAllowedAccountIds.contains(account.id);
                    return FilterChip(
                      avatar: Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                        color: isSelected ? Colors.white : Color(account.type.color),
                      ),
                      label: Text(
                        account.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAllowedAccountIds.add(account.id);
                          } else {
                            _selectedAllowedAccountIds.remove(account.id);
                          }
                        });
                      },
                      backgroundColor: isSelected
                          ? Color(account.type.color)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                    );
                  }).toList(),
                ),

                // Info message
                if (_selectedDefaultAccountId != null) ...[
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final selectedAccount = accounts.firstWhere(
                        (account) => account.id == _selectedDefaultAccountId,
                      );
                      return Container(
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
                                'Income will be deposited to ${selectedAccount.displayName}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Future<void> _confirmDelete() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Income'),
        content: Text(
          'Are you sure you want to delete "${_originalIncome?.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteIncome();
    }
  }

  Future<void> _deleteIncome() async {
    setState(() => _isSubmitting = true);

    try {
      final success = await ref
          .read(recurringIncomeNotifierProvider.notifier)
          .deleteIncome(widget.incomeId);

      if (success && mounted) {
        ref.invalidate(dashboardDataProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recurring income deleted')),
            );
            Navigator.pop(context);
          }
        });
      } else if (mounted) {
        final incomeState = ref.read(recurringIncomeNotifierProvider);
        final errorMessage = incomeState.maybeWhen(
          error: (message, incomes, summary) => message ?? 'Failed to delete recurring income',
          orElse: () => 'Failed to delete recurring income',
        );

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

      final updatedIncome = _originalIncome!.copyWith(
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
        allowedAccountIds: _selectedAllowedAccountIds.isNotEmpty
            ? _selectedAllowedAccountIds
            : null,
        isVariableAmount: _isVariableAmount,
        minAmount: minAmount,
        maxAmount: maxAmount,
      );

      final success = await ref
          .read(recurringIncomeNotifierProvider.notifier)
          .updateIncome(updatedIncome);

      if (success && mounted) {
        ref.invalidate(dashboardDataProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recurring income updated successfully')),
            );
            Navigator.pop(context);
          }
        });
      } else if (mounted) {
        final incomeState = ref.read(recurringIncomeNotifierProvider);
        final errorMessage = incomeState.maybeWhen(
          error: (message, incomes, summary) => message ?? 'Failed to update recurring income',
          orElse: () => 'Failed to update recurring income',
        );

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