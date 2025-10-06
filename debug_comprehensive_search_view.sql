-- =====================================================
-- فحص وتصحيح comprehensive_search_view
-- Debug and fix comprehensive_search_view
-- =====================================================

-- 1. فحص البيانات الموجودة في الجداول الأساسية
-- Check existing data in base tables

-- فحص جدول المنتجات
SELECT 
    'products' as table_name,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_deleted = false THEN 1 END) as active_count,
    COUNT(CASE WHEN is_deleted = true THEN 1 END) as deleted_count
FROM products;

-- فحص جدول التجار
SELECT 
    'vendors' as table_name,
    COUNT(*) as total_count,
    COUNT(CASE WHEN organization_activated = true THEN 1 END) as activated_count,
    COUNT(CASE WHEN organization_deleted = false THEN 1 END) as not_deleted_count,
    COUNT(CASE WHEN organization_activated = true AND organization_deleted = false THEN 1 END) as active_vendors
FROM vendors;

-- فحص جدول فئات التجار
SELECT 
    'vendor_categories' as table_name,
    COUNT(*) as total_count,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_count
FROM vendor_categories;

-- فحص العلاقات بين الجداول
SELECT 
    'product_vendor_relations' as relation_type,
    COUNT(*) as total_relations,
    COUNT(CASE WHEN p.is_deleted = false AND v.organization_activated = true AND v.organization_deleted = false THEN 1 END) as valid_relations
FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id;

-- فحص العلاقات مع فئات التجار
SELECT 
    'product_vendor_category_relations' as relation_type,
    COUNT(*) as total_relations,
    COUNT(CASE WHEN p.is_deleted = false AND v.organization_activated = true AND v.organization_deleted = false AND vc.is_active = true THEN 1 END) as valid_relations
FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id;

-- =====================================================
-- 2. إنشاء View مبسط للاختبار
-- Create simplified view for testing
-- =====================================================

-- حذف View الحالي
DROP VIEW IF EXISTS comprehensive_search_view;

-- إنشاء View مبسط بدون شروط صارمة
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
    
    -- نص شامل للبحث مع search_vector
    to_tsvector('arabic', CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
        COALESCE(vc.title, '')
    )) as search_vector,
    
    -- نص عادي للبحث
    CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
        COALESCE(vc.title, '')
    ) as search_text,
    
    -- تصنيف النتائج حسب ترتيب الفئة
    CASE 
        WHEN vc.sort_order <= 2 THEN 'high_priority'
        WHEN vc.sort_order <= 5 THEN 'medium_priority'
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
    
    -- تقييم افتراضي (يمكن تحديثه لاحقاً)
    5 as rating

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

-- شروط مبسطة - عرض جميع المنتجات مع معلومات التاجر إن وجدت
WHERE 
    p.is_deleted = false; -- فقط المنتجات غير المحذوفة

-- =====================================================
-- 3. اختبار View الجديد
-- Test new view
-- =====================================================

-- فحص عدد السجلات في View الجديد
SELECT 
    'comprehensive_search_view' as view_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN vendor_status = 'active' THEN 1 END) as active_vendors,
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
-- 4. إنشاء View بديل مع شروط مرنة
-- Create alternative view with flexible conditions
-- =====================================================

-- إنشاء View مرن للبحث
CREATE OR REPLACE VIEW flexible_search_view AS
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
    
    -- بيانات التاجر (مع قيم افتراضية)
    v.id as vendor_id,
    v.user_id as vendor_user_id,
    COALESCE(v.organization_name, 'تاجر غير محدد') as vendor_name,
    COALESCE(v.organization_bio, '') as vendor_bio,
    COALESCE(v.banner_image, '') as vendor_banner,
    COALESCE(v.organization_logo, '') as vendor_logo,
    COALESCE(v.organization_cover, '') as vendor_cover,
    COALESCE(v.brief, '') as vendor_brief,
    v.exclusive_id,
    COALESCE(v.store_message, '') as store_message,
    COALESCE(v.in_exclusive, false) as in_exclusive,
    COALESCE(v.is_subscriber, false) as is_subscriber,
    COALESCE(v.is_verified, false) as is_verified,
    COALESCE(v.is_royal, false) as is_royal,
    COALESCE(v.enable_iwinto_payment, false) as enable_iwinto_payment,
    COALESCE(v.enable_cod, false) as enable_cod,
    COALESCE(v.organization_deleted, false) as organization_deleted,
    COALESCE(v.organization_activated, false) as organization_activated,
    COALESCE(v.default_currency, 'USD') as default_currency,
    COALESCE(v.created_at, p.created_at) as vendor_created_at,
    COALESCE(v.updated_at, p.updated_at) as vendor_updated_at,
    COALESCE(v.selected_major_categories, '') as selected_major_categories,
    
    -- بيانات فئة التاجر (مع قيم افتراضية)
    vc.id as vendor_category_vc_id,
    COALESCE(vc.title, 'فئة عامة') as vendor_category_title,
    COALESCE(vc.color, '#000000') as vendor_category_color,
    COALESCE(vc.icon, '') as vendor_category_icon,
    COALESCE(vc.sort_order, 999) as vendor_category_sort_order,
    COALESCE(vc.is_active, true) as vendor_category_active,
    COALESCE(vc.created_at, p.created_at) as vendor_category_created_at,
    COALESCE(vc.updated_at, p.updated_at) as vendor_category_updated_at,
    
    -- بيانات إضافية للبحث
    COALESCE(p.product_type, '') as product_type_text,
    
    -- نص شامل للبحث
    to_tsvector('arabic', CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
        COALESCE(vc.title, '')
    )) as search_vector,
    
    -- نص عادي للبحث
    CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
        COALESCE(vc.title, '')
    ) as search_text,
    
    -- نوع العنصر للفلترة
    'منتج' as item_type,
    
    -- تقييم افتراضي
    5 as rating

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

-- شرط واحد فقط: المنتجات غير المحذوفة
WHERE p.is_deleted = false;

-- =====================================================
-- 5. اختبار View المرن
-- Test flexible view
-- =====================================================

-- فحص عدد السجلات في View المرن
SELECT 
    'flexible_search_view' as view_name,
    COUNT(*) as total_records
FROM flexible_search_view;

-- عرض عينة من البيانات
SELECT 
    product_title,
    vendor_name,
    price,
    vendor_category_title
FROM flexible_search_view 
LIMIT 10;

-- =====================================================
-- 6. إعطاء الصلاحيات
-- Grant permissions
-- =====================================================

-- صلاحيات للقراءة
GRANT SELECT ON comprehensive_search_view TO authenticated;
GRANT SELECT ON flexible_search_view TO authenticated;

-- =====================================================
-- انتهاء السكريبت
-- End of script
-- =====================================================
