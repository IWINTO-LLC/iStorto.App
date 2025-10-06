-- =====================================================
-- إصلاح آمن لمشكلة عدم ظهور التجار في الفئات
-- Safe Fix for Category Vendors Issue
-- =====================================================

-- 1. فحص هيكل جدول vendor_major_categories
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'vendor_major_categories'
ORDER BY ordinal_position;

-- 2. فحص البيانات الموجودة
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

-- 3. فحص الفئات النشطة الموجودة
SELECT 
    id,
    name,
    arabic_name,
    status,
    is_feature
FROM major_categories
WHERE status = 1
ORDER BY name;

-- 4. فحص التجار المتاحين
SELECT 
    id,
    organization_name,
    is_verified,
    organization_activated
FROM vendors
WHERE organization_deleted = false
ORDER BY organization_name
LIMIT 10;

-- 5. فحص الربط الحالي بين التجار والفئات
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

-- 6. إضافة فئات تجريبية إذا لم تكن موجودة
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

INSERT INTO major_categories (id, name, arabic_name, status, is_feature)
SELECT 
    gen_random_uuid(),
    'Home & Garden',
    'المنزل والحديقة',
    1,
    false
WHERE NOT EXISTS (
    SELECT 1 FROM major_categories WHERE name = 'Home & Garden'
);

-- 7. ربط التجار بالفئات (مع إنشاء ID صحيح)
INSERT INTO vendor_major_categories (
    id, 
    vendor_id, 
    major_category_id, 
    is_primary, 
    priority, 
    specialization_level,
    is_active,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    v.id,
    mc.id,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY v.id ORDER BY v.id) = 1 THEN true ELSE false END,
    ROW_NUMBER() OVER (PARTITION BY v.id ORDER BY v.id),
    CASE 
        WHEN v.is_verified = true THEN 5
        WHEN v.organization_activated = true THEN 4
        ELSE 3
    END,
    true,
    NOW(),
    NOW()
FROM vendors v
CROSS JOIN major_categories mc
WHERE mc.name = 'Electronics'
AND v.organization_deleted = false
AND NOT EXISTS (
    SELECT 1 FROM vendor_major_categories vmc2 
    WHERE vmc2.vendor_id = v.id AND vmc2.major_category_id = mc.id
)
LIMIT 5;

-- ربط تجار بالفئة الثانية
INSERT INTO vendor_major_categories (
    id, 
    vendor_id, 
    major_category_id, 
    is_primary, 
    priority, 
    specialization_level,
    is_active,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    v.id,
    mc.id,
    false,
    2,
    CASE 
        WHEN v.is_verified = true THEN 5
        WHEN v.organization_activated = true THEN 4
        ELSE 3
    END,
    true,
    NOW(),
    NOW()
FROM vendors v
CROSS JOIN major_categories mc
WHERE mc.name = 'Clothing'
AND v.organization_deleted = false
AND NOT EXISTS (
    SELECT 1 FROM vendor_major_categories vmc2 
    WHERE vmc2.vendor_id = v.id AND vmc2.major_category_id = mc.id
)
LIMIT 3;

-- ربط تجار بالفئة الثالثة
INSERT INTO vendor_major_categories (
    id, 
    vendor_id, 
    major_category_id, 
    is_primary, 
    priority, 
    specialization_level,
    is_active,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    v.id,
    mc.id,
    false,
    3,
    CASE 
        WHEN v.is_verified = true THEN 5
        WHEN v.organization_activated = true THEN 4
        ELSE 3
    END,
    true,
    NOW(),
    NOW()
FROM vendors v
CROSS JOIN major_categories mc
WHERE mc.name = 'Home & Garden'
AND v.organization_deleted = false
AND NOT EXISTS (
    SELECT 1 FROM vendor_major_categories vmc2 
    WHERE vmc2.vendor_id = v.id AND vmc2.major_category_id = mc.id
)
LIMIT 2;

-- 8. فحص النتائج بعد الإصلاح
SELECT 
    mc.name as category_name,
    mc.arabic_name,
    COUNT(vmc.id) as vendor_count
FROM major_categories mc
LEFT JOIN vendor_major_categories vmc ON mc.id = vmc.major_category_id AND vmc.is_active = true
WHERE mc.status = 1
GROUP BY mc.id, mc.name, mc.arabic_name
ORDER BY vendor_count DESC;

-- 9. اختبار استعلام التجار للفئة
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

-- 10. إنشاء فهارس لتحسين الأداء (إذا لم تكن موجودة)
CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_category_active 
ON vendor_major_categories (major_category_id, is_active);

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_vendor_active 
ON vendor_major_categories (vendor_id, is_active);

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_priority 
ON vendor_major_categories (priority, specialization_level);

CREATE INDEX IF NOT EXISTS idx_vendors_deleted_activated 
ON vendors (organization_deleted, organization_activated);

CREATE INDEX IF NOT EXISTS idx_major_categories_status 
ON major_categories (status);

-- 11. إعطاء الصلاحيات المناسبة
GRANT SELECT ON vendor_major_categories TO authenticated;
GRANT SELECT ON major_categories TO authenticated;
GRANT SELECT ON vendors TO authenticated;

-- 12. فحص الصلاحيات
SELECT 
    table_name,
    privilege_type
FROM information_schema.table_privileges 
WHERE table_name IN ('vendor_major_categories', 'major_categories', 'vendors')
AND grantee = 'authenticated';

-- 13. عرض عينة من البيانات النهائية
SELECT 
    mc.name as category_name,
    v.organization_name as vendor_name,
    vmc.is_primary,
    vmc.priority,
    vmc.specialization_level,
    v.is_verified
FROM vendor_major_categories vmc
JOIN major_categories mc ON vmc.major_category_id = mc.id
JOIN vendors v ON vmc.vendor_id = v.id
WHERE vmc.is_active = true
ORDER BY mc.name, vmc.priority, vmc.specialization_level DESC
LIMIT 10;

-- =====================================================
-- انتهاء الإصلاح الآمن
-- End of safe fix
-- =====================================================
