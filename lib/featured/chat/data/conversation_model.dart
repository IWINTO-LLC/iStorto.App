class ConversationModel {
  final String id;
  final String userId;
  final String vendorId;
  final String? lastMessageId;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String lastMessageType;

  // حالة المحادثة
  final bool isArchived;
  final bool isFavorite;
  final bool isMuted;

  // حالة القراءة
  final int userUnreadCount;
  final int vendorUnreadCount;
  final DateTime? lastReadByUserAt;
  final DateTime? lastReadByVendorAt;

  // التواريخ
  final DateTime createdAt;
  final DateTime updatedAt;

  // تفاصيل إضافية (من JOIN)
  final String? userName;
  final String? userImageUrl;
  final String? vendorStoreName;
  final String? vendorImageUrl;
  final String? vendorUserId;

  ConversationModel({
    required this.id,
    required this.userId,
    required this.vendorId,
    this.lastMessageId,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageType = 'text',
    this.isArchived = false,
    this.isFavorite = false,
    this.isMuted = false,
    this.userUnreadCount = 0,
    this.vendorUnreadCount = 0,
    this.lastReadByUserAt,
    this.lastReadByVendorAt,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userImageUrl,
    this.vendorStoreName,
    this.vendorImageUrl,
    this.vendorUserId,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    try {
      // طباعة البيانات للتشخيص
      print('🔍 Parsing conversation from map: ${map.keys}');

      return ConversationModel(
        id: _parseString(map['id']),
        userId: _parseString(map['user_id']),
        vendorId: _parseString(map['vendor_id']),
        lastMessageId: map['last_message_id']?.toString(),
        lastMessageText: map['last_message_text']?.toString(),
        lastMessageAt:
            map['last_message_at'] != null
                ? DateTime.parse(map['last_message_at'].toString())
                : null,
        lastMessageType: map['last_message_type']?.toString() ?? 'text',
        isArchived: map['is_archived'] == true || map['is_archived'] == 'true',
        isFavorite: map['is_favorite'] == true || map['is_favorite'] == 'true',
        isMuted: map['is_muted'] == true || map['is_muted'] == 'true',
        userUnreadCount: _parseInt(map['user_unread_count']),
        vendorUnreadCount: _parseInt(map['vendor_unread_count']),
        lastReadByUserAt:
            map['last_read_by_user_at'] != null
                ? DateTime.parse(map['last_read_by_user_at'].toString())
                : null,
        lastReadByVendorAt:
            map['last_read_by_vendor_at'] != null
                ? DateTime.parse(map['last_read_by_vendor_at'].toString())
                : null,
        createdAt: DateTime.parse(map['created_at'].toString()),
        updatedAt: DateTime.parse(map['updated_at'].toString()),
        userName: map['user_name']?.toString(),
        userImageUrl: map['user_image_url']?.toString(),
        vendorStoreName: map['vendor_store_name']?.toString(),
        vendorImageUrl: map['vendor_image_url']?.toString(),
        vendorUserId: map['vendor_user_id']?.toString(),
      );
    } catch (e) {
      print('❌ Error parsing ConversationModel: $e');
      print('❌ Map data: $map');
      rethrow;
    }
  }

  /// مساعد لتحويل القيمة إلى String بأمان
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List && value.isNotEmpty) return value.first.toString();
    return value.toString();
  }

  /// مساعد لتحويل القيمة إلى int بأمان
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'vendor_id': vendorId,
      'last_message_id': lastMessageId,
      'last_message_text': lastMessageText,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_type': lastMessageType,
      'is_archived': isArchived,
      'is_favorite': isFavorite,
      'is_muted': isMuted,
      'user_unread_count': userUnreadCount,
      'vendor_unread_count': vendorUnreadCount,
      'last_read_by_user_at': lastReadByUserAt?.toIso8601String(),
      'last_read_by_vendor_at': lastReadByVendorAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ConversationModel copyWith({
    String? id,
    String? userId,
    String? vendorId,
    String? lastMessageId,
    String? lastMessageText,
    DateTime? lastMessageAt,
    String? lastMessageType,
    bool? isArchived,
    bool? isFavorite,
    bool? isMuted,
    int? userUnreadCount,
    int? vendorUnreadCount,
    DateTime? lastReadByUserAt,
    DateTime? lastReadByVendorAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userImageUrl,
    String? vendorStoreName,
    String? vendorImageUrl,
    String? vendorUserId,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      isArchived: isArchived ?? this.isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
      isMuted: isMuted ?? this.isMuted,
      userUnreadCount: userUnreadCount ?? this.userUnreadCount,
      vendorUnreadCount: vendorUnreadCount ?? this.vendorUnreadCount,
      lastReadByUserAt: lastReadByUserAt ?? this.lastReadByUserAt,
      lastReadByVendorAt: lastReadByVendorAt ?? this.lastReadByVendorAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      vendorStoreName: vendorStoreName ?? this.vendorStoreName,
      vendorImageUrl: vendorImageUrl ?? this.vendorImageUrl,
      vendorUserId: vendorUserId ?? this.vendorUserId,
    );
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, userId: $userId, vendorId: $vendorId, lastMessageText: $lastMessageText, userUnreadCount: $userUnreadCount, vendorUnreadCount: $vendorUnreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
