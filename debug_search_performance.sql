-- =====================================================
-- تحليل أداء البحث وتشخيص المشاكل
-- Search Performance Analysis and Debugging
-- =====================================================

-- 1. فحص عدد السجلات في الـ view
-- Check record count in the view
SELECT 
    'comprehensive_search_view' as table_name,
    COUNT(*) as total_records
FROM comprehensive_search_view;

-- 2. فحص عدد السجلات في الجداول الأساسية
-- Check record count in base tables
SELECT 'products' as table_name, COUNT(*) as total_records FROM products WHERE is_deleted = false
UNION ALL
SELECT 'vendors' as table_name, COUNT(*) as total_records FROM vendors
UNION ALL
SELECT 'vendor_categories' as table_name, COUNT(*) as total_records FROM vendor_categories;

-- 3. فحص الفهارس الموجودة
-- Check existing indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('products', 'vendors', 'vendor_categories', 'comprehensive_search_view')
ORDER BY tablename, indexname;

-- 4. تحليل خطة التنفيذ للاستعلام البطيء
-- Analyze execution plan for slow query
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) 
SELECT * FROM comprehensive_search_view 
WHERE search_text ILIKE '%test%' 
LIMIT 20;

-- 5. فحص حجم البيانات في كل جدول
-- Check data size for each table
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE tablename IN ('products', 'vendors', 'vendor_categories')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 6. فحص الـ JOINs المعقدة
-- Check complex JOINs
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    p.id,
    p.title,
    v.organization_name,
    vc.title
FROM products p
LEFT JOIN vendors v ON p.vendor_id = v.id
LEFT JOIN vendor_categories vc ON p.vendor_category_id = vc.id
WHERE p.is_deleted = false;

-- 7. فحص استخدام الفهارس
-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE tablename IN ('products', 'vendors', 'vendor_categories')
ORDER BY idx_tup_read DESC;

-- 8. فحص الاستعلامات البطيئة
-- Check slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements 
WHERE query LIKE '%comprehensive_search_view%'
ORDER BY mean_time DESC
LIMIT 10;

-- 9. فحص إحصائيات الجداول
-- Check table statistics
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_tuples,
    n_dead_tup as dead_tuples,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables 
WHERE tablename IN ('products', 'vendors', 'vendor_categories')
ORDER BY n_live_tup DESC;

-- 10. فحص المشاكل المحتملة في الـ view
-- Check potential issues in the view
SELECT 
    'Missing vendor_id' as issue,
    COUNT(*) as count
FROM comprehensive_search_view 
WHERE vendor_id IS NULL

UNION ALL

SELECT 
    'Missing vendor_category_id' as issue,
    COUNT(*) as count
FROM comprehensive_search_view 
WHERE vendor_category_vc_id IS NULL

UNION ALL

SELECT 
    'Empty search_text' as issue,
    COUNT(*) as count
FROM comprehensive_search_view 
WHERE search_text IS NULL OR search_text = '';

-- 11. اختبار البحث مع فهارس مختلفة
-- Test search with different indexes

-- اختبار البحث بدون فهارس
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM comprehensive_search_view 
WHERE search_text ILIKE '%منتج%' 
LIMIT 10;

-- 12. فحص إعدادات PostgreSQL
-- Check PostgreSQL settings
SELECT name, setting, unit, context 
FROM pg_settings 
WHERE name IN (
    'shared_buffers',
    'work_mem',
    'maintenance_work_mem',
    'effective_cache_size',
    'random_page_cost',
    'seq_page_cost'
);

-- 13. فحص الجداول الكبيرة
-- Check large tables
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE tablename IN ('products', 'vendors', 'vendor_categories')
AND n_distinct > 100
ORDER BY n_distinct DESC;

-- =====================================================
-- انتهاء التحليل
-- End of analysis
-- =====================================================
