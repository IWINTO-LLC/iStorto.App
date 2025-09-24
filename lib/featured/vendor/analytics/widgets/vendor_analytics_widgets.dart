import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/vendor/analytics/vendor_analytics_controller.dart';

/// Widget to display vendor summary analytics
class VendorSummaryCard extends StatelessWidget {
  const VendorSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<VendorAnalyticsController>();

    return Obx(() {
      final summary = analytics.vendorSummary.value;
      if (summary == null) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملخص الأداء',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي المنتجات',
                      value: '${summary['total_products'] ?? 0}',
                      icon: Icons.inventory,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: 'المنتجات المحفوظة',
                      value: '${summary['total_saves'] ?? 0}',
                      icon: Icons.bookmark,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إضافة للسلة',
                      value: '${summary['total_cart_additions'] ?? 0}',
                      icon: Icons.shopping_cart,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: 'القيمة المحتملة',
                      value: '${analytics.totalPotentialRevenue.toStringAsFixed(0)} ريال',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Widget to display top performing products
class TopPerformingProductsList extends StatelessWidget {
  const TopPerformingProductsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<VendorAnalyticsController>();

    return Obx(() {
      if (analytics.isLoadingTopProducts.value) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final products = analytics.topPerformingProducts;
      if (products.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('لا توجد منتجات متاحة'),
            ),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أفضل المنتجات أداءً',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...products.take(5).map((product) => _ProductAnalyticsTile(
                product: product,
                showEngagement: true,
              )),
            ],
          ),
        ),
      );
    });
  }
}

/// Widget to display products needing attention
class ProductsNeedingAttentionList extends StatelessWidget {
  const ProductsNeedingAttentionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<VendorAnalyticsController>();

    return Obx(() {
      final products = analytics.productsNeedingAttention;
      if (products.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('جميع المنتجات تعمل بشكل جيد!'),
            ),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'منتجات تحتاج انتباه',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'منتجات عالية الحفظ ولكن منخفضة الإضافة للسلة',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...products.take(3).map((product) => _ProductAnalyticsTile(
                product: product,
                showConversion: true,
              )),
            ],
          ),
        ),
      );
    });
  }
}

/// Widget to display recent activity
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<VendorAnalyticsController>();

    return Obx(() {
      if (analytics.isLoadingRecentActivity.value) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final activities = analytics.recentActivity;
      if (activities.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('لا توجد أنشطة حديثة'),
            ),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الأنشطة الحديثة (آخر 24 ساعة)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...activities.take(5).map((activity) => _ActivityTile(
                activity: activity,
              )),
            ],
          ),
        ),
      );
    });
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Product analytics tile widget
class _ProductAnalyticsTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool showEngagement;
  final bool showConversion;

  const _ProductAnalyticsTile({
    required this.product,
    this.showEngagement = false,
    this.showConversion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image),
                    ),
                  )
                : const Icon(Icons.image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['product_title'] ?? 'منتج غير محدد',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MetricChip(
                      label: 'حفظ',
                      value: '${product['times_saved'] ?? 0}',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _MetricChip(
                      label: 'سلة',
                      value: '${product['times_in_cart'] ?? 0}',
                      color: Colors.green,
                    ),
                    if (showEngagement) ...[
                      const SizedBox(width: 8),
                      _MetricChip(
                        label: 'تفاعل',
                        value: '${(product['engagement_score'] ?? 0).toStringAsFixed(1)}',
                        color: Colors.purple,
                      ),
                    ],
                  ],
                ),
                if (showConversion) ...[
                  const SizedBox(height: 4),
                  Text(
                    'معدل التحويل: ${_calculateConversionRate(product)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateConversionRate(Map<String, dynamic> product) {
    final saves = (product['times_saved'] as num?)?.toInt() ?? 0;
    final carts = (product['times_in_cart'] as num?)?.toInt() ?? 0;
    if (saves == 0) return '0';
    return ((carts / saves) * 100).toStringAsFixed(1);
  }
}

/// Activity tile widget
class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final type = activity['activity_type'] as String?;
    final isSaved = type == 'saved';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSaved ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSaved ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSaved ? Icons.bookmark : Icons.shopping_cart,
            color: isSaved ? Colors.orange : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['product_title'] ?? 'منتج غير محدد',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity['user_count'] ?? 0} مستخدم - ${activity['total_quantity'] ?? 0} كمية',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(activity['activity_time']),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final time = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final difference = now.difference(time);
      
      if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else {
        return 'منذ ${difference.inDays} يوم';
      }
    } catch (e) {
      return '';
    }
  }
}

/// Metric chip widget
class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
