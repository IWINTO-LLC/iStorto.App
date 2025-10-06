-- إزالة اتصال فئات التجار بالفئات الرئيسية
-- Remove connection between vendor categories and major categories

-- 1. إزالة قيود المفاتيح الخارجية
-- Remove foreign key constraints
ALTER TABLE vendor_categories 
DROP CONSTRAINT IF EXISTS fk_vendor_categories_major_category;

-- 2. إزالة الفهارس المتعلقة بالفئات الرئيسية
-- Remove indexes related to major categories
DROP INDEX IF EXISTS idx_vendor_categories_major_category;
DROP INDEX IF EXISTS idx_vendor_categories_vendor_major;

-- 3. إزالة عمود major_category_id
-- Remove major_category_id column
ALTER TABLE vendor_categories 
DROP COLUMN IF EXISTS major_category_id;

-- 4. حذف View القديم
-- Drop old view
DROP VIEW IF EXISTS vendor_categories_with_details;

-- 5. إنشاء View جديد بدون الفئات الرئيسية
-- Create new view without major categories
CREATE OR REPLACE VIEW vendor_categories_with_details AS
SELECT 
    vc.id,
    vc.vendor_id,
    vc.title,
    vc.is_primary,
    vc.priority,
    vc.specialization_level,
    vc.custom_description,
    vc.is_active,
    vc.created_at,
    vc.updated_at,
    v.organization_name as vendor_name
FROM vendor_categories vc
LEFT JOIN vendors v ON vc.vendor_id = v.id
WHERE vc.is_active = true;

-- 6. تحديث دالة إضافة فئة جديدة للتاجر
-- Update function to add new category to vendor
CREATE OR REPLACE FUNCTION add_vendor_category(
    p_vendor_id UUID,
    p_title TEXT,
    p_is_primary BOOLEAN DEFAULT FALSE,
    p_priority INTEGER DEFAULT 0,
    p_specialization_level INTEGER DEFAULT 1,
    p_custom_description TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- إدراج فئة جديدة
    INSERT INTO vendor_categories (
        vendor_id,
        title,
        is_primary,
        priority,
        specialization_level,
        custom_description,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        p_vendor_id,
        p_title,
        p_is_primary,
        p_priority,
        p_specialization_level,
        p_custom_description,
        TRUE,
        NOW(),
        NOW()
    ) RETURNING to_json(vendor_categories.*) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. تحديث دالة الحصول على فئات التاجر مع التفاصيل
-- Update function to get vendor categories with details
CREATE OR REPLACE FUNCTION get_vendor_categories_with_details(p_vendor_id UUID)
RETURNS TABLE (
    id UUID,
    vendor_id UUID,
    title TEXT,
    is_primary BOOLEAN,
    priority INTEGER,
    specialization_level INTEGER,
    custom_description TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    vendor_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM vendor_categories_with_details
    WHERE vendor_categories_with_details.vendor_id = p_vendor_id
    ORDER BY 
        vendor_categories_with_details.is_primary DESC,
        vendor_categories_with_details.priority ASC,
        vendor_categories_with_details.created_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. إضافة صلاحيات للمستخدمين
-- Grant permissions to users
GRANT SELECT, INSERT, UPDATE, DELETE ON vendor_categories TO authenticated;
GRANT SELECT ON vendor_categories_with_details TO authenticated;
GRANT EXECUTE ON FUNCTION add_vendor_category TO authenticated;
GRANT EXECUTE ON FUNCTION get_vendor_categories_with_details TO authenticated;

-- 9. مثال على الاستخدام الجديد
-- New usage example
/*
-- إضافة فئة جديدة للتاجر
SELECT add_vendor_category(
    'vendor-uuid-here'::UUID,
    'اسم الفئة المخصص',
    FALSE, -- is_primary
    1,     -- priority
    3,     -- specialization_level
    'وصف مخصص للفئة' -- custom_description
);

-- الحصول على فئات التاجر مع التفاصيل
SELECT * FROM get_vendor_categories_with_details('vendor-uuid-here'::UUID);
*/
