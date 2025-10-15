import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/conversation_model.dart';
import '../data/message_model.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  static ChatController get instance => Get.find();

  final ChatService _chatService = ChatService.instance;

  // البحث
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;

  // الرسائل
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxString currentMessageText = ''.obs; // للاستماع للتغييرات

  // الفلاتر
  final RxString selectedFilter = 'all'.obs; // all, favorites, archived
  final RxBool showArchivedOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    _setupMessageListener();
    _loadInitialData();
  }

  /// إعداد listener لحقل الرسالة
  void _setupMessageListener() {
    messageController.addListener(() {
      currentMessageText.value = messageController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// إعداد listener للتمرير
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        // تحميل المزيد من الرسائل عند الوصول للنهاية
        _loadMoreMessages();
      }
    });
  }

  /// تحميل البيانات الأولية
  void _loadInitialData() {
    _chatService.loadConversations();
  }

  /// تحميل المزيد من الرسائل
  void _loadMoreMessages() {
    if (_chatService.selectedConversationId.isNotEmpty) {
      // يمكن إضافة منطق تحميل المزيد هنا
    }
  }

  /// بدء البحث
  void startSearch() {
    isSearching.value = true;
    searchController.clear();
  }

  /// إيقاف البحث
  void stopSearch() {
    isSearching.value = false;
    searchController.clear();
    _chatService.searchResults.clear();
  }

  /// البحث في المحادثات
  void searchConversations(String query) {
    if (query.isEmpty) {
      _chatService.searchResults.clear();
      return;
    }
    _chatService.searchConversations(query);
  }

  /// تحديد المحادثة
  void selectConversation(String conversationId) {
    _chatService.loadMessages(conversationId);
  }

  /// إرسال رسالة
  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty || _chatService.selectedConversationId.isEmpty) return;

    _chatService.sendMessage(
      conversationId: _chatService.selectedConversationId,
      messageText: text,
    );

    messageController.clear();

    // تمرير لآخر رسالة
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  /// إرسال رسالة من التاجر
  void sendVendorMessage(String vendorId) {
    final text = messageController.text.trim();
    if (text.isEmpty || _chatService.selectedConversationId.isEmpty) return;

    _chatService.sendVendorMessage(
      conversationId: _chatService.selectedConversationId,
      vendorId: vendorId,
      messageText: text,
    );

    messageController.clear();

    // تمرير لآخر رسالة
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  /// بدء محادثة جديدة مع تاجر
  Future<void> startConversationWithVendor(String vendorId) async {
    final conversation = await _chatService.startConversationWithVendor(
      vendorId,
    );
    if (conversation != null) {
      selectConversation(conversation.id);
    }
  }

  /// تمرير لآخر رسالة
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// تمرير لآخر رسالة فوراً
  void scrollToBottom() {
    _scrollToBottom();
  }

  /// تبديل حالة المفضلة
  void toggleFavorite(String conversationId, bool isFavorite) {
    _chatService.updateConversationStatus(
      conversationId: conversationId,
      isFavorite: !isFavorite,
    );
  }

  /// تبديل حالة الأرشفة
  void toggleArchive(String conversationId, bool isArchived) {
    _chatService.updateConversationStatus(
      conversationId: conversationId,
      isArchived: !isArchived,
    );
  }

  /// تبديل حالة كتم الصوت
  void toggleMute(String conversationId, bool isMuted) {
    _chatService.updateConversationStatus(
      conversationId: conversationId,
      isMuted: !isMuted,
    );
  }

  /// حذف رسالة
  void deleteMessage(String messageId) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_message'.tr),
        content: Text('delete_message_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              _chatService.deleteMessage(messageId);
            },
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  /// حذف محادثة
  void deleteConversation(String conversationId) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_conversation'.tr),
        content: Text('delete_conversation_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              _chatService.deleteConversation(conversationId);
            },
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  /// تغيير الفلتر
  void changeFilter(String filter) {
    selectedFilter.value = filter;

    switch (filter) {
      case 'all':
        showArchivedOnly.value = false;
        break;
      case 'favorites':
        showArchivedOnly.value = false;
        break;
      case 'archived':
        showArchivedOnly.value = true;
        break;
    }
  }

  /// الحصول على المحادثات المفلترة
  List<ConversationModel> getFilteredConversations() {
    if (isSearching.value && _chatService.searchResults.isNotEmpty) {
      return _chatService.searchResults;
    }

    List<ConversationModel> conversations;

    if (showArchivedOnly.value) {
      conversations = _chatService.archivedConversations;
    } else {
      conversations = _chatService.activeConversations;
    }

    switch (selectedFilter.value) {
      case 'favorites':
        return conversations.where((c) => c.isFavorite).toList();
      case 'archived':
        return conversations.where((c) => c.isArchived).toList();
      default:
        return conversations;
    }
  }

  /// التحقق من أن الرسالة من المستخدم الحالي
  bool isMessageFromCurrentUser(MessageModel message) {
    // سيتم تحديث هذا بناءً على المستخدم الحالي
    return message.senderType == 'user';
  }

  /// تنسيق وقت الرسالة
  String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}${'days_ago'.tr}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${'hours_ago'.tr}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${'minutes_ago'.tr}';
    } else {
      return 'now'.tr;
    }
  }

  /// تنسيق وقت المحادثة
  String formatConversationTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'yesterday'.tr;
      } else if (difference.inDays < 7) {
        return '${difference.inDays}${'days_ago'.tr}';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// تحديث البيانات
  void refreshData() {
    _chatService.loadConversations();
  }

  /// مسح البيانات
  void clearData() {
    _chatService.clearData();
    messageController.clear();
    searchController.clear();
    isSearching.value = false;
    selectedFilter.value = 'all';
    showArchivedOnly.value = false;
  }
}
