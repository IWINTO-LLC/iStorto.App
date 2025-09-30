import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_test_runner.dart';
import 'package:istoreto/featured/payment/data/currency_model.dart';

class CurrencyTestPage extends StatefulWidget {
  const CurrencyTestPage({super.key});

  @override
  State<CurrencyTestPage> createState() => _CurrencyTestPageState();
}

class _CurrencyTestPageState extends State<CurrencyTestPage> {
  final CurrencyController currencyController = Get.put(CurrencyController());

  final TextEditingController amountController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  String conversionResult = '';
  String testResults = '';

  @override
  void initState() {
    super.initState();
    _loadMockCurrencies();
  }

  void _loadMockCurrencies() {
    // Load mock currencies for testing
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

    for (var currency in mockCurrencies) {
      currencyController.currencies[currency.iso] = currency;
    }

    setState(() {});
  }

  void _performConversion() {
    try {
      final amount = double.tryParse(amountController.text) ?? 0.0;
      final from = fromController.text.trim().toUpperCase();
      final to = toController.text.trim().toUpperCase();

      final result = currencyController.convert(amount, from, to);
      setState(() {
        conversionResult =
            '${amount.toStringAsFixed(2)} $from = ${result.toStringAsFixed(2)} $to';
      });
    } catch (e) {
      setState(() {
        conversionResult = 'Error: $e';
      });
    }
  }

  void _runTests() {
    setState(() {
      testResults = 'Running tests...\n';
    });

    // Capture test output (simplified version)
    final results = <String>[];

    try {
      // Test 1: Basic conversion
      final conversion = currencyController.convert(100, 'USD', 'EUR');
      results.add(
        '✅ USD to EUR: 100 USD = ${conversion.toStringAsFixed(2)} EUR',
      );

      // Test 2: Currency availability
      final usdAvailable = currencyController.isCurrencyAvailable('USD');
      results.add('✅ USD Available: $usdAvailable');

      // Test 3: Currency retrieval
      final usdCurrency = currencyController.getCurrency('USD');
      results.add('✅ USD Currency: ${usdCurrency?.name}');

      // Test 4: Error handling
      try {
        currencyController.convert(100, 'INVALID', 'USD');
        results.add('❌ Error handling: Should have thrown exception');
      } catch (e) {
        results.add('✅ Error handling: Exception thrown correctly');
      }

      setState(() {
        testResults = results.join('\n');
      });
    } catch (e) {
      setState(() {
        testResults = 'Test failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Controller Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Currency Conversion Test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Currency Conversion Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fromController,
                            decoration: const InputDecoration(
                              labelText: 'From (ISO)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: toController,
                            decoration: const InputDecoration(
                              labelText: 'To (ISO)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _performConversion,
                      child: const Text('Convert'),
                    ),
                    if (conversionResult.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        conversionResult,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Tests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            amountController.text = '100';
                            fromController.text = 'USD';
                            toController.text = 'EUR';
                            _performConversion();
                          },
                          child: const Text('100 USD → EUR'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            amountController.text = '100';
                            fromController.text = 'EUR';
                            toController.text = 'GBP';
                            _performConversion();
                          },
                          child: const Text('100 EUR → GBP'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            amountController.text = '100';
                            fromController.text = 'USD';
                            toController.text = 'SAR';
                            _performConversion();
                          },
                          child: const Text('100 USD → SAR'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            amountController.text = '100';
                            fromController.text = 'AED';
                            toController.text = 'USD';
                            _performConversion();
                          },
                          child: const Text('100 AED → USD'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _runTests,
                      child: const Text('Run All Tests'),
                    ),
                    if (testResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          testResults,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Available Currencies
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Currencies',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final currencies =
                          currencyController.currencies.values.toList();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            currencies.map((currency) {
                              return Chip(
                                label: Text(
                                  '${currency.iso} (${currency.name})',
                                ),
                                backgroundColor: Colors.blue[100],
                              );
                            }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Console Tests Button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Console Tests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Run comprehensive tests and check console output for detailed results.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            CurrencyTestRunner.runTests();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Basic tests completed! Check console.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text('Run Basic Tests'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            CurrencyTestRunner.runIntegrationTest();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Integration test completed! Check console.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text('Run Integration Test'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
}

