import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// مكون Shimmer لتحميل صفحة المتجر
class MarketPlaceShimmerWidget extends StatelessWidget {
  const MarketPlaceShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Shimmer للرأس
          _buildHeaderShimmer(),

          SizedBox(height: 28),

          // Shimmer للمحتوى
          _buildContentShimmer(),
        ],
      ),
    );
  }

  /// بناء Shimmer للرأس
  Widget _buildHeaderShimmer() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Shimmer لصورة الغلاف
          Positioned.fill(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(color: Colors.grey.shade300),
            ),
          ),

          // Shimmer للشعار
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),

          // Shimmer للمعلومات
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 200,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Shimmer للأزرار
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButtonShimmer(),
                    SizedBox(width: 20),
                    _buildButtonShimmer(),
                    SizedBox(width: 20),
                    _buildButtonShimmer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء Shimmer للمحتوى
  Widget _buildContentShimmer() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Shimmer للتبويبات
          _buildTabsShimmer(),
          SizedBox(height: 20),

          // Shimmer للمنتجات
          _buildProductsShimmer(),
        ],
      ),
    );
  }

  /// بناء Shimmer للتبويبات
  Widget _buildTabsShimmer() {
    return Row(
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء Shimmer للمنتجات
  Widget _buildProductsShimmer() {
    return Column(
      children: [
        // Shimmer لصف المنتجات الأول
        Row(
          children: [
            Expanded(child: _buildProductCardShimmer()),
            SizedBox(width: 12),
            Expanded(child: _buildProductCardShimmer()),
          ],
        ),
        SizedBox(height: 12),

        // Shimmer لصف المنتجات الثاني
        Row(
          children: [
            Expanded(child: _buildProductCardShimmer()),
            SizedBox(width: 12),
            Expanded(child: _buildProductCardShimmer()),
          ],
        ),
        SizedBox(height: 12),

        // Shimmer لصف المنتجات الثالث
        Row(
          children: [
            Expanded(child: _buildProductCardShimmer()),
            SizedBox(width: 12),
            Expanded(child: _buildProductCardShimmer()),
          ],
        ),
      ],
    );
  }

  /// بناء Shimmer لبطاقة المنتج
  Widget _buildProductCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Shimmer لصورة المنتج
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 8),

            // Shimmer للنص
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
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

  /// بناء Shimmer للزر
  Widget _buildButtonShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
