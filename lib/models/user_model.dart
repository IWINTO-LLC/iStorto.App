class UserModel {
  final String id;
  final String userId;
  final String? vendorId;
  final String? username;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String profileImage;
  final String bio;
  final String brief;
  final String defaultCurrency;
  final int accountType; // 0: regular, 1: commercial
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.userId,
    this.vendorId,
    this.username,
    required this.name,
    this.email,
    this.phoneNumber,
    this.profileImage = '',
    this.bio = '',
    this.brief = '',
    this.defaultCurrency = 'USD',
    this.accountType = 0, // Default to regular account
    this.isActive = true,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      vendorId: json['vendor_id'] as String?, // ✨ vendor_id from JSON
      username: json['username'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profileImage: json['profile_image'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      brief: json['brief'] as String? ?? '',
      defaultCurrency: json['default_currency'] as String? ?? 'USD',
      accountType: json['account_type'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Factory constructor from auth.users JSON (for follow system)
  factory UserModel.fromAuthUsersJson(Map<String, dynamic> json) {
    final rawUserMetaData =
        json['raw_user_meta_data'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id: json['id'] as String,
      userId: json['id'] as String, // In auth.users, id is the user_id
      vendorId: null, // Not available in auth.users
      username: rawUserMetaData['username'] as String?,
      name: rawUserMetaData['name'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: rawUserMetaData['phone_number'] as String?,
      profileImage: rawUserMetaData['profile_image'] as String? ?? '',
      bio: rawUserMetaData['bio'] as String? ?? '',
      brief: rawUserMetaData['brief'] as String? ?? '',
      defaultCurrency: rawUserMetaData['default_currency'] as String? ?? 'USD',
      accountType: rawUserMetaData['account_type'] as int? ?? 0,
      isActive: json['email_confirmed_at'] != null,
      emailVerified: json['email_confirmed_at'] != null,
      phoneVerified: rawUserMetaData['phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vendor_id': vendorId, // ✨ vendor_id to JSON
      'username': username,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'bio': bio,
      'brief': brief,
      'default_currency': defaultCurrency,
      'account_type': accountType,
      'is_active': isActive,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create user for registration
  factory UserModel.createForRegistration({
    required String userId,
    required String email,
    String? phoneNumber,
    String? name,
    String? username,
    int accountType = 0, // Default to regular account
  }) {
    final now = DateTime.now();
    return UserModel(
      id: '', // Will be set by database
      userId: userId,
      username: username ?? email.split('@')[0],
      name: name ?? email.split('@')[0],
      email: email,
      phoneNumber: phoneNumber,
      profileImage: '',
      bio: '',
      brief: '',
      defaultCurrency: 'USD',
      accountType: accountType,
      isActive: true,
      emailVerified: false,
      phoneVerified: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create user for social login
  factory UserModel.createForSocialLogin({
    required String userId,
    required String email,
    String? name,
    String? profileImage,
    String? username,
    int accountType = 0, // Default to regular account
  }) {
    final now = DateTime.now();
    return UserModel(
      id: '', // Will be set by database
      userId: userId,
      username: username ?? email.split('@')[0],
      name: name ?? email.split('@')[0],
      email: email,
      phoneNumber: null,
      profileImage: profileImage ?? '',
      bio: '',
      brief: '',
      defaultCurrency: 'USD',
      accountType: accountType,
      isActive: true,
      emailVerified: true,
      phoneVerified: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? userId,
    String? vendorId,
    String? username,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImage,
    String? bio,
    String? brief,
    String? defaultCurrency,
    int? accountType,
    bool? isActive,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId, // ✨ vendor_id in copyWith
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      brief: brief ?? this.brief,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      accountType: accountType ?? this.accountType,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update timestamp
  UserModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  // Check if user is complete
  bool get isComplete {
    return name.isNotEmpty && email != null && email!.isNotEmpty;
  }

  // Check if user profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email != null &&
        email!.isNotEmpty &&
        bio.isNotEmpty;
  }

  // Get display name
  String get displayName {
    return name.isNotEmpty
        ? name
        : (username ?? email?.split('@')[0] ?? 'User');
  }

  // Get initials
  String get initials {
    if (name.isNotEmpty) {
      final words = name.split(' ');
      if (words.length >= 2) {
        return '${words[0][0]}${words[1][0]}'.toUpperCase();
      } else {
        return name[0].toUpperCase();
      }
    } else if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  // Check if account is commercial
  bool get isCommercialAccount {
    return accountType == 1;
  }

  // Check if account is regular
  bool get isRegularAccount {
    return accountType == 0;
  }

  // Check if user is a vendor (has vendor_id)
  bool get isVendor {
    return vendorId != null && vendorId!.isNotEmpty;
  }

  // Check if user is a verified vendor
  bool get isVerifiedVendor {
    return isCommercialAccount && isVendor;
  }

  // Get account type display name
  String get accountTypeDisplayName {
    switch (accountType) {
      case 1:
        return 'Commercial';
      case 0:
      default:
        return 'Regular';
    }
  }

  // Get account type display name in Arabic
  String get accountTypeDisplayNameAr {
    switch (accountType) {
      case 1:
        return 'تجاري';
      case 0:
      default:
        return 'عادي';
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, userId: $userId, vendorId: $vendorId, username: $username, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id && other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode;
  }
}
