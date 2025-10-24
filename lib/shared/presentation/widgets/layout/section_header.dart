import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../buttons/app_icon_button.dart';

/// Section header component for organizing content sections
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTrailingPressed;
  final IconData? trailingIcon;
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTrailingPressed,
    this.trailingIcon,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h2,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ] else if (trailingIcon != null && onTrailingPressed != null) ...[
              const SizedBox(width: 12),
              AppIconButton(
                icon: trailingIcon!,
                onPressed: onTrailingPressed,
                variant: AppIconButtonVariant.ghost,
                size: AppIconButtonSize.small,
              ),
            ],
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(
            color: AppColors.borderSubtle,
            thickness: 1,
          ),
        ],
      ],
    );
  }
}