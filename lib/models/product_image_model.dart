/// نموذج صورة المنتج
/// Product Image Model
class ProductImageModel {
  final String id;
  final String productId;
  final String imageUrl;
  final int imageOrder;
  final bool isThumbnail;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // معلومات المنتج (من الـ JOIN)
  final String? productTitle;
  final double? productPrice;
  final double? productOldPrice;
  final String? vendorId;
  final String? vendorName;
  final String? vendorLogo;

  ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    this.imageOrder = 0,
    this.isThumbnail = false,
    required this.createdAt,
    this.updatedAt,
    this.productTitle,
    this.productPrice,
    this.productOldPrice,
    this.vendorId,
    this.vendorName,
    this.vendorLogo,
  });

  /// من JSON (من قاعدة البيانات)
  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      imageUrl: json['image_url'] as String,
      imageOrder: json['image_order'] as int? ?? 0,
      isThumbnail: json['is_thumbnail'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      productTitle: json['product_title'] as String?,
      productPrice: (json['product_price'] as num?)?.toDouble(),
      productOldPrice: (json['product_old_price'] as num?)?.toDouble(),
      vendorId: json['vendor_id'] as String?,
      vendorName: json['vendor_name'] as String?,
      vendorLogo: json['vendor_logo'] as String?,
    );
  }

  /// إلى JSON (للحفظ في قاعدة البيانات)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image_url': imageUrl,
      'image_order': imageOrder,
      'is_thumbnail': isThumbnail,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// نسخة مع تعديلات
  ProductImageModel copyWith({
    String? id,
    String? productId,
    String? imageUrl,
    int? imageOrder,
    bool? isThumbnail,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productTitle,
    double? productPrice,
    double? productOldPrice,
    String? vendorId,
    String? vendorName,
    String? vendorLogo,
  }) {
    return ProductImageModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageOrder: imageOrder ?? this.imageOrder,
      isThumbnail: isThumbnail ?? this.isThumbnail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      productOldPrice: productOldPrice ?? this.productOldPrice,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorLogo: vendorLogo ?? this.vendorLogo,
    );
  }

  /// نموذج فارغ
  factory ProductImageModel.empty() {
    return ProductImageModel(
      id: '',
      productId: '',
      imageUrl: '',
      imageOrder: 0,
      isThumbnail: false,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ProductImageModel(id: $id, productId: $productId, imageUrl: $imageUrl, order: $imageOrder)';
  }
}


