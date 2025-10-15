import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/chat/services/chat_service.dart';
import 'package:istoreto/featured/chat/views/chat_screen.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:intl/intl.dart';

/// صفحة عرض المحادثات للتاجر (Vendor Inbox)
class VendorChatListScreen extends StatefulWidget {
  final String vendorId;

  const VendorChatListScreen({super.key, required this.vendorId});

  @override
  State<VendorChatListScreen> createState() => _VendorChatListScreenState();
}

class _VendorChatListScreenState extends State<VendorChatListScreen> {
  late final ChatService chatService;

  @override
  void initState() {
    super.initState();

    // تسجيل ChatService
    if (!Get.isRegistered<ChatService>()) {
      Get.put(ChatService());
    }

    chatService = ChatService.instance;

    // تحميل محادثات التاجر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatService.loadVendorConversations(widget.vendorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'inbox'.tr,
          style: titilliumBold.copyWith(color: Colors.black, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: إضافة ميزة البحث
            },
          ),
        ],
      ),
      body: Obx(() {
        if (chatService.isLoadingConversations) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatService.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_conversations'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'start_chatting_with_customers'.tr,
                  style: titilliumRegular.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => chatService.loadVendorConversations(widget.vendorId),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatService.conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = chatService.conversations[index];
              final hasUnread = conversation.vendorUnreadCount > 0;

              return InkWell(
                onTap: () {
                  Get.to(() => ChatScreen(conversation: conversation));
                },
                child: Container(
                  color: hasUnread ? Colors.blue.shade50 : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // صورة المستخدم
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: TColors.primary.withOpacity(0.1),
                        backgroundImage:
                            conversation.userImageUrl != null &&
                                    conversation.userImageUrl!.isNotEmpty
                                ? NetworkImage(conversation.userImageUrl!)
                                : null,
                        child:
                            conversation.userImageUrl == null ||
                                    conversation.userImageUrl!.isEmpty
                                ? Icon(
                                  Icons.person,
                                  color: TColors.primary,
                                  size: 28,
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),

                      // تفاصيل المحادثة
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // اسم المستخدم
                                Expanded(
                                  child: Text(
                                    conversation.userName ?? 'user'.tr,
                                    style: titilliumBold.copyWith(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight:
                                          hasUnread
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // الوقت
                                if (conversation.lastMessageAt != null)
                                  Text(
                                    _formatTime(conversation.lastMessageAt!),
                                    style: titilliumRegular.copyWith(
                                      fontSize: 12,
                                      color:
                                          hasUnread
                                              ? TColors.primary
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // آخر رسالة
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    conversation.lastMessageText ??
                                        'no_messages_yet'.tr,
                                    style: titilliumRegular.copyWith(
                                      fontSize: 14,
                                      color:
                                          hasUnread
                                              ? Colors.black87
                                              : Colors.grey.shade600,
                                      fontWeight:
                                          hasUnread
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // عداد الرسائل غير المقروءة
                                if (hasUnread)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${conversation.vendorUnreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// تنسيق الوقت
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now'.tr;
    }
  }
}
