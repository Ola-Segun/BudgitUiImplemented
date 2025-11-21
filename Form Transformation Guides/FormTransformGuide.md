
Comprehensive UI Transformation Guide for Form Components
Executive Summary
This guide transforms the existing verbose, traditional form layouts into a modern, compact, and minimalist design system inspired by the reference images. The new system prioritizes visual hierarchy, intelligent spacing, micro-interactions, and reusable components while maintaining all existing functionality.

Core Design Principles Extracted from Reference Images
1. Visual Language
Minimalist Aesthetic: Clean, uncluttered interfaces with ample breathing room
Soft Geometry: Rounded corners (12-20px radius) for all interactive elements
Elevated Cards: Subtle shadows for depth and hierarchy
Color Psychology:
Primary accent: Vibrant teal/mint green (
#00D09C, 
#14B8A6)
Gradients for important CTAs
Semantic colors (red for expenses, green for income)
Neutral grays for secondary content
2. Typography Hierarchy
Primary Headers: 24-28px, bold (600-700 weight)
Section Headers: 16-18px, semi-bold (600 weight)
Body Text: 14-15px, regular (400-500 weight)
Captions/Metadata: 12-13px, regular, muted color
Limited font weights: Only 400, 500, 600, 700
3. Spacing System
Compact Vertical Rhythm: 12px base unit
Tiny: 4px
Small: 8px
Medium: 12-16px
Large: 20-24px
XLarge: 32px+
Horizontal Padding: Consistent 16-20px screen margins
Element Spacing: Tight grouping (8-12px) for related items, 20-24px for sections
4. Component Architecture
Input Fields (Transformed)
FROM: Traditional full-width stacked fields with labels above
TO: Compact inline labels with modern styling

Old Pattern:
┌─────────────────────────────────┐
│ Label                           │
│ ┌─────────────────────────────┐ │
│ │ Input field                 │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘

New Pattern (Compact):
┌──────────────────────────────────┐
│ 💰  Amount          │ $0.00      │
│     Small hint text │ [value]    │
└──────────────────────────────────┘

Key Changes:
- Icon prefix for context (20px, colored)
- Inline label with input
- Reduced height (44-48px vs 60-72px)
- Background: subtle gray (#F5F5F7)
- No visible borders (only focus state)
- Placeholder text as hint
Segmented Controls (Type Selectors)
Reference: Image 2 (All/Incomes/Spends tabs)

Old Pattern:
┌─────────────────────────────────┐
│ ○ Expense    ○ Income           │
└─────────────────────────────────┘

New Pattern:
┌──────────────────────────────────┐
│  Expense  │  Income             │
│  (dark)   │  (selected: mint)   │
└──────────────────────────────────┘

Specifications:
- Container: Light gray background, pill shape
- Height: 40-44px
- Selected: White background, shadow, colored text
- Unselected: Transparent, gray text
- Smooth transition (200ms ease)
- Haptic feedback on selection
Category Selectors
Reference: Image 3 (Category management icons)

Old Pattern: Dropdown with text list

New Pattern: Horizontal scrollable icon grid
┌──────────────────────────────────┐
│ 🍕 🎉 💖 🛍️ 🎬 🏢            →│
│ Food Party Love Shop Movie      │
└──────────────────────────────────┘

Specifications:
- Icon size: 24px in 48px container
- Background: Colored circle (category-specific)
- Selected state: Ring border, scale 1.05
- Horizontal scroll with snap points
- 3-4 visible at once, 8px gap
Date/Time Pickers
Reference: Image 4 (Duration selector with horizontal number scroll)

Old Pattern: Native picker dialog

New Pattern: Inline compact selector
┌──────────────────────────────────┐
│ 📅  Jan 15, 2025    [▼]         │
└──────────────────────────────────┘

Or horizontal scroll:
┌──────────────────────────────────┐
│ 1  2  3  4  5  [6]  7  8  9  10 │
│        Days Months Years         │
└──────────────────────────────────┘

Specifications:
- Calendar icon prefix
- Formatted date display
- Chevron for expansion
- Bottom sheet with horizontal number picker
- Selected: Dark background, white text
Action Buttons
Reference: Image 9 (Primary CTAs with gradients)

Primary Button (Gradient):
┌──────────────────────────────────┐
│        Add Transaction    +      │
│   (mint→teal gradient, shadow)   │
└──────────────────────────────────┘

Secondary Button (Outlined):
┌──────────────────────────────────┐
│           Cancel                 │
│     (gray border, no fill)       │
└──────────────────────────────────┘

Specifications:
- Height: 52-56px
- Border radius: 16px
- Primary: Gradient + shadow
- Secondary: 1.5px border
- Icon spacing: 8px from text
- Haptic feedback on press
Transformation Implementation Plan
Phase 1: Foundation Components
1.1 Enhanced Text Field Widget
dart
// Replace all TextFormField instances with:
class CompactTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final Color? iconColor;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  
  // Design specifications
  static const double _height = 48.0;
  static const double _borderRadius = 12.0;
  static const Color _backgroundColor = Color(0xFFF5F5F7);
  static const double _iconSize = 20.0;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: _iconSize, color: iconColor ?? ColorTokens.textSecondary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TypographyTokens.captionMd.copyWith(
                    color: ColorTokens.textSecondary,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  onChanged: onChanged,
                  style: TypographyTokens.bodyMd.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
1.2 Segmented Control Widget
dart
class CompactSegmentedControl<T> extends StatelessWidget {
  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: options.map((option) {
          final isSelected = option.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(option.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (option.icon != null) ...[
                      Icon(
                        option.icon,
                        size: 18,
                        color: isSelected ? option.color : ColorTokens.textSecondary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option.label,
                      style: TypographyTokens.labelMd.copyWith(
                        color: isSelected ? option.color : ColorTokens.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
1.3 Icon Category Selector
dart
class HorizontalCategorySelector extends StatelessWidget {
  final List<TransactionCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TypographyTokens.labelMd.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == selectedId;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged(category.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(category.color).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(
                            color: Color(category.color),
                            width: 2.5,
                          ) : null,
                        ),
                        child: Center(
                          child: Icon(
                            categoryIconService.getIconForCategory(category.id),
                            size: 24,
                            color: Color(category.color),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        style: TypographyTokens.captionSm.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? ColorTokens.textPrimary : ColorTokens.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
1.4 Compact Date Picker
dart
class CompactDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final date = await showModalBottomSheet<DateTime>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => _CompactDatePickerSheet(
            initialDate: selectedDate,
          ),
        );
        if (date != null) onChanged(date);
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: ColorTokens.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TypographyTokens.captionMd.copyWith(
                      fontSize: 11,
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: TypographyTokens.bodyMd.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: ColorTokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
1.5 Gradient Button
dart
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  
  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return _buildSecondaryButton();
    }
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading
            ? ColorTokens.gradientPrimary
            : null,
        color: onPressed == null || isLoading 
            ? ColorTokens.surfaceSecondary 
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null && !isLoading ? [
          BoxShadow(
            color: ColorTokens.teal500.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed != null && !isLoading ? () {
            HapticFeedback.mediumImpact();
            onPressed!();
          } : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TypographyTokens.labelLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSecondaryButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorTokens.borderPrimary,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: TypographyTokens.labelLg.copyWith(
                color: ColorTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
Phase 2: Form-Specific Transformations
2.1 Transaction Form Transformation
Before:

dart
// Verbose vertical stacking
Column(
  children: [
    TextFormField(labelText: 'Amount'),
    SizedBox(height: 16),
    TextFormField(labelText: 'Title'),
    SizedBox(height: 16),
    DropdownButtonFormField(labelText: 'Category'),
    // ... continues
  ],
)
After:

dart
class CompactTransactionForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type selector (compact)
        CompactSegmentedControl<TransactionType>(
          options: [
            SegmentOption(
              value: TransactionType.expense,
              label: 'Expense',
              icon: Icons.remove_circle_outline,
              color: ColorTokens.critical500,
            ),
            SegmentOption(
              value: TransactionType.income,
              label: 'Income',
              icon: Icons.add_circle_outline,
              color: ColorTokens.success500,
            ),
          ],
          selected: _selectedType,
          onChanged: (type) => setState(() => _selectedType = type),
        ),
        
        const SizedBox(height: 20),
        
        // Amount (compact inline)
        CompactTextField(
          label: 'Amount',
          hint: '0.00',
          icon: Icons.attach_money,
          iconColor: ColorTokens.teal500,
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        
        const SizedBox(height: 12),
        
        // Category (horizontal scroll)
        HorizontalCategorySelector(
          categories: categories,
          selectedId: _selectedCategoryId,
          onChanged: (id) => setState(() => _selectedCategoryId = id),
        ),
        
        const SizedBox(height: 12),
        
        // Account (compact inline)
        CompactTextField(
          label: 'Account',
          hint: 'Select account',
          icon: Icons.account_balance_wallet,
          iconColor: ColorTokens.textSecondary,
          // ... dropdown logic
        ),
        
        const SizedBox(height: 12),
        
        // Date (compact inline)
        CompactDatePicker(
          selectedDate: _selectedDate,
          onChanged: (date) => setState(() => _selectedDate = date),
        ),
        
        const SizedBox(height: 24),
        
        // CTA (gradient button)
        GradientButton(
          label: 'Add Transaction',
          icon: Icons.add,
          onPressed: _submitTransaction,
          isLoading: _isSubmitting,
        ),
      ],
    );
  }
}
2.2 Bill Form Transformation
Key Changes:

Replace dropdown with horizontal icon scroll for frequency
Combine amount + frequency in a two-column layout
Use compact date picker for start/end dates
Replace switch with a modern toggle pill
Implementation:

dart
// Frequency + Amount row
Row(
  children: [
    Expanded(
      flex: 3,
      child: CompactTextField(
        label: 'Amount',
        hint: '0.00',
        icon: Icons.attach_money,
        controller: _amountController,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      flex: 2,
      child: _FrequencySelector(
        selected: _selectedFrequency,
        onChanged: (freq) => setState(() => _selectedFrequency = freq),
      ),
    ),
  ],
),

// Frequency selector as compact chip
class _FrequencySelector extends StatelessWidget {
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showFrequencySheet,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Frequency', style: captionStyle),
                Text(_selectedFrequency.displayName, style: bodyStyle),
              ],
            ),
            Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
2.3 Goal Form Transformation
Key Changes:

Replace target amount with a visual progress indicator input
Use horizontal priority selector (Low/Medium/High chips)
Category as horizontal scroll icons
Compact date range picker
Implementation:

dart
// Priority selector (chip style)
class PrioritySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: labelStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            _PriorityChip(
              label: 'Low',
              color: ColorTokens.success500,
              isSelected: _selectedPriority == GoalPriority.low,
              onTap: () => _updatePriority(GoalPriority.low),
            ),
            const SizedBox(width: 8),
            _PriorityChip(
              label: 'Medium',
              color: ColorTokens.warning500,
              isSelected: _selectedPriority == GoalPriority.medium,
              onTap: () => _updatePriority(GoalPriority.medium),
            ),
            const SizedBox(width: 8),
            _PriorityChip(
              label: 'High',
              color: ColorTokens.critical500,
              isSelected: _selectedPriority == GoalPriority.high,
              onTap: () => _updatePriority(GoalPriority.high),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Text(
          label,
          style: TypographyTokens.labelMd.copyWith(
            color: isSelected ? color : ColorTokens.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
Phase 3: Optional Fields Pattern
Reference: Images show a clean "Show More" pattern

Implementation:

dart
class OptionalFieldsToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isExpanded ? 'Hide optional fields' : 'Show optional fields',
              style: TypographyTokens.labelMd.copyWith(
                color: ColorTokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: ColorTokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Usage in forms
Column(
  children: [
    // Required fields
    CompactTextField(...),
    CompactTextField(...),
    
    const SizedBox(height: 16),
    
    OptionalFieldsToggle(
      isExpanded: _showOptionalFields,
      onToggle: () => setState(() => _showOptionalFields = !_showOptionalFields),
    ),
    
    if (_showOptionalFields) ...[
      const SizedBox(height: 16),
      CompactTextField(label: 'Description (optional)'),
      CompactTextField(label: 'Notes (optional)'),
    ],
  ],
)
Phase 4: Bottom Sheet Modal Pattern
Reference: Image 1, 4 (Compact bottom sheets with drag handle)

Implementation:

dart
class CompactBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
    List<Widget>? actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompactBottomSheet(
        title: title,
        subtitle: subtitle,
        child: child,
        actions: actions,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: ColorTokens.borderSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              children: [
                Text(
                  title,
                  style: TypographyTokens.heading5.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: child,
            ),
          ),
          
          // Actions
          if (actions != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
Phase 5: Validation & Error States
Pattern from Images: Subtle inline errors, no disruptive alerts

Implementation:

dart
class CompactTextField extends StatefulWidget {
  // ... previous properties
  final String? Function(String?)? asyncValidator;
  
  @override
  State<CompactTextField> createState() => _CompactTextFieldState();
}

class _CompactTextFieldState extends State<CompactTextField> {
  String? _errorMessage;
  bool _isValidating = false;
  
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: _errorMessage != null 
                ? ColorTokens.critical500.withOpacity(0.05)
                : ColorTokens.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: _errorMessage != null 
                ? Border.all(color: ColorTokens.critical500, width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // ... icon and input
              
              if (_isValidating)
                SizedBox(
                  width:
Continue

dart
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.textSecondary),
                  ),
                )
              else if (_errorMessage != null)
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: ColorTokens.critical500,
                ),
            ],
          ),
        ),
        
        // Inline error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: ColorTokens.critical500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TypographyTokens.captionSm.copyWith(
                      color: ColorTokens.critical500,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
Phase 6: Animation & Micro-interactions
Key Principles from Images:

Smooth transitions (200-300ms)
Scale effects on selection (1.0 → 1.05)
Fade-in animations for content
Haptic feedback on interactions
Implementation:

dart
class AnimationConfig {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  
  static const Curve defaultCurve = Curves.easeOut;
  static const Curve elasticCurve = Curves.elasticOut;
}

// Example: Animated category selection
class _CategoryIcon extends StatefulWidget {
  @override
  State<_CategoryIcon> createState() => _CategoryIconState();
}

class _CategoryIconState extends State<_CategoryIcon> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConfig.normal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }
  
  @override
  void didUpdateWidget(_CategoryIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: AnimationConfig.normal,
          curve: AnimationConfig.defaultCurve,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Color(widget.category.color).withOpacity(0.15),
            shape: BoxShape.circle,
            border: widget.isSelected
                ? Border.all(
                    color: Color(widget.category.color),
                    width: 2.5,
                  )
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Color(widget.category.color).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.category.icon,
            size: 24,
            color: Color(widget.category.color),
          ),
        ),
      ),
    );
  }
}
Phase 7: Spacing System Implementation
Reference: Images show consistent, tight spacing

dart
class FormSpacing {
  // Vertical spacing between elements
  static const double fieldGap = 12.0;        // Between form fields
  static const double sectionGap = 20.0;      // Between sections
  static const double groupGap = 8.0;         // Within grouped items
  static const double contentPadding = 24.0;  // Screen edges
  
  // Horizontal spacing
  static const double iconGap = 12.0;         // Icon to text
  static const double buttonGap = 12.0;       // Between buttons
  
  // Component internal spacing
  static const double inputPaddingH = 16.0;
  static const double inputPaddingV = 12.0;
}

// Apply consistently across all forms
class FormLayout extends StatelessWidget {
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FormSpacing.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) 
              const SizedBox(height: FormSpacing.fieldGap),
          ],
        ],
      ),
    );
  }
}
Phase 8: Complete Form Examples
Example 1: Add Transaction Form (Complete)
dart
class CompactAddTransactionForm extends StatefulWidget {
  const CompactAddTransactionForm({super.key});
  
  @override
  State<CompactAddTransactionForm> createState() => 
      _CompactAddTransactionFormState();
}

class _CompactAddTransactionFormState 
    extends State<CompactAddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  String? _accountId;
  DateTime _date = DateTime.now();
  bool _showOptional = false;
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Transaction Type
          CompactSegmentedControl<TransactionType>(
            options: [
              SegmentOption(
                value: TransactionType.expense,
                label: 'Expense',
                icon: Icons.remove_circle_outline,
                color: ColorTokens.critical500,
              ),
              SegmentOption(
                value: TransactionType.income,
                label: 'Income',
                icon: Icons.add_circle_outline,
                color: ColorTokens.success500,
              ),
            ],
            selected: _type,
            onChanged: (type) => setState(() => _type = type),
          ),
          
          const SizedBox(height: FormSpacing.sectionGap),
          
          // Amount
          CompactTextField(
            label: 'Amount',
            hint: '0.00',
            icon: Icons.attach_money,
            iconColor: ColorTokens.teal500,
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Invalid amount';
              }
              return null;
            },
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Category (horizontal scroll)
          Consumer(
            builder: (context, ref, _) {
              final categories = ref.watch(categoryNotifierProvider);
              return categories.when(
                data: (state) => HorizontalCategorySelector(
                  categories: state.getCategoriesByType(_type),
                  selectedId: _categoryId,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Account
          Consumer(
            builder: (context, ref, _) {
              final accounts = ref.watch(filteredAccountsProvider);
              return accounts.when(
                data: (accts) => CompactDropdown<String>(
                  label: 'Account',
                  icon: Icons.account_balance_wallet,
                  value: _accountId,
                  items: accts.map((a) => DropdownItem(
                    value: a.id,
                    label: a.displayName,
                    subtitle: a.formattedBalance,
                  )).toList(),
                  onChanged: (id) => setState(() => _accountId = id),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Date
          CompactDatePicker(
            selectedDate: _date,
            onChanged: (date) => setState(() => _date = date),
          ),
          
          const SizedBox(height: FormSpacing.sectionGap),
          
          // Optional Fields Toggle
          OptionalFieldsToggle(
            isExpanded: _showOptional,
            onToggle: () => setState(() => _showOptional = !_showOptional),
          ),
          
          if (_showOptional) ...[
            const SizedBox(height: FormSpacing.fieldGap),
            
            CompactTextField(
              label: 'Title',
              hint: 'e.g., Grocery shopping',
              icon: Icons.text_fields,
              controller: _titleController,
            ),
            
            const SizedBox(height: FormSpacing.fieldGap),
            
            CompactTextField(
              label: 'Description',
              hint: 'Optional notes',
              icon: Icons.notes,
              maxLines: 2,
            ),
          ],
          
          const SizedBox(height: FormSpacing.sectionGap * 1.5),
          
          // Submit Button
          GradientButton(
            label: 'Add Transaction',
            icon: Icons.add_rounded,
            onPressed: _submit,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null || _accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select category and account')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    // Submit logic...
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
    }
  }
}
Example 2: Bill Form (Complete)
dart
class CompactBillForm extends StatefulWidget {
  const CompactBillForm({super.key});
  
  @override
  State<CompactBillForm> createState() => _CompactBillFormState();
}

class _CompactBillFormState extends State<CompactBillForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  BillFrequency _frequency = BillFrequency.monthly;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  String? _categoryId;
  String? _accountId;
  bool _isAutoPay = false;
  bool _showOptional = false;
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name
          CompactTextField(
            label: 'Bill Name',
            hint: 'e.g., Electricity',
            icon: Icons.receipt_long,
            iconColor: ColorTokens.teal500,
            controller: _nameController,
            validator: (v) => v?.isEmpty ?? true ? 'Enter bill name' : null,
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Amount + Frequency Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CompactTextField(
                  label: 'Amount',
                  hint: '0.00',
                  icon: Icons.attach_money,
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    final amount = double.tryParse(v!);
                    if (amount == null || amount <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: FormSpacing.buttonGap),
              Expanded(
                flex: 2,
                child: _FrequencySelector(
                  selected: _frequency,
                  onChanged: (f) => setState(() => _frequency = f),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Category
          Consumer(
            builder: (context, ref, _) {
              final categories = ref.watch(categoryNotifierProvider);
              return categories.when(
                data: (state) => HorizontalCategorySelector(
                  categories: state.getCategoriesByType(
                    TransactionType.expense,
                  ),
                  selectedId: _categoryId,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Account
          Consumer(
            builder: (context, ref, _) {
              final accounts = ref.watch(filteredAccountsProvider);
              return accounts.when(
                data: (accts) => CompactDropdown<String>(
                  label: 'Payment Account',
                  icon: Icons.account_balance_wallet,
                  value: _accountId,
                  items: [
                    DropdownItem(
                      value: null,
                      label: 'No default account',
                    ),
                    ...accts.map((a) => DropdownItem(
                      value: a.id,
                      label: a.displayName,
                      subtitle: a.formattedBalance,
                    )),
                  ],
                  onChanged: (id) => setState(() => _accountId = id),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Due Date
          CompactDatePicker(
            selectedDate: _dueDate,
            onChanged: (date) => setState(() => _dueDate = date),
          ),
          
          const SizedBox(height: FormSpacing.sectionGap),
          
          // Auto Pay Toggle
          CompactToggle(
            label: 'Auto Pay',
            subtitle: 'Automatically pay when due',
            value: _isAutoPay,
            onChanged: (v) => setState(() => _isAutoPay = v),
          ),
          
          const SizedBox(height: FormSpacing.fieldGap),
          
          // Optional Fields
          OptionalFieldsToggle(
            isExpanded: _showOptional,
            onToggle: () => setState(() => _showOptional = !_showOptional),
          ),
          
          if (_showOptional) ...[
            const SizedBox(height: FormSpacing.fieldGap),
            
            CompactTextField(
              label: 'Payee',
              hint: 'Optional',
              icon: Icons.business,
            ),
            
            const SizedBox(height: FormSpacing.fieldGap),
            
            CompactTextField(
              label: 'Notes',
              hint: 'Additional details',
              icon: Icons.notes,
              maxLines: 2,
            ),
          ],
          
          const SizedBox(height: FormSpacing.sectionGap * 1.5),
          
          // Submit
          GradientButton(
            label: 'Add Bill',
            icon: Icons.add_rounded,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Submit logic...
  }
}

// Frequency selector component
class _FrequencySelector extends StatelessWidget {
  final BillFrequency selected;
  final ValueChanged<BillFrequency> onChanged;
  
  const _FrequencySelector({
    required this.selected,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFrequencySheet(context),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequency',
              style: TypographyTokens.captionMd.copyWith(
                fontSize: 11,
                color: ColorTokens.textSecondary,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selected.displayName,
                    style: TypographyTokens.bodyMd.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: ColorTokens.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFrequencySheet(BuildContext context) {
    CompactBottomSheet.show(
      context: context,
      title: 'Bill Frequency',
      child: Column(
        children: BillFrequency.values.map((freq) {
          final isSelected = freq == selected;
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(freq);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorTokens.borderSecondary,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      freq.displayName,
                      style: TypographyTokens.bodyLg.copyWith(
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w400,
                        color: isSelected 
                            ? ColorTokens.teal500 
                            : ColorTokens.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      color: ColorTokens.teal500,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
Phase 9: Compact Toggle Component
Reference: Modern toggle switches in images

dart
class CompactToggle extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  
  const CompactToggle({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value 
              ? ColorTokens.teal500.withOpacity(0.08)
              : ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: value
              ? Border.all(
                  color: ColorTokens.teal500.withOpacity(0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: value
                      ? ColorTokens.teal500.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: value 
                      ? ColorTokens.teal500 
                      : ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TypographyTokens.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ColorTokens.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: value ? ColorTokens.teal500 : ColorTokens.borderPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Phase 10: Compact Dropdown Component
dart
class CompactDropdown<T> extends StatelessWidget {
  final String label;
  final IconData? icon;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  
  const CompactDropdown({
    super.key,
    required this.label,
    this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => items.first,
    );
    
    return GestureDetector(
      onTap: () => _showSelectionSheet(context),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: ColorTokens.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: ColorTokens.textSecondary,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TypographyTokens.captionMd.copyWith(
                      fontSize: 11,
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedItem.label,
                          style: TypographyTokens.bodyMd.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectedItem.subtitle != null)
                        Flexible(
                          child: Text(
                            ' • ${selectedItem.subtitle}',
                            style: TypographyTokens.captionSm.copyWith(
                              fontSize: 12,
                              color: ColorTokens.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: ColorTokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSelectionSheet(BuildContext context) {
    CompactBottomSheet.show(
      context: context,
      title: 'Select $label',
      child: Column(
        children: items.map((item) {
          final isSelected = item.value == value;
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(item.value);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorTokens.borderSecondary,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TypographyTokens.bodyLg.copyWith(
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                            color: isSelected 
                                ? ColorTokens.teal500 
                                : ColorTokens.textPrimary,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: TypographyTokens.captionMd.copyWith(
                              color: ColorTokens.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: ColorTokens.teal500,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DropdownItem<T> {
  final T? value;
  final String label;
  final String? subtitle;
  
  const DropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
  });
}
Implementation Checklist
✅ Phase 1: Foundation (Week 1)
 Create CompactTextField widget
 Create CompactSegmentedControl widget
 Create HorizontalCategorySelector widget
 Create CompactDatePicker widget
 Create GradientButton widget
 Test all components in isolation
✅ Phase 2: Advanced Components (Week 2)
 Create CompactDropdown widget
 Create CompactToggle widget
 Create OptionalFieldsToggle widget
 Create CompactBottomSheet wrapper
 Implement animation system
 Add haptic feedback
✅ Phase 3: Form Transformations (Week 3)
 Transform AddTransactionBottomSheet
 Transform BillCreationScreen
 Transform GoalCreationScreen
 Transform RecurringIncomeCreationScreen
 Transform EditBillBottomSheet
 Transform TransferForm
✅ Phase 4: Validation & Polish (Week 4)
 Implement async validation
 Add error state animations
 Test keyboard interactions
 Test accessibility
 Performance optimization
 Documentation
Key Metrics for Success
Reduced Form Height: 30-40% reduction in vertical space
Reduced Tap Distance: 25% reduction in user travel
Improved Completion Time: 20% faster form submission
Visual Consistency: 100% adherence to design system
Code Reusability: 80%+ component reuse across forms
Final Notes for AI Copilot
Critical Dos:
✅ Always use haptic feedback on interactions
✅ Maintain 48px minimum touch targets
✅ Use consistent spacing (12px base unit)
✅ Apply smooth animations (200-300ms)
✅ Keep forms scrollable

