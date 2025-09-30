import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/services/product_currency_service.dart';
import 'package:istoreto/utils/constants/color.dart';

class CurrencyPriceWidget extends StatelessWidget {
  final ProductModel product;
  final String? targetCurrency;
  final TextStyle? priceStyle;
  final TextStyle? oldPriceStyle;
  final TextStyle? currencyStyle;
  final bool showCurrencySymbol;
  final bool showDiscountPercentage;
  final bool showSavings;
  final VoidCallback? onCurrencyChanged;

  const CurrencyPriceWidget({
    super.key,
    required this.product,
    this.targetCurrency,
    this.priceStyle,
    this.oldPriceStyle,
    this.currencyStyle,
    this.showCurrencySymbol = true,
    this.showDiscountPercentage = true,
    this.showSavings = false,
    this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currencyService = Get.find<ProductCurrencyService>();
    final currencyController = Get.find<CurrencyController>();

    final displayCurrency =
        targetCurrency ?? currencyController.currentUserCurrency;

    return Obx(() {
      try {
        final formattedPrice = currencyService.getFormattedPrice(
          product,
          displayCurrency,
        );
        final formattedOldPrice = currencyService.getFormattedOldPrice(
          product,
          displayCurrency,
        );
        final hasDiscount = currencyService.hasDiscount(
          product,
          displayCurrency,
        );
        final discountPercentage = currencyService.getDiscountPercentage(
          product,
          displayCurrency,
        );
        final formattedSavings = currencyService.getFormattedSavings(
          product,
          displayCurrency,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main price
            Row(
              children: [
                Text(
                  formattedPrice,
                  style:
                      priceStyle ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
                if (showCurrencySymbol && onCurrencyChanged != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onCurrencyChanged,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayCurrency,
                            style:
                                currencyStyle ??
                                TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: TColors.primary,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: TColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Old price and discount
            if (hasDiscount && formattedOldPrice.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    formattedOldPrice,
                    style:
                        oldPriceStyle ??
                        TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                  ),
                  if (showDiscountPercentage) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discountPercentage%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Savings
            if (showSavings && formattedSavings.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'You save: $formattedSavings',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      } catch (e) {
        debugPrint('Error displaying price: $e');
        // Fallback to original price
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.formattedPrice,
              style:
                  priceStyle ??
                  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
            ),
            if (product.formattedOldPrice.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                product.formattedOldPrice,
                style:
                    oldPriceStyle ??
                    TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        );
      }
    });
  }
}

class CurrencySelectorWidget extends StatelessWidget {
  final String currentCurrency;
  final Function(String) onCurrencyChanged;
  final List<String> availableCurrencies;

  const CurrencySelectorWidget({
    super.key,
    required this.currentCurrency,
    required this.onCurrencyChanged,
    this.availableCurrencies = const ['USD', 'EUR', 'GBP', 'SAR', 'AED'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: currentCurrency,
        underline: const SizedBox(),
        isExpanded: true,
        items:
            availableCurrencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Row(
                  children: [
                    Text(currency),
                    const SizedBox(width: 8),
                    Text(
                      _getCurrencySymbol(currency),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            onCurrencyChanged(value);
          }
        },
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'EGP':
        return 'ج.م';
      default:
        return currency;
    }
  }
}

class PriceComparisonWidget extends StatelessWidget {
  final ProductModel product;
  final List<String> currencies;
  final TextStyle? textStyle;

  const PriceComparisonWidget({
    super.key,
    required this.product,
    this.currencies = const ['USD', 'EUR', 'GBP', 'SAR'],
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final currencyService = Get.find<ProductCurrencyService>();

    return Obx(() {
      final comparison = currencyService.getPriceComparison(
        product,
        currencies,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Comparison',
            style:
                textStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...comparison.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${entry.key}:'),
                  Text(
                    entry.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    });
  }
}

class CurrencyToggleWidget extends StatelessWidget {
  final String currentCurrency;
  final Function(String) onCurrencyChanged;
  final List<String> supportedCurrencies;

  const CurrencyToggleWidget({
    super.key,
    required this.currentCurrency,
    required this.onCurrencyChanged,
    this.supportedCurrencies = const ['USD', 'EUR', 'GBP', 'SAR', 'AED'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: supportedCurrencies.length,
        itemBuilder: (context, index) {
          final currency = supportedCurrencies[index];
          final isSelected = currency == currentCurrency;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onCurrencyChanged(currency),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? TColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? TColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  currency,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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

