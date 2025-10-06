-- =====================================================
-- إصلاح سريع لأداء البحث
-- Quick Search Performance Fix
-- =====================================================

-- 1. حذف الـ view الحالي
DROP VIEW IF EXISTS comprehensive_search_view;

-- 2. إنشاء view مبسط وسريع
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
    
    -- بيانات التاجر الأساسية
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
    
    -- نص البحث المبسط
    p.title as search_text,
    
    -- نوع العنصر
    'منتج' as item_type,
    
    -- التقييم المبسط
    COALESCE(vc.sort_order, 5) as rating,
    
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

-- 3. إنشاء فهارس أساسية
CREATE INDEX IF NOT EXISTS idx_products_deleted_feature 
ON products (is_deleted, is_feature) 
WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_products_title_search 
ON products (title) 
WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_vendors_verified 
ON vendors (is_verified);

CREATE INDEX IF NOT EXISTS idx_vendor_categories_sort 
ON vendor_categories (sort_order);

-- 4. إعطاء الصلاحيات
GRANT SELECT ON comprehensive_search_view TO authenticated;

-- 5. اختبار الأداء
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM comprehensive_search_view 
WHERE search_text ILIKE '%test%' 
LIMIT 20;

-- 6. فحص عدد السجلات
SELECT COUNT(*) as total_records FROM comprehensive_search_view;
