// Simple test runner for CurrencyController
// Run this file to test the currency controller functionality

import 'lib/featured/currency/controller/currency_test_runner.dart';

void main() {
  print('🧪 Currency Controller Test Suite');
  print('==================================\n');

  // Run basic tests
  CurrencyTestRunner.runTests();

  // Run integration tests
  CurrencyTestRunner.runIntegrationTest();

  print('\n🎉 All tests completed!');
}
