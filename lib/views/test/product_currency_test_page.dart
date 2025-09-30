import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/services/product_currency_service.dart';
import 'package:istoreto/featured/product/widgets/currency_price_widget.dart';

class ProductCurrencyTestPage extends StatefulWidget {
  const ProductCurrencyTestPage({super.key});

  @override
  State<ProductCurrencyTestPage> createState() =>
      _ProductCurrencyTestPageState();
}

class _ProductCurrencyTestPageState extends State<ProductCurrencyTestPage> {
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final ProductCurrencyService currencyService =
      Get.find<ProductCurrencyService>();

  String selectedCurrency = 'USD';
  List<ProductModel> testProducts = [];
  String conversionResults = '';

  @override
  void initState() {
    super.initState();
    _loadTestProducts();
  }

  void _loadTestProducts() {
    // Create test products with different currencies
    testProducts = [
      ProductModel(
        id: '1',
        title: 'iPhone 15 Pro',
        description: 'Latest iPhone model',
        price: 999.00,
        oldPrice: 1099.00,
        currency: 'USD',
        vendorId: 'vendor1',
      ),
      ProductModel(
        id: '2',
        title: 'Samsung Galaxy S24',
        description: 'Premium Android phone',
        price: 899.00,
        oldPrice: 999.00,
        currency: 'EUR',
        vendorId: 'vendor1',
      ),
      ProductModel(
        id: '3',
        title: 'MacBook Pro M3',
        description: 'Powerful laptop for professionals',
        price: 1999.00,
        currency: 'GBP',
        vendorId: 'vendor1',
      ),
      ProductModel(
        id: '4',
        title: 'iPad Air',
        description: 'Versatile tablet',
        price: 599.00,
        currency: 'SAR',
        vendorId: 'vendor1',
      ),
      ProductModel(
        id: '5',
        title: 'AirPods Pro',
        description: 'Wireless earbuds',
        price: 249.00,
        oldPrice: 279.00,
        currency: 'AED',
        vendorId: 'vendor1',
      ),
    ];
  }

  void _testCurrencyConversions() {
    setState(() {
      conversionResults = 'Testing Currency Conversions:\n\n';
    });

    for (final product in testProducts) {
      try {
        final formattedPrice = currencyService.getFormattedPrice(
          product,
          selectedCurrency,
        );
        final hasDiscount = currencyService.hasDiscount(
          product,
          selectedCurrency,
        );
        final discountPercentage = currencyService.getDiscountPercentage(
          product,
          selectedCurrency,
        );

        setState(() {
          conversionResults += '${product.title}:\n';
          conversionResults += '  Original: ${product.formattedPrice}\n';
          conversionResults += '  Converted: $formattedPrice\n';
          if (hasDiscount) {
            conversionResults += '  Discount: $discountPercentage%\n';
          }
          conversionResults += '\n';
        });
      } catch (e) {
        setState(() {
          conversionResults += '${product.title}: Error - $e\n\n';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Currency Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Currency Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Currency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CurrencySelectorWidget(
                      currentCurrency: selectedCurrency,
                      onCurrencyChanged: (currency) {
                        setState(() {
                          selectedCurrency = currency;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Currency Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Currency Switch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CurrencyToggleWidget(
                      currentCurrency: selectedCurrency,
                      onCurrencyChanged: (currency) {
                        setState(() {
                          selectedCurrency = currency;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Products Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...testProducts.map((product) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: CurrencyPriceWidget(
                                    product: product,
                                    targetCurrency: selectedCurrency,
                                    showCurrencySymbol: true,
                                    showDiscountPercentage: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Original Currency: ${product.currency ?? 'USD'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Price Comparison
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Comparison',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (testProducts.isNotEmpty)
                      PriceComparisonWidget(
                        product: testProducts.first,
                        currencies: const ['USD', 'EUR', 'GBP', 'SAR', 'AED'],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Functions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testCurrencyConversions,
                            child: const Text('Test Conversions'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                conversionResults = '';
                              });
                            },
                            child: const Text('Clear Results'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Conversion Results
            if (conversionResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conversion Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                          conversionResults,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

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
          ],
        ),
      ),
    );
  }
}
