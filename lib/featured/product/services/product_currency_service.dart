import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';

class ProductCurrencyService extends GetxController {
  static ProductCurrencyService get instance => Get.find();

  final CurrencyController _currencyController = Get.find<CurrencyController>();

  // Convert product price to target currency
  double convertProductPrice(ProductModel product, String targetCurrency) {
    try {
      final productCurrency = product.currency ?? 'USD';

      // If same currency, return original price
      if (productCurrency.toUpperCase() == targetCurrency.toUpperCase()) {
        return product.price;
      }

      // Convert using currency controller
      return _currencyController.convert(
        product.price,
        productCurrency,
        targetCurrency,
      );
    } catch (e) {
      debugPrint('Error converting product price: $e');
      return product.price; // Return original price on error
    }
  }

  // Convert product old price to target currency
  double? convertProductOldPrice(ProductModel product, String targetCurrency) {
    try {
      if (product.oldPrice == null) return null;

      final productCurrency = product.currency ?? 'USD';

      // If same currency, return original old price
      if (productCurrency.toUpperCase() == targetCurrency.toUpperCase()) {
        return product.oldPrice;
      }

      // Convert using currency controller
      return _currencyController.convert(
        product.oldPrice!,
        productCurrency,
        targetCurrency,
      );
    } catch (e) {
      debugPrint('Error converting product old price: $e');
      return product.oldPrice; // Return original price on error
    }
  }

  // Get formatted price in target currency
  String getFormattedPrice(ProductModel product, String targetCurrency) {
    try {
      final convertedPrice = convertProductPrice(product, targetCurrency);
      final currencyModel = _currencyController.getCurrency(targetCurrency);

      if (currencyModel != null) {
        return currencyModel.getFormattedAmount(convertedPrice);
      } else {
        return '${convertedPrice.toStringAsFixed(2)} $targetCurrency';
      }
    } catch (e) {
      debugPrint('Error formatting product price: $e');
      return product.formattedPrice;
    }
  }

  // Get formatted old price in target currency
  String getFormattedOldPrice(ProductModel product, String targetCurrency) {
    try {
      final convertedOldPrice = convertProductOldPrice(product, targetCurrency);
      if (convertedOldPrice == null) return '';

      final currencyModel = _currencyController.getCurrency(targetCurrency);

      if (currencyModel != null) {
        return currencyModel.getFormattedAmount(convertedOldPrice);
      } else {
        return '${convertedOldPrice.toStringAsFixed(2)} $targetCurrency';
      }
    } catch (e) {
      debugPrint('Error formatting product old price: $e');
      return product.formattedOldPrice;
    }
  }

  // Convert list of products to target currency
  List<ProductModel> convertProductsCurrency(
    List<ProductModel> products,
    String targetCurrency,
  ) {
    return products.map((product) {
      try {
        final convertedPrice = convertProductPrice(product, targetCurrency);
        final convertedOldPrice = convertProductOldPrice(
          product,
          targetCurrency,
        );

        return product.copyWith(
          price: convertedPrice,
          oldPrice: convertedOldPrice,
          currency: targetCurrency,
        );
      } catch (e) {
        debugPrint('Error converting product ${product.id}: $e');
        return product; // Return original product on error
      }
    }).toList();
  }

  // Get currency symbol for target currency
  String getCurrencySymbol(String currency) {
    final currencyModel = _currencyController.getCurrency(currency);
    return currencyModel?.symbol ?? currency;
  }

  // Check if currency conversion is available
  bool canConvertCurrency(String fromCurrency, String toCurrency) {
    return _currencyController.isCurrencyAvailable(fromCurrency) &&
        _currencyController.isCurrencyAvailable(toCurrency);
  }

  // Get available currencies
  List<String> getAvailableCurrencies() {
    return _currencyController.currencies.keys.toList();
  }

  // Get user's preferred currency
  String getUserPreferredCurrency() {
    return _currencyController.currentUserCurrency.isNotEmpty
        ? _currencyController.currentUserCurrency
        : 'USD';
  }

  // Convert product to user's preferred currency
  ProductModel convertToUserCurrency(ProductModel product) {
    final userCurrency = getUserPreferredCurrency();
    return convertProductToCurrency(product, userCurrency);
  }

  // Convert product to specific currency
  ProductModel convertProductToCurrency(
    ProductModel product,
    String targetCurrency,
  ) {
    try {
      final convertedPrice = convertProductPrice(product, targetCurrency);
      final convertedOldPrice = convertProductOldPrice(product, targetCurrency);

      return product.copyWith(
        price: convertedPrice,
        oldPrice: convertedOldPrice,
        currency: targetCurrency,
      );
    } catch (e) {
      debugPrint('Error converting product to currency: $e');
      return product; // Return original product on error
    }
  }

  // Get price comparison between currencies
  Map<String, String> getPriceComparison(
    ProductModel product,
    List<String> currencies,
  ) {
    final comparison = <String, String>{};

    for (final currency in currencies) {
      try {
        final formattedPrice = getFormattedPrice(product, currency);
        comparison[currency] = formattedPrice;
      } catch (e) {
        debugPrint('Error getting price comparison for $currency: $e');
        comparison[currency] = 'N/A';
      }
    }

    return comparison;
  }

  // Calculate savings in target currency
  double? calculateSavings(ProductModel product, String targetCurrency) {
    try {
      if (product.oldPrice == null || product.oldPrice! <= 0) return null;

      final convertedPrice = convertProductPrice(product, targetCurrency);
      final convertedOldPrice = convertProductOldPrice(product, targetCurrency);

      if (convertedOldPrice == null) return null;

      return convertedOldPrice - convertedPrice;
    } catch (e) {
      debugPrint('Error calculating savings: $e');
      return null;
    }
  }

  // Get formatted savings in target currency
  String getFormattedSavings(ProductModel product, String targetCurrency) {
    try {
      final savings = calculateSavings(product, targetCurrency);
      if (savings == null || savings <= 0) return '';

      final currencyModel = _currencyController.getCurrency(targetCurrency);

      if (currencyModel != null) {
        return currencyModel.getFormattedAmount(savings);
      } else {
        return '${savings.toStringAsFixed(2)} $targetCurrency';
      }
    } catch (e) {
      debugPrint('Error formatting savings: $e');
      return '';
    }
  }

  // Check if product has discount in target currency
  bool hasDiscount(ProductModel product, String targetCurrency) {
    try {
      final savings = calculateSavings(product, targetCurrency);
      return savings != null && savings > 0;
    } catch (e) {
      debugPrint('Error checking discount: $e');
      return false;
    }
  }

  // Get discount percentage in target currency
  int getDiscountPercentage(ProductModel product, String targetCurrency) {
    try {
      final convertedOldPrice = convertProductOldPrice(product, targetCurrency);
      if (convertedOldPrice == null || convertedOldPrice <= 0) return 0;

      final convertedPrice = convertProductPrice(product, targetCurrency);
      return ((convertedOldPrice - convertedPrice) / convertedOldPrice * 100)
          .round();
    } catch (e) {
      debugPrint('Error calculating discount percentage: $e');
      return 0;
    }
  }

  // Initialize currency service
  Future<void> initialize() async {
    try {
      // Fetch currencies if not already loaded
      if (_currencyController.currencies.isEmpty) {
        await _currencyController.fetchAllCurrencies();
      }
    } catch (e) {
      debugPrint('Error initializing ProductCurrencyService: $e');
    }
  }
}
