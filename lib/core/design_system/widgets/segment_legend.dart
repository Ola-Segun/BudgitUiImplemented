import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../models/circular_segment.dart';

/// Legend display for circular segments
///
/// Usage:
/// ```dart
/// SegmentLegend(
///   segments: segments,
///   totalValue: 1000,
///   selectedSegmentId: 'food',
///   onSegmentTap: (segment) => setState(() => selected = segment.id),
/// )
/// ```
class SegmentLegend extends StatelessWidget {
  const SegmentLegend({
    super.key,
    required this.segments,
    required this.totalValue,
    this.selectedSegmentId,
    this.onSegmentTap,
    this.showPercentages = true,
    this.showValues = true,
    this.compact = false,
  });

  final List<CircularSegment> segments;
  final double totalValue;
  final String? selectedSegmentId;
  final ValueChanged<CircularSegment>? onSegmentTap;
  final bool showPercentages;
  final bool showValues;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isSelected = segment.id == selectedSegmentId;

        return _buildLegendItem(segment, index, isSelected);
      }).toList(),
    );
  }

  Widget _buildLegendItem(CircularSegment segment, int index, bool isSelected) {
    final percentage = segment.getPercentage(totalValue);

    return Padding(
      padding: EdgeInsets.only(
        bottom: compact ? DesignTokens.spacing2 : DesignTokens.spacing3,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSegmentTap != null ? () => onSegmentTap!(segment) : null,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: AnimatedContainer(
            duration: DesignTokens.durationSm,
            padding: EdgeInsets.all(compact ? DesignTokens.spacing2 : DesignTokens.spacing3),
            decoration: BoxDecoration(
              color: isSelected
                  ? segment.color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: isSelected
                  ? Border.all(color: segment.color, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                // Color indicator
                AnimatedContainer(
                  duration: DesignTokens.durationSm,
                  width: compact ? 12 : 16,
                  height: compact ? 12 : 16,
                  decoration: BoxDecoration(
                    color: segment.color,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: segment.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(width: compact ? DesignTokens.spacing2 : DesignTokens.spacing3),

                // Icon
                Container(
                  padding: EdgeInsets.all(compact ? DesignTokens.spacing1 : DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: segment.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Icon(
                    segment.icon,
                    size: compact ? DesignTokens.iconSm : DesignTokens.iconMd,
                    color: segment.color,
                  ),
                ),
                SizedBox(width: compact ? DesignTokens.spacing2 : DesignTokens.spacing3),

                // Label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.label,
                        style: (compact
                            ? TypographyTokens.bodySm
                            : TypographyTokens.bodyMd
                        ).copyWith(
                          fontWeight: isSelected
                              ? TypographyTokens.weightSemiBold
                              : TypographyTokens.weightRegular,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (segment.category != null && !compact) ...[
                        const SizedBox(height: 2),
                        Text(
                          segment.category!,
                          style: TypographyTokens.captionSm.copyWith(
                            color: ColorTokens.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Values
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showValues)
                      Text(
                        '\$${segment.value.toInt()}',
                        style: (compact
                            ? TypographyTokens.labelSm
                            : TypographyTokens.labelMd
                        ).copyWith(
                          color: segment.color,
                          fontWeight: TypographyTokens.weightBold,
                        ),
                      ),
                    if (showPercentages) ...[
                      if (showValues) const SizedBox(height: 2),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: TypographyTokens.captionSm.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate()
        .fadeIn(duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 50 * index))
        .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: Duration(milliseconds: 50 * index)),
    );
  }
}