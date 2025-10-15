import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/conversation_model.dart';
import '../data/message_model.dart';

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// الحصول على جميع المحادثات للمستخدم
  Future<List<ConversationModel>> getUserConversations(String userId) async {
    try {
      final response = await _supabase
          .from('conversations_with_details')
          .select('*')
          .eq('user_id', userId)
          .order('last_message_at', ascending: false);

      return response
          .map<ConversationModel>((data) => ConversationModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error getting user conversations: $e');
      throw Exception('فشل في تحميل المحادثات');
    }
  }

  /// الحصول على جميع المحادثات للتاجر
  Future<List<ConversationModel>> getVendorConversations(
    String vendorId,
  ) async {
    try {
      final response = await _supabase
          .from('conversations_with_details')
          .select('*')
          .eq('vendor_id', vendorId)
          .order('last_message_at', ascending: false);

      return response
          .map<ConversationModel>((data) => ConversationModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error getting vendor conversations: $e');
      throw Exception('فشل في تحميل المحادثات');
    }
  }

  /// الحصول على محادثة محددة
  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      final response =
          await _supabase
              .from('conversations_with_details')
              .select('*')
              .eq('id', conversationId)
              .single();

      return ConversationModel.fromMap(response);
    } catch (e) {
      print('Error getting conversation: $e');
      return null;
    }
  }

  /// الحصول على أو إنشاء محادثة بين مستخدم وتاجر
  Future<ConversationModel> getOrCreateConversation(
    String userId,
    String vendorId,
  ) async {
    try {
      print(
        '🔍 Calling get_or_create_conversation with userId: $userId, vendorId: $vendorId',
      );

      final response = await _supabase.rpc(
        'get_or_create_conversation',
        params: {'p_user_id': userId, 'p_vendor_id': vendorId},
      );

      print('📦 Response type: ${response.runtimeType}');
      print('📦 Response data: $response');

      // الـ Function ترجع List مع صف واحد
      if (response is List && response.isNotEmpty) {
        final conversationData = response.first;
        print('✅ Conversation data: $conversationData');

        // التأكد من أن البيانات Map
        if (conversationData is Map<String, dynamic>) {
          return ConversationModel.fromMap(conversationData);
        } else {
          print('❌ Expected Map but got: ${conversationData.runtimeType}');
          throw Exception('بيانات المحادثة بصيغة خاطئة');
        }
      } else {
        print('❌ Response is empty or not a List');
        throw Exception('فشل في إنشاء المحادثة');
      }
    } catch (e) {
      print('❌ Error getting or creating conversation: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw Exception('فشل في إنشاء المحادثة: $e');
    }
  }

  /// الحصول على رسائل المحادثة
  Future<List<MessageModel>> getConversationMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('messages_with_sender_details')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<MessageModel>((data) => MessageModel.fromMap(data))
          .toList()
          .reversed
          .toList(); // عكس الترتيب ليكون من الأقدم للأحدث
    } catch (e) {
      print('Error getting conversation messages: $e');
      throw Exception('فشل في تحميل الرسائل');
    }
  }

  /// إرسال رسالة جديدة
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderType,
    String? messageText,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? replyToMessageId,
  }) async {
    try {
      final response =
          await _supabase
              .from('messages')
              .insert({
                'conversation_id': conversationId,
                'sender_id': senderId,
                'sender_type': senderType,
                'message_text': messageText,
                'message_type': messageType,
                'attachment_url': attachmentUrl,
                'attachment_name': attachmentName,
                'attachment_size': attachmentSize,
                'reply_to_message_id': replyToMessageId,
              })
              .select()
              .single();

      return MessageModel.fromMap(response);
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('فشل في إرسال الرسالة');
    }
  }

  /// تمييز الرسائل كمقروءة
  Future<void> markMessagesAsRead(
    String conversationId,
    String readerId,
    String readerType,
  ) async {
    try {
      await _supabase.rpc(
        'mark_messages_as_read',
        params: {
          'p_conversation_id': conversationId,
          'p_reader_id': readerId,
          'p_reader_type': readerType,
        },
      );
    } catch (e) {
      print('Error marking messages as read: $e');
      throw Exception('فشل في تمييز الرسائل كمقروءة');
    }
  }

  /// تحديث حالة المحادثة (مفضلة، مؤرشف، صامت)
  Future<void> updateConversationStatus({
    required String conversationId,
    bool? isArchived,
    bool? isFavorite,
    bool? isMuted,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (isArchived != null) updates['is_archived'] = isArchived;
      if (isFavorite != null) updates['is_favorite'] = isFavorite;
      if (isMuted != null) updates['is_muted'] = isMuted;

      await _supabase
          .from('conversations')
          .update(updates)
          .eq('id', conversationId);
    } catch (e) {
      print('Error updating conversation status: $e');
      throw Exception('فشل في تحديث حالة المحادثة');
    }
  }

  /// الحصول على عدد الرسائل غير المقروءة
  Future<int> getUnreadCount(String userId, String userType) async {
    try {
      final response = await _supabase.rpc(
        'get_unread_count',
        params: {'p_user_id': userId, 'p_user_type': userType},
      );

      return response ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('فشل في حذف الرسالة');
    }
  }

  /// حذف محادثة
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _supabase.from('conversations').delete().eq('id', conversationId);
    } catch (e) {
      print('Error deleting conversation: $e');
      throw Exception('فشل في حذف المحادثة');
    }
  }

  /// البحث في المحادثات
  Future<List<ConversationModel>> searchConversations(
    String userId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('conversations_with_details')
          .select('*')
          .eq('user_id', userId)
          .or(
            'vendor_store_name.ilike.%$query%,last_message_text.ilike.%$query%',
          )
          .order('last_message_at', ascending: false);

      return response
          .map<ConversationModel>((data) => ConversationModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error searching conversations: $e');
      throw Exception('فشل في البحث في المحادثات');
    }
  }

  /// البحث في الرسائل
  Future<List<MessageModel>> searchMessages(
    String conversationId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('messages_with_sender_details')
          .select('*')
          .eq('conversation_id', conversationId)
          .ilike('message_text', '%$query%')
          .order('created_at', ascending: false);

      return response
          .map<MessageModel>((data) => MessageModel.fromMap(data))
          .toList();
    } catch (e) {
      print('Error searching messages: $e');
      throw Exception('فشل في البحث في الرسائل');
    }
  }

  /// الاستماع للتغييرات في المحادثات (Real-time)
  RealtimeChannel listenToConversations(String userId) {
    return _supabase
        .channel('conversations_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print('Conversation updated: $payload');
          },
        )
        .subscribe();
  }

  /// الاستماع للتغييرات في الرسائل (Real-time)
  RealtimeChannel listenToMessages(String conversationId) {
    return _supabase
        .channel('messages_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            print('Message updated: $payload');
          },
        )
        .subscribe();
  }

  /// إلغاء الاشتراك في Real-time
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
