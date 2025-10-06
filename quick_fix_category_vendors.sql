-- =====================================================
-- إصلاح سريع لمشكلة عدم ظهور التجار في الفئات
-- Quick Fix for Category Vendors Issue
-- =====================================================

-- 1. إضافة فئات تجريبية إذا لم تكن موجودة
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

-- 2. ربط التجار بالفئات (مع إنشاء ID صحيح)
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
    true,
    1,
    5,
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
LIMIT 3;

-- 3. ربط تجار بالفئة الثانية
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
    4,
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
LIMIT 2;

-- 4. فحص النتائج
SELECT 
    mc.name as category_name,
    mc.arabic_name,
    COUNT(vmc.id) as vendor_count
FROM major_categories mc
LEFT JOIN vendor_major_categories vmc ON mc.id = vmc.major_category_id AND vmc.is_active = true
WHERE mc.status = 1
GROUP BY mc.id, mc.name, mc.arabic_name
ORDER BY vendor_count DESC;

-- 5. عرض عينة من البيانات
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
ORDER BY mc.name, vmc.priority
LIMIT 10;
