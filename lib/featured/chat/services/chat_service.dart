import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/conversation_model.dart';
import '../data/message_model.dart';
import '../repository/chat_repository.dart';
import '../../../controllers/auth_controller.dart';

class ChatService extends GetxController {
  static ChatService get instance => Get.find();

  final ChatRepository _repository = ChatRepository();
  final AuthController _authController = AuthController.instance;

  // قوائم البيانات
  final RxList<ConversationModel> _conversations = <ConversationModel>[].obs;
  final RxList<MessageModel> _messages = <MessageModel>[].obs;
  final RxString _selectedConversationId = ''.obs;
  final RxInt _unreadCount = 0.obs;

  // حالة التحميل
  final RxBool _isLoadingConversations = false.obs;
  final RxBool _isLoadingMessages = false.obs;
  final RxBool _isSendingMessage = false.obs;

  // البحث
  final RxString _searchQuery = ''.obs;
  final RxList<ConversationModel> _searchResults = <ConversationModel>[].obs;

  // Real-time channels
  RealtimeChannel? _conversationsChannel;
  RealtimeChannel? _messagesChannel;

  // Getters
  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  String get selectedConversationId => _selectedConversationId.value;
  int get unreadCount => _unreadCount.value;
  bool get isLoadingConversations => _isLoadingConversations.value;
  bool get isLoadingMessages => _isLoadingMessages.value;
  bool get isSendingMessage => _isSendingMessage.value;
  String get searchQuery => _searchQuery.value;
  List<ConversationModel> get searchResults => _searchResults;

  // المحادثات المفضلة
  List<ConversationModel> get favoriteConversations =>
      _conversations.where((c) => c.isFavorite).toList();

  // المحادثات المأرشفة
  List<ConversationModel> get archivedConversations =>
      _conversations.where((c) => c.isArchived).toList();

  // المحادثات العادية (غير مأرشفة)
  List<ConversationModel> get activeConversations =>
      _conversations.where((c) => !c.isArchived).toList();

  @override
  void onInit() {
    super.onInit();
    _setupRealTimeListeners();
  }

  @override
  void onClose() {
    _conversationsChannel?.unsubscribe();
    _messagesChannel?.unsubscribe();
    super.onClose();
  }

  /// إعداد Real-time listeners
  void _setupRealTimeListeners() {
    final user = _authController.currentUser.value;
    if (user != null) {
      _conversationsChannel = _repository.listenToConversations(user.id);
    }
  }

  /// تحميل المحادثات للمستخدم
  Future<void> loadConversations() async {
    if (_authController.currentUser.value == null) return;

    _isLoadingConversations.value = true;
    
    try {
      final user = _authController.currentUser.value!;
      final conversations = await _repository.getUserConversations(user.id);
      
      _conversations.value = conversations;
      _calculateUnreadCount();
    } catch (e) {
      print('Error loading conversations: $e');
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المحادثات',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoadingConversations.value = false;
    }
  }

  /// تحميل المحادثات للتاجر
  Future<void> loadVendorConversations(String vendorId) async {
    _isLoadingConversations.value = true;
    
    try {
      final conversations = await _repository.getVendorConversations(vendorId);
      _conversations.value = conversations;
      _calculateUnreadCount();
    } catch (e) {
      print('Error loading vendor conversations: $e');
      Get.snackbar(
        'خطأ',
        'فشل في تحميل محادثات المتجر',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoadingConversations.value = false;
    }
  }

  /// تحميل رسائل محادثة محددة
  Future<void> loadMessages(String conversationId) async {
    _isLoadingMessages.value = true;
    _selectedConversationId.value = conversationId;
    
    try {
      final messages = await _repository.getConversationMessages(conversationId);
      _messages.value = messages;
      
      // إعداد Real-time listener للرسائل
      _messagesChannel?.unsubscribe();
      _messagesChannel = _repository.listenToMessages(conversationId);
      
      // تمييز الرسائل كمقروءة
      await _markMessagesAsRead(conversationId);
    } catch (e) {
      print('Error loading messages: $e');
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الرسائل',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isLoadingMessages.value = false;
    }
  }

  /// إرسال رسالة جديدة
  Future<void> sendMessage({
    required String conversationId,
    String? messageText,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? replyToMessageId,
  }) async {
    if (_authController.currentUser.value == null) return;

    _isSendingMessage.value = true;
    
    try {
      final user = _authController.currentUser.value!;
      
      await _repository.sendMessage(
        conversationId: conversationId,
        senderId: user.id,
        senderType: 'user',
        messageText: messageText,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSize: attachmentSize,
        replyToMessageId: replyToMessageId,
      );
      
      // إعادة تحميل المحادثات والرسائل
      await loadConversations();
      await loadMessages(conversationId);
      
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'خطأ',
        'فشل في إرسال الرسالة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isSendingMessage.value = false;
    }
  }

  /// إرسال رسالة من التاجر
  Future<void> sendVendorMessage({
    required String conversationId,
    required String vendorId,
    String? messageText,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? replyToMessageId,
  }) async {
    _isSendingMessage.value = true;
    
    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        senderId: vendorId,
        senderType: 'vendor',
        messageText: messageText,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSize: attachmentSize,
        replyToMessageId: replyToMessageId,
      );
      
      // إعادة تحميل المحادثات والرسائل
      await loadVendorConversations(vendorId);
      await loadMessages(conversationId);
      
    } catch (e) {
      print('Error sending vendor message: $e');
      Get.snackbar(
        'خطأ',
        'فشل في إرسال الرسالة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      _isSendingMessage.value = false;
    }
  }

  /// بدء محادثة جديدة مع تاجر
  Future<ConversationModel?> startConversationWithVendor(String vendorId) async {
    if (_authController.currentUser.value == null) return null;

    try {
      final user = _authController.currentUser.value!;
      final conversation = await _repository.getOrCreateConversation(
        user.id,
        vendorId,
      );
      
      // إعادة تحميل المحادثات
      await loadConversations();
      
      return conversation;
    } catch (e) {
      print('Error starting conversation: $e');
      Get.snackbar(
        'خطأ',
        'فشل في بدء المحادثة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return null;
    }
  }

  /// تمييز الرسائل كمقروءة
  Future<void> _markMessagesAsRead(String conversationId) async {
    if (_authController.currentUser.value == null) return;

    try {
      final user = _authController.currentUser.value!;
      await _repository.markMessagesAsRead(
        conversationId,
        user.id,
        'user',
      );
      
      // تحديث العداد
      _calculateUnreadCount();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// تحديث حالة المحادثة
  Future<void> updateConversationStatus({
    required String conversationId,
    bool? isArchived,
    bool? isFavorite,
    bool? isMuted,
  }) async {
    try {
      await _repository.updateConversationStatus(
        conversationId: conversationId,
        isArchived: isArchived,
        isFavorite: isFavorite,
        isMuted: isMuted,
      );
      
      // تحديث القائمة المحلية
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final updated = _conversations[index].copyWith(
          isArchived: isArchived,
          isFavorite: isFavorite,
          isMuted: isMuted,
        );
        _conversations[index] = updated;
      }
      
      Get.snackbar(
        'نجح',
        'تم تحديث حالة المحادثة',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error updating conversation status: $e');
      Get.snackbar(
        'خطأ',
        'فشل في تحديث حالة المحادثة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// البحث في المحادثات
  Future<void> searchConversations(String query) async {
    if (_authController.currentUser.value == null) return;

    _searchQuery.value = query;
    
    if (query.isEmpty) {
      _searchResults.clear();
      return;
    }

    try {
      final user = _authController.currentUser.value!;
      final results = await _repository.searchConversations(user.id, query);
      _searchResults.value = results;
    } catch (e) {
      print('Error searching conversations: $e');
      _searchResults.clear();
    }
  }

  /// البحث في الرسائل
  Future<List<MessageModel>> searchMessages(String query) async {
    if (_selectedConversationId.value.isEmpty) return [];

    try {
      return await _repository.searchMessages(
        _selectedConversationId.value,
        query,
      );
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(messageId);
      
      // إزالة الرسالة من القائمة المحلية
      _messages.removeWhere((m) => m.id == messageId);
      
      // إعادة تحميل المحادثات
      await loadConversations();
      
      Get.snackbar(
        'نجح',
        'تم حذف الرسالة',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error deleting message: $e');
      Get.snackbar(
        'خطأ',
        'فشل في حذف الرسالة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// حذف محادثة
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
      
      // إزالة المحادثة من القائمة المحلية
      _conversations.removeWhere((c) => c.id == conversationId);
      
      // إعادة حساب العداد
      _calculateUnreadCount();
      
      Get.snackbar(
        'نجح',
        'تم حذف المحادثة',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error deleting conversation: $e');
      Get.snackbar(
        'خطأ',
        'فشل في حذف المحادثة',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// حساب عدد الرسائل غير المقروءة
  void _calculateUnreadCount() {
    _unreadCount.value = _conversations
        .where((c) => !c.isArchived)
        .fold(0, (sum, c) => sum + c.userUnreadCount);
  }

  /// الحصول على عدد الرسائل غير المقروءة للتاجر
  Future<int> getVendorUnreadCount(String vendorId) async {
    try {
      return await _repository.getUnreadCount(vendorId, 'vendor');
    } catch (e) {
      print('Error getting vendor unread count: $e');
      return 0;
    }
  }

  /// مسح البيانات
  void clearData() {
    _conversations.clear();
    _messages.clear();
    _searchResults.clear();
    _selectedConversationId.value = '';
    _unreadCount.value = 0;
    _searchQuery.value = '';
  }
}
