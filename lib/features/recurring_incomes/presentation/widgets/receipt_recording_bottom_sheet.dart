import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/design_system/components/enhanced_bottom_sheet.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../receipt_scanning/domain/entities/receipt_data.dart';
import '../../domain/entities/recurring_income.dart';
import '../providers/recurring_income_providers.dart';

/// Bottom sheet for recording income receipts
class ReceiptRecordingBottomSheet extends ConsumerStatefulWidget {
  const ReceiptRecordingBottomSheet({
    super.key,
    required this.incomeId,
    required this.onReceiptRecorded,
  });

  final String incomeId;
  final VoidCallback onReceiptRecorded;

  @override
  ConsumerState<ReceiptRecordingBottomSheet> createState() =>
      _ReceiptRecordingBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    required String incomeId,
    required VoidCallback onReceiptRecorded,
  }) {
    EnhancedBottomSheet.showForm(
      context: context,
      title: 'Record Receipt',
      subtitle: 'Record a payment receipt for your income',
      child: ReceiptRecordingBottomSheet(
        incomeId: incomeId,
        onReceiptRecorded: onReceiptRecorded,
      ),
      actions: [], // Actions will be handled inside the widget
    );
    return Future.value();
  }
}

class _ReceiptRecordingBottomSheetState
    extends ConsumerState<ReceiptRecordingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  RecurringIncome? _income;
  Account? _selectedAccount;
  DateTime _receiptDate = DateTime.now();
  bool _isLoading = true;
  bool _isRecording = false;
  String? _attachedReceiptPath;

  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadIncome() async {
    final incomeState = ref.read(recurringIncomeNotifierProvider);
    final incomes = incomeState.maybeWhen(
      loaded: (incomes, summary) => incomes,
      orElse: () => <RecurringIncome>[],
    );

    final income = incomes.firstWhere(
      (inc) => inc.id == widget.incomeId,
      orElse: () => throw Exception('Income not found'),
    );

    if (mounted) {
      setState(() {
        _income = income;
        _amountController.text = income.amount.toStringAsFixed(2);
        _selectedAccount = _getDefaultAccount(income);
        _isLoading = false;
      });
    }
  }

  Account? _getDefaultAccount(RecurringIncome income) {
    final accountsAsync = ref.read(filteredAccountsProvider);
    return accountsAsync.maybeWhen(
      data: (accounts) {
        // Try to find the default account first
        if (income.defaultAccountId != null) {
          return accounts.firstWhere(
            (account) => account.id == income.defaultAccountId,
            orElse: () => accounts.firstWhere(
              (account) => income.allowedAccountIds?.contains(account.id) ?? false,
              orElse: () => accounts.first,
            ),
          );
        }
        // Fall back to first allowed account or any account
        return accounts.firstWhere(
          (account) => income.allowedAccountIds?.contains(account.id) ?? false,
          orElse: () => accounts.first,
        );
      },
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_income == null) {
      return const Center(
        child: Text('Income not found'),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income Summary Card
          _buildIncomeSummary(),

          const SizedBox(height: spacing_lg),

          // Amount Display
          ModernAmountDisplay(
            amount: double.tryParse(_amountController.text) ?? _income!.amount,
            isEditable: true,
            onTap: () {
              // Focus on amount field when tapped
            },
            onAmountChanged: (value) {
              _amountController.text = value.toStringAsFixed(2);
            },
          ).animate()
            .fadeIn(duration: ModernAnimations.normal)
            .slideX(begin: 0.1, duration: ModernAnimations.normal),

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

          // Account Selection
          Consumer(
            builder: (context, ref, child) {
              final accountsAsync = ref.watch(filteredAccountsProvider);

              return accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ModernColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(radius_md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: ModernColors.error,
                          ),
                          const SizedBox(width: spacing_sm),
                          Expanded(
                            child: Text(
                              'No accounts available. Please create an account first.',
                              style: ModernTypography.bodyLarge.copyWith(
                                color: ModernColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 200.ms)
                      .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 200.ms);
                  }

                  final selectedAccount = accounts.firstWhere(
                    (account) => account.id == _selectedAccount?.id,
                    orElse: () => accounts.first,
                  );

                  // Use selectedAccount if needed

                  return ModernDropdownSelector<String>(
                    label: 'Deposit Account',
                    placeholder: 'Select account',
                    selectedValue: _selectedAccount?.id,
                    items: accounts.map((account) {
                      return ModernDropdownItem<String>(
                        value: account.id,
                        label: '${account.displayName} • ${account.formattedAvailableBalance}',
                        icon: Icons.account_balance_wallet,
                        color: Color(account.type.color),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = accounts.firstWhere(
                          (account) => account.id == value,
                        );
                      });
                    },
                  ).animate()
                    .fadeIn(duration: ModernAnimations.normal, delay: 300.ms)
                    .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 300.ms);
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()).animate()
                      .fadeIn(duration: ModernAnimations.normal, delay: 200.ms),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(radius_md),
                  ),
                  child: Text(
                    'Error loading accounts: $error',
                    style: ModernTypography.bodyLarge.copyWith(
                      color: ModernColors.error,
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: ModernAnimations.normal, delay: 200.ms)
                  .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 200.ms),
              );
            },
          ),

          const SizedBox(height: spacing_lg),

          // Receipt Date
          ModernDateTimePicker(
            selectedDate: _receiptDate,
            onDateChanged: (date) {
              if (date != null) {
                setState(() {
                  _receiptDate = date;
                });
              }
            },
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 400.ms)
            .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 400.ms),

          const SizedBox(height: spacing_lg),

          // Attach Receipt
          Container(
            padding: const EdgeInsets.all(spacing_lg),
            decoration: BoxDecoration(
              color: ModernColors.primaryGray,
              borderRadius: BorderRadius.circular(radius_md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      color: ModernColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: spacing_sm),
                    Text(
                      'Receipt Attachment',
                      style: ModernTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: spacing_sm),
                if (_attachedReceiptPath != null) ...[
                  Container(
                    padding: const EdgeInsets.all(spacing_sm),
                    decoration: BoxDecoration(
                      color: ModernColors.lightBackground,
                      borderRadius: BorderRadius.circular(radius_sm),
                      border: Border.all(color: ModernColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt,
                          color: ModernColors.accentGreen,
                          size: 20,
                        ),
                        const SizedBox(width: spacing_sm),
                        Expanded(
                          child: Text(
                            'Receipt attached',
                            style: ModernTypography.bodyLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _removeAttachment,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacing_sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _scanReceipt,
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Rescan'),
                        ),
                      ),
                      const SizedBox(width: spacing_sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Change'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Attach a receipt image for this payment',
                    style: ModernTypography.bodyLarge.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: spacing_md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _scanReceipt,
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Scan Receipt'),
                        ),
                      ),
                      const SizedBox(width: spacing_sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('From Gallery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 500.ms)
            .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 500.ms),

          const SizedBox(height: spacing_lg),

          // Notes (Optional)
          ModernTextField(
            controller: _notesController,
            label: 'Notes (Optional)',
            placeholder: 'Add any notes about this receipt',
            maxLength: 500,
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 600.ms)
            .slideX(begin: 0.1, duration: ModernAnimations.normal, delay: 600.ms),

          const SizedBox(height: spacing_xl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ModernActionButton(
                  text: 'Cancel',
                  onPressed: _isRecording ? null : () => Navigator.pop(context),
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: spacing_md),
              Expanded(
                child: ModernActionButton(
                  text: 'Record Receipt',
                  onPressed: _isRecording ? null : _recordReceipt,
                  isLoading: _isRecording,
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: ModernAnimations.normal, delay: 700.ms)
            .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 700.ms),
        ],
      ),
    );
  }

  Widget _buildIncomeSummary() {
    final income = _income!;

    return Container(
      padding: const EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.primaryGray,
        borderRadius: BorderRadius.circular(radius_md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: ModernColors.accentGreen,
                size: 20,
              ),
              const SizedBox(width: spacing_sm),
              Text(
                'Income Details',
                style: ModernTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: spacing_md),
          _buildSummaryRow('Name', income.name),
          _buildSummaryRow('Expected Amount', '\$${income.amount.toStringAsFixed(2)}'),
          _buildSummaryRow('Frequency', income.frequency.displayName),
          if (income.nextExpectedDate != null)
            _buildSummaryRow(
              'Next Expected',
              DateFormat('MMM dd, yyyy').format(income.nextExpectedDate!),
            ),
        ],
      ),
    ).animate()
      .fadeIn(duration: ModernAnimations.normal, delay: 100.ms)
      .slideY(begin: 0.1, duration: ModernAnimations.normal, delay: 100.ms);
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spacing_xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: ModernTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ModernTypography.bodyLarge.copyWith(
                color: ModernColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanReceipt() async {
    // Navigate to receipt scanning screen and wait for result
    final result = await context.push('/scan-receipt');

    if (result != null && result is ReceiptData) {
      // Update amount from scanned receipt data
      _amountController.text = result.amount.toStringAsFixed(2);

      // Update date from scanned receipt data
      setState(() {
        _receiptDate = result.date;
      });

      // Update notes with merchant name as description
      _notesController.text = result.merchant;

      // Set attached receipt path if available
      if (result.imagePath != null) {
        setState(() {
          _attachedReceiptPath = result.imagePath;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt data applied successfully')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    // TODO: Implement gallery picker
    // For now, just show a placeholder
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery picker not yet implemented')),
      );
    }
  }

  void _removeAttachment() {
    setState(() => _attachedReceiptPath = null);
  }

  Future<void> _recordReceipt() async {
    if (!_formKey.currentState!.validate()) return;

    if (_income == null || _selectedAccount == null) {
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      // Create income instance
      final instance = RecurringIncomeInstance(
        id: 'receipt_${_income!.id}_${DateTime.now().millisecondsSinceEpoch}',
        amount: double.parse(_amountController.text),
        receivedDate: _receiptDate,
        transactionId: null, // Will be set by the repository
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        accountId: _selectedAccount!.id,
      );

      // Record the receipt
      final success = await ref
          .read(recurringIncomeNotifierProvider.notifier)
          .recordIncomeReceipt(_income!.id, instance, accountId: _selectedAccount!.id);

      if (success && mounted) {
        widget.onReceiptRecorded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Income receipt recorded successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to record income receipt')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }
}