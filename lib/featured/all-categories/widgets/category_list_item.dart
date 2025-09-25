// lib/featured/all-categories/widgets/category_list_item.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/models/major_category_model.dart';

class CategoryListItem extends StatelessWidget {
  final MajorCategoryModel category;
  final VoidCallback onTap;
  final VoidCallback onToggleFeatured;
  final Function(int) onStatusChanged;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
    required this.onToggleFeatured,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category image
              Container(
                width: 60,
                height: 60,
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
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildCategoryIcon();
                            },
                          ),
                        )
                        : _buildCategoryIcon(),
              ),

              const SizedBox(width: 16),

              // Category details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category name
                    Text(
                      category.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (category.arabicName != null &&
                        category.arabicName != category.name) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Status and featured badges
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              category.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(
                                category.status,
                              ).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getStatusText(category.status),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(category.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Featured badge
                        if (category.isFeature)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'featured'.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  // Featured toggle
                  IconButton(
                    onPressed: onToggleFeatured,
                    icon: Icon(
                      category.isFeature ? Icons.star : Icons.star_border,
                      color: category.isFeature ? Colors.amber : Colors.grey,
                    ),
                  ),

                  // More options
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: onStatusChanged,
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('set_active'.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(Icons.schedule, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text('set_pending'.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 3,
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red),
                                const SizedBox(width: 8),
                                Text('set_inactive'.tr),
                              ],
                            ),
                          ),
                        ],
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
            _getCategoryColor(categoryName).withOpacity(0.7),
          ],
        ),
      ),
      child: Icon(
        _getCategoryIcon(categoryName),
        color: Colors.white,
        size: 24,
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
