// lib/data/models/vendor_category_model.dart
import 'major_category_model.dart';

class VendorCategoryModel {
  String? id;
  String vendorId;
  String majorCategoryId;
  bool isPrimary;
  int priority; // 0 = أعلى أولوية
  int specializationLevel; // 1-5
  String? customDescription;
  bool isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  // العلاقة مع الفئة الرئيسية
  // Relationship with major category
  MajorCategoryModel? majorCategory;

  VendorCategoryModel({
    this.id,
    required this.vendorId,
    required this.majorCategoryId,
    this.isPrimary = false,
    this.priority = 0,
    this.specializationLevel = 1,
    this.customDescription,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.majorCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'major_category_id': majorCategoryId,
      'is_primary': isPrimary,
      'priority': priority,
      'specialization_level': specializationLevel,
      'custom_description': customDescription,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryModel(
      id: json['id'],
      vendorId: json['vendor_id'] ?? '',
      majorCategoryId: json['major_category_id'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      priority: json['priority'] ?? 0,
      specializationLevel: json['specialization_level'] ?? 1,
      customDescription: json['custom_description'],
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  // إنشاء من JSON مع بيانات الفئة الرئيسية
  // Create from JSON with major category data
  factory VendorCategoryModel.fromJsonWithCategory(Map<String, dynamic> json) {
    final model = VendorCategoryModel.fromJson(json);

    // إضافة بيانات الفئة الرئيسية إذا كانت متوفرة
    // Add major category data if available
    if (json['major_category'] != null) {
      model.majorCategory = MajorCategoryModel.fromJson(json['major_category']);
    }

    return model;
  }

  // إنشاء فارغ
  // Create empty
  static VendorCategoryModel empty() {
    return VendorCategoryModel(
      vendorId: '',
      majorCategoryId: '',
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
    String? majorCategoryId,
    bool? isPrimary,
    int? priority,
    int? specializationLevel,
    String? customDescription,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    MajorCategoryModel? majorCategory,
  }) {
    return VendorCategoryModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      majorCategoryId: majorCategoryId ?? this.majorCategoryId,
      isPrimary: isPrimary ?? this.isPrimary,
      priority: priority ?? this.priority,
      specializationLevel: specializationLevel ?? this.specializationLevel,
      customDescription: customDescription ?? this.customDescription,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      majorCategory: majorCategory ?? this.majorCategory,
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
        majorCategoryId.isNotEmpty &&
        specializationLevel >= 1 &&
        specializationLevel <= 5;
  }

  // الحصول على اسم الفئة
  // Get category name
  String get categoryName {
    return majorCategory?.displayName ?? 'Unknown Category';
  }

  // الحصول على صورة الفئة
  // Get category image
  String? get categoryImage {
    return majorCategory?.image;
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
  String toString() {
    return 'VendorCategoryModel(id: $id, vendorId: $vendorId, majorCategoryId: $majorCategoryId, isPrimary: $isPrimary, priority: $priority, specializationLevel: $specializationLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorCategoryModel &&
        other.id == id &&
        other.vendorId == vendorId &&
        other.majorCategoryId == majorCategoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ vendorId.hashCode ^ majorCategoryId.hashCode;
  }
}

// نموذج لطلب إضافة فئة للتاجر
// Model for adding category to vendor request
class AddVendorCategoryRequest {
  String vendorId;
  String majorCategoryId;
  bool isPrimary;
  int priority;
  int specializationLevel;
  String? customDescription;

  AddVendorCategoryRequest({
    required this.vendorId,
    required this.majorCategoryId,
    this.isPrimary = false,
    this.priority = 0,
    this.specializationLevel = 1,
    this.customDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'major_category_id': majorCategoryId,
      'is_primary': isPrimary,
      'priority': priority,
      'specialization_level': specializationLevel,
      'custom_description': customDescription,
    };
  }
}

// نموذج لتحديث أولويات الفئات
// Model for updating category priorities
class UpdateCategoryPrioritiesRequest {
  String vendorId;
  List<CategoryPriorityItem> priorities;

  UpdateCategoryPrioritiesRequest({
    required this.vendorId,
    required this.priorities,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'priorities': priorities.map((item) => item.toJson()).toList(),
    };
  }
}

// نموذج لعنصر أولوية الفئة
// Model for category priority item
class CategoryPriorityItem {
  String majorCategoryId;
  int priority;

  CategoryPriorityItem({required this.majorCategoryId, required this.priority});

  Map<String, dynamic> toJson() {
    return {'major_category_id': majorCategoryId, 'priority': priority};
  }
}
