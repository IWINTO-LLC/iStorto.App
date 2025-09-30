import 'package:istoreto/featured/shop/data/social-link.dart';

class VendorModel {
  final String? id;
  final String? userId;
  final String organizationName;
  final String organizationBio;
  final String bannerImage;
  final String organizationLogo;
  final String organizationCover;
  final String website;
  final String brief;
  final String exclusiveId;
  final String storeMessage;
  final bool inExclusive;
  final bool isSubscriber;
  final bool isVerified;
  final bool isRoyal;
  final bool enableIwintoPayment;
  final bool enableCod;
  final bool organizationDeleted;
  final bool organizationActivated;
  final String defaultCurrency;
  final String? selectedMajorCategories; // الفئات العامة المختارة
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SocialLink? socialLink;

  const VendorModel({
    this.id,
    this.userId,
    required this.organizationName,
    this.organizationBio = '',
    this.bannerImage = '',
    this.organizationLogo = '',
    this.organizationCover = '',
    this.website = '',
    this.brief = '',
    this.exclusiveId = '',
    this.storeMessage = '',
    this.inExclusive = false,
    this.isSubscriber = false,
    this.isVerified = false,
    this.isRoyal = false,
    this.enableIwintoPayment = false,
    this.enableCod = false,
    this.organizationDeleted = false,
    this.organizationActivated = true,
    this.defaultCurrency = 'USD',
    this.selectedMajorCategories,
    this.socialLink,
    this.createdAt,
    this.updatedAt,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'],
      userId: json['user_id'],
      organizationName: json['organization_name'] ?? '',
      organizationBio: json['organization_bio'] ?? '',
      bannerImage: json['banner_image'] ?? '',
      organizationLogo: json['organization_logo'] ?? '',
      organizationCover: json['organization_cover'] ?? '',
      website: json['website'] ?? '',
      brief: json['brief'] ?? '',
      exclusiveId: json['exclusive_id'] ?? '',
      storeMessage: json['store_message'] ?? '',
      inExclusive: json['in_exclusive'] ?? false,
      isSubscriber: json['is_subscriber'] ?? false,
      isVerified: json['is_verified'] ?? false,
      isRoyal: json['is_royal'] ?? false,
      enableIwintoPayment: json['enable_iwinto_payment'] ?? false,
      enableCod: json['enable_cod'] ?? false,
      organizationDeleted: json['organization_deleted'] ?? false,
      organizationActivated: json['organization_activated'] ?? true,
      defaultCurrency: json['default_currency'] ?? 'USD',
      selectedMajorCategories: json['selected_major_categories'],
      socialLink:
          json['social_link'] != null
              ? SocialLink.fromJson(json['social_link'])
              : const SocialLink(),
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'user_id': userId,
      'organization_name': organizationName,
      'organization_bio': organizationBio,
      'banner_image': bannerImage,
      'organization_logo': organizationLogo,
      'organization_cover': organizationCover,
      'website': website,
      'brief': brief,
      'exclusive_id': exclusiveId,
      'store_message': storeMessage,
      'in_exclusive': inExclusive,
      'is_subscriber': isSubscriber,
      'is_verified': isVerified,
      'is_royal': isRoyal,
      'enable_iwinto_payment': enableIwintoPayment,
      'enable_cod': enableCod,
      'organization_deleted': organizationDeleted,
      'organization_activated': organizationActivated,
      'default_currency': defaultCurrency,
      'selected_major_categories': selectedMajorCategories,
      'social_link': socialLink?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };

    // Only include id if it's not null
    if (id != null) {
      json['id'] = id;
    }

    return json;
  }

  // Create empty profile
  static VendorModel empty() {
    return VendorModel(organizationName: '');
  }

  // Copy with method for updates
  VendorModel copyWith({
    String? id,
    String? userId,
    String? organizationName,
    String? organizationBio,
    String? bannerImage,
    String? organizationLogo,
    String? organizationCover,
    String? website,
    String? brief,
    String? exclusiveId,
    String? storeMessage,
    bool? inExclusive,
    bool? isSubscriber,
    bool? isVerified,
    bool? isRoyal,
    bool? enableIwintoPayment,
    bool? enableCod,
    bool? organizationDeleted,
    bool? organizationActivated,
    String? defaultCurrency,
    String? selectedMajorCategories,
    SocialLink? socialLink,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      organizationName: organizationName ?? this.organizationName,
      organizationBio: organizationBio ?? this.organizationBio,
      bannerImage: bannerImage ?? this.bannerImage,
      organizationLogo: organizationLogo ?? this.organizationLogo,
      organizationCover: organizationCover ?? this.organizationCover,
      website: website ?? this.website,
      brief: brief ?? this.brief,
      exclusiveId: exclusiveId ?? this.exclusiveId,
      storeMessage: storeMessage ?? this.storeMessage,
      inExclusive: inExclusive ?? this.inExclusive,
      isSubscriber: isSubscriber ?? this.isSubscriber,
      isVerified: isVerified ?? this.isVerified,
      isRoyal: isRoyal ?? this.isRoyal,
      enableIwintoPayment: enableIwintoPayment ?? this.enableIwintoPayment,
      enableCod: enableCod ?? this.enableCod,
      organizationDeleted: organizationDeleted ?? this.organizationDeleted,
      organizationActivated:
          organizationActivated ?? this.organizationActivated,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      selectedMajorCategories:
          selectedMajorCategories ?? this.selectedMajorCategories,
      socialLink: socialLink ?? this.socialLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update timestamp
  VendorModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if profile is valid
  bool get isValid {
    return organizationName.isNotEmpty && userId != null && userId!.isNotEmpty;
  }

  // Get display name
  String get displayName {
    return organizationName;
  }

  // Check if vendor is active
  bool get isActive {
    return organizationActivated && !organizationDeleted;
  }

  @override
  String toString() {
    return 'VendorModel(id: $id, userId: $userId, organizationName: $organizationName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
