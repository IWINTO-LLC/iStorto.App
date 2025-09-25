// lib/data/models/major_category_model.dart
class MajorCategoryModel {
  String? id;
  String name;
  String? arabicName;
  String? image;
  bool isFeature;
  int status; // 1: Active, 2: Pending, 3: Inactive
  String? parentId;
  DateTime? createdAt;
  DateTime? updatedAt;

  // For hierarchical structure
  List<MajorCategoryModel> children = [];
  MajorCategoryModel? parent;

  MajorCategoryModel({
    this.id,
    required this.name,
    this.arabicName,
    this.image,
    this.isFeature = false,
    this.status = 2, // Default: Pending
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.children = const [],
    this.parent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic_name': arabicName,
      'image': image,
      'is_feature': isFeature,
      'status': status,
      'parent_id': parentId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory MajorCategoryModel.fromJson(Map<String, dynamic> json) {
    return MajorCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      arabicName: json['arabic_name'],
      image: json['image'],
      isFeature: json['is_feature'] ?? false,
      status: json['status'] ?? 2,
      parentId: json['parent_id'],
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
  static MajorCategoryModel empty() {
    return MajorCategoryModel(name: '', isFeature: false, status: 2);
  }

  // Copy with method for updates
  MajorCategoryModel copyWith({
    String? id,
    String? name,
    String? arabicName,
    String? image,
    bool? isFeature,
    int? status,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MajorCategoryModel>? children,
    MajorCategoryModel? parent,
  }) {
    return MajorCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      image: image ?? this.image,
      isFeature: isFeature ?? this.isFeature,
      status: status ?? this.status,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
      parent: parent ?? this.parent,
    );
  }

  // Update timestamp
  MajorCategoryModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if category is valid
  bool get isValid {
    return name.isNotEmpty;
  }

  // Check if category is active
  bool get isActive => status == 1;

  // Check if category is pending
  bool get isPending => status == 2;

  // Check if category is inactive
  bool get isInactive => status == 3;

  // Get display name (Arabic if available, otherwise English)
  String get displayName {
    if (arabicName?.isNotEmpty == true) {
      return arabicName!;
    }
    return name.isNotEmpty ? name : 'Unknown Category';
  }

  // Check if this is a root category (no parent)
  bool get isRoot => parentId == null;

  // Check if this is a leaf category (no children)
  bool get isLeaf => children.isEmpty;

  // Get depth level in hierarchy
  int get depth {
    int level = 0;
    MajorCategoryModel? current = parent;
    while (current != null) {
      level++;
      current = current.parent;
    }
    return level;
  }

  // Get full path from root
  String get fullPath {
    List<String> path = [displayName];
    MajorCategoryModel? current = parent;
    while (current != null) {
      path.insert(0, current.displayName);
      current = current.parent;
    }
    return path.join(' > ');
  }

  // Add child category
  void addChild(MajorCategoryModel child) {
    children.add(child);
    child.parent = this;
    child.parentId = id;
  }

  // Remove child category
  void removeChild(MajorCategoryModel child) {
    children.remove(child);
    child.parent = null;
    child.parentId = null;
  }

  // Get all descendants (children + grandchildren + ...)
  List<MajorCategoryModel> get allDescendants {
    List<MajorCategoryModel> descendants = [];
    for (var child in children) {
      descendants.add(child);
      descendants.addAll(child.allDescendants);
    }
    return descendants;
  }

  // Get all ancestors (parent + grandparent + ...)
  List<MajorCategoryModel> get allAncestors {
    List<MajorCategoryModel> ancestors = [];
    MajorCategoryModel? current = parent;
    while (current != null) {
      ancestors.insert(0, current);
      current = current.parent;
    }
    return ancestors;
  }

  // Convert to flat list (for API calls)
  List<MajorCategoryModel> toFlatList() {
    List<MajorCategoryModel> flatList = [this];
    for (var child in children) {
      flatList.addAll(child.toFlatList());
    }
    return flatList;
  }

  // Build hierarchy from flat list
  static List<MajorCategoryModel> buildHierarchy(
    List<MajorCategoryModel> flatList,
  ) {
    Map<String, MajorCategoryModel> categoryMap = {};
    List<MajorCategoryModel> rootCategories = [];

    // Create map for quick lookup
    for (var category in flatList) {
      categoryMap[category.id!] = category;
    }

    // Build hierarchy
    for (var category in flatList) {
      if (category.parentId == null) {
        rootCategories.add(category);
      } else {
        var parent = categoryMap[category.parentId];
        if (parent != null) {
          parent.addChild(category);
        }
      }
    }

    return rootCategories;
  }

  @override
  String toString() {
    return 'MajorCategoryModel(id: $id, name: $name, parentId: $parentId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MajorCategoryModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
