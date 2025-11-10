import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/notification_manager.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// Bottom sheet for adding new transactions
/// @deprecated Use EnhancedAddTransactionBottomSheet instead
class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({
    super.key,
    required this.onSubmit,
    this.initialType,
  });

  final Future<void> Function(Transaction) onSubmit;
  final TransactionType? initialType;

  @override
  ConsumerState<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends ConsumerState<AddTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId; // Will be set dynamically based on transaction type
  String? _selectedAccountId; // Will be set from real accounts

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    debugPrint('AddTransactionBottomSheet: Initialized with initialType: ${widget.initialType}, selectedType: $_selectedType');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(filteredAccountsProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);

    // Debug logging for responsiveness investigation
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    debugPrint('AddTransactionBottomSheet: Screen size: ${screenWidth}x$screenHeight');
    debugPrint('DEBUG: AddTransactionBottomSheet is building with selectedType: $_selectedType');

    final buttonChild = _isSubmitting
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          )
        : const Text('Add Transaction');

    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint('AddTransactionBottomSheet: Available width: ${constraints.maxWidth}, height: ${constraints.maxHeight}');
        return Container(
            padding: AppTheme.screenPaddingAll,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width, // Ensure it doesn't exceed screen width
            ),
            child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Header with animation
            Row(
              children: [
                Text(
                  'Add Transaction',
                  style: Theme.of(context).textTheme.headlineSmall,
                ).animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.2, duration: 300.ms, curve: Curves.easeOutCubic),
                const Spacer(),
                Semantics(
                  label: 'Close add transaction form',
                  button: true,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ).animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, delay: 100.ms, curve: Curves.elasticOut),
                ),
              ],
            ).animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.1, duration: 200.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 24),

            // Transaction Type Toggle with animation
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (selected) {
                  setState(() {
                    _selectedType = selected.first;
                    // Reset category when type changes so it gets the new default
                    _selectedCategoryId = null;
                  });
                },
              ).animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, duration: 400.ms, delay: 200.ms, curve: Curves.easeOutCubic),
            ),
            const SizedBox(height: 24),

            // Amount Field with animation
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
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
              autofocus: true,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: 0.1, duration: 400.ms, delay: 300.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),

            // Category Selection with animation
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth - (AppTheme.screenPaddingAll.horizontal * 2),
              ),
              child: categoriesAsync.when(
                data: (categoryState) {
                  final categories = categoryState.categories;
                  // Set default category if not set and categories exist
                  if (_selectedCategoryId == null && categories.isNotEmpty) {
                    final defaultCategoryId = _getSmartDefaultCategoryId(categories, _selectedType);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedCategoryId = defaultCategoryId;
                        });
                      }
                    });
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIconColorService.getIconForCategory(category.id), size: 20, color: categoryIconColorService.getColorForCategory(category.id)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                category.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideX(begin: 0.1, duration: 400.ms, delay: 400.ms, curve: Curves.easeOutCubic);
                },
                loading: () => const CircularProgressIndicator().animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut),
                error: (error, stack) => Text('Error loading categories: $error').animate()
                  .fadeIn(duration: 300.ms)
                  .shake(duration: 500.ms),
              ),
            ),
            const SizedBox(height: 16),

            // Account Selection with animation
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth - (AppTheme.screenPaddingAll.horizontal * 2),
              ),
              child: accountsAsync.when(
                data: (accounts) {
                  // Set default account if not set and accounts exist
                  if (_selectedAccountId == null && accounts.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedAccountId = accounts.first.id;
                        });
                      }
                    });
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an account';
                      }
                      return null;
                    },
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideX(begin: 0.1, duration: 400.ms, delay: 500.ms, curve: Curves.easeOutCubic);
                },
                loading: () => const CircularProgressIndicator().animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticInOut),
                error: (error, stack) => Text('Error loading accounts: $error').animate()
                  .fadeIn(duration: 300.ms)
                  .shake(duration: 500.ms),
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker with animation
            InkWell(
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
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ).animate()
              .fadeIn(duration: 400.ms, delay: 600.ms)
              .slideX(begin: 0.1, duration: 400.ms, delay: 600.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),

            // Description Field with animation
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g., Grocery shopping at Walmart',
              ),
              maxLength: 100,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 700.ms)
              .slideX(begin: 0.1, duration: 400.ms, delay: 700.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),

            // Receipt Scanning with animation
            OutlinedButton.icon(
              onPressed: _scanReceipt,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Receipt'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ).animate()
              .fadeIn(duration: 400.ms, delay: 800.ms)
              .slideY(begin: 0.1, duration: 400.ms, delay: 800.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),

            // Note Field with animation
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Additional details...',
              ),
              maxLength: 200,
              maxLines: 2,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 900.ms)
              .slideX(begin: 0.1, duration: 400.ms, delay: 900.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 32),

            // Action Buttons with animation
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 1000.ms)
                    .slideY(begin: 0.1, duration: 400.ms, delay: 1000.ms, curve: Curves.easeOutCubic),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () {
                      _submitTransaction();
                    },
                    child: buttonChild,
                  ).animate()
                    .fadeIn(duration: 400.ms, delay: 1100.ms)
                    .slideY(begin: 0.1, duration: 400.ms, delay: 1100.ms, curve: Curves.easeOutCubic)
                    .scale(begin: const Offset(0.95, 0.95), duration: 200.ms, delay: 1100.ms),
                ),
              ],
            ),
          ],
        ),
      ),
        ),
      ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  /// Get smart default category ID based on transaction type
  String _getSmartDefaultCategoryId(List<TransactionCategory> categories, TransactionType type) {
    final typeCategories = categories.where((cat) => cat.type == type).toList();

    if (typeCategories.isEmpty) {
      // Fallback to default categories if no user categories exist
      final defaultCategories = TransactionCategory.defaultCategories.where((cat) => cat.type == type).toList();
      return defaultCategories.isNotEmpty ? defaultCategories.first.id : 'other';
    }

    // Prefer commonly used categories
    final preferredIds = type == TransactionType.expense ? ['food', 'transport', 'shopping'] : ['salary', 'freelance'];
    for (final preferredId in preferredIds) {
      final preferredCategory = typeCategories.firstWhere(
        (cat) => cat.id == preferredId,
        orElse: () => typeCategories.first,
      );
      if (preferredCategory.id != typeCategories.first.id || preferredIds.contains(preferredCategory.id)) {
        return preferredCategory.id;
      }
    }

    // Return first category of the type
    return typeCategories.first.id;
  }

  Future<void> _scanReceipt() async {
    // Show receipt scanning dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Scanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Receipt scanning feature is coming soon!\n\nFor now, you can manually enter transaction details.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  Future<void> _submitTransaction() async {
    debugPrint('DEBUG: _submitTransaction called');
    if (!_formKey.currentState!.validate()) {
      debugPrint('DEBUG: Form validation failed');
      return;
    }

    // Additional validation for account selection
    if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
      debugPrint('DEBUG: No account selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    // Additional validation for category selection
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      debugPrint('DEBUG: No category selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    debugPrint('AddTransactionBottomSheet: _submitTransaction called, _isSubmitting: $_isSubmitting');
    if (_isSubmitting) {
      debugPrint('AddTransactionBottomSheet: Already submitting, ignoring duplicate call');
      return;
    }

    setState(() => _isSubmitting = true);
    debugPrint('AddTransactionBottomSheet: Set _isSubmitting to true');

    try {
      final amount = double.parse(_amountController.text);

      // Get account currency for the transaction
      final accountsAsync = ref.read(filteredAccountsProvider);
      String? accountCurrency;
      if (accountsAsync.hasValue) {
        try {
          final account = accountsAsync.value!.firstWhere(
            (acc) => acc.id == _selectedAccountId,
          );
          accountCurrency = account.currency ?? 'USD';
        } catch (e) {
          accountCurrency = 'USD'; // Fallback if account not found
        }
      }

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Transaction',
        amount: amount,
        type: _selectedType,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId,
        description: _noteController.text.isNotEmpty
            ? _noteController.text
            : null,
        currencyCode: accountCurrency,
      );

      debugPrint('AddTransactionBottomSheet: Created transaction - ID: ${transaction.id}, Title: ${transaction.title}, Amount: ${transaction.amount}, Type: ${transaction.type}, Category: ${transaction.categoryId}, Account: ${transaction.accountId}, Date: ${transaction.date}');
      debugPrint('AddTransactionBottomSheet: Calling onSubmit with transaction');
      await widget.onSubmit(transaction);
      debugPrint('AddTransactionBottomSheet: onSubmit completed - dismissing bottom sheet');

      // Safely dismiss the bottom sheet after successful submission
      // Use post-frame callback to ensure the widget tree is stable
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            // Check if we can safely pop (not the last page)
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              debugPrint('AddTransactionBottomSheet: Bottom sheet dismissed successfully');
            } else {
              debugPrint('AddTransactionBottomSheet: Cannot pop - would leave empty navigation stack');
            }
          } catch (e) {
            debugPrint('AddTransactionBottomSheet: Error during dismissal: $e');
            // If popping fails, the bottom sheet will remain open, which is safer than crashing
          }
        }
      });
    } catch (e) {
      debugPrint('AddTransactionBottomSheet: Error during transaction creation: $e');
      if (mounted) {
        NotificationManager.transactionAddFailed(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        debugPrint('AddTransactionBottomSheet: Reset _isSubmitting to false');
      }
    }
  }
}