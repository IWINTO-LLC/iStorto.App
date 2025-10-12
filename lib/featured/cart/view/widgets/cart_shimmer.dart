import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';

/// Shimmer effect for cart screen while loading
class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان "منتجات حسب المتاجر"
          const TShimmerEffect(width: 180, height: 20),
          const SizedBox(height: 16),

          // Vendor Block 1
          _buildVendorBlockShimmer(),
          const SizedBox(height: 16),

          // Vendor Block 2
          _buildVendorBlockShimmer(),
          const SizedBox(height: 16),

          // Vendor Block 3
          _buildVendorBlockShimmer(),
        ],
      ),
    );
  }

  Widget _buildVendorBlockShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor Header
          Row(
            children: [
              TShimmerEffect(
                width: 50,
                height: 50,
                raduis: BorderRadius.circular(25),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TShimmerEffect(width: 120, height: 16),
                  SizedBox(height: 8),
                  TShimmerEffect(width: 80, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Product Item 1
          _buildProductItemShimmer(),
          const SizedBox(height: 12),

          // Product Item 2
          _buildProductItemShimmer(),
          const SizedBox(height: 16),

          // Total and Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TShimmerEffect(width: 100, height: 24),
              TShimmerEffect(
                width: 120,
                height: 40,
                raduis: BorderRadius.circular(30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductItemShimmer() {
    return Row(
      children: [
        // Product Image
        TShimmerEffect(width: 80, height: 80, raduis: BorderRadius.circular(8)),
        const SizedBox(width: 12),

        // Product Info
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TShimmerEffect(width: double.infinity, height: 16),
              SizedBox(height: 8),
              TShimmerEffect(width: 100, height: 14),
              SizedBox(height: 8),
              TShimmerEffect(width: 60, height: 12),
            ],
          ),
        ),

        // Quantity Controls
        TShimmerEffect(
          width: 80,
          height: 32,
          raduis: BorderRadius.circular(16),
        ),
      ],
    );
  }
}
