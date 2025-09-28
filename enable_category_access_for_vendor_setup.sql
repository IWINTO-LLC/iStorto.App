-- تمكين الوصول للفئات في إعداد الحساب التجاري
-- Enable Category Access for Vendor Setup

-- 1. التحقق من وجود جدول major_categories
-- Check if major_categories table exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'major_categories') THEN
        -- إنشاء جدول الفئات الرئيسية إذا لم يكن موجوداً
        -- Create major_categories table if it doesn't exist
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
        
        -- إنشاء فهرس للأداء
        -- Create index for performance
        CREATE INDEX idx_major_categories_status ON major_categories(status);
        CREATE INDEX idx_major_categories_parent_id ON major_categories(parent_id);
        
        RAISE NOTICE 'Created major_categories table';
    ELSE
        RAISE NOTICE 'major_categories table already exists';
    END IF;
END $$;

-- 2. تفعيل RLS على جدول major_categories
-- Enable RLS on major_categories table
ALTER TABLE major_categories ENABLE ROW LEVEL SECURITY;

-- 3. حذف السياسات الموجودة (إن وجدت)
-- Drop existing policies (if any)
DROP POLICY IF EXISTS "major_categories_public_read_policy" ON major_categories;
DROP POLICY IF EXISTS "major_categories_authenticated_insert_policy" ON major_categories;
DROP POLICY IF EXISTS "major_categories_authenticated_update_policy" ON major_categories;

-- 4. إنشاء سياسة القراءة العامة للفئات النشطة
-- Create public read policy for active categories
CREATE POLICY "major_categories_public_read_policy" ON major_categories
    FOR SELECT
    USING (status = 1); -- Active categories only

-- 5. إنشاء سياسة الإدراج للمستخدمين المصادق عليهم
-- Create insert policy for authenticated users
CREATE POLICY "major_categories_authenticated_insert_policy" ON major_categories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- 6. إنشاء سياسة التحديث للمستخدمين المصادق عليهم
-- Create update policy for authenticated users
CREATE POLICY "major_categories_authenticated_update_policy" ON major_categories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- 7. التحقق من وجود جدول vendor_major_categories
-- Check if vendor_major_categories table exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendor_major_categories') THEN
        -- إنشاء جدول ربط التاجر بالفئات
        -- Create vendor_major_categories junction table
        CREATE TABLE vendor_major_categories (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
            major_category_id UUID NOT NULL REFERENCES major_categories(id) ON DELETE CASCADE,
            
            -- إعدادات التخصص
            -- Specialization settings
            is_primary BOOLEAN DEFAULT false, -- الفئة الأساسية
            priority INTEGER DEFAULT 0, -- الأولوية (0 = أعلى أولوية)
            specialization_level INTEGER DEFAULT 1, -- مستوى التخصص (1-5)
            custom_description TEXT, -- وصف مخصص
            is_active BOOLEAN DEFAULT true, -- تفعيل/إلغاء التخصص
            
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            
            -- قيود فريدة
            -- Unique constraints
            CONSTRAINT unique_vendor_category UNIQUE(vendor_id, major_category_id),
            CONSTRAINT valid_specialization_level CHECK (specialization_level BETWEEN 1 AND 5)
        );
        
        -- إنشاء فهارس للأداء
        -- Create indexes for performance
        CREATE INDEX idx_vendor_major_categories_vendor_id ON vendor_major_categories(vendor_id);
        CREATE INDEX idx_vendor_major_categories_category_id ON vendor_major_categories(major_category_id);
        CREATE INDEX idx_vendor_major_categories_active ON vendor_major_categories(is_active) WHERE is_active = true;
        CREATE INDEX idx_vendor_major_categories_primary ON vendor_major_categories(is_primary) WHERE is_primary = true;
        
        RAISE NOTICE 'Created vendor_major_categories table';
    ELSE
        RAISE NOTICE 'vendor_major_categories table already exists';
    END IF;
END $$;

-- 8. تفعيل RLS على جدول vendor_major_categories
-- Enable RLS on vendor_major_categories table
ALTER TABLE vendor_major_categories ENABLE ROW LEVEL SECURITY;

-- 9. حذف السياسات الموجودة (إن وجدت)
-- Drop existing policies (if any)
DROP POLICY IF EXISTS "vendor_major_categories_public_read_policy" ON vendor_major_categories;
DROP POLICY IF EXISTS "vendor_major_categories_own_data_read_policy" ON vendor_major_categories;
DROP POLICY IF EXISTS "vendor_major_categories_authenticated_insert_policy" ON vendor_major_categories;
DROP POLICY IF EXISTS "vendor_major_categories_own_data_update_policy" ON vendor_major_categories;
DROP POLICY IF EXISTS "vendor_major_categories_own_data_delete_policy" ON vendor_major_categories;

-- 10. إنشاء سياسة القراءة العامة للفئات النشطة
-- Create public read policy for active specializations
CREATE POLICY "vendor_major_categories_public_read_policy" ON vendor_major_categories
    FOR SELECT
    USING (
        is_active = true
        AND EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.organization_activated = true 
            AND vendors.organization_deleted = false
        )
    );

-- 11. إنشاء سياسة القراءة الخاصة للتاجر
-- Create private read policy for vendor
CREATE POLICY "vendor_major_categories_own_data_read_policy" ON vendor_major_categories
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 12. إنشاء سياسة الإدراج للمستخدمين المصادق عليهم
-- Create insert policy for authenticated users
CREATE POLICY "vendor_major_categories_authenticated_insert_policy" ON vendor_major_categories
    FOR INSERT
    WITH CHECK (
        auth.role() = 'authenticated'
        AND EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 13. إنشاء سياسة التحديث للتاجر
-- Create update policy for vendor
CREATE POLICY "vendor_major_categories_own_data_update_policy" ON vendor_major_categories
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 14. إنشاء سياسة الحذف للتاجر
-- Create delete policy for vendor
CREATE POLICY "vendor_major_categories_own_data_delete_policy" ON vendor_major_categories
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 15. إنشاء دالة للتحقق من فئة أساسية واحدة فقط
-- Create function to ensure single primary category
CREATE OR REPLACE FUNCTION check_single_primary_category()
RETURNS TRIGGER AS $$
BEGIN
    -- إذا تم تعيين is_primary = true
    IF NEW.is_primary = true THEN
        -- تحديث جميع الفئات الأخرى للتاجر إلى is_primary = false
        UPDATE vendor_major_categories 
        SET is_primary = false, updated_at = NOW()
        WHERE vendor_id = NEW.vendor_id 
        AND id != NEW.id 
        AND is_primary = true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 16. إنشاء مشغل للتحقق من الفئة الأساسية
-- Create trigger for primary category check
DROP TRIGGER IF EXISTS trigger_check_single_primary_category ON vendor_major_categories;
CREATE TRIGGER trigger_check_single_primary_category
    BEFORE INSERT OR UPDATE ON vendor_major_categories
    FOR EACH ROW
    EXECUTE FUNCTION check_single_primary_category();

-- 17. إنشاء دالة تحديث updated_at تلقائياً
-- Create auto-update updated_at function
CREATE OR REPLACE FUNCTION update_vendor_major_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 18. إنشاء مشغل تحديث updated_at
-- Create trigger for auto-update updated_at
DROP TRIGGER IF EXISTS trigger_update_vendor_major_categories_updated_at ON vendor_major_categories;
CREATE TRIGGER trigger_update_vendor_major_categories_updated_at
    BEFORE UPDATE ON vendor_major_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_vendor_major_categories_updated_at();

-- 19. إدراج بيانات تجريبية للفئات (اختياري)
-- Insert sample categories (optional)
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
('Office Supplies', 'القرطاسية', false, 1)
ON CONFLICT (name) DO NOTHING;

-- 20. التحقق من الجداول والفهارس
-- Verify tables and indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('vendor_major_categories', 'major_categories')
ORDER BY tablename, indexname;

-- 21. التحقق من السياسات
-- Verify policies
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('vendor_major_categories', 'major_categories')
ORDER BY tablename, policyname;

-- 22. اختبار الوصول
-- Test access
SELECT 
    'major_categories' as table_name,
    COUNT(*) as total_categories,
    COUNT(CASE WHEN status = 1 THEN 1 END) as active_categories
FROM major_categories
UNION ALL
SELECT 
    'vendor_major_categories' as table_name,
    COUNT(*) as total_relations,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_relations
FROM vendor_major_categories;

-- 23. معلومات إضافية
-- Additional information
SELECT 
    'Setup completed successfully!' as message,
    'You can now use the category selection in the commercial account setup' as description;
