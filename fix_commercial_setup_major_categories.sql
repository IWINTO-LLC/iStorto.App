-- إصلاح نظام اختيار الفئات في إنشاء الحساب التجاري
-- Fix Category Selection System for Commercial Account Setup

-- 1. إضافة حقل للفئات المختارة في جدول vendors
-- Add selected categories field to vendors table
DO $$
BEGIN
    -- التحقق من وجود الحقل
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendors' 
        AND column_name = 'selected_major_categories'
    ) THEN
        -- إضافة الحقل
        ALTER TABLE vendors 
        ADD COLUMN selected_major_categories TEXT;
        
        RAISE NOTICE 'Added selected_major_categories column to vendors table';
    ELSE
        RAISE NOTICE 'selected_major_categories column already exists in vendors table';
    END IF;
END $$;

-- 2. التحقق من وجود جدول major_categories
-- Check if major_categories table exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'major_categories') THEN
        -- إنشاء جدول الفئات الرئيسية
        -- Create major_categories table
        CREATE TABLE major_categories (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            arabic_name VARCHAR(255),
            image VARCHAR(500),
            is_feature BOOLEAN DEFAULT false,
            status INTEGER DEFAULT 2, -- 1: Active, 2: Pending, 3: Inactive
            parent_id UUID REFERENCES major_categories(id) ON DELETE CASCADE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- إنشاء فهارس للأداء
        -- Create indexes for performance
        CREATE INDEX idx_major_categories_status ON major_categories(status);
        CREATE INDEX idx_major_categories_parent_id ON major_categories(parent_id);
        CREATE INDEX idx_major_categories_feature ON major_categories(is_feature) WHERE is_feature = true;
        
        RAISE NOTICE 'Created major_categories table';
    ELSE
        RAISE NOTICE 'major_categories table already exists';
    END IF;
END $$;

-- 3. تفعيل RLS على جدول major_categories
-- Enable RLS on major_categories table
ALTER TABLE major_categories ENABLE ROW LEVEL SECURITY;

-- 4. حذف السياسات الموجودة (إن وجدت)
-- Drop existing policies (if any)
DROP POLICY IF EXISTS "major_categories_public_read_policy" ON major_categories;
DROP POLICY IF EXISTS "major_categories_authenticated_insert_policy" ON major_categories;
DROP POLICY IF EXISTS "major_categories_authenticated_update_policy" ON major_categories;

-- 5. إنشاء سياسة القراءة العامة للفئات النشطة
-- Create public read policy for active categories
CREATE POLICY "major_categories_public_read_policy" ON major_categories
    FOR SELECT
    USING (status = 1); -- Active categories only

-- 6. إنشاء سياسة الإدراج للمستخدمين المصادق عليهم (للإدارة)
-- Create insert policy for authenticated users (for admin)
CREATE POLICY "major_categories_authenticated_insert_policy" ON major_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- 7. إنشاء سياسة التحديث للمستخدمين المصادق عليهم (للإدارة)
-- Create update policy for authenticated users (for admin)
CREATE POLICY "major_categories_authenticated_update_policy" ON major_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- 8. إدراج بيانات تجريبية للفئات العامة
-- Insert sample general categories
INSERT INTO major_categories (name, arabic_name, is_feature, status) VALUES
('Electronics', 'إلكترونيات', true, 1),
('Fashion', 'أزياء', true, 1),
('Home & Garden', 'المنزل والحديقة', false, 1),
('Sports', 'رياضة', false, 1),
('Books', 'كتب', false, 1),
('Health & Beauty', 'الصحة والجمال', false, 1),
('Automotive', 'السيارات', false, 1),
('Food & Beverage', 'الطعام والشراب', false, 1),
('Toys & Games', 'الألعاب', false, 1),
('Office Supplies', 'القرطاسية', false, 1),
('Jewelry', 'المجوهرات', false, 1),
('Pet Supplies', 'مستلزمات الحيوانات الأليفة', false, 1),
('Musical Instruments', 'الآلات الموسيقية', false, 1),
('Art & Crafts', 'الفنون والحرف', false, 1),
('Travel', 'السفر', false, 1)
ON CONFLICT (name) DO NOTHING;

-- 9. إنشاء دالة للحصول على الفئات النشطة
-- Create function to get active categories
CREATE OR REPLACE FUNCTION get_active_major_categories()
RETURNS TABLE (
    id UUID,
    name VARCHAR(255),
    arabic_name VARCHAR(255),
    image VARCHAR(500),
    is_feature BOOLEAN,
    status INTEGER,
    parent_id UUID,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mc.id,
        mc.name,
        mc.arabic_name,
        mc.image,
        mc.is_feature,
        mc.status,
        mc.parent_id,
        mc.created_at
    FROM major_categories mc
    WHERE mc.status = 1
    ORDER BY mc.is_feature DESC, mc.name ASC;
END;
$$ LANGUAGE plpgsql;

-- 10. إنشاء دالة للحصول على فئات التاجر المختارة
-- Create function to get vendor's selected categories
CREATE OR REPLACE FUNCTION get_vendor_selected_categories(p_vendor_id UUID)
RETURNS TABLE (
    id UUID,
    name VARCHAR(255),
    arabic_name VARCHAR(255),
    image VARCHAR(500),
    is_feature BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mc.id,
        mc.name,
        mc.arabic_name,
        mc.image,
        mc.is_feature
    FROM vendors v
    JOIN major_categories mc ON mc.id::text = ANY(string_to_array(v.selected_major_categories, ','))
    WHERE v.id = p_vendor_id
    AND mc.status = 1
    ORDER BY mc.is_feature DESC, mc.name ASC;
END;
$$ LANGUAGE plpgsql;

-- 11. إنشاء دالة لتحديث فئات التاجر المختارة
-- Create function to update vendor's selected categories
CREATE OR REPLACE FUNCTION update_vendor_selected_categories(
    p_vendor_id UUID,
    p_selected_categories TEXT
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE vendors 
    SET 
        selected_major_categories = p_selected_categories,
        updated_at = NOW()
    WHERE id = p_vendor_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- 12. التحقق من الجداول والفهارس
-- Verify tables and indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'major_categories'
ORDER BY indexname;

-- 13. التحقق من السياسات
-- Verify policies
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'major_categories'
ORDER BY policyname;

-- 14. اختبار الوصول للفئات
-- Test category access
SELECT 
    'major_categories' as table_name,
    COUNT(*) as total_categories,
    COUNT(CASE WHEN status = 1 THEN 1 END) as active_categories,
    COUNT(CASE WHEN is_feature = true AND status = 1 THEN 1 END) as featured_categories
FROM major_categories;

-- 15. عرض الفئات النشطة
-- Display active categories
SELECT 
    id,
    name,
    arabic_name,
    is_feature,
    CASE 
        WHEN is_feature = true THEN 'مميز'
        ELSE 'عادي'
    END as category_type
FROM major_categories 
WHERE status = 1
ORDER BY is_feature DESC, name ASC;

-- 16. معلومات إضافية
-- Additional information
SELECT 
    'Category selection system setup completed successfully!' as message,
    'Vendors can now select from general categories during commercial account setup' as description,
    'selected_major_categories field added to vendors table' as note1,
    'major_categories table ready with sample data' as note2,
    'Public read access enabled for active categories' as note3;
