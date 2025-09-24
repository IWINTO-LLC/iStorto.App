import 'package:supabase_flutter/supabase_flutter.dart';
import 'currency_model.dart';

class CurrencyRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Create a new currency
  Future<CurrencyModel?> createCurrency(CurrencyModel currency) async {
    try {
      final currencyData = currency.toMap();
      currencyData['created_at'] = DateTime.now().toIso8601String();
      currencyData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('currencies')
              .insert(currencyData)
              .select()
              .single();

      return CurrencyModel.fromMap(response);
    } catch (e) {
      print('Error creating currency: $e');
      return null;
    }
  }

  // Get currency by ID
  Future<CurrencyModel?> getCurrencyById(String currencyId) async {
    try {
      final response =
          await _client
              .from('currencies')
              .select()
              .eq('id', currencyId)
              .maybeSingle();

      if (response == null) return null;
      return CurrencyModel.fromMap(response);
    } catch (e) {
      print('Error getting currency by ID: $e');
      return null;
    }
  }

  // Get currency by ISO code
  Future<CurrencyModel?> getCurrencyByISO(String iso) async {
    try {
      final response =
          await _client
              .from('currencies')
              .select()
              .eq('iso', iso.toUpperCase())
              .maybeSingle();

      if (response == null) return null;
      return CurrencyModel.fromMap(response);
    } catch (e) {
      print('Error getting currency by ISO: $e');
      return null;
    }
  }

  // Get all currencies
  Future<List<CurrencyModel>> getAllCurrencies() async {
    try {
      final response = await _client
          .from('currencies')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting all currencies: $e');
      return [];
    }
  }

  // Update currency
  Future<CurrencyModel?> updateCurrency(CurrencyModel currency) async {
    try {
      final currencyData = currency.toMap();
      currencyData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('currencies')
              .update(currencyData)
              .eq('id', currency.id!)
              .select()
              .single();

      return CurrencyModel.fromMap(response);
    } catch (e) {
      print('Error updating currency: $e');
      return null;
    }
  }

  // Delete currency
  Future<bool> deleteCurrency(String currencyId) async {
    try {
      await _client.from('currencies').delete().eq('id', currencyId);

      return true;
    } catch (e) {
      print('Error deleting currency: $e');
      return false;
    }
  }

  // Search currencies by name or ISO
  Future<List<CurrencyModel>> searchCurrencies(String query) async {
    try {
      final response = await _client
          .from('currencies')
          .select()
          .or('name.ilike.%$query%,iso.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error searching currencies: $e');
      return [];
    }
  }

  // Get currencies count
  Future<int> getCurrenciesCount() async {
    try {
      final response = await _client.from('currencies').select('id');

      return (response as List).length;
    } catch (e) {
      print('Error getting currencies count: $e');
      return 0;
    }
  }

  // Get currencies with pagination
  Future<List<CurrencyModel>> getCurrenciesPaginated({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('currencies')
          .select()
          .order('name', ascending: true)
          .range(page * limit, (page + 1) * limit - 1);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting currencies paginated: $e');
      return [];
    }
  }

  // Get currencies stream for real-time updates
  Stream<List<CurrencyModel>> getCurrenciesStream() {
    try {
      return _client
          .from('currencies')
          .stream(primaryKey: ['id'])
          .order('name', ascending: true)
          .map(
            (data) =>
                (data as List)
                    .map((currency) => CurrencyModel.fromMap(currency))
                    .toList(),
          );
    } catch (e) {
      print('Error getting currencies stream: $e');
      return Stream.value([]);
    }
  }

  // Update exchange rate
  Future<bool> updateExchangeRate(String currencyId, double newRate) async {
    try {
      await _client
          .from('currencies')
          .update({
            'usd_to_coin_exchange_rate': newRate,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currencyId);

      return true;
    } catch (e) {
      print('Error updating exchange rate: $e');
      return false;
    }
  }

  // Bulk update exchange rates
  Future<bool> bulkUpdateExchangeRates(Map<String, double> rateUpdates) async {
    try {
      for (var entry in rateUpdates.entries) {
        await _client
            .from('currencies')
            .update({
              'usd_to_coin_exchange_rate': entry.value,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('iso', entry.key);
      }
      return true;
    } catch (e) {
      print('Error bulk updating exchange rates: $e');
      return false;
    }
  }

  // Get popular currencies (most used)
  Future<List<CurrencyModel>> getPopularCurrencies() async {
    try {
      // This would typically be based on usage statistics
      // For now, return common currencies
      final commonISOs = ['USD', 'EUR', 'GBP', 'JPY', 'SAR', 'AED', 'EGP'];

      final response = await _client
          .from('currencies')
          .select()
          .inFilter('iso', commonISOs)
          .order('name', ascending: true);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting popular currencies: $e');
      return [];
    }
  }

  // Convert amount between currencies
  Future<double?> convertCurrency(
    String fromISO,
    String toISO,
    double amount,
  ) async {
    try {
      final fromCurrency = await getCurrencyByISO(fromISO);
      final toCurrency = await getCurrencyByISO(toISO);

      if (fromCurrency == null || toCurrency == null) {
        return null;
      }

      // Convert to USD first, then to target currency
      final usdAmount = fromCurrency.convertToUSD(amount);
      final convertedAmount = toCurrency.convertFromUSD(usdAmount);

      return convertedAmount;
    } catch (e) {
      print('Error converting currency: $e');
      return null;
    }
  }

  // Get currency statistics
  Future<Map<String, dynamic>> getCurrencyStatistics() async {
    try {
      final response = await _client
          .from('currencies')
          .select('iso, usd_to_coin_exchange_rate');

      final currencies =
          (response as List)
              .map((currency) => CurrencyModel.fromMap(currency))
              .toList();

      int totalCount = currencies.length;
      double averageRate =
          currencies.isNotEmpty
              ? currencies
                      .map((c) => c.usdToCoinExchangeRate)
                      .reduce((a, b) => a + b) /
                  currencies.length
              : 0.0;

      double highestRate =
          currencies.isNotEmpty
              ? currencies
                  .map((c) => c.usdToCoinExchangeRate)
                  .reduce((a, b) => a > b ? a : b)
              : 0.0;

      double lowestRate =
          currencies.isNotEmpty
              ? currencies
                  .map((c) => c.usdToCoinExchangeRate)
                  .reduce((a, b) => a < b ? a : b)
              : 0.0;

      return {
        'total_currencies': totalCount,
        'average_rate': averageRate,
        'highest_rate': highestRate,
        'lowest_rate': lowestRate,
      };
    } catch (e) {
      print('Error getting currency statistics: $e');
      return {};
    }
  }

  // Check if currency exists
  Future<bool> currencyExists(String iso) async {
    try {
      final response = await _client
          .from('currencies')
          .select('id')
          .eq('iso', iso.toUpperCase())
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking if currency exists: $e');
      return false;
    }
  }

  // Get currencies by exchange rate range
  Future<List<CurrencyModel>> getCurrenciesByRateRange(
    double minRate,
    double maxRate,
  ) async {
    try {
      final response = await _client
          .from('currencies')
          .select()
          .gte('usd_to_coin_exchange_rate', minRate)
          .lte('usd_to_coin_exchange_rate', maxRate)
          .order('usd_to_coin_exchange_rate', ascending: true);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting currencies by rate range: $e');
      return [];
    }
  }

  // Get user's default currency
  Future<String?> getUserDefaultCurrency(String userId) async {
    try {
      final response =
          await _client
              .from('users')
              .select('default_currency')
              .eq('user_id', userId)
              .maybeSingle();

      return response?['default_currency'] as String?;
    } catch (e) {
      print('Error getting user default currency: $e');
      return null;
    }
  }

  // Update user's default currency
  Future<bool> updateUserDefaultCurrency(
    String userId,
    String currencyISO,
  ) async {
    try {
      await _client
          .from('users')
          .update({
            'default_currency': currencyISO,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error updating user default currency: $e');
      return false;
    }
  }

  // Get currencies with real-time updates
  Stream<List<CurrencyModel>> watchCurrencies() {
    try {
      return _client
          .from('currencies')
          .stream(primaryKey: ['id'])
          .order('name', ascending: true)
          .map(
            (data) =>
                (data as List)
                    .map((currency) => CurrencyModel.fromMap(currency))
                    .toList(),
          );
    } catch (e) {
      print('Error watching currencies: $e');
      return Stream.value([]);
    }
  }

  // Get currency by name (case insensitive)
  Future<List<CurrencyModel>> getCurrenciesByName(String name) async {
    try {
      final response = await _client
          .from('currencies')
          .select()
          .ilike('name', '%$name%')
          .order('name', ascending: true);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting currencies by name: $e');
      return [];
    }
  }

  // Get active currencies (if you add an active field)
  Future<List<CurrencyModel>> getActiveCurrencies() async {
    try {
      final response = await _client
          .from('currencies')
          .select()
          .eq('active', true)
          .order('name', ascending: true);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting active currencies: $e');
      return [];
    }
  }

  // Bulk create currencies
  Future<bool> bulkCreateCurrencies(List<CurrencyModel> currencies) async {
    try {
      final currenciesData =
          currencies.map((currency) {
            final data = currency.toMap();
            data['created_at'] = DateTime.now().toIso8601String();
            data['updated_at'] = DateTime.now().toIso8601String();
            return data;
          }).toList();

      await _client.from('currencies').insert(currenciesData);

      return true;
    } catch (e) {
      print('Error bulk creating currencies: $e');
      return false;
    }
  }

  // Get currency conversion rate between two currencies
  Future<double?> getConversionRate(String fromISO, String toISO) async {
    try {
      final fromCurrency = await getCurrencyByISO(fromISO);
      final toCurrency = await getCurrencyByISO(toISO);

      if (fromCurrency == null || toCurrency == null) {
        return null;
      }

      // Convert to USD first, then to target currency
      return toCurrency.usdToCoinExchangeRate /
          fromCurrency.usdToCoinExchangeRate;
    } catch (e) {
      print('Error getting conversion rate: $e');
      return null;
    }
  }

  // Get currencies with pagination and filtering
  Future<List<CurrencyModel>> getCurrenciesFiltered({
    int page = 0,
    int limit = 20,
    String? searchQuery,
    double? minRate,
    double? maxRate,
    String? sortBy = 'name',
    bool ascending = true,
  }) async {
    try {
      var query = _client.from('currencies').select();

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,iso.ilike.%$searchQuery%');
      }

      if (minRate != null) {
        query = query.gte('usd_to_coin_exchange_rate', minRate);
      }

      if (maxRate != null) {
        query = query.lte('usd_to_coin_exchange_rate', maxRate);
      }

      // Apply sorting and pagination
      final response = await query
          .order(sortBy ?? 'name', ascending: ascending)
          .range(page * limit, (page + 1) * limit - 1);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting filtered currencies: $e');
      return [];
    }
  }

  // Get currency usage statistics (if you track usage)
  Future<Map<String, int>> getCurrencyUsageStats() async {
    try {
      // This would require a separate table to track currency usage
      // For now, return empty map
      return {};
    } catch (e) {
      print('Error getting currency usage stats: $e');
      return {};
    }
  }

  // Validate currency data
  bool validateCurrency(CurrencyModel currency) {
    return currency.name.isNotEmpty &&
        currency.iso.isNotEmpty &&
        currency.iso.length == 3 &&
        currency.usdToCoinExchangeRate > 0;
  }

  // Get currency exchange rate history (if you implement history tracking)
  Future<List<Map<String, dynamic>>> getCurrencyRateHistory(
    String currencyISO, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // This would require a separate table for rate history
      // For now, return empty list
      return [];
    } catch (e) {
      print('Error getting currency rate history: $e');
      return [];
    }
  }

  // Update multiple exchange rates at once
  Future<bool> updateMultipleExchangeRates(
    Map<String, double> rateUpdates,
  ) async {
    try {
      for (var entry in rateUpdates.entries) {
        await _client
            .from('currencies')
            .update({
              'usd_to_coin_exchange_rate': entry.value,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('iso', entry.key);
      }
      return true;
    } catch (e) {
      print('Error updating multiple exchange rates: $e');
      return false;
    }
  }

  // Get currency by partial ISO match
  Future<List<CurrencyModel>> getCurrenciesByPartialISO(
    String partialISO,
  ) async {
    try {
      final response = await _client
          .from('currencies')
          .select()
          .ilike('iso', '%$partialISO%')
          .order('iso', ascending: true);

      return (response as List)
          .map((currency) => CurrencyModel.fromMap(currency))
          .toList();
    } catch (e) {
      print('Error getting currencies by partial ISO: $e');
      return [];
    }
  }

  // Check if currency exists by ISO
  Future<bool> currencyExistsByISO(String iso) async {
    try {
      final response = await _client
          .from('currencies')
          .select('id')
          .eq('iso', iso.toUpperCase())
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking if currency exists by ISO: $e');
      return false;
    }
  }

  // Get currencies count with filters
  Future<int> getCurrenciesCountFiltered({
    String? searchQuery,
    double? minRate,
    double? maxRate,
  }) async {
    try {
      var query = _client.from('currencies').select('id');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,iso.ilike.%$searchQuery%');
      }

      if (minRate != null) {
        query = query.gte('usd_to_coin_exchange_rate', minRate);
      }

      if (maxRate != null) {
        query = query.lte('usd_to_coin_exchange_rate', maxRate);
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      print('Error getting filtered currencies count: $e');
      return 0;
    }
  }
}
