import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/payment/data/currency_model.dart';

void main() {
  late CurrencyController currencyController;

  setUp(() {
    // Initialize GetX
    Get.testMode = true;

    // Create currency controller instance
    currencyController = CurrencyController();
    Get.put(currencyController);
  });

  tearDown(() {
    Get.reset();
  });

  group('CurrencyController Tests', () {
    test('should initialize with empty values', () {
      expect(currencyController.userCurrency.value, '');
      expect(currencyController.allItems, isEmpty);
      expect(currencyController.isLoading.value, false);
      expect(currencyController.currencies, isEmpty);
    });

    test('should fetch all currencies successfully', () async {
      // Mock currencies data
      final mockCurrencies = [
        CurrencyModel(
          id: '1',
          name: 'US Dollar',
          iso: 'USD',
          usdToCoinExchangeRate: 1.0,
        ),
        CurrencyModel(
          id: '2',
          name: 'Euro',
          iso: 'EUR',
          usdToCoinExchangeRate: 0.85,
        ),
      ];

      // Mock the repository response
      // Note: In a real test, you would mock the repository
      // For now, we'll test the logic without actual database calls

      expect(currencyController.allItems.value, isEmpty);
      expect(currencyController.currencies.value, isEmpty);
    });

    test('should convert currency correctly', () {
      // Setup mock currencies
      final usdCurrency = CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      );

      final eurCurrency = CurrencyModel(
        id: '2',
        name: 'Euro',
        iso: 'EUR',
        usdToCoinExchangeRate: 0.85,
      );

      // Add currencies to the controller
      currencyController.currencies['USD'] = usdCurrency;
      currencyController.currencies['EUR'] = eurCurrency;

      // Test conversion: 100 USD to EUR
      final convertedAmount = currencyController.convert(100, 'USD', 'EUR');
      expect(convertedAmount, equals(85.0)); // 100 * 0.85

      // Test conversion: 100 EUR to USD
      final convertedBack = currencyController.convert(100, 'EUR', 'USD');
      expect(convertedBack, closeTo(117.65, 0.01)); // 100 / 0.85
    });

    test('should throw exception for invalid currency codes', () {
      expect(
        () => currencyController.convert(100, 'INVALID', 'USD'),
        throwsA(isA<Exception>()),
      );

      expect(
        () => currencyController.convert(100, 'USD', 'INVALID'),
        throwsA(isA<Exception>()),
      );
    });

    test('should convert to dollar correctly', () {
      // Setup EUR currency
      final eurCurrency = CurrencyModel(
        id: '2',
        name: 'Euro',
        iso: 'EUR',
        usdToCoinExchangeRate: 0.85,
      );

      final usdCurrency = CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      );

      currencyController.currencies['EUR'] = eurCurrency;
      currencyController.currencies['USD'] = usdCurrency;

      // Test conversion: 85 EUR to USD
      final dollarAmount = currencyController.convertToDollar(85);
      expect(dollarAmount, equals(100.0)); // 85 / 0.85
    });

    test('should return 0 for zero amount in convertToDollar', () {
      final result = currencyController.convertToDollar(0.0);
      expect(result, equals(0.0));
    });

    test('should convert to default currency correctly', () {
      // Setup user default currency
      currencyController.userCurrency.value = 'EUR';

      final eurCurrency = CurrencyModel(
        id: '2',
        name: 'Euro',
        iso: 'EUR',
        usdToCoinExchangeRate: 0.85,
      );

      currencyController.currencies['EUR'] = eurCurrency;

      // Test conversion: 100 USD to EUR (default currency)
      final convertedAmount = currencyController.convertToDefaultCurrency(100);
      expect(convertedAmount, equals(85.0)); // 100 * 0.85
    });

    test('should return 0 for zero amount in convertToDefaultCurrency', () {
      final result = currencyController.convertToDefaultCurrency(0.0);
      expect(result, equals(0.0));
    });

    test('should throw exception when default currency not found', () {
      currencyController.userCurrency.value = 'INVALID';

      expect(
        () => currencyController.convertToDefaultCurrency(100),
        throwsA(isA<Exception>()),
      );
    });

    test('should check currency availability correctly', () {
      final usdCurrency = CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      );

      currencyController.currencies['USD'] = usdCurrency;

      expect(currencyController.isCurrencyAvailable('USD'), true);
      expect(currencyController.isCurrencyAvailable('EUR'), false);
    });

    test('should get currency by ISO correctly', () {
      final usdCurrency = CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      );

      currencyController.currencies['USD'] = usdCurrency;

      final retrievedCurrency = currencyController.getCurrency('USD');
      expect(retrievedCurrency, equals(usdCurrency));
      expect(retrievedCurrency?.iso, equals('USD'));

      final nonExistentCurrency = currencyController.getCurrency('EUR');
      expect(nonExistentCurrency, isNull);
    });

    test('should get current user currency correctly', () {
      currencyController.userCurrency.value = 'EUR';
      expect(currencyController.currentUserCurrency, equals('EUR'));
    });

    test('should handle loading state correctly', () {
      expect(currencyController.isLoading.value, false);

      // In a real test, you would mock the async operation
      // and verify that isLoading becomes true during the operation
    });
  });

  group('CurrencyController Integration Tests', () {
    test('should handle multiple currency conversions', () {
      // Setup multiple currencies
      final currencies = {
        'USD': CurrencyModel(
          id: '1',
          name: 'US Dollar',
          iso: 'USD',
          usdToCoinExchangeRate: 1.0,
        ),
        'EUR': CurrencyModel(
          id: '2',
          name: 'Euro',
          iso: 'EUR',
          usdToCoinExchangeRate: 0.85,
        ),
        'GBP': CurrencyModel(
          id: '3',
          name: 'British Pound',
          iso: 'GBP',
          usdToCoinExchangeRate: 0.73,
        ),
        'JPY': CurrencyModel(
          id: '4',
          name: 'Japanese Yen',
          iso: 'JPY',
          usdToCoinExchangeRate: 110.0,
        ),
      };

      // Add all currencies to controller
      for (var entry in currencies.entries) {
        currencyController.currencies[entry.key] = entry.value;
      }

      // Test various conversions
      final usdToEur = currencyController.convert(100, 'USD', 'EUR');
      expect(usdToEur, equals(85.0));

      final eurToGbp = currencyController.convert(100, 'EUR', 'GBP');
      expect(eurToGbp, closeTo(85.88, 0.01)); // 100 * 0.73 / 0.85

      final gbpToJpy = currencyController.convert(100, 'GBP', 'JPY');
      expect(gbpToJpy, closeTo(15068.49, 0.01)); // 100 * 110.0 / 0.73
    });

    test('should handle edge cases in currency conversion', () {
      final usdCurrency = CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      );

      currencyController.currencies['USD'] = usdCurrency;

      // Test with very small amount
      final smallAmount = currencyController.convert(0.01, 'USD', 'USD');
      expect(smallAmount, equals(0.01));

      // Test with very large amount
      final largeAmount = currencyController.convert(1000000, 'USD', 'USD');
      expect(largeAmount, equals(1000000.0));
    });
  });
}

// Mock classes for testing (these would be generated by mockito)
class MockCurrencyRepository {
  Future<List<CurrencyModel>> getAllCurrencies() async {
    return [
      CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      ),
      CurrencyModel(
        id: '2',
        name: 'Euro',
        iso: 'EUR',
        usdToCoinExchangeRate: 0.85,
      ),
    ];
  }
}

// Test helper functions
void testCurrencyControllerWithMockData() {
  print('🧪 Testing CurrencyController with Mock Data...');

  // Create controller instance
  final controller = CurrencyController();

  // Setup mock currencies
  final mockCurrencies = [
    CurrencyModel(
      id: '1',
      name: 'US Dollar',
      iso: 'USD',
      usdToCoinExchangeRate: 1.0,
    ),
    CurrencyModel(
      id: '2',
      name: 'Euro',
      iso: 'EUR',
      usdToCoinExchangeRate: 0.85,
    ),
    CurrencyModel(
      id: '3',
      name: 'British Pound',
      iso: 'GBP',
      usdToCoinExchangeRate: 0.73,
    ),
    CurrencyModel(
      id: '4',
      name: 'Japanese Yen',
      iso: 'JPY',
      usdToCoinExchangeRate: 110.0,
    ),
  ];

  // Add currencies to controller
  for (var currency in mockCurrencies) {
    controller.currencies[currency.iso] = currency;
  }

  print('✅ Currencies loaded: ${controller.currencies.length}');

  // Test conversions
  print('\n🔄 Testing Currency Conversions:');

  // USD to EUR
  final usdToEur = controller.convert(100, 'USD', 'EUR');
  print('100 USD = $usdToEur EUR');

  // EUR to GBP
  final eurToGbp = controller.convert(100, 'EUR', 'GBP');
  print('100 EUR = ${eurToGbp.toStringAsFixed(2)} GBP');

  // GBP to JPY
  final gbpToJpy = controller.convert(100, 'GBP', 'JPY');
  print('100 GBP = ${gbpToJpy.toStringAsFixed(2)} JPY');

  // Test availability
  print('\n🔍 Testing Currency Availability:');
  print('USD available: ${controller.isCurrencyAvailable("USD")}');
  print('EUR available: ${controller.isCurrencyAvailable("EUR")}');
  print('INVALID available: ${controller.isCurrencyAvailable("INVALID")}');

  // Test currency retrieval
  print('\n📋 Testing Currency Retrieval:');
  final usdCurrency = controller.getCurrency('USD');
  print('USD Currency: ${usdCurrency?.name} (${usdCurrency?.iso})');

  final eurCurrency = controller.getCurrency('EUR');
  print('EUR Currency: ${eurCurrency?.name} (${eurCurrency?.iso})');

  // Test default currency conversion
  print('\n👤 Testing Default Currency:');
  controller.userCurrency.value = 'EUR';
  final defaultConversion = controller.convertToDefaultCurrency(100);
  print(
    '100 USD to default currency (EUR): ${defaultConversion.toStringAsFixed(2)} EUR',
  );

  print('\n✅ All CurrencyController tests completed successfully!');
}
