# دليل إصلاح مشكلة RLS للعناوين 🔧
# Addresses RLS Fix Guide

## المشكلة 🚨

```
Error creating address: PostgrestException(
  message: new row violates row-level security policy for table "addresses",
  code: 42501,
  details: Forbidden,
  hint: null
)
```

هذا الخطأ يعني أن **Row Level Security (RLS)** على جدول `addresses` يمنع المستخدم من إضافة عنوان جديد.

---

## السبب 🔍

المشكلة تحدث عادةً بسبب واحد أو أكثر من الأسباب التالية:

1. **عدم وجود RLS Policy للإدراج (INSERT)**
2. **Policy خاطئة لا تسمح للمستخدم بالإضافة**
3. **عمود `user_id` غير موجود أو فارغ**
4. **`auth.uid()` لا يطابق `user_id` في البيانات المرسلة**

---

## الحل السريع ⚡

### الخطوة 1: تشغيل سكريبت الإصلاح

1. افتح **Supabase Dashboard** → **SQL Editor**
2. انسخ محتوى ملف `fix_addresses_rls_policies.sql`
3. الصقه في SQL Editor
4. انقر على **Run**

### الخطوة 2: التحقق من النجاح

بعد تشغيل السكريبت، قم بتشغيل هذا الاستعلام للتحقق:

```sql
-- التحقق من تفعيل RLS
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'addresses';
-- يجب أن يرجع: rowsecurity = true

-- التحقق من Policies
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'addresses';
-- يجب أن يعرض 4 policies: SELECT, INSERT, UPDATE, DELETE
```

### الخطوة 3: اختبار من التطبيق

حاول إضافة عنوان جديد من التطبيق. يجب أن يعمل الآن بدون مشاكل.

---

## الحل التفصيلي 📝

### 1. التحقق من هيكل الجدول

تأكد من أن جدول `addresses` يحتوي على الحقول المطلوبة:

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'addresses'
ORDER BY ordinal_position;
```

**الحقول المطلوبة:**
- `id` (UUID) - Primary Key
- `user_id` (UUID) - Foreign Key إلى `auth.users(id)`
- `title` (TEXT)
- `full_address` (TEXT)
- `city` (TEXT)
- `street` (TEXT)
- `building_number` (TEXT)
- `phone` (TEXT)
- `latitude` (DOUBLE PRECISION) - اختياري
- `longitude` (DOUBLE PRECISION) - اختياري
- `is_default` (BOOLEAN) - افتراضي FALSE
- `created_at` (TIMESTAMP WITH TIME ZONE)
- `updated_at` (TIMESTAMP WITH TIME ZONE)

### 2. إنشاء الجدول (إذا لم يكن موجوداً)

```sql
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT,
    full_address TEXT NOT NULL,
    city TEXT,
    street TEXT,
    building_number TEXT,
    phone TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3. تفعيل RLS

```sql
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
```

### 4. إنشاء RLS Policies الصحيحة

```sql
-- Policy للقراءة
CREATE POLICY "Users can view their own addresses"
    ON public.addresses
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy للإدراج (هذا هو الأهم!)
CREATE POLICY "Users can insert their own addresses"
    ON public.addresses
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy للتحديث
CREATE POLICY "Users can update their own addresses"
    ON public.addresses
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy للحذف
CREATE POLICY "Users can delete their own addresses"
    ON public.addresses
    FOR DELETE
    USING (auth.uid() = user_id);
```

### 5. منح الصلاحيات

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON public.addresses TO authenticated;
```

---

## استكشاف الأخطاء المتقدم 🔎

### المشكلة: "auth.uid() is null"

**السبب:** المستخدم غير مسجل دخول أو الـ JWT token منتهي.

**الحل:**
```dart
// في Flutter، تحقق من تسجيل الدخول
final user = Supabase.instance.client.auth.currentUser;
if (user == null) {
  print('User not logged in!');
  // أعد توجيه المستخدم لصفحة تسجيل الدخول
}
```

### المشكلة: "user_id does not match auth.uid()"

**السبب:** الـ `user_id` المرسل في البيانات لا يطابق المستخدم الحالي.

**الحل:**
```dart
// تأكد من أن user_id صحيح عند إنشاء العنوان
final address = AddressModel(
  userId: Supabase.instance.client.auth.currentUser!.id, // ✅ صحيح
  // userId: 'some-other-uuid', // ❌ خطأ
  title: title,
  fullAddress: fullAddress,
  // ... باقي الحقول
);
```

### المشكلة: "Foreign key violation"

**السبب:** الـ `user_id` لا يوجد في جدول `auth.users`.

**الحل:**
```sql
-- تحقق من وجود المستخدم
SELECT id FROM auth.users WHERE id = 'your-user-id-here';

-- إذا لم يوجد، تحقق من تسجيل الدخول في التطبيق
```

### المشكلة: "RLS still not working after fix"

**الحلول المحتملة:**

1. **أعد تسجيل الدخول في التطبيق:**
   ```dart
   await Supabase.instance.client.auth.signOut();
   // ثم سجل دخول مرة أخرى
   ```

2. **تحقق من JWT Token:**
   ```dart
   final session = Supabase.instance.client.auth.currentSession;
   print('Token: ${session?.accessToken}');
   ```

3. **امسح Cache التطبيق:**
   ```bash
   flutter clean
   flutter pub get
   ```

4. **أعد تشغيل Supabase Client:**
   ```dart
   await Supabase.instance.dispose();
   await Supabase.initialize(/* ... */);
   ```

---

## اختبار RLS Policies 🧪

### اختبار من SQL Editor:

```sql
-- اختبار 1: التحقق من auth.uid()
SELECT auth.uid(); 
-- يجب أن يرجع UUID المستخدم الحالي (أو NULL إذا لم تكن مسجل دخول)

-- اختبار 2: محاولة إدراج عنوان
INSERT INTO addresses (user_id, full_address, title)
VALUES (auth.uid(), 'Test Address', 'Home');
-- يجب أن ينجح بدون أخطاء

-- اختبار 3: قراءة العناوين
SELECT * FROM addresses WHERE user_id = auth.uid();
-- يجب أن يعرض العناوين الخاصة بك فقط

-- اختبار 4: محاولة إدراج عنوان لمستخدم آخر (يجب أن يفشل)
INSERT INTO addresses (user_id, full_address, title)
VALUES ('00000000-0000-0000-0000-000000000000', 'Test', 'Test');
-- يجب أن يرجع خطأ RLS
```

### اختبار من التطبيق:

```dart
// في AddressRepository أو AddressService
Future<void> testAddressCreation() async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    print('Current User ID: $userId');
    
    if (userId == null) {
      print('❌ User not logged in');
      return;
    }
    
    final testAddress = AddressModel(
      userId: userId,
      title: 'Test Address',
      fullAddress: '123 Test Street',
      city: 'Test City',
      isDefault: false,
    );
    
    final result = await createAddress(testAddress);
    
    if (result != null) {
      print('✅ Address created successfully: ${result.id}');
    } else {
      print('❌ Failed to create address');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## Best Practices للعناوين 💡

### 1. التحقق من تسجيل الدخول قبل العمليات:

```dart
Future<AddressModel?> createAddress(AddressModel address) async {
  // تحقق من تسجيل الدخول أولاً
  if (Supabase.instance.client.auth.currentUser == null) {
    throw Exception('User must be logged in to create address');
  }
  
  // تأكد من أن user_id صحيح
  address = address.copyWith(
    userId: Supabase.instance.client.auth.currentUser!.id,
  );
  
  // ... باقي الكود
}
```

### 2. معالجة الأخطاء بشكل صحيح:

```dart
try {
  final result = await createAddress(address);
  // نجحت العملية
} on PostgrestException catch (e) {
  if (e.code == '42501') {
    // RLS Policy Error
    print('Permission denied. Please check RLS policies.');
  } else {
    print('Database error: ${e.message}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

### 3. استخدام Transactions للعمليات المعقدة:

```dart
Future<bool> setAsDefault(String addressId) async {
  try {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    
    // استخدم transaction أو multiple queries
    // 1. إلغاء جميع العناوين الافتراضية
    await Supabase.instance.client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId);
    
    // 2. تعيين العنوان الجديد كافتراضي
    await Supabase.instance.client
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId)
        .eq('user_id', userId);
    
    return true;
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
```

---

## الخلاصة ✅

بعد تطبيق هذا الإصلاح، يجب أن:

- ✅ يعمل إنشاء العناوين بدون مشاكل
- ✅ يمكن للمستخدمين رؤية عناوينهم فقط
- ✅ لا يمكن للمستخدمين الوصول لعناوين الآخرين
- ✅ يتم التحقق من الأمان تلقائياً

إذا استمرت المشكلة بعد تطبيق جميع الخطوات، تحقق من:
1. Supabase Logs للحصول على تفاصيل أكثر
2. نسخة Supabase Client محدثة
3. اتصال الإنترنت مستقر

---

## روابط مفيدة 📚

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)

---

**المشكلة محلولة! 🎉**

الآن يمكنك إضافة وإدارة العناوين بأمان وبدون مشاكل.

