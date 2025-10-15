import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/message_model.dart';

/// Widget لعرض حالة الرسالة مثل واتساب
class MessageStatusWidget extends StatelessWidget {
  final MessageModel message;
  final bool isFromCurrentUser;

  const MessageStatusWidget({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كانت الرسالة ليست من المستخدم الحالي، لا نعرض حالة
    if (!isFromCurrentUser) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // وقت الرسالة
        Text(
          _formatTime(message.createdAt),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 4),
        
        // أيقونة الحالة
        _buildStatusIcon(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    // تحديد حالة الرسالة
    MessageStatus status = _getMessageStatus();
    
    switch (status) {
      case MessageStatus.sent:
        return const Icon(
          Icons.done,
          size: 16,
          color: Colors.white70,
        );
      
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.white70,
        );
      
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue,
        );
      
      case MessageStatus.failed:
        return const Icon(
          Icons.error,
          size: 16,
          color: Colors.red,
        );
      
      case MessageStatus.pending:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
    }
  }

  MessageStatus _getMessageStatus() {
    // إذا كان هناك وقت قراءة، الرسالة مقروءة
    if (message.readAt != null) {
      return MessageStatus.read;
    }
    
    // إذا كان هناك خطأ في الإرسال (يمكن إضافة هذا الحقل لاحقاً)
    // if (message.hasError) {
    //   return MessageStatus.failed;
    // }
    
    // إذا كانت الرسالة مرسلة ولكن لم تُقرأ بعد
    if (message.isRead == false) {
      return MessageStatus.delivered;
    }
    
    // إذا كانت الرسالة مرسلة
    return MessageStatus.sent;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// حالات الرسالة
enum MessageStatus {
  pending,    // جاري الإرسال
  sent,       // تم الإرسال
  delivered,  // تم التسليم
  read,       // تم القراءة
  failed,     // فشل الإرسال
}

/// Widget لعرض حالة الاتصال (متصل/غير متصل)
class OnlineStatusWidget extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSeen;

  const OnlineStatusWidget({
    super.key,
    required this.isOnline,
    this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Online',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (lastSeen != null) {
      return Text(
        'Last seen ${_formatLastSeen(lastSeen!)}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      );
    } else {
      return const Text(
        'Offline',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      );
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Widget لعرض مؤشر الكتابة
class TypingIndicatorWidget extends StatelessWidget {
  final bool isTyping;

  const TypingIndicatorWidget({
    super.key,
    required this.isTyping,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTyping) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'typing'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          _buildTypingDots(),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return SizedBox(
      width: 20,
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 600 + (index * 200)),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

/// Widget لعرض عدد الرسائل غير المقروءة
class UnreadCountWidget extends StatelessWidget {
  final int count;

  const UnreadCountWidget({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Widget لعرض حالة المرفقات
class AttachmentStatusWidget extends StatelessWidget {
  final String? attachmentUrl;
  final String? attachmentName;
  final int? attachmentSize;
  final bool isUploading;
  final double? uploadProgress;

  const AttachmentStatusWidget({
    super.key,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.isUploading = false,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (isUploading && uploadProgress != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: uploadProgress,
              strokeWidth: 2,
            ),
            const SizedBox(height: 4),
            Text(
              'uploading'.tr,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (attachmentUrl != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_file, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachmentName ?? 'file_message'.tr,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attachmentSize != null)
                  Text(
                    _formatFileSize(attachmentSize!),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatFileSize(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    
    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    } else {
      return '$bytes Bytes';
    }
  }
}
