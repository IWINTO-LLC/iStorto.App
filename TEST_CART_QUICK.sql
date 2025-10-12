-- ═══════════════════════════════════════════════════════════════
-- اختبار سريع لنظام السلة
-- نفذ هذا السكريبت للتحقق من عمل النظام
-- ═══════════════════════════════════════════════════════════════

-- 🔍 الخطوة 1: التحقق من المستخدم الحالي
SELECT 
    '👤 المستخدم الحالي' as info,
    auth.uid() as user_id,
    auth.email() as email,
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ غير مسجل دخول - سجل دخول أولاً!'
        ELSE '✅ مسجل دخول'
    END as status;

-- ═══════════════════════════════════════════════════════════════

-- 🗄️ الخطوة 2: التحقق من وجود الجدول
SELECT 
    '📋 جدول cart_items' as info,
    CASE 
        WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'cart_items')
        THEN '✅ موجود'
        ELSE '❌ غير موجود - نفذ COMPLETE_CART_SYSTEM_FIX.sql'
    END as status;

-- ═══════════════════════════════════════════════════════════════

-- 🔒 الخطوة 3: التحقق من RLS
SELECT 
    '🔒 Row Level Security' as info,
    CASE 
        WHEN (SELECT rowsecurity FROM pg_tables WHERE tablename = 'cart_items')
        THEN '✅ مفعل'
        ELSE '❌ غير مفعل - نفذ: ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;'
    END as status;

-- ═══════════════════════════════════════════════════════════════

-- 📜 الخطوة 4: التحقق من السياسات
SELECT 
    '📜 سياسات RLS' as info,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'cart_items')::TEXT || ' من 4' as count,
    CASE 
        WHEN (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'cart_items') >= 4
        THEN '✅ كاملة'
        ELSE '❌ ناقصة - نفذ COMPLETE_CART_SYSTEM_FIX.sql'
    END as status;

-- ═══════════════════════════════════════════════════════════════

-- 🔑 الخطوة 5: التحقق من الصلاحيات
SELECT 
    '🔑 الصلاحيات' as info,
    (SELECT COUNT(DISTINCT privilege_type) 
     FROM information_schema.table_privileges 
     WHERE table_name = 'cart_items' AND grantee = 'authenticated')::TEXT || ' من 4' as count,
    CASE 
        WHEN (SELECT COUNT(DISTINCT privilege_type) 
              FROM information_schema.table_privileges 
              WHERE table_name = 'cart_items' AND grantee = 'authenticated') >= 4
        THEN '✅ كاملة'
        ELSE '❌ ناقصة - نفذ: GRANT SELECT, INSERT, UPDATE, DELETE ON cart_items TO authenticated;'
    END as status;

-- ═══════════════════════════════════════════════════════════════

-- 🧪 الخطوة 6: اختبار الإضافة
DO $$
BEGIN
    -- محاولة إضافة عنصر اختباري
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
        'quick_test_' || EXTRACT(EPOCH FROM NOW())::TEXT,
        'test_vendor',
        '🧪 Test Item - Safe to Delete',
        1.00,
        1,
        1.00
    );
    
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE '✅ اختبار الإضافة: نجح!';
    RAISE NOTICE '✅ النظام يعمل بشكل صحيح!';
    RAISE NOTICE '═══════════════════════════════════════════════';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '═══════════════════════════════════════════════';
    RAISE NOTICE '❌ اختبار الإضافة: فشل!';
    RAISE NOTICE '❌ المشكلة: %', SQLERRM;
    RAISE NOTICE '💡 الحل: نفذ COMPLETE_CART_SYSTEM_FIX.sql';
    RAISE NOTICE '═══════════════════════════════════════════════';
END $$;

-- ═══════════════════════════════════════════════════════════════

-- 🧹 الخطوة 7: تنظيف (حذف العناصر الاختبارية)
DELETE FROM cart_items 
WHERE user_id = auth.uid() 
    AND title LIKE '%Test Item%';

-- ═══════════════════════════════════════════════════════════════

-- 📊 الخطوة 8: عرض السلة الحالية
SELECT 
    '🛒 عناصر السلة الحالية' as info,
    COUNT(*) as items_count,
    COALESCE(SUM(quantity), 0) as total_quantity,
    COALESCE(SUM(total_price), 0.00) as total_value
FROM cart_items
WHERE user_id = auth.uid();

-- عرض التفاصيل
SELECT 
    product_id,
    title,
    price,
    quantity,
    total_price,
    created_at
FROM cart_items
WHERE user_id = auth.uid()
ORDER BY created_at DESC;

-- ═══════════════════════════════════════════════════════════════

-- 📝 ملخص النتائج
SELECT '═══════════════════════════════════════════════' as separator
UNION ALL
SELECT '          ملخص فحص نظام السلة'
UNION ALL
SELECT '═══════════════════════════════════════════════'
UNION ALL
SELECT CASE 
    WHEN auth.uid() IS NULL THEN '❌ 1. المستخدم: غير مسجل دخول'
    ELSE '✅ 1. المستخدم: ' || auth.email()
END
UNION ALL
SELECT CASE 
    WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'cart_items')
    THEN '✅ 2. الجدول: موجود'
    ELSE '❌ 2. الجدول: غير موجود'
END
UNION ALL
SELECT CASE 
    WHEN (SELECT rowsecurity FROM pg_tables WHERE tablename = 'cart_items')
    THEN '✅ 3. RLS: مفعل'
    ELSE '❌ 3. RLS: غير مفعل'
END
UNION ALL
SELECT '✅ 4. السياسات: ' || 
    (SELECT COUNT(*)::TEXT FROM pg_policies WHERE tablename = 'cart_items') || ' من 4'
UNION ALL
SELECT '✅ 5. الصلاحيات: ' || 
    (SELECT COUNT(DISTINCT privilege_type)::TEXT 
     FROM information_schema.table_privileges 
     WHERE table_name = 'cart_items' AND grantee = 'authenticated') || ' من 4'
UNION ALL
SELECT '✅ 6. عناصر السلة: ' || 
    COALESCE((SELECT COUNT(*)::TEXT FROM cart_items WHERE user_id = auth.uid()), '0')
UNION ALL
SELECT '═══════════════════════════════════════════════';

-- ═══════════════════════════════════════════════════════════════
-- نهاية الاختبار السريع
-- 
-- إذا رأيت جميع ✅ → النظام يعمل!
-- إذا رأيت أي ❌ → نفذ COMPLETE_CART_SYSTEM_FIX.sql
-- ═══════════════════════════════════════════════════════════════

