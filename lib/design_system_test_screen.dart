import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/app_dimensions.dart';
import 'core/extensions/number_extensions.dart';
import 'core/extensions/date_extensions.dart';
import 'shared/presentation/widgets/common/gap.dart';
import 'shared/presentation/widgets/buttons/app_button.dart';
import 'shared/presentation/widgets/buttons/app_icon_button.dart';
import 'shared/presentation/widgets/cards/app_card.dart';
import 'shared/presentation/widgets/cards/balance_card.dart';
import 'shared/presentation/widgets/inputs/app_text_field.dart';
import 'shared/presentation/widgets/inputs/currency_input.dart';
import 'shared/presentation/widgets/states/empty_state.dart';
import 'shared/presentation/widgets/states/loading_skeleton.dart';
import 'shared/presentation/widgets/layout/section_header.dart';
import 'shared/presentation/widgets/layout/metric_display.dart';

class DesignSystemTestScreen extends StatelessWidget {
  const DesignSystemTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Test'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colors Test
            Text('Colors Test', style: AppTypography.h2),
            const Gap.md(),
            _buildColorRow('Primary', AppColors.primary),
            _buildColorRow('Secondary', AppColors.secondary),
            _buildColorRow('Success', AppColors.success),
            _buildColorRow('Error', AppColors.error),
            _buildColorRow('Warning', AppColors.warning),
            _buildColorRow('Info', AppColors.info),

            const Gap.xl(),

            // Typography Test
            Text('Typography Test', style: AppTypography.h2),
            const Gap.md(),
            Text('Hero Style', style: AppTypography.hero),
            Text('Display Style', style: AppTypography.display),
            Text('H1 Style', style: AppTypography.h1),
            Text('H2 Style', style: AppTypography.h2),
            Text('H3 Style', style: AppTypography.h3),
            Text('Body Style', style: AppTypography.body),
            Text('Body Medium Style', style: AppTypography.bodyMedium),
            Text('Body Small Style', style: AppTypography.bodySmall),
            Text('Caption Style', style: AppTypography.caption),
            Text('Overline Style', style: AppTypography.overline),

            const Gap.xl(),

            // Number Extensions Test
            Text('Number Extensions Test', style: AppTypography.h2),
            const Gap.md(),
            Text('Currency: ${1234.56.toCurrency()}', style: AppTypography.body),
            Text('Formatted: ${1234567.toFormatted()}', style: AppTypography.body),
            Text('Compact: ${1500000.toCompact()}', style: AppTypography.body),
            Text('Percentage: ${0.85.toPercentage()}', style: AppTypography.body),

            const Gap.xl(),

            // Date Extensions Test
            Text('Date Extensions Test', style: AppTypography.h2),
            const Gap.md(),
            Text('Display Date: ${DateTime.now().toDisplayDate()}', style: AppTypography.body),
            Text('Relative Date: ${DateTime.now().toRelativeDate()}', style: AppTypography.body),
            Text('Time Ago: ${DateTime.now().subtract(const Duration(hours: 2)).toTimeAgo()}', style: AppTypography.body),

            const Gap.xl(),

            // Dimensions Test
            Text('Dimensions Test', style: AppTypography.h2),
            const Gap.md(),
            Container(
              width: AppDimensions.categoryIconSize,
              height: AppDimensions.categoryIconSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.categoryIconRadius),
              ),
              child: const Icon(Icons.category, color: Colors.white),
            ),

            const Gap.xl(),

            // Gap Widget Test
            Text('Gap Widget Test', style: AppTypography.h2),
            const Gap.md(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item 1', style: AppTypography.body),
                  const Gap.sm(),
                  Text('Item 2', style: AppTypography.body),
                  const Gap.md(),
                  Text('Item 3', style: AppTypography.body),
                  const Gap.lg(),
                  Text('Item 4', style: AppTypography.body),
                ],
              ),
            ),

            const Gap.xl(),

            // Button Test
            Text('Button Test', style: AppTypography.h2),
            const Gap.md(),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Primary Button'),
            ),

            const Gap.xl(),

            // Card Test
            Text('Card Test', style: AppTypography.h2),
            const Gap.md(),
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.cardPadding),
                child: Text('This is a card component', style: AppTypography.body),
              ),
            ),

            const Gap.xl(),

            // AppButton Test
            SectionHeader(title: 'AppButton Components'),
            const Gap.md(),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AppButton(
                  text: 'Primary',
                  onPressed: () {},
                  variant: AppButtonVariant.primary,
                ),
                AppButton(
                  text: 'Secondary',
                  onPressed: () {},
                  variant: AppButtonVariant.secondary,
                ),
                AppButton(
                  text: 'Outline',
                  onPressed: () {},
                  variant: AppButtonVariant.outline,
                ),
                AppButton(
                  text: 'Ghost',
                  onPressed: () {},
                  variant: AppButtonVariant.ghost,
                ),
                AppButton(
                  text: 'Loading',
                  onPressed: () {},
                  isLoading: true,
                ),
                AppButton(
                  text: 'Disabled',
                  onPressed: null,
                ),
              ],
            ),

            const Gap.xl(),

            // AppIconButton Test
            SectionHeader(title: 'AppIconButton Components'),
            const Gap.md(),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AppIconButton(
                  icon: Icons.add,
                  onPressed: () {},
                  variant: AppIconButtonVariant.primary,
                ),
                AppIconButton(
                  icon: Icons.edit,
                  onPressed: () {},
                  variant: AppIconButtonVariant.secondary,
                ),
                AppIconButton(
                  icon: Icons.delete,
                  onPressed: () {},
                  variant: AppIconButtonVariant.outline,
                ),
                AppIconButton(
                  icon: Icons.more_vert,
                  onPressed: () {},
                  variant: AppIconButtonVariant.ghost,
                ),
              ],
            ),

            const Gap.xl(),

            // AppCard Test
            SectionHeader(title: 'AppCard Components'),
            const Gap.md(),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.cardPadding),
                      child: Text('Basic Card', style: AppTypography.body),
                    ),
                  ),
                ),
                const Gap.md(),
                Expanded(
                  child: AppCard(
                    elevation: AppCardElevation.medium,
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.cardPadding),
                      child: Text('Elevated Card', style: AppTypography.body),
                    ),
                  ),
                ),
              ],
            ),

            const Gap.xl(),

            // BalanceCard Test
            SectionHeader(title: 'BalanceCard Components'),
            const Gap.md(),
            BalanceCard(
              title: 'Total Balance',
              amount: '\$12,345.67',
              subtitle: 'Available funds',
              icon: Icons.account_balance_wallet,
            ),

            const Gap.xl(),

            // AppTextField Test
            SectionHeader(title: 'Input Components'),
            const Gap.md(),
            AppTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
            ),

            const Gap.md(),

            CurrencyInput(
              label: 'Amount',
              hint: 'Enter amount',
              initialValue: 1234.56,
            ),

            const Gap.xl(),

            // EmptyState Test
            SectionHeader(title: 'EmptyState Component'),
            const Gap.md(),
            SizedBox(
              height: 200,
              child: EmptyState(
                icon: Icons.inbox,
                title: 'No Transactions',
                message: 'You haven\'t made any transactions yet. Start by adding your first expense or income.',
                actionLabel: 'Add Transaction',
                onAction: () {},
              ),
            ),

            const Gap.xl(),

            // LoadingSkeleton Test
            SectionHeader(title: 'LoadingSkeleton Components'),
            const Gap.md(),
            Column(
              children: [
                SkeletonComponents.card(),
                const Gap.md(),
                SkeletonComponents.listItem(),
                const Gap.md(),
                SkeletonComponents.transactionCard(),
              ],
            ),

            const Gap.xl(),

            // MetricDisplay Test
            SectionHeader(title: 'MetricDisplay Components'),
            const Gap.md(),
            Row(
              children: [
                Expanded(
                  child: MetricDisplay(
                    value: '\$2,450',
                    label: 'This Month',
                    icon: Icons.trending_up,
                  ),
                ),
                const Gap.md(),
                Expanded(
                  child: MetricDisplay(
                    value: '24',
                    label: 'Transactions',
                    icon: Icons.receipt,
                  ),
                ),
              ],
            ),

            const Gap.xl(),

            // CompactMetricDisplay Test
            SectionHeader(title: 'Compact Metric Displays'),
            const Gap.md(),
            Row(
              children: [
                CompactMetricDisplay(
                  value: '\$1,250',
                  label: 'Income',
                  icon: Icons.arrow_upward,
                  valueColor: AppColors.success,
                ),
                const Gap.lg(),
                CompactMetricDisplay(
                  value: '\$890',
                  label: 'Expenses',
                  icon: Icons.arrow_downward,
                  valueColor: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Gap.md(),
          Text(label, style: AppTypography.body),
        ],
      ),
    );
  }
}