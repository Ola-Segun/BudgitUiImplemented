import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../form_design_system.dart';
import 'modern_design_constants.dart';

/// Enhanced ModernAmountDisplay with integrated keyboard
class ModernAmountDisplay extends StatefulWidget {
  final double amount;
  final bool isEditable;
  final ValueChanged<double>? onAmountChanged;
  final VoidCallback? onTap;
  final String currencySymbol;

  const ModernAmountDisplay({
    super.key,
    required this.amount,
    this.isEditable = false,
    this.onAmountChanged,
    this.onTap,
    this.currencySymbol = '\$',
  });

  @override
  State<ModernAmountDisplay> createState() => _ModernAmountDisplayState();
}

class _ModernAmountDisplayState extends State<ModernAmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ModernAmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _showIntegratedKeyboard() async {
    if (!widget.isEditable) return;

    // Call custom onTap if provided, otherwise show integrated keyboard
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IntegratedNumericKeyboard(
        initialValue: widget.amount.toStringAsFixed(0),
        currencySymbol: widget.currencySymbol,
        showDecimal: false,
      ),
    );

    if (result != null) {
      final newAmount = double.tryParse(result) ?? 0.0;
      widget.onAmountChanged?.call(newAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountText = '${widget.currencySymbol}${widget.amount.toStringAsFixed(0)}';

    return Align(
      alignment: Alignment.center,
      child: Semantics(
        label: 'Amount display',
        value: amountText,
        button: widget.isEditable,
        child: GestureDetector(
          onTap: widget.isEditable ? _showIntegratedKeyboard : null,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ModernColors.primaryGray,
                        borderRadius: BorderRadius.circular(radius_pill),
                        border: widget.isEditable
                            ? Border.all(
                                color: ModernColors.accentGreen.withOpacity(0.3),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            amountText,
                            style: ModernTypography.displayMedium.copyWith(
                              color: ModernColors.primaryBlack,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          // if (widget.isEditable) ...[
                          //   const SizedBox(width: 8),
                          //   Icon(
                          //     Icons.edit,
                          //     size: 20,
                          //     color: ModernColors.textSecondary,
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Integrated Numeric Keyboard that updates the amount display in real-time
class IntegratedNumericKeyboard extends StatefulWidget {
  final String initialValue;
  final String currencySymbol;
  final bool showDecimal;
  final int? maxLength;

  const IntegratedNumericKeyboard({
    super.key,
    this.initialValue = '',
    this.currencySymbol = '\$',
    this.showDecimal = true,
    this.maxLength,
  });

  @override
  State<IntegratedNumericKeyboard> createState() =>
      _IntegratedNumericKeyboardState();
}

class _IntegratedNumericKeyboardState extends State<IntegratedNumericKeyboard>
    with SingleTickerProviderStateMixin {
  late String _currentValue;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  void _handleKeyPress(String value) {
    HapticFeedback.lightImpact();
    
    setState(() {
      if (value == 'backspace') {
        if (_currentValue.isNotEmpty) {
          _currentValue = _currentValue.substring(0, _currentValue.length - 1);
        }
      } else if (value == 'clear') {
        _currentValue = '';
      } else if (value == 'done') {
        _slideController.reverse().then((_) {
          Navigator.of(context).pop(_currentValue);
        });
      } else {
        // Check for decimal point
        if (value == '.' && (!widget.showDecimal || _currentValue.contains('.'))) {
          return;
        }
        
        // Check max length
        if (widget.maxLength != null && _currentValue.length >= widget.maxLength!) {
          return;
        }
        
        // Don't allow leading zeros
        if (_currentValue == '0' && value != '.') {
          _currentValue = value;
        } else {
          _currentValue += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = _currentValue.isEmpty ? '0' : _currentValue;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: ModernColors.lightBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ModernColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Live amount display (replaces the original in the form)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: spacing_lg,
                vertical: spacing_md,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey(displayAmount),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ModernColors.primaryGray,
                    borderRadius: BorderRadius.circular(radius_pill),
                  ),
                  child: Text(
                    '${widget.currencySymbol}$displayAmount',
                    style: ModernTypography.displayMedium.copyWith(
                      color: ModernColors.primaryBlack,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),

            // Keyboard
            Container(
              padding: const EdgeInsets.all(spacing_md),
              child: Column(
                children: [
                  // Row 1: 1, 2, 3
                  _buildKeyRow(['1', '2', '3']),
                  const SizedBox(height: spacing_sm),

                  // Row 2: 4, 5, 6
                  _buildKeyRow(['4', '5', '6']),
                  const SizedBox(height: spacing_sm),

                  // Row 3: 7, 8, 9
                  _buildKeyRow(['7', '8', '9']),
                  const SizedBox(height: spacing_sm),

                  // Row 4: ., 0, backspace
                  _buildKeyRow([
                    widget.showDecimal ? '.' : '',
                    '0',
                    'backspace',
                  ]),
                  
                  const SizedBox(height: spacing_md),
                  
                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Clear',
                          Icons.clear_all,
                          ModernColors.textSecondary,
                          () => _handleKeyPress('clear'),
                        ),
                      ),
                      const SizedBox(width: spacing_sm),
                      Expanded(
                        flex: 2,
                        child: _buildActionButton(
                          'Done',
                          Icons.check,
                          ModernColors.accentGreen,
                          () => _handleKeyPress('done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + spacing_sm),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        if (key.isEmpty) {
          return const Expanded(child: SizedBox(height: 56));
        }
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing_xs),
            child: _KeyButton(
              value: key,
              icon: key == 'backspace' ? Icons.backspace_outlined : null,
              onPressed: () => _handleKeyPress(key),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius_md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius_md),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: spacing_xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
}

/// Individual key button with press animation
class _KeyButton extends StatefulWidget {
  final String value;
  final VoidCallback onPressed;
  final IconData? icon;

  const _KeyButton({
    required this.value,
    required this.onPressed,
    this.icon,
  });

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
      end: 0.92,
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
                color: ModernColors.lightBackground,
                borderRadius: BorderRadius.circular(radius_md),
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
                        color: ModernColors.primaryBlack,
                        size: 24,
                      )
                    : Text(
                        widget.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.primaryBlack,
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

// Demo widget to show the integrated keyboard in action
class ModernAmountDisplayDemo extends StatefulWidget {
  const ModernAmountDisplayDemo({super.key});

  @override
  State<ModernAmountDisplayDemo> createState() => _ModernAmountDisplayDemoState();
}

class _ModernAmountDisplayDemoState extends State<ModernAmountDisplayDemo> {
  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Integrated Amount Keyboard'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tap to edit amount',
              style: TextStyle(
                fontSize: 16,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: spacing_lg),
            ModernAmountDisplay(
              amount: _amount,
              isEditable: true,
              onAmountChanged: (newAmount) {
                setState(() {
                  _amount = newAmount;
                });
              },
            ),
            const SizedBox(height: spacing_lg),
            Text(
              'Current: \$${_amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}