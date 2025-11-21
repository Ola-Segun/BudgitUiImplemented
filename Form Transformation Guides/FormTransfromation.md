
Comprehensive UI Transformation Guide for Form Components
Executive Summary
This guide provides a complete blueprint for transforming the existing Flutter form components to match the modern, clean aesthetic shown in the reference images. The transformation focuses on creating a cohesive, reusable design system with consistent spacing, typography, colors, and interaction patterns.

1. Core Design Principles Extracted from Images
1.1 Visual Hierarchy
Large, prominent amount displays - Center-aligned, gray background pill
Icon-driven category selection - Colorful rounded square icons with labels
Minimal text input decoration - Clean borders, ample padding
Bottom-anchored CTAs - Dark rounded buttons with clear actions
Sheet-style overlays - Rounded top corners, drag handle indicator
1.2 Spacing System
dart
// Extracted spacing values
const double spacing_xs = 4.0;
const double spacing_sm = 8.0;
const double spacing_md = 16.0;
const double spacing_lg = 24.0;
const double spacing_xl = 32.0;

// Component-specific
const double categoryIconSize = 56.0;
const double categoryIconRadius = 16.0;
const double buttonHeight = 56.0;
const double inputFieldHeight = 56.0;
1.3 Color Palette
dart
// Primary colors from images
const Color primaryBlack = Color(0xFF1A1A1A);
const Color primaryGray = Color(0xFFF5F5F5);
const Color accentGreen = Color(0xFF00D09C);
const Color textPrimary = Color(0xFF1A1A1A);
const Color textSecondary = Color(0xFF8E8E93);
const Color borderColor = Color(0xFFE5E5EA);

// Category colors (vibrant, distinct)
const Color categoryGreen = Color(0xFF00D09C);
const Color categoryBlack = Color(0xFF1A1A1A);
const Color categoryOrange = Color(0xFFFF6B2C);
const Color categoryBlue = Color(0xFF007AFF);
const Color categoryPink = Color(0xFFFF2D92);
const Color categoryPurple = Color(0xFF5E5CE6);
1.4 Typography System
dart
// Extracted from images
const TextStyle displayLarge = TextStyle(
  fontSize: 48,
  fontWeight: FontWeight.w600,
  letterSpacing: -1.0,
);

const TextStyle titleLarge = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
);

const TextStyle bodyLarge = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.4,
);

const TextStyle labelMedium = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  letterSpacing: -0.2,
);
1.5 Border Radius System
dart
const double radius_sm = 8.0;
const double radius_md = 12.0;
const double radius_lg = 16.0;
const double radius_xl = 24.0;
const double radius_pill = 999.0;
2. Reusable Component Library
2.1 ModernAmountDisplay Widget
Purpose: Large, prominent amount display with gray pill background

Design Specs:

Center-aligned
Large font size (48-56pt)
Gray background (
#F5F5F5)
Pill-shaped (999px border radius)
Generous padding (24px vertical, 48px horizontal)
Dollar sign prefix
Implementation:

dart
class ModernAmountDisplay extends StatelessWidget {
  final double amount;
  final bool isEditable;
  final Function(double)? onAmountChanged;

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '\$${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
          letterSpacing: -1.0,
        ),
      ),
    );
  }
}
2.2 ModernCategorySelector Widget
Purpose: Horizontal scrollable category icons with labels

Design Specs:

Rounded square icons (56x56px)
Icon size: 24x24px
Corner radius: 16px
Vibrant, distinct colors per category
Label below icon (13pt, medium weight)
Horizontal scroll
12px spacing between items
Implementation:

dart
class ModernCategorySelector extends StatelessWidget {
  final List<CategoryItem> categories;
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;

  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;
          
          return GestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? Border.all(
                      color: Colors.black,
                      width: 2,
                    ) : null,
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.black : Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
2.3 ModernTextField Widget
Purpose: Clean, minimal text input with icon prefix

Design Specs:

Height: 56px
Border: 1px solid 
#E5E5EA
Border radius: 12px
Padding: 16px horizontal
Icon prefix (optional): 24x24px, gray
Placeholder: 
#8E8E93
Text: 
#1A1A1A, 17pt
Implementation:

dart
class ModernTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5E5EA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            SizedBox(width: 16),
            Icon(prefixIcon, color: Color(0xFF8E8E93), size: 24),
            SizedBox(width: 12),
          ] else
            SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF8E8E93),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}
2.4 ModernDateTimePicker Widget
Purpose: Date and time selection with icon indicators

Design Specs:

Two side-by-side buttons
Light gray background (
#F5F5F5)
Rounded corners (12px)
Icon + text layout
Height: 56px
Implementation:

dart
class ModernDateTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay) onTimeChanged;

  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateTimeButton(
            icon: Icons.calendar_today,
            label: _formatDate(selectedDate),
            onTap: () => _selectDate(context),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _DateTimeButton(
            icon: Icons.access_time,
            label: _formatTime(selectedTime),
            onTap: () => _selectTime(context),
          ),
        ),
      ],
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Color(0xFF1A1A1A)),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
2.5 ModernToggleButton Widget
Purpose: Segmented control for binary choices

Design Specs:

Light gray background (
#F5F5F5)
White selected state
Rounded pill shape
Smooth animation
Equal width segments
Implementation:

dart
class ModernToggleButton extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final Function(int) onChanged;

  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: Color(0xFF1A1A1A),
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
2.6 ModernActionButton Widget
Purpose: Primary and secondary action buttons

Design Specs:

Height: 56px
Border radius: 16px
Primary: Black background, white text
Secondary: Light gray background, black text
Full width by default
Loading state support
Implementation:

dart
class ModernActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5),
          foregroundColor: isPrimary ? Colors.white : Color(0xFF1A1A1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Color(0xFFE5E5EA),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isPrimary ? Colors.white : Color(0xFF1A1A1A),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
2.7 ModernSlideToConfirm Widget
Purpose: Slide-to-confirm interaction for important actions

Design Specs:

Light gray background
Dark circle with chevron icon
Animated sliding
Haptic feedback
"Slide to Save" text
Implementation:

dart
class ModernSlideToConfirm extends StatefulWidget {
  final VoidCallback onConfirmed;
  final String label;

  @override
  State<ModernSlideToConfirm> createState() => _ModernSlideToConfirmState();
}

class _ModernSlideToConfirmState extends State<ModernSlideToConfirm> {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;

  Widget build(BuildContext context) {
    final maxDrag = MediaQuery.of(context).size.width - 120;
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition = (_dragPosition + details.delta.dx)
                      .clamp(0.0, maxDrag);
                });
              },
              onHorizontalDragEnd: (_) {
                if (_dragPosition > maxDrag * 0.8) {
                  HapticFeedback.mediumImpact();
                  widget.onConfirmed();
                  setState(() => _isConfirmed = true);
                } else {
                  setState(() => _dragPosition = 0);
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
2.8 ModernGoalAllocationCard Widget
Purpose: Goal allocation display with progress indicator

Design Specs:

White background with border
Rounded corners (12px)
Icon + text + progress layout
Compact height (~80px)
Implementation:

dart
class ModernGoalAllocationCard extends StatelessWidget {
  final String goalName;
  final double currentAmount;
  final double targetAmount;
  final String? imageUrl;
  final VoidCallback? onTap;

  Widget build(BuildContext context) {
    final progress = currentAmount / targetAmount;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFE5E5EA)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Goal icon/image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageUrl != null
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.flag, color: Color(0xFF8E8E93)),
            ),
            SizedBox(width: 12),
            
            // Goal info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    goalName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13),
                      children: [
                        TextSpan(
                          text: '\$${currentAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: ' / ',
                          style: TextStyle(color: Color(0xFF8E8E93)),
                        ),
                        TextSpan(
                          text: '\$${targetAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF00D09C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
2.9 ModernBottomSheet Container
Purpose: Consistent bottom sheet wrapper with drag handle

Design Specs:

Rounded top corners (24px)
Drag handle indicator (4px height, 36px width)
White background
Padding: 24px horizontal, 16px top
Shadow: subtle upward shadow
Implementation:

dart
class ModernBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? maxHeight;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernBottomSheet(
        title: title,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          
          // Title
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
2.10 ModernKeyboard Widget
Purpose: Custom numeric keyboard overlay

Design Specs:

4x3 grid layout
Light gray button background (
#F5F5F5)
Rounded buttons (12px)
Large, clear numbers (24pt)
Decimal and backspace buttons
Implementation:

dart
class ModernKeyboard extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback onDecimal;

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          SizedBox(height: 12),
          _buildRow(['4', '5', '6']),
          SizedBox(height: 12),
          _buildRow(['7', '8', '9']),
          SizedBox(height: 12),
          _buildRow(['.', '0', '←']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: _KeyButton(
              label: key,
              onPressed: () {
                if (key == '←') {
                  onBackspace();
                } else if (key == '.') {
                  onDecimal();
                } else {
                  onNumberPressed(key);
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: label == '←'
              ? Icon(Icons.backspace_outlined, color: Color(0xFF1A1A1A))
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
        ),
      ),
    );
  }
}
```

---

## 3. Form-Specific Transformation Guidelines

### 3.1 Transaction Forms (Add Income/Expense)

**Before**: Traditional form with stacked fields
**After**: Modern slide-up sheet with amount-first design

**Key Changes**:
1. Replace standard TextFields with ModernTextField
2. Add ModernAmountDisplay at top
3. Replace category dropdown with ModernCategorySelector
4. Use ModernToggleButton for One Time/Repetitive
5. Add ModernSlideToConfirm for final submission
6. Include ModernKeyboard overlay for amount entry

**Layout Structure**:
```
┌─────────────────────────────┐
│ [Drag Handle]               │
│                             │
│ One Time    [Repetitive]    │  ← ModernToggleButton
│                             │
│    [$2,400]                 │  ← ModernAmountDisplay
│                             │
│ [🏢] [💼] [🏠] [%] [💻]    │  ← ModernCategorySelector
│                             │
│ [✏️ Note]                   │  ← ModernTextField
│                             │
│ Include in Goals      [🔘]  │
│                             │
│ [📅 Today]  [🕐 12:36 PM]  │  ← ModernDateTimePicker
│                             │
│ [>> Slide to Save]          │  ← ModernSlideToConfirm
│                             │
│ [1] [2] [3]                 │
│ [4] [5] [6]                 │  ← ModernKeyboard
│ [7] [8] [9]                 │
│ [.] [0] [←]                 │
└─────────────────────────────┘
Code Example:

dart
class TransformedTransactionForm extends StatefulWidget {
  @override
  State<TransformedTransactionForm> createState() => _TransformedTransactionFormState();
}

class _TransformedTransactionFormState extends State<TransformedTransactionForm> {
  double _amount = 0.0;
  String? _selectedCategoryId;
  bool _isOneTime = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      title: 'Add Income',
      child: Column(
        children: [
          // Toggle: One Time / Repetitive
          ModernToggleButton(
            options: ['One Time', 'Repetitive'],
            selectedIndex: _isOneTime ? 0 : 1,
            onChanged: (index) => setState(() => _isOneTime = index == 0),
          ),
          SizedBox(height: 24),

          // Amount Display
          ModernAmountDisplay(
            amount: _amount,
            isEditable: true,
          ),
          SizedBox(height: 24),

          // Category Selector
          ModernCategorySelector(
            categories: _getCategories(),
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
          ),
          SizedBox(height: 24),

          // Note Field
          ModernTextField(
            placeholder: 'Note',
            prefixIcon: Icons.edit_outlined,
          ),
          SizedBox(height: 24),

          // Goal Allocation Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Include in Goals',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              Switch(value: false, onChanged: (_) {}),
            ],
          ),
          SizedBox(height: 24),

          // Date & Time Picker
          ModernDateTimePicker(
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            onDateChanged: (date) => setState(() => _selectedDate = date),
            onTimeChanged: (time) => setState(() => _selectedTime = time),
          ),
          SizedBox(height: 32),

          // Slide to Confirm
          ModernSlideToConfirm(
            label: 'Slide to Save',
            onConfirmed: _handleSubmit,
          ),
          SizedBox(height: 24),

          // Custom Keyboard
          ModernKeyboard(
            onNumberPressed: _handleNumberInput,
            onBackspace: _handleBackspace,
            onDecimal: _handleDecimal,
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    // Submit logic
  }
}
```

---

### 3.2 Goal Forms (Create/Edit Goal)

**Before**: Traditional vertical form
**After**: Image-first design with minimal fields

**Key Changes**:
1. Add image placeholder at top with "Add Image" button
2. Use ModernTextField for all inputs
3. Replace date pickers with ModernDateTimePicker
4. Use ModernActionButton for Create/Update/Delete
5. Add ModernKeyboard for amount entry

**Layout Structure**:
```
┌─────────────────────────────┐
│ Create Goal                 │
│                             │
│   [📷 Add Image]            │  ← Image placeholder
│                             │
│ [🎯 Goal Title]             │  ← ModernTextField
│                             │
│ [$ Target Amount]           │  ← ModernTextField
│                             │
│ [📅 Today] [📅 Until Forever] │ ← ModernDateTimePicker
│                             │
│ [Create]                    │  ← ModernActionButton
│                             │
│ [Keyboard...]               │
└─────────────────────────────┘
3.3 Profile/Settings Forms
Before: Standard form fields After: Clean, icon-prefixed inputs

Key Changes:

Use ModernTextField with appropriate icons
Add ModernActionButton for primary action
Use subtle borders and spacing
Include ModernKeyboard for phone number
3.4 Budget Management Forms
Before: Multiple input fields After: Focused, hierarchical input

Key Changes:

Large, prominent amount displays
Secondary fields in lighter style
Clear visual hierarchy
Modern
Continue

3.4 Budget Management Forms (Continued)
Layout Structure:

┌─────────────────────────────┐
│ Manage Budget               │
│                             │
│ Total Monthly Budget        │
│ [$ 12,000]                  │  ← ModernTextField (prominent)
│                             │
│ Daily Budget Limit          │
│ [$ 200]                     │  ← ModernTextField (secondary)
│                             │
│ [Update]                    │  ← ModernActionButton
│                             │
│ [Keyboard...]               │
└─────────────────────────────┘
Code Example:

dart
class TransformedBudgetForm extends StatefulWidget {
  @override
  State<TransformedBudgetForm> createState() => _TransformedBudgetFormState();
}

class _TransformedBudgetFormState extends State<TransformedBudgetForm> {
  final _monthlyController = TextEditingController();
  final _dailyController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      title: 'Manage Budget',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            'Total Monthly Budget',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12),

          // Monthly amount - prominent
          ModernTextField(
            controller: _monthlyController,
            prefixIcon: Icons.attach_money,
            placeholder: '0',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 24),

          // Daily limit label
          Text(
            'Daily Budget Limit',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12),

          // Daily amount - secondary style
          ModernTextField(
            controller: _dailyController,
            prefixIcon: Icons.attach_money,
            placeholder: '0',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 32),

          // Action button
          ModernActionButton(
            label: 'Update',
            isPrimary: true,
            isLoading: _isLoading,
            onPressed: _handleUpdate,
          ),
          SizedBox(height: 24),

          // Keyboard
          ModernKeyboard(
            onNumberPressed: _handleNumberInput,
            onBackspace: _handleBackspace,
            onDecimal: _handleDecimal,
          ),
        ],
      ),
    );
  }

  void _handleUpdate() async {
    setState(() => _isLoading = true);
    // Update logic
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }
}
```

---

### 3.5 Duration/Frequency Selection Forms

**Before**: Standard dropdowns
**After**: Segmented controls with numeric input

**Key Changes**:
1. Use ModernToggleButton for duration type (Days/Months/Years)
2. Add numeric value selector above toggle
3. Clean, focused layout
4. Minimal chrome

**Layout Structure**:
```
┌─────────────────────────────┐
│ Select Duration             │
│                             │
│ [1] [2] [3] [4] [5] [6]...  │  ← Horizontal number selector
│                             │
│ [Forever][Days][Months][Years] │ ← ModernToggleButton
│                             │
│ [Update]                    │
└─────────────────────────────┘
Code Example:

dart
class TransformedDurationSelector extends StatefulWidget {
  @override
  State<TransformedDurationSelector> createState() => _TransformedDurationSelectorState();
}

class _TransformedDurationSelectorState extends State<TransformedDurationSelector> {
  int _selectedNumber = 6;
  int _selectedUnitIndex = 2; // Months
  final List<String> _units = ['Forever', 'Days', 'Months', 'Years'];

  @override
  Widget build(BuildContext context) {
    return ModernBottomSheet(
      title: 'Select End Duration',
      maxHeight: 300,
      child: Column(
        children: [
          // Number selector (if not Forever)
          if (_selectedUnitIndex > 0) ...[
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                itemBuilder: (context, index) {
                  final number = index + 1;
                  final isSelected = number == _selectedNumber;
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedNumber = number);
                    },
                    child: Container(
                      width: 60,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF1A1A1A) : Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
          ],

          // Unit selector
          ModernToggleButton(
            options: _units,
            selectedIndex: _selectedUnitIndex,
            onChanged: (index) => setState(() {
              _selectedUnitIndex = index;
              if (index == 0) _selectedNumber = 0; // Forever
            }),
          ),
          SizedBox(height: 24),

          // Update button
          ModernActionButton(
            label: 'Update',
            isPrimary: true,
            onPressed: _handleUpdate,
          ),
        ],
      ),
    );
  }

  void _handleUpdate() {
    Navigator.pop(context, {
      'number': _selectedNumber,
      'unit': _units[_selectedUnitIndex],
    });
  }
}
```

---

### 3.6 Category Management Forms

**Before**: List with edit/delete buttons
**After**: Card-based layout with inline actions

**Key Changes**:
1. Use card containers for each category
2. Inline edit/delete icons
3. Transaction count badge
4. Drag handle for reordering
5. Bottom "Create New" button

**Layout Structure**:
```
┌─────────────────────────────┐
│ Manage Categories           │
│ [Spending]  [Income]        │  ← ModernToggleButton
│                             │
│ ┌─────────────────────────┐ │
│ │ [🏢] Business           │ │
│ │     12 Transactions  ✏️ 🗑│ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ [🍕] Food               │ │
│ │     6 Transactions   ✏️ 🗑│ │
│ └─────────────────────────┘ │
│                             │
│ [Create New +]              │  ← ModernActionButton
└─────────────────────────────┘
Code Example:

dart
class TransformedCategoryList extends StatelessWidget {
  final List<CategoryItem> categories;
  final Function(CategoryItem) onEdit;
  final Function(CategoryItem) onDelete;

  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: categories.length + 1, // +1 for create button
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return ModernActionButton(
            label: 'Create New',
            isPrimary: true,
            icon: Icons.add,
            onPressed: () => _showCreateDialog(context),
          );
        }

        final category = categories[index];
        return ModernCategoryCard(
          category: category,
          onEdit: () => onEdit(category),
          onDelete: () => onDelete(category),
        );
      },
    );
  }
}

class ModernCategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E5EA)),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),

          // Category info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${category.transactionCount} Transactions',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
            color: Color(0xFF8E8E93),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
            color: Color(0xFF8E8E93),
          ),
        ],
      ),
    );
  }
}
4. Specific File Transformation Instructions
4.1 recurring_income_creation_screen.dart
Transformation Steps:

Replace AppBar with ModernBottomSheet pattern
dart
   // BEFORE
   Scaffold(
     appBar: AppBar(title: Text('Add Recurring Income')),
     body: Form(...)
   )

   // AFTER
   ModernBottomSheet.show(
     context: context,
     title: 'Add Income',
     child: TransformedIncomeForm(),
   )
Replace amount input with ModernAmountDisplay + ModernKeyboard
dart
   // BEFORE
   TextFormField(
     controller: _amountController,
     decoration: InputDecoration(labelText: 'Amount', prefixText: '\$'),
   )

   // AFTER
   ModernAmountDisplay(
     amount: _amount,
     isEditable: true,
   )
   // + ModernKeyboard at bottom
Replace category dropdown with ModernCategorySelector
dart
   // BEFORE
   DropdownButtonFormField<String>(...)

   // AFTER
   ModernCategorySelector(
     categories: incomeCategories,
     selectedCategoryId: _selectedCategoryId,
     onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
   )
Replace frequency dropdown with ModernToggleButton
dart
   // BEFORE
   DropdownButtonFormField<RecurringIncomeFrequency>(...)

   // AFTER
   ModernToggleButton(
     options: ['Weekly', 'Monthly', 'Yearly'],
     selectedIndex: _getFrequencyIndex(),
     onChanged: (index) => _setFrequency(index),
   )
Replace date pickers with ModernDateTimePicker
dart
   // BEFORE
   InkWell(
     onTap: () async { /* showDatePicker */ },
     child: InputDecorator(...)
   )

   // AFTER
   ModernDateTimePicker(
     selectedDate: _selectedStartDate,
     selectedTime: TimeOfDay.now(),
     onDateChanged: (date) => setState(() => _selectedStartDate = date),
     onTimeChanged: (time) {},
   )
Replace text fields with ModernTextField
dart
   // BEFORE
   TextFormField(
     controller: _descriptionController,
     decoration: InputDecoration(labelText: 'Description'),
   )

   // AFTER
   ModernTextField(
     controller: _descriptionController,
     placeholder: 'Description',
     prefixIcon: Icons.description_outlined,
   )
Replace action buttons with ModernActionButton
dart
   // BEFORE
   Row(
     children: [
       Expanded(child: OutlinedButton(...)),
       Expanded(child: ElevatedButton(...)),
     ],
   )

   // AFTER
   ModernActionButton(
     label: 'Add Income',
     isPrimary: true,
     isLoading: _isSubmitting,
     onPressed: _submitIncome,
   )
Add ModernSlideToConfirm for final submission
dart
   ModernSlideToConfirm(
     label: 'Slide to Save',
     onConfirmed: _submitIncome,
   )
4.2 add_transaction_bottom_sheet.dart & enhanced_add_transaction_bottom_sheet.dart
Complete Rewrite Structure:

dart
class ModernAddTransactionSheet extends ConsumerStatefulWidget {
  const ModernAddTransactionSheet({
    Key? key,
    required this.onSubmit,
    this.initialType,
  }) : super(key: key);

  final Future<void> Function(Transaction) onSubmit;
  final TransactionType? initialType;

  static Future<T?> show<T>({
    required BuildContext context,
    required Future<void> Function(Transaction) onSubmit,
    TransactionType? initialType,
  }) {
    return ModernBottomSheet.show<T>(
      context: context,
      title: initialType == TransactionType.income ? 'Add Income' : 'Add Spend',
      child: ModernAddTransactionSheet(
        onSubmit: onSubmit,
        initialType: initialType,
      ),
    );
  }

  @override
  ConsumerState<ModernAddTransactionSheet> createState() => _ModernAddTransactionSheetState();
}

class _ModernAddTransactionSheetState extends ConsumerState<ModernAddTransactionSheet> {
  late TransactionType _type;
  double _amount = 0.0;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isOneTime = true;
  
  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Type toggle (if no initial type)
        if (widget.initialType == null)
          ModernToggleButton(
            options: ['Income', 'Expense'],
            selectedIndex: _type == TransactionType.income ? 0 : 1,
            onChanged: (index) => setState(() {
              _type = index == 0 ? TransactionType.income : TransactionType.expense;
              _selectedCategoryId = null; // Reset category
            }),
          ),
        SizedBox(height: 24),

        // One Time / Repetitive toggle
        ModernToggleButton(
          options: ['One Time', 'Repetitive'],
          selectedIndex: _isOneTime ? 0 : 1,
          onChanged: (index) => setState(() => _isOneTime = index == 0),
        ),
        SizedBox(height: 24),

        // Amount display
        ModernAmountDisplay(amount: _amount),
        SizedBox(height: 24),

        // Category selector
        ModernCategorySelector(
          categories: _getCategories(),
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
        ),
        SizedBox(height: 24),

        // Note field
        ModernTextField(
          placeholder: 'Note',
          prefixIcon: Icons.edit_outlined,
        ),
        SizedBox(height: 24),

        // Goal allocation toggle (for income only)
        if (_type == TransactionType.income)
          _buildGoalToggle(),
        
        // Date & time
        ModernDateTimePicker(
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onTimeChanged: (time) => setState(() => _selectedTime = time),
        ),
        SizedBox(height: 32),

        // Slide to save
        ModernSlideToConfirm(
          label: 'Slide to Save',
          onConfirmed: _handleSubmit,
        ),
        SizedBox(height: 24),

        // Keyboard
        ModernKeyboard(
          onNumberPressed: _handleNumberInput,
          onBackspace: _handleBackspace,
          onDecimal: _handleDecimal,
        ),
      ],
    );
  }

  Widget _buildGoalToggle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Include in Goals',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Switch(
              value: _includeInGoals,
              onChanged: (value) => setState(() => _includeInGoals = value),
              activeColor: Color(0xFF00D09C),
            ),
          ],
        ),
        if (_includeInGoals) ...[
          SizedBox(height: 16),
          _buildGoalCards(),
        ],
        SizedBox(height: 24),
      ],
    );
  }

  void _handleNumberInput(String number) {
    setState(() {
      final currentString = _amount.toString().replaceAll('.', '');
      final newString = currentString + number;
      _amount = double.parse(newString) / 100; // Assuming cents
    });
  }

  void _handleBackspace() {
    setState(() {
      final currentString = (_amount * 100).toInt().toString();
      if (currentString.length > 1) {
        final newString = currentString.substring(0, currentString.length - 1);
        _amount = double.parse(newString) / 100;
      } else {
        _amount = 0.0;
      }
    });
  }

  void _handleDecimal() {
    // Handle decimal point logic
  }

  Future<void> _handleSubmit() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: _amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      title: 'Transaction', // Can be enhanced
    );

    await widget.onSubmit(transaction);
    if (mounted) Navigator.pop(context);
  }
}
4.3 goal_creation_screen.dart & edit_goal_bottom_sheet.dart
Key Transformations:

Add image picker at top
dart
   GestureDetector(
     onTap: _pickImage,
     child: Container(
       width: 120,
       height: 120,
       decoration: BoxDecoration(
         color: Color(0xFFF5F5F5),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(
           color: Color(0xFFE5E5EA),
           width: 2,
           style: BorderStyle.dashed,
         ),
       ),
       child: _imageUrl != null
           ? ClipRRect(
               borderRadius: BorderRadius.circular(14),
               child: Image.network(_imageUrl!, fit: BoxFit.cover),
             )
           : Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.add_photo_alternate, size: 32, color: Color(0xFF8E8E93)),
                 SizedBox(height: 8),
                 Text('Add Image', style: TextStyle(color: Color(0xFF8E8E93))),
               ],
             ),
     ),
   )
Replace all TextFormFields with ModernTextField
Use ModernDateTimePicker for dates
Add two-button layout for Edit mode
dart
   Row(
     children: [
       Expanded(
         child: ModernActionButton(
           label: 'Delete',
           isPrimary: false,
           icon: Icons.delete_outline,
           onPressed: _handleDelete,
         ),
       ),
       SizedBox(width: 16),
       Expanded(
         child: ModernActionButton(
           label: 'Update',
           isPrimary: true,
           onPressed: _handleUpdate,
         ),
       ),
     ],
   )
4.4 bill_creation_screen.dart & edit_bill_bottom_sheet.dart
Similar transformations as income forms:

Replace all standard fields with Modern equivalents
Add ModernCategorySelector for bill categories
Use ModernToggleButton for AutoPay
Implement ModernSlideToConfirm for payment submission
4.5 transfer_form.dart
Special Considerations:

Account selectors should use card-based UI
dart
   class ModernAccountSelector extends StatelessWidget {
     final String label;
     final Account? selectedAccount;
     final Function(Account) onSelected;

     Widget build(BuildContext context) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             label,
             style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
           ),
           SizedBox(height: 12),
           GestureDetector(
             onTap: () => _showAccountPicker(context),
             child: Container(
               padding: EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.white,
                 border: Border.all(color: Color(0xFFE5E5EA)),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Row(
                 children: [
                   Container(
                     width: 48,
                     height: 48,
                     decoration: BoxDecoration(
                       color: selectedAccount?.color ?? Color(0xFFF5F5F5),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Icon(
                       Icons.account_balance_wallet,
                       color: Colors.white,
                     ),
                   ),
                   SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           selectedAccount?.name ?? 'Select Account',
                           style: TextStyle(
                             fontSize: 17,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                         if (selectedAccount != null)
                           Text(
                             selectedAccount!.formattedBalance,
                             style: TextStyle(
                               fontSize: 13,
                               color: Color(0xFF8E8E93),
                             ),
                           ),
                       ],
                     ),
                   ),
                   Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                 ],
               ),
             ),
           ),
         ],
       );
     }
   }
Transfer summary card
dart
   Container(
     padding: EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: Color(0xFFF5F5F5),
       borderRadius: BorderRadius.circular(12),
     ),
     child: Column(
       children: [
         _buildSummaryRow('From', sourceAccount.name),
         SizedBox(height: 12),
         Icon(Icons.arrow_downward, color: Color(0xFF8E8E93)),
         SizedBox(height: 12),
         _buildSummaryRow('To', destinationAccount.name),
         Divider(height: 24),
         _buildSummaryRow('Amount', '\$$amount', isBold: true),
       ],
     ),
   )
5. Animation and Interaction Patterns
5.1 Sheet Entry Animation
dart
// Slide up from bottom with fade
ModernBottomSheet.show(
  context: context,
  child: YourForm(),
).then((_) {
  // Animate entry
});

// Inside ModernBottomSheet
AnimatedSlide(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutCubic,
  offset: _isVisible ? Offset.zero : Offset(0, 1),
  child: child,
)
5.2 Amount Input Animation
dart
// Scale and fade when amount changes
AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  transitionBuilder: (child, animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  },
  child: Text(
    '\$$_amount',
    key: ValueKey(_amount),
    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
  ),
)
5.3 Category Selection Animation
dart
// Scale and color transition
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
  decoration: BoxDecoration(
    color: category.color,
    borderRadius: BorderRadius.circular(16),
    border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
    boxShadow: isSelected ? [
      BoxShadow(
        color: category.color.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ] : null,
  ),
  child: Icon(category.icon, color: Colors.white),
)
5.4 Keyboard Button Feedback
dart
GestureDetector(
  onTapDown: (_) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  },
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedScale(
    duration: Duration(milliseconds: 100),
    scale: _isPressed ? 0.95 : 1.0,
    child: Container(/* button content */),
  ),
)
5.5 Slide to Confirm Animation
dart
AnimatedBuilder(
  animation: _dragController,
  builder: (context, child) {
    return CustomPaint(
      painter: SlideTrailPainter(
        progress: _dragPosition / _maxDrag,
        color: Color(0xFF00D09C),
      ),
      child: child,
    );
  },
  child: /* Slide handle */,
)
6. Color and Theme Integration
6.1 Dark Mode Support
dart
class ModernColors {
  // Light mode
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F5);
  static const lightText = Color(0xFF1A1A1A);
  static const lightBorder = Color(0xFFE5E5EA);

  // Dark mode
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkText = Color(0xFFFFFFFF);
  static const darkBorder = Color(0xFF38383A);

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkText
        : lightText;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }
}
6.2 Semantic Colors
dart
class ModernSemanticColors {
  static const success = Color(0xFF00D09C);
  static const error = Color(0xFFFF3B30);
  static const warning = Color(0xFFFF9500);
  static const info = Color(0xFF007AFF);

  static const income = Color(0xFF00D09C);
  static const expense = Color(0xFFFF3B30);
}
7. Accessibility Considerations
7.1 Semantic Labels
dart
Semantics(
  label: 'Amount: \$${amount.toStringAsFixed(2)}',
  hint: 'Tap to edit amount',
  child: ModernAmountDisplay(amount: amount),
)
7.2 Focus Management
dart
FocusScope.of(context).requestFocus(_firstFieldFocus);
7.3 Minimum Touch Targets
dart
// Ensure all interactive elements are at least 44x44 logical pixels
Container(
  constraints: BoxConstraints(minWidth: 44, minHeight: 44),
  child: /* Interactive element */,
)
7.4 Screen Reader Support
dart
Semantics(
  button: true,
Continue

7.4 Screen Reader Support (Continued)
dart
Semantics(
  button: true,
  label: 'Slide to save transaction',
  hint: 'Drag to the right to confirm',
  onTap: () => _handleSubmit(), // Fallback for accessibility
  child: ModernSlideToConfirm(
    label: 'Slide to Save',
    onConfirmed: _handleSubmit,
  ),
)
7.5 High Contrast Mode
dart
class ModernTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.of(context).highContrast;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: highContrast ? Colors.black : Color(0xFFE5E5EA),
          width: highContrast ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      // ...
    );
  }
}
8. Performance Optimization Guidelines
8.1 Widget Rebuilding
dart
// Use const constructors where possible
const ModernTextField(
  placeholder: 'Enter amount',
  prefixIcon: Icons.attach_money,
)

// Separate stateful widgets for isolated rebuilds
class _AmountDisplay extends StatefulWidget {
  // Only this rebuilds when amount changes
}

class _CategorySelector extends StatefulWidget {
  // Only this rebuilds when category changes
}
8.2 List Performance
dart
// Use ListView.builder for long lists
ListView.builder(
  itemCount: categories.length,
  itemBuilder: (context, index) {
    return ModernCategoryCard(
      key: ValueKey(categories[index].id), // Add keys for stability
      category: categories[index],
    );
  },
)

// Add RepaintBoundary for complex items
RepaintBoundary(
  child: ModernCategoryCard(category: category),
)
8.3 Image Loading
dart
// Use cached network images
CachedNetworkImage(
  imageUrl: goal.imageUrl,
  placeholder: (context, url) => Container(
    color: Color(0xFFF5F5F5),
    child: Icon(Icons.image, color: Color(0xFF8E8E93)),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
8.4 Keyboard Performance
dart
// Debounce number input
Timer? _inputDebounce;

void _handleNumberInput(String number) {
  _inputDebounce?.cancel();
  _inputDebounce = Timer(Duration(milliseconds: 50), () {
    setState(() {
      // Update amount
    });
  });
}
9. Migration Strategy
9.1 Phase 1: Core Components (Week 1)
Objective: Build reusable component library

Tasks:

Create modern_components.dart file
Implement all Modern widgets:
ModernAmountDisplay
ModernTextField
ModernActionButton
ModernToggleButton
ModernBottomSheet
Create style constants file
Test components in isolation
Create component showcase/demo screen
Deliverables:

lib/core/design_system/modern/
modern_amount_display.dart
modern_text_field.dart
modern_action_button.dart
modern_toggle_button.dart
modern_bottom_sheet.dart
modern_category_selector.dart
modern_date_time_picker.dart
modern_slide_to_confirm.dart
modern_keyboard.dart
modern_goal_card.dart
modern_colors.dart
modern_typography.dart
modern_spacing.dart
9.2 Phase 2: Transaction Forms (Week 2)
Objective: Transform add/edit transaction flows

Tasks:

Create new modern_add_transaction_sheet.dart
Replace old bottom sheet calls with new implementation
Test both income and expense flows
Verify goal allocation works
Test keyboard interactions
Verify form validation
Files to Transform:

enhanced_add_transaction_bottom_sheet.dart → Complete rewrite
add_transaction_bottom_sheet.dart → Deprecate and replace
transaction_detail_bottom_sheet.dart → Transform edit mode
9.3 Phase 3: Recurring Income/Bill Forms (Week 3)
Objective: Transform recurring income and bill management

Tasks:

Transform recurring_income_creation_screen.dart
Transform recurring_income_editing_screen.dart
Transform bill_creation_screen.dart
Transform edit_bill_bottom_sheet.dart
Transform payment_recording_bottom_sheet.dart
Special Considerations:

Maintain all validation logic
Preserve account selection functionality
Keep auto-pay toggle working
Test receipt attachment flow
9.4 Phase 4: Goal Forms (Week 4)
Objective: Transform goal creation and editing

Tasks:

Transform goal_creation_screen.dart
Transform edit_goal_bottom_sheet.dart
Add image picker functionality
Transform add_contribution_bottom_sheet.dart
9.5 Phase 5: Settings & Profile Forms (Week 5)
Objective: Transform remaining forms

Tasks:

Transform profile editing forms
Transform budget management forms
Transform category management screens
Transform duration/frequency selectors
9.6 Phase 6: Testing & Polish (Week 6)
Objective: Comprehensive testing and refinement

Tasks:

Accessibility audit
Performance profiling
Dark mode verification
Animation smoothness check
User testing feedback
Bug fixes and polish
10. Implementation Checklist
10.1 Before Starting
 Review all reference images thoroughly
 Set up design system folder structure
 Create color and typography constants
 Set up animation utilities
 Create component demo/showcase screen
10.2 Component Development
 ModernAmountDisplay with keyboard integration
 ModernTextField with proper validation
 ModernActionButton with loading states
 ModernToggleButton with smooth animations
 ModernBottomSheet with drag handle
 ModernCategorySelector with horizontal scroll
 ModernDateTimePicker with native pickers
 ModernSlideToConfirm with haptics
 ModernKeyboard with proper feedback
 ModernGoalAllocationCard with progress
10.3 Form Transformations
 Transaction creation (income)
 Transaction creation (expense)
 Transaction editing
 Recurring income creation
 Recurring income editing
 Bill creation
 Bill editing
 Payment recording
 Goal creation
 Goal editing
 Goal contribution
 Profile editing
 Budget management
 Category management
 Transfer form
10.4 Testing
 Unit tests for components
 Widget tests for forms
 Integration tests for complete flows
 Accessibility testing
 Performance profiling
 Dark mode verification
 Tablet/landscape testing
 Screen reader testing
10.5 Documentation
 Component API documentation
 Usage examples for each component
 Migration guide for developers
 Design system documentation
 Accessibility guidelines
11. Code Examples: Complete Form Transformations
11.1 Complete Income Form Example
dart
// lib/features/transactions/presentation/sheets/modern_income_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/modern/modern_components.dart';
import '../../domain/entities/transaction.dart';

class ModernIncomeSheet extends ConsumerStatefulWidget {
  const ModernIncomeSheet({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  final Future<void> Function(Transaction) onSubmit;

  static Future<T?> show<T>({
    required BuildContext context,
    required Future<void> Function(Transaction) onSubmit,
  }) {
    return ModernBottomSheet.show<T>(
      context: context,
      title: 'Add Income',
      maxHeight: null, // Full height
      child: ModernIncomeSheet(onSubmit: onSubmit),
    );
  }

  @override
  ConsumerState<ModernIncomeSheet> createState() => _ModernIncomeSheetState();
}

class _ModernIncomeSheetState extends ConsumerState<ModernIncomeSheet> {
  // Form state
  double _amount = 0.0;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isOneTime = true;
  bool _includeInGoals = false;
  final _noteController = TextEditingController();
  
  // Frequency state (for repetitive)
  int _frequencyValue = 1;
  String _frequencyUnit = 'Month';
  
  // Goal allocation state
  final List<String> _selectedGoalIds = [];
  final Map<String, double> _goalAllocations = {};
  
  // UI state
  bool _isSubmitting = false;
  FocusNode _noteFocusNode = FocusNode();

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // One Time / Repetitive Toggle
        ModernToggleButton(
          options: ['One Time', 'Repetitive'],
          selectedIndex: _isOneTime ? 0 : 1,
          onChanged: (index) {
            HapticFeedback.lightImpact();
            setState(() => _isOneTime = index == 0);
          },
        ),
        SizedBox(height: 24),

        // Frequency selector (if repetitive)
        if (!_isOneTime) ...[
          _buildFrequencySelector(),
          SizedBox(height: 24),
        ],

        // Amount Display
        ModernAmountDisplay(
          amount: _amount,
          isEditable: true,
          onTap: () {
            // Show keyboard if hidden
            FocusScope.of(context).unfocus();
          },
        ),
        SizedBox(height: 24),

        // Category Selector
        _buildCategorySelector(),
        SizedBox(height: 24),

        // Note Field
        ModernTextField(
          controller: _noteController,
          placeholder: 'Add a note',
          prefixIcon: Icons.edit_outlined,
          focusNode: _noteFocusNode,
          onTap: () {
            // Hide keyboard when focusing on note
            setState(() {});
          },
        ),
        SizedBox(height: 24),

        // Include in Goals Toggle
        _buildGoalToggle(),

        // Date & Time Picker
        ModernDateTimePicker(
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          onDateChanged: (date) {
            HapticFeedback.lightImpact();
            setState(() => _selectedDate = date);
          },
          onTimeChanged: (time) {
            HapticFeedback.lightImpact();
            setState(() => _selectedTime = time);
          },
        ),
        SizedBox(height: 32),

        // Slide to Confirm
        ModernSlideToConfirm(
          label: 'Slide to Save',
          onConfirmed: _handleSubmit,
          isEnabled: _canSubmit(),
        ),
        SizedBox(height: 24),

        // Custom Keyboard (only show when not focusing on note)
        if (!_noteFocusNode.hasFocus) ...[
          ModernKeyboard(
            onNumberPressed: _handleNumberInput,
            onBackspace: _handleBackspace,
            onDecimal: _handleDecimal,
          ),
        ],
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repeat Every',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // Number selector
              Container(
                width: 80,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFE5E5EA)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 20),
                      onPressed: () {
                        if (_frequencyValue > 1) {
                          HapticFeedback.lightImpact();
                          setState(() => _frequencyValue--);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 30),
                    ),
                    Text(
                      '$_frequencyValue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _frequencyValue++);
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 30),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              // Unit selector
              Expanded(
                child: ModernToggleButton(
                  options: ['Day', 'Week', 'Month', 'Year'],
                  selectedIndex: ['Day', 'Week', 'Month', 'Year'].indexOf(_frequencyUnit),
                  onChanged: (index) {
                    setState(() {
                      _frequencyUnit = ['Day', 'Week', 'Month', 'Year'][index];
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoryState = ref.watch(categoryNotifierProvider);
    
    return categoryState.when(
      data: (state) {
        final categories = state.getCategoriesByType(TransactionType.income);
        
        return ModernCategorySelector(
          categories: categories.map((cat) => CategoryItem(
            id: cat.id,
            name: cat.name,
            icon: _getIconData(cat.icon),
            color: Color(cat.color),
          )).toList(),
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: (id) {
            HapticFeedback.lightImpact();
            setState(() => _selectedCategoryId = id);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error loading categories'),
    );
  }

  Widget _buildGoalToggle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Include in Goals',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Allocate to savings goals',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
            Switch(
              value: _includeInGoals,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _includeInGoals = value);
              },
              activeColor: ModernSemanticColors.success,
            ),
          ],
        ),
        
        // Goal cards (if enabled)
        if (_includeInGoals && _amount > 0) ...[
          SizedBox(height: 16),
          _buildGoalCards(),
        ],
        
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGoalCards() {
    final goalsAsync = ref.watch(goalNotifierProvider);
    
    return goalsAsync.when(
      data: (state) {
        final activeGoals = state.goals.where((g) => !g.isCompleted).toList();
        
        if (activeGoals.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: Color(0xFF8E8E93)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No active goals. Create one to allocate income.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: activeGoals.take(2).map((goal) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ModernGoalAllocationCard(
                goalName: goal.title,
                currentAmount: goal.currentAmount,
                targetAmount: goal.targetAmount,
                imageUrl: goal.imageUrl,
                onTap: () => _showGoalAllocation(goal),
              ),
            );
          }).toList(),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => SizedBox.shrink(),
    );
  }

  void _handleNumberInput(String number) {
    setState(() {
      // Convert current amount to cents
      int cents = (_amount * 100).round();
      
      // Append new digit
      String centsString = cents.toString() + number;
      
      // Convert back to dollars
      _amount = int.parse(centsString) / 100.0;
      
      // Limit to reasonable amount
      if (_amount > 999999.99) {
        _amount = 999999.99;
      }
    });
    
    HapticFeedback.lightImpact();
  }

  void _handleBackspace() {
    setState(() {
      // Convert to cents
      int cents = (_amount * 100).round();
      
      // Remove last digit
      cents = cents ~/ 10;
      
      // Convert back to dollars
      _amount = cents / 100.0;
    });
    
    HapticFeedback.lightImpact();
  }

  void _handleDecimal() {
    // Decimal is handled automatically in the display
    HapticFeedback.lightImpact();
  }

  bool _canSubmit() {
    return _amount > 0 && _selectedCategoryId != null;
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter amount and select category'),
          backgroundColor: ModernSemanticColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: _amount,
        type: TransactionType.income,
        categoryId: _selectedCategoryId!,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        title: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : 'Income',
        description: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        // Add goal allocations if applicable
        goalAllocations: _includeInGoals ? _buildGoalAllocations() : null,
      );

      await widget.onSubmit(transaction);

      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Income added successfully'),
              ],
            ),
            backgroundColor: ModernSemanticColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ModernSemanticColors.error,
          ),
        );
      }
    }
  }

  List<GoalContribution>? _buildGoalAllocations() {
    if (_goalAllocations.isEmpty) return null;
    
    return _goalAllocations.entries.map((entry) {
      return GoalContribution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: entry.key,
        amount: entry.value,
        date: DateTime.now(),
      );
    }).toList();
  }

  void _showGoalAllocation(Goal goal) {
    // Show allocation sheet
    ModernBottomSheet.show(
      context: context,
      title: 'Allocate to ${goal.title}',
      child: _GoalAllocationSheet(
        goal: goal,
        maxAmount: _amount,
        currentAllocation: _goalAllocations[goal.id] ?? 0,
        onSave: (amount) {
          setState(() {
            if (amount > 0) {
              _goalAllocations[goal.id] = amount;
            } else {
              _goalAllocations.remove(goal.id);
            }
          });
        },
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Convert icon name string to IconData
    // This is a simplified version - you'd need proper mapping
    return Icons.category;
  }
}

// Goal allocation sub-sheet
class _GoalAllocationSheet extends StatefulWidget {
  final Goal goal;
  final double maxAmount;
  final double currentAllocation;
  final Function(double) onSave;

  const _GoalAllocationSheet({
    required this.goal,
    required this.maxAmount,
    required this.currentAllocation,
    required this.onSave,
  });

  @override
  State<_GoalAllocationSheet> createState() => _GoalAllocationSheetState();
}

class _GoalAllocationSheetState extends State<_GoalAllocationSheet> {
  late double _amount;

  @override
  void initState() {
    super.initState();
    _amount = widget.currentAllocation;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    final maxPossible = remaining < widget.maxAmount ? remaining : widget.maxAmount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Goal info
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.goal.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.goal.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.flag, color: Color(0xFF8E8E93)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.goal.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Need \$${remaining.toStringAsFixed(0)} more',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Amount display
        ModernAmountDisplay(amount: _amount),
        SizedBox(height: 24),

        // Quick amount buttons
        Row(
          children: [
            Expanded(
              child: _QuickAmountButton(
                label: '25%',
                amount: maxPossible * 0.25,
                onTap: () => setState(() => _amount = maxPossible * 0.25),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickAmountButton(
                label: '50%',
                amount: maxPossible * 0.5,
                onTap: () => setState(() => _amount = maxPossible * 0.5),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickAmountButton(
                label: 'All',
                amount: maxPossible,
                onTap: () => setState(() => _amount = maxPossible),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Save button
        ModernActionButton(
          label: 'Save Allocation',
          isPrimary: true,
          onPressed: () {
            widget.onSave(_amount);
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 24),

        // Keyboard
        ModernKeyboard(
          onNumberPressed: (num) {
            setState(() {
              int cents = (_amount * 100).round();
              cents = int.parse(cents.toString() + num);
              _amount = (cents / 100.0).clamp(0, maxPossible);
            });
          },
          onBackspace: () {
            setState(() {
              int cents = (_amount * 100).round();
              cents = cents ~/ 10;
              _amount = cents / 100.0;
            });
          },
          onDecimal: () {},
        ),
      ],
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
12. Testing Strategy
12.1 Component Testing
dart
// test/core/design_system/modern/modern_amount_display_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_app/core/design_system/modern/modern_amount_display.dart';

void main() {
  group('ModernAmountDisplay', () {
    testWidgets('displays amount correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernAmountDisplay(amount: 2400.00),
          ),
        ),
      );

      expect(find.text('\$2,400'), findsOneWidget);
    });

    testWidgets('has correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernAmountDisplay(amount: 2400.00),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Color(0xFFF5F5F5));
      expect(decoration.borderRadius, BorderRadius.circular(999));
    });
  });
}
12.2 Integration Testing
dart
// integration_test/transaction_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Transaction Creation Flow', () {
    testWidgets('complete income transaction creation', (tester) async {
      // Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter amount using keyboard
      await tester.tap(find.text('2'));
      await tester.tap(find.text('4'));
      await tester.tap(find.text('0'));
      await tester.tap(find.text('0'));
