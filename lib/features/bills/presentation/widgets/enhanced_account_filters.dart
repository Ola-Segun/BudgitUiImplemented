import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced account filters for bills with improved UI
class EnhancedAccountFilters extends ConsumerStatefulWidget {
  const EnhancedAccountFilters({
    super.key,
    required this.selectedAccountFilterId,
    required this.showLinkedOnly,
    required this.onAccountFilterChanged,
    required this.onLinkedOnlyChanged,
  });

  final String? selectedAccountFilterId;
  final bool showLinkedOnly;
  final ValueChanged<String?> onAccountFilterChanged;
  final ValueChanged<bool> onLinkedOnlyChanged;

  @override
  ConsumerState<EnhancedAccountFilters> createState() => _EnhancedAccountFiltersState();
}

class _EnhancedAccountFiltersState extends ConsumerState<EnhancedAccountFilters> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Filter by Account',
            style: BillsThemeExtended.billTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ).animate()
            .fadeIn(duration: BillsThemeExtended.billAnimationFast)
            .slideX(begin: -0.1, duration: BillsThemeExtended.billAnimationFast),

          SizedBox(height: AppDimensions.spacing3),

          // Filters
          Consumer(
            builder: (context, ref, child) {
              final accountsAsync = ref.watch(filteredAccountsProvider);
              return accountsAsync.when(
                data: (accounts) {
                  return Wrap(
                    spacing: AppDimensions.spacing2,
                    runSpacing: AppDimensions.spacing2,
                    children: [
                      // All bills filter
                      _FilterChip(
                        label: 'All Bills',
                        selected: widget.selectedAccountFilterId == null && !widget.showLinkedOnly,
                        onSelected: (selected) {
                          if (selected) {
                            HapticFeedback.lightImpact();
                            widget.onAccountFilterChanged(null);
                            widget.onLinkedOnlyChanged(false);
                          }
                        },
                      ).animate()
                        .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast)
                        .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationFast),

                      // Linked bills only filter
                      _FilterChip(
                        label: 'Linked Only',
                        selected: widget.showLinkedOnly,
                        onSelected: (selected) {
                          HapticFeedback.lightImpact();
                          widget.onLinkedOnlyChanged(selected);
                          if (!selected && widget.selectedAccountFilterId == null) {
                            // Stay on all bills if no specific account selected
                          }
                        },
                      ).animate()
                        .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal)
                        .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: BillsThemeExtended.billAnimationNormal),

                      // Individual account filters
                      ...accounts.map((account) {
                        return _AccountFilterChip(
                          account: account,
                          selected: widget.selectedAccountFilterId == account.id,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            widget.onAccountFilterChanged(selected ? account.id : null);
                            widget.onLinkedOnlyChanged(false); // Clear linked only when selecting specific account
                          },
                        ).animate()
                          .fadeIn(duration: BillsThemeExtended.billAnimationNormal, delay: Duration(milliseconds: 100 + accounts.indexOf(account) * 50))
                          .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal, delay: Duration(milliseconds: 100 + accounts.indexOf(account) * 50));
                      }),
                    ],
                  );
                },
                loading: () => SizedBox(
                  height: BillsThemeExtended.billMinTouchTarget,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BillsThemeExtended.billStatusOverdue.withValues(alpha: 0.1),
                    borderRadius: BillsThemeExtended.billChipRadius,
                  ),
                  child: Text(
                    'Error loading accounts: $error',
                    style: BillsThemeExtended.billStatusText.copyWith(
                      color: BillsThemeExtended.billStatusOverdue,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(minHeight: BillsThemeExtended.billMinTouchTarget),
          decoration: BoxDecoration(
            color: selected
                ? BillsThemeExtended.billFilterSelected
                : BillsThemeExtended.billFilterUnselected,
            borderRadius: BillsThemeExtended.billChipRadius,
            border: selected ? Border.all(
              color: BillsThemeExtended.billFilterSelected.withValues(alpha: 0.3),
              width: 1,
            ) : null,
          ),
          child: Text(
            label,
            style: BillsThemeExtended.billFilterText.copyWith(
              color: selected
                  ? BillsThemeExtended.billFilterTextSelected
                  : BillsThemeExtended.billFilterTextUnselected,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountFilterChip extends StatelessWidget {
  const _AccountFilterChip({
    required this.account,
    required this.selected,
    required this.onSelected,
  });

  final dynamic account; // Using dynamic to avoid import issues
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final accountColor = Color(account.type?.color ?? 0xFF6B7280);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BillsThemeExtended.billChipRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(minHeight: BillsThemeExtended.billMinTouchTarget),
          decoration: BoxDecoration(
            color: selected
                ? BillsThemeExtended.billFilterSelected
                : BillsThemeExtended.billFilterUnselected,
            borderRadius: BillsThemeExtended.billChipRadius,
            border: selected ? Border.all(
              color: BillsThemeExtended.billFilterSelected.withValues(alpha: 0.3),
              width: 1,
            ) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account type indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accountColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Account name
              Text(
                account.displayName ?? 'Unknown Account',
                style: BillsThemeExtended.billFilterText.copyWith(
                  color: selected
                      ? BillsThemeExtended.billFilterTextSelected
                      : BillsThemeExtended.billFilterTextUnselected,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}