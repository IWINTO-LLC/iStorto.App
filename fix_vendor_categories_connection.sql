-- إصلاح اتصال فئات التجار بالفئات الرئيسية
-- Fix vendor categories connection with major categories

-- 1. إضافة عمود major_category_id إلى جدول vendor_categories
-- Add major_category_id column to vendor_categories table
ALTER TABLE vendor_categories 
ADD COLUMN IF NOT EXISTS major_category_id UUID;

-- 2. إضافة عمود title إذا لم يكن موجوداً
-- Add title column if it doesn't exist
ALTER TABLE vendor_categories 
ADD COLUMN IF NOT EXISTS title TEXT;

-- 3. إضافة فهرس للبحث السريع
-- Add index for fast searching
CREATE INDEX IF NOT EXISTS idx_vendor_categories_major_category 
ON vendor_categories(major_category_id);

CREATE INDEX IF NOT EXISTS idx_vendor_categories_vendor_major 
ON vendor_categories(vendor_id, major_category_id);

-- 4. إضافة قيود المفاتيح الخارجية
-- Add foreign key constraints
ALTER TABLE vendor_categories 
ADD CONSTRAINT fk_vendor_categories_major_category 
FOREIGN KEY (major_category_id) 
REFERENCES major_categories(id) 
ON DELETE CASCADE;

-- 5. إنشاء أو تحديث view للفئات مع التفاصيل
-- Create or update view for categories with details
CREATE OR REPLACE VIEW vendor_categories_with_details AS
SELECT 
    vc.id,
    vc.vendor_id,
    vc.major_category_id,
    vc.title,
    vc.is_primary,
    vc.priority,
    vc.specialization_level,
    vc.custom_description,
    vc.is_active,
    vc.created_at,
    vc.updated_at,
    mc.title as major_category_title,
    mc.icon as major_category_icon,
    mc.color as major_category_color,
    v.organization_name as vendor_name
FROM vendor_categories vc
LEFT JOIN major_categories mc ON vc.major_category_id = mc.id
LEFT JOIN vendors v ON vc.vendor_id = v.id
WHERE vc.is_active = true;

-- 6. إنشاء دالة لإضافة فئة جديدة للتاجر
-- Create function to add new category to vendor
CREATE OR REPLACE FUNCTION add_vendor_category(
    p_vendor_id UUID,
    p_major_category_id UUID,
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
        major_category_id,
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
        p_major_category_id,
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

-- 7. إنشاء دالة للحصول على فئات التاجر مع التفاصيل
-- Create function to get vendor categories with details
CREATE OR REPLACE FUNCTION get_vendor_categories_with_details(p_vendor_id UUID)
RETURNS TABLE (
    id UUID,
    vendor_id UUID,
    major_category_id UUID,
    title TEXT,
    is_primary BOOLEAN,
    priority INTEGER,
    specialization_level INTEGER,
    custom_description TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    major_category_title TEXT,
    major_category_icon TEXT,
    major_category_color TEXT,
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

-- 9. إنشاء سياسات RLS
-- Create RLS policies
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- سياسة للقراءة - يمكن للمستخدمين رؤية فئات التجار النشطة
CREATE POLICY "Users can view active vendor categories" ON vendor_categories
    FOR SELECT USING (is_active = true);

-- سياسة للإدراج - يمكن للتجار إضافة فئات لأنفسهم
CREATE POLICY "Vendors can insert their own categories" ON vendor_categories
    FOR INSERT WITH CHECK (
        vendor_id IN (
            SELECT id FROM vendors 
            WHERE user_id = auth.uid()
        )
    );

-- سياسة للتحديث - يمكن للتجار تحديث فئاتهم
CREATE POLICY "Vendors can update their own categories" ON vendor_categories
    FOR UPDATE USING (
        vendor_id IN (
            SELECT id FROM vendors 
            WHERE user_id = auth.uid()
        )
    );

-- سياسة للحذف - يمكن للتجار حذف فئاتهم
CREATE POLICY "Vendors can delete their own categories" ON vendor_categories
    FOR DELETE USING (
        vendor_id IN (
            SELECT id FROM vendors 
            WHERE user_id = auth.uid()
        )
    );

-- 10. مثال على الاستخدام
-- Usage example
/*
-- إضافة فئة جديدة للتاجر
SELECT add_vendor_category(
    'vendor-uuid-here'::UUID,
    'major-category-uuid-here'::UUID,
    'اسم الفئة المخصص',
    FALSE, -- is_primary
    1,     -- priority
    3,     -- specialization_level
    'وصف مخصص للفئة' -- custom_description
);

-- الحصول على فئات التاجر مع التفاصيل
SELECT * FROM get_vendor_categories_with_details('vendor-uuid-here'::UUID);
*/
