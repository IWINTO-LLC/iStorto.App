import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';

class BannerDebugPage extends StatefulWidget {
  const BannerDebugPage({super.key});

  @override
  State<BannerDebugPage> createState() => _BannerDebugPageState();
}

class _BannerDebugPageState extends State<BannerDebugPage> {
  final BannerController _controller = Get.put(BannerController());
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _debugInfo = 'Loading banners...';
    });

    try {
      await _controller.fetchAllBanners();

      setState(() {
        _debugInfo = '''
📊 Debug Info:
================
Total Banners: ${_controller.banners.length}
Active Banners: ${_controller.activeBanners.length}
Loading: ${_controller.isLoading.value}

📋 Banner Details:
${_controller.banners.isEmpty ? 'No banners found' : _controller.banners.map((banner) => '''
- ID: ${banner.id ?? 'NULL'}
- Title: ${banner.title ?? 'No title'}
- Scope: ${banner.scope.name}
- Active: ${banner.active}
- Vendor ID: ${banner.vendorId ?? 'NULL'}
''').join('\n')}
        ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = '❌ Error: $e\n\nStack trace:\n${StackTrace.current}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner Debug'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadBanners),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debug Info Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SelectableText(
                  _debugInfo.isEmpty ? 'Press refresh to load' : _debugInfo,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Quick Actions
            Text(
              'Quick Actions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _debugInfo = 'Testing Supabase connection...';
                });
                await _loadBanners();
              },
              icon: Icon(Icons.cloud),
              label: Text('Test Supabase Connection'),
            ),

            SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Controller Info',
                  'isLoading: ${_controller.isLoading.value}\n'
                      'Banners count: ${_controller.banners.length}',
                  duration: Duration(seconds: 5),
                );
              },
              icon: Icon(Icons.info),
              label: Text('Show Controller State'),
            ),

            SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _debugInfo = 'Adding test banner...';
                });
                await _controller.addCompanyBanner('gallery');
              },
              icon: Icon(Icons.add),
              label: Text('Try Add Banner (Gallery)'),
            ),
          ],
        ),
      ),
    );
  }
}
