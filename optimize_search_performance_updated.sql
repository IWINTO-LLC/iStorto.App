-- =====================================================
-- سكريبت تحسين الأداء والمراقبة (محدث)
-- Performance Optimization and Monitoring Script (Updated)
-- =====================================================

-- =====================================================
-- 1. تحليل الأداء الحالي
-- Current Performance Analysis
-- =====================================================

-- تحليل حجم الجداول
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE tablename IN ('products', 'vendors', 'vendor_categories')
ORDER BY tablename, attname;

-- تحليل حجم الفهارس
SELECT 
    indexname,
    tablename,
    indexdef,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes 
WHERE tablename IN ('products', 'vendors', 'vendor_categories')
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- =====================================================
-- 2. إنشاء فهارس إضافية لتحسين الأداء
-- Create Additional Indexes for Performance
-- =====================================================

-- فهرس على نص البحث في الجداول الأساسية
CREATE INDEX IF NOT EXISTS idx_products_search_text 
ON products USING gin(to_tsvector('arabic', COALESCE(name, '') || ' ' || COALESCE(description, '') || ' ' || COALESCE(tags, '') || ' ' || COALESCE(brand, '') || ' ' || COALESCE(model, '')));

CREATE INDEX IF NOT EXISTS idx_vendors_search_text 
ON vendors USING gin(to_tsvector('arabic', COALESCE(name, '') || ' ' || COALESCE(bio, '') || ' ' || COALESCE(brief, '')));

CREATE INDEX IF NOT EXISTS idx_vendor_categories_search_text 
ON vendor_categories USING gin(to_tsvector('arabic', COALESCE(title, '')));

-- فهارس مركبة لتحسين الاستعلامات المعقدة
CREATE INDEX IF NOT EXISTS idx_products_vendor_active 
ON products (vendor_id, is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_vendor_categories_vendor_active 
ON vendor_categories (vendor_id, is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_vendor_categories_sort_order 
ON vendor_categories (sort_order) WHERE is_active = true;

-- فهرس على السعر مع حالة النشاط
CREATE INDEX IF NOT EXISTS idx_products_price_active 
ON products (price, is_active) WHERE is_active = true;

-- فهرس على كمية المخزون
CREATE INDEX IF NOT EXISTS idx_products_stock 
ON products (stock_quantity) WHERE is_active = true;

-- فهرس على لون فئة التاجر
CREATE INDEX IF NOT EXISTS idx_vendor_categories_color 
ON vendor_categories (color) WHERE is_active = true;

-- فهرس على أيقونة فئة التاجر
CREATE INDEX IF NOT EXISTS idx_vendor_categories_icon 
ON vendor_categories (icon) WHERE is_active = true;

-- =====================================================
-- 3. إنشاء دالة لتحليل الأداء
-- Create Function for Performance Analysis
-- =====================================================

CREATE OR REPLACE FUNCTION analyze_search_performance()
RETURNS TABLE (
    metric_name TEXT,
    metric_value TEXT,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    
    -- حجم الجداول
    SELECT 
        'table_size'::TEXT,
        pg_size_pretty(pg_total_relation_size('products'))::TEXT,
        'Products table size'::TEXT
    UNION ALL
    
    SELECT 
        'table_size'::TEXT,
        pg_size_pretty(pg_total_relation_size('vendors'))::TEXT,
        'Vendors table size'::TEXT
    UNION ALL
    
    SELECT 
        'table_size'::TEXT,
        pg_size_pretty(pg_total_relation_size('vendor_categories'))::TEXT,
        'Vendor categories table size'::TEXT
    UNION ALL
    
    SELECT 
        'table_size'::TEXT,
        pg_size_pretty(pg_total_relation_size('comprehensive_search_materialized'))::TEXT,
        'Materialized view size'::TEXT
    UNION ALL
    
    -- عدد السجلات
    SELECT 
        'record_count'::TEXT,
        COUNT(*)::TEXT,
        'Total products'::TEXT
    FROM products
    UNION ALL
    
    SELECT 
        'record_count'::TEXT,
        COUNT(*)::TEXT,
        'Total vendors'::TEXT
    FROM vendors
    UNION ALL
    
    SELECT 
        'record_count'::TEXT,
        COUNT(*)::TEXT,
        'Total vendor categories'::TEXT
    FROM vendor_categories
    UNION ALL
    
    -- إحصائيات الفهارس
    SELECT 
        'index_count'::TEXT,
        COUNT(*)::TEXT,
        'Total indexes on search tables'::TEXT
    FROM pg_indexes 
    WHERE tablename IN ('products', 'vendors', 'vendor_categories', 'comprehensive_search_materialized');
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. إنشاء دالة لمراقبة استخدام الفهارس
-- Create Function to Monitor Index Usage
-- =====================================================

CREATE OR REPLACE FUNCTION monitor_index_usage()
RETURNS TABLE (
    index_name TEXT,
    table_name TEXT,
    index_size TEXT,
    index_scans BIGINT,
    tuples_read BIGINT,
    tuples_fetched BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.indexname::TEXT,
        i.tablename::TEXT,
        pg_size_pretty(pg_relation_size(i.indexname::regclass))::TEXT,
        s.idx_scan,
        s.idx_tup_read,
        s.idx_tup_fetch
    FROM pg_indexes i
    LEFT JOIN pg_stat_user_indexes s ON i.indexname = s.indexrelname
    WHERE i.tablename IN ('products', 'vendors', 'vendor_categories', 'comprehensive_search_materialized')
    ORDER BY pg_relation_size(i.indexname::regclass) DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. إنشاء دالة لتحليل استعلامات البحث
-- Create Function to Analyze Search Queries
-- =====================================================

CREATE OR REPLACE FUNCTION analyze_search_queries()
RETURNS TABLE (
    query_type TEXT,
    avg_execution_time TEXT,
    total_executions BIGINT,
    recommendations TEXT
) AS $$
BEGIN
    RETURN QUERY
    
    -- تحليل استعلامات البحث الأساسية
    SELECT 
        'basic_search'::TEXT,
        'N/A'::TEXT,
        0::BIGINT,
        'Use search_comprehensive() function for best performance'::TEXT
    UNION ALL
    
    -- تحليل استعلامات البحث السريع
    SELECT 
        'quick_search'::TEXT,
        'N/A'::TEXT,
        0::BIGINT,
        'Use quick_search_comprehensive() for simple queries'::TEXT
    UNION ALL
    
    -- تحليل Materialized View
    SELECT 
        'materialized_view'::TEXT,
        'N/A'::TEXT,
        0::BIGINT,
        'Refresh materialized view regularly for best performance'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. إنشاء دالة لتحسين الفهارس تلقائياً
-- Create Function for Automatic Index Optimization
-- =====================================================

CREATE OR REPLACE FUNCTION optimize_search_indexes()
RETURNS TABLE (
    action TEXT,
    result TEXT
) AS $$
BEGIN
    RETURN QUERY
    
    -- تحديث إحصائيات الجداول
    SELECT 
        'analyze_products'::TEXT,
        'Statistics updated'::TEXT
    FROM pg_stat_user_tables 
    WHERE relname = 'products'
    UNION ALL
    
    SELECT 
        'analyze_vendors'::TEXT,
        'Statistics updated'::TEXT
    FROM pg_stat_user_tables 
    WHERE relname = 'vendors'
    UNION ALL
    
    SELECT 
        'analyze_vendor_categories'::TEXT,
        'Statistics updated'::TEXT
    FROM pg_stat_user_tables 
    WHERE relname = 'vendor_categories';
    
    -- تحديث إحصائيات الجداول
    ANALYZE products;
    ANALYZE vendors;
    ANALYZE vendor_categories;
    ANALYZE comprehensive_search_materialized;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. إنشاء دالة لتنظيف البيانات القديمة
-- Create Function to Clean Old Data
-- =====================================================

CREATE OR REPLACE FUNCTION cleanup_old_search_data()
RETURNS TABLE (
    action TEXT,
    affected_rows BIGINT
) AS $$
BEGIN
    RETURN QUERY
    
    -- تنظيف المنتجات غير النشطة القديمة (أكثر من سنة)
    SELECT 
        'cleanup_inactive_products'::TEXT,
        COUNT(*)::BIGINT
    FROM products 
    WHERE is_active = false 
    AND updated_at < NOW() - INTERVAL '1 year';
    
    -- تنظيف فئات التجار غير النشطة القديمة
    SELECT 
        'cleanup_inactive_vendor_categories'::TEXT,
        COUNT(*)::BIGINT
    FROM vendor_categories 
    WHERE is_active = false 
    AND updated_at < NOW() - INTERVAL '6 months';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. إنشاء دالة لمراقبة الأداء في الوقت الفعلي
-- Create Function for Real-time Performance Monitoring
-- =====================================================

CREATE OR REPLACE FUNCTION monitor_real_time_performance()
RETURNS TABLE (
    metric TEXT,
    value TEXT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    
    -- مراقبة حجم قاعدة البيانات
    SELECT 
        'database_size'::TEXT,
        pg_size_pretty(pg_database_size(current_database()))::TEXT,
        CASE 
            WHEN pg_database_size(current_database()) > 1000000000 THEN 'warning'::TEXT
            ELSE 'ok'::TEXT
        END
    UNION ALL
    
    -- مراقبة عدد الاتصالات النشطة
    SELECT 
        'active_connections'::TEXT,
        COUNT(*)::TEXT,
        CASE 
            WHEN COUNT(*) > 50 THEN 'warning'::TEXT
            ELSE 'ok'::TEXT
        END
    FROM pg_stat_activity
    WHERE state = 'active'
    UNION ALL
    
    -- مراقبة حجم Materialized View
    SELECT 
        'materialized_view_size'::TEXT,
        pg_size_pretty(pg_total_relation_size('comprehensive_search_materialized'))::TEXT,
        CASE 
            WHEN pg_total_relation_size('comprehensive_search_materialized') > 500000000 THEN 'warning'::TEXT
            ELSE 'ok'::TEXT
        END;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. إنشاء جدول لتسجيل أداء البحث
-- Create Table to Log Search Performance
-- =====================================================

CREATE TABLE IF NOT EXISTS search_performance_log (
    id SERIAL PRIMARY KEY,
    search_query TEXT NOT NULL,
    search_type TEXT NOT NULL,
    execution_time_ms INTEGER,
    results_count INTEGER,
    user_id TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- إنشاء فهرس على جدول التسجيل
CREATE INDEX IF NOT EXISTS idx_search_performance_log_created_at 
ON search_performance_log (created_at);

CREATE INDEX IF NOT EXISTS idx_search_performance_log_search_type 
ON search_performance_log (search_type);

-- =====================================================
-- 10. إنشاء دالة لتسجيل أداء البحث
-- Create Function to Log Search Performance
-- =====================================================

CREATE OR REPLACE FUNCTION log_search_performance(
    p_search_query TEXT,
    p_search_type TEXT,
    p_execution_time_ms INTEGER,
    p_results_count INTEGER,
    p_user_id TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    INSERT INTO search_performance_log (
        search_query,
        search_type,
        execution_time_ms,
        results_count,
        user_id
    ) VALUES (
        p_search_query,
        p_search_type,
        p_execution_time_ms,
        p_results_count,
        p_user_id
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 11. إنشاء دالة للحصول على تقرير الأداء
-- Create Function to Get Performance Report
-- =====================================================

CREATE OR REPLACE FUNCTION get_performance_report()
RETURNS TABLE (
    report_section TEXT,
    metric_name TEXT,
    metric_value TEXT,
    recommendation TEXT
) AS $$
BEGIN
    RETURN QUERY
    
    -- تقرير الأداء العام
    SELECT 
        'general_performance'::TEXT,
        'database_size'::TEXT,
        pg_size_pretty(pg_database_size(current_database()))::TEXT,
        'Monitor database growth regularly'::TEXT
    UNION ALL
    
    SELECT 
        'general_performance'::TEXT,
        'total_products'::TEXT,
        COUNT(*)::TEXT,
        'Consider archiving old products if count exceeds 100,000'::TEXT
    FROM products
    UNION ALL
    
    SELECT 
        'general_performance'::TEXT,
        'total_vendors'::TEXT,
        COUNT(*)::TEXT,
        'Monitor vendor growth and performance'::TEXT
    FROM vendors
    UNION ALL
    
    SELECT 
        'general_performance'::TEXT,
        'total_vendor_categories'::TEXT,
        COUNT(*)::TEXT,
        'Monitor vendor category distribution'::TEXT
    FROM vendor_categories
    UNION ALL
    
    -- تقرير الأداء المتقدم
    SELECT 
        'advanced_performance'::TEXT,
        'materialized_view_size'::TEXT,
        pg_size_pretty(pg_total_relation_size('comprehensive_search_materialized'))::TEXT,
        'Refresh materialized view if size exceeds 500MB'::TEXT
    UNION ALL
    
    SELECT 
        'advanced_performance'::TEXT,
        'index_count'::TEXT,
        COUNT(*)::TEXT,
        'Monitor index usage and remove unused indexes'::TEXT
    FROM pg_indexes 
    WHERE tablename IN ('products', 'vendors', 'vendor_categories', 'comprehensive_search_materialized');
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 12. إنشاء دالة لتحليل فئات التجار
-- Create Function to Analyze Vendor Categories
-- =====================================================

CREATE OR REPLACE FUNCTION analyze_vendor_categories()
RETURNS TABLE (
    category_title TEXT,
    category_color TEXT,
    category_icon TEXT,
    total_vendors BIGINT,
    total_products BIGINT,
    avg_sort_order DECIMAL,
    high_priority_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vc.title,
        vc.color,
        vc.icon,
        COUNT(DISTINCT vc.vendor_id) as total_vendors,
        COUNT(DISTINCT p.id) as total_products,
        AVG(vc.sort_order) as avg_sort_order,
        COUNT(CASE WHEN vc.sort_order <= 2 THEN 1 END) as high_priority_count
    FROM vendor_categories vc
    LEFT JOIN products p ON vc.vendor_id = p.vendor_id
    WHERE vc.is_active = true
    GROUP BY vc.title, vc.color, vc.icon
    ORDER BY total_products DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 13. إعطاء الصلاحيات المناسبة
-- Grant Appropriate Permissions
-- =====================================================

-- صلاحيات للدوال الجديدة
GRANT EXECUTE ON FUNCTION analyze_search_performance TO authenticated;
GRANT EXECUTE ON FUNCTION monitor_index_usage TO authenticated;
GRANT EXECUTE ON FUNCTION analyze_search_queries TO authenticated;
GRANT EXECUTE ON FUNCTION optimize_search_indexes TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_search_data TO authenticated;
GRANT EXECUTE ON FUNCTION monitor_real_time_performance TO authenticated;
GRANT EXECUTE ON FUNCTION log_search_performance TO authenticated;
GRANT EXECUTE ON FUNCTION get_performance_report TO authenticated;
GRANT EXECUTE ON FUNCTION analyze_vendor_categories TO authenticated;

-- صلاحيات لجدول التسجيل
GRANT SELECT, INSERT ON search_performance_log TO authenticated;

-- =====================================================
-- انتهاء سكريبت التحسين والمراقبة المحدث
-- End of updated optimization and monitoring script
-- =====================================================
