import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// Dropdown item model
class ModernDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? color;

  const ModernDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}

/// ModernDropdownSelector Widget
/// Modern dropdown selector with bottom sheet presentation
/// Clean button-style trigger with chevron icon
class ModernDropdownSelector<T> extends StatefulWidget {
  final String label;
  final String? placeholder;
  final T? selectedValue;
  final List<ModernDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? errorText;
  final double height;

  const ModernDropdownSelector({
    super.key,
    required this.label,
    this.placeholder,
    this.selectedValue,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.height = ModernSizes.buttonHeight,
  });

  @override
  State<ModernDropdownSelector<T>> createState() => _ModernDropdownSelectorState<T>();
}

class _ModernDropdownSelectorState<T> extends State<ModernDropdownSelector<T>> {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _toggleDropdown() {
    if (!widget.enabled || widget.onChanged == null) return;

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + spacing_xs,
              width: size.width,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(radius_md),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: ModernColors.lightBackground,
                    borderRadius: BorderRadius.circular(radius_md),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: ModernColors.borderColor,
                    ),
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = item.value == widget.selectedValue;

                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onChanged!(item.value);
                          _removeOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: spacing_md,
                            vertical: spacing_md,
                          ),
                          child: Row(
                            children: [
                              if (item.icon != null) ...[
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: item.color ?? ModernColors.textPrimary,
                                ),
                                const SizedBox(width: spacing_sm),
                              ],
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: ModernTypography.bodyLarge.copyWith(
                                    color: isSelected
                                        ? ModernColors.accentGreen
                                        : ModernColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  size: 20,
                                  color: ModernColors.accentGreen,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  String _getDisplayText() {
    if (widget.selectedValue == null) {
      return widget.placeholder ?? 'Select ${widget.label.toLowerCase()}';
    }

    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.selectedValue,
      orElse: () => ModernDropdownItem(value: widget.selectedValue as T, label: widget.selectedValue.toString()),
    );

    return selectedItem.label;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          enabled: widget.enabled,
          label: '${widget.label}: ${_getDisplayText()}',
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: spacing_md),
              decoration: BoxDecoration(
                color: ModernColors.primaryGray,
                borderRadius: BorderRadius.circular(radius_md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: ModernColors.textSecondary,
                  ),
                  const SizedBox(width: spacing_sm),
                  Text(
                    widget.label,
                    style: ModernTypography.labelMedium.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: spacing_sm),
                  Expanded(
                    child: Text(
                      _getDisplayText(),
                      style: ModernTypography.bodyLarge.copyWith(
                        color: widget.selectedValue != null
                            ? ModernColors.textPrimary
                            : ModernColors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: ModernColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: spacing_xs),
          Text(
            widget.errorText!,
            style: ModernTypography.labelMedium.copyWith(
              color: ModernColors.error,
            ),
          ),
        ],
      ],
    );
  }
}