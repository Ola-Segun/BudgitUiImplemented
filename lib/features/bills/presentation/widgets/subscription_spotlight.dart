import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_providers.dart';
import '../theme/bills_theme_extended.dart';

/// Widget that displays subscription spotlight information
class SubscriptionSpotlight extends ConsumerWidget {
  const SubscriptionSpotlight({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubscriptions = ref.watch(activeSubscriptionsProvider);
    final totalMonthly = ref.watch(totalMonthlySubscriptionsProvider);
    final unusedSubscriptions = ref.watch(unusedSubscriptionsProvider);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.subscriptions,
                  color: BillsThemeExtended.billStatsPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Subscription Spotlight',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BillsThemeExtended.billStatsPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary message
            Text(
              'You have ${activeSubscriptions.length} active subscriptions totaling \$${totalMonthly.toStringAsFixed(2)}/month',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Subscription list
            if (activeSubscriptions.isNotEmpty) ...[
              Text(
                'Your Subscriptions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...activeSubscriptions.map((subscription) => _buildSubscriptionItem(context, subscription)),
            ],

            // Review for savings section
            if (unusedSubscriptions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Review for Savings',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${unusedSubscriptions.length} subscription${unusedSubscriptions.length == 1 ? '' : 's'} may be unused. Consider reviewing them to save money.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionItem(BuildContext context, Subscription subscription) {
    final isUnused = subscription.isUnused;
    final daysSinceLastUsed = subscription.daysSinceLastUsed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnused ? Colors.red.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnused ? Colors.red.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Subscription icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnused ? Colors.red.withValues(alpha: 0.1) : BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.subscriptions,
              color: isUnused ? Colors.red : BillsThemeExtended.billStatsPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Subscription details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${subscription.amount.toStringAsFixed(2)}/${subscription.frequency.displayName.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (daysSinceLastUsed != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Last used: ${daysSinceLastUsed == 0 ? 'Today' : '$daysSinceLastUsed days ago'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUnused ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isUnused ? FontWeight.w500 : FontWeight.normal,
                        ),
                  ),
                ],
              ],
            ),
          ),

          // Unused indicator
          if (isUnused) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Unused',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

}