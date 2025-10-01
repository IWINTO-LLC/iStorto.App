import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// مكون Shimmer لتحميل الملف الشخصي
class UserProfileShimmerWidget extends StatelessWidget {
  const UserProfileShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Shimmer للرأس
          _buildHeaderShimmer(),

          // Shimmer للمحتوى
          _buildContentShimmer(),

          // Shimmer للأزرار
          _buildActionsShimmer(),
        ],
      ),
    );
  }

  /// بناء Shimmer للرأس
  Widget _buildHeaderShimmer() {
    return SizedBox(
      height: 280,
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

          // Shimmer للصورة الشخصية
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
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer لقسم "حول"
            _buildSectionShimmer(),
            SizedBox(height: 24),
            _buildSectionShimmer(),
          ],
        ),
      ),
    );
  }

  /// بناء Shimmer للأزرار
  Widget _buildActionsShimmer() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildActionButtonShimmer(),
          SizedBox(height: 12),
          _buildActionButtonShimmer(),
          SizedBox(height: 12),
          _buildActionButtonShimmer(),
        ],
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

  /// بناء Shimmer للقسم
  Widget _buildSectionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 12),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء Shimmer لزر الإجراء
  Widget _buildActionButtonShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
