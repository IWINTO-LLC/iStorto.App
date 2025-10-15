# دليل تثبيت قاعدة بيانات نظام الدردشة 🗄️
# Chat Database Setup Guide

## نظرة عامة 📋

هذا الدليل يشرح كيفية تثبيت وتفعيل نظام الدردشة في قاعدة بيانات Supabase مع جميع الـ RLS Policies والأمان الكامل.

---

## المتطلبات الأساسية ✅

قبل تشغيل السكريبت، تأكد من وجود:

1. **جدول `user_profiles`**
   ```sql
   -- يجب أن يحتوي على الأقل على:
   - id (UUID)
   - name (TEXT)
   - image_url (TEXT)
   ```

2. **جدول `vendors`**
   ```sql
   -- يجب أن يحتوي على الأقل على:
   - id (UUID)
   - user_id (UUID) -- المرتبط بـ auth.users
   - store_name (TEXT)
   - image_url (TEXT)
   - brief (TEXT)
   ```

3. **حساب Supabase نشط** مع صلاحيات Admin

---

## خطوات التثبيت 🚀

### الخطوة 1: الوصول إلى SQL Editor في Supabase

1. افتح مشروعك في [Supabase Dashboard](https://app.supabase.com)
2. اذهب إلى **SQL Editor** من القائمة الجانبية
3. انقر على **New Query**

### الخطوة 2: نسخ ولصق السكريبت

1. افتح ملف `create_complete_chat_system.sql`
2. انسخ المحتوى الكامل
3. الصق في SQL Editor
4. انقر على **Run** أو اضغط `Ctrl+Enter`

### الخطوة 3: التحقق من نجاح التثبيت

قم بتشغيل الأوامر التالية للتحقق:

```sql
-- 1. التحقق من الجداول
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('conversations', 'messages');

-- 2. التحقق من الـ Views
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public' 
AND table_name IN ('conversations_with_details', 'messages_with_sender_details');

-- 3. التحقق من الـ RLS Policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('conversations', 'messages');

-- 4. التحقق من الـ Functions
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN (
    'mark_messages_as_read', 
    'get_or_create_conversation',
    'update_conversation_on_new_message',
    'update_conversations_updated_at'
);
-- يجب أن يعرض 4 functions
```

---

## هيكل قاعدة البيانات 📊

### 1. جدول `conversations` (المحادثات)

```sql
conversations:
  - id: UUID (PK)
  - user_id: UUID (FK → auth.users)
  - vendor_id: UUID (FK → vendors)
  - last_message_id: UUID
  - last_message_text: TEXT
  - last_message_at: TIMESTAMP
  - is_archived: BOOLEAN
  - is_favorite: BOOLEAN
  - is_muted: BOOLEAN
  - user_unread_count: INTEGER
  - vendor_unread_count: INTEGER
  - last_read_by_user_at: TIMESTAMP
  - last_read_by_vendor_at: TIMESTAMP
  - created_at: TIMESTAMP
  - updated_at: TIMESTAMP
```

### 2. جدول `messages` (الرسائل)

```sql
messages:
  - id: UUID (PK)
  - conversation_id: UUID (FK → conversations)
  - sender_id: UUID
  - sender_type: TEXT ('user' | 'vendor')
  - message_text: TEXT
  - message_type: TEXT ('text' | 'image' | 'file' | 'location' | 'video' | 'audio')
  - attachment_url: TEXT
  - attachment_name: TEXT
  - attachment_size: INTEGER
  - is_read: BOOLEAN
  - read_at: TIMESTAMP
  - reply_to_message_id: UUID (FK → messages)
  - created_at: TIMESTAMP
```

### 3. Views (طرق العرض)

#### `conversations_with_details`
يعرض المحادثات مع تفاصيل التاجر والمستخدم:
- معلومات التاجر (اسم المتجر، الصورة، النبذة)
- معلومات المستخدم (الاسم، الصورة)
- تفاصيل آخر رسالة

#### `messages_with_sender_details`
يعرض الرسائل مع تفاصيل المرسل:
- اسم المرسل (سواء كان مستخدم أو تاجر)
- صورة المرسل
- جميع تفاصيل الرسالة

---

## RLS Policies (سياسات الأمان) 🔒

### سياسات المحادثات:

1. **Users can view their own conversations**
   - المستخدمون يمكنهم رؤية محادثاتهم فقط

2. **Vendors can view their conversations**
   - التجار يمكنهم رؤية محادثات متاجرهم فقط

3. **Users can create conversations**
   - المستخدمون يمكنهم إنشاء محادثات جديدة

4. **Users can update their own conversations**
   - المستخدمون يمكنهم تحديث إعدادات محادثاتهم (أرشفة، مفضلة، كتم صوت)

5. **Vendors can update their conversations**
   - التجار يمكنهم تحديث محادثاتهم

6. **Users can delete their own conversations**
   - المستخدمون يمكنهم حذف محادثاتهم

### سياسات الرسائل:

1. **Users can view messages in their conversations**
   - المستخدمون يمكنهم رؤية رسائل محادثاتهم فقط

2. **Vendors can view messages in their conversations**
   - التجار يمكنهم رؤية رسائل محادثاتهم فقط

3. **Users can send messages**
   - المستخدمون يمكنهم إرسال رسائل في محادثاتهم

4. **Vendors can send messages**
   - التجار يمكنهم إرسال رسائل في محادثاتهم

5. **Users can update their own messages**
   - المستخدمون يمكنهم تحديث حالة القراءة للرسائل

6. **Vendors can update their own messages**
   - التجار يمكنهم تحديث رسائلهم

7. **Users can delete their own messages**
   - المستخدمون يمكنهم حذف رسائلهم

---

## Functions المتاحة ⚡

### 1. `get_or_create_conversation(user_id, vendor_id)`

الحصول على محادثة موجودة أو إنشاء محادثة جديدة إذا لم توجد.

**الاستخدام:**
```sql
SELECT * FROM get_or_create_conversation(
    'user-uuid-here'::UUID,
    'vendor-uuid-here'::UUID
);
```

**المعاملات:**
- `p_user_id`: UUID المستخدم
- `p_vendor_id`: UUID التاجر

**القيمة المرجعة:**
- يرجع صف واحد من `conversations_with_details` مع جميع التفاصيل

**من التطبيق:**
```dart
final result = await supabase.rpc('get_or_create_conversation', params: {
  'p_user_id': userId,
  'p_vendor_id': vendorId,
});
```

---

### 2. `mark_messages_as_read(conversation_id, reader_id, reader_type)`

تمييز جميع الرسائل في محادثة كمقروءة وإعادة تعيين العداد.

**الاستخدام:**
```sql
SELECT mark_messages_as_read(
    'conversation-uuid-here'::UUID,
    'user-uuid-here'::UUID,
    'user'
);
```

**المعاملات:**
- `p_conversation_id`: UUID المحادثة
- `p_reader_id`: UUID القارئ (المستخدم أو التاجر)
- `p_reader_type`: نوع القارئ ('user' أو 'vendor')

**من التطبيق:**
```dart
await supabase.rpc('mark_messages_as_read', params: {
  'p_conversation_id': conversationId,
  'p_reader_id': userId,
  'p_reader_type': 'user',
});
```

---

## Triggers التلقائية 🔄

### 1. `update_conversations_updated_at_trigger`
يحدث `updated_at` تلقائياً عند تعديل المحادثة.

### 2. `update_conversation_on_new_message_trigger`
عند إضافة رسالة جديدة:
- يحدث آخر رسالة في المحادثة
- يزيد عداد الرسائل غير المقروءة للمستقبل
- يحدث `updated_at` للمحادثة

---

## أمثلة استخدام 💡

### إنشاء محادثة جديدة أو الحصول عليها:

**الطريقة الموصى بها (استخدام Function):**
```sql
-- ✅ استخدام get_or_create_conversation
SELECT * FROM get_or_create_conversation(
    auth.uid(),
    'vendor-uuid-here'::UUID
);
```

**من التطبيق:**
```dart
final result = await supabase.rpc('get_or_create_conversation', params: {
  'p_user_id': userId,
  'p_vendor_id': vendorId,
});

if (result != null && result.isNotEmpty) {
  final conversation = ConversationModel.fromMap(result.first);
  print('Conversation ID: ${conversation.id}');
}
```

**الطريقة البديلة (INSERT مع ON CONFLICT):**
```sql
INSERT INTO conversations (user_id, vendor_id)
VALUES (
    'user-uuid-here'::UUID,
    'vendor-uuid-here'::UUID
)
ON CONFLICT (user_id, vendor_id) DO NOTHING
RETURNING *;
```

### إرسال رسالة:

```sql
INSERT INTO messages (
    conversation_id,
    sender_id,
    sender_type,
    message_text,
    message_type
)
VALUES (
    'conversation-uuid'::UUID,
    'sender-uuid'::UUID,
    'user',
    'Hello! How are you?',
    'text'
);
```

### الحصول على محادثات المستخدم:

```sql
SELECT * 
FROM conversations_with_details
WHERE user_id = 'user-uuid'::UUID
ORDER BY updated_at DESC;
```

### الحصول على رسائل محادثة:

```sql
SELECT * 
FROM messages_with_sender_details
WHERE conversation_id = 'conversation-uuid'::UUID
ORDER BY created_at ASC;
```

### تمييز الرسائل كمقروءة:

```sql
SELECT mark_messages_as_read(
    'conversation-uuid'::UUID,
    auth.uid(),
    'user'
);
```

### تحديث إعدادات المحادثة:

```sql
-- أرشفة محادثة
UPDATE conversations
SET is_archived = true
WHERE id = 'conversation-uuid'::UUID;

-- إضافة للمفضلة
UPDATE conversations
SET is_favorite = true
WHERE id = 'conversation-uuid'::UUID;

-- كتم الصوت
UPDATE conversations
SET is_muted = true
WHERE id = 'conversation-uuid'::UUID;
```

---

## استكشاف الأخطاء 🔍

### مشكلة: "permission denied for table conversations"

**الحل:**
```sql
-- تأكد من تفعيل RLS
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- تأكد من وجود Policies
SELECT * FROM pg_policies WHERE tablename = 'conversations';
```

### مشكلة: "relation vendors does not exist"

**الحل:**
تأكد من إنشاء جدول `vendors` قبل تشغيل السكريبت.

### مشكلة: "foreign key violation"

**الحل:**
تأكد من وجود السجلات المطلوبة في الجداول المرجعية (`auth.users`, `vendors`, `user_profiles`).

---

## الصيانة والتحديث 🔧

### إعادة بناء Indexes:

```sql
REINDEX TABLE conversations;
REINDEX TABLE messages;
```

### تنظيف الرسائل القديمة:

```sql
-- حذف الرسائل الأقدم من 6 أشهر
DELETE FROM messages
WHERE created_at < NOW() - INTERVAL '6 months';
```

### إحصائيات النظام:

```sql
-- عدد المحادثات النشطة
SELECT COUNT(*) FROM conversations;

-- عدد الرسائل اليومية
SELECT COUNT(*) 
FROM messages 
WHERE created_at >= CURRENT_DATE;

-- أكثر المستخدمين نشاطاً
SELECT user_id, COUNT(*) as message_count
FROM conversations c
JOIN messages m ON c.id = m.conversation_id
WHERE m.sender_type = 'user'
GROUP BY user_id
ORDER BY message_count DESC
LIMIT 10;
```

---

## الأمان والخصوصية 🔐

### أفضل الممارسات:

1. **لا تعطل RLS أبداً** على جداول الإنتاج
2. **راجع Policies بانتظام** للتأكد من عدم وجود ثغرات
3. **استخدم HTTPS** دائماً للاتصال بقاعدة البيانات
4. **راقب النشاط المشبوه** باستخدام Supabase Logs
5. **احفظ نسخة احتياطية** من قاعدة البيانات بانتظام

### فحص الأمان:

```sql
-- التحقق من تفعيل RLS
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('conversations', 'messages');

-- التحقق من عدد Policies
SELECT tablename, COUNT(*) as policy_count
FROM pg_policies
WHERE tablename IN ('conversations', 'messages')
GROUP BY tablename;
```

---

## الدعم والمساعدة 📞

إذا واجهت أي مشاكل:

1. راجع [Supabase Documentation](https://supabase.com/docs)
2. تحقق من [Supabase Logs](https://app.supabase.com/project/_/logs/explorer)
3. راجع ملف `CHAT_SYSTEM_COMPLETE_GUIDE.md` للتفاصيل

---

## الخلاصة ✅

بعد تشغيل هذا السكريبت، سيكون لديك:

- ✅ نظام دردشة كامل وآمن
- ✅ RLS Policies شاملة لحماية البيانات
- ✅ Triggers تلقائية لتحديث البيانات
- ✅ Views جاهزة للاستخدام في التطبيق
- ✅ Functions مساعدة للعمليات الشائعة
- ✅ Indexes محسنة للأداء العالي

**النظام جاهز الآن للاستخدام في التطبيق!** 🎉

