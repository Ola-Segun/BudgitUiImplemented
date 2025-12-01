import 'package:flutter/material.dart';
import 'modern_design_constants.dart';

/// Modern Color Picker Widget
/// Provides a simple color selection interface with predefined colors
class ModernColorPicker extends StatefulWidget {
  final Color? initialColor;
  final ValueChanged<Color> onColorChanged;
  final String? label;
  final bool showTransparent;

  const ModernColorPicker({
    super.key,
    this.initialColor,
    required this.onColorChanged,
    this.label,
    this.showTransparent = false,
  });

  @override
  State<ModernColorPicker> createState() => _ModernColorPickerState();
}

class _ModernColorPickerState extends State<ModernColorPicker> {
  late Color _selectedColor;

  // Predefined color palette
  static const List<Color> _colorPalette = [
    Color(0xFF00D09C), // Green
    Color(0xFF007AFF), // Blue
    Color(0xFF5E5CE6), // Purple
    Color(0xFFFF2D92), // Pink
    Color(0xFFFF6B2C), // Orange
    Color(0xFFFF9500), // Yellow
    Color(0xFFFF3B30), // Red
    Color(0xFF1A1A1A), // Black
    Color(0xFF8E8E93), // Gray
    Color(0xFFF5F5F5), // Light Gray
    Color(0xFF007AFF), // Blue (duplicate for more options)
    Color(0xFF00D09C), // Green (duplicate)
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor ?? _colorPalette[0];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: ModernTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing_sm),
        ],
        // Current color display
        Container(
          padding: EdgeInsets.all(spacing_md),
          decoration: BoxDecoration(
            color: ModernColors.lightBackground,
            borderRadius: BorderRadius.circular(radius_md),
            border: Border.all(color: ModernColors.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(radius_sm),
                  border: Border.all(
                    color: ModernColors.borderColor,
                    width: 2,
                  ),
                ),
              ),
              SizedBox(width: spacing_md),
              Expanded(
                child: Text(
                  'Selected Color',
                  style: ModernTypography.bodyLarge,
                ),
              ),
              Text(
                '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                style: ModernTypography.labelMedium,
              ),
            ],
          ),
        ),
        SizedBox(height: spacing_md),
        // Color palette grid
        Container(
          padding: EdgeInsets.all(spacing_md),
          decoration: BoxDecoration(
            color: ModernColors.lightBackground,
            borderRadius: BorderRadius.circular(radius_md),
            border: Border.all(color: ModernColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Color',
                style: ModernTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing_md),
              Wrap(
                spacing: spacing_sm,
                runSpacing: spacing_sm,
                children: _colorPalette.map((color) {
                  final isSelected = color.value == _selectedColor.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      widget.onColorChanged(color);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(radius_sm),
                        border: Border.all(
                          color: isSelected
                              ? ModernColors.primaryBlack
                              : ModernColors.borderColor,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [ModernShadows.subtle]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              if (widget.showTransparent) ...[
                SizedBox(height: spacing_md),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = Colors.transparent;
                    });
                    widget.onColorChanged(Colors.transparent);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(radius_sm),
                      border: Border.all(
                        color: _selectedColor == Colors.transparent
                            ? ModernColors.primaryBlack
                            : ModernColors.borderColor,
                        width: _selectedColor == Colors.transparent ? 3 : 1,
                      ),
                      boxShadow: _selectedColor == Colors.transparent
                          ? [ModernShadows.subtle]
                          : null,
                    ),
                    child: _selectedColor == Colors.transparent
                        ? Icon(
                            Icons.check,
                            color: ModernColors.primaryBlack,
                            size: 20,
                          )
                        : Icon(
                            Icons.clear,
                            color: ModernColors.textSecondary,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    // Simple luminance calculation for contrast
    final luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}