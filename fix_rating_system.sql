-- =====================================================
-- إصلاح نظام التقييم في comprehensive_search_view
-- Fix rating system in comprehensive_search_view
-- =====================================================

-- 1. فحص الجداول الموجودة للتقييمات
-- Check existing tables for ratings

-- فحص إذا كان هناك جدول تقييمات
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%rating%' 
OR table_name LIKE '%review%';

-- فحص إذا كان هناك عمود تقييم في جدول المنتجات
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'products' 
AND column_name LIKE '%rating%' 
OR column_name LIKE '%review%';

-- =====================================================
-- 2. إنشاء جدول تقييمات المنتجات (إذا لم يكن موجوداً)
-- Create product ratings table (if not exists)
-- =====================================================

CREATE TABLE IF NOT EXISTS product_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(product_id, user_id)
);

-- إنشاء فهرس على product_id لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_product_ratings_product_id 
ON product_ratings (product_id);

-- إنشاء فهرس على rating للفلترة
CREATE INDEX IF NOT EXISTS idx_product_ratings_rating 
ON product_ratings (rating);

-- =====================================================
-- 3. إنشاء دالة لحساب متوسط التقييم
-- Create function to calculate average rating
-- =====================================================

CREATE OR REPLACE FUNCTION get_product_average_rating(product_uuid UUID)
RETURNS DECIMAL AS $$
DECLARE
    avg_rating DECIMAL;
BEGIN
    SELECT COALESCE(AVG(rating), 0) INTO avg_rating
    FROM product_ratings
    WHERE product_id = product_uuid;
    
    RETURN ROUND(avg_rating, 1);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. إنشاء دالة لحساب عدد التقييمات
-- Create function to count ratings
-- =====================================================

CREATE OR REPLACE FUNCTION get_product_rating_count(product_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    rating_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO rating_count
    FROM product_ratings
    WHERE product_id = product_uuid;
    
    RETURN rating_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. تحديث comprehensive_search_view مع التقييمات الحقيقية
-- Update comprehensive_search_view with real ratings
-- =====================================================

-- حذف الـ view الحالي
DROP VIEW IF EXISTS comprehensive_search_view;

-- إنشاء الـ view الجديد مع التقييمات الحقيقية
CREATE VIEW comprehensive_search_view AS
SELECT 
    -- معرفات أساسية
    p.id as product_id,
    p.title as product_title,
    p.description as product_description,
    p.price,
    p.old_price,
    p.product_type,
    p.thumbnail as product_thumbnail,
    p.images as product_images,
    p.category_id,
    p.vendor_category_id,
    p.is_feature,
    p.is_deleted,
    p.min_quantity,
    p.sale_percentage,
    p.currency,
    p.created_at as product_created_at,
    p.updated_at as product_updated_at,
    
    -- بيانات التاجر
    v.id as vendor_id,
    v.user_id as vendor_user_id,
    v.organization_name as vendor_name,
    v.organization_bio as vendor_bio,
    v.banner_image as vendor_banner,
    v.organization_logo as vendor_logo,
    v.organization_cover as vendor_cover,
    v.brief as vendor_brief,
    v.exclusive_id,
    v.store_message,
    v.in_exclusive,
    v.is_subscriber,
    v.is_verified,
    v.is_royal,
    v.enable_iwinto_payment,
    v.enable_cod,
    v.organization_deleted,
    v.organization_activated,
    v.default_currency,
    v.created_at as vendor_created_at,
    v.updated_at as vendor_updated_at,
    v.selected_major_categories,
    
    -- بيانات فئة التاجر
    vc.id as vendor_category_vc_id,
    vc.title as vendor_category_title,
    vc.color as vendor_category_color,
    vc.icon as vendor_category_icon,
    vc.sort_order as vendor_category_sort_order,
    vc.is_active as vendor_category_active,
    vc.created_at as vendor_category_created_at,
    vc.updated_at as vendor_category_updated_at,
    
    -- بيانات إضافية للبحث
    COALESCE(p.product_type, '') as product_type_text,
    
    -- نص شامل للبحث
    to_tsvector('arabic', CONCAT_WS(' ',
        COALESCE(p.title, ''),
        COALESCE(p.description, ''),
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
        COALESCE(vc.title, '')
    )) as search_vector,
    
    -- نص عادي للبحث
    CONCAT_WS(' ',
        COALESCE(p.title, ''),
        COALESCE(p.description, ''),
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
        COALESCE(vc.title, '')
    ) as search_text,
    
    -- تصنيف النتائج حسب ترتيب الفئة
    CASE 
        WHEN vc.sort_order IS NOT NULL AND vc.sort_order <= 2 THEN 'high_priority'
        WHEN vc.sort_order IS NOT NULL AND vc.sort_order <= 5 THEN 'medium_priority'
        ELSE 'low_priority'
    END as category_priority_level,
    
    -- حالة التوفر
    CASE 
        WHEN p.min_quantity > 0 THEN 'available'
        ELSE 'unavailable'
    END as availability_status,
    
    -- حالة المميز
    CASE 
        WHEN p.is_feature = true THEN 'featured'
        ELSE 'normal'
    END as feature_status,
    
    -- حالة الحذف
    CASE 
        WHEN p.is_deleted = true THEN 'deleted'
        ELSE 'active'
    END as deletion_status,
    
    -- حالة التاجر
    CASE 
        WHEN v.organization_activated = true AND v.organization_deleted = false THEN 'active'
        WHEN v.organization_deleted = true THEN 'deleted'
        WHEN v.id IS NULL THEN 'no_vendor'
        ELSE 'inactive'
    END as vendor_status,
    
    -- نقاط البحث
    CASE 
        WHEN p.is_feature = true AND v.is_verified = true AND vc.sort_order = 1 THEN 100
        WHEN p.is_feature = true AND v.is_verified = true AND vc.sort_order <= 2 THEN 95
        WHEN p.is_feature = true AND v.is_verified = true THEN 90
        WHEN p.is_feature = true AND vc.sort_order = 1 THEN 85
        WHEN p.is_feature = true AND vc.sort_order <= 2 THEN 80
        WHEN p.is_feature = true THEN 75
        WHEN v.is_verified = true AND vc.sort_order = 1 THEN 70
        WHEN v.is_verified = true AND vc.sort_order <= 2 THEN 65
        WHEN v.is_verified = true THEN 60
        WHEN vc.sort_order = 1 THEN 55
        WHEN vc.sort_order <= 2 THEN 50
        WHEN vc.sort_order <= 5 THEN 45
        WHEN vc.sort_order <= 10 THEN 40
        ELSE 35
    END as search_score,
    
    -- حساب الخصم
    CASE 
        WHEN p.old_price > 0 AND p.price > 0 THEN 
            ROUND(((p.old_price - p.price) / p.old_price) * 100, 2)
        ELSE 0
    END as discount_percentage,
    
    -- نوع العنصر للفلترة
    'منتج' as item_type,
    
    -- التقييم الحقيقي من جدول التقييمات
    CASE 
        WHEN get_product_average_rating(p.id) > 0 THEN 
            CEIL(get_product_average_rating(p.id))::INTEGER
        ELSE 0
    END as rating,
    
    -- متوسط التقييم الدقيق
    get_product_average_rating(p.id) as average_rating,
    
    -- عدد التقييمات
    get_product_rating_count(p.id) as rating_count

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

-- شرط واحد فقط: المنتجات غير المحذوفة
WHERE p.is_deleted = false;

-- =====================================================
-- 6. إضافة بيانات تجريبية للتقييمات (اختياري)
-- Add sample rating data (optional)
-- =====================================================

-- إدراج تقييمات تجريبية لبعض المنتجات
-- INSERT INTO product_ratings (product_id, user_id, rating, review_text)
-- SELECT 
--     p.id,
--     gen_random_uuid(),
--     (random() * 4 + 1)::INTEGER, -- تقييم عشوائي من 1 إلى 5
--     CASE 
--         WHEN random() > 0.5 THEN 'منتج ممتاز'
--         ELSE NULL
--     END
-- FROM products p
-- WHERE p.is_deleted = false
-- LIMIT 50;

-- =====================================================
-- 7. إعطاء الصلاحيات
-- Grant permissions
-- =====================================================

-- صلاحيات للقراءة
GRANT SELECT ON comprehensive_search_view TO authenticated;
GRANT SELECT ON product_ratings TO authenticated;
GRANT EXECUTE ON FUNCTION get_product_average_rating TO authenticated;
GRANT EXECUTE ON FUNCTION get_product_rating_count TO authenticated;

-- =====================================================
-- 8. اختبار النظام الجديد
-- Test new system
-- =====================================================

-- فحص عدد السجلات
SELECT 
    'comprehensive_search_view' as view_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN rating > 0 THEN 1 END) as products_with_ratings,
    COUNT(CASE WHEN rating = 0 THEN 1 END) as products_without_ratings,
    AVG(average_rating) as avg_rating_all_products,
    AVG(CASE WHEN rating > 0 THEN average_rating END) as avg_rating_rated_products
FROM comprehensive_search_view;

-- عرض عينة من البيانات مع التقييمات
SELECT 
    product_title,
    vendor_name,
    price,
    rating,
    average_rating,
    rating_count
FROM comprehensive_search_view 
WHERE rating > 0
LIMIT 10;

-- اختبار الفلترة حسب التقييم
SELECT 
    product_title,
    vendor_name,
    price,
    rating,
    average_rating
FROM comprehensive_search_view 
WHERE rating >= 4
LIMIT 5;

-- =====================================================
-- انتهاء السكريبت
-- End of script
-- =====================================================
