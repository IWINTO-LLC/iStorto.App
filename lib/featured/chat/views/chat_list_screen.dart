import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/conversation_model.dart';
import '../controllers/chat_controller.dart';
import '../services/chat_service.dart';
import '../../../utils/common/styles/styles.dart';
import '../../../utils/constants/color.dart';
import 'chat_screen.dart';
import '../widgets/message_status_widget.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatController chatController;
  late final ChatService chatService;

  @override
  void initState() {
    super.initState();

    // تسجيل Controllers
    if (!Get.isRegistered<ChatService>()) {
      Get.put(ChatService());
    }
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }

    chatController = ChatController.instance;
    chatService = ChatService.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('chats'.tr, style: titilliumBold.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // زر البحث
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: chatController.startSearch,
          ),
          // قائمة الخيارات
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  // TODO: فتح إعدادات المحادثة
                  break;
                case 'help':
                  // TODO: فتح المساعدة
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings, size: 20),
                        const SizedBox(width: 8),
                        Text('chat_settings'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'help',
                    child: Row(
                      children: [
                        const Icon(Icons.help, size: 20),
                        const SizedBox(width: 8),
                        Text('chat_help'.tr),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Obx(
            () =>
                chatController.isSearching.value
                    ? Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: chatController.searchController,
                              decoration: InputDecoration(
                                hintText: 'search_conversations'.tr,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    chatController.searchController.clear();
                                    chatController.searchConversations('');
                                  },
                                ),
                              ),
                              onChanged: chatController.searchConversations,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: chatController.stopSearch,
                            child: Text('cancel'.tr),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),

          // فلاتر المحادثات
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all'.tr, 'all', chatController),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'favorites'.tr,
                          'favorites',
                          chatController,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'archived'.tr,
                          'archived',
                          chatController,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة المحادثات
          Expanded(
            child: Obx(() {
              if (chatService.isLoadingConversations) {
                return const Center(child: CircularProgressIndicator());
              }

              final conversations = chatController.getFilteredConversations();

              if (conversations.isEmpty) {
                return _buildEmptyState(chatController);
              }

              return RefreshIndicator(
                onRefresh: chatService.loadConversations,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _buildConversationItem(conversation, chatController);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    ChatController controller,
  ) {
    return Obx(
      () => FilterChip(
        label: Text(label),
        selected: controller.selectedFilter.value == value,
        onSelected: (selected) {
          if (selected) {
            controller.changeFilter(value);
          }
        },
        selectedColor: TColors.primary.withOpacity(0.2),
        checkmarkColor: TColors.primary,
        labelStyle: TextStyle(
          color:
              controller.selectedFilter.value == value
                  ? TColors.primary
                  : Colors.grey.shade600,
          fontWeight:
              controller.selectedFilter.value == value
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildConversationItem(
    ConversationModel conversation,
    ChatController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildAvatar(conversation),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.vendorStoreName ?? 'unknown_vendor'.tr,
                style: titilliumBold.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.isMuted)
              const Icon(Icons.volume_off, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            if (conversation.isFavorite)
              const Icon(Icons.star, size: 16, color: Colors.amber),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              conversation.lastMessageText ?? 'no_messages'.tr,
              style: titilliumRegular.copyWith(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  controller.formatConversationTime(conversation.lastMessageAt),
                  style: titilliumRegular.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (conversation.userUnreadCount > 0) ...[
                  const SizedBox(width: 8),
                  UnreadCountWidget(count: conversation.userUnreadCount),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected:
              (value) => _handleMenuAction(value, conversation, controller),
          itemBuilder:
              (context) => [
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
                PopupMenuItem(
                  value: conversation.isArchived ? 'unarchive' : 'archive',
                  child: Row(
                    children: [
                      Icon(
                        conversation.isArchived
                            ? Icons.unarchive
                            : Icons.archive,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation.isArchived
                            ? 'unarchive_conversation'.tr
                            : 'archive_conversation'.tr,
                      ),
                    ],
                  ),
                ),
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
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'delete_conversation'.tr,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () => _openChat(conversation),
      ),
    );
  }

  Widget _buildAvatar(ConversationModel conversation) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: TColors.primary.withOpacity(0.1),
          backgroundImage:
              conversation.vendorImageUrl != null
                  ? NetworkImage(conversation.vendorImageUrl!)
                  : null,
          child:
              conversation.vendorImageUrl == null
                  ? Icon(Icons.store, color: TColors.primary, size: 20)
                  : null,
        ),
        // مؤشر الحالة (يمكن إضافته لاحقاً)
        // Positioned(
        //   bottom: 0,
        //   right: 0,
        //   child: Container(
        //     width: 12,
        //     height: 12,
        //     decoration: BoxDecoration(
        //       color: Colors.green,
        //       shape: BoxShape.circle,
        //       border: Border.all(color: Colors.white, width: 2),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildEmptyState(ChatController controller) {
    String title;
    String subtitle;
    IconData icon;

    switch (controller.selectedFilter.value) {
      case 'favorites':
        title = 'no_conversations'.tr;
        subtitle = 'favorite_chats'.tr;
        icon = Icons.star_border;
        break;
      case 'archived':
        title = 'no_conversations'.tr;
        subtitle = 'archived_chats'.tr;
        icon = Icons.archive;
        break;
      default:
        title = 'no_conversations'.tr;
        subtitle = 'no_conversations_subtitle'.tr;
        icon = Icons.chat_bubble_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: titilliumBold.copyWith(
              fontSize: 20,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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

  void _handleMenuAction(
    String action,
    ConversationModel conversation,
    ChatController controller,
  ) {
    switch (action) {
      case 'favorite':
        controller.toggleFavorite(conversation.id, conversation.isFavorite);
        break;
      case 'unfavorite':
        controller.toggleFavorite(conversation.id, conversation.isFavorite);
        break;
      case 'archive':
        controller.toggleArchive(conversation.id, conversation.isArchived);
        break;
      case 'unarchive':
        controller.toggleArchive(conversation.id, conversation.isArchived);
        break;
      case 'mute':
        controller.toggleMute(conversation.id, conversation.isMuted);
        break;
      case 'unmute':
        controller.toggleMute(conversation.id, conversation.isMuted);
        break;
      case 'delete':
        controller.deleteConversation(conversation.id);
        break;
    }
  }

  void _openChat(ConversationModel conversation) {
    Get.to(() => ChatScreen(conversation: conversation));
  }
}
