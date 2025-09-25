// lib/examples/test_connection_page.dart
import 'package:flutter/material.dart';

import 'test_supabase_connection.dart';

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  State<TestConnectionPage> createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _testResults = 'No tests run yet';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Supabase Connection'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase Connection Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Test buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _runBasicTest,
                  child: const Text('Basic Connection Test'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _runTableTest,
                  child: const Text('Categories Table Test'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _runInsertTest,
                  child: const Text('Insert Test'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _runAllTests,
                  child: const Text('Run All Tests'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 16),

            // Results
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Clear button
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _testResults = 'No tests run yet';
                  });
                },
                child: const Text('Clear Results'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runBasicTest() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running basic connection test...\n';
    });

    try {
      await TestSupabaseConnection.testConnection();
      setState(() {
        _testResults += '\n✅ Basic test completed successfully!';
      });
    } catch (e) {
      setState(() {
        _testResults += '\n❌ Basic test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runTableTest() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running categories table test...\n';
    });

    try {
      await TestSupabaseConnection.testCategoriesTable();
      setState(() {
        _testResults += '\n✅ Table test completed successfully!';
      });
    } catch (e) {
      setState(() {
        _testResults += '\n❌ Table test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runInsertTest() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running insert test...\n';
    });

    try {
      await TestSupabaseConnection.testInsertData();
      setState(() {
        _testResults += '\n✅ Insert test completed successfully!';
      });
    } catch (e) {
      setState(() {
        _testResults += '\n❌ Insert test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running all tests...\n';
    });

    try {
      await TestSupabaseConnection.testConnection();
      _testResults += '\n---\n';
      await TestSupabaseConnection.testCategoriesTable();
      _testResults += '\n---\n';
      await TestSupabaseConnection.testInsertData();

      setState(() {
        _testResults += '\n✅ All tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        _testResults += '\n❌ Some tests failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
