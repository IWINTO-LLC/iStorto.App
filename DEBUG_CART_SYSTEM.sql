-- ═══════════════════════════════════════════════════════════════
-- سكريبت تشخيص مشاكل نظام السلة
-- استخدم هذا السكريبت لمعرفة المشكلة بالضبط
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- 1. فحص المستخدم الحالي
-- ═══════════════════════════════════════════════════════════════

SELECT 
    auth.uid() as current_user_id,
    auth.email() as current_user_email,
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ غير مسجل دخول'
        ELSE '✅ مسجل دخول'
    END as login_status;

-- ═══════════════════════════════════════════════════════════════
-- 2. فحص وجود جدول cart_items
-- ═══════════════════════════════════════════════════════════════

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'cart_items'
        ) THEN '✅ الجدول موجود'
        ELSE '❌ الجدول غير موجود - نفذ COMPLETE_CART_SYSTEM_FIX.sql'
    END as table_status;

-- ═══════════════════════════════════════════════════════════════
-- 3. فحص تفعيل RLS
-- ═══════════════════════════════════════════════════════════════

SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN '✅ RLS مفعل'
        ELSE '❌ RLS غير مفعل - المشكلة هنا!'
    END as rls_status
FROM pg_tables
WHERE tablename = 'cart_items';

-- ═══════════════════════════════════════════════════════════════
-- 4. فحص السياسات (Policies)
-- ═══════════════════════════════════════════════════════════════

SELECT 
    cmd as operation,
    policyname as policy_name,
    CASE 
        WHEN qual IS NOT NULL OR with_check IS NOT NULL THEN '✅ موجودة'
        ELSE '❌ مفقودة'
    END as status
FROM pg_policies
WHERE tablename = 'cart_items'
ORDER BY cmd;

-- التحقق من عدد السياسات
SELECT 
    COUNT(*) as total_policies,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ جميع السياسات موجودة'
        ELSE '❌ بعض السياسات مفقودة - المشكلة هنا!'
    END as policies_status
FROM pg_policies
WHERE tablename = 'cart_items';

-- ═══════════════════════════════════════════════════════════════
-- 5. فحص الصلاحيات (Permissions)
-- ═══════════════════════════════════════════════════════════════

SELECT 
    privilege_type,
    '✅' as status
FROM information_schema.table_privileges
WHERE table_name = 'cart_items'
    AND grantee = 'authenticated'
ORDER BY privilege_type;

-- التحقق من وجود جميع الصلاحيات
SELECT 
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ جميع الصلاحيات موجودة (SELECT, INSERT, UPDATE, DELETE)'
        ELSE '❌ بعض الصلاحيات مفقودة - المشكلة هنا! الموجودة: ' || array_to_string(array_agg(privilege_type), ', ')
    END as permissions_status
FROM information_schema.table_privileges
WHERE table_name = 'cart_items'
    AND grantee = 'authenticated';

-- ═══════════════════════════════════════════════════════════════
-- 6. فحص عناصر السلة الحالية
-- ═══════════════════════════════════════════════════════════════

SELECT 
    COUNT(*) as items_count,
    SUM(quantity) as total_quantity,
    SUM(total_price) as total_value,
    COUNT(DISTINCT vendor_id) as unique_vendors
FROM cart_items
WHERE user_id = auth.uid();

-- عرض تفاصيل العناصر
SELECT 
    id,
    product_id,
    vendor_id,
    title,
    price,
    quantity,
    total_price,
    created_at,
    updated_at
FROM cart_items
WHERE user_id = auth.uid()
ORDER BY created_at DESC;

-- ═══════════════════════════════════════════════════════════════
-- 7. اختبار العمليات CRUD
-- ═══════════════════════════════════════════════════════════════

-- اختبار SELECT
DO $$
DECLARE
    can_select BOOLEAN;
BEGIN
    BEGIN
        PERFORM * FROM cart_items WHERE user_id = auth.uid() LIMIT 1;
        can_select := TRUE;
    EXCEPTION WHEN OTHERS THEN
        can_select := FALSE;
    END;
    
    RAISE NOTICE 'اختبار SELECT: %', 
        CASE WHEN can_select THEN '✅ يعمل' ELSE '❌ لا يعمل' END;
END $$;

-- ═══════════════════════════════════════════════════════════════
-- 8. فحص المشاكل الشائعة
-- ═══════════════════════════════════════════════════════════════

-- المشكلة 1: RLS غير مفعل
SELECT 
    'المشكلة 1: RLS' as issue,
    CASE 
        WHEN rowsecurity THEN '✅ لا توجد مشكلة'
        ELSE '❌ RLS غير مفعل - نفذ: ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;'
    END as solution
FROM pg_tables
WHERE tablename = 'cart_items';

-- المشكلة 2: سياسات مفقودة
SELECT 
    'المشكلة 2: السياسات' as issue,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ لا توجد مشكلة'
        ELSE '❌ سياسات مفقودة - نفذ COMPLETE_CART_SYSTEM_FIX.sql'
    END as solution
FROM pg_policies
WHERE tablename = 'cart_items';

-- المشكلة 3: صلاحيات مفقودة
SELECT 
    'المشكلة 3: الصلاحيات' as issue,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ لا توجد مشكلة'
        ELSE '❌ صلاحيات مفقودة - نفذ: GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO authenticated;'
    END as solution
FROM information_schema.table_privileges
WHERE table_name = 'cart_items' AND grantee = 'authenticated';

-- المشكلة 4: المستخدم غير مسجل دخول
SELECT 
    'المشكلة 4: تسجيل الدخول' as issue,
    CASE 
        WHEN auth.uid() IS NOT NULL THEN '✅ لا توجد مشكلة'
        ELSE '❌ المستخدم غير مسجل دخول - سجل دخول أولاً'
    END as solution;

-- ═══════════════════════════════════════════════════════════════
-- 9. اختبار سريع للإضافة
-- ═══════════════════════════════════════════════════════════════

-- حاول إضافة عنصر بسيط
-- إذا نجح: النظام يعمل
-- إذا فشل: راجع رسالة الخطأ

DO $$
BEGIN
    -- محاولة الإضافة
    INSERT INTO cart_items (
        user_id, 
        product_id, 
        vendor_id, 
        title, 
        price, 
        quantity, 
        total_price
    )
    VALUES (
        auth.uid(),
        'test_' || EXTRACT(EPOCH FROM NOW())::TEXT,
        'test_vendor',
        'Test Product',
        9.99,
        1,
        9.99
    );
    
    RAISE NOTICE '✅ اختبار الإضافة: نجح - النظام يعمل!';
    
    -- حذف العنصر الاختباري
    DELETE FROM cart_items 
    WHERE user_id = auth.uid() 
        AND title = 'Test Product';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ اختبار الإضافة: فشل - المشكلة: %', SQLERRM;
END $$;

-- ═══════════════════════════════════════════════════════════════
-- 10. تقرير شامل
-- ═══════════════════════════════════════════════════════════════

SELECT 
    '═══════════ تقرير نظام السلة ═══════════' as report_title
UNION ALL
SELECT '1. الجدول: ' || 
    CASE WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'cart_items') 
    THEN '✅ موجود' ELSE '❌ غير موجود' END
UNION ALL
SELECT '2. RLS: ' || 
    CASE WHEN (SELECT rowsecurity FROM pg_tables WHERE tablename = 'cart_items') 
    THEN '✅ مفعل' ELSE '❌ غير مفعل' END
UNION ALL
SELECT '3. السياسات: ' || 
    (SELECT COUNT(*)::TEXT FROM pg_policies WHERE tablename = 'cart_items') || 
    ' من 4 ' ||
    CASE WHEN (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'cart_items') >= 4
    THEN '✅' ELSE '❌' END
UNION ALL
SELECT '4. الصلاحيات: ' || 
    (SELECT COUNT(DISTINCT privilege_type)::TEXT FROM information_schema.table_privileges 
     WHERE table_name = 'cart_items' AND grantee = 'authenticated') ||
    ' من 4 ' ||
    CASE WHEN (SELECT COUNT(DISTINCT privilege_type) FROM information_schema.table_privileges 
               WHERE table_name = 'cart_items' AND grantee = 'authenticated') >= 4
    THEN '✅' ELSE '❌' END
UNION ALL
SELECT '5. المستخدم: ' || 
    CASE WHEN auth.uid() IS NOT NULL 
    THEN '✅ مسجل دخول' ELSE '❌ غير مسجل دخول' END
UNION ALL
SELECT '6. عدد العناصر: ' || 
    COALESCE((SELECT COUNT(*)::TEXT FROM cart_items WHERE user_id = auth.uid()), '0')
UNION ALL
SELECT '═══════════════════════════════════════';

-- ═══════════════════════════════════════════════════════════════
-- نهاية السكريبت
-- ═══════════════════════════════════════════════════════════════

