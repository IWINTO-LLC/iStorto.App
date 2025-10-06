enum BannerScope {
  company, // بنرات الشركة
  vendor, // بنرات التجار
}

class BannerModel {
  String? id;
  String image;

  String targetScreen;
  bool active;
  String? vendorId; // معرف التاجر (null للبنرات العامة)
  BannerScope scope; // نطاق البانر
  String? title; // عنوان البانر
  String? description; // وصف البانر
  int? priority; // أولوية العرض (الأعلى أولاً)
  DateTime? createdAt;
  DateTime? updatedAt;

  BannerModel({
    this.id,
    required this.image,
    required this.targetScreen,
    this.active = false,
    this.vendorId,
    this.scope = BannerScope.company,
    this.title,
    this.description,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  static BannerModel empty() => BannerModel(
    image: '',
    targetScreen: '',
    active: false,
    scope: BannerScope.company,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'target_screen': targetScreen,
      'active': active,
      'vendor_id': vendorId,
      'scope': scope.name,
      'title': title,
      'description': description,
      'priority': priority,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory BannerModel.fromJson(Map<String, dynamic> data) {
    return BannerModel(
      id: data['id'],
      image: data['image'] ?? '',
      targetScreen: data['target_screen'] ?? '',
      active: data['active'] ?? false,
      vendorId: data['vendor_id'],
      scope:
          data['scope'] != null
              ? BannerScope.values.firstWhere(
                (e) => e.name == data['scope'],
                orElse: () => BannerScope.company,
              )
              : BannerScope.company,
      title: data['title'],
      description: data['description'],
      priority: data['priority']?.toInt(),
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

  // Copy with method for updates
  BannerModel copyWith({
    String? id,
    String? image,
    String? targetScreen,
    bool? active,
    String? vendorId,
    BannerScope? scope,
    String? title,
    String? description,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      image: image ?? this.image,
      targetScreen: targetScreen ?? this.targetScreen,
      active: active ?? this.active,
      vendorId: vendorId ?? this.vendorId,
      scope: scope ?? this.scope,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update timestamp
  BannerModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if banner is valid
  bool get isValid {
    return image.isNotEmpty && targetScreen.isNotEmpty;
  }

  // Check if banner is active
  bool get isActive {
    return active;
  }

  // Check if banner is company banner
  bool get isCompanyBanner {
    return scope == BannerScope.company;
  }

  // Check if banner is vendor banner
  bool get isVendorBanner {
    return scope == BannerScope.vendor;
  }

  // Check if banner belongs to specific vendor
  bool belongsToVendor(String? vendorId) {
    return this.vendorId == vendorId;
  }

  // Get display title
  String get displayTitle {
    return title ?? 'بانر إعلاني';
  }

  // Get display description
  String get displayDescription {
    return description ?? '';
  }

  // Get priority for sorting (higher number = higher priority)
  int get sortPriority {
    return priority ?? 0;
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, image: $image, targetScreen: $targetScreen, scope: ${scope.name}, vendorId: $vendorId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BannerModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
