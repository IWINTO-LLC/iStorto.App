-- =====================================================
-- أرشيف شامل لسكريبتات قاعدة البيانات - iStoreto
-- Comprehensive Database Scripts Archive - iStoreto
-- تاريخ الإنشاء: 2024
-- =====================================================

-- =====================================================
-- 1. سكريبت البحث الشامل النهائي
-- Final Comprehensive Search Script
-- =====================================================

-- View أساسي للبحث الشامل
CREATE OR REPLACE VIEW comprehensive_search_view AS
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
    v.name as vendor_name,
    v.bio as vendor_bio,
    v.brief as vendor_brief,
    v.email as vendor_email,
    v.phone_number as vendor_phone,
    v.profile_image as vendor_image,
    v.is_active as vendor_active,
    v.created_at as vendor_created_at,
    
    -- بيانات فئة التاجر
    vc.id as vendor_category_id,
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
    CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        v.name,
        v.bio,
        v.brief,
        vc.title
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
    END as deletion_status

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

WHERE 
    p.is_deleted = false 
    AND v.is_active = true 
    AND vc.is_active = true;

-- Materialized View للبحث الشامل
CREATE MATERIALIZED VIEW IF NOT EXISTS comprehensive_search_materialized AS
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
    v.name as vendor_name,
    v.bio as vendor_bio,
    v.brief as vendor_brief,
    v.email as vendor_email,
    v.phone_number as vendor_phone,
    v.profile_image as vendor_image,
    v.is_active as vendor_active,
    v.created_at as vendor_created_at,
    
    -- بيانات فئة التاجر
    vc.id as vendor_category_id,
    vc.title as vendor_category_title,
    vc.color as vendor_category_color,
    vc.icon as vendor_category_icon,
    vc.sort_order as vendor_category_sort_order,
    vc.is_active as vendor_category_active,
    vc.created_at as vendor_category_created_at,
    vc.updated_at as vendor_category_updated_at,
    
    -- بيانات إضافية للبحث
    COALESCE(p.product_type, '') as product_type_text,
    
    -- نص شامل للبحث مع تحسينات
    to_tsvector('arabic', CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        v.name,
        v.bio,
        v.brief,
        vc.title
    )) as search_vector,
    
    -- نص عادي للبحث
    CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        v.name,
        v.bio,
        v.brief,
        vc.title
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
    
    -- نقاط البحث (لترتيب النتائج)
    CASE 
        WHEN p.is_feature = true AND vc.sort_order = 1 THEN 100
        WHEN p.is_feature = true AND vc.sort_order <= 2 THEN 95
        WHEN p.is_feature = true THEN 90
        WHEN vc.sort_order = 1 THEN 85
        WHEN vc.sort_order <= 2 THEN 80
        WHEN vc.sort_order <= 5 THEN 70
        WHEN vc.sort_order <= 10 THEN 60
        ELSE 50
    END as search_score,
    
    -- حساب الخصم
    CASE 
        WHEN p.old_price > 0 AND p.price > 0 THEN 
            ROUND(((p.old_price - p.price) / p.old_price) * 100, 2)
        ELSE 0
    END as discount_percentage

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

WHERE 
    p.is_deleted = false 
    AND v.is_active = true 
    AND vc.is_active = true;

-- =====================================================
-- 2. فهارس البحث الشامل
-- Comprehensive Search Indexes
-- =====================================================

-- فهرس على النص الشامل للبحث
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_text 
ON comprehensive_search_materialized USING gin(search_vector);

-- فهرس على معرف المنتج
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_product_id 
ON comprehensive_search_materialized (product_id);

-- فهرس على معرف التاجر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_vendor_id 
ON comprehensive_search_materialized (vendor_id);

-- فهرس على معرف فئة التاجر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_vendor_category_id 
ON comprehensive_search_materialized (vendor_category_id);

-- فهرس على حالة التوفر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_availability 
ON comprehensive_search_materialized (availability_status);

-- فهرس على حالة المميز
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_feature 
ON comprehensive_search_materialized (is_feature);

-- فهرس على نقاط البحث
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_score 
ON comprehensive_search_materialized (search_score DESC);

-- فهرس مركب على التاجر وفئة التاجر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_vendor_category 
ON comprehensive_search_materialized (vendor_id, vendor_category_id);

-- فهرس على ترتيب الفئة
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_sort_order 
ON comprehensive_search_materialized (vendor_category_sort_order);

-- فهرس على السعر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_price 
ON comprehensive_search_materialized (price);

-- فهرس على نوع المنتج
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_product_type 
ON comprehensive_search_materialized (product_type);

-- فهرس على حالة الحذف
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_deleted 
ON comprehensive_search_materialized (is_deleted);

-- =====================================================
-- 3. دوال البحث الشامل
-- Comprehensive Search Functions
-- =====================================================

-- دالة لتحديث Materialized View
CREATE OR REPLACE FUNCTION refresh_comprehensive_search()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY comprehensive_search_materialized;
END;
$$ LANGUAGE plpgsql;

-- دالة للبحث الشامل
CREATE OR REPLACE FUNCTION search_comprehensive(
    search_query TEXT,
    category_filter TEXT DEFAULT NULL,
    vendor_filter TEXT DEFAULT NULL,
    availability_filter TEXT DEFAULT NULL,
    feature_filter TEXT DEFAULT NULL,
    price_min DECIMAL DEFAULT NULL,
    price_max DECIMAL DEFAULT NULL,
    limit_count INTEGER DEFAULT 50,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    product_id TEXT,
    product_title TEXT,
    product_description TEXT,
    price DECIMAL,
    old_price DECIMAL,
    product_type TEXT,
    product_thumbnail TEXT,
    product_images TEXT,
    currency TEXT,
    vendor_id TEXT,
    vendor_name TEXT,
    vendor_bio TEXT,
    vendor_category_id TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    vendor_category_sort_order INTEGER,
    is_feature BOOLEAN,
    min_quantity INTEGER,
    sale_percentage DECIMAL,
    availability_status TEXT,
    feature_status TEXT,
    search_score INTEGER,
    discount_percentage DECIMAL,
    relevance_score REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        csm.product_id,
        csm.product_title,
        csm.product_description,
        csm.price,
        csm.old_price,
        csm.product_type,
        csm.product_thumbnail,
        csm.product_images,
        csm.currency,
        csm.vendor_id,
        csm.vendor_name,
        csm.vendor_bio,
        csm.vendor_category_id,
        csm.vendor_category_title,
        csm.vendor_category_color,
        csm.vendor_category_icon,
        csm.vendor_category_sort_order,
        csm.is_feature,
        csm.min_quantity,
        csm.sale_percentage,
        csm.availability_status,
        csm.feature_status,
        csm.search_score,
        csm.discount_percentage,
        ts_rank(csm.search_vector, plainto_tsquery('arabic', search_query)) as relevance_score
    FROM comprehensive_search_materialized csm
    WHERE 
        csm.search_vector @@ plainto_tsquery('arabic', search_query)
        AND (category_filter IS NULL OR csm.vendor_category_title ILIKE '%' || category_filter || '%')
        AND (vendor_filter IS NULL OR csm.vendor_name ILIKE '%' || vendor_filter || '%')
        AND (availability_filter IS NULL OR csm.availability_status = availability_filter)
        AND (feature_filter IS NULL OR csm.feature_status = feature_filter)
        AND (price_min IS NULL OR csm.price >= price_min)
        AND (price_max IS NULL OR csm.price <= price_max)
    ORDER BY 
        relevance_score DESC,
        csm.search_score DESC,
        csm.product_title ASC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- دالة للبحث السريع
CREATE OR REPLACE FUNCTION quick_search_comprehensive(
    search_query TEXT,
    limit_count INTEGER DEFAULT 20
)
RETURNS TABLE (
    product_id TEXT,
    product_title TEXT,
    vendor_name TEXT,
    vendor_category_title TEXT,
    price DECIMAL,
    old_price DECIMAL,
    currency TEXT,
    product_thumbnail TEXT,
    availability_status TEXT,
    feature_status TEXT,
    search_score INTEGER,
    discount_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        csm.product_id,
        csm.product_title,
        csm.vendor_name,
        csm.vendor_category_title,
        csm.price,
        csm.old_price,
        csm.currency,
        csm.product_thumbnail,
        csm.availability_status,
        csm.feature_status,
        csm.search_score,
        csm.discount_percentage
    FROM comprehensive_search_materialized csm
    WHERE 
        csm.search_text ILIKE '%' || search_query || '%'
    ORDER BY 
        csm.search_score DESC,
        csm.product_title ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على إحصائيات البحث
CREATE OR REPLACE FUNCTION get_search_statistics()
RETURNS TABLE (
    total_products BIGINT,
    total_vendors BIGINT,
    total_vendor_categories BIGINT,
    active_products BIGINT,
    featured_products BIGINT,
    available_products BIGINT,
    high_priority_categories BIGINT,
    avg_price DECIMAL,
    min_price DECIMAL,
    max_price DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT csm.product_id) as total_products,
        COUNT(DISTINCT csm.vendor_id) as total_vendors,
        COUNT(DISTINCT csm.vendor_category_id) as total_vendor_categories,
        COUNT(DISTINCT CASE WHEN csm.is_deleted = false THEN csm.product_id END) as active_products,
        COUNT(DISTINCT CASE WHEN csm.is_feature = true THEN csm.product_id END) as featured_products,
        COUNT(DISTINCT CASE WHEN csm.availability_status = 'available' THEN csm.product_id END) as available_products,
        COUNT(DISTINCT CASE WHEN csm.vendor_category_sort_order <= 2 THEN csm.vendor_category_id END) as high_priority_categories,
        AVG(csm.price) as avg_price,
        MIN(csm.price) as min_price,
        MAX(csm.price) as max_price
    FROM comprehensive_search_materialized csm;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. Views الصفحة الرئيسية
-- Homepage Views
-- =====================================================

-- View لأحدث المنتجات
CREATE OR REPLACE VIEW homepage_latest_products AS
SELECT 
    -- بيانات المنتج
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
    v.name as vendor_name,
    v.bio as vendor_bio,
    v.brief as vendor_brief,
    v.profile_image as vendor_image,
    v.is_active as vendor_active,
    v.created_at as vendor_created_at,
    
    -- بيانات فئة التاجر
    vc.id as vendor_category_id,
    vc.title as vendor_category_title,
    vc.color as vendor_category_color,
    vc.icon as vendor_category_icon,
    vc.sort_order as vendor_category_sort_order,
    vc.is_active as vendor_category_active,
    
    -- بيانات إضافية للعرض
    CASE 
        WHEN p.min_quantity > 0 THEN 'available'
        ELSE 'unavailable'
    END as availability_status,
    
    -- نقاط الأولوية للعرض
    CASE 
        WHEN p.is_feature = true AND vc.sort_order = 1 THEN 100
        WHEN p.is_feature = true AND vc.sort_order <= 2 THEN 95
        WHEN p.is_feature = true THEN 90
        WHEN vc.sort_order = 1 THEN 85
        WHEN vc.sort_order <= 2 THEN 80
        WHEN vc.sort_order <= 5 THEN 70
        WHEN vc.sort_order <= 10 THEN 60
        ELSE 50
    END as display_priority,
    
    -- حالة الجدة
    CASE 
        WHEN p.created_at > NOW() - INTERVAL '7 days' THEN 'new'
        WHEN p.created_at > NOW() - INTERVAL '30 days' THEN 'recent'
        ELSE 'old'
    END as product_age_status,
    
    -- حساب الخصم
    CASE 
        WHEN p.old_price > 0 AND p.price > 0 THEN 
            ROUND(((p.old_price - p.price) / p.old_price) * 100, 2)
        ELSE 0
    END as discount_percentage

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

WHERE 
    p.is_deleted = false 
    AND v.is_active = true 
    AND vc.is_active = true
    AND p.min_quantity > 0  -- فقط المنتجات المتوفرة

ORDER BY 
    p.created_at DESC,
    display_priority DESC,
    p.updated_at DESC;

-- View لأحدث التجار
CREATE OR REPLACE VIEW homepage_latest_vendors AS
SELECT 
    -- بيانات التاجر
    v.id as vendor_id,
    v.name as vendor_name,
    v.bio as vendor_bio,
    v.brief as vendor_brief,
    v.email as vendor_email,
    v.phone_number as vendor_phone,
    v.profile_image as vendor_image,
    v.is_active as vendor_active,
    v.created_at as vendor_created_at,
    v.updated_at as vendor_updated_at,
    
    -- بيانات فئة التاجر
    vc.id as vendor_category_id,
    vc.title as vendor_category_title,
    vc.color as vendor_category_color,
    vc.icon as vendor_category_icon,
    vc.sort_order as vendor_category_sort_order,
    vc.is_active as vendor_category_active,
    
    -- إحصائيات التاجر
    COUNT(DISTINCT p.id) as total_products,
    COUNT(DISTINCT CASE WHEN p.is_deleted = false THEN p.id END) as active_products,
    COUNT(DISTINCT CASE WHEN p.min_quantity > 0 THEN p.id END) as available_products,
    COUNT(DISTINCT CASE WHEN p.is_feature = true THEN p.id END) as featured_products,
    AVG(p.price) as avg_product_price,
    MIN(p.price) as min_product_price,
    MAX(p.price) as max_product_price,
    AVG(CASE 
        WHEN p.old_price > 0 AND p.price > 0 THEN 
            ROUND(((p.old_price - p.price) / p.old_price) * 100, 2)
        ELSE 0
    END) as avg_discount_percentage,
    
    -- نقاط الأولوية للعرض
    CASE 
        WHEN vc.sort_order = 1 THEN 100
        WHEN vc.sort_order = 2 THEN 90
        WHEN vc.sort_order <= 5 THEN 80
        WHEN vc.sort_order <= 10 THEN 70
        ELSE 50
    END as display_priority,
    
    -- حالة الجدة
    CASE 
        WHEN v.created_at > NOW() - INTERVAL '7 days' THEN 'new'
        WHEN v.created_at > NOW() - INTERVAL '30 days' THEN 'recent'
        ELSE 'old'
    END as vendor_age_status

FROM vendors v
LEFT JOIN vendor_categories vc ON v.id = vc.vendor_id
LEFT JOIN products p ON v.id = p.vendor_id

WHERE 
    v.is_active = true 
    AND vc.is_active = true

GROUP BY 
    v.id, v.name, v.bio, v.brief, v.email, v.phone_number, 
    v.profile_image, v.is_active, v.created_at, v.updated_at,
    vc.id, vc.title, vc.color, vc.icon, vc.sort_order, vc.is_active

ORDER BY 
    v.created_at DESC,
    display_priority DESC,
    total_products DESC;

-- View للمنتجات المميزة
CREATE OR REPLACE VIEW homepage_featured_products AS
SELECT 
    -- بيانات المنتج
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
    v.name as vendor_name,
    v.bio as vendor_bio,
    v.brief as vendor_brief,
    v.profile_image as vendor_image,
    v.is_active as vendor_active,
    
    -- بيانات فئة التاجر
    vc.id as vendor_category_id,
    vc.title as vendor_category_title,
    vc.color as vendor_category_color,
    vc.icon as vendor_category_icon,
    vc.sort_order as vendor_category_sort_order,
    vc.is_active as vendor_category_active,
    
    -- بيانات إضافية للعرض
    CASE 
        WHEN p.min_quantity > 0 THEN 'available'
        ELSE 'unavailable'
    END as availability_status,
    
    -- نقاط الأولوية للعرض
    CASE 
        WHEN p.is_feature = true AND vc.sort_order = 1 THEN 100
        WHEN p.is_feature = true AND vc.sort_order <= 2 THEN 95
        WHEN p.is_feature = true THEN 90
        WHEN vc.sort_order = 1 THEN 85
        WHEN vc.sort_order <= 2 THEN 80
        WHEN vc.sort_order <= 5 THEN 70
        WHEN vc.sort_order <= 10 THEN 60
        ELSE 50
    END as display_priority,
    
    -- حساب الخصم
    CASE 
        WHEN p.old_price > 0 AND p.price > 0 THEN 
            ROUND(((p.old_price - p.price) / p.old_price) * 100, 2)
        ELSE 0
    END as discount_percentage

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

WHERE 
    p.is_deleted = false 
    AND v.is_active = true 
    AND vc.is_active = true
    AND p.min_quantity > 0
    AND (p.is_feature = true OR vc.sort_order <= 5)  -- المنتجات المميزة أو الفئات عالية الأولوية

ORDER BY 
    display_priority DESC,
    p.created_at DESC,
    p.updated_at DESC;

-- View للتجار المميزين
CREATE OR REPLACE VIEW homepage_featured_vendors AS
SELECT 
    -- بيانات التاجر
    v.id as vendor_id,
    v.name as vendor_name,
    v.bio as vendor_bio,
    v.brief as vendor_brief,
    v.email as vendor_email,
    v.phone_number as vendor_phone,
    v.profile_image as vendor_image,
    v.is_active as vendor_active,
    v.created_at as vendor_created_at,
    v.updated_at as vendor_updated_at,
    
    -- بيانات فئة التاجر
    vc.id as vendor_category_id,
    vc.title as vendor_category_title,
    vc.color as vendor_category_color,
    vc.icon as vendor_category_icon,
    vc.sort_order as vendor_category_sort_order,
    vc.is_active as vendor_category_active,
    
    -- إحصائيات التاجر
    COUNT(DISTINCT p.id) as total_products,
    COUNT(DISTINCT CASE WHEN p.is_deleted = false THEN p.id END) as active_products,
    COUNT(DISTINCT CASE WHEN p.min_quantity > 0 THEN p.id END) as available_products,
    COUNT(DISTINCT CASE WHEN p.is_feature = true THEN p.id END) as featured_products,
    AVG(p.price) as avg_product_price,
    MIN(p.price) as min_product_price,
    MAX(p.price) as max_product_price,
    AVG(CASE 
        WHEN p.old_price > 0 AND p.price > 0 THEN 
            ROUND(((p.old_price - p.price) / p.old_price) * 100, 2)
        ELSE 0
    END) as avg_discount_percentage,
    
    -- نقاط الأولوية للعرض
    CASE 
        WHEN vc.sort_order = 1 THEN 100
        WHEN vc.sort_order = 2 THEN 90
        WHEN vc.sort_order <= 5 THEN 80
        WHEN vc.sort_order <= 10 THEN 70
        ELSE 50
    END as display_priority

FROM vendors v
LEFT JOIN vendor_categories vc ON v.id = vc.vendor_id
LEFT JOIN products p ON v.id = p.vendor_id

WHERE 
    v.is_active = true 
    AND vc.is_active = true
    AND vc.sort_order <= 5  -- فقط الفئات عالية الأولوية

GROUP BY 
    v.id, v.name, v.bio, v.brief, v.email, v.phone_number, 
    v.profile_image, v.is_active, v.created_at, v.updated_at,
    vc.id, vc.title, vc.color, vc.icon, vc.sort_order, vc.is_active

ORDER BY 
    display_priority DESC,
    total_products DESC,
    v.created_at DESC;

-- View لإحصائيات الصفحة الرئيسية
CREATE OR REPLACE VIEW homepage_statistics AS
SELECT 
    -- إحصائيات المنتجات
    COUNT(DISTINCT p.id) as total_products,
    COUNT(DISTINCT CASE WHEN p.is_deleted = false THEN p.id END) as active_products,
    COUNT(DISTINCT CASE WHEN p.min_quantity > 0 THEN p.id END) as available_products,
    COUNT(DISTINCT CASE WHEN p.is_feature = true THEN p.id END) as featured_products,
    COUNT(DISTINCT CASE WHEN p.created_at > NOW() - INTERVAL '7 days' THEN p.id END) as new_products_week,
    COUNT(DISTINCT CASE WHEN p.created_at > NOW() - INTERVAL '30 days' THEN p.id END) as new_products_month,
    
    -- إحصائيات التجار
    COUNT(DISTINCT v.id) as total_vendors,
    COUNT(DISTINCT CASE WHEN v.is_active = true THEN v.id END) as active_vendors,
    COUNT(DISTINCT CASE WHEN v.created_at > NOW() - INTERVAL '7 days' THEN v.id END) as new_vendors_week,
    COUNT(DISTINCT CASE WHEN v.created_at > NOW() - INTERVAL '30 days' THEN v.id END) as new_vendors_month,
    
    -- إحصائيات الفئات
    COUNT(DISTINCT vc.id) as total_vendor_categories,
    COUNT(DISTINCT CASE WHEN vc.is_active = true THEN vc.id END) as active_vendor_categories,
    COUNT(DISTINCT CASE WHEN vc.sort_order <= 5 THEN vc.id END) as high_priority_categories,
    
    -- إحصائيات الأسعار
    AVG(p.price) as avg_product_price,
    MIN(p.price) as min_product_price,
    MAX(p.price) as max_product_price,
    
    -- إحصائيات الخصم
    AVG(CASE 
        WHEN p.old_price > 0 AND p.price > 0 THEN 
            ROUND(((p.old_price - p.price) / p.old_price) * 100, 2)
        ELSE 0
    END) as avg_discount_percentage,
    
    -- إحصائيات المخزون
    SUM(p.min_quantity) as total_min_quantity,
    COUNT(DISTINCT CASE WHEN p.min_quantity > 10 THEN p.id END) as well_stocked_products,
    COUNT(DISTINCT CASE WHEN p.min_quantity = 0 THEN p.id END) as out_of_stock_products

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

WHERE 
    p.is_deleted = false 
    AND v.is_active = true 
    AND vc.is_active = true;

-- =====================================================
-- 5. دوال الصفحة الرئيسية
-- Homepage Functions
-- =====================================================

-- دالة للحصول على أحدث المنتجات
CREATE OR REPLACE FUNCTION get_latest_products(
    limit_count INTEGER DEFAULT 20,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    product_id TEXT,
    product_title TEXT,
    product_description TEXT,
    price DECIMAL,
    old_price DECIMAL,
    product_type TEXT,
    product_thumbnail TEXT,
    product_images TEXT,
    currency TEXT,
    vendor_id TEXT,
    vendor_name TEXT,
    vendor_image TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    availability_status TEXT,
    display_priority INTEGER,
    product_age_status TEXT,
    discount_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hlp.product_id,
        hlp.product_title,
        hlp.product_description,
        hlp.price,
        hlp.old_price,
        hlp.product_type,
        hlp.product_thumbnail,
        hlp.product_images,
        hlp.currency,
        hlp.vendor_id,
        hlp.vendor_name,
        hlp.vendor_image,
        hlp.vendor_category_title,
        hlp.vendor_category_color,
        hlp.vendor_category_icon,
        hlp.availability_status,
        hlp.display_priority,
        hlp.product_age_status,
        hlp.discount_percentage
    FROM homepage_latest_products hlp
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على أحدث التجار
CREATE OR REPLACE FUNCTION get_latest_vendors(
    limit_count INTEGER DEFAULT 10,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    vendor_id TEXT,
    vendor_name TEXT,
    vendor_bio TEXT,
    vendor_brief TEXT,
    vendor_image TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    total_products BIGINT,
    active_products BIGINT,
    available_products BIGINT,
    featured_products BIGINT,
    avg_product_price DECIMAL,
    avg_discount_percentage DECIMAL,
    display_priority INTEGER,
    vendor_age_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hlv.vendor_id,
        hlv.vendor_name,
        hlv.vendor_bio,
        hlv.vendor_brief,
        hlv.vendor_image,
        hlv.vendor_category_title,
        hlv.vendor_category_color,
        hlv.vendor_category_icon,
        hlv.total_products,
        hlv.active_products,
        hlv.available_products,
        hlv.featured_products,
        hlv.avg_product_price,
        hlv.avg_discount_percentage,
        hlv.display_priority,
        hlv.vendor_age_status
    FROM homepage_latest_vendors hlv
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على المنتجات المميزة
CREATE OR REPLACE FUNCTION get_featured_products(
    limit_count INTEGER DEFAULT 15,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    product_id TEXT,
    product_title TEXT,
    product_description TEXT,
    price DECIMAL,
    old_price DECIMAL,
    product_type TEXT,
    product_thumbnail TEXT,
    product_images TEXT,
    currency TEXT,
    vendor_id TEXT,
    vendor_name TEXT,
    vendor_image TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    availability_status TEXT,
    display_priority INTEGER,
    discount_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hfp.product_id,
        hfp.product_title,
        hfp.product_description,
        hfp.price,
        hfp.old_price,
        hfp.product_type,
        hfp.product_thumbnail,
        hfp.product_images,
        hfp.currency,
        hfp.vendor_id,
        hfp.vendor_name,
        hfp.vendor_image,
        hfp.vendor_category_title,
        hfp.vendor_category_color,
        hfp.vendor_category_icon,
        hfp.availability_status,
        hfp.display_priority,
        hfp.discount_percentage
    FROM homepage_featured_products hfp
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على التجار المميزين
CREATE OR REPLACE FUNCTION get_featured_vendors(
    limit_count INTEGER DEFAULT 8,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    vendor_id TEXT,
    vendor_name TEXT,
    vendor_bio TEXT,
    vendor_brief TEXT,
    vendor_image TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    total_products BIGINT,
    active_products BIGINT,
    available_products BIGINT,
    featured_products BIGINT,
    avg_product_price DECIMAL,
    avg_discount_percentage DECIMAL,
    display_priority INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hfv.vendor_id,
        hfv.vendor_name,
        hfv.vendor_bio,
        hfv.vendor_brief,
        hfv.vendor_image,
        hfv.vendor_category_title,
        hfv.vendor_category_color,
        hfv.vendor_category_icon,
        hfv.total_products,
        hfv.active_products,
        hfv.available_products,
        hfv.featured_products,
        hfv.avg_product_price,
        hfv.avg_discount_percentage,
        hfv.display_priority
    FROM homepage_featured_vendors hfv
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على إحصائيات الصفحة الرئيسية
CREATE OR REPLACE FUNCTION get_homepage_statistics()
RETURNS TABLE (
    total_products BIGINT,
    active_products BIGINT,
    available_products BIGINT,
    featured_products BIGINT,
    new_products_week BIGINT,
    new_products_month BIGINT,
    total_vendors BIGINT,
    active_vendors BIGINT,
    new_vendors_week BIGINT,
    new_vendors_month BIGINT,
    total_vendor_categories BIGINT,
    active_vendor_categories BIGINT,
    high_priority_categories BIGINT,
    avg_product_price DECIMAL,
    min_product_price DECIMAL,
    max_product_price DECIMAL,
    avg_discount_percentage DECIMAL,
    total_min_quantity BIGINT,
    well_stocked_products BIGINT,
    out_of_stock_products BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hs.total_products,
        hs.active_products,
        hs.available_products,
        hs.featured_products,
        hs.new_products_week,
        hs.new_products_month,
        hs.total_vendors,
        hs.active_vendors,
        hs.new_vendors_week,
        hs.new_vendors_month,
        hs.total_vendor_categories,
        hs.active_vendor_categories,
        hs.high_priority_categories,
        hs.avg_product_price,
        hs.min_product_price,
        hs.max_product_price,
        hs.avg_discount_percentage,
        hs.total_min_quantity,
        hs.well_stocked_products,
        hs.out_of_stock_products
    FROM homepage_statistics hs;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. Triggers للتحديث التلقائي
-- Auto-Update Triggers
-- =====================================================

-- دالة تحديث عند تغيير المنتجات
CREATE OR REPLACE FUNCTION trigger_refresh_search_on_products()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM refresh_comprehensive_search();
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- دالة تحديث عند تغيير التجار
CREATE OR REPLACE FUNCTION trigger_refresh_search_on_vendors()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM refresh_comprehensive_search();
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- دالة تحديث عند تغيير فئات التجار
CREATE OR REPLACE FUNCTION trigger_refresh_search_on_vendor_categories()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM refresh_comprehensive_search();
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- إنشاء Triggers
DROP TRIGGER IF EXISTS trigger_products_search_refresh ON products;
CREATE TRIGGER trigger_products_search_refresh
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH STATEMENT
    EXECUTE FUNCTION trigger_refresh_search_on_products();

DROP TRIGGER IF EXISTS trigger_vendors_search_refresh ON vendors;
CREATE TRIGGER trigger_vendors_search_refresh
    AFTER INSERT OR UPDATE OR DELETE ON vendors
    FOR EACH STATEMENT
    EXECUTE FUNCTION trigger_refresh_search_on_vendors();

DROP TRIGGER IF EXISTS trigger_vendor_categories_search_refresh ON vendor_categories;
CREATE TRIGGER trigger_vendor_categories_search_refresh
    AFTER INSERT OR UPDATE OR DELETE ON vendor_categories
    FOR EACH STATEMENT
    EXECUTE FUNCTION trigger_refresh_search_on_vendor_categories();

-- =====================================================
-- 7. فهارس إضافية للأداء
-- Additional Performance Indexes
-- =====================================================

-- فهارس على التواريخ للعرض
CREATE INDEX IF NOT EXISTS idx_products_created_at 
ON products (created_at DESC) WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_products_updated_at 
ON products (updated_at DESC) WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_vendors_created_at 
ON vendors (created_at DESC) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_vendors_updated_at 
ON vendors (updated_at DESC) WHERE is_active = true;

-- فهارس على حالة التوفر
CREATE INDEX IF NOT EXISTS idx_products_min_quantity 
ON products (min_quantity) WHERE is_deleted = false AND min_quantity > 0;

-- فهارس على حالة المميز
CREATE INDEX IF NOT EXISTS idx_products_is_feature 
ON products (is_feature) WHERE is_deleted = false;

-- فهارس على ترتيب الفئات
CREATE INDEX IF NOT EXISTS idx_vendor_categories_sort_order 
ON vendor_categories (sort_order) WHERE is_active = true;

-- فهارس مركبة للعرض
CREATE INDEX IF NOT EXISTS idx_products_vendor_active_created 
ON products (vendor_id, is_deleted, created_at DESC) WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_vendors_category_active_created 
ON vendors (id, is_active, created_at DESC) WHERE is_active = true;

-- فهارس على السعر
CREATE INDEX IF NOT EXISTS idx_products_price 
ON products (price) WHERE is_deleted = false;

-- فهارس على نوع المنتج
CREATE INDEX IF NOT EXISTS idx_products_product_type 
ON products (product_type) WHERE is_deleted = false;

-- فهارس على حالة الحذف
CREATE INDEX IF NOT EXISTS idx_products_deleted 
ON products (is_deleted) WHERE is_deleted = false;

-- =====================================================
-- 8. الصلاحيات
-- Permissions
-- =====================================================

-- صلاحيات للقراءة
GRANT SELECT ON comprehensive_search_view TO authenticated;
GRANT SELECT ON comprehensive_search_materialized TO authenticated;
GRANT SELECT ON homepage_latest_products TO authenticated;
GRANT SELECT ON homepage_latest_vendors TO authenticated;
GRANT SELECT ON homepage_featured_products TO authenticated;
GRANT SELECT ON homepage_featured_vendors TO authenticated;
GRANT SELECT ON homepage_statistics TO authenticated;

-- صلاحيات للدوال
GRANT EXECUTE ON FUNCTION search_comprehensive TO authenticated;
GRANT EXECUTE ON FUNCTION quick_search_comprehensive TO authenticated;
GRANT EXECUTE ON FUNCTION get_search_statistics TO authenticated;
GRANT EXECUTE ON FUNCTION refresh_comprehensive_search TO authenticated;
GRANT EXECUTE ON FUNCTION get_latest_products TO authenticated;
GRANT EXECUTE ON FUNCTION get_latest_vendors TO authenticated;
GRANT EXECUTE ON FUNCTION get_featured_products TO authenticated;
GRANT EXECUTE ON FUNCTION get_featured_vendors TO authenticated;
GRANT EXECUTE ON FUNCTION get_homepage_statistics TO authenticated;

-- =====================================================
-- 9. تحديث Materialized View لأول مرة
-- Initial Materialized View Refresh
-- =====================================================

REFRESH MATERIALIZED VIEW comprehensive_search_materialized;

-- =====================================================
-- انتهاء الأرشيف الشامل
-- End of Comprehensive Archive
-- =====================================================

-- ملاحظات مهمة:
-- 1. هذا الأرشيف يحتوي على جميع السكريبتات المهمة للبحث والصفحة الرئيسية
-- 2. يمكن تشغيل هذا الملف كاملاً في Supabase SQL Editor
-- 3. جميع الدوال والـ Views جاهزة للاستخدام في Flutter
-- 4. النظام يدعم البحث باللغة العربية مع Full Text Search
-- 5. Materialized View يتم تحديثه تلقائياً عند تغيير البيانات
-- 6. جميع الفهارس محسنة للأداء العالي
-- 7. النظام يدعم التصفح (Pagination) والفلترة المتقدمة
-- 8. يمكن استخدام هذه السكريبتات في أي وقت في المستقبل
