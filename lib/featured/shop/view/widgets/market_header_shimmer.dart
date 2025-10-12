import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:sizer/sizer.dart';

/// Shimmer effect for MarketHeader widget
/// Matches the exact design of the actual MarketHeader
class MarketHeaderShimmer extends StatelessWidget {
  const MarketHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Header with Cover Image Shimmer
        SizedBox(
          height: 40.h + 55,
          child: Stack(
            children: [
              // Cover Image Shimmer
              Container(
                width: 100.w,
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: const TShimmerEffect(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              // Top Action Buttons Shimmer
              Positioned(
                top: 30,
                right: 20,
                child: Row(
                  children: [
                    // Share Button Shimmer
                    TShimmerEffect(
                      width: 44,
                      height: 44,
                      raduis: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 12),
                    // Settings Button Shimmer
                    TShimmerEffect(
                      width: 44,
                      height: 44,
                      raduis: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ),

              // Left Action Buttons Shimmer (Profile, Search)
              Positioned(
                top: 30,
                left: 20,
                child: Row(
                  children: [
                    TShimmerEffect(
                      width: 44,
                      height: 44,
                      raduis: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 12),
                    TShimmerEffect(
                      width: 44,
                      height: 44,
                      raduis: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ),

              // Vendor Logo Shimmer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      // Logo Circle Shimmer
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: TShimmerEffect(
                            width: 120,
                            height: 120,
                            raduis: BorderRadius.circular(60),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content Section Shimmer
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vendor Name Shimmer
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TShimmerEffect(width: 200, height: 24),
                  SizedBox(width: 8),
                  TShimmerEffect(width: 20, height: 20), // Verified badge
                ],
              ),

              const SizedBox(height: 8),

              // Brief Description Shimmer
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TShimmerEffect(width: double.infinity, height: 16),
                    SizedBox(height: 6),
                    TShimmerEffect(width: 250, height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Row Shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCardShimmer(),
                  _buildStatCardShimmer(),
                  _buildStatCardShimmer(),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons Row Shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TShimmerEffect(
                    width: 100,
                    height: 40,
                    raduis: BorderRadius.circular(20),
                  ),
                  TShimmerEffect(
                    width: 100,
                    height: 40,
                    raduis: BorderRadius.circular(20),
                  ),
                  TShimmerEffect(
                    width: 100,
                    height: 40,
                    raduis: BorderRadius.circular(20),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Social Links Shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TShimmerEffect(
                    width: 32,
                    height: 32,
                    raduis: BorderRadius.circular(16),
                  ),
                  const SizedBox(width: 12),
                  TShimmerEffect(
                    width: 32,
                    height: 32,
                    raduis: BorderRadius.circular(16),
                  ),
                  const SizedBox(width: 12),
                  TShimmerEffect(
                    width: 32,
                    height: 32,
                    raduis: BorderRadius.circular(16),
                  ),
                  const SizedBox(width: 12),
                  TShimmerEffect(
                    width: 32,
                    height: 32,
                    raduis: BorderRadius.circular(16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TShimmerEffect(
            width: 24,
            height: 24,
            raduis: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          const TShimmerEffect(width: 40, height: 18),
          const SizedBox(height: 4),
          const TShimmerEffect(width: 60, height: 12),
        ],
      ),
    );
  }
}
