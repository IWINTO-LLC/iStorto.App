class SectorModel {
  String? id;
  String vendorId;
  String name;
  String englishName;
  DateTime? createdAt;
  DateTime? updatedAt;

  SectorModel({
    this.id,
    required this.vendorId,
    required this.name,
    required this.englishName,
    this.createdAt,
    this.updatedAt,
  });
  static SectorModel empty() =>
      SectorModel(id: '', vendorId: '', name: '', englishName: '');

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'english_name': englishName,
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
      name: (json['name'] ?? '') as String,
      englishName:
          (json['english_name'] ?? json['englishName'] ?? '') as String,
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
  }) {
    return SectorModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
