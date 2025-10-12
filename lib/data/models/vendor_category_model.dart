class VendorCategoryModel {
  String? id;
  String vendorId;
  String title;
  bool isPrimary;
  int priority; // 0 = أعلى أولوية
  int specializationLevel; // 1-5
  String? customDescription;
  String? icon;
  bool isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  VendorCategoryModel({
    this.id,
    required this.vendorId,
    required this.title,
    this.isPrimary = false,
    this.priority = 0,
    this.specializationLevel = 1,
    this.customDescription,
    this.icon,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    // Keep only columns that are guaranteed to exist in current schema
    return {
      'id': id,
      'vendor_id': vendorId,
      'title': title,
      // 'custom_description': customDescription,
      // 'is_active': isActive,
      // timestamps are managed by DB defaults/triggers
    };
  }

  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryModel(
      id: json['id'],
      vendorId: json['vendor_id'] ?? '',
      title: json['title'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      priority: json['priority'] ?? 0,
      specializationLevel: json['specialization_level'] ?? 1,
      customDescription: json['custom_description'],
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  // إنشاء من JSON مع بيانات الفئة الرئيسية
  // Create from JSON with major category data
  factory VendorCategoryModel.fromJsonWithCategory(Map<String, dynamic> json) {
    final model = VendorCategoryModel.fromJson(json);

    return model;
  }

  // إنشاء فارغ
  // Create empty
  static VendorCategoryModel empty() {
    return VendorCategoryModel(
      vendorId: '',
      title: '',
      isPrimary: false,
      priority: 0,
      specializationLevel: 1,
      isActive: true,
    );
  }

  // نسخ مع تغييرات
  // Copy with changes
  VendorCategoryModel copyWith({
    String? id,
    String? vendorId,
    String? title,
    bool? isPrimary,
    int? priority,
    int? specializationLevel,
    String? customDescription,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorCategoryModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      title: title ?? this.title,
      isPrimary: isPrimary ?? this.isPrimary,
      priority: priority ?? this.priority,
      specializationLevel: specializationLevel ?? this.specializationLevel,
      customDescription: customDescription ?? this.customDescription,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // تحديث الطابع الزمني
  // Update timestamp
  VendorCategoryModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // التحقق من صحة البيانات
  // Validate data
  bool get isValid {
    return vendorId.isNotEmpty &&
        title.isNotEmpty &&
        specializationLevel >= 1 &&
        specializationLevel <= 5;
  }

  // التحقق من أن هذا هو التخصص الأساسي
  // Check if this is the primary specialization
  bool get isPrimarySpecialization => isPrimary;

  // الحصول على مستوى التخصص كنص
  // Get specialization level as text
  String get specializationLevelText {
    switch (specializationLevel) {
      case 1:
        return 'مبتدئ';
      case 2:
        return 'متوسط';
      case 3:
        return 'متقدم';
      case 4:
        return 'خبير';
      case 5:
        return 'متميز';
      default:
        return 'غير محدد';
    }
  }

  // الحصول على لون مستوى التخصص
  // Get specialization level color
  String get specializationLevelColor {
    switch (specializationLevel) {
      case 1:
        return '#4CAF50'; // أخضر
      case 2:
        return '#2196F3'; // أزرق
      case 3:
        return '#FF9800'; // برتقالي
      case 4:
        return '#9C27B0'; // بنفسجي
      case 5:
        return '#F44336'; // أحمر
      default:
        return '#9E9E9E'; // رمادي
    }
  }

  // الحصول على أولوية النص
  // Get priority text
  String get priorityText {
    if (priority == 0) {
      return 'أولوية عالية';
    } else if (priority <= 2) {
      return 'أولوية متوسطة';
    } else {
      return 'أولوية منخفضة';
    }
  }

  // التحقق من أن التخصص نشط
  // Check if specialization is active
  bool get isActiveSpecialization => isActive;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorCategoryModel &&
        other.id == id &&
        other.vendorId == vendorId;
  }
}

// نموذج لطلب إضافة فئة للتاجر
// Model for adding category to vendor request
class AddVendorCategoryRequest {
  String vendorId;
  String title;
  bool isPrimary;
  int priority;
  int specializationLevel;
  String? customDescription;
  String? icon;

  AddVendorCategoryRequest({
    required this.vendorId,
    required this.title,
    this.isPrimary = false,
    this.priority = 0,
    this.specializationLevel = 1,
    this.customDescription,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    // Keep only columns that are guaranteed to exist in current schema
    return {
      'vendor_id': vendorId,
      'title': title,
      if (icon != null && icon!.isNotEmpty) 'icon': icon,
      // 'custom_description': customDescription,
    };
  }
}
