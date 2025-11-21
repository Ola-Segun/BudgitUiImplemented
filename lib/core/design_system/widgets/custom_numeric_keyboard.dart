import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../form_design_system.dart';

/// Helper function to show CustomNumericKeyboard as overlay
Future<String?> showCustomNumericKeyboard({
  required BuildContext context,
  String initialValue = '',
  bool showDecimal = true,
  int? maxLength,
}) async {
  String currentValue = initialValue;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.only(bottom: FormDesignSystem.spacing16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display area
              Container(
                padding: const EdgeInsets.all(FormDesignSystem.spacing16),
                margin: const EdgeInsets.symmetric(horizontal: FormDesignSystem.spacing16),
                decoration: BoxDecoration(
                  color: FormDesignSystem.surfaceWhite,
                  borderRadius: BorderRadius.circular(FormDesignSystem.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentValue.isEmpty ? '0' : currentValue,
                        style: FormDesignSystem.currencyStyle.copyWith(
                          color: FormDesignSystem.primaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (currentValue.isNotEmpty) {
                            currentValue = currentValue.substring(0, currentValue.length - 1);
                          }
                        });
                      },
                      icon: const Icon(Icons.clear),
                      color: FormDesignSystem.primaryDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FormDesignSystem.spacing16),
              // Keyboard
              CustomNumericKeyboard(
                showDot: showDecimal,
                onKeyPressed: (value) {
                  setState(() {
                    if (value == 'backspace') {
                      if (currentValue.isNotEmpty) {
                        currentValue = currentValue.substring(0, currentValue.length - 1);
                      }
                    } else {
                      if (maxLength == null || currentValue.length < maxLength) {
                        currentValue += value;
                      }
                    }
                  });
                },
              ),
              const SizedBox(height: FormDesignSystem.spacing16),
              // Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: FormDesignSystem.spacing16),
                child: PrimaryActionButton(
                  text: 'Done',
                  onPressed: () => Navigator.of(context).pop(currentValue),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

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