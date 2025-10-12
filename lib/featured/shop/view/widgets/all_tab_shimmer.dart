import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:sizer/sizer.dart';

/// Shimmer effect for AllTab widget in market place
/// Matches the structure: Banner -> Categories -> Products Grid -> Sectors
class AllTabShimmer extends StatelessWidget {
  const AllTabShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner Slider Shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TShimmerEffect(
            width: double.infinity,
            height: 180,
            raduis: BorderRadius.circular(16),
          ),
        ),

        const SizedBox(height: 16),

        // Categories Section Shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories Title
              const TShimmerEffect(width: 150, height: 20),
              const SizedBox(height: 12),

              // Categories List
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        TShimmerEffect(
                          width: 70,
                          height: 70,
                          raduis: BorderRadius.circular(35),
                        ),
                        const SizedBox(height: 8),
                        const TShimmerEffect(width: 70, height: 12),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Products Grid Shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Products Title
              const TShimmerEffect(width: 120, height: 20),
              const SizedBox(height: 12),

              // Products Grid (2 rows x 2 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _buildProductCardShimmer();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sector 1 Shimmer
        _buildSectorShimmer(),

        const SizedBox(height: 16),

        // Sector 2 Shimmer
        _buildSectorShimmer(),
      ],
    );
  }

  Widget _buildProductCardShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          TShimmerEffect(
            width: double.infinity,
            height: 120,
            raduis: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),

          // Product Info
          const Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TShimmerEffect(width: double.infinity, height: 14),
                SizedBox(height: 6),
                TShimmerEffect(width: 80, height: 12),
                SizedBox(height: 6),
                TShimmerEffect(width: 60, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sector Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TShimmerEffect(width: 150, height: 20),
              TShimmerEffect(width: 80, height: 16),
            ],
          ),
          const SizedBox(height: 12),

          // Sector Items
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return TShimmerEffect(
                  width: 70.w,
                  height: 200,
                  raduis: BorderRadius.circular(12),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
