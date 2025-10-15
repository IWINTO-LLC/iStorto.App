class VendorSocialLinksModel {
  final String id;
  final String vendorId;
  final String
  linkType; // 'website', 'email', 'whatsapp', 'phone', 'location', 'linkedin', 'youtube'
  final String linkValue;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorSocialLinksModel({
    required this.id,
    required this.vendorId,
    required this.linkType,
    required this.linkValue,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorSocialLinksModel.fromMap(Map<String, dynamic> map) {
    return VendorSocialLinksModel(
      id: map['id']?.toString() ?? '',
      vendorId: map['vendor_id']?.toString() ?? '',
      linkType: map['link_type']?.toString() ?? '',
      linkValue: map['link_value']?.toString() ?? '',
      isActive: map['is_active'] == true || map['is_active'] == 'true',
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'link_type': linkType,
      'link_value': linkValue,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VendorSocialLinksModel copyWith({
    String? id,
    String? vendorId,
    String? linkType,
    String? linkValue,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorSocialLinksModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      linkType: linkType ?? this.linkType,
      linkValue: linkValue ?? this.linkValue,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'VendorSocialLinksModel(id: $id, vendorId: $vendorId, linkType: $linkType, linkValue: $linkValue, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorSocialLinksModel &&
        other.id == id &&
        other.vendorId == vendorId &&
        other.linkType == linkType &&
        other.linkValue == linkValue &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        vendorId.hashCode ^
        linkType.hashCode ^
        linkValue.hashCode ^
        isActive.hashCode;
  }
}
