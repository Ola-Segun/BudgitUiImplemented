import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../../../../core/design_system/modern/modern_color_picker.dart';
import '../../../../core/design_system/modern/modern.dart';
import '../../../accounts/domain/entities/account_type_theme.dart';
import '../../domain/entities/settings.dart';
import '../providers/settings_providers.dart';

/// Account Themes Customization Bottom Sheet
class AccountThemesEditorSheet extends ConsumerStatefulWidget {
  const AccountThemesEditorSheet({
    super.key,
    required this.currentThemes,
  });

  final Map<String, AccountTypeTheme> currentThemes;

  @override
  ConsumerState<AccountThemesEditorSheet> createState() => _AccountThemesEditorSheetState();
}

class _AccountThemesEditorSheetState extends ConsumerState<AccountThemesEditorSheet> {
  late Map<String, AccountTypeTheme> _editedThemes;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _editedThemes = Map.from(widget.currentThemes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: spacing_md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ColorTokens.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(spacing_lg),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(spacing_xs),
                  decoration: BoxDecoration(
                    color: ColorTokens.withOpacity(ColorTokens.teal500, 0.1),
                    borderRadius: BorderRadius.circular(radius_md),
                  ),
                  child: Icon(
                    Icons.color_lens,
                    color: ColorTokens.teal500,
                    size: DesignTokens.iconMd,
                  ),
                ),
                SizedBox(width: spacing_md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Account Themes',
                        style: TypographyTokens.heading4,
                      ),
                      Text(
                        'Personalize colors for each account type',
                        style: TypographyTokens.bodyMd.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: spacing_lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview Section
                  _buildPreviewSection(),
                  SizedBox(height: spacing_xl),

                  // Account Types List
                  Text(
                    'Account Types',
                    style: TypographyTokens.heading5,
                  ),
                  SizedBox(height: spacing_md),

                  ...AccountTypeTheme.defaultThemes.entries.map((entry) {
                    final accountType = entry.key;
                    final defaultTheme = entry.value;
                    final currentTheme = _editedThemes[accountType] ?? defaultTheme;

                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing_md),
                      child: _AccountTypeThemeEditor(
                        accountType: accountType,
                        theme: currentTheme,
                        onColorChanged: (color) {
                          setState(() {
                            _editedThemes[accountType] = currentTheme.copyWith(
                              colorValue: color.value,
                            );
                            _hasChanges = true;
                          });
                        },
                      ),
                    );
                  }),

                  SizedBox(height: spacing_xl),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.all(spacing_lg),
            decoration: BoxDecoration(
              color: ColorTokens.surfacePrimary,
              border: Border(
                top: BorderSide(
                  color: ColorTokens.neutral200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ModernActionButton(
                    text: 'Reset',
                    icon: Icons.restore,
                    isPrimary: false,
                    onPressed: _resetToDefaults,
                  ),
                ),
                SizedBox(width: spacing_md),
                Expanded(
                  child: ModernActionButton(
                    text: 'Save Changes',
                    icon: Icons.save,
                    isPrimary: _hasChanges,
                    onPressed: _hasChanges ? _saveChanges : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: EdgeInsets.all(spacing_lg),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(radius_lg),
        border: Border.all(color: ColorTokens.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: ColorTokens.teal500,
                size: DesignTokens.iconMd,
              ),
              SizedBox(width: spacing_sm),
              Text(
                'Preview',
                style: TypographyTokens.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing_md),
          Wrap(
            spacing: spacing_md,
            runSpacing: spacing_md,
            children: AccountTypeTheme.defaultThemes.entries.take(4).map((entry) {
              final accountType = entry.key;
              final theme = _editedThemes[accountType] ?? entry.value;

              return Container(
                width: 80,
                padding: EdgeInsets.all(spacing_sm),
                decoration: BoxDecoration(
                  color: ColorTokens.surfacePrimary,
                  borderRadius: BorderRadius.circular(radius_md),
                  border: Border.all(color: ColorTokens.neutral200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.color,
                        borderRadius: BorderRadius.circular(radius_sm),
                      ),
                      child: Icon(
                        theme.iconData,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    SizedBox(height: spacing_xs),
                    Text(
                      theme.displayName,
                      style: TypographyTokens.captionMd,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    HapticFeedback.mediumImpact();
    setState(() {
      _editedThemes = Map.from(AccountTypeTheme.defaultThemes);
      _hasChanges = !_areThemesEqual(_editedThemes, widget.currentThemes);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reset to default themes'),
        backgroundColor: ColorTokens.info500,
      ),
    );
  }

  void _saveChanges() {
    HapticFeedback.mediumImpact();

    // Update settings
    ref.read(settingsNotifierProvider.notifier).updateSetting('accountTypeThemes', _editedThemes);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account themes updated successfully'),
        backgroundColor: ColorTokens.success500,
      ),
    );
  }

  bool _areThemesEqual(Map<String, AccountTypeTheme> a, Map<String, AccountTypeTheme> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key]!.colorValue != b[key]!.colorValue) return false;
    }

    return true;
  }
}

class _AccountTypeThemeEditor extends StatefulWidget {
  const _AccountTypeThemeEditor({
    required this.accountType,
    required this.theme,
    required this.onColorChanged,
  });

  final String accountType;
  final AccountTypeTheme theme;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_AccountTypeThemeEditor> createState() => _AccountTypeThemeEditorState();
}

class _AccountTypeThemeEditorState extends State<_AccountTypeThemeEditor> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.theme.color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spacing_md),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(radius_md),
        border: Border.all(color: ColorTokens.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Type Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(radius_md),
                ),
                child: Icon(
                  widget.theme.iconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: spacing_md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.theme.displayName,
                      style: TypographyTokens.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to change color',
                      style: TypographyTokens.captionMd.copyWith(
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing_md),

          // Color Picker
          ModernColorPicker(
            initialColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              widget.onColorChanged(color);
            },
          ),
        ],
      ),
    );
  }
}