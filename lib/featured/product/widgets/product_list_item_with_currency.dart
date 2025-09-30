import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/product/widgets/currency_price_widget.dart';
import 'package:istoreto/utils/constants/color.dart';

class ProductListItemWithCurrency extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final String? targetCurrency;

  const ProductListItemWithCurrency({
    super.key,
    required this.product,
    this.onTap,
    this.targetCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child:
                      product.thumbnail != null && product.thumbnail!.isNotEmpty
                          ? Image.network(
                            product.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          )
                          : const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                ),
              ),

              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Product Description
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // Price with Currency
                    CurrencyPriceWidget(
                      product: product,
                      targetCurrency: targetCurrency,
                      priceStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                      showDiscountPercentage: true,
                      showSavings: false,
                    ),

                    const SizedBox(height: 4),

                    // Product Info Row
                    Row(
                      children: [
                        // Original Currency
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.currency ?? 'USD',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Stock Status
                        if (product.minQuantity > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Min: ${product.minQuantity}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button
              Column(
                children: [
                  IconButton(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: TColors.primary,
                    ),
                  ),
                  if (product.isFeature)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
}

class ProductGridItemWithCurrency extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final String? targetCurrency;

  const ProductGridItemWithCurrency({
    super.key,
    required this.product,
    this.onTap,
    this.targetCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child:
                      product.thumbnail != null && product.thumbnail!.isNotEmpty
                          ? Image.network(
                            product.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.grey,
                              );
                            },
                          )
                          : const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                ),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Price with Currency
                    CurrencyPriceWidget(
                      product: product,
                      targetCurrency: targetCurrency,
                      priceStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                      showDiscountPercentage: true,
                      showSavings: false,
                    ),

                    const Spacer(),

                    // Product Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Original Currency
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.currency ?? 'USD',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Featured Badge
                        if (product.isFeature)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '★',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

