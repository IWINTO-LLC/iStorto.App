-- =====================================================
-- سكريبت Views الصفحة الرئيسية المصحح
-- Corrected Homepage Views Script
-- =====================================================

-- =====================================================
-- 1. View لأحدث المنتجات مع بيانات التاجر والفئة
-- View for Latest Products with Vendor and Category Data
-- =====================================================

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
    
    -- بيانات التاجر (بدون name)
    v.id as vendor_id,
    v.user_id as vendor_user_id,
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

-- =====================================================
-- 2. View لأحدث التجار مع إحصائياتهم
-- View for Latest Vendors with Their Statistics
-- =====================================================

CREATE OR REPLACE VIEW homepage_latest_vendors AS
SELECT 
    -- بيانات التاجر (بدون name)
    v.id as vendor_id,
    v.user_id as vendor_user_id,
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
    v.id, v.user_id, v.bio, v.brief, v.email, v.phone_number, 
    v.profile_image, v.is_active, v.created_at, v.updated_at,
    vc.id, vc.title, vc.color, vc.icon, vc.sort_order, vc.is_active

ORDER BY 
    v.created_at DESC,
    display_priority DESC,
    total_products DESC;

-- =====================================================
-- 3. View للمنتجات المميزة (عالية الأولوية)
-- View for Featured Products (High Priority)
-- =====================================================

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
    
    -- بيانات التاجر (بدون name)
    v.id as vendor_id,
    v.user_id as vendor_user_id,
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

-- =====================================================
-- 4. View للتجار المميزين (عاليو الأولوية)
-- View for Featured Vendors (High Priority)
-- =====================================================

CREATE OR REPLACE VIEW homepage_featured_vendors AS
SELECT 
    -- بيانات التاجر (بدون name)
    v.id as vendor_id,
    v.user_id as vendor_user_id,
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
    v.id, v.user_id, v.bio, v.brief, v.email, v.phone_number, 
    v.profile_image, v.is_active, v.created_at, v.updated_at,
    vc.id, vc.title, vc.color, vc.icon, vc.sort_order, vc.is_active

ORDER BY 
    display_priority DESC,
    total_products DESC,
    v.created_at DESC;

-- =====================================================
-- 5. View لإحصائيات الصفحة الرئيسية
-- View for Homepage Statistics
-- =====================================================

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
-- 6. إنشاء فهارس لتحسين الأداء
-- Create Indexes for Better Performance
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
-- 7. إنشاء دوال للصفحة الرئيسية
-- Create Functions for Homepage
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
    vendor_user_id TEXT,
    vendor_bio TEXT,
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
        hlp.vendor_user_id,
        hlp.vendor_bio,
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
    vendor_user_id TEXT,
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
        hlv.vendor_user_id,
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
    vendor_user_id TEXT,
    vendor_bio TEXT,
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
        hfp.vendor_user_id,
        hfp.vendor_bio,
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
    vendor_user_id TEXT,
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
        hfv.vendor_user_id,
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
-- 8. إعطاء الصلاحيات المناسبة
-- Grant Appropriate Permissions
-- =====================================================

-- صلاحيات للقراءة
GRANT SELECT ON homepage_latest_products TO authenticated;
GRANT SELECT ON homepage_latest_vendors TO authenticated;
GRANT SELECT ON homepage_featured_products TO authenticated;
GRANT SELECT ON homepage_featured_vendors TO authenticated;
GRANT SELECT ON homepage_statistics TO authenticated;

-- صلاحيات للدوال
GRANT EXECUTE ON FUNCTION get_latest_products TO authenticated;
GRANT EXECUTE ON FUNCTION get_latest_vendors TO authenticated;
GRANT EXECUTE ON FUNCTION get_featured_products TO authenticated;
GRANT EXECUTE ON FUNCTION get_featured_vendors TO authenticated;
GRANT EXECUTE ON FUNCTION get_homepage_statistics TO authenticated;

-- =====================================================
-- انتهاء سكريبت Views الصفحة الرئيسية المصحح
-- End of Corrected Homepage Views Script
-- =====================================================
