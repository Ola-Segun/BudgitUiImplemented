import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';

/// Enhanced bottom sheet with consistent styling and animations
class EnhancedBottomSheet {
  /// Show a form bottom sheet with enhanced UX
  static Future<T?> showForm<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedFormBottomSheet(
        title: title,
        subtitle: subtitle,
        onClose: onClose,
        actions: actions,
        child: child,
      ),
    );
  }

  /// Show a scrollable content bottom sheet
  static Future<T?> showScrollable<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    double? maxHeight,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedScrollableBottomSheet(
        title: title,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
}

/// Form bottom sheet with fixed header and footer
class _EnhancedFormBottomSheet extends StatefulWidget {
  const _EnhancedFormBottomSheet({
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  @override
  State<_EnhancedFormBottomSheet> createState() => _EnhancedFormBottomSheetState();
}

class _EnhancedFormBottomSheetState extends State<_EnhancedFormBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = screenHeight * 0.9 - keyboardHeight;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: ColorTokens.surfacePrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusXxl),
            ),
            boxShadow: DesignTokens.elevationXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: DesignTokens.spacing2),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              _buildHeader(context),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(DesignTokens.screenPaddingH),
                  child: widget.child,
                ),
              ),

              // Actions (if provided)
              if (widget.actions != null) _buildActions(),

              // Keyboard padding
              SizedBox(height: keyboardHeight > 0 ? DesignTokens.spacing2 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorTokens.borderSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TypographyTokens.heading4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 100.ms)
                  .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 100.ms),
                if (widget.subtitle != null) ...[
                  SizedBox(height: DesignTokens.spacing1),
                  Text(
                    widget.subtitle!,
                    style: TypographyTokens.bodyMd.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ).animate()
                  .fadeIn(duration: DesignTokens.durationNormal, delay: 150.ms)
                  .slideX(begin: -0.1, duration: DesignTokens.durationNormal, delay: 150.ms),
                ],
              ],
            ),
          ),
          SizedBox(width: DesignTokens.spacing2),
          Container(
            decoration: BoxDecoration(
              color: ColorTokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: IconButton(
              icon: Icon(Icons.close, size: DesignTokens.iconMd),
              onPressed: () {
                widget.onClose?.call();
                Navigator.pop(context);
              },
              color: ColorTokens.textSecondary,
              tooltip: 'Close',
            ),
          ).animate()
            .fadeIn(duration: DesignTokens.durationNormal, delay: 200.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: DesignTokens.durationNormal, delay: 200.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        border: Border(
          top: BorderSide(
            color: ColorTokens.borderSecondary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: widget.actions!
            .map((action) => Expanded(child: action))
            .toList()
            .fold<List<Widget>>(
              [],
              (list, item) => list.isEmpty
                  ? [item]
                  : [...list, SizedBox(width: DesignTokens.spacing3), item],
            ),
      ),
    ).animate()
      .fadeIn(duration: DesignTokens.durationNormal, delay: 300.ms)
      .slideY(begin: 0.1, duration: DesignTokens.durationNormal, delay: 300.ms);
  }
}

/// Scrollable content bottom sheet
class _EnhancedScrollableBottomSheet extends StatefulWidget {
  const _EnhancedScrollableBottomSheet({
    required this.title,
    required this.child,
    this.maxHeight,
  });

  final String title;
  final Widget child;
  final double? maxHeight;

  @override
  State<_EnhancedScrollableBottomSheet> createState() =>
      _EnhancedScrollableBottomSheetState();
}

class _EnhancedScrollableBottomSheetState
    extends State<_EnhancedScrollableBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveEaseOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultMaxHeight = screenHeight * 0.7;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: widget.maxHeight ?? defaultMaxHeight,
          ),
          decoration: BoxDecoration(
            color: ColorTokens.surfacePrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusXxl),
            ),
            boxShadow: DesignTokens.elevationXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: DesignTokens.spacing2),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(DesignTokens.screenPaddingH),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TypographyTokens.heading4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorTokens.surfaceSecondary,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, size: DesignTokens.iconMd),
                        onPressed: () => Navigator.pop(context),
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: ColorTokens.borderSecondary),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(DesignTokens.screenPaddingH),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}