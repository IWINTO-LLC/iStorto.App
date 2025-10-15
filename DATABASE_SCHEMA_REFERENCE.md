# مرجع أسماء الأعمدة في قاعدة البيانات 📊
# Database Schema Reference

## نظرة عامة 📋

هذا المستند يوضح أسماء الأعمدة الصحيحة في جداول قاعدة البيانات لتجنب الأخطاء.

---

## الجداول الرئيسية 🗄️

### 1. جدول `vendors` (التجار)

```sql
vendors:
  - id: UUID PRIMARY KEY
  - user_id: UUID REFERENCES auth.users(id)
  - organization_name: TEXT          ← اسم المتجر/المنظمة
  - organization_slug: TEXT          ← رابط فريد للمتجر
  - organization_logo: TEXT          ← شعار/صورة المتجر
  - organization_cover: TEXT         ← صورة الغلاف
  - brief: TEXT                      ← نبذة مختصرة
  - bio: TEXT                        ← السيرة الذاتية التفصيلية
  - is_active: BOOLEAN
  - is_verified: BOOLEAN
  - is_royal: BOOLEAN
  - created_at: TIMESTAMP
  - updated_at: TIMESTAMP
```

**ملاحظات مهمة:**
- ✅ استخدم `organization_name` وليس `store_name`
- ✅ استخدم `organization_logo` وليس `image_url` أو `logo`
- ✅ `user_id` مرتبط بـ `auth.users(id)`

---

### 2. جدول `user_profiles` (ملفات المستخدمين)

```sql
user_profiles:
  - id: UUID PRIMARY KEY
  - user_id: UUID REFERENCES auth.users(id)
  - name: TEXT                       ← اسم المستخدم
  - username: TEXT                   ← اسم المستخدم الفريد
  - profile_image: TEXT              ← صورة الملف الشخصي
  - cover: TEXT                      ← صورة الغلاف (للحسابات التجارية)
  - bio: TEXT                        ← السيرة الذاتية
  - brief: TEXT                      ← نبذة مختصرة
  - phone_number: TEXT
  - email: TEXT
  - default_currency: TEXT
  - account_type: INTEGER            ← 0: عادي, 1: تجاري
  - is_active: BOOLEAN
  - email_verified: BOOLEAN
  - phone_verified: BOOLEAN
  - vendor_id: UUID                  ← معرف المتجر إذا كان تاجراً
  - created_at: TIMESTAMP
  - updated_at: TIMESTAMP
```

**ملاحظات مهمة:**
- ✅ استخدم `profile_image` وليس `image_url`
- ✅ `user_id` مرتبط بـ `auth.users(id)`
- ✅ `vendor_id` يشير إلى `vendors(id)` إذا كان المستخدم تاجراً

---

### 3. جدول `addresses` (العناوين)

```sql
addresses:
  - id: UUID PRIMARY KEY
  - user_id: UUID REFERENCES auth.users(id)
  - title: TEXT                      ← عنوان العنوان (مثل: المنزل، العمل)
  - full_address: TEXT               ← العنوان الكامل
  - city: TEXT
  - street: TEXT
  - building_number: TEXT
  - phone: TEXT
  - latitude: DOUBLE PRECISION
  - longitude: DOUBLE PRECISION
  - is_default: BOOLEAN              ← هل هو العنوان الافتراضي
  - created_at: TIMESTAMP
  - updated_at: TIMESTAMP
```

**ملاحظات مهمة:**
- ✅ `user_id` مرتبط بـ `auth.users(id)`
- ✅ يمكن أن يكون عنوان واحد فقط `is_default = true` لكل مستخدم

---

### 4. جدول `conversations` (المحادثات)

```sql
conversations:
  - id: UUID PRIMARY KEY
  - user_id: UUID REFERENCES auth.users(id)
  - vendor_id: UUID REFERENCES vendors(id)
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

**ملاحظات مهمة:**
- ✅ `UNIQUE (user_id, vendor_id)` - محادثة واحدة فقط لكل مستخدم وتاجر
- ✅ `user_id` مرتبط بـ `auth.users(id)`
- ✅ `vendor_id` مرتبط بـ `vendors(id)`

---

### 5. جدول `messages` (الرسائل)

```sql
messages:
  - id: UUID PRIMARY KEY
  - conversation_id: UUID REFERENCES conversations(id)
  - sender_id: UUID                  ← UUID المرسل (مستخدم أو تاجر)
  - sender_type: TEXT                ← 'user' أو 'vendor'
  - message_text: TEXT
  - message_type: TEXT               ← 'text', 'image', 'file', 'location', 'video', 'audio'
  - attachment_url: TEXT
  - attachment_name: TEXT
  - attachment_size: INTEGER
  - is_read: BOOLEAN
  - read_at: TIMESTAMP
  - reply_to_message_id: UUID REFERENCES messages(id)
  - created_at: TIMESTAMP
```

**ملاحظات مهمة:**
- ✅ `sender_type` يحدد إذا كان المرسل مستخدم أو تاجر
- ✅ `sender_id` يجب أن يطابق `auth.uid()` للمستخدمين أو `vendors.id` للتجار

---

## Views المتاحة 🔍

### 1. `conversations_with_details`

يعرض المحادثات مع تفاصيل كاملة:

```sql
SELECT * FROM conversations_with_details
WHERE user_id = auth.uid()
ORDER BY updated_at DESC;
```

**الأعمدة المضافة:**
- `vendor_store_name` ← من `vendors.organization_name`
- `vendor_image_url` ← من `vendors.organization_logo`
- `vendor_brief` ← من `vendors.brief`
- `user_name` ← من `user_profiles.name`
- `user_image_url` ← من `user_profiles.profile_image`
- `last_message_content` ← من `messages.message_text`
- `last_message_sender_type` ← من `messages.sender_type`
- `last_message_time` ← من `messages.created_at`

### 2. `messages_with_sender_details`

يعرض الرسائل مع تفاصيل المرسل:

```sql
SELECT * FROM messages_with_sender_details
WHERE conversation_id = 'conversation-uuid'
ORDER BY created_at ASC;
```

**الأعمدة المضافة:**
- `user_sender_name` ← اسم المرسل إذا كان مستخدم
- `user_sender_image` ← صورة المرسل إذا كان مستخدم
- `vendor_sender_name` ← اسم المرسل إذا كان تاجر
- `vendor_sender_image` ← صورة المرسل إذا كان تاجر
- `sender_name` ← اسم المرسل (موحد)
- `sender_image_url` ← صورة المرسل (موحد)

---

## الربط بين الجداول 🔗

### العلاقات:

```
auth.users (id)
    ↓
    ├── user_profiles (user_id)
    │       ↓
    │       └── addresses (user_id)
    │       ↓
    │       └── conversations (user_id)
    │
    └── vendors (user_id)
            ↓
            └── conversations (vendor_id)

conversations (id)
    ↓
    └── messages (conversation_id)
```

---

## أمثلة استخدام صحيحة ✅

### 1. الحصول على معلومات التاجر:

```dart
// ✅ صحيح - استخدام الأسماء الصحيحة
final vendor = await supabase
    .from('vendors')
    .select('id, organization_name, organization_logo, brief')
    .eq('id', vendorId)
    .single();

print(vendor['organization_name']); // ✅
print(vendor['organization_logo']); // ✅
```

```dart
// ❌ خطأ - أسماء أعمدة غير موجودة
print(vendor['store_name']); // ❌ خطأ
print(vendor['image_url']);  // ❌ خطأ
```

### 2. الحصول على معلومات المستخدم:

```dart
// ✅ صحيح
final user = await supabase
    .from('user_profiles')
    .select('id, name, profile_image, bio')
    .eq('user_id', userId)
    .single();

print(user['profile_image']); // ✅
```

```dart
// ❌ خطأ
print(user['image_url']); // ❌ خطأ
```

### 3. الحصول على محادثات مع تفاصيل:

```dart
// ✅ صحيح - استخدام View
final conversations = await supabase
    .from('conversations_with_details')
    .select()
    .eq('user_id', userId)
    .order('updated_at', ascending: false);

for (var conv in conversations) {
  print(conv['vendor_store_name']);  // ✅ organization_name
  print(conv['vendor_image_url']);   // ✅ organization_logo
  print(conv['user_image_url']);     // ✅ profile_image
}
```

---

## قائمة الأعمدة السريعة 📝

### للنسخ السريع عند الاستخدام:

| الجدول | اسم المتجر | صورة المتجر | صورة المستخدم |
|--------|-----------|------------|--------------|
| `vendors` | `organization_name` | `organization_logo` | - |
| `user_profiles` | - | - | `profile_image` |
| `conversations_with_details` | `vendor_store_name` | `vendor_image_url` | `user_image_url` |
| `messages_with_sender_details` | `vendor_sender_name` | `vendor_sender_image` | `user_sender_image` |

---

## الخلاصة ✨

**احفظ هذا المرجع واستخدمه دائماً عند:**
- ✅ كتابة استعلامات SQL جديدة
- ✅ إنشاء Views جديدة
- ✅ تطوير ميزات تستخدم هذه الجداول
- ✅ إصلاح أخطاء أسماء الأعمدة

**الأسماء الصحيحة:**
- ✅ `organization_name` (vendors)
- ✅ `organization_logo` (vendors)
- ✅ `profile_image` (user_profiles)

**الأسماء الخاطئة (لا تستخدمها):**
- ❌ `store_name`
- ❌ `image_url`
- ❌ `logo`

---

**احفظ هذا المرجع للاستخدام المستقبلي!** 📌

