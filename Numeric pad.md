import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../form_design_system.dart';

/// Custom Numeric Keyboard matching the FormDesign screenshots
class CustomNumericKeyboard extends StatelessWidget {
  const CustomNumericKeyboard({
    super.key,
    required this.onKeyPressed,
    this.showDot = true,
  });

  final Function(String) onKeyPressed;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FormDesignSystem.spacing16),
      decoration: const BoxDecoration(
        color: FormDesignSystem.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 1, 2, 3
          Row(
            children: [
              _buildKey('1'),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildKey('2'),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildKey('3'),
            ],
          ),
          const SizedBox(height: FormDesignSystem.spacing12),

          // Row 2: 4, 5, 6
          Row(
            children: [
              _buildKey('4'),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildKey('5'),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildKey('6'),
            ],
          ),
          const SizedBox(height: FormDesignSystem.spacing12),

          // Row 3: 7, 8, 9
          Row(
            children: [
              _buildKey('7'),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildKey('8'),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildKey('9'),
            ],
          ),
          const SizedBox(height: FormDesignSystem.spacing12),

          // Row 4: ., 0, backspace
          Row(
            children: [
              showDot
                  ? _buildKey('.')
                  : _buildEmptyKey(),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildKey('0'),
              const SizedBox(width: FormDesignSystem.spacing12),
              _buildBackspaceKey(),
            ],
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return Expanded(
      child: _KeyButton(
        value: value,
        onPressed: () {
          HapticFeedback.lightImpact();
          onKeyPressed(value);
        },
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Expanded(
      child: _KeyButton(
        value: 'backspace',
        icon: Icons.backspace,
        onPressed: () {
          HapticFeedback.lightImpact();
          onKeyPressed('backspace');
        },
      ),
    );
  }

  Widget _buildEmptyKey() {
    return const Expanded(child: SizedBox(height: 56));
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    required this.value,
    required this.onPressed,
    this.icon,
  });

  final String value;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: FormDesignSystem.surfaceWhite,
                borderRadius: BorderRadius.circular(FormDesignSystem.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: widget.icon != null
                    ? Icon(
                        widget.icon,
                        color: FormDesignSystem.primaryDark,
                        size: 24,
                      )
                    : Text(
                        widget.value,
                        style: FormDesignSystem.titleStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'design_tokens.dart';
import 'color_tokens.dart';
import 'typography_tokens.dart';

/// Comprehensive Form Design System based on FormDesign screenshots
class FormDesignSystem {
  FormDesignSystem._();

  // Color palette from design system profile
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color backgroundLight = Color(0xFFF2F4F6);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color errorColor = Color(0xFFEF4444);

  // Typography scales
  static const TextStyle currencyStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: primaryDark,
    letterSpacing: -1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: primaryDark,
    letterSpacing: -0.8,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryDark,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.4,
  );

  // Spacing system
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Component dimensions
  static const double buttonHeight = 56.0;
  static const double fieldPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double categoryButtonSize = 64.0;
  static const double iconSize = 20.0;

  // Animation durations
  static const Duration quickAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 350);

  // Form patterns
  static BoxDecoration get fieldDecoration => BoxDecoration(
    color: surfaceWhite,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: borderLight, width: 1.5),
  );

  static BoxDecoration get focusedFieldDecoration => BoxDecoration(
    color: surfaceWhite,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: primaryTeal, width: 2),
    boxShadow: [
      BoxShadow(
        color: primaryTeal.withOpacity(0.15),
        blurRadius: 8,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: primaryDark,
    borderRadius: BorderRadius.circular(borderRadius),
  );

  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
    color: const Color(0xFFF1F5F9),
    borderRadius: BorderRadius.circular(borderRadius),
  );

  // Category colors (from design profile)
  static const Map<String, Color> categoryColors = {
    'Business': Color(0xFF14B8A6),
    'Salary': Color(0xFF0F172A),
    'Property': Color(0xFFF97316),
    'Interest': Color(0xFF3B82F6),
    'Freelance': Color(0xFFEC4899),
    'Scholarship': Color(0xFF8B5CF6),
    'General': Color(0xFF14B8A6),
    'Food': Color(0xFFF97316),
    'Party': Color(0xFF8B5CF6),
    'Charity': Color(0xFFEC4899),
    'Movies': Color(0xFF0F172A),
    'Shopping': Color(0xFF3B82F6),
  };
}

/// Modern Switch Toggle Component matching the design
class ModernSwitchToggle extends StatelessWidget {
  const ModernSwitchToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 40,
  });

  final List<String> options;
  final int selectedIndex;
  final Function(int) onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: FormDesignSystem.normalAnimation,
                curve: Curves.easeOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? FormDesignSystem.primaryTeal
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular((height - 8) / 2),
                ),
                child: Center(
                  child: Text(
                    options[index],
                    style: FormDesignSystem.bodyStyle.copyWith(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Large Amount Input Field
class AmountInputField extends StatefulWidget {
  const AmountInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.currencySymbol = '\$',
    this.enabled = true,
  });

  final TextEditingController controller;
  final Function(String) onChanged;
  final String currencySymbol;
  final bool enabled;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FormDesignSystem.spacing24,
        vertical: FormDesignSystem.spacing16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(FormDesignSystem.borderRadius),
        border: Border.all(
          color: _isFocused
              ? FormDesignSystem.primaryTeal
              : FormDesignSystem.borderLight,
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.currencySymbol,
            style: FormDesignSystem.currencyStyle.copyWith(
              color: FormDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              style: FormDesignSystem.currencyStyle,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: FormDesignSystem.currencyStyle,
              ),
              onChanged: widget.onChanged,
              enabled: widget.enabled,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Selection Grid
class CategorySelectionGrid extends StatelessWidget {
  const CategorySelectionGrid({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<CategoryItem> categories;
  final String? selectedCategory;
  final Function(CategoryItem) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: FormDesignSystem.spacing16,
        ),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.name == selectedCategory;

          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: AnimatedContainer(
              duration: FormDesignSystem.normalAnimation,
              curve: Curves.easeOut,
              width: FormDesignSystem.categoryButtonSize,
              decoration: BoxDecoration(
                color: isSelected
                    ? category.color
                    : category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FormDesignSystem.borderRadius),
                border: isSelected
                    ? Border.all(color: category.color, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? Colors.white : category.color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: FormDesignSystem.captionStyle.copyWith(
                      color: isSelected ? Colors.white : category.color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Modern Text Field
class ModernTextField extends StatefulWidget {
  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final bool obscureText;

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: FormDesignSystem.normalAnimation,
      decoration: _isFocused
          ? FormDesignSystem.focusedFieldDecoration
          : FormDesignSystem.fieldDecoration,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: FormDesignSystem.bodyStyle,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: _isFocused
                      ? FormDesignSystem.primaryTeal
                      : FormDesignSystem.textSecondary,
                  size: FormDesignSystem.iconSize,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(FormDesignSystem.fieldPadding),
          labelStyle: FormDesignSystem.bodyStyle.copyWith(
            color: _isFocused
                ? FormDesignSystem.primaryTeal
                : FormDesignSystem.textSecondary,
          ),
          hintStyle: FormDesignSystem.bodyStyle.copyWith(
            color: FormDesignSystem.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Primary Action Button
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: FormDesignSystem.buttonHeight,
      decoration: FormDesignSystem.primaryButtonDecoration.copyWith(
        color: enabled
            ? FormDesignSystem.primaryDark
            : FormDesignSystem.primaryDark.withOpacity(0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(FormDesignSystem.borderRadius),
          onTap: enabled && !isLoading ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: FormDesignSystem.bodyStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Data classes
class CategoryItem {
  final String name;
  final Color color;
  final IconData icon;

  const CategoryItem({
    required this.name,
    required this.color,
    required this.icon,
  });
}

/// Date Time Picker Buttons
class DateTimePickerButtons extends StatelessWidget {
  const DateTimePickerButtons({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateTimeButton(
            icon: Icons.calendar_today,
            label: 'Today',
            value: _formatDate(selectedDate),
            onTap: () => _selectDate(context),
          ),
        ),
        const SizedBox(width: FormDesignSystem.spacing12),
        Expanded(
          child: _DateTimeButton(
            icon: Icons.access_time,
            label: 'Time',
            value: _formatTime(selectedTime),
            onTap: () => _selectTime(context),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      onDateSelected(date);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      onTimeSelected(time);
    }
  }

  String _formatDate(DateTime date) {
    if (DateTime.now().difference(date).inDays == 0) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FormDesignSystem.spacing16),
        decoration: FormDesignSystem.secondaryButtonDecoration,
        child: Row(
          children: [
            Icon(
              icon,
              color: FormDesignSystem.textSecondary,
              size: FormDesignSystem.iconSize,
            ),
            const SizedBox(width: FormDesignSystem.spacing8),
            Text(
              value,
              style: FormDesignSystem.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}