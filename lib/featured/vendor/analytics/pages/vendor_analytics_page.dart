import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/vendor/analytics/vendor_analytics_controller.dart';
import 'package:istoreto/featured/vendor/analytics/widgets/vendor_analytics_widgets.dart';

class VendorAnalyticsPage extends StatefulWidget {
  final String vendorId;

  const VendorAnalyticsPage({Key? key, required this.vendorId})
    : super(key: key);

  @override
  State<VendorAnalyticsPage> createState() => _VendorAnalyticsPageState();
}

class _VendorAnalyticsPageState extends State<VendorAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final analyticsController = Get.find<VendorAnalyticsController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Set vendor ID and load analytics
    analyticsController.setVendorId(widget.vendorId);
    analyticsController.loadVendorAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليلات التاجر'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'الملخص'),
            Tab(icon: Icon(Icons.trending_up), text: 'الأداء'),
            Tab(icon: Icon(Icons.warning), text: 'الانتباه'),
            Tab(icon: Icon(Icons.history), text: 'الأنشطة'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => analyticsController.refreshAll(),
          ),
        ],
      ),
      body: Obx(() {
        if (analyticsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            // Summary Tab
            _buildSummaryTab(),

            // Performance Tab
            _buildPerformanceTab(),

            // Attention Tab
            _buildAttentionTab(),

            // Activity Tab
            _buildActivityTab(),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const VendorSummaryCard(),
          const SizedBox(height: 16),
          const TopPerformingProductsList(),
          const SizedBox(height: 16),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const TopPerformingProductsList(),
          const SizedBox(height: 16),
          _buildEngagementChart(),
          const SizedBox(height: 16),
          _buildRevenueChart(),
        ],
      ),
    );
  }

  Widget _buildAttentionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ProductsNeedingAttentionList(),
          const SizedBox(height: 16),
          _buildConversionAnalysis(),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const RecentActivityList(),
          const SizedBox(height: 16),
          _buildActivityChart(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات سريعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _QuickStatItem(
                      title: 'المستخدمين الفريدين',
                      value: '${analyticsController.totalUniqueSavers}',
                      subtitle: 'حفظوا منتجاتك',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickStatItem(
                      title: 'معدل التفاعل',
                      value:
                          '${analyticsController.averageEngagementScore.toStringAsFixed(1)}',
                      subtitle: 'نقاط التفاعل',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نقاط التفاعل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final products =
                  analyticsController.topEngagementProducts.take(5).toList();
              if (products.isEmpty) {
                return const Center(child: Text('لا توجد بيانات متاحة'));
              }

              return Column(
                children:
                    products.map((product) {
                      final score =
                          (product['engagement_score'] as num?)?.toDouble() ??
                          0;
                      final maxScore =
                          products.first['engagement_score'] as num? ?? 1;
                      final percentage =
                          maxScore > 0 ? (score / maxScore) * 100 : 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                product['product_title'] ?? 'منتج غير محدد',
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  percentage > 70
                                      ? Colors.green
                                      : percentage > 40
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              score.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'القيمة المحتملة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final totalRevenue = analyticsController.totalPotentialRevenue;
              return Center(
                child: Column(
                  children: [
                    Text(
                      '${totalRevenue.toStringAsFixed(0)} ريال',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'إجمالي القيمة المحتملة',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تحليل معدل التحويل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final highSaveLowCart =
                  analyticsController.productsNeedingAttention;
              final highCartLowSave =
                  analyticsController.highCartLowSaveProducts;

              return Column(
                children: [
                  _AnalysisItem(
                    title: 'منتجات عالية الحفظ منخفضة السلة',
                    count: highSaveLowCart.length,
                    description: 'تحتاج تحسين في العرض أو السعر',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _AnalysisItem(
                    title: 'منتجات عالية السلة منخفضة الحفظ',
                    count: highCartLowSave.length,
                    description: 'أداء جيد في التحويل',
                    color: Colors.green,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نشاط المستخدمين',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final recentActivity = analyticsController.recentActivity;
              if (recentActivity.isEmpty) {
                return const Center(child: Text('لا توجد أنشطة حديثة'));
              }

              // Group activities by hour
              final Map<int, int> hourlyActivity = {};
              for (var activity in recentActivity) {
                final time = DateTime.parse(
                  activity['activity_time'].toString(),
                );
                final hour = time.hour;
                hourlyActivity[hour] = (hourlyActivity[hour] ?? 0) + 1;
              }

              return Column(
                children:
                    hourlyActivity.entries.toList().reversed.take(6).map((
                      entry,
                    ) {
                      final hour = entry.key;
                      final count = entry.value;
                      final maxCount = hourlyActivity.values.reduce(
                        (a, b) => a > b ? a : b,
                      );
                      final percentage =
                          maxCount > 0 ? (count / maxCount) * 100 : 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _QuickStatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AnalysisItem extends StatelessWidget {
  final String title;
  final int count;
  final String description;
  final Color color;

  const _AnalysisItem({
    required this.title,
    required this.count,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
