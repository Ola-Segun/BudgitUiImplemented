import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/di/providers.dart' as core_providers;
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../../receipt_scanning/presentation/widgets/receipt_image_preview.dart';
import '../../domain/entities/bill.dart';
import '../../domain/usecases/validate_bill_account.dart';
import '../providers/bill_providers.dart';

/// Bottom sheet for recording bill payments
class PaymentRecordingBottomSheet extends ConsumerStatefulWidget {
  const PaymentRecordingBottomSheet({
    super.key,
    required this.bill,
    required this.onPaymentRecorded,
  });

  final Bill bill;
  final VoidCallback onPaymentRecorded;

  @override
  ConsumerState<PaymentRecordingBottomSheet> createState() =>
      _PaymentRecordingBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    required Bill bill,
    required VoidCallback onPaymentRecorded,
  }) {
    showModernBottomSheet(
      context: context,
      builder: (context) => ModernBottomSheet(
        child: PaymentRecordingBottomSheet(
          bill: bill,
          onPaymentRecorded: onPaymentRecorded,
        ),
      ),
    );
    return Future.value();
  }
}

class _PaymentRecordingBottomSheetState
    extends ConsumerState<PaymentRecordingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.other;
  String? _selectedAccountId;
  bool _isLoading = false;
  String? _balanceWarning;
  String? _attachedReceiptPath;

  @override
  void initState() {
    super.initState();
    // Pre-fill amount with bill amount
    _amountController.text = widget.bill.amount.toStringAsFixed(2);
    // Pre-select bill's default account if available
    _selectedAccountId = widget.bill.accountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _validateAccountBalance(List<Account> accounts) {
    if (_selectedAccountId == null) {
      setState(() => _balanceWarning = null);
      return;
    }

    final selectedAccount = accounts.firstWhere(
      (account) => account.id == _selectedAccountId,
      orElse: () => accounts.first,
    );

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      setState(() => _balanceWarning = null);
      return;
    }

    if (selectedAccount.availableBalance < amount) {
      final shortfall = amount - selectedAccount.availableBalance;
      setState(() => _balanceWarning =
          'Insufficient funds. This account is short by ${selectedAccount.currency} ${shortfall.toStringAsFixed(2)}.');
    } else {
      setState(() => _balanceWarning = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: spacing_lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Payment',
                  style: ModernTypography.titleLarge,
                ),
                const SizedBox(height: spacing_xs),
                Text(
                  'Record a payment for ${widget.bill.name}',
                  style: ModernTypography.bodyLarge.copyWith(
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Amount Display
          ModernAmountDisplay(
            amount: double.tryParse(_amountController.text) ?? widget.bill.amount,
            isEditable: true,
            onTap: () {
              // Focus on amount field when tapped
            },
            onAmountChanged: (value) {
              _amountController.text = value.toStringAsFixed(2);
            },
          ),

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
            const SizedBox(height: 16),

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
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No accounts available. Please create an account first.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final selectedAccount = accounts.firstWhere(
                      (account) => account.id == _selectedAccountId,
                      orElse: () => accounts.first,
                    );

                    // Validate balance when account or amount changes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _validateAccountBalance(accounts);
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedAccountId,
                          isExpanded: true, // CRITICAL: This fixes the overflow
                          decoration: const InputDecoration(
                            labelText: 'Payment Account',
                            border: OutlineInputBorder(),
                            helperText:
                                'Select the account to deduct payment from',
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            // Custom builder for the selected value display
                            return accounts.map((account) {
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
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                          items: accounts.map((account) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          account.displayName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          account.formattedAvailableBalance,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
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
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedAccountId = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an account';
                            }
                            return null;
                          },
                        ),
                        if (_balanceWarning != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _balanceWarning!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                  'After payment: ${selectedAccount.currency} ${(selectedAccount.availableBalance - (double.tryParse(_amountController.text) ?? 0)).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error loading accounts: $error',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Payment Date
            ModernDateTimePicker(
              selectedDate: _paymentDate,
              onDateChanged: (date) {
                if (date != null) {
                  setState(() {
                    _paymentDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: spacing_lg),

            // Payment Method - Keep existing dropdown for now
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
              ),
              items: PaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),
            const SizedBox(height: spacing_lg),

            // Attach Payment Confirmation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Confirmation',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_attachedReceiptPath != null) ...[
                    ReceiptImagePreview(imagePath: _attachedReceiptPath!),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _removeAttachment,
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _attachReceipt,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Change'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Attach a receipt or payment confirmation image',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _attachReceipt,
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Take Photo'),
                          ),
                        ),
                        const SizedBox(width: 8),
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
            ),
            const SizedBox(height: 16),

            // Notes (Optional)
            ModernTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              placeholder: 'Add any notes about this payment',
              maxLength: 500,
            ),
            const SizedBox(height: spacing_xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ModernActionButton(
                    text: 'Cancel',
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: spacing_md),
                Expanded(
                  child: ModernActionButton(
                    text: 'Record Payment',
                    onPressed: _isLoading ? null : _recordPayment,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  Future<void> _selectPaymentDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null) {
      setState(() => _paymentDate = pickedDate);
    }
  }

  Future<void> _attachReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _attachedReceiptPath = pickedFile.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _attachedReceiptPath = pickedFile.path);
    }
  }

  void _removeAttachment() {
    setState(() => _attachedReceiptPath = null);
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      // Validate account before proceeding with payment
      if (_selectedAccountId != null) {
        final accountRepository =
            ref.read(core_providers.accountRepositoryProvider);
        final validateAccount = ValidateBillAccount(accountRepository);
        final accountValidation =
            await validateAccount.callForPayment(_selectedAccountId!, amount);

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

      final payment = BillPayment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        paymentDate: _paymentDate,
        method: _paymentMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Store attached receipt path in payment notes if available
      final paymentWithReceipt = _attachedReceiptPath != null
          ? payment.copyWith(
              notes: '${payment.notes ?? ''}\n[Receipt: $_attachedReceiptPath]'.trim(),
            )
          : payment;

      final success = await ref
          .read(billNotifierProvider.notifier)
          .markBillAsPaid(widget.bill.id, paymentWithReceipt,
              accountId: _selectedAccountId);

      if (success && mounted) {
        widget.onPaymentRecorded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record payment'),
            backgroundColor: Colors.red,
          ),
        );
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
        setState(() => _isLoading = false);
      }
    }
  }
}
