import 'package:flutter/widgets.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Responsive spacing widget
/// Replaces SizedBox for consistent spacing
class Gap extends StatelessWidget {
  final double size;
  final bool isHorizontal;

  const Gap(this.size, {super.key}) : isHorizontal = false;
  const Gap.horizontal(this.size, {super.key}) : isHorizontal = true;

  // Named constructors for common sizes
  const Gap.xs({super.key}) : size = AppDimensions.spacing1, isHorizontal = false;
  const Gap.sm({super.key}) : size = AppDimensions.spacing2, isHorizontal = false;
  const Gap.md({super.key}) : size = AppDimensions.spacing3, isHorizontal = false;
  const Gap.lg({super.key}) : size = AppDimensions.spacing4, isHorizontal = false;
  const Gap.xl({super.key}) : size = AppDimensions.spacing6, isHorizontal = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isHorizontal ? size : null,
      height: isHorizontal ? null : size,
    );
  }
}