import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../../../../core/design_system/typography_tokens.dart';
import '../providers/settings_providers.dart';

class CurrencySelectorSheet extends ConsumerStatefulWidget {
  const CurrencySelectorSheet({super.key, required this.currentCurrency});

  final String currentCurrency;

  @override
  ConsumerState<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends ConsumerState<CurrencySelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<CurrencyInfo> _filteredCurrencies;

  final List<CurrencyInfo> _currencies = [
    CurrencyInfo('USD', 'US Dollar', '\$', '🇺🇸'),
    CurrencyInfo('EUR', 'Euro', '€', '🇪🇺'),
    CurrencyInfo('GBP', 'British Pound', '£', '🇬🇧'),
    CurrencyInfo('CAD', 'Canadian Dollar', 'CA\$', '🇨🇦'),
    CurrencyInfo('AUD', 'Australian Dollar', 'A\$', '🇦🇺'),
    CurrencyInfo('JPY', 'Japanese Yen', '¥', '🇯🇵'),
    CurrencyInfo('NGN', 'Nigerian Naira', '₦', '🇳🇬'),
    CurrencyInfo('INR', 'Indian Rupee', '₹', '🇮🇳'),
    CurrencyInfo('CNY', 'Chinese Yuan', '¥', '🇨🇳'),
    CurrencyInfo('CHF', 'Swiss Franc', 'CHF', '🇨🇭'),
  ];

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = _currencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _currencies;
      } else {
        _filteredCurrencies = _currencies.where((currency) {
          return currency.code.toLowerCase().contains(query.toLowerCase()) ||
              currency.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(DesignTokens.spacing5),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: DesignTokens.spacing5),

                Text(
                  'Choose Currency',
                  style: TypographyTokens.heading4,
                ),
                SizedBox(height: DesignTokens.spacing4),

                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: ColorTokens.surfaceSecondary,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCurrencies,
                    decoration: InputDecoration(
                      hintText: 'Search currencies...',
                      hintStyle: TypographyTokens.bodyMd.copyWith(
                        color: ColorTokens.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: ColorTokens.textSecondary,
                        size: DesignTokens.iconMd,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing3,
                        vertical: DesignTokens.spacing3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Currency list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing5),
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final isSelected = currency.code == widget.currentCurrency;

                return Padding(
                  padding: EdgeInsets.only(bottom: DesignTokens.spacing2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(settingsNotifierProvider.notifier)
                            .updateCurrencyCode(currency.code);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      child: Container(
                        padding: EdgeInsets.all(DesignTokens.spacing3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ColorTokens.withOpacity(ColorTokens.teal500, 0.1)
                              : ColorTokens.surfaceSecondary,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          border: Border.all(
                            color: isSelected
                                ? ColorTokens.teal500
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ColorTokens.withOpacity(
                                  ColorTokens.teal500,
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currency.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            SizedBox(width: DesignTokens.spacing3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency.name,
                                    style: TypographyTokens.bodyLg.copyWith(
                                      fontWeight: isSelected
                                          ? TypographyTokens.weightBold
                                          : TypographyTokens.weightRegular,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${currency.code} (${currency.symbol})',
                                    style: TypographyTokens.captionMd.copyWith(
                                      color: isSelected
                                          ? ColorTokens.teal500
                                          : ColorTokens.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: ColorTokens.teal500,
                                size: DesignTokens.iconMd,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  CurrencyInfo(this.code, this.name, this.symbol, this.flag);
}