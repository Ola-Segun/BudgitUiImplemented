import 'package:flutter/material.dart';
import '../../../../core/design_system/modern/modern_design_constants.dart';
import '../../../../core/design_system/modern/modern_action_button.dart';

/// Modern settings tile for account management
class AccountSettingsTile extends StatelessWidget {
  const AccountSettingsTile({
    super.key,
    required this.onManageAccounts,
    required this.onSignOut,
  });

  final VoidCallback onManageAccounts;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ModernColors.lightBackground,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ModernColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing_xs),
                decoration: BoxDecoration(
                  color: ModernColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: ModernColors.accentGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Account Management',
                style: ModernTypography.titleLarge,
              ),
            ],
          ),
          SizedBox(height: spacing_lg),

          // Manage Accounts Button
          Semantics(
            button: true,
            label: 'Manage accounts button',
            hint: 'Double tap to manage your accounts',
            child: ModernActionButton(
              text: 'Manage Accounts',
              icon: Icons.account_balance,
              isPrimary: false,
              onPressed: onManageAccounts,
            ),
          ),

          SizedBox(height: spacing_md),

          // Sign Out Button
          Semantics(
            button: true,
            label: 'Sign out button',
            hint: 'Double tap to sign out of your account',
            child: ModernActionButton(
              text: 'Sign Out',
              icon: Icons.logout,
              isPrimary: false,
              onPressed: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}