import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';
import 'modern_action_button.dart';

/// ModernKeyboard Widget
/// Custom numeric keyboard overlay
/// 4x3 grid layout, Light gray button background (#F5F5F5)
/// Rounded buttons (12px), Large, clear numbers (24pt)
/// Decimal and backspace buttons
class ModernKeyboard extends StatelessWidget {
  final ValueChanged<String>? onKeyPressed;
  final VoidCallback? onBackspace;
  final bool showDecimal;
  final double buttonSize;

  const ModernKeyboard({
    super.key,
    this.onKeyPressed,
    this.onBackspace,
    this.showDecimal = true,
    this.buttonSize = ModernSizes.keyboardButtonSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Numeric keyboard',
      child: Container(
        padding: const EdgeInsets.all(spacing_md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: 1, 2, 3
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKey('1'),
                _buildKey('2'),
                _buildKey('3'),
              ],
            ),
            const SizedBox(height: spacing_md),
            // Row 2: 4, 5, 6
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKey('4'),
                _buildKey('5'),
                _buildKey('6'),
              ],
            ),
            const SizedBox(height: spacing_md),
            // Row 3: 7, 8, 9
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKey('7'),
                _buildKey('8'),
                _buildKey('9'),
              ],
            ),
            const SizedBox(height: spacing_md),
            // Row 4: ., 0, backspace
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (showDecimal) _buildKey('.'),
                _buildKey('0'),
                _buildBackspaceKey(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String value) {
    return Semantics(
      label: value,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onKeyPressed?.call(value);
        },
        child: AnimatedContainer(
          duration: ModernAnimations.fast,
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: ModernColors.primaryGray,
            borderRadius: BorderRadius.circular(radius_md),
          ),
          child: Center(
            child: Text(
              value,
              style: ModernTypography.titleLarge.copyWith(
                color: ModernColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Semantics(
      label: 'Backspace',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onBackspace?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          // Implement long press for continuous backspace
          onBackspace?.call();
        },
        child: AnimatedContainer(
          duration: ModernAnimations.fast,
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: ModernColors.primaryGray,
            borderRadius: BorderRadius.circular(radius_md),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace,
              size: 24,
              color: ModernColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show ModernKeyboard as overlay
Future<String?> showModernKeyboard({
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
          padding: const EdgeInsets.only(bottom: spacing_xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display area
              Container(
                padding: const EdgeInsets.all(spacing_lg),
                margin: const EdgeInsets.symmetric(horizontal: spacing_lg),
                decoration: BoxDecoration(
                  color: ModernColors.lightBackground,
                  borderRadius: BorderRadius.circular(radius_md),
                  boxShadow: [ModernShadows.subtle],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentValue.isEmpty ? '0' : currentValue,
                        style: ModernTypography.displayLarge.copyWith(
                          color: ModernColors.textPrimary,
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
                      color: ModernColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: spacing_lg),
              // Keyboard
              ModernKeyboard(
                showDecimal: showDecimal,
                onKeyPressed: (value) {
                  setState(() {
                    if (maxLength == null || currentValue.length < maxLength) {
                      currentValue += value;
                    }
                  });
                },
                onBackspace: () {
                  setState(() {
                    if (currentValue.isNotEmpty) {
                      currentValue = currentValue.substring(0, currentValue.length - 1);
                    }
                  });
                },
              ),
              const SizedBox(height: spacing_lg),
              // Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: spacing_lg),
                child: ModernActionButton(
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