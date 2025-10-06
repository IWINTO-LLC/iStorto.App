-- =====================================================
-- إصلاح مشكلة عدم ظهور التجار في الفئات
-- Fix Category Vendors Issue
-- =====================================================

-- 1. فحص البيانات الموجودة
SELECT 
    'Major Categories' as table_name,
    COUNT(*) as total_records
FROM major_categories

UNION ALL

SELECT 
    'Vendor Major Categories' as table_name,
    COUNT(*) as total_records
FROM vendor_major_categories

UNION ALL

SELECT 
    'Vendors' as table_name,
    COUNT(*) as total_records
FROM vendors;

-- 2. فحص الفئات النشطة
SELECT 
    id,
    name,
    arabic_name,
    status,
    is_feature
FROM major_categories
WHERE status = 1
ORDER BY name;

-- 3. فحص ربط التجار بالفئات
SELECT 
    vmc.id,
    mc.name as category_name,
    v.organization_name as vendor_name,
    vmc.is_primary,
    vmc.priority,
    vmc.is_active
FROM vendor_major_categories vmc
JOIN major_categories mc ON vmc.major_category_id = mc.id
JOIN vendors v ON vmc.vendor_id = v.id
WHERE vmc.is_active = true
ORDER BY mc.name, vmc.priority;

-- 4. إضافة بيانات تجريبية للتجار والفئات (إذا لم تكن موجودة)
-- Add sample data if not exists

-- إضافة فئة تجريبية
INSERT INTO major_categories (id, name, arabic_name, status, is_feature)
SELECT 
    gen_random_uuid(),
    'Electronics',
    'إلكترونيات',
    1,
    true
WHERE NOT EXISTS (
    SELECT 1 FROM major_categories WHERE name = 'Electronics'
);

-- إضافة فئة أخرى
INSERT INTO major_categories (id, name, arabic_name, status, is_feature)
SELECT 
    gen_random_uuid(),
    'Clothing',
    'ملابس',
    1,
    false
WHERE NOT EXISTS (
    SELECT 1 FROM major_categories WHERE name = 'Clothing'
);

-- 5. ربط تجار موجودين بالفئات (إذا لم يكن الربط موجود)
INSERT INTO vendor_major_categories (id, vendor_id, major_category_id, is_primary, priority, is_active)
SELECT 
    gen_random_uuid(),
    v.id,
    mc.id,
    true,
    1,
    true
FROM vendors v
CROSS JOIN major_categories mc
WHERE mc.name = 'Electronics'
AND NOT EXISTS (
    SELECT 1 FROM vendor_major_categories vmc2 
    WHERE vmc2.vendor_id = v.id AND vmc2.major_category_id = mc.id
)
LIMIT 5;

-- ربط تجار بالفئة الثانية
INSERT INTO vendor_major_categories (id, vendor_id, major_category_id, is_primary, priority, is_active)
SELECT 
    gen_random_uuid(),
    v.id,
    mc.id,
    false,
    2,
    true
FROM vendors v
CROSS JOIN major_categories mc
WHERE mc.name = 'Clothing'
AND NOT EXISTS (
    SELECT 1 FROM vendor_major_categories vmc2 
    WHERE vmc2.vendor_id = v.id AND vmc2.major_category_id = mc.id
)
LIMIT 3;

-- 6. فحص النتائج بعد الإصلاح
SELECT 
    mc.name as category_name,
    mc.arabic_name,
    COUNT(vmc.id) as vendor_count
FROM major_categories mc
LEFT JOIN vendor_major_categories vmc ON mc.id = vmc.major_category_id AND vmc.is_active = true
WHERE mc.status = 1
GROUP BY mc.id, mc.name, mc.arabic_name
ORDER BY vendor_count DESC;

-- 7. اختبار استعلام التجار للفئة
SELECT 
    vmc.id,
    v.organization_name,
    v.organization_logo,
    v.is_verified,
    vmc.is_primary,
    vmc.priority,
    vmc.specialization_level
FROM vendor_major_categories vmc
JOIN vendors v ON vmc.vendor_id = v.id
JOIN major_categories mc ON vmc.major_category_id = mc.id
WHERE mc.name = 'Electronics'
AND vmc.is_active = true
ORDER BY vmc.priority, vmc.specialization_level DESC;

-- 8. إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_category_active 
ON vendor_major_categories (major_category_id, is_active);

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_vendor_active 
ON vendor_major_categories (vendor_id, is_active);

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_priority 
ON vendor_major_categories (priority, specialization_level);

-- 9. إعطاء الصلاحيات المناسبة
GRANT SELECT ON vendor_major_categories TO authenticated;
GRANT SELECT ON major_categories TO authenticated;
GRANT SELECT ON vendors TO authenticated;

-- 10. فحص الصلاحيات
SELECT 
    table_name,
    privilege_type
FROM information_schema.table_privileges 
WHERE table_name IN ('vendor_major_categories', 'major_categories', 'vendors')
AND grantee = 'authenticated';

-- =====================================================
-- انتهاء الإصلاح
-- End of fix
-- =====================================================
