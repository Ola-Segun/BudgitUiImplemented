import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/patterns/info_card_pattern.dart';
import '../../../../core/design_system/patterns/action_button_pattern.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/enhanced_transaction_tile.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';
import '../widgets/add_edit_account_bottom_sheet.dart';

// Accessibility utilities
class AccessibilityUtils {
  // Ensure minimum touch target size (48x48dp)
  static const double minTouchTargetSize = 48.0;

  // Check if color meets contrast requirements
  static bool meetsContrastRatio(Color foreground, Color background) {
    // Simple luminance calculation for contrast checking
    double getLuminance(Color color) {
      final r = color.r / 255.0;
      final g = color.g / 255.0;
      final b = color.b / 255.0;
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    final fgLuminance = getLuminance(foreground);
    final bgLuminance = getLuminance(background);
    final contrast = (fgLuminance > bgLuminance)
        ? (fgLuminance + 0.05) / (bgLuminance + 0.05)
        : (bgLuminance + 0.05) / (fgLuminance + 0.05);

    return contrast >= 4.5;
  }

  // Get accessible text color based on background
  static Color getAccessibleTextColor(Color background) {
    return ColorTokens.isLight(background)
        ? ColorTokens.textPrimary
        : ColorTokens.textInverse;
  }
}

/// Enhanced account detail screen with modern UI and smooth animations
class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({
    super.key,
    required this.accountId,
  });

  final String accountId;

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: DesignTokens.curveEaseOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountProvider(widget.accountId));
    final accountTransactionsAsync = ref.watch(accountTransactionsProvider(widget.accountId));

    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: _buildAppBar(context, accountAsync),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: accountAsync.when(
          data: (account) {
            if (account == null) {
              return const Center(
                child: Text('Account not found'),
              );
            }

            return _buildAccountDetail(context, ref, account, accountTransactionsAsync);
          },
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.refresh(accountProvider(widget.accountId)),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AsyncValue<Account?> accountAsync) {
    return AppBar(
      backgroundColor: ColorTokens.surfacePrimary,
      elevation: 0,
      title: accountAsync.when(
        data: (account) => Text(
          account?.name ?? 'Account Details',
          style: TypographyTokens.heading3,
        ),
        loading: () => Text(
          'Loading...',
          style: TypographyTokens.heading3,
        ),
        error: (error, stack) => Text(
          'Account Details',
          style: TypographyTokens.heading3,
        ),
      ),
      actions: [
        accountAsync.when(
          data: (account) {
            if (account == null) return const SizedBox.shrink();
            return PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, account, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: ColorTokens.teal500),
                      SizedBox(width: 8),
                      Text('Edit Account'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: ColorTokens.critical500),
                      SizedBox(width: 8),
                      Text('Delete Account', style: TextStyle(color: ColorTokens.critical500)),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAccountDetail(
    BuildContext context,
    WidgetRef ref,
    Account account,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    return Semantics(
      label: 'Account details for ${account.name}',
      hint: 'Scroll to view account information, balance, and transactions',
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(accountNotifierProvider.notifier).loadAccounts(),
            ref.read(transactionNotifierProvider.notifier).loadTransactions(),
          ]);
        },
        color: ColorTokens.teal500,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DesignTokens.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Card
              Semantics(
                label: 'Account overview card',
                child: _buildAccountCard(context, account).animate()
                  .fadeIn(duration: DesignTokens.durationNormal)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Balance Visualization
              Semantics(
                label: 'Balance visualization section',
                child: _buildBalanceVisualization(context, account).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Quick Actions
              Semantics(
                label: 'Quick actions section',
                child: _buildQuickActions(context, account).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Account Information
              Semantics(
                label: 'Account information section',
                child: _buildAccountInfo(context, account).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),
              ),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Transaction History
              Semantics(
                label: 'Transaction history section',
                child: _buildTransactionHistory(context, transactionsAsync).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 400.ms),
              ),

              SizedBox(height: DesignTokens.spacing8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Account account) {
    return Semantics(
      label: 'Account card for ${account.name}, type ${account.type.displayName}, balance ${account.currency} ${account.currentBalance.toStringAsFixed(2)}',
      hint: 'Tap to view account details',
      child: Container(
        padding: EdgeInsets.all(DesignTokens.cardPaddingLg),
        decoration: BoxDecoration(
          gradient: ColorTokens.gradientPrimary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          boxShadow: DesignTokens.elevationColored(
            ColorTokens.teal500,
            alpha: 0.3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Type and Name
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    _getAccountTypeIcon(account.type),
                    color: Colors.white,
                    size: DesignTokens.iconMd,
                    semanticLabel: 'Account type icon',
                  ),
                ),
                SizedBox(width: DesignTokens.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: TypographyTokens.heading4.copyWith(
                          color: AccessibilityUtils.getAccessibleTextColor(ColorTokens.teal500),
                        ),
                        semanticsLabel: 'Account name: ${account.name}',
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.type.displayName,
                        style: TypographyTokens.captionMd.copyWith(
                          color: AccessibilityUtils.getAccessibleTextColor(ColorTokens.teal500).withValues(alpha: 0.9),
                        ),
                        semanticsLabel: 'Account type: ${account.type.displayName}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: DesignTokens.spacing4),

            // Balance
            Text(
              'Current Balance',
              style: TypographyTokens.captionMd.copyWith(
                color: AccessibilityUtils.getAccessibleTextColor(ColorTokens.teal500).withValues(alpha: 0.8),
              ),
              semanticsLabel: 'Balance label',
            ),
            const SizedBox(height: 4),
            Text(
              '${account.currency} ${account.currentBalance.toStringAsFixed(2)}',
              style: TypographyTokens.numericXl.copyWith(
                color: AccessibilityUtils.getAccessibleTextColor(ColorTokens.teal500),
              ),
              semanticsLabel: 'Current balance: ${account.currency} ${account.currentBalance.toStringAsFixed(2)}',
            ),

            // Account Status
            if (!account.isActive) ...[
              SizedBox(height: DesignTokens.spacing3),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing2,
                  vertical: DesignTokens.spacing1,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  'Inactive',
                  style: TypographyTokens.captionSm.copyWith(
                    color: AccessibilityUtils.getAccessibleTextColor(ColorTokens.teal500),
                  ),
                  semanticsLabel: 'Account status: Inactive',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceVisualization(BuildContext context, Account account) {
    return InfoCardPattern(
      title: 'Balance Overview',
      icon: Icons.insights,
      iconColor: ColorTokens.teal500,
      children: [
        // Balance Progress (for credit cards and loans)
        if (account.type == AccountType.creditCard && account.creditLimit != null) ...[
          _buildBalanceProgress(account).animate()
            .fadeIn(duration: DesignTokens.durationNormal)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

          SizedBox(height: DesignTokens.spacing4),
        ],

        // Balance Stats
        Row(
          children: [
            Expanded(
              child: _buildBalanceStat(
                'Available',
                '${account.currency} ${account.availableBalance.toStringAsFixed(2)}',
                ColorTokens.success500,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: _buildBalanceStat(
                'Used',
                '${account.currency} ${(account.currentBalance - account.availableBalance).abs().toStringAsFixed(2)}',
                ColorTokens.warning500,
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 50.ms),
            ),
          ],
        ),

        // Credit utilization for credit cards
        if (account.type == AccountType.creditCard && account.utilizationRate != null) ...[
          SizedBox(height: DesignTokens.spacing4),
          Text(
            'Credit Utilization',
            style: TypographyTokens.labelMd,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

          SizedBox(height: DesignTokens.spacing2),
          LinearProgressIndicator(
            value: account.utilizationRate! / 100,
            backgroundColor: ColorTokens.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              account.utilizationRate! > 30 ? ColorTokens.critical500 : ColorTokens.success500,
            ),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 150.ms),

          SizedBox(height: DesignTokens.spacing2),
          Text(
            '${account.utilizationRate!.toStringAsFixed(1)}%',
            style: TypographyTokens.bodyMd.copyWith(
              color: account.utilizationRate! > 30 ? ColorTokens.critical500 : ColorTokens.success500,
              fontWeight: TypographyTokens.weightSemiBold,
            ),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 200.ms),
        ],
      ],
    );
  }

  Widget _buildBalanceProgress(Account account) {
    final usedAmount = account.creditLimit! - (account.availableCredit ?? 0);
    final utilizationRate = account.utilizationRate ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Credit Used',
              style: TypographyTokens.bodyMd,
            ),
            Text(
              '${account.currency} ${usedAmount.toStringAsFixed(2)} / ${account.currency} ${account.creditLimit!.toStringAsFixed(2)}',
              style: TypographyTokens.bodyMd.copyWith(
                fontWeight: TypographyTokens.weightSemiBold,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignTokens.spacing2),
        LinearProgressIndicator(
          value: utilizationRate / 100,
          backgroundColor: ColorTokens.neutral200,
          valueColor: AlwaysStoppedAnimation<Color>(
            utilizationRate > 30 ? ColorTokens.critical500 : ColorTokens.success500,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceStat(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: ColorTokens.withOpacity(color, 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TypographyTokens.captionMd.copyWith(
              color: color,
            ),
          ),
          SizedBox(height: DesignTokens.spacing1),
          Text(
            value,
            style: TypographyTokens.numericMd.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Account account) {
    return InfoCardPattern(
      title: 'Quick Actions',
      icon: Icons.flash_on,
      iconColor: ColorTokens.warning500,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'Add transaction to ${account.name}',
                hint: 'Opens transaction creation screen',
                child: _QuickActionButton(
                  icon: Icons.add,
                  label: 'Add Transaction',
                  gradient: ColorTokens.gradientPrimary,
                  onTap: () => _addTransaction(context),
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal),
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Transfer money from ${account.name}',
                hint: 'Opens transfer screen',
                child: _QuickActionButton(
                  icon: Icons.transfer_within_a_station,
                  label: 'Transfer',
                  gradient: ColorTokens.gradientSecondary,
                  onTap: () => _transferMoney(context),
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 50.ms),
              ),
            ),
          ],
        ),
        SizedBox(height: DesignTokens.spacing3),
        Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'Reconcile account ${account.name}',
                hint: 'Opens account reconciliation',
                child: _QuickActionButton(
                  icon: Icons.sync,
                  label: 'Reconcile',
                  gradient: LinearGradient(
                    colors: [ColorTokens.warning500, ColorTokens.warning600],
                  ),
                  onTap: () => _reconcileAccount(context, account),
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Share details of ${account.name}',
                hint: 'Opens share options',
                child: _QuickActionButton(
                  icon: Icons.share,
                  label: 'Share Details',
                  gradient: LinearGradient(
                    colors: [ColorTokens.info500, ColorTokens.info600],
                  ),
                  onTap: () => _shareAccountDetails(context, account),
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                  .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountInfo(BuildContext context, Account account) {
    return InfoCardPattern(
      title: 'Account Information',
      icon: Icons.info_outline,
      iconColor: ColorTokens.info500,
      children: [
        // Account Type
        _buildInfoRow('Type', account.type.displayName).animate()
          .fadeIn(duration: DesignTokens.durationNormal)
          .slideX(begin: -0.1, duration: DesignTokens.durationNormal),

        // Institution
        if (account.institution != null)
          _buildInfoRow('Institution', account.institution!).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 50.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 50.ms),

        // Account Number
        if (account.accountNumber != null)
          _buildInfoRow('Account Number', account.accountNumber!).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

        // Currency
        _buildInfoRow('Currency', account.currency ?? 'USD').animate()
          .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
          .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 150.ms),

        // Status
        _buildInfoRow('Status', account.isActive ? 'Active' : 'Inactive').animate()
          .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
          .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

        // Created Date
        if (account.createdAt != null)
          _buildInfoRow(
            'Created',
            DateFormat('MMM dd, yyyy').format(account.createdAt!),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 250.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 250.ms),

        // Description
        if (account.description != null && account.description!.isNotEmpty) ...[
          SizedBox(height: DesignTokens.spacing4),
          Text(
            'Description',
            style: TypographyTokens.labelMd,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

          SizedBox(height: DesignTokens.spacing2),
          Text(
            account.description!,
            style: TypographyTokens.bodyMd,
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 350.ms)
            .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 350.ms),
        ],

        // Type-specific information
        ..._buildTypeSpecificInfo(context, account),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TypographyTokens.bodyMd.copyWith(
                color: ColorTokens.textSecondary,
                fontWeight: TypographyTokens.weightMedium,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TypographyTokens.bodyMd,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeSpecificInfo(BuildContext context, Account account) {
    switch (account.type) {
      case AccountType.creditCard:
        return [
          if (account.creditLimit != null) ...[
            SizedBox(height: DesignTokens.spacing4),
            Text(
              'Credit Card Details',
              style: TypographyTokens.labelMd,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

            SizedBox(height: DesignTokens.spacing2),
            _buildInfoRow('Credit Limit', '${account.currency} ${account.creditLimit!.toStringAsFixed(2)}').animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 450.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 450.ms),

            if (account.availableCredit != null)
              _buildInfoRow('Available Credit', '${account.currency} ${account.availableCredit!.toStringAsFixed(2)}').animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 500.ms),

            if (account.minimumPayment != null)
              _buildInfoRow('Minimum Payment', '${account.currency} ${account.minimumPayment!.toStringAsFixed(2)}').animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 550.ms)
                .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 550.ms),
          ],
        ];

      case AccountType.loan:
        return [
          if (account.interestRate != null || account.minimumPayment != null) ...[
            SizedBox(height: DesignTokens.spacing4),
            Text(
              'Loan Details',
              style: TypographyTokens.labelMd,
            ).animate()
              .fadeIn(duration: DesignTokens.durationNormal, delay: 400.ms)
              .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 400.ms),

            SizedBox(height: DesignTokens.spacing2),
            if (account.interestRate != null)
              _buildInfoRow('Interest Rate', '${account.interestRate!.toStringAsFixed(2)}%').animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 450.ms)
                .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 450.ms),

            if (account.minimumPayment != null)
              _buildInfoRow('Monthly Payment', '${account.currency} ${account.minimumPayment!.toStringAsFixed(2)}').animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 500.ms)
                .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 500.ms),
          ],
        ];

      default:
        return [];
    }
  }

  Widget _buildTransactionHistory(
    BuildContext context,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    return InfoCardPattern(
      title: 'Recent Transactions',
      icon: Icons.history,
      iconColor: ColorTokens.neutral600,
      children: [
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing8),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: ColorTokens.neutral500,
                    ),
                    SizedBox(height: DesignTokens.spacing3),
                    Text(
                      'No transactions yet',
                      style: TypographyTokens.heading6,
                    ),
                    SizedBox(height: DesignTokens.spacing2),
                    Text(
                      'Transactions for this account will appear here',
                      style: TypographyTokens.bodyMd.copyWith(
                        color: ColorTokens.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Show only recent 10 transactions
            final recentTransactions = transactions.take(10).toList();

            // Filter to show only transfers involving this account
            final transferTransactions = recentTransactions.where((t) => t.isTransfer).toList();
            final otherTransactions = recentTransactions.where((t) => !t.isTransfer).toList();

            return Column(
              children: [
                // Show transfer transactions first if any
                if (transferTransactions.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
                    child: Text(
                      'Transfer History',
                      style: TypographyTokens.labelMd.copyWith(
                        color: ColorTokens.teal500,
                        fontWeight: TypographyTokens.weightSemiBold,
                      ),
                    ),
                  ),
                  ...transferTransactions.map((transaction) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
                      child: EnhancedTransactionTile(transaction: transaction),
                    );
                  }),
                  if (otherTransactions.isNotEmpty)
                    SizedBox(height: DesignTokens.spacing3),
                ],

                // Show other transactions
                if (otherTransactions.isNotEmpty) ...[
                  if (transferTransactions.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
                      child: Text(
                        'Other Transactions',
                        style: TypographyTokens.labelMd.copyWith(
                          color: ColorTokens.textSecondary,
                          fontWeight: TypographyTokens.weightSemiBold,
                        ),
                      ),
                    ),
                  ...otherTransactions.map((transaction) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
                      child: EnhancedTransactionTile(transaction: transaction),
                    );
                  }),
                ],

                SizedBox(height: DesignTokens.spacing3),
                ActionButtonPattern(
                  label: 'View All Transactions',
                  icon: Icons.arrow_forward,
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                  isFullWidth: true,
                  onPressed: () {
                    // TODO: Navigate to full transaction list for this account
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('View all transactions - Coming soon!'),
                        backgroundColor: ColorTokens.info500,
                      ),
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Failed to load transactions: $error'),
          ),
        ),
      ],
    );
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return Icons.account_balance_wallet;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.loan:
        return Icons.account_balance;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.manualAccount:
        return Icons.edit;
    }
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    Account account,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditAccountSheet(context, ref, account);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, account);
        break;
    }
  }

  Future<void> _showEditAccountSheet(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: AddEditAccountBottomSheet(
        account: account,
        onSubmit: (updatedAccount) async {
          final success = await ref
              .read(accountNotifierProvider.notifier)
              .updateAccount(updatedAccount);

          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account updated successfully'),
                backgroundColor: ColorTokens.success500,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorTokens.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing2),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.critical500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                Icons.delete_forever,
                color: ColorTokens.critical500,
                size: DesignTokens.iconMd,
              ),
            ),
            SizedBox(width: DesignTokens.spacing3),
            Text(
              'Delete Account',
              style: TypographyTokens.heading5,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${account.name}"? This action cannot be undone.',
              style: TypographyTokens.bodyMd,
            ),
            SizedBox(height: DesignTokens.spacing3),
            Container(
              padding: EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                color: ColorTokens.withOpacity(ColorTokens.critical500, 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: ColorTokens.critical500,
                    size: DesignTokens.iconSm,
                  ),
                  SizedBox(width: DesignTokens.spacing2),
                  Expanded(
                    child: Text(
                      'All associated transactions will remain in your history.',
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.critical500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ActionButtonPattern(
                  label: 'Cancel',
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.medium,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: ActionButtonPattern(
                  label: 'Delete',
                  variant: ButtonVariant.danger,
                  size: ButtonSize.medium,
                  icon: Icons.delete_forever,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(accountNotifierProvider.notifier)
          .deleteAccount(account.id);

      if (success && mounted) {
        context.go('/more/accounts'); // Go back to accounts list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: ColorTokens.success500,
          ),
        );
      }
    }
  }

  void _addTransaction(BuildContext context) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to add transaction screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add transaction - Coming soon!'),
        backgroundColor: ColorTokens.info500,
      ),
    );
  }

  void _transferMoney(BuildContext context) {
    HapticFeedback.lightImpact();
    // Navigate to transfer screen with pre-selected source account
    context.go('/more/accounts/transfer', extra: widget.accountId);
  }

  void _reconcileAccount(BuildContext context, Account account) {
    HapticFeedback.lightImpact();
    // Navigate to reconciliation screen
    context.go('/more/accounts/${account.id}/reconcile');
  }

  void _viewStatement(BuildContext context) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to statement view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('View statement - Coming soon!'),
        backgroundColor: ColorTokens.info500,
      ),
    );
  }

  void _shareAccountDetails(BuildContext context, Account account) {
    HapticFeedback.lightImpact();
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${account.name} details...'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        // Ensure minimum touch target size
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AccessibilityUtils.minTouchTargetSize,
            minHeight: AccessibilityUtils.minTouchTargetSize,
          ),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              boxShadow: DesignTokens.elevationColored(
                gradient.colors.first,
                alpha: 0.3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: DesignTokens.iconLg,
                    semanticLabel: '$label icon',
                  ),
                ),
                SizedBox(height: DesignTokens.spacing2),
                Text(
                  label,
                  style: TypographyTokens.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: TypographyTokens.weightBold,
                  ),
                  textAlign: TextAlign.center,
                  semanticsLabel: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}