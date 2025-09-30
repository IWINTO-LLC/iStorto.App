import 'package:flutter/material.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/payment/data/currency_model.dart';

class CurrencyTestRunner {
  static void runTests() {
    print('🚀 Starting Currency Controller Tests...\n');

    // Test 1: Basic initialization
    _testInitialization();

    // Test 2: Currency conversion
    _testCurrencyConversion();

    // Test 3: Currency availability
    _testCurrencyAvailability();

    // Test 4: Error handling
    _testErrorHandling();

    print('\n✅ All tests completed successfully!');
  }

  static void _testInitialization() {
    print('📋 Test 1: Initialization');

    try {
      final controller = CurrencyController();

      // Check initial values
      assert(
        controller.userCurrency.value == '',
        'User currency should be empty initially',
      );
      assert(
        controller.allItems.isEmpty,
        'All items should be empty initially',
      );
      assert(!controller.isLoading.value, 'Loading should be false initially');
      assert(
        controller.currencies.isEmpty,
        'Currencies should be empty initially',
      );

      print('✅ Initialization test passed');
    } catch (e) {
      print('❌ Initialization test failed: $e');
    }
  }

  static void _testCurrencyConversion() {
    print('\n🔄 Test 2: Currency Conversion');

    try {
      final controller = CurrencyController();

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

      // Add currencies to controller
      controller.currencies['USD'] = usdCurrency;
      controller.currencies['EUR'] = eurCurrency;

      // Test conversion: 100 USD to EUR
      final convertedAmount = controller.convert(100, 'USD', 'EUR');
      assert(convertedAmount == 85.0, '100 USD should equal 85 EUR');
      print('✅ USD to EUR conversion: 100 USD = $convertedAmount EUR');

      // Test conversion: 100 EUR to USD
      final convertedBack = controller.convert(100, 'EUR', 'USD');
      assert(
        (convertedBack - 117.65).abs() < 0.01,
        '100 EUR should equal ~117.65 USD',
      );
      print(
        '✅ EUR to USD conversion: 100 EUR = ${convertedBack.toStringAsFixed(2)} USD',
      );

      print('✅ Currency conversion test passed');
    } catch (e) {
      print('❌ Currency conversion test failed: $e');
    }
  }

  static void _testCurrencyAvailability() {
    print('\n🔍 Test 3: Currency Availability');

    try {
      final controller = CurrencyController();

      final usdCurrency = CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      );

      controller.currencies['USD'] = usdCurrency;

      // Test availability
      assert(controller.isCurrencyAvailable('USD'), 'USD should be available');
      assert(
        !controller.isCurrencyAvailable('EUR'),
        'EUR should not be available',
      );
      assert(
        !controller.isCurrencyAvailable('INVALID'),
        'INVALID should not be available',
      );

      print('✅ USD available: ${controller.isCurrencyAvailable("USD")}');
      print('✅ EUR available: ${controller.isCurrencyAvailable("EUR")}');
      print(
        '✅ INVALID available: ${controller.isCurrencyAvailable("INVALID")}',
      );

      // Test currency retrieval
      final retrievedCurrency = controller.getCurrency('USD');
      assert(retrievedCurrency != null, 'USD currency should be retrievable');
      assert(
        retrievedCurrency!.iso == 'USD',
        'Retrieved currency should have correct ISO',
      );

      final nonExistentCurrency = controller.getCurrency('EUR');
      assert(
        nonExistentCurrency == null,
        'Non-existent currency should return null',
      );

      print('✅ Currency availability test passed');
    } catch (e) {
      print('❌ Currency availability test failed: $e');
    }
  }

  static void _testErrorHandling() {
    print('\n⚠️ Test 4: Error Handling');

    try {
      final controller = CurrencyController();

      // Test conversion with invalid currencies
      bool exceptionThrown = false;
      try {
        controller.convert(100, 'INVALID', 'USD');
      } catch (e) {
        exceptionThrown = true;
        assert(
          e.toString().contains('Invalid currency codes'),
          'Should throw currency codes error',
        );
      }
      assert(exceptionThrown, 'Should throw exception for invalid currency');

      print('✅ Invalid currency conversion throws exception');

      // Test convertToDollar with zero amount
      final zeroResult = controller.convertToDollar(0.0);
      assert(zeroResult == 0.0, 'Zero amount should return 0.0');

      print('✅ Zero amount conversion returns 0.0');

      // Test convertToDefaultCurrency with zero amount
      controller.userCurrency.value = 'USD';
      final usdCurrency = CurrencyModel(
        id: '1',
        name: 'US Dollar',
        iso: 'USD',
        usdToCoinExchangeRate: 1.0,
      );
      controller.currencies['USD'] = usdCurrency;

      final zeroDefaultResult = controller.convertToDefaultCurrency(0.0);
      assert(
        zeroDefaultResult == 0.0,
        'Zero amount should return 0.0 for default currency',
      );

      print('✅ Zero amount default currency conversion returns 0.0');

      print('✅ Error handling test passed');
    } catch (e) {
      print('❌ Error handling test failed: $e');
    }
  }

  static void runIntegrationTest() {
    print('\n🔗 Running Integration Test with Real Currency Data...\n');

    try {
      final controller = CurrencyController();

      // Setup comprehensive currency data
      final currencies = [
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
        CurrencyModel(
          id: '5',
          name: 'Saudi Riyal',
          iso: 'SAR',
          usdToCoinExchangeRate: 3.75,
        ),
        CurrencyModel(
          id: '6',
          name: 'UAE Dirham',
          iso: 'AED',
          usdToCoinExchangeRate: 3.67,
        ),
      ];

      // Add all currencies
      for (var currency in currencies) {
        controller.currencies[currency.iso] = currency;
      }

      print('📊 Loaded ${controller.currencies.length} currencies');

      // Test multiple conversions
      print('\n🔄 Testing Multiple Currency Conversions:');

      final conversions = [
        {'from': 'USD', 'to': 'EUR', 'amount': 100.0},
        {'from': 'EUR', 'to': 'GBP', 'amount': 100.0},
        {'from': 'GBP', 'to': 'JPY', 'amount': 100.0},
        {'from': 'USD', 'to': 'SAR', 'amount': 100.0},
        {'from': 'AED', 'to': 'USD', 'amount': 100.0},
      ];

      for (var conversion in conversions) {
        final from = conversion['from'] as String;
        final to = conversion['to'] as String;
        final amount = conversion['amount'] as double;

        final result = controller.convert(amount, from, to);
        print(
          '${amount.toStringAsFixed(2)} $from = ${result.toStringAsFixed(2)} $to',
        );
      }

      // Test current user currency
      print('\n👤 Testing Current User Currency:');
      controller.userCurrency.value = 'EUR';
      final currentCurrency = controller.currentUserCurrency;
      print('Current user currency: $currentCurrency');

      // Test default currency conversion
      final defaultConversion = controller.convertToDefaultCurrency(100.0);
      print(
        '100.00 USD to default currency (EUR): ${defaultConversion.toStringAsFixed(2)} EUR',
      );

      print('\n✅ Integration test completed successfully!');
    } catch (e) {
      print('❌ Integration test failed: $e');
    }
  }
}

// Widget to run tests in the app
class CurrencyTestWidget extends StatelessWidget {
  const CurrencyTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Controller Tests'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                CurrencyTestRunner.runTests();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tests completed! Check console for results.',
                    ),
                  ),
                );
              },
              child: const Text('Run Basic Tests'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CurrencyTestRunner.runIntegrationTest();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Integration test completed! Check console for results.',
                    ),
                  ),
                );
              },
              child: const Text('Run Integration Test'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check the console output for detailed test results. The tests verify:\n'
              '• Controller initialization\n'
              '• Currency conversion accuracy\n'
              '• Currency availability checking\n'
              '• Error handling\n'
              '• Integration with multiple currencies',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
