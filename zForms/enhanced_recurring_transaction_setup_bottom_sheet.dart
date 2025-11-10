import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/form_tokens.dart';
import '../../../../core/design_system/components/enhanced_text_field.dart';
import '../../../../core/design_system/components/enhanced_switch_field.dart';
import '../../domain/entities/recurring_transaction.dart';

/// Enhanced recurring transaction setup bottom sheet
/// Provides comprehensive recurrence configuration with live preview
class EnhancedRecurringTransactionSetupBottomSheet extends ConsumerStatefulWidget {
  const EnhancedRecurringTransactionSetupBottomSheet({super.key, 
    this.initialTransaction,
  });

  static Future<RecurringTransaction?> show({
    required BuildContext context,
    RecurringTransaction? initialTransaction,
  }) {
    return showModalBottomSheet<RecurringTransaction>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedRecurringTransactionSetupBottomSheet(
        initialTransaction: initialTransaction,
      ),
    );
  }

  final RecurringTransaction? initialTransaction;

  @override
  ConsumerState<EnhancedRecurringTransactionSetupBottomSheet> createState() =>
      _EnhancedRecurringTransactionSetupBottomSheetState();
}

class _EnhancedRecurringTransactionSetupBottomSheetState
    extends ConsumerState<EnhancedRecurringTransactionSetupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  RecurrenceType _selectedRecurrenceType = RecurrenceType.monthly;
  int _recurrenceValue = 1;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;
  bool _isSubmitting = false;

  // Live preview state
  DateTime? _nextDueDate;
  Timer? _previewUpdateTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _initializeFromTransaction(widget.initialTransaction!);
    }
    _updatePreview();
  }

  void _initializeFromTransaction(RecurringTransaction transaction) {
    _titleController.text = transaction.title;
    _amountController.text = transaction.amount.toStringAsFixed(2);
    _descriptionController.text = transaction.description ?? '';
    _selectedRecurrenceType = transaction.recurrenceType;
    _recurrenceValue = transaction.recurrenceValue;
    _startDate = transaction.startDate;
    _endDate = transaction.endDate;
    _hasEndDate = transaction.endDate != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _previewUpdateTimer?.cancel();
    super.dispose();
  }

  void _updatePreview() {
    _previewUpdateTimer?.cancel();
    _previewUpdateTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _nextDueDate = _calculateNextDueDate();
        });
      }
    });
  }

  DateTime? _calculateNextDueDate() {
    try {
      final transaction = RecurringTransaction(
        id: 'preview',
        title: _titleController.text.isNotEmpty ? _titleController.text : 'Preview',
        amount: double.tryParse(_amountController.text) ?? 0.0,
        recurrenceType: _selectedRecurrenceType,
        recurrenceValue: _recurrenceValue,
        startDate: _startDate,
        endDate: _hasEndDate ? _endDate : null,
        categoryId: 'preview',
        accountId: 'preview',
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        isActive: true,
        currencyCode: 'USD',
      );

      return transaction.calculateNextDueDate(DateTime.now());
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget should be shown as a dialog, not returned directly
    // The actual showing is handled by the caller
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information Section
              _buildSectionHeader(
                'Basic Information',
                'Transaction details and amount',
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal)
                .slideX(begin: -0.1, duration: DesignTokens.durationNormal),
    
              SizedBox(height: FormTokens.groupGap),
    
              // Title Field
              EnhancedTextField(
                controller: _titleController,
                label: 'Transaction Title',
                hint: 'e.g., Monthly Rent Payment',
                prefix: Icon(
                  Icons.title,
                  color: FormTokens.iconColor,
                  size: DesignTokens.iconMd,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a transaction title';
                  }
                  if (value.trim().length < 2) {
                    return 'Title must be at least 2 characters';
                  }
                  return null;
                },
                onChanged: (_) => _updatePreview(),
                autofocus: widget.initialTransaction == null,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
    
              SizedBox(height: FormTokens.fieldGapMd),
    
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
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
                onChanged: (_) => _updatePreview(),
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
    
              SizedBox(height: FormTokens.fieldGapMd),
    
              // Description Field
              EnhancedTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                hint: 'Additional details about this transaction',
                maxLines: 2,
                maxLength: 200,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),
    
              SizedBox(height: FormTokens.sectionGap),
    
              // Recurrence Configuration Section
              _buildSectionHeader(
                'Recurrence Pattern',
                'How often should this transaction repeat?',
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 400.ms),
    
              SizedBox(height: FormTokens.groupGap),
    
              // Recurrence Type Selection
              _buildRecurrenceTypeSelector().animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationNormal, delay: 500.ms),
    
              SizedBox(height: FormTokens.fieldGapMd),
    
              // Frequency Configuration
              _buildFrequencySelector().animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 600.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 600.ms),
    
              SizedBox(height: FormTokens.sectionGap),
    
              // Schedule Section
              _buildSectionHeader(
                'Schedule',
                'When should the recurrence start and end?',
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 700.ms)
                .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 700.ms),
    
              SizedBox(height: FormTokens.groupGap),
    
              // Start Date Picker
              _buildStartDatePicker().animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 800.ms)
                .slideX(begin: 0.1, duration: DesignTokens.durationNormal, delay: 800.ms),
    
              SizedBox(height: FormTokens.fieldGapMd),
    
              // End Date Toggle and Picker
              _buildEndDateSection().animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 900.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 900.ms),
    
              SizedBox(height: FormTokens.sectionGap),
    
              // Live Preview Section
              if (_nextDueDate != null) ...[
                _buildPreviewSection().animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 1000.ms)
                  .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationNormal, delay: 1000.ms),
                SizedBox(height: FormTokens.sectionGap),
              ],
    
              // Add buttons
              SizedBox(height: FormTokens.sectionGap),
              Row(
                children: [
                  Expanded(child: _buildCancelButton()),
                  SizedBox(width: DesignTokens.spacing3),
                  Expanded(child: _buildSubmitButton()),
                ],
              ),
            ],
          ),
        ),
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

  Widget _buildRecurrenceTypeSelector() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
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
          Text(
            'Recurrence Type',
            style: TypographyTokens.labelMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignTokens.spacing3),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: DesignTokens.spacing2,
            crossAxisSpacing: DesignTokens.spacing2,
            childAspectRatio: 2.5,
            children: RecurrenceType.values.map((type) {
              return _buildRecurrenceTypeCard(type);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurrenceTypeCard(RecurrenceType type) {
    final isSelected = _selectedRecurrenceType == type;
    final typeColor = _getRecurrenceTypeColor(type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedRecurrenceType = type;
            _updatePreview();
          });
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: AnimatedContainer(
          duration: DesignTokens.durationSm,
          curve: DesignTokens.curveEaseOut,
          padding: EdgeInsets.all(DesignTokens.spacing3),
          decoration: BoxDecoration(
            color: isSelected
                ? typeColor.withValues(alpha: 0.1)
                : ColorTokens.surfacePrimary,
            border: Border.all(
              color: isSelected
                  ? typeColor
                  : ColorTokens.borderSecondary,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            boxShadow: isSelected
                ? DesignTokens.elevationGlow(
                    typeColor,
                    alpha: 0.2,
                    spread: 0,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing1),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  _getRecurrenceTypeIcon(type),
                  size: DesignTokens.iconSm,
                  color: typeColor,
                ),
              ),
              SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: Text(
                  type.displayName,
                  style: TypographyTokens.labelSm.copyWith(
                    color: isSelected ? typeColor : ColorTokens.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildFrequencySelector() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
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
          Text(
            'Frequency',
            style: TypographyTokens.labelMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignTokens.spacing3),
          Row(
            children: [
              Text(
                'Every',
                style: TypographyTokens.bodyMd,
              ),
              SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing3,
                    vertical: DesignTokens.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.surfacePrimary,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(
                      color: ColorTokens.borderPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButton<int>(
                    value: _recurrenceValue,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: List.generate(30, (index) => index + 1)
                        .map((value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                value.toString(),
                                style: TypographyTokens.bodyMd,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _recurrenceValue = value;
                          _updatePreview();
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),
              Text(
                _getFrequencyUnitText(),
                style: TypographyTokens.bodyMd.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _startDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          );
          if (date != null) {
            setState(() {
              _startDate = date;
              _updatePreview();
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
                      'Start Date',
                      style: TypographyTokens.captionMd.copyWith(
                        color: FormTokens.labelColor,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacing05),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_startDate),
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

  Widget _buildEndDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedSwitchField(
          title: 'Set End Date',
          subtitle: 'Transaction will stop recurring after this date',
          value: _hasEndDate,
          onChanged: (value) {
            setState(() {
              _hasEndDate = value;
              if (!value) {
                _endDate = null;
              } else {
                _endDate ??= _startDate.add(const Duration(days: 365));
              }
              _updatePreview();
            });
          },
          icon: Icons.event_busy,
          iconColor: ColorTokens.warning500,
        ),
        if (_hasEndDate) ...[
          SizedBox(height: DesignTokens.spacing3),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
                  firstDate: _startDate.add(const Duration(days: 1)),
                  lastDate: _startDate.add(const Duration(days: 365 * 10)),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                    _updatePreview();
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
                      Icons.event_busy,
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
                            'End Date',
                            style: TypographyTokens.captionMd.copyWith(
                              color: FormTokens.labelColor,
                            ),
                          ),
                          SizedBox(height: DesignTokens.spacing05),
                          Text(
                            _endDate != null
                                ? DateFormat('EEEE, MMMM dd, yyyy').format(_endDate!)
                                : 'Select end date',
                            style: TypographyTokens.labelMd.copyWith(
                              color: _endDate != null
                                  ? ColorTokens.textPrimary
                                  : ColorTokens.textTertiary,
                            ),
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
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewSection() {
    final recurrenceDescription = _getRecurrenceDescription();
    final nextDueText = _nextDueDate != null
        ? DateFormat('MMM dd, yyyy').format(_nextDueDate!)
        : 'Calculating...';

    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorTokens.teal500.withValues(alpha: 0.05),
            ColorTokens.purple600.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        border: Border.all(
          color: ColorTokens.teal500.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing1),
                decoration: BoxDecoration(
                  color: ColorTokens.teal500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  Icons.preview,
                  size: DesignTokens.iconMd,
                  color: ColorTokens.teal500,
                ),
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                'Preview',
                style: TypographyTokens.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorTokens.teal500,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacing3),
          Text(
            'Pattern: $recurrenceDescription',
            style: TypographyTokens.bodyMd,
          ),
          SizedBox(height: DesignTokens.spacing1),
          Text(
            'Next due: $nextDueText',
            style: TypographyTokens.bodyMd.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
          if (_hasEndDate && _endDate != null) ...[
            SizedBox(height: DesignTokens.spacing1),
            Text(
              'Ends: ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
              style: TypographyTokens.captionMd.copyWith(
                color: ColorTokens.warning500,
              ),
            ),
          ],
        ],
      ),
    );
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
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1100.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1100.ms);
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: ColorTokens.gradientPrimary,
        borderRadius: BorderRadius.circular(FormTokens.fieldRadiusMd),
        boxShadow: _isSubmitting
            ? []
            : DesignTokens.elevationColored(ColorTokens.teal500, alpha: 0.3),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRecurringTransaction,
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
                widget.initialTransaction != null
                    ? 'Update Recurring Transaction'
                    : 'Create Recurring Transaction',
                style: TypographyTokens.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 1200.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 1200.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: DesignTokens.durationSm, delay: 1200.ms);
  }

  // Helper methods
  Color _getRecurrenceTypeColor(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return ColorTokens.info500;
      case RecurrenceType.weekly:
        return ColorTokens.success500;
      case RecurrenceType.monthly:
        return ColorTokens.teal500;
      case RecurrenceType.yearly:
        return ColorTokens.purple600;
    }
  }

  IconData _getRecurrenceTypeIcon(RecurrenceType type) {
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

  String _getFrequencyUnitText() {
    switch (_selectedRecurrenceType) {
      case RecurrenceType.daily:
        return _recurrenceValue == 1 ? 'day' : 'days';
      case RecurrenceType.weekly:
        return _recurrenceValue == 1 ? 'week' : 'weeks';
      case RecurrenceType.monthly:
        return _recurrenceValue == 1 ? 'month' : 'months';
      case RecurrenceType.yearly:
        return _recurrenceValue == 1 ? 'year' : 'years';
    }
  }

  String _getRecurrenceDescription() {
    final value = _recurrenceValue;
    final unit = _getFrequencyUnitText();

    if (value == 1) {
      return 'Every $unit';
    } else {
      return 'Every $value $unit';
    }
  }

  Future<void> _submitRecurringTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasEndDate && _endDate != null && _endDate!.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: ColorTokens.critical500,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);

      final transaction = RecurringTransaction(
        id: widget.initialTransaction?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        recurrenceType: _selectedRecurrenceType,
        recurrenceValue: _recurrenceValue,
        startDate: _startDate,
        endDate: _hasEndDate ? _endDate : null,
        categoryId: 'placeholder', // This would be set from actual category selection
        accountId: 'placeholder', // This would be set from actual account selection
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        isActive: true,
        currencyCode: 'USD',
        tags: [],
      );

      Navigator.pop(context, transaction);
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