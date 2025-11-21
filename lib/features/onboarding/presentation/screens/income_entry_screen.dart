import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/design_system/modern/modern.dart';
import '../../domain/entities/income_source.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/add_income_source_bottom_sheet.dart';

class IncomeEntryScreen extends ConsumerStatefulWidget {
  const IncomeEntryScreen({super.key});

  @override
  ConsumerState<IncomeEntryScreen> createState() => _IncomeEntryScreenState();
}

class _IncomeEntryScreenState extends ConsumerState<IncomeEntryScreen> {

  void _removeIncomeSource(String id) {
    ref.read(onboardingNotifierProvider.notifier).removeIncomeSource(id);
  }

  void _handleContinue() {
    final onboardingData = ref.read(onboardingDataProvider);
    if (onboardingData.incomeSources.isNotEmpty) {
      ref.read(onboardingNotifierProvider.notifier).confirmIncome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(onboardingProgressProvider);
    final onboardingData = ref.watch(onboardingDataProvider);
    final totalMonthlyIncome = onboardingData.totalMonthlyIncome;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(spacing_lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: ModernColors.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(ModernColors.accentGreen),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: spacing_xl),

                  // Header
                  Text(
                    'Tell us about your income',
                    style: ModernTypography.titleLarge.copyWith(
                      color: ModernColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().slideY(begin: 0.3, duration: 400.ms).fadeIn(),

                  Gap(spacing_md),

                  Text(
                    'Add all your income sources to help us create the perfect budget for you.',
                    style: ModernTypography.bodyLarge.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ).animate().slideY(begin: 0.2, duration: 500.ms).fadeIn(),

                  Gap(spacing_lg),

                  // Total monthly income display
                  if (totalMonthlyIncome > 0)
                    Container(
                      padding: const EdgeInsets.all(spacing_md),
                      decoration: BoxDecoration(
                        color: ModernColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(radius_md),
                        border: Border.all(color: ModernColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: ModernColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: spacing_sm),
                          Text(
                            'Monthly Income: \$${totalMonthlyIncome.toStringAsFixed(2)}',
                            style: ModernTypography.bodyLarge.copyWith(
                              color: ModernColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.1, duration: 600.ms).fadeIn(),

                  Gap(spacing_lg),

                  // Existing income sources
                  if (onboardingData.incomeSources.isNotEmpty) ...[
                    Text(
                      'Your Income Sources',
                      style: ModernTypography.bodyLarge.copyWith(
                        color: ModernColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 700.ms),

                    Gap(spacing_md),

                    ...onboardingData.incomeSources.map((source) => Padding(
                          padding: const EdgeInsets.only(bottom: spacing_sm),
                          child: IncomeSourceCard(
                            source: source,
                            onRemove: () => _removeIncomeSource(source.id),
                          ),
                        ).animate().slideX(begin: 0.1, duration: 800.ms).fadeIn()),
                  ],

                  Gap(spacing_lg),

                  // Add new income button
                  Text(
                    'Add Income Source',
                    style: ModernTypography.bodyLarge.copyWith(
                      color: ModernColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 900.ms),

                  Gap(spacing_md),

                  ModernActionButton(
                    text: 'Add Income Source',
                    onPressed: () => AddIncomeSourceBottomSheet.show(context),
                    isPrimary: false,
                  ).animate().slideY(begin: 0.1, duration: 1000.ms).fadeIn(),

                  // Add bottom padding to ensure content doesn't get cut off
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(spacing_lg),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Continue button
                ModernActionButton(
                  text: 'Continue to Budget Setup',
                  onPressed: onboardingData.incomeSources.isNotEmpty ? _handleContinue : null,
                  isPrimary: true,
                ).animate().slideY(begin: 0.2, duration: 1300.ms).fadeIn(),

                Gap(spacing_md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IncomeSourceCard extends StatelessWidget {
  const IncomeSourceCard({
    super.key,
    required this.source,
    required this.onRemove,
  });

  final IncomeSource source;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius_md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(spacing_md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.name,
                    style: ModernTypography.labelMedium.copyWith(
                      color: ModernColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: spacing_xs),
                  Text(
                    '\$${source.amount.toStringAsFixed(2)} ${source.frequency.displayName.toLowerCase()}',
                    style: ModernTypography.bodyLarge.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Monthly: \$${source.monthlyAmount.toStringAsFixed(2)}',
                    style: ModernTypography.labelSmall.copyWith(
                      color: ModernColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.delete_outline,
                color: ModernColors.error,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}