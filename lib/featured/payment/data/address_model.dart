class AddressModel {
  final String? id;
  final String userId;
  final String title; // عنوان مخصص مثل "المنزل"، "العمل"
  final String fullAddress;
  final String? city;
  final String? street;
  final String? buildingNumber;
  final String? phoneNumber;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    this.id,
    required this.userId,
    required this.title,
    required this.fullAddress,
    this.city,
    this.street,
    this.buildingNumber,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'full_address': fullAddress,
      'city': city,
      'street': street,
      'building_number': buildingNumber,
      'phone_number': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'],
      userId: map['user_id'] ?? map['userId'] ?? '',
      title: map['title'] ?? '',
      fullAddress: map['full_address'] ?? map['fullAddress'] ?? '',
      city: map['city'],
      street: map['street'],
      buildingNumber: map['building_number'] ?? map['buildingNumber'],
      phoneNumber: map['phone_number'] ?? map['phoneNumber'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      isDefault: map['is_default'] ?? map['isDefault'] ?? false,
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : map['createdAt'] != null
              ? (map['createdAt'] is DateTime
                  ? map['createdAt']
                  : DateTime.parse(map['createdAt'].toString()))
              : null,
      updatedAt:
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'])
              : map['updatedAt'] != null
              ? (map['updatedAt'] is DateTime
                  ? map['updatedAt']
                  : DateTime.parse(map['updatedAt'].toString()))
              : null,
    );
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? fullAddress,
    String? city,
    String? street,
    String? buildingNumber,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      street: street ?? this.street,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Create empty address
  static AddressModel empty() =>
      AddressModel(userId: '', title: '', fullAddress: '');

  // Update timestamp
  AddressModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if address is valid
  bool get isValid {
    return userId.isNotEmpty && title.isNotEmpty && fullAddress.isNotEmpty;
  }

  // Get formatted address
  String get formattedAddress {
    List<String> parts = [];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (buildingNumber != null && buildingNumber!.isNotEmpty)
      parts.add('Building ${buildingNumber!}');

    if (parts.isEmpty) return fullAddress;
    return '${fullAddress}, ${parts.join(', ')}';
  }

  // Get short address for display
  String get shortAddress {
    if (city != null && city!.isNotEmpty) {
      return '$title - $city';
    }
    return title;
  }

  @override
  String toString() {
    return 'AddressModel(id: $id, title: $title, city: $city, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
