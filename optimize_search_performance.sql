-- =====================================================
-- تحسين أداء البحث
-- Search Performance Optimization
-- =====================================================

-- 1. حذف الـ view الحالي
-- Drop current view
DROP VIEW IF EXISTS comprehensive_search_view;

-- 2. إنشاء فهارس محسنة قبل إنشاء الـ view
-- Create optimized indexes before creating the view

-- فهارس أساسية للمنتجات
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_search_optimized 
ON products (is_deleted, is_feature, price) 
WHERE is_deleted = false;

-- فهرس على vendor_id للمنتجات
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_vendor_id 
ON products (vendor_id) 
WHERE is_deleted = false;

-- فهرس على vendor_category_id للمنتجات
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_vendor_category_id 
ON products (vendor_category_id) 
WHERE is_deleted = false;

-- فهرس على عنوان المنتج للبحث النصي
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_title_gin 
ON products USING gin(to_tsvector('arabic', title)) 
WHERE is_deleted = false;

-- فهرس على وصف المنتج للبحث النصي
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_description_gin 
ON products USING gin(to_tsvector('arabic', description)) 
WHERE is_deleted = false;

-- فهارس التجار
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_vendors_active_verified 
ON vendors (organization_activated, organization_deleted, is_verified);

-- فهرس على اسم التاجر للبحث النصي
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_vendors_name_gin 
ON vendors USING gin(to_tsvector('arabic', organization_name));

-- فهارس فئات التجار
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_vendor_categories_active_sort 
ON vendor_categories (is_active, sort_order);

-- 3. إنشاء view محسن مع تقليل العمليات المعقدة
-- Create optimized view with reduced complex operations
CREATE VIEW comprehensive_search_view AS
SELECT 
    -- البيانات الأساسية فقط
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
    
    -- بيانات التاجر الأساسية فقط
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
    
    -- بيانات فئة التاجر الأساسية فقط
    vc.id as vendor_category_vc_id,
    vc.title as vendor_category_title,
    vc.color as vendor_category_color,
    vc.icon as vendor_category_icon,
    vc.sort_order as vendor_category_sort_order,
    vc.is_active as vendor_category_active,
    vc.created_at as vendor_category_created_at,
    vc.updated_at as vendor_category_updated_at,
    
    -- نص البحث المبسط (بدون CONCAT_WS المعقد)
    COALESCE(p.title, '') as search_text,
    
    -- نوع العنصر
    'منتج' as item_type,
    
    -- التقييم المبسط
    COALESCE(vc.sort_order, 5) as rating,
    
    -- حالة التاجر المبسطة
    CASE 
        WHEN v.organization_activated = true AND v.organization_deleted = false THEN 'active'
        WHEN v.organization_deleted = true THEN 'deleted'
        WHEN v.id IS NULL THEN 'no_vendor'
        ELSE 'inactive'
    END as vendor_status,
    
    -- نقاط البحث المبسطة
    CASE 
        WHEN p.is_feature = true AND v.is_verified = true THEN 100
        WHEN p.is_feature = true THEN 80
        WHEN v.is_verified = true THEN 60
        ELSE 40
    END as search_score

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id
WHERE p.is_deleted = false;

-- 4. إنشاء فهرس على الـ view للبحث السريع
-- Create index on view for fast search
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comprehensive_search_text 
ON comprehensive_search_view USING gin(to_tsvector('arabic', search_text));

-- 5. إنشاء فهرس على التقييم للفلترة السريعة
-- Create index on rating for fast filtering
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comprehensive_search_rating 
ON comprehensive_search_view (rating) 
WHERE rating > 0;

-- 6. إنشاء فهرس على السعر للفلترة السريعة
-- Create index on price for fast filtering
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comprehensive_search_price 
ON comprehensive_search_view (price) 
WHERE price > 0;

-- 7. إنشاء فهرس على حالة التاجر
-- Create index on vendor status
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comprehensive_search_vendor_status 
ON comprehensive_search_view (vendor_status);

-- 8. إنشاء فهرس مركب للبحث المتقدم
-- Create composite index for advanced search
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comprehensive_search_composite 
ON comprehensive_search_view (is_feature, is_verified, rating, price);

-- 9. تحديث إحصائيات الجداول
-- Update table statistics
ANALYZE products;
ANALYZE vendors;
ANALYZE vendor_categories;

-- 10. إعطاء الصلاحيات
-- Grant permissions
GRANT SELECT ON comprehensive_search_view TO authenticated;

-- 11. إنشاء دالة للبحث المحسن
-- Create function for optimized search
CREATE OR REPLACE FUNCTION search_products_optimized(
    search_query TEXT DEFAULT '',
    min_price DECIMAL DEFAULT NULL,
    max_price DECIMAL DEFAULT NULL,
    min_rating INTEGER DEFAULT NULL,
    is_featured BOOLEAN DEFAULT NULL,
    is_verified BOOLEAN DEFAULT NULL,
    limit_count INTEGER DEFAULT 20,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    product_id UUID,
    product_title TEXT,
    vendor_name TEXT,
    price DECIMAL,
    rating INTEGER,
    search_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        csv.product_id,
        csv.product_title,
        csv.vendor_name,
        csv.price,
        csv.rating,
        csv.search_score
    FROM comprehensive_search_view csv
    WHERE 
        (search_query = '' OR csv.search_text ILIKE '%' || search_query || '%')
        AND (min_price IS NULL OR csv.price >= min_price)
        AND (max_price IS NULL OR csv.price <= max_price)
        AND (min_rating IS NULL OR csv.rating >= min_rating)
        AND (is_featured IS NULL OR csv.is_feature = is_featured)
        AND (is_verified IS NULL OR csv.is_verified = is_verified)
    ORDER BY csv.search_score DESC, csv.rating DESC, csv.price ASC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- 12. اختبار الأداء
-- Performance test
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM search_products_optimized('منتج', NULL, NULL, 4, NULL, NULL, 20, 0);

-- 13. إحصائيات الأداء
-- Performance statistics
SELECT 
    'Optimized Search Performance' as test_name,
    COUNT(*) as total_records,
    AVG(rating) as avg_rating,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM comprehensive_search_view;

-- =====================================================
-- انتهاء التحسين
-- End of optimization
-- =====================================================