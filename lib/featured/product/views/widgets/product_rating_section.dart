import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/utils/constants/color.dart';

/// قسم تقييم المنتج
/// Product Rating Section
class ProductRatingSection extends StatelessWidget {
  final ProductModel product;

  const ProductRatingSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'product_rating'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () => _showRatingDialog(context),
                icon: Icon(Icons.star_border, color: TColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rating Summary
          _RatingSummary(product: product),

          const SizedBox(height: 16),

          // Rating Form
          _RatingForm(product: product),
        ],
      ),
    );
  }

  /// عرض نافذة التقييم
  /// Show rating dialog
  void _showRatingDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('rate_product'.tr),
        content: _RatingDialogContent(product: product),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              // Handle rating submission
              Get.back();
              Get.snackbar(
                'rating_submitted'.tr,
                'thank_you_for_rating'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: TColors.primary,
                colorText: Colors.white,
              );
            },
            child: Text('submit_rating'.tr),
          ),
        ],
      ),
    );
  }
}

/// ملخص التقييم
/// Rating Summary
class _RatingSummary extends StatelessWidget {
  final ProductModel product;

  const _RatingSummary({required this.product});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getRatingSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text(
            'error_loading_ratings'.tr,
            style: TextStyle(color: Colors.grey.shade600),
          );
        }

        final data = snapshot.data ?? {};
        final averageRating = data['average_rating'] ?? 0.0;
        final totalRatings = data['total_ratings'] ?? 0;

        return Row(
          children: [
            // Average Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStars(averageRating.toInt()),
                        const SizedBox(height: 4),
                        Text(
                          'out_of_5_stars'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalRatings ${'ratings'.tr}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),

            const Spacer(),

            // Rating Distribution
            if (totalRatings > 0) _RatingDistribution(data: data),
          ],
        );
      },
    );
  }

  /// الحصول على ملخص التقييم
  /// Get rating summary
  Future<Map<String, dynamic>> _getRatingSummary() async {
    try {
      // TODO: Implement actual API call to get rating summary
      // This is a mock implementation
      return {
        'average_rating': 4.2,
        'total_ratings': 15,
        'rating_distribution': {'5': 8, '4': 4, '3': 2, '2': 1, '1': 0},
      };
    } catch (e) {
      throw Exception('Failed to load rating summary: ${e.toString()}');
    }
  }

  /// بناء النجوم
  /// Build stars
  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}

/// توزيع التقييمات
/// Rating Distribution
class _RatingDistribution extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RatingDistribution({required this.data});

  @override
  Widget build(BuildContext context) {
    final distribution =
        data['rating_distribution'] as Map<String, dynamic>? ?? {};
    final totalRatings = data['total_ratings'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final count = distribution[rating.toString()] ?? 0;
        final percentage =
            totalRatings > 0 ? (count / totalRatings) * 100 : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$rating', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$count', style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }),
    );
  }
}

/// نموذج التقييم
/// Rating Form
class _RatingForm extends StatefulWidget {
  final ProductModel product;

  const _RatingForm({required this.product});

  @override
  State<_RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends State<_RatingForm> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'rate_this_product'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Star Rating
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = index + 1;
                });
              },
              child: Icon(
                index < _selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // Review Text
        TextField(
          controller: _reviewController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'write_review_placeholder'.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: TColors.primary),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedRating > 0 ? _submitRating : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'submit_rating'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// إرسال التقييم
  /// Submit rating
  void _submitRating() async {
    try {
      // TODO: Implement actual API call to submit rating
      // This is a mock implementation

      Get.snackbar(
        'rating_submitted'.tr,
        'thank_you_for_rating'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.primary,
        colorText: Colors.white,
      );

      // Reset form
      setState(() {
        _selectedRating = 0;
        _reviewController.clear();
      });
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_submit_rating'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

/// محتوى نافذة التقييم
/// Rating Dialog Content
class _RatingDialogContent extends StatefulWidget {
  final ProductModel product;

  const _RatingDialogContent({required this.product});

  @override
  State<_RatingDialogContent> createState() => _RatingDialogContentState();
}

class _RatingDialogContentState extends State<_RatingDialogContent> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Review Text
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'write_review_placeholder'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: TColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
