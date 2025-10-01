# إصلاح مشكلة إضافة البنرات - Banner RLS Fix Guide

## 🔴 المشكلة (The Problem)

عند محاولة إضافة بنر جديد من صفحة Admin Banners، لا يتم إضافة البنر ولا يعمل النظام بشكل صحيح.

**السبب**: سياسة RLS في جدول `banners` في Supabase غير صحيحة. السياسة القديمة:

```sql
CREATE POLICY "Admins can manage company banners" ON banners
    FOR ALL USING (
        scope = 'company' AND
        auth.role() = 'authenticated'
    );
```

هذه السياسة تستخدم `FOR ALL` مع `USING` فقط، وهذا خطأ لأن:
- `USING` يُستخدم فقط للقراءة (SELECT)
- `FOR ALL` يحتاج إلى `WITH CHECK` للعمليات الأخرى (INSERT, UPDATE, DELETE)

---

## ✅ الحل (The Solution)

### الخطوة 1️⃣: تطبيق سياسات RLS الجديدة

افتح **Supabase Dashboard** واذهب إلى:
```
SQL Editor → New Query
```

ثم انسخ والصق المحتوى من ملف `lib/utils/fix_banner_rls_policies.sql`:

```sql
-- Fix Banner RLS Policies for Company Banners
-- This script adds proper INSERT, UPDATE, and DELETE policies for company banners

-- Drop the incorrect "Admins can manage company banners" policy
DROP POLICY IF EXISTS "Admins can manage company banners" ON banners;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Authenticated users can view company banners" ON banners;
DROP POLICY IF EXISTS "Anyone can view active banners" ON banners;

-- Create separate policies for company banners

-- 1. Allow EVERYONE (including guests) to view ALL banners (active or not)
CREATE POLICY "Everyone can view all banners" ON banners
    FOR SELECT USING (true);

-- 2. Allow authenticated users to insert company banners
CREATE POLICY "Authenticated users can insert company banners" ON banners
    FOR INSERT WITH CHECK (
        scope = 'company' AND
        vendor_id IS NULL AND
        auth.role() = 'authenticated'
    );

-- 3. Allow authenticated users to update company banners
CREATE POLICY "Authenticated users can update company banners" ON banners
    FOR UPDATE USING (
        scope = 'company' AND
        auth.role() = 'authenticated'
    )
    WITH CHECK (
        scope = 'company' AND
        auth.role() = 'authenticated'
    );

-- 4. Allow authenticated users to delete company banners
CREATE POLICY "Authenticated users can delete company banners" ON banners
    FOR DELETE USING (
        scope = 'company' AND
        auth.role() = 'authenticated'
    );
```

ثم اضغط على **Run** أو **F5**.

---

### الخطوة 2️⃣: التحقق من السياسات

بعد تطبيق السكريبت، تحقق من السياسات الجديدة:

```
Supabase Dashboard → Authentication → Policies → banners table
```

يجب أن ترى:
- ✅ `Everyone can view all banners` (SELECT)
- ✅ `Authenticated users can insert company banners` (INSERT)
- ✅ `Authenticated users can update company banners` (UPDATE)
- ✅ `Authenticated users can delete company banners` (DELETE)
- ✅ `Vendors can insert their own banners` (INSERT)
- ✅ `Vendors can update their own banners` (UPDATE)
- ✅ `Vendors can delete their own banners` (DELETE)

---

## 📋 السياسات الجديدة (New Policies)

### 1️⃣ عرض البنرات (View Banners)

```sql
CREATE POLICY "Everyone can view all banners" ON banners
    FOR SELECT USING (true);
```

**الوصف**: جميع المستخدمين (بما فيهم الزوار) يمكنهم رؤية جميع البنرات (نشطة أو غير نشطة).

**السبب**: 
- لعرض البنرات في الصفحة الرئيسية للزوار
- لعرض البنرات في صفحة Admin للمسؤولين

---

### 2️⃣ إضافة بنرات الشركة (Insert Company Banners)

```sql
CREATE POLICY "Authenticated users can insert company banners" ON banners
    FOR INSERT WITH CHECK (
        scope = 'company' AND
        vendor_id IS NULL AND
        auth.role() = 'authenticated'
    );
```

**الوصف**: المستخدمون المسجلون فقط يمكنهم إضافة بنرات الشركة.

**الشروط**:
- ✅ `scope` يجب أن يكون `'company'`
- ✅ `vendor_id` يجب أن يكون `NULL`
- ✅ المستخدم يجب أن يكون مسجل دخول

---

### 3️⃣ تحديث بنرات الشركة (Update Company Banners)

```sql
CREATE POLICY "Authenticated users can update company banners" ON banners
    FOR UPDATE USING (
        scope = 'company' AND
        auth.role() = 'authenticated'
    )
    WITH CHECK (
        scope = 'company' AND
        auth.role() = 'authenticated'
    );
```

**الوصف**: المستخدمون المسجلون يمكنهم تحديث بنرات الشركة (مثل: تفعيل/تعطيل، تغيير الأولوية).

**ملاحظة**: 
- `USING`: للتحقق من صلاحية قراءة السجل قبل التحديث
- `WITH CHECK`: للتحقق من صلاحية القيم الجديدة بعد التحديث

---

### 4️⃣ حذف بنرات الشركة (Delete Company Banners)

```sql
CREATE POLICY "Authenticated users can delete company banners" ON banners
    FOR DELETE USING (
        scope = 'company' AND
        auth.role() = 'authenticated'
    );
```

**الوصف**: المستخدمون المسجلون يمكنهم حذف بنرات الشركة.

---

## 🧪 الاختبار (Testing)

### اختبار 1: إضافة بنر من Admin

1. افتح التطبيق وسجل دخول
2. اذهب إلى `Admin Zone → Banner Management`
3. اضغط على زر `+` (Add Banner)
4. اختر `From Gallery` أو `From Camera`
5. اختر صورة وقص
6. انتظر رفع الصورة
7. يجب أن يظهر البنر في تبويب "Company Banners"

---

### اختبار 2: تفعيل/تعطيل بنر

1. في صفحة `Admin Banners`
2. اضغط على زر `Activate` أو `Deactivate`
3. يجب أن يتغير لون الشارة (أخضر/أحمر)

---

### اختبار 3: تحويل بنر تاجر لبنر شركة

1. اذهب إلى تبويب "Vendor Banners"
2. اضغط على زر `To Company`
3. أكد التحويل
4. يجب أن ينتقل البنر لتبويب "Company Banners"

---

### اختبار 4: حذف بنر

1. اضغط على زر `Delete`
2. أكد الحذف
3. يجب أن يختفي البنر من القائمة

---

## 🔐 تقييد الصلاحيات للمسؤولين فقط (Optional: Admin-Only Access)

إذا أردت تقييد إدارة بنرات الشركة للمسؤولين فقط:

### الخطوة 1: إضافة عمود `is_admin`

```sql
-- Add is_admin column to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

-- Set specific users as admin
UPDATE user_profiles 
SET is_admin = true 
WHERE email = 'admin@example.com'; -- Replace with your admin email
```

### الخطوة 2: تحديث السياسات

```sql
-- Drop old policies
DROP POLICY IF EXISTS "Authenticated users can insert company banners" ON banners;
DROP POLICY IF EXISTS "Authenticated users can update company banners" ON banners;
DROP POLICY IF EXISTS "Authenticated users can delete company banners" ON banners;

-- Create admin-only policies
CREATE POLICY "Admin users can insert company banners" ON banners
    FOR INSERT WITH CHECK (
        scope = 'company' AND
        vendor_id IS NULL AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() 
            AND is_admin = true
        )
    );

CREATE POLICY "Admin users can update company banners" ON banners
    FOR UPDATE USING (
        scope = 'company' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() 
            AND is_admin = true
        )
    )
    WITH CHECK (
        scope = 'company' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() 
            AND is_admin = true
        )
    );

CREATE POLICY "Admin users can delete company banners" ON banners
    FOR DELETE USING (
        scope = 'company' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_id = auth.uid() 
            AND is_admin = true
        )
    );
```

---

## 📊 ملخص السياسات (Policies Summary)

| العملية | من يستطيع | الشرط |
|---------|-----------|-------|
| **عرض البنرات** | الجميع (بما فيهم الزوار) | - |
| **إضافة بنر شركة** | مستخدمين مسجلين | `scope='company'` + `vendor_id IS NULL` |
| **تحديث بنر شركة** | مستخدمين مسجلين | `scope='company'` |
| **حذف بنر شركة** | مستخدمين مسجلين | `scope='company'` |
| **إضافة بنر تاجر** | التاجر نفسه | `scope='vendor'` + `vendor_id=auth.uid()` |
| **تحديث بنر تاجر** | التاجر نفسه | `scope='vendor'` + `vendor_id=auth.uid()` |
| **حذف بنر تاجر** | التاجر نفسه | `scope='vendor'` + `vendor_id=auth.uid()` |

---

## 🐛 استكشاف الأخطاء (Troubleshooting)

### مشكلة 1: "new row violates row-level security policy"

**السبب**: السياسات غير مطبقة بشكل صحيح

**الحل**:
1. تأكد من تطبيق السكريبت في Supabase
2. تحقق من أن المستخدم مسجل دخول
3. تحقق من أن `scope='company'` و `vendor_id IS NULL`

---

### مشكلة 2: لا تظهر البنرات للزوار

**السبب**: سياسة `SELECT` غير موجودة أو خاطئة

**الحل**:
```sql
-- Verify SELECT policy exists
SELECT * FROM pg_policies WHERE tablename = 'banners' AND cmd = 'SELECT';

-- Re-create if needed
CREATE POLICY "Everyone can view all banners" ON banners
    FOR SELECT USING (true);
```

---

### مشكلة 3: لا يمكن تحديث أو حذف البنرات

**السبب**: سياسات UPDATE/DELETE غير موجودة

**الحل**: أعد تطبيق السكريبت كاملاً من `fix_banner_rls_policies.sql`

---

## ✅ التحقق النهائي (Final Verification)

قم بتشغيل هذا الأمر في Supabase SQL Editor:

```sql
-- Check all banner policies
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'banners'
ORDER BY cmd, policyname;
```

يجب أن ترى 7 سياسات على الأقل.

---

## 🎉 النتيجة

الآن يمكنك:
- ✅ إضافة بنرات شركة من Admin Zone
- ✅ تفعيل/تعطيل البنرات
- ✅ تحويل بنرات التجار لبنرات شركة
- ✅ حذف البنرات
- ✅ عرض البنرات للزوار في الصفحة الرئيسية
- ✅ إدارة بنرات التجار بشكل منفصل

---

## 📝 ملاحظات مهمة

1. **الأمان**: السياسات الحالية تسمح لأي مستخدم مسجل بإدارة بنرات الشركة. للإنتاج، يُفضل تقييدها للمسؤولين فقط (راجع القسم الاختياري أعلاه).

2. **Storage**: تأكد من أن مجلد `banners` في Supabase Storage له صلاحيات مناسبة:
   - قراءة: الجميع
   - كتابة: مستخدمين مسجلين

3. **Testing**: اختبر جميع العمليات (إضافة، تحديث، حذف) قبل النشر.

---

**تم إنشاء هذا الدليل بواسطة**: AI Assistant  
**التاريخ**: 2025  
**الإصدار**: 1.0

