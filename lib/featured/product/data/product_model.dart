import 'package:istoreto/data/models/category_model.dart';

class ProductModel {
  String id;
  String? vendorId;
  String title;
  String? description;
  double price;
  double? oldPrice;
  String? productType;
  String? thumbnail;
  List<String> images;
  CategoryModel? category;
  String? vendorCategoryId;
  bool isFeature;
  bool isDeleted;
  int minQuantity;
  int salePercentage;
  String? currency; // Currency ISO code (e.g., 'USD', 'EUR')
  DateTime? createdAt;
  DateTime? updatedAt;

  ProductModel({
    required this.id,
    this.vendorId,
    required this.title,
    this.description,
    required this.price,
    this.oldPrice,
    this.productType,
    this.thumbnail,
    this.images = const [],
    this.category,
    this.vendorCategoryId,
    this.isFeature = false,
    this.isDeleted = false,
    this.minQuantity = 1,
    this.salePercentage = 0,
    this.currency = 'USD', // Default to USD
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'title': title,
      'description': description,
      'price': price,
      'old_price': oldPrice,
      'product_type': productType,
      'thumbnail': thumbnail,
      'images': images,
      'category_id': category?.id,
      'vendor_category_id': vendorCategoryId,
      'is_feature': isFeature,
      'is_deleted': isDeleted,
      'min_quantity': minQuantity,
      'sale_percentage': salePercentage,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static ProductModel empty() => ProductModel(id: '', title: '', price: 0);

  static ProductModel fromJson(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] ?? '',
      vendorId: data['vendor_id'],
      title: data['title'] ?? '',
      description: data['description'],
      price: (data['price'] ?? 0.0).toDouble(),
      oldPrice: data['old_price']?.toDouble(),
      productType: data['product_type'],
      thumbnail: data['thumbnail'],
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      category:
          data['category'] != null
              ? CategoryModel.fromJson(data['category'])
              : null,
      vendorCategoryId: data['vendor_category_id'],
      isFeature: data['is_feature'] ?? false,
      isDeleted: data['is_deleted'] ?? false,
      minQuantity: data['min_quantity'] ?? 1,
      salePercentage: data['sale_percentage'] ?? 0,
      currency: data['currency'] ?? 'USD',
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null,
    );
  }

  ProductModel copyWith({
    String? id,
    String? vendorId,
    String? title,
    String? description,
    double? price,
    double? oldPrice,
    String? productType,
    String? thumbnail,
    List<String>? images,
    CategoryModel? category,
    String? vendorCategoryId,
    bool? isFeature,
    bool? isDeleted,
    int? minQuantity,
    int? salePercentage,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      productType: productType ?? this.productType,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      category: category ?? this.category,
      vendorCategoryId: vendorCategoryId ?? this.vendorCategoryId,
      isFeature: isFeature ?? this.isFeature,
      isDeleted: isDeleted ?? this.isDeleted,
      minQuantity: minQuantity ?? this.minQuantity,
      salePercentage: salePercentage ?? this.salePercentage,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update timestamp
  ProductModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if product is valid
  bool get isValid {
    return id.isNotEmpty &&
        title.isNotEmpty &&
        price > 0 &&
        vendorId != null &&
        vendorId!.isNotEmpty;
  }

  // Check if product is active
  bool get isActive {
    return !isDeleted;
  }

  // Get display price
  double get displayPrice {
    return oldPrice != null && oldPrice! > 0 ? oldPrice! : price;
  }

  // Get sale percentage
  int get calculatedSalePercentage {
    if (oldPrice == null || oldPrice! <= 0) return 0;
    return ((oldPrice! - price) / oldPrice! * 100).round();
  }

  // Get currency symbol
  String get currencySymbol {
    switch (currency?.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'EGP':
        return 'ج.م';
      default:
        return currency ?? 'USD';
    }
  }

  // Get formatted price with currency
  String get formattedPrice {
    return '${price.toStringAsFixed(2)} $currencySymbol';
  }

  // Get formatted old price with currency
  String get formattedOldPrice {
    if (oldPrice == null || oldPrice! <= 0) return '';
    return '${oldPrice!.toStringAsFixed(2)} $currencySymbol';
  }

  // Check if currency is supported
  bool get hasValidCurrency {
    return currency != null && currency!.isNotEmpty;
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, price: $price, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
