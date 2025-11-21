import 'package:flutter/material.dart';
import 'modern_design_constants.dart';

/// ModernBottomSheet Container
/// Consistent bottom sheet wrapper with drag handle
/// Rounded top corners (24px), Drag handle indicator (4px height, 36px width)
/// White background, Padding: 24px horizontal, 16px top
/// Subtle upward shadow
class ModernBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool showDragHandle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const ModernBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.showDragHandle = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bottom sheet',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? ModernColors.lightBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(radius_xl),
            topRight: Radius.circular(radius_xl),
          ),
          boxShadow: [ModernShadows.medium],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle) ...[
              const SizedBox(height: spacing_md),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ModernColors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: spacing_md),
            ],
            Flexible(
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: spacing_lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show ModernBottomSheet
Future<T?> showModernBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool enableDrag = true,
  Color? backgroundColor,
  double? height,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (context) => ModernBottomSheet(
      backgroundColor: backgroundColor,
      height: height,
      child: builder(context),
    ),
  );
}