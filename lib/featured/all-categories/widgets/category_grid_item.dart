// lib/featured/all-categories/widgets/category_grid_item.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/models/major_category_model.dart';

class CategoryGridItem extends StatelessWidget {
  final MajorCategoryModel category;
  final VoidCallback onTap;
  final VoidCallback onToggleFeatured;

  const CategoryGridItem({
    super.key,
    required this.category,
    required this.onTap,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category image and featured badge
              Stack(
                children: [
                  // Category image
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child:
                        category.image != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                category.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildCategoryIcon();
                                },
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return _buildCategoryIcon();
                                },
                              ),
                            )
                            : _buildCategoryIcon(),
                  ),

                  // Featured badge
                  if (category.isFeature)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Status indicator
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(category.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getStatusText(category.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category name
              Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (category.arabicName != null &&
                  category.arabicName != category.name) ...[
                const SizedBox(height: 4),
                Text(
                  category.name,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: onToggleFeatured,
                      icon: Icon(
                        category.isFeature ? Icons.star : Icons.star_border,
                        color: category.isFeature ? Colors.amber : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    final categoryName = category.name.isNotEmpty ? category.name : 'Unknown';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(categoryName),
            _getCategoryColor(categoryName).withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Icon(
        _getCategoryIcon(categoryName),
        color: Colors.white,
        size: 32,
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('clothes')) {
      return Icons.checkroom;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Icons.shopping_bag;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Icons.shopping_basket;
    } else if (name.contains('accessories') || name.contains('watch')) {
      return Icons.watch;
    } else if (name.contains('electronics') || name.contains('phone')) {
      return Icons.phone_android;
    } else if (name.contains('home') || name.contains('furniture')) {
      return Icons.home;
    } else if (name.contains('beauty') || name.contains('cosmetics')) {
      return Icons.face;
    } else if (name.contains('sports') || name.contains('fitness')) {
      return Icons.sports;
    } else if (name.contains('books') || name.contains('education')) {
      return Icons.book;
    } else if (name.contains('toys') || name.contains('games')) {
      return Icons.toys;
    } else {
      return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('clothing') || name.contains('clothes')) {
      return Colors.pink;
    } else if (name.contains('shoes') || name.contains('footwear')) {
      return Colors.brown;
    } else if (name.contains('bags') || name.contains('handbag')) {
      return Colors.purple;
    } else if (name.contains('accessories') || name.contains('watch')) {
      return Colors.blue;
    } else if (name.contains('electronics') || name.contains('phone')) {
      return Colors.blueGrey;
    } else if (name.contains('home') || name.contains('furniture')) {
      return Colors.green;
    } else if (name.contains('beauty') || name.contains('cosmetics')) {
      return Colors.pinkAccent;
    } else if (name.contains('sports') || name.contains('fitness')) {
      return Colors.orange;
    } else if (name.contains('books') || name.contains('education')) {
      return Colors.indigo;
    } else if (name.contains('toys') || name.contains('games')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: // Active
        return Colors.green;
      case 2: // Pending
        return Colors.orange;
      case 3: // Inactive
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'active'.tr;
      case 2:
        return 'pending'.tr;
      case 3:
        return 'inactive'.tr;
      default:
        return 'unknown'.tr;
    }
  }
}
