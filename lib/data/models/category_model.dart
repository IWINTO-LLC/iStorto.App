// lib/data/models/category_model.dart
class CategoryModel {
  String? id;
  String? vendorId;
  String title;

  String color;
  String? icon;
  bool isActive;
  int sortOrder;
  DateTime? createdAt;
  DateTime? updatedAt;

  CategoryModel({
    this.id,
    this.vendorId,
    required this.title,

    this.color = '#007bff',
    this.icon,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'title': title,

      'color': color,
      'icon': icon,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      vendorId: json['vendor_id'],

      title: json['title'],

      color: json['color'] ?? '#007bff',
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
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

  // Create empty category
  static CategoryModel empty() {
    return CategoryModel(
      title: '',
      color: '#007bff',
      isActive: true,
      sortOrder: 0,
    );
  }

  // Copy with method for updates
  CategoryModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? arabicName,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      title: title,

      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update timestamp
  CategoryModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if category is valid
  bool get isValid {
    return title.isNotEmpty && vendorId != null && vendorId!.isNotEmpty;
  }

  // Get display name (Arabic if available, otherwise English)

  @override
  String toString() {
    return 'CategoryModel(id: $id, vendorId: $vendorId, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
