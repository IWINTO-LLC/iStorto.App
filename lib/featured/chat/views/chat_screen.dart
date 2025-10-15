import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/conversation_model.dart';
import '../data/message_model.dart';
import '../controllers/chat_controller.dart';
import '../services/chat_service.dart';
import '../../../utils/common/styles/styles.dart';
import '../../../utils/constants/color.dart';
import '../widgets/message_status_widget.dart';

class ChatScreen extends StatelessWidget {
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    // تسجيل Controllers
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    if (!Get.isRegistered<ChatService>()) {
      Get.put(ChatService());
    }

    final chatController = ChatController.instance;
    final chatService = ChatService.instance;

    // تحميل الرسائل عند فتح المحادثة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.selectConversation(conversation.id);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            // صورة التاجر
            CircleAvatar(
              radius: 18,
              backgroundColor: TColors.primary.withOpacity(0.1),
              backgroundImage:
                  conversation.vendorImageUrl != null
                      ? NetworkImage(conversation.vendorImageUrl!)
                      : null,
              child:
                  conversation.vendorImageUrl == null
                      ? Icon(Icons.store, color: TColors.primary, size: 16)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.vendorStoreName ?? 'unknown_vendor'.tr,
                    style: titilliumBold.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  OnlineStatusWidget(
                    isOnline: true, // يمكن تحسين هذا لاحقاً
                    lastSeen: null,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // مكالمة صوتية
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // TODO: بدء مكالمة صوتية
            },
          ),
          // مكالمة فيديو
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: بدء مكالمة فيديو
            },
          ),
          // قائمة الخيارات
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, chatController),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'view_profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 8),
                        Text('view_profile'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'media',
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library, size: 20),
                        const SizedBox(width: 8),
                        Text('media'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'search',
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20),
                        const SizedBox(width: 8),
                        Text('search_in_chat'.tr),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: conversation.isMuted ? 'unmute' : 'mute',
                    child: Row(
                      children: [
                        Icon(
                          conversation.isMuted
                              ? Icons.volume_up
                              : Icons.volume_off,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          conversation.isMuted
                              ? 'unmute_conversation'.tr
                              : 'mute_conversation'.tr,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: conversation.isFavorite ? 'unfavorite' : 'favorite',
                    child: Row(
                      children: [
                        Icon(
                          conversation.isFavorite
                              ? Icons.star_border
                              : Icons.star,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          conversation.isFavorite
                              ? 'remove_from_favorites'.tr
                              : 'add_to_favorites'.tr,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'clear_chat',
                    child: Row(
                      children: [
                        const Icon(Icons.clear_all, size: 20),
                        const SizedBox(width: 8),
                        Text('clear_chat_history'.tr),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: Obx(() {
              if (chatService.isLoadingMessages) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = chatService.messages;

              if (messages.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                controller: chatController.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(message, chatController);
                },
              );
            }),
          ),

          // شريط إرسال الرسالة
          _buildMessageInput(chatController),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, ChatController controller) {
    final isFromCurrentUser = controller.isMessageFromCurrentUser(message);
    final isTextMessage = message.messageType == 'text';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: TColors.primary.withOpacity(0.1),
              backgroundImage:
                  message.senderImageUrl != null
                      ? NetworkImage(message.senderImageUrl!)
                      : null,
              child:
                  message.senderImageUrl == null
                      ? Icon(
                        message.senderType == 'user'
                            ? Icons.person
                            : Icons.store,
                        color: TColors.primary,
                        size: 12,
                      )
                      : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromCurrentUser ? TColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
                  bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTextMessage)
                    Text(
                      message.messageText ?? '',
                      style: titilliumRegular.copyWith(
                        fontSize: 16,
                        color:
                            isFromCurrentUser ? Colors.white : Colors.black87,
                      ),
                    )
                  else
                    _buildAttachmentMessage(message, isFromCurrentUser),

                  const SizedBox(height: 4),

                  MessageStatusWidget(
                    message: message,
                    isFromCurrentUser: isFromCurrentUser,
                  ),
                ],
              ),
            ),
          ),
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: null, // سيتم إضافة صورة المستخدم لاحقاً
              child: const Icon(Icons.person, color: Colors.grey, size: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentMessage(MessageModel message, bool isFromCurrentUser) {
    Widget attachmentWidget;

    switch (message.messageType) {
      case 'image':
        attachmentWidget = Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade300,
          ),
          child:
              message.attachmentUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message.attachmentUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey.shade600,
                        );
                      },
                    ),
                  )
                  : Icon(Icons.image, size: 50, color: Colors.grey.shade600),
        );
        break;
      case 'file':
        attachmentWidget = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file,
                color: isFromCurrentUser ? Colors.white : TColors.primary,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.attachmentName ?? 'file_message'.tr,
                    style: titilliumRegular.copyWith(
                      fontSize: 14,
                      color: isFromCurrentUser ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.attachmentSize != null)
                    Text(
                      message.formattedFileSize,
                      style: titilliumRegular.copyWith(
                        fontSize: 12,
                        color:
                            isFromCurrentUser
                                ? Colors.white70
                                : Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
        break;
      case 'location':
        attachmentWidget = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: isFromCurrentUser ? Colors.white : TColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'location_message'.tr,
                style: titilliumRegular.copyWith(
                  fontSize: 14,
                  color: isFromCurrentUser ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
        break;
      default:
        attachmentWidget = Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            'unknown_message_type'.tr,
            style: titilliumRegular.copyWith(
              fontSize: 14,
              color: isFromCurrentUser ? Colors.white : Colors.black87,
            ),
          ),
        );
    }

    return GestureDetector(
      onTap: () {
        // TODO: فتح المرفق
      },
      child: attachmentWidget,
    );
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر المرفقات
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: إظهار قائمة المرفقات
            },
          ),

          // حقل النص
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: 'type_message'.tr,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.sendMessage();
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // زر الإرسال مع Obx
          Obx(() {
            // استخدام currentMessageText من Controller
            final hasText =
                controller.currentMessageText.value.trim().isNotEmpty;

            return Container(
              decoration: BoxDecoration(
                color: hasText ? TColors.primary : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed:
                    hasText
                        ? () {
                          if (controller.messageController.text
                              .trim()
                              .isNotEmpty) {
                            controller.sendMessage();
                          }
                        }
                        : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'no_messages'.tr,
            style: titilliumBold.copyWith(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_messages_subtitle'.tr,
            style: titilliumRegular.copyWith(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, ChatController controller) {
    switch (action) {
      case 'view_profile':
        // TODO: فتح ملف التاجر الشخصي
        break;
      case 'media':
        // TODO: فتح معرض الوسائط
        break;
      case 'search':
        // TODO: فتح البحث في المحادثة
        break;
      case 'mute':
        controller.toggleMute(conversation.id, conversation.isMuted);
        break;
      case 'unmute':
        controller.toggleMute(conversation.id, conversation.isMuted);
        break;
      case 'favorite':
        controller.toggleFavorite(conversation.id, conversation.isFavorite);
        break;
      case 'unfavorite':
        controller.toggleFavorite(conversation.id, conversation.isFavorite);
        break;
      case 'clear_chat':
        // TODO: مسح تاريخ المحادثة
        break;
    }
  }
}
