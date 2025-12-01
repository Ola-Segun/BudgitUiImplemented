import 'package:flutter/material.dart';

/// Widget that shows a visual indicator when privacy mode is active
class PrivacyModeIndicator extends StatelessWidget {
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const PrivacyModeIndicator({
    super.key,
    this.size = 16.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Properly inject PrivacyModeService with Ref
    // For now, assume privacy mode is not active to fix compilation
    const isActive = false;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? (activeColor ?? Colors.red)
            : (inactiveColor ?? Colors.transparent),
        border: isActive
            ? Border.all(color: Colors.white, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: isActive
          ? Icon(
              Icons.visibility_off,
              size: size * 0.6,
              color: Colors.white,
            )
          : null,
    );
  }
}

/// App bar widget that includes privacy mode indicator
class PrivacyModeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;

  const PrivacyModeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Properly inject PrivacyModeService with Ref
    // For now, assume privacy mode is not active to fix compilation
    final isActive = false;

    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            const PrivacyModeIndicator(),
          ],
        ],
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}