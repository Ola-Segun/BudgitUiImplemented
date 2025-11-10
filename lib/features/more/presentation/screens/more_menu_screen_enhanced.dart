import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';

class MoreMenuScreenEnhanced extends StatelessWidget {
  const MoreMenuScreenEnhanced({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DesignTokens.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: DesignTokens.spacing3),

              // Header with Profile
              _buildHeader(context).animate()
                .fadeIn(duration: DesignTokens.durationNormal)
                .slideY(begin: -0.1, duration: DesignTokens.durationNormal),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Financial Management Section
              _buildSection(
                context,
                title: 'Financial Management',
                icon: Icons.account_balance_wallet,
                color: ColorTokens.teal500,
                items: [
                  MenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Accounts',
                    subtitle: 'Manage accounts and cards',
                    color: ColorTokens.teal500,
                    route: '/more/accounts',
                  ),
                  MenuItem(
                    icon: Icons.receipt_long,
                    title: 'Bills & Subscriptions',
                    subtitle: 'Track recurring payments',
                    color: ColorTokens.purple600,
                    route: '/more/bills',
                  ),
                  MenuItem(
                    icon: Icons.account_balance,
                    title: 'Debt Manager',
                    subtitle: 'Monitor and manage debts',
                    color: ColorTokens.critical500,
                    route: '/more/debt',
                  ),
                  MenuItem(
                    icon: Icons.category,
                    title: 'Categories',
                    subtitle: 'Manage transaction categories',
                    color: ColorTokens.warning500,
                    route: '/more/categories',
                  ),
                ],
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 100.ms),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Insights Section
              _buildSection(
                context,
                title: 'Insights & Analytics',
                icon: Icons.insights,
                color: ColorTokens.info500,
                items: [
                  MenuItem(
                    icon: Icons.insights,
                    title: 'Insights & Reports',
                    subtitle: 'View spending analytics',
                    color: ColorTokens.info500,
                    route: '/more/insights',
                  ),
                ],
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 200.ms),

              SizedBox(height: DesignTokens.sectionGapLg),

              // Settings Section
              _buildSection(
                context,
                title: 'Settings & Support',
                icon: Icons.settings,
                color: ColorTokens.neutral600,
                items: [
                  MenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    color: ColorTokens.neutral600,
                    route: '/more/settings',
                  ),
                  MenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'FAQs and contact support',
                    color: ColorTokens.success500,
                    route: '/more/help',
                  ),
                ],
              ).animate()
                .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
                .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms),

              SizedBox(height: DesignTokens.spacing8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More',
          style: TypographyTokens.display3.copyWith(
            fontSize: 32,
          ),
        ),
        SizedBox(height: DesignTokens.spacing2),
        Text(
          'Manage your finances and preferences',
          style: TypographyTokens.bodyLg.copyWith(
            color: ColorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.only(
            left: DesignTokens.spacing2,
            bottom: DesignTokens.spacing3,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing1),
                decoration: BoxDecoration(
                  color: ColorTokens.withOpacity(color, 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: DesignTokens.iconSm,
                  color: color,
                ),
              ),
              SizedBox(width: DesignTokens.spacing2),
              Text(
                title,
                style: TypographyTokens.heading6.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),

        // Menu Items
        Container(
          decoration: BoxDecoration(
            color: ColorTokens.surfacePrimary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            boxShadow: DesignTokens.elevationLow,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _MenuItemTile(item: item),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: ColorTokens.neutral200,
                      indent: DesignTokens.spacing5 + DesignTokens.iconMd + DesignTokens.spacing3,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go(item.route);
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacing4),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color,
                      ColorTokens.darken(item.color, 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  boxShadow: DesignTokens.elevationColored(
                    item.color,
                    alpha: 0.2,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: DesignTokens.iconMd,
                ),
              ),
              SizedBox(width: DesignTokens.spacing3),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TypographyTokens.bodyLg.copyWith(
                        fontWeight: TypographyTokens.weightSemiBold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                padding: EdgeInsets.all(DesignTokens.spacing1),
                decoration: BoxDecoration(
                  color: ColorTokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: ColorTokens.textSecondary,
                  size: DesignTokens.iconMd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}