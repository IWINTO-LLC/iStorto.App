-- =====================================================
-- سكريبت إنشاء Views للصفحة الرئيسية
-- Homepage Views Creation Script
-- =====================================================

-- =====================================================
-- 1. View لأحدث المنتجات مع بيانات التاجر والفئة
-- View for Latest Products with Vendor and Category Data
-- =====================================================

CREATE OR REPLACE VIEW homepage_latest_products AS
SELECT 
    -- بيانات المنتج
    p.id as product_id,
    p.name as product_name,
    p.description as product_description,
    p.price,
    p.currency,
    p.stock_quantity,
    p.image as product_image,
    p.tags as product_tags,
    p.brand as product_brand,
    p.model as product_model,
    p.is_active as product_active,
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
        WHEN p.stock_quantity > 10 THEN 'in_stock'
        WHEN p.stock_quantity > 0 THEN 'low_stock'
        ELSE 'out_of_stock'
    END as stock_status,
    
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
        WHEN p.created_at > NOW() - INTERVAL '7 days' THEN 'new'
        WHEN p.created_at > NOW() - INTERVAL '30 days' THEN 'recent'
        ELSE 'old'
    END as product_age_status

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON v.id = vc.vendor_id

WHERE 
    p.is_active = true 
    AND v.is_active = true 
    AND vc.is_active = true
    AND p.stock_quantity > 0  -- فقط المنتجات المتوفرة

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
    COUNT(DISTINCT CASE WHEN p.is_active = true THEN p.id END) as active_products,
    COUNT(DISTINCT CASE WHEN p.stock_quantity > 0 THEN p.id END) as available_products,
    AVG(p.price) as avg_product_price,
    MIN(p.price) as min_product_price,
    MAX(p.price) as max_product_price,
    
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

-- =====================================================
-- 3. View للمنتجات المميزة (عالية الأولوية)
-- View for Featured Products (High Priority)
-- =====================================================

CREATE OR REPLACE VIEW homepage_featured_products AS
SELECT 
    -- بيانات المنتج
    p.id as product_id,
    p.name as product_name,
    p.description as product_description,
    p.price,
    p.currency,
    p.stock_quantity,
    p.image as product_image,
    p.tags as product_tags,
    p.brand as product_brand,
    p.model as product_model,
    p.is_active as product_active,
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
        WHEN p.stock_quantity > 10 THEN 'in_stock'
        WHEN p.stock_quantity > 0 THEN 'low_stock'
        ELSE 'out_of_stock'
    END as stock_status,
    
    -- نقاط الأولوية للعرض
    CASE 
        WHEN vc.sort_order = 1 THEN 100
        WHEN vc.sort_order = 2 THEN 90
        WHEN vc.sort_order <= 5 THEN 80
        WHEN vc.sort_order <= 10 THEN 70
        ELSE 50
    END as display_priority

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON v.id = vc.vendor_id

WHERE 
    p.is_active = true 
    AND v.is_active = true 
    AND vc.is_active = true
    AND p.stock_quantity > 0
    AND vc.sort_order <= 5  -- فقط الفئات عالية الأولوية

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
    COUNT(DISTINCT CASE WHEN p.is_active = true THEN p.id END) as active_products,
    COUNT(DISTINCT CASE WHEN p.stock_quantity > 0 THEN p.id END) as available_products,
    AVG(p.price) as avg_product_price,
    MIN(p.price) as min_product_price,
    MAX(p.price) as max_product_price,
    
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

-- =====================================================
-- 5. View لإحصائيات الصفحة الرئيسية
-- View for Homepage Statistics
-- =====================================================

CREATE OR REPLACE VIEW homepage_statistics AS
SELECT 
    -- إحصائيات المنتجات
    COUNT(DISTINCT p.id) as total_products,
    COUNT(DISTINCT CASE WHEN p.is_active = true THEN p.id END) as active_products,
    COUNT(DISTINCT CASE WHEN p.stock_quantity > 0 THEN p.id END) as available_products,
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
    
    -- إحصائيات المخزون
    SUM(p.stock_quantity) as total_stock_quantity,
    COUNT(DISTINCT CASE WHEN p.stock_quantity > 10 THEN p.id END) as well_stocked_products,
    COUNT(DISTINCT CASE WHEN p.stock_quantity = 0 THEN p.id END) as out_of_stock_products

FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON v.id = vc.vendor_id

WHERE 
    p.is_active = true 
    AND v.is_active = true 
    AND vc.is_active = true;

-- =====================================================
-- 6. إنشاء فهارس لتحسين الأداء
-- Create Indexes for Better Performance
-- =====================================================

-- فهارس على التواريخ للعرض
CREATE INDEX IF NOT EXISTS idx_products_created_at 
ON products (created_at DESC) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_products_updated_at 
ON products (updated_at DESC) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_vendors_created_at 
ON vendors (created_at DESC) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_vendors_updated_at 
ON vendors (updated_at DESC) WHERE is_active = true;

-- فهارس على حالة المخزون
CREATE INDEX IF NOT EXISTS idx_products_stock_quantity 
ON products (stock_quantity) WHERE is_active = true AND stock_quantity > 0;

-- فهارس على ترتيب الفئات
CREATE INDEX IF NOT EXISTS idx_vendor_categories_sort_order 
ON vendor_categories (sort_order) WHERE is_active = true;

-- فهارس مركبة للعرض
CREATE INDEX IF NOT EXISTS idx_products_vendor_active_created 
ON products (vendor_id, is_active, created_at DESC) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_vendors_category_active_created 
ON vendors (id, is_active, created_at DESC) WHERE is_active = true;

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
    product_name TEXT,
    product_description TEXT,
    price DECIMAL,
    currency TEXT,
    stock_quantity INTEGER,
    product_image TEXT,
    vendor_id TEXT,
    vendor_name TEXT,
    vendor_image TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    stock_status TEXT,
    display_priority INTEGER,
    product_age_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hlp.product_id,
        hlp.product_name,
        hlp.product_description,
        hlp.price,
        hlp.currency,
        hlp.stock_quantity,
        hlp.product_image,
        hlp.vendor_id,
        hlp.vendor_name,
        hlp.vendor_image,
        hlp.vendor_category_title,
        hlp.vendor_category_color,
        hlp.vendor_category_icon,
        hlp.stock_status,
        hlp.display_priority,
        hlp.product_age_status
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
    avg_product_price DECIMAL,
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
        hlv.avg_product_price,
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
    product_name TEXT,
    product_description TEXT,
    price DECIMAL,
    currency TEXT,
    stock_quantity INTEGER,
    product_image TEXT,
    vendor_id TEXT,
    vendor_name TEXT,
    vendor_image TEXT,
    vendor_category_title TEXT,
    vendor_category_color TEXT,
    vendor_category_icon TEXT,
    stock_status TEXT,
    display_priority INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hfp.product_id,
        hfp.product_name,
        hfp.product_description,
        hfp.price,
        hfp.currency,
        hfp.stock_quantity,
        hfp.product_image,
        hfp.vendor_id,
        hfp.vendor_name,
        hfp.vendor_image,
        hfp.vendor_category_title,
        hfp.vendor_category_color,
        hfp.vendor_category_icon,
        hfp.stock_status,
        hfp.display_priority
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
    avg_product_price DECIMAL,
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
        hfv.avg_product_price,
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
    total_stock_quantity BIGINT,
    well_stocked_products BIGINT,
    out_of_stock_products BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hs.total_products,
        hs.active_products,
        hs.available_products,
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
        hs.total_stock_quantity,
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
-- انتهاء سكريبت Views الصفحة الرئيسية
-- End of Homepage Views Script
-- =====================================================
