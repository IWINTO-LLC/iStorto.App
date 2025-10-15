class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; // 'user' or 'vendor'
  final String? messageText;
  final String messageType; // 'text', 'image', 'file', 'location'

  // المرفقات
  final String? attachmentUrl;
  final String? attachmentName;
  final int? attachmentSize;

  // حالة الرسالة
  final bool isRead;
  final DateTime? readAt;

  // رد على رسالة سابقة
  final String? replyToMessageId;
  final MessageModel? replyToMessage; // الرسالة التي يتم الرد عليها

  // التواريخ
  final DateTime createdAt;

  // تفاصيل المرسل (من JOIN)
  final String? senderName;
  final String? senderImageUrl;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    this.messageText,
    this.messageType = 'text',
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.isRead = false,
    this.readAt,
    this.replyToMessageId,
    this.replyToMessage,
    required this.createdAt,
    this.senderName,
    this.senderImageUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    try {
      return MessageModel(
        id: map['id']?.toString() ?? '',
        conversationId: map['conversation_id']?.toString() ?? '',
        senderId: map['sender_id']?.toString() ?? '',
        senderType: map['sender_type']?.toString() ?? 'user',
        messageText: map['message_text']?.toString(),
        messageType: map['message_type']?.toString() ?? 'text',
        attachmentUrl: map['attachment_url']?.toString(),
        attachmentName: map['attachment_name']?.toString(),
        attachmentSize:
            map['attachment_size'] != null
                ? (map['attachment_size'] is int
                    ? map['attachment_size']
                    : int.tryParse(map['attachment_size'].toString()))
                : null,
        isRead: map['is_read'] == true || map['is_read'] == 'true',
        readAt:
            map['read_at'] != null
                ? DateTime.parse(map['read_at'].toString())
                : null,
        replyToMessageId: map['reply_to_message_id']?.toString(),
        replyToMessage:
            map['reply_to_message'] != null
                ? MessageModel.fromMap(
                  map['reply_to_message'] as Map<String, dynamic>,
                )
                : null,
        createdAt:
            map['created_at'] != null
                ? DateTime.parse(map['created_at'].toString())
                : DateTime.now(),
        senderName: map['sender_name']?.toString(),
        senderImageUrl: map['sender_image_url']?.toString(),
      );
    } catch (e) {
      print('❌ Error parsing MessageModel: $e');
      print('❌ Map data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_type': senderType,
      'message_text': messageText,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'attachment_size': attachmentSize,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'reply_to_message_id': replyToMessageId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderType,
    String? messageText,
    String? messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    bool? isRead,
    DateTime? readAt,
    String? replyToMessageId,
    MessageModel? replyToMessage,
    DateTime? createdAt,
    String? senderName,
    String? senderImageUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      messageText: messageText ?? this.messageText,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
    );
  }

  /// التحقق من أن الرسالة من المستخدم الحالي
  bool get isFromCurrentUser {
    // سيتم تحديث هذا في الـ Controller
    return false;
  }

  /// الحصول على اسم المرسل
  String get displayName {
    return senderName ?? (senderType == 'user' ? 'مستخدم' : 'تاجر');
  }

  /// الحصول على رابط صورة المرسل
  String? get displayImageUrl {
    return senderImageUrl;
  }

  /// التحقق من وجود مرفق
  bool get hasAttachment {
    return attachmentUrl != null && attachmentUrl!.isNotEmpty;
  }

  /// التحقق من وجود رد
  bool get hasReply {
    return replyToMessageId != null && replyToMessage != null;
  }

  /// تنسيق حجم الملف
  String get formattedFileSize {
    if (attachmentSize == null) return '';

    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (attachmentSize! >= gb) {
      return '${(attachmentSize! / gb).toStringAsFixed(1)} GB';
    } else if (attachmentSize! >= mb) {
      return '${(attachmentSize! / mb).toStringAsFixed(1)} MB';
    } else if (attachmentSize! >= kb) {
      return '${(attachmentSize! / kb).toStringAsFixed(1)} KB';
    } else {
      return '$attachmentSize Bytes';
    }
  }

  /// تنسيق وقت الرسالة
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, conversationId: $conversationId, senderType: $senderType, messageText: $messageText, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
