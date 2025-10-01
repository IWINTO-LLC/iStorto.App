import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/payment/data/currency_model.dart';
import 'package:istoreto/featured/payment/data/currency_repository.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/utils/logging/logger.dart';

class CurrencyController extends GetxController {
  static CurrencyController get instance => Get.find();
  final _repository = CurrencyRepository();
  final _client = SupabaseService.client;

  RxString userCurrency = ''.obs;
  RxList<CurrencyModel> allItems = <CurrencyModel>[].obs;
  RxBool isLoading = false.obs;
  RxMap<String, CurrencyModel> currencies = <String, CurrencyModel>{}.obs;

  //CurrencyController(this.currencies);

  double convert(double amount, String fromCurrency, String toCurrency) {
    if (!currencies.containsKey(fromCurrency) ||
        !currencies.containsKey(toCurrency)) {
      throw Exception("Invalid currency codes");
    }

    // Convert using the new exchange rate structure
    double amountInUSD =
        amount / currencies[fromCurrency]!.usdToCoinExchangeRate;
    return amountInUSD * currencies[toCurrency]!.usdToCoinExchangeRate;
  }

  double convertToDollar(double amount) {
    if (amount == 0.0) return 0.0;

    // Get USD currency from our currencies map
    final usdCurrency = currencies['USD'];
    if (usdCurrency == null) {
      throw Exception("USD currency not found");
    }

    return amount / usdCurrency.usdToCoinExchangeRate;
  }

  double convertToDefaultCurrency(double amount) {
    if (amount == 0.0) return 0.0;

    // Get user's default currency ISO code
    final defaultCurrencyISO =
        AuthController.instance.currentUser.value?.defaultCurrency;

    // إذا كان المستخدم زائر (غير مسجل) أو لم يحدد عملة افتراضية، استخدم الدولار
    String currencyToUse;
    if (defaultCurrencyISO == null || defaultCurrencyISO.isEmpty) {
      currencyToUse = 'USD'; // العملة الافتراضية للزوار
    } else {
      currencyToUse = defaultCurrencyISO;
    }

    // Get currency model from currencies map
    final defaultCurrency = currencies[currencyToUse];
    if (defaultCurrency == null) {
      throw Exception("Currency data not found for $currencyToUse");
    }

    return amount * defaultCurrency.usdToCoinExchangeRate;
  }

  Future<void> fetchAllCurrencies() async {
    try {
      isLoading.value = true;
      final fetchedCurrencies = await _repository.getAllCurrencies();

      allItems.value = fetchedCurrencies;

      // Update currencies map for quick access
      currencies.clear();
      for (var currency in fetchedCurrencies) {
        currencies[currency.iso] = currency;
      }

      isLoading.value = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching currencies: $e');
      }
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch currencies: ${e.toString()}');
    }
  }

  Future<Map<String, CurrencyModel>> fetchCurrencies() async {
    try {
      final currenciesList = await _repository.getAllCurrencies();
      final currenciesMap = <String, CurrencyModel>{};

      for (var currency in currenciesList) {
        currenciesMap[currency.iso] = currency;
      }

      return currenciesMap;
    } catch (e) {
      print("Error fetching currencies: $e");
      return {};
    }
  }

  Future<List<CurrencyModel>> getAllCurencies() async {
    try {
      final currenciesList = await _repository.getAllCurrencies();

      TLoggerHelper.info("=======Currencies Data==============");
      TLoggerHelper.info(currenciesList.toString());

      return currenciesList;
    } catch (e) {
      TLoggerHelper.error("Error getting currencies: $e");
      throw e.toString();
    }
  }

  Future<String?> getDefaultCurrency(String userId) async {
    try {
      // إذا كان المستخدم زائر (userId فارغ أو غير صالح)، استخدم الدولار
      if (userId.isEmpty) {
        userCurrency.value = 'USD';
        return 'USD';
      }

      final response =
          await _client
              .from('users')
              .select('default_currency')
              .eq('user_id', userId)
              .maybeSingle();

      if (response != null) {
        final defaultCurrency =
            response['default_currency'] as String? ?? 'USD';
        userCurrency.value = defaultCurrency;
        return defaultCurrency;
      } else {
        // إذا لم يتم العثور على المستخدم، استخدم الدولار كافتراضي
        userCurrency.value = 'USD';
        return 'USD';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting default currency: $e');
      }
      // في حالة الخطأ، استخدم الدولار كافتراضي
      userCurrency.value = 'USD';
      return 'USD';
    }
  }

  Future<void> updateDefaultCurrency(String userId, String newCurrency) async {
    try {
      await _client
          .from('users')
          .update({
            'default_currency': newCurrency,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      userCurrency.value = newCurrency;

      if (kDebugMode) {
        TLoggerHelper.info('Default Currency updated to $newCurrency');
      }
    } catch (e) {
      TLoggerHelper.error('Error while updating currency: $e');
      Get.snackbar('Error', 'Failed to update default currency');
    }
  }

  // Additional methods for currency management
  Future<void> refreshCurrencies() async {
    await fetchAllCurrencies();
  }

  Future<CurrencyModel?> getCurrencyByISO(String iso) async {
    return await _repository.getCurrencyByISO(iso);
  }

  Future<double?> convertCurrency(
    String fromISO,
    String toISO,
    double amount,
  ) async {
    return await _repository.convertCurrency(fromISO, toISO, amount);
  }

  Future<List<CurrencyModel>> getPopularCurrencies() async {
    return await _repository.getPopularCurrencies();
  }

  Future<Map<String, dynamic>> getCurrencyStatistics() async {
    return await _repository.getCurrencyStatistics();
  }

  // Get current user's default currency
  String get currentUserCurrency {
    // إذا كان المستخدم زائر أو لم يحدد عملة، استخدم الدولار
    if (userCurrency.value.isEmpty) {
      return 'USD';
    }
    return userCurrency.value;
  }

  // Check if currency is available
  bool isCurrencyAvailable(String iso) {
    return currencies.containsKey(iso);
  }

  // Get currency by ISO
  CurrencyModel? getCurrency(String iso) {
    return currencies[iso];
  }
}
