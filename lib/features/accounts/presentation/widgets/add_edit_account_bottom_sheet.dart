import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/modern/modern.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type_theme.dart';

/// Enhanced add/edit account bottom sheet with modern design
class AddEditAccountBottomSheet extends StatefulWidget {
  const AddEditAccountBottomSheet({
    super.key,
    this.account,
    required this.onSubmit,
  });

  final Account? account;
  final void Function(Account) onSubmit;

  @override
  State<AddEditAccountBottomSheet> createState() =>
      _AddEditAccountBottomSheetState();
}

class _AddEditAccountBottomSheetState
    extends State<AddEditAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  double _balance = 0.0;
  final _descriptionController = TextEditingController();
  final _institutionController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _minimumPaymentController = TextEditingController();

  AccountType _selectedType = AccountType.bankAccount;
  String? _selectedCurrency;
  bool _isActive = true;
  bool _isSubmitting = false;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY'];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      final account = widget.account!;
      _nameController.text = account.name;
      _balance = account.currentBalance;
      _descriptionController.text = account.description ?? '';
      _institutionController.text = account.institution ?? '';
      _accountNumberController.text = account.accountNumber ?? '';
      _selectedType = account.type;
      _selectedCurrency = account.currency ?? 'USD';
      _isActive = account.isActive;

      if (account.creditLimit != null) {
        _creditLimitController.text = account.creditLimit!.toStringAsFixed(2);
      }
      if (account.interestRate != null) {
        _interestRateController.text = account.interestRate!.toStringAsFixed(2);
      }
      if (account.minimumPayment != null) {
        _minimumPaymentController.text = account.minimumPayment!.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _institutionController.dispose();
    _accountNumberController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXxl),
        ),
        boxShadow: DesignTokens.elevationXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: DesignTokens.spacing2),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorTokens.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(DesignTokens.screenPaddingH),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorTokens.borderSecondary,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEditing ? 'Edit Account' : 'Add Account',
                        style: TypographyTokens.heading4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate()
                        .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                        .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
                      if (isEditing) ...[
                        SizedBox(height: DesignTokens.spacing1),
                        Text(
                          'Update ${widget.account!.name}',
                          style: TypographyTokens.bodyMd.copyWith(
                            color: ColorTokens.textSecondary,
                          ),
                        ).animate()
                          .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                          .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
                      ] else ...[
                        SizedBox(height: DesignTokens.spacing1),
                        Text(
                          'Create a new account to track',
                          style: TypographyTokens.bodyMd.copyWith(
                            color: ColorTokens.textSecondary,
                          ),
                        ).animate()
                          .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                          .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: DesignTokens.spacing2),
                Container(
                  decoration: BoxDecoration(
                    color: ColorTokens.surfaceSecondary,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, size: DesignTokens.iconMd),
                    onPressed: () => Navigator.pop(context),
                    color: ColorTokens.textSecondary,
                    tooltip: 'Close',
                  ),
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: DesignTokens.durationNormal, delay: 200.ms, curve: Curves.elasticOut),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DesignTokens.screenPaddingH),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section: Account Type
                    _buildSectionHeader(
                      'Account Type',
                      'Choose the type that best describes this account',
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal)
                      .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

                    SizedBox(height: FormTokens.groupGap),

                    _buildAccountTypeGrid().animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationNormal, delay: 100.ms),

                    SizedBox(height: FormTokens.sectionGap),

                    // Section: Basic Information
                    _buildSectionHeader(
                      'Basic Information',
                      'Essential details about your account',
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                      .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

                    SizedBox(height: FormTokens.groupGap),

                    // Account Name
                    ModernTextField(
                      controller: _nameController,
                      label: 'Account Name',
                      placeholder: 'e.g., Main Checking',
                      prefixIcon: Icons.account_balance_wallet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account name is required';
                        }
                        return null;
                      },
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                      .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

                    SizedBox(height: FormTokens.fieldGapMd),

                    // Balance
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance',
                            style: TypographyTokens.labelMd.copyWith(
                              color: ColorTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ModernAmountDisplay(
                            amount: _balance,
                            isEditable: true,
                            currencySymbol: _selectedCurrency ?? 'USD',
                            onAmountChanged: (value) {
                              setState(() {
                                _balance = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                      .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

                    SizedBox(height: FormTokens.fieldGapMd),

                    // Currency
                    ModernDropdownSelector<String>(
                      label: 'Currency',
                      selectedValue: _selectedCurrency ?? 'USD',
                      items: _currencies.map((currency) {
                        return ModernDropdownItem<String>(
                          value: currency,
                          label: currency,
                          icon: Icons.currency_exchange,
                          color: ColorTokens.teal500,
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCurrency = value;
                          });
                        }
                      },
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                      .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

                    SizedBox(height: FormTokens.sectionGap),

                    // Section: Optional Details
                    _buildSectionHeader(
                      'Optional Details',
                      'Additional information (can be added later)',
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
                      .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 600.ms),

                    SizedBox(height: FormTokens.groupGap),

                    // Institution
                    ModernTextField(
                      controller: _institutionController,
                      label: 'Institution (optional)',
                      placeholder: 'e.g., Bank of America',
                      prefixIcon: Icons.business,
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
                      .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 700.ms),

                    SizedBox(height: FormTokens.fieldGapMd),

                    // Account Number
                    ModernTextField(
                      controller: _accountNumberController,
                      label: 'Account Number (optional)',
                      placeholder: 'e.g., ****1234',
                      prefixIcon: Icons.numbers,
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
                      .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms),

                    SizedBox(height: FormTokens.fieldGapMd),

                    // Description
                    ModernTextField(
                      controller: _descriptionController,
                      label: 'Description (optional)',
                      placeholder: 'Additional notes about this account',
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
                      .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms),

                    // Type-specific fields
                    ..._buildTypeSpecificFields(),

                    SizedBox(height: FormTokens.sectionGap),

                    // Active Status
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: ColorTokens.teal500,
                            size: DesignTokens.iconMd,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account is Active',
                                  style: TypographyTokens.labelMd.copyWith(
                                    color: ColorTokens.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Inactive accounts are hidden from calculations',
                                  style: TypographyTokens.captionMd.copyWith(
                                    color: ColorTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                            activeThumbColor: ColorTokens.teal500,
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: DesignTokens.durationNormal, delay: 1000.ms)
                      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1000.ms),
                  ],
                ),
              ),
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.all(DesignTokens.screenPaddingH),
            decoration: BoxDecoration(
              color: ColorTokens.surfaceSecondary,
              border: Border(
                top: BorderSide(
                  color: ColorTokens.borderSecondary,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildCancelButton()),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(child: _buildSubmitButton(isEditing)),
              ],
            ),
          ),

          // Keyboard padding
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? DesignTokens.spacing2 : 0),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TypographyTokens.heading6.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: DesignTokens.spacing1),
        Text(
          subtitle,
          style: TypographyTokens.captionMd.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth < 360 ? 2 : 3;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: DesignTokens.spacing2,
          crossAxisSpacing: DesignTokens.spacing2,
          childAspectRatio: 1.1,
          children: AccountType.values.map((type) {
            final isSelected = _selectedType == type;
            // Use themed color - for now use default since we don't have settings access here
            final theme = AccountTypeTheme.defaultThemeFor(type.name);
            final typeColor = theme.color;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedType = type;
                  });
                },
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                child: AnimatedContainer(
                  duration: DesignTokens.durationSm,
                  curve: DesignTokens.curveEaseOut,
                  padding: EdgeInsets.all(DesignTokens.spacing3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? typeColor.withValues(alpha: 0.1)
                        : ColorTokens.surfaceSecondary,
                    border: Border.all(
                      color: isSelected
                          ? typeColor
                          : ColorTokens.borderSecondary,
                      width: isSelected ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    boxShadow: isSelected
                        ? DesignTokens.elevationGlow(
                            typeColor,
                            alpha: 0.2,
                            spread: 0,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(DesignTokens.spacing2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                        child: Icon(
                          theme.iconData,
                          color: typeColor,
                          size: DesignTokens.iconLg,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spacing2),
                      Flexible(
                        child: Text(
                          type.displayName,
                          style: TypographyTokens.labelSm.copyWith(
                            color: isSelected ? typeColor : ColorTokens.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ).animate(target: isSelected ? 1 : 0)
                  .scaleXY(
                    begin: 1.0,
                    end: 1.05,
                    duration: DesignTokens.durationSm,
                  ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  List<Widget> _buildTypeSpecificFields() {
    switch (_selectedType) {
      case AccountType.creditCard:
        return [
          SizedBox(height: FormTokens.sectionGap),
          _buildSectionHeader(
            'Credit Card Details',
            'Specific information for credit cards',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 1100.ms),
          SizedBox(height: FormTokens.groupGap),
          ModernTextField(
            controller: _creditLimitController,
            label: 'Credit Limit',
            placeholder: '5000.00',
            prefixIcon: Icons.credit_card,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final limit = double.tryParse(value);
                if (limit == null || limit <= 0) {
                  return 'Please enter a valid credit limit';
                }
                final balance = _balance;
                if (balance > limit) {
                  return 'Balance cannot exceed credit limit';
                }
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1200.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1200.ms),
          SizedBox(height: FormTokens.fieldGapMd),
          ModernTextField(
            controller: _minimumPaymentController,
            label: 'Minimum Payment (optional)',
            placeholder: '25.00',
            prefixIcon: Icons.payment,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1300.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1300.ms),
        ];

      case AccountType.loan:
        return [
          SizedBox(height: FormTokens.sectionGap),
          _buildSectionHeader(
            'Loan Details',
            'Specific information for loans',
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 1100.ms),
          SizedBox(height: FormTokens.groupGap),
          ModernTextField(
            controller: _interestRateController,
            label: 'Interest Rate (%)',
            placeholder: '5.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final rate = double.tryParse(value);
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Please enter a valid interest rate (0-100%)';
                }
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1200.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1200.ms),
          SizedBox(height: FormTokens.fieldGapMd),
          ModernTextField(
            controller: _minimumPaymentController,
            label: 'Monthly Payment (optional)',
            placeholder: '150.00',
            prefixIcon: Icons.payment,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 1300.ms)
            .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1300.ms),
        ];

      default:
        return [];
    }
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
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1400.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1400.ms);
  }

  Widget _buildSubmitButton(bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        boxShadow: _isSubmitting
            ? []
            : DesignTokens.elevationColored(ColorTokens.teal500, alpha: 0.3),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitAccount,
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
                isEditing ? 'Update Account' : 'Add Account',
                style: TypographyTokens.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1500.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1500.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 1500.ms);
  }


  Future<void> _submitAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final balance = _balance;
      final creditLimit = _creditLimitController.text.isNotEmpty
          ? double.tryParse(_creditLimitController.text)
          : null;
      final interestRate = _interestRateController.text.isNotEmpty
          ? double.tryParse(_interestRateController.text)
          : null;
      final minimumPayment = _minimumPaymentController.text.isNotEmpty
          ? double.tryParse(_minimumPaymentController.text)
          : null;

      final account = Account(
        id: widget.account?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: balance,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        institution: _institutionController.text.isNotEmpty
            ? _institutionController.text.trim()
            : null,
        accountNumber: _accountNumberController.text.isNotEmpty
            ? _accountNumberController.text.trim()
            : null,
        currency: _selectedCurrency ?? 'USD',
        createdAt: widget.account?.createdAt,
        updatedAt: DateTime.now(),
        creditLimit: creditLimit,
        interestRate: interestRate,
        minimumPayment: minimumPayment,
        isActive: _isActive,
      );

      widget.onSubmit(account);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${widget.account != null ? 'update' : 'create'} account: ${e.toString()}',
            ),
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