class SectorModel {
  String? id;
  String vendorId;
  String name; // section_key في قاعدة البيانات
  String englishName; // display_name في قاعدة البيانات
  String? arabicName;
  String displayType; // grid, list, slider, carousel, custom
  double? cardWidth;
  double? cardHeight;
  int itemsPerRow;
  bool isActive;
  bool isVisibleToCustomers;
  int sortOrder;
  String? iconName;
  String? colorHex;
  DateTime? createdAt;
  DateTime? updatedAt;

  SectorModel({
    this.id,
    required this.vendorId,
    required this.name,
    required this.englishName,
    this.arabicName,
    this.displayType = 'grid',
    this.cardWidth,
    this.cardHeight,
    this.itemsPerRow = 3,
    this.isActive = true,
    this.isVisibleToCustomers = true,
    this.sortOrder = 0,
    this.iconName,
    this.colorHex,
    this.createdAt,
    this.updatedAt,
  });

  static SectorModel empty() =>
      SectorModel(id: '', vendorId: '', name: '', englishName: '');

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vendor_id': vendorId,
      'section_key': name,
      'display_name': englishName,
      if (arabicName != null) 'arabic_name': arabicName,
      'display_type': displayType,
      if (cardWidth != null) 'card_width': cardWidth,
      if (cardHeight != null) 'card_height': cardHeight,
      'items_per_row': itemsPerRow,
      'is_active': isActive,
      'is_visible_to_customers': isVisibleToCustomers,
      'sort_order': sortOrder,
      if (iconName != null) 'icon_name': iconName,
      if (colorHex != null) 'color_hex': colorHex,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Backwards compatibility for old calls
  Map<String, dynamic> toMap() => toJson();

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id'] as String?,
      vendorId: (json['vendor_id'] ?? json['vendorId'] ?? '') as String,
      name: (json['section_key'] ?? json['name'] ?? '') as String,
      englishName:
          (json['display_name'] ??
                  json['english_name'] ??
                  json['englishName'] ??
                  '')
              as String,
      arabicName: json['arabic_name'] as String?,
      displayType: (json['display_type'] ?? 'grid') as String,
      cardWidth:
          json['card_width'] != null
              ? (json['card_width'] as num).toDouble()
              : null,
      cardHeight:
          json['card_height'] != null
              ? (json['card_height'] as num).toDouble()
              : null,
      itemsPerRow: (json['items_per_row'] ?? 3) as int,
      isActive: (json['is_active'] ?? true) as bool,
      isVisibleToCustomers: (json['is_visible_to_customers'] ?? true) as bool,
      sortOrder: (json['sort_order'] ?? 0) as int,
      iconName: json['icon_name'] as String?,
      colorHex: json['color_hex'] as String?,
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

  /// Creates a copy of this SectorModel with the given fields replaced by new values
  SectorModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? englishName,
    String? arabicName,
    String? displayType,
    double? cardWidth,
    double? cardHeight,
    int? itemsPerRow,
    bool? isActive,
    bool? isVisibleToCustomers,
    int? sortOrder,
    String? iconName,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SectorModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      arabicName: arabicName ?? this.arabicName,
      displayType: displayType ?? this.displayType,
      cardWidth: cardWidth ?? this.cardWidth,
      cardHeight: cardHeight ?? this.cardHeight,
      itemsPerRow: itemsPerRow ?? this.itemsPerRow,
      isActive: isActive ?? this.isActive,
      isVisibleToCustomers: isVisibleToCustomers ?? this.isVisibleToCustomers,
      sortOrder: sortOrder ?? this.sortOrder,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SectorModel(id: $id, vendorId: $vendorId, name: $name, englishName: $englishName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SectorModel &&
        other.id == id &&
        other.vendorId == vendorId &&
        other.name == name &&
        other.englishName == englishName;
  }

  @override
  int get hashCode {
    return (id ?? '').hashCode ^
        vendorId.hashCode ^
        name.hashCode ^
        englishName.hashCode;
  }
}
