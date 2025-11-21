import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/notification_manager.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// Bottom sheet for adding new transactions
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
              .fadeIn(duration: DesignTokens.durationNormal)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal),

            SizedBox(height: spacing_lg),

            // Transaction Type Toggle with animation
            ModernToggleButton(
              options: const ['Expense', 'Income'],
              selectedIndex: _selectedType == TransactionType.expense ? 0 : 1,
              onChanged: (index) {
                setState(() {
                  _selectedType = index == 0 ? TransactionType.expense : TransactionType.income;
                  // Reset category when type changes so it gets the new default
                  _selectedCategoryId = null;
                });
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
            SizedBox(height: spacing_lg),

            // Amount Display (Amount-first design)
            ModernAmountDisplay(
              amount: _amountController.text.isEmpty
                ? 0
                : double.parse(_amountController.text),
              isEditable: true,
              onAmountChanged: (newAmount) {
                setState(() {
                  _amountController.text = newAmount.toStringAsFixed(0);
                });
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
            const SizedBox(height: 16),

            // Category Selection
            categoriesAsync.when(
              data: (categoryState) {
                final categories = categoryState.categories.where((cat) => cat.type == _selectedType).toList();
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

                final categoryItems = categories.map((cat) => CategoryItem(
                  id: cat.id,
                  name: cat.name,
                  icon: categoryIconColorService.getIconForCategory(cat.id),
                  color: categoryIconColorService.getColorForCategory(cat.id).value,
                )).toList();

                return ModernCategorySelector(
                  categories: categoryItems,
                  selectedId: _selectedCategoryId,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading categories: $error'),
            ),
            const SizedBox(height: 16),

            // Account Selection
            accountsAsync.when(
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

                return ModernDropdownSelector<String>(
                  label: 'Account',
                  selectedValue: _selectedAccountId,
                  items: accounts.map((account) => ModernDropdownItem<String>(
                    value: account.id,
                    label: '${account.displayName} - \$${(account.balance ?? 0).toStringAsFixed(2)}',
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAccountId = value);
                    }
                  },
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms);
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading accounts: $error'),
            ),
            const SizedBox(height: 16),

            // Date and Time Picker
            ModernDateTimePicker(
              selectedDate: _selectedDate,
              selectedTime: TimeOfDay.fromDateTime(_selectedDate),
              onDateChanged: (date) {
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              onTimeChanged: (time) {
                if (time != null) {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),
            SizedBox(height: spacing_md),

            // Title Field
            ModernTextField(
              controller: _descriptionController,
              placeholder: 'Title',
              prefixIcon: Icons.title,
              maxLength: 100,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),
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

            // Description Field
            ModernTextField(
              controller: _noteController,
              placeholder: 'Description (optional)',
              prefixIcon: Icons.description_outlined,
              maxLength: 200,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
              .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

            SizedBox(height: spacing_xl),

            // Scan Receipt and Confirm Buttons Row
            Row(
              children: [
                // Scan Receipt Button (30% - icon only)
                Expanded(
                  flex: 2,
                  child: IconButton(
                    onPressed: _scanReceipt,
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    tooltip: 'Scan Receipt',
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms),
                ),

                SizedBox(width: spacing_md),

                // Slide to Confirm (70%)
                Expanded(
                  flex: 7,
                  child: ModernSlideToConfirm(
                    text: 'Slide to Save',
                    onSlideComplete: _isSubmitting ? null : _handleSlideComplete,
                  ).animate()
                    .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
                    .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms),
                ),
              ],
            ),

            // Extra bottom padding to ensure button visibility
            SizedBox(height: spacing_xl),
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


  Future<bool> _handleSlideComplete() async {
    debugPrint('DEBUG: _handleSlideComplete called');
    if (!_formKey.currentState!.validate()) {
      debugPrint('DEBUG: Form validation failed');
      return false;
    }

    // Additional validation for account selection
    if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
      debugPrint('DEBUG: No account selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return false;
    }

    // Additional validation for category selection
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      debugPrint('DEBUG: No category selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return false;
    }

    debugPrint('AddTransactionBottomSheet: _handleSlideComplete called, _isSubmitting: $_isSubmitting');
    if (_isSubmitting) {
      debugPrint('AddTransactionBottomSheet: Already submitting, ignoring duplicate call');
      return false;
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
      return true;
    } catch (e) {
      debugPrint('AddTransactionBottomSheet: Error during transaction creation: $e');
      if (mounted) {
        NotificationManager.transactionAddFailed(context, e.toString());
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        debugPrint('AddTransactionBottomSheet: Reset _isSubmitting to false');
      }
    }
  }
}