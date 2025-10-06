-- =====================================================
-- سكريبت البحث الشامل المصحح نهائياً (بدون تكرار الأعمدة)
-- Final Corrected Comprehensive Search Script (No Duplicate Columns)
-- =====================================================

-- 1. إنشاء View أساسي يجمع البيانات من الجداول الثلاث
-- Create basic view that combines data from all three tables

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
    
    -- بيانات التاجر (الهيكل الصحيح)
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
    
    -- بيانات فئة التاجر (مع اسم مختلف لتجنب التكرار)
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
    CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
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
    
    -- حالة التاجر
    CASE 
        WHEN v.organization_activated = true AND v.organization_deleted = false THEN 'active'
        WHEN v.organization_deleted = true THEN 'deleted'
        ELSE 'inactive'
    END as vendor_status

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

WHERE 
    p.is_deleted = false 
    AND v.organization_activated = true 
    AND v.organization_deleted = false
    AND vc.is_active = true;

-- =====================================================
-- 2. إنشاء Materialized View لتحسين الأداء
-- Create Materialized View for better performance
-- =====================================================

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
    
    -- بيانات التاجر (الهيكل الصحيح)
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
    
    -- بيانات فئة التاجر (مع اسم مختلف لتجنب التكرار)
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
    
    -- نص شامل للبحث مع تحسينات
    to_tsvector('arabic', CONCAT_WS(' ',
        p.title,
        p.description,
        COALESCE(p.product_type, ''),
        COALESCE(v.organization_name, ''),
        COALESCE(v.organization_bio, ''),
        COALESCE(v.brief, ''),
        COALESCE(v.store_message, ''),
        vc.title
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
    END as discount_percentage

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id

WHERE 
    p.is_deleted = false 
    AND v.organization_activated = true 
    AND v.organization_deleted = false
    AND vc.is_active = true;

-- =====================================================
-- 3. إنشاء فهارس لتحسين الأداء
-- Create indexes for better performance
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
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_vendor_category_vc_id 
ON comprehensive_search_materialized (vendor_category_vc_id);

-- فهرس على حالة التوفر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_availability 
ON comprehensive_search_materialized (availability_status);

-- فهرس على حالة المميز
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_feature 
ON comprehensive_search_materialized (is_feature);

-- فهرس على حالة التاجر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_vendor_status 
ON comprehensive_search_materialized (vendor_status);

-- فهرس على حالة التحقق
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_verified 
ON comprehensive_search_materialized (is_verified);

-- فهرس على نقاط البحث
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_score 
ON comprehensive_search_materialized (search_score DESC);

-- فهرس مركب على التاجر وفئة التاجر
CREATE INDEX IF NOT EXISTS idx_comprehensive_search_vendor_category 
ON comprehensive_search_materialized (vendor_id, vendor_category_vc_id);

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
-- 4. إنشاء دالة لتحديث Materialized View
-- Create function to refresh Materialized View
-- =====================================================

CREATE OR REPLACE FUNCTION refresh_comprehensive_search()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY comprehensive_search_materialized;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. إنشاء دالة للبحث الشامل
-- Create function for comprehensive search
-- =====================================================

CREATE OR REPLACE FUNCTION search_comprehensive(
    search_query TEXT,
    category_filter TEXT DEFAULT NULL,
    vendor_filter TEXT DEFAULT NULL,
    availability_filter TEXT DEFAULT NULL,
    feature_filter TEXT DEFAULT NULL,
    verified_filter BOOLEAN DEFAULT NULL,
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
    vendor_user_id TEXT,
    vendor_name TEXT,
    vendor_bio TEXT,
    vendor_logo TEXT,
    vendor_cover TEXT,
    vendor_brief TEXT,
    vendor_category_vc_id TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    vendor_category_sort_order INTEGER,
    is_feature BOOLEAN,
    is_verified BOOLEAN,
    min_quantity INTEGER,
    sale_percentage DECIMAL,
    availability_status TEXT,
    feature_status TEXT,
    vendor_status TEXT,
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
        csm.vendor_user_id,
        csm.vendor_name,
        csm.vendor_bio,
        csm.vendor_logo,
        csm.vendor_cover,
        csm.vendor_brief,
        csm.vendor_category_vc_id,
        csm.vendor_category_title,
        csm.vendor_category_color,
        csm.vendor_category_icon,
        csm.vendor_category_sort_order,
        csm.is_feature,
        csm.is_verified,
        csm.min_quantity,
        csm.sale_percentage,
        csm.availability_status,
        csm.feature_status,
        csm.vendor_status,
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
        AND (verified_filter IS NULL OR csm.is_verified = verified_filter)
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

-- =====================================================
-- 6. إنشاء دالة للبحث السريع (بدون Full Text Search)
-- Create function for quick search (without Full Text Search)
-- =====================================================

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
    is_verified BOOLEAN,
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
        csm.is_verified,
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

-- =====================================================
-- 7. إنشاء دالة للحصول على إحصائيات البحث
-- Create function to get search statistics
-- =====================================================

CREATE OR REPLACE FUNCTION get_search_statistics()
RETURNS TABLE (
    total_products BIGINT,
    total_vendors BIGINT,
    total_vendor_categories BIGINT,
    active_products BIGINT,
    featured_products BIGINT,
    available_products BIGINT,
    verified_vendors BIGINT,
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
        COUNT(DISTINCT csm.vendor_category_vc_id) as total_vendor_categories,
        COUNT(DISTINCT CASE WHEN csm.is_deleted = false THEN csm.product_id END) as active_products,
        COUNT(DISTINCT CASE WHEN csm.is_feature = true THEN csm.product_id END) as featured_products,
        COUNT(DISTINCT CASE WHEN csm.availability_status = 'available' THEN csm.product_id END) as available_products,
        COUNT(DISTINCT CASE WHEN csm.is_verified = true THEN csm.vendor_id END) as verified_vendors,
        COUNT(DISTINCT CASE WHEN csm.vendor_category_sort_order <= 2 THEN csm.vendor_category_vc_id END) as high_priority_categories,
        AVG(csm.price) as avg_price,
        MIN(csm.price) as min_price,
        MAX(csm.price) as max_price
    FROM comprehensive_search_materialized csm;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. إنشاء Trigger لتحديث Materialized View تلقائياً
-- Create trigger to automatically update Materialized View
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
-- 9. تحديث Materialized View لأول مرة
-- Refresh Materialized View for the first time
-- =====================================================

REFRESH MATERIALIZED VIEW comprehensive_search_materialized;

-- =====================================================
-- 10. إعطاء الصلاحيات المناسبة
-- Grant appropriate permissions
-- =====================================================

-- صلاحيات للقراءة
GRANT SELECT ON comprehensive_search_view TO authenticated;
GRANT SELECT ON comprehensive_search_materialized TO authenticated;

-- صلاحيات للدوال
GRANT EXECUTE ON FUNCTION search_comprehensive TO authenticated;
GRANT EXECUTE ON FUNCTION quick_search_comprehensive TO authenticated;
GRANT EXECUTE ON FUNCTION get_search_statistics TO authenticated;
GRANT EXECUTE ON FUNCTION refresh_comprehensive_search TO authenticated;

-- =====================================================
-- انتهاء السكريبت المصحح نهائياً (بدون تكرار الأعمدة)
-- End of Final Corrected Script (No Duplicate Columns)
-- =====================================================
