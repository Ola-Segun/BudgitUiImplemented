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
dart// Extracted spacing values
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
dart// Primary colors from images
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
dart// Extracted from images
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
dartconst double radius_sm = 8.0;
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
Gray background (#F5F5F5)
Pill-shaped (999px border radius)
Generous padding (24px vertical, 48px horizontal)
Dollar sign prefix

Implementation:
dartclass ModernAmountDisplay extends StatelessWidget {
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
dartclass ModernCategorySelector extends StatelessWidget {
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
Border: 1px solid #E5E5EA
Border radius: 12px
Padding: 16px horizontal
Icon prefix (optional): 24x24px, gray
Placeholder: #8E8E93
Text: #1A1A1A, 17pt

Implementation:
dartclass ModernTextField extends StatelessWidget {
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
Light gray background (#F5F5F5)
Rounded corners (12px)
Icon + text layout
Height: 56px

Implementation:
dartclass ModernDateTimePicker extends StatelessWidget {
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

Light gray background (#F5F5F5)
White selected state
Rounded pill shape
Smooth animation
Equal width segments

Implementation:
dartclass ModernToggleButton extends StatelessWidget {
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
dartclass ModernActionButton extends StatelessWidget {
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
dartclass ModernSlideToConfirm extends StatefulWidget {
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
dartclass ModernGoalAllocationCard extends StatelessWidget {
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
dartclass ModernBottomSheet extends StatelessWidget {
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
Light gray button background (#F5F5F5)
Rounded buttons (12px)
Large, clear numbers (24pt)
Decimal and backspace buttons

Implementation:
dartclass ModernKeyboard extends StatelessWidget {
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
dartclass TransformedTransactionForm extends StatefulWidget {
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
Before: Standard form fields
After: Clean, icon-prefixed inputs
Key Changes:

Use ModernTextField with appropriate icons
Add ModernActionButton for primary action
Use subtle borders and spacing
Include ModernKeyboard for phone number


3.4 Budget Management Forms
Before: Multiple input fields
After: Focused, hierarchical input
Key Changes:

Large, prominent amount displays
Secondary fields in lighter style
Clear visual hierarchy