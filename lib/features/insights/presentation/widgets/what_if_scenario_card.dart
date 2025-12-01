import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../settings/presentation/widgets/formatting_widgets.dart';
import '../../../settings/presentation/widgets/privacy_mode_text.dart';

/// Card widget for What-If scenario analysis
class WhatIfScenarioCard extends ConsumerStatefulWidget {
  const WhatIfScenarioCard({super.key});

  @override
  ConsumerState<WhatIfScenarioCard> createState() => _WhatIfScenarioCardState();
}

class _WhatIfScenarioCardState extends ConsumerState<WhatIfScenarioCard> {
  ScenarioType _selectedScenario = ScenarioType.incomeIncrease;
  double _changeAmount = 500.0;
  int _timeframeMonths = 12;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconXxl,
                  height: AppSpacing.iconXxl,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.explore,
                    color: AppColors.primary,
                    size: AppSpacing.iconLg,
                  ),
                ),
                Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What-If Scenarios',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        'Explore how changes affect your finances',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(AppSpacing.lg),

            // Scenario selector
            Text(
              'Scenario',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Gap(AppSpacing.sm),
            DropdownButtonFormField<ScenarioType>(
              initialValue: _selectedScenario,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ScenarioType.values.map((scenario) {
                return DropdownMenuItem(
                  value: scenario,
                  child: Text(scenario.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedScenario = value);
                }
              },
            ),
            Gap(AppSpacing.md),

            // Change amount input
            Text(
              _selectedScenario.amountLabel,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Gap(AppSpacing.sm),
            TextFormField(
              initialValue: _changeAmount.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefix: SettingsCurrencyText(
                  amount: 0,
                  style: AppTypography.bodyMedium,
                  currencyCode: 'USD',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final amount = double.tryParse(value);
                if (amount != null) {
                  setState(() => _changeAmount = amount);
                }
              },
            ),
            Gap(AppSpacing.md),

            // Timeframe selector
            Text(
              'Timeframe',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Gap(AppSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: _timeframeMonths,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [3, 6, 12, 24, 36].map((months) {
                return DropdownMenuItem(
                  value: months,
                  child: Text('$months months'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _timeframeMonths = value);
                }
              },
            ),
            Gap(AppSpacing.lg),

            // Calculate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateScenario,
                style: ElevatedButton.styleFrom(
                  padding: AppSpacing.buttonPaddingAll,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text(
                  'Calculate Impact',
                  style: AppTypography.buttonLarge,
                ),
              ),
            ),
            Gap(AppSpacing.md),

            // Results section (shown after calculation)
            if (_scenarioResult != null) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  ScenarioResult? _scenarioResult;

  void _calculateScenario() {
    // TODO: Replace with actual calculation logic
    setState(() {
      _scenarioResult = _calculateMockResult();
    });
  }

  ScenarioResult _calculateMockResult() {
    // Mock calculation - replace with real logic
    final monthlyImpact = _selectedScenario.isPositive ? _changeAmount : -_changeAmount;
    final totalImpact = monthlyImpact * _timeframeMonths;

    return ScenarioResult(
      monthlyImpact: monthlyImpact,
      totalImpact: totalImpact,
      projectedSavings: totalImpact * 0.7, // Assume 70% goes to savings
      breakEvenMonths: _selectedScenario.isPositive ? 0 : (_changeAmount / 100).round(), // Mock break-even
    );
  }

  Widget _buildResultsSection() {
    if (_scenarioResult == null) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.cardPaddingAll,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projected Impact',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(AppSpacing.md),
          _buildResultRow('Monthly Impact', _scenarioResult!.monthlyImpact),
          _buildResultRow('Total Impact', _scenarioResult!.totalImpact),
          _buildResultRow('Projected Savings', _scenarioResult!.projectedSavings),
          if (_scenarioResult!.breakEvenMonths > 0)
            _buildTextResultRow('Break-even Period', '${_scenarioResult!.breakEvenMonths} months'),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          PrivacyModeAmount(
            amount: value,
            currency: '\$',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scenario types for what-if analysis
enum ScenarioType {
  incomeIncrease('Increase Monthly Income', 'Additional Income', true),
  expenseReduction('Reduce Monthly Expenses', 'Expense Reduction', true),
  priceIncrease('Price Increase (Inflation)', 'Price Increase', false),
  emergencyFund('Build Emergency Fund', 'Monthly Contribution', true),
  debtPayoff('Accelerate Debt Payoff', 'Extra Payment', true);

  const ScenarioType(this.displayName, this.amountLabel, this.isPositive);

  final String displayName;
  final String amountLabel;
  final bool isPositive;
}

/// Result of scenario calculation
class ScenarioResult {
  const ScenarioResult({
    required this.monthlyImpact,
    required this.totalImpact,
    required this.projectedSavings,
    required this.breakEvenMonths,
  });

  final double monthlyImpact;
  final double totalImpact;
  final double projectedSavings;
  final int breakEvenMonths;
}