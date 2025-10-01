# دليل ربط Vendor ID مع User Model
## User-Vendor ID Integration Guide

---

## 🎯 الهدف (Goal)

ربط `vendor_id` في `UserModel` للحصول على معرّف التاجر تلقائياً عند جلب بيانات المستخدم.

---

## 📊 بنية قاعدة البيانات (Database Structure)

### جدول `user_profiles`:
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  name VARCHAR(255),
  email VARCHAR(255),
  account_type INTEGER DEFAULT 0,  -- 0: regular, 1: commercial
  ...
);
```

### جدول `vendors`:
```sql
CREATE TABLE vendors (
  id UUID PRIMARY KEY,              -- vendor_id
  user_id UUID REFERENCES auth.users(id),
  organization_name VARCHAR(255),
  organization_bio TEXT,
  ...
);
```

### العلاقة:
```
user_profiles (user_id) ←→ vendors (user_id)
```

إذا كان المستخدم تاجر (account_type = 1)، سيكون له صف في جدول `vendors`.

---

## ✅ ما تم تنفيذه

### 1️⃣ تحديث `UserModel`

أُضيف حقل `vendorId`:

```dart
class UserModel {
  final String id;
  final String userId;
  final String? vendorId;  // ✨ جديد!
  final String? username;
  // ... باقي الحقول
}
```

**الاستخدام**:
```dart
UserModel user = await userRepository.getUserById(userId);

if (user.vendorId != null) {
  print('This user is a vendor with ID: ${user.vendorId}');
  // يمكنك الآن استخدام vendor_id مباشرة
}
```

---

### 2️⃣ تحديث `UserRepository`

#### تم تعديل `getUserById`:

```dart
Future<UserModel?> getUserById(String id) async {
  try {
    // محاولة الجلب مع join على vendors
    final response = await _client
        .from(_tableName)
        .select('*, vendors!inner(id)')  // Join مع vendors
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      // للمستخدمين العاديين (غير التجار)
      final userResponse =
          await _client.from(_tableName).select().eq('id', id).single();
      return UserModel.fromJson(userResponse);
    }

    // استخراج vendor_id من البيانات المدمجة
    final userData = Map<String, dynamic>.from(response);
    if (userData['vendors'] != null && userData['vendors'] is List) {
      final vendors = userData['vendors'] as List;
      if (vendors.isNotEmpty && vendors[0]['id'] != null) {
        userData['vendor_id'] = vendors[0]['id'];  // ✨ إضافة vendor_id
      }
    }
    userData.remove('vendors'); // إزالة البيانات المدمجة

    return UserModel.fromJson(userData);
  } catch (e) {
    print('Error getting user by ID: $e');
    return null;
  }
}
```

#### تم تعديل `getUserByUserId`:

نفس المنطق، لكن يبحث بـ `user_id` بدلاً من `id`.

---

## 🔄 كيف يعمل (How It Works)

### السيناريو 1: مستخدم عادي (Regular User)

```dart
// المستخدم: account_type = 0
UserModel user = await userRepository.getUserById('user-123');

print(user.vendorId);  // null ✅
print(user.accountType);  // 0 (regular)
```

**ما يحدث**:
1. محاولة join مع `vendors` → فشل (لا يوجد صف)
2. الرجوع إلى جلب عادي بدون join
3. `vendorId` = `null`

---

### السيناريو 2: مستخدم تاجر (Vendor User)

```dart
// المستخدم: account_type = 1
UserModel user = await userRepository.getUserById('user-456');

print(user.vendorId);  // 'vendor-uuid-789' ✅
print(user.accountType);  // 1 (commercial)
```

**ما يحدث**:
1. join مع `vendors` → نجح
2. استخراج `vendors[0]['id']` → `vendor-uuid-789`
3. إضافة `vendor_id` إلى `userData`
4. `UserModel.fromJson()` يقرأ `vendor_id`

---

## 📝 أمثلة استخدام (Usage Examples)

### مثال 1: التحقق من نوع الحساب

```dart
Future<void> checkUserType() async {
  final user = await userRepository.getUserById('user-id');
  
  if (user == null) {
    print('User not found');
    return;
  }

  if (user.isCommercialAccount && user.vendorId != null) {
    print('✅ Verified Vendor');
    print('Vendor ID: ${user.vendorId}');
    
    // يمكنك الآن استخدام vendor_id
    final products = await productRepository.getVendorProducts(user.vendorId!);
  } else {
    print('Regular User');
  }
}
```

---

### مثال 2: عرض بيانات المتجر

```dart
Future<Widget> buildUserProfile(String userId) async {
  final user = await userRepository.getUserById(userId);
  
  if (user == null) {
    return Text('User not found');
  }

  return Column(
    children: [
      Text(user.displayName),
      Text(user.email ?? 'No email'),
      
      // إذا كان تاجر، عرض رابط المتجر
      if (user.vendorId != null)
        ElevatedButton(
          onPressed: () {
            Get.to(() => VendorStorePage(vendorId: user.vendorId!));
          },
          child: Text('View Store'),
        ),
    ],
  );
}
```

---

### مثال 3: التحقق في AuthController

```dart
class AuthController extends GetxController {
  final currentUser = Rx<UserModel?>(null);
  
  Future<void> loadUserData() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) return;
    
    final user = await userRepository.getUserByUserId(authUser.id);
    currentUser.value = user;
    
    // التحقق من vendor_id
    if (user?.vendorId != null) {
      print('✅ User is a vendor: ${user!.vendorId}');
      // تحميل بيانات المتجر
      await vendorController.fetchVendorData(user.vendorId!);
    }
  }
}
```

---

## 🔍 استعلامات SQL المفيدة (Useful SQL Queries)

### 1. عرض جميع التجار مع بياناتهم:

```sql
SELECT 
  up.id as user_profile_id,
  up.user_id,
  up.name,
  up.email,
  up.account_type,
  v.id as vendor_id,
  v.organization_name
FROM user_profiles up
LEFT JOIN vendors v ON up.user_id = v.user_id
WHERE up.account_type = 1;
```

---

### 2. البحث عن مستخدم وvendor_id:

```sql
SELECT 
  up.*,
  v.id as vendor_id
FROM user_profiles up
LEFT JOIN vendors v ON up.user_id = v.user_id
WHERE up.id = 'user-uuid';
```

---

### 3. عدد التجار النشطين:

```sql
SELECT COUNT(*) 
FROM user_profiles up
INNER JOIN vendors v ON up.user_id = v.user_id
WHERE up.account_type = 1 
  AND v.organization_activated = true
  AND v.organization_deleted = false;
```

---

## 🐛 استكشاف الأخطاء (Troubleshooting)

### خطأ 1: `vendorId` دائماً `null`

**السبب**: المستخدم ليس تاجر أو لا يوجد صف في جدول `vendors`

**الحل**:
```sql
-- تحقق من وجود صف في vendors
SELECT * FROM vendors WHERE user_id = 'user-uuid';

-- إذا لم يكن موجود، أضف صف
INSERT INTO vendors (user_id, organization_name, slugn)
VALUES ('user-uuid', 'Store Name', 'store-slug');

-- تحديث account_type
UPDATE user_profiles 
SET account_type = 1 
WHERE user_id = 'user-uuid';
```

---

### خطأ 2: خطأ في استعلام Join

```
Error: relation "vendors" does not exist
```

**السبب**: جدول `vendors` غير موجود

**الحل**: تطبيق سكريبت `create_vendors_table.sql`

---

### خطأ 3: RLS Policy يمنع القراءة

```
Error: new row violates row-level security policy
```

**السبب**: سياسات RLS تمنع القراءة

**الحل**:
```sql
-- التحقق من السياسات
SELECT * FROM pg_policies WHERE tablename = 'vendors';

-- إذا لزم الأمر، إضافة سياسة قراءة
CREATE POLICY "Allow authenticated users to read vendors" ON vendors
  FOR SELECT USING (auth.role() = 'authenticated');
```

---

## 📊 أداء الاستعلامات (Query Performance)

### Before (بدون Join):
```dart
// استعلامين منفصلين
final user = await getUserById('user-id');
final vendor = await vendorRepository.getVendorByUserId(user.userId);
```

### After (مع Join):
```dart
// استعلام واحد فقط
final user = await getUserById('user-id');  // يتضمن vendor_id
```

**النتيجة**: 
- ✅ تقليل عدد الاستعلامات
- ✅ تحسين الأداء
- ✅ كود أبسط وأنظف

---

## 🎯 ملخص التغييرات (Summary)

### في `UserModel`:
```dart
✅ أُضيف: final String? vendorId;
✅ يُملأ تلقائياً من جدول vendors
```

### في `UserRepository`:
```dart
✅ getUserById() - يجلب vendor_id مع join
✅ getUserByUserId() - يجلب vendor_id مع join
✅ معالجة fallback للمستخدمين العاديين
```

---

## 🚀 الاستخدام في التطبيق

### 1. في Profile Page:
```dart
Obx(() {
  final user = authController.currentUser.value;
  
  if (user?.vendorId != null) {
    return ElevatedButton(
      onPressed: () => Get.to(() => MyStorePage(vendorId: user!.vendorId!)),
      child: Text('My Store'),
    );
  }
  
  return SizedBox.shrink();
})
```

### 2. في VendorController:
```dart
Future<void> initVendorData() async {
  final user = authController.currentUser.value;
  
  if (user?.vendorId != null) {
    await fetchVendorData(user!.vendorId!);
  }
}
```

### 3. في ProductController:
```dart
Future<void> createProduct() async {
  final user = authController.currentUser.value;
  
  if (user?.vendorId == null) {
    Get.snackbar('Error', 'You must be a vendor to create products');
    return;
  }
  
  await productRepository.createProduct(
    vendorId: user!.vendorId!,
    // ... product data
  );
}
```

---

## ✅ الخلاصة

الآن عند جلب أي `UserModel`:
- ✅ إذا كان تاجر → `vendorId` يُملأ تلقائياً
- ✅ إذا كان عادي → `vendorId` = `null`
- ✅ لا حاجة لاستعلامات إضافية
- ✅ كود أبسط وأسرع

**جاهز للاستخدام!** 🎉

---

**تاريخ التحديث**: 2025  
**الحالة**: مكتمل  
**النسخة**: 1.0

