import 'package:flutter/material.dart';
import 'package:istoreto/featured/search/data/search_model.dart';
import 'package:istoreto/utils/constants/color.dart';

/// بطاقة عرض نتيجة البحث
class SearchResultCard extends StatelessWidget {
  final SearchResultModel item;
  final VoidCallback? onTap;

  const SearchResultCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // صورة العنصر
              _buildImage(),
              const SizedBox(width: 12),

              // معلومات العنصر
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // النوع
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTypeText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTypeColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    if (item.price != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${item.price!.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      ),
                    ],

                    if (item.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            item.rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // أيقونة النوع
              Icon(_getTypeIcon(), color: _getTypeColor(), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء صورة العنصر
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child:
          item.image != null && item.image!.isNotEmpty
              ? Image.network(
                item.image!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
              : _buildPlaceholderImage(),
    );
  }

  /// بناء صورة بديلة
  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_getTypeIcon(), color: Colors.grey[400], size: 24),
    );
  }

  /// الحصول على لون النوع
  Color _getTypeColor() {
    switch (item.type) {
      case 'منتج':
        return TColors.primary;
      case 'تاجر':
        return Colors.green;
      case 'فئة':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على نص النوع
  String _getTypeText() {
    switch (item.type) {
      case 'منتج':
        return 'منتج';
      case 'تاجر':
        return 'تاجر';
      case 'فئة':
        return 'فئة';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على أيقونة النوع
  IconData _getTypeIcon() {
    switch (item.type) {
      case 'منتج':
        return Icons.shopping_bag;
      case 'تاجر':
        return Icons.store;
      case 'فئة':
        return Icons.category;
      default:
        return Icons.help_outline;
    }
  }
}
