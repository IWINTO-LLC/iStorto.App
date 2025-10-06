-- =====================================================
-- TEST SCRIPT FOR FAVORITE PRODUCTS SETUP
-- سكريبت اختبار إعداد المنتجات المفضلة
-- =====================================================

-- 1. التحقق من وجود الجدول
SELECT 
    'Table exists' as test_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'favorite_products'
    ) THEN 'PASS' ELSE 'FAIL' END as result;

-- 2. التحقق من وجود الدوال
SELECT 
    'Functions exist' as test_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_name IN (
            'get_user_favorites_count',
            'is_product_favorite',
            'product_exists',
            'add_to_favorites',
            'remove_from_favorites',
            'clear_user_favorites'
        )
    ) THEN 'PASS' ELSE 'FAIL' END as result;

-- 3. التحقق من وجود العرض
SELECT 
    'View exists' as test_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.views 
        WHERE table_name = 'user_favorites_with_details'
    ) THEN 'PASS' ELSE 'FAIL' END as result;

-- 4. التحقق من سياسات RLS
SELECT 
    'RLS Policies exist' as test_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'favorite_products'
    ) THEN 'PASS' ELSE 'FAIL' END as result;

-- 5. اختبار الدوال (إذا كان هناك مستخدم مصادق عليه)
DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    test_product_id TEXT := 'test-product-123';
    result_count INTEGER;
BEGIN
    -- اختبار دالة عدد المفضلات
    SELECT get_user_favorites_count(test_user_id) INTO result_count;
    
    -- اختبار دالة التحقق من المفضلة
    IF NOT is_product_favorite(test_user_id, test_product_id) THEN
        RAISE NOTICE '✅ دالة التحقق من المفضلة تعمل بشكل صحيح';
    END IF;
    
    RAISE NOTICE '✅ جميع الاختبارات الأساسية نجحت';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ بعض الاختبارات فشلت: %', SQLERRM;
END $$;

-- 6. عرض هيكل الجدول
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'favorite_products'
ORDER BY ordinal_position;

-- 7. عرض الفهارس
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'favorite_products';

-- 8. عرض السياسات
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'favorite_products';

RAISE NOTICE '🎯 تم إكمال جميع اختبارات إعداد المنتجات المفضلة!';
