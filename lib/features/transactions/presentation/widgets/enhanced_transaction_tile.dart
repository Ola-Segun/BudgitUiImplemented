import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/cards/app_card.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../../../../core/widgets/notification_manager.dart';
import 'transaction_detail_bottom_sheet.dart';

/// Enhanced Transaction Tile with swipe actions and animations
class EnhancedTransactionTile extends ConsumerStatefulWidget {
  const EnhancedTransactionTile({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  ConsumerState<EnhancedTransactionTile> createState() => _EnhancedTransactionTileState();
}

class _EnhancedTransactionTileState extends ConsumerState<EnhancedTransactionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Get category data using centralized service
    final categoryIconColorService = ref.watch(categoryIconColorServiceProvider);
    final categories = ref.watch(transactionCategoriesProvider);
    final category = categories.where((c) => c.id == widget.transaction.categoryId).firstOrNull;
    final categoryIcon = categoryIconColorService.getIconForCategory(widget.transaction.categoryId);
    final categoryColor = categoryIconColorService.getColorForCategory(widget.transaction.categoryId);
    final categoryName = category != null ? category.name : 'Unknown Category';

    return Slidable(
      key: ValueKey(widget.transaction.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // Delete action (red)
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, ref),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            autoClose: true,
            padding: EdgeInsets.zero,
            spacing: 0,
          ),
          // Duplicate action (blue)
          SlidableAction(
            onPressed: (_) => _duplicateTransaction(context, ref),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.copy,
            label: 'Duplicate',
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            autoClose: true,
            padding: EdgeInsets.zero,
            spacing: 0,
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // Edit action (blue)
          SlidableAction(
            onPressed: (_) => _showEditSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            autoClose: true,
            padding: EdgeInsets.zero,
            spacing: 0,
          ),
          // Share action (green)
          SlidableAction(
            onPressed: (_) => _shareTransaction(context),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            autoClose: true,
            padding: EdgeInsets.zero,
            spacing: 0,
          ),
        ],
      ),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: AppCard(
              elevation: _isPressed ? AppCardElevation.low : AppCardElevation.medium,
              padding: EdgeInsets.all(AppDimensions.cardPadding),
              onTap: () {
                HapticFeedback.selectionClick();
                _showDetailSheet(context);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Icon with entrance animation
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 20,
                    ),
                  ).animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, delay: 100.ms, curve: Curves.elasticOut),
                  SizedBox(width: AppDimensions.spacing3),

                  // Transaction Details - Expanded to take remaining space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Amount Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Category - takes available space
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Transaction Title
                                  Text(
                                    widget.transaction.title,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).animate()
                                    .fadeIn(duration: 400.ms, delay: 200.ms)
                                    .slideX(begin: 0.2, duration: 400.ms, delay: 200.ms, curve: Curves.easeOutCubic),
                                  SizedBox(height: AppDimensions.spacing1),
                                  // Category Name - directly under transaction name
                                  Text(
                                    categoryName,
                                    style: AppTypography.caption.copyWith(
                                      color: categoryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).animate()
                                    .fadeIn(duration: 300.ms, delay: 250.ms),
                                ],
                              ),
                            ),
                            SizedBox(width: AppDimensions.spacing2),
                            // Amount and Time Since - fixed width section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Transaction Amount
                                Text(
                                  widget.transaction.signedAmount,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: widget.transaction.isIncome ? AppColors.success : AppColors.danger,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).animate()
                                  .fadeIn(duration: 400.ms, delay: 300.ms)
                                  .slideX(begin: -0.2, duration: 400.ms, delay: 300.ms, curve: Curves.easeOutCubic),
                                SizedBox(height: AppDimensions.spacing1),
                                // Time Since - always shown, aligned to bottom of amount
                                Text(
                                  widget.transaction.date.toTimeAgo(),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                ).animate()
                                  .fadeIn(duration: 300.ms, delay: 350.ms),
                              ],
                            ),
                          ],
                        ),

                        // Description (if available)
                        if (widget.transaction.description != null) ...[
                          SizedBox(height: AppDimensions.spacing1),
                          Text(
                            widget.transaction.description!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).animate()
                            .fadeIn(duration: 300.ms, delay: 400.ms)
                            .slideY(begin: 0.1, duration: 300.ms, delay: 400.ms, curve: Curves.easeOut),
                        ],

                        // Account and Date
                        SizedBox(height: AppDimensions.spacing1),
                        Row(
                          children: [
                            // Account indicator - flexible
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacing1,
                                  vertical: AppDimensions.spacing0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                ),
                                child: Text(
                                  (widget.transaction.accountId?.isEmpty ?? true)
                                      ? 'No Account'
                                      : 'Account ${widget.transaction.accountId}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ).animate()
                                .fadeIn(duration: 300.ms, delay: 450.ms)
                                .scale(begin: const Offset(0.9, 0.9), duration: 300.ms, delay: 450.ms),
                            ),
                            SizedBox(width: AppDimensions.spacing2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ).animate()
                              .fadeIn(duration: 200.ms, delay: 500.ms),
                            SizedBox(width: AppDimensions.spacing2),
                            // Date - fixed content
                            Text(
                              DateFormat('MMM dd').format(widget.transaction.date),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).animate()
                              .fadeIn(duration: 300.ms, delay: 550.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  void _showDetailSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    AppBottomSheet.show(
      context: context,
      child: TransactionDetailBottomSheet(transaction: widget.transaction),
    );
  }

  void _showEditSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    AppBottomSheet.show(
      context: context,
      child: TransactionDetailBottomSheet(
        transaction: widget.transaction,
        startInEditMode: true,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    HapticFeedback.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete "${widget.transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(widget.transaction.id);

      if (success && context.mounted) {
        HapticFeedback.mediumImpact();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NotificationManager.transactionDeleted(context);
          }
        });
      }
    }
  }

  Future<void> _duplicateTransaction(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();

    // Create duplicate with new ID
    final duplicateTransaction = widget.transaction.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${widget.transaction.title} (Copy)',
    );

    final success = await ref
        .read(transactionNotifierProvider.notifier)
        .addTransaction(duplicateTransaction);

    if (success && context.mounted) {
      HapticFeedback.mediumImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          NotificationManager.transactionDuplicated(context);
        }
      });
    }
  }

  Future<void> _shareTransaction(BuildContext context) async {
    HapticFeedback.selectionClick();

    // Create share text
    final shareText = '''
Transaction Details:
Title: ${widget.transaction.title}
Amount: ${widget.transaction.signedAmount}
Date: ${DateFormat('MMM dd, yyyy').format(widget.transaction.date)}
${widget.transaction.description != null ? 'Description: ${widget.transaction.description}' : ''}
''';

    // Use share_plus or similar package to share
    // For now, just copy to clipboard
    await Clipboard.setData(ClipboardData(text: shareText));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction details copied to clipboard')),
      );
    }
  }
}