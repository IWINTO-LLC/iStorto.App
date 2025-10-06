-- =====================================================
-- إصلاح بسيط للـ view مع تجنب مشاكل أنواع البيانات
-- Simple view fix avoiding data type issues
-- =====================================================

-- 1. حذف الـ views الموجودة
DROP VIEW IF EXISTS comprehensive_search_view;
DROP VIEW IF EXISTS flexible_search_view;

-- 2. إنشاء view بسيط وآمن
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
    
    -- بيانات التاجر (فقط إذا كانت موجودة)
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
    
    -- بيانات فئة التاجر (فقط إذا كانت موجودة)
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
    
    -- حالة التوفر (بناءً على min_quantity)
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
    
    -- نقاط البحث (لترتيب النتائج)
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
    
    -- تقييم افتراضي
    COALESCE(vc.sort_order, 5) as rating

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

-- شرط واحد فقط: المنتجات غير المحذوفة
WHERE p.is_deleted = false;

-- =====================================================
-- 3. إنشاء فهارس لتحسين الأداء
-- Create indexes for better performance
-- =====================================================

-- فهرس على عنوان المنتج
CREATE INDEX IF NOT EXISTS idx_products_title 
ON products (title);

-- فهرس على وصف المنتج
CREATE INDEX IF NOT EXISTS idx_products_description 
ON products (description);

-- فهرس على نوع المنتج
CREATE INDEX IF NOT EXISTS idx_products_type 
ON products (product_type);

-- فهرس على اسم التاجر
CREATE INDEX IF NOT EXISTS idx_vendors_name 
ON vendors (organization_name);

-- فهرس على وصف التاجر
CREATE INDEX IF NOT EXISTS idx_vendors_bio 
ON vendors (organization_bio);

-- فهرس على عنوان فئة التاجر
CREATE INDEX IF NOT EXISTS idx_vendor_categories_title 
ON vendor_categories (title);

-- فهرس على حالة المنتج
CREATE INDEX IF NOT EXISTS idx_products_deleted 
ON products (is_deleted);

-- فهرس على حالة التاجر
CREATE INDEX IF NOT EXISTS idx_vendors_activated 
ON vendors (organization_activated);

-- فهرس على حالة حذف التاجر
CREATE INDEX IF NOT EXISTS idx_vendors_deleted 
ON vendors (organization_deleted);

-- فهرس على حالة فئة التاجر
CREATE INDEX IF NOT EXISTS idx_vendor_categories_active 
ON vendor_categories (is_active);

-- فهرس على السعر
CREATE INDEX IF NOT EXISTS idx_products_price 
ON products (price);

-- فهرس على حالة المميز
CREATE INDEX IF NOT EXISTS idx_products_feature 
ON products (is_feature);

-- فهرس على حالة التحقق
CREATE INDEX IF NOT EXISTS idx_vendors_verified 
ON vendors (is_verified);

-- فهرس على ترتيب فئة التاجر
CREATE INDEX IF NOT EXISTS idx_vendor_categories_sort_order 
ON vendor_categories (sort_order);

-- =====================================================
-- 4. إعطاء الصلاحيات المناسبة
-- Grant appropriate permissions
-- =====================================================

-- صلاحيات للقراءة
GRANT SELECT ON comprehensive_search_view TO authenticated;

-- =====================================================
-- 5. اختبار الـ view الجديد
-- Test new view
-- =====================================================

-- فحص عدد السجلات
SELECT 
    'comprehensive_search_view' as view_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN vendor_status = 'active' THEN 1 END) as active_vendors,
    COUNT(CASE WHEN vendor_status = 'no_vendor' THEN 1 END) as no_vendor_products,
    COUNT(CASE WHEN feature_status = 'featured' THEN 1 END) as featured_products,
    COUNT(CASE WHEN availability_status = 'available' THEN 1 END) as available_products
FROM comprehensive_search_view;

-- عرض عينة من البيانات
SELECT 
    product_title,
    vendor_name,
    price,
    vendor_status,
    feature_status,
    availability_status
FROM comprehensive_search_view 
LIMIT 10;

-- =====================================================
-- 6. اختبار البحث
-- Test search functionality
-- =====================================================

-- اختبار البحث النصي
SELECT 
    product_title,
    vendor_name,
    price
FROM comprehensive_search_view 
WHERE search_text ILIKE '%test%' 
LIMIT 5;

-- اختبار الفلترة
SELECT 
    product_title,
    vendor_name,
    price
FROM comprehensive_search_view 
WHERE price >= 100 AND price <= 1000
LIMIT 5;

-- =====================================================
-- انتهاء السكريبت
-- End of script
-- =====================================================
