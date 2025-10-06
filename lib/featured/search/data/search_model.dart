/// نموذج بيانات نتيجة البحث الشامل
class SearchResultModel {
  final String id;
  final String title;
  final String type; // منتج، تاجر، فئة
  final String? image;
  final String? description;
  final double? price;
  final int? rating;
  final Map<String, dynamic> additionalData;

  SearchResultModel({
    required this.id,
    required this.title,
    required this.type,
    this.image,
    this.description,
    this.price,
    this.rating,
    this.additionalData = const {},
  });

  /// إنشاء نموذج من بيانات قاعدة البيانات
  factory SearchResultModel.fromMap(Map<String, dynamic> data) {
    return SearchResultModel(
      id: data['id']?.toString() ?? '',
      title: _getTitle(data),
      type: data['item_type']?.toString() ?? 'منتج',
      image: _getImage(data),
      description: data['description']?.toString(),
      price: _getPrice(data),
      rating: _getRating(data),
      additionalData: data,
    );
  }

  /// استخراج العنوان حسب نوع العنصر
  static String _getTitle(Map<String, dynamic> data) {
    return data['product_title']?.toString() ??
        data['vendor_name']?.toString() ??
        data['category_title']?.toString() ??
        'عنوان غير محدد';
  }

  /// استخراج الصورة حسب نوع العنصر
  static String? _getImage(Map<String, dynamic> data) {
    return data['product_thumbnail']?.toString() ??
        data['vendor_logo']?.toString() ??
        data['category_image']?.toString();
  }

  /// استخراج السعر
  static double? _getPrice(Map<String, dynamic> data) {
    final price = data['price'];
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price);
    return null;
  }

  /// استخراج التقييم
  static int? _getRating(Map<String, dynamic> data) {
    final rating = data['rating'];
    if (rating is num) return rating.toInt();
    if (rating is String) return int.tryParse(rating);
    return null;
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'image': image,
      'description': description,
      'price': price,
      'rating': rating,
      ...additionalData,
    };
  }

  /// نسخ مع تعديل
  SearchResultModel copyWith({
    String? id,
    String? title,
    String? type,
    String? image,
    String? description,
    double? price,
    int? rating,
    Map<String, dynamic>? additionalData,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      image: image ?? this.image,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'SearchResultModel(id: $id, title: $title, type: $type, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResultModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// نموذج فلاتر البحث
class SearchFilters {
  final String? itemType; // منتج، تاجر، فئة
  final double? minPrice;
  final double? maxPrice;
  final int? minRating;
  final bool? isVerified;
  final bool? isFeatured;

  SearchFilters({
    this.itemType,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.isVerified,
    this.isFeatured,
  });

  /// نسخ مع تعديل
  SearchFilters copyWith({
    String? itemType,
    double? minPrice,
    double? maxPrice,
    int? minRating,
    bool? isVerified,
    bool? isFeatured,
  }) {
    return SearchFilters(
      itemType: itemType ?? this.itemType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  /// التحقق من وجود فلاتر نشطة
  bool get hasActiveFilters {
    return itemType != null ||
        minPrice != null ||
        maxPrice != null ||
        minRating != null ||
        isVerified != null ||
        isFeatured != null;
  }

  /// إعادة تعيين الفلاتر
  SearchFilters clear() {
    return SearchFilters();
  }

  @override
  String toString() {
    return 'SearchFilters(itemType: $itemType, minPrice: $minPrice, maxPrice: $maxPrice, minRating: $minRating)';
  }
}
