-- تصميم نظام فئات متعدد للتجار (Many-to-Many)
-- Vendor Category Many-to-Many Relationship Design

-- 1. جدول الفئات الرئيسية (Major Categories) - موجود بالفعل
-- Major Categories Table (already exists)

CREATE TABLE IF NOT EXISTS major_categories (
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

-- 2. جدول ربط التاجر بالفئات (Vendor Category Junction Table)
-- Vendor Category Junction Table (Many-to-Many)

CREATE TABLE IF NOT EXISTS vendor_major_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    major_category_id UUID NOT NULL REFERENCES major_categories(id) ON DELETE CASCADE,
    
    -- إعدادات إضافية للتخصص
    -- Additional specialization settings
    is_primary BOOLEAN DEFAULT false, -- الفئة الأساسية للتاجر
    priority INTEGER DEFAULT 0, -- أولوية الفئة (0 = أعلى أولوية)
    specialization_level INTEGER DEFAULT 1, -- مستوى التخصص (1-5)
    custom_description TEXT, -- وصف مخصص للتاجر في هذه الفئة
    is_active BOOLEAN DEFAULT true, -- تفعيل/إلغاء تفعيل التخصص
    
    -- تواريخ
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- قيود فريدة
    -- Unique constraints
    CONSTRAINT unique_vendor_category UNIQUE(vendor_id, major_category_id),
    
    -- فهارس
    -- Indexes
    CONSTRAINT valid_priority CHECK (priority >= 0),
    CONSTRAINT valid_specialization_level CHECK (specialization_level BETWEEN 1 AND 5)
);

-- 3. فهارس للأداء
-- Performance Indexes

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_vendor_id 
    ON vendor_major_categories(vendor_id);

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_category_id 
    ON vendor_major_categories(major_category_id);

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_active 
    ON vendor_major_categories(is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_primary 
    ON vendor_major_categories(is_primary) WHERE is_primary = true;

CREATE INDEX IF NOT EXISTS idx_vendor_major_categories_priority 
    ON vendor_major_categories(priority);

-- 4. دالة تحديث updated_at تلقائياً
-- Auto-update updated_at function

CREATE OR REPLACE FUNCTION update_vendor_major_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- تشغيل الدالة عند التحديث
-- Trigger for auto-update
CREATE TRIGGER trigger_update_vendor_major_categories_updated_at
    BEFORE UPDATE ON vendor_major_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_vendor_major_categories_updated_at();

-- 5. قيود RLS (Row Level Security)
-- RLS Policies

ALTER TABLE vendor_major_categories ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: السماح لجميع المستخدمين بقراءة التخصصات النشطة
-- Read policy: Allow all users to read active specializations
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

-- سياسة القراءة الخاصة: السماح للتاجر بقراءة تخصصاته الخاصة
-- Private read policy: Allow vendors to read their own specializations
CREATE POLICY "vendor_major_categories_own_data_read_policy" ON vendor_major_categories
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- سياسة الإدراج: السماح للتاجر بإضافة تخصصات جديدة
-- Insert policy: Allow vendors to add new specializations
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

-- سياسة التحديث: السماح للتاجر بتحديث تخصصاته الخاصة
-- Update policy: Allow vendors to update their own specializations
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

-- سياسة الحذف: السماح للتاجر بحذف تخصصاته الخاصة
-- Delete policy: Allow vendors to delete their own specializations
CREATE POLICY "vendor_major_categories_own_data_delete_policy" ON vendor_major_categories
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM vendors 
            WHERE vendors.id = vendor_major_categories.vendor_id 
            AND vendors.user_id = auth.uid()::text
        )
    );

-- 6. دالة للتحقق من أن التاجر لديه فئة أساسية واحدة فقط
-- Function to ensure vendor has only one primary category

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

-- تشغيل الدالة عند الإدراج أو التحديث
-- Trigger for single primary category check
CREATE TRIGGER trigger_check_single_primary_category
    BEFORE INSERT OR UPDATE ON vendor_major_categories
    FOR EACH ROW
    EXECUTE FUNCTION check_single_primary_category();

-- 7. دالة للحصول على فئات التاجر مع التفاصيل
-- Function to get vendor categories with details

CREATE OR REPLACE FUNCTION get_vendor_categories_with_details(p_vendor_id UUID)
RETURNS TABLE (
    category_id UUID,
    category_name VARCHAR(255),
    category_arabic_name VARCHAR(255),
    category_image VARCHAR(500),
    is_primary BOOLEAN,
    priority INTEGER,
    specialization_level INTEGER,
    custom_description TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mc.id,
        mc.name,
        mc.arabic_name,
        mc.image,
        vmc.is_primary,
        vmc.priority,
        vmc.specialization_level,
        vmc.custom_description,
        vmc.is_active,
        vmc.created_at
    FROM vendor_major_categories vmc
    JOIN major_categories mc ON vmc.major_category_id = mc.id
    WHERE vmc.vendor_id = p_vendor_id
    AND vmc.is_active = true
    ORDER BY vmc.is_primary DESC, vmc.priority ASC, vmc.created_at ASC;
END;
$$ LANGUAGE plpgsql;

-- 8. دالة لإضافة فئة جديدة للتاجر
-- Function to add new category to vendor

CREATE OR REPLACE FUNCTION add_vendor_category(
    p_vendor_id UUID,
    p_major_category_id UUID,
    p_is_primary BOOLEAN DEFAULT false,
    p_priority INTEGER DEFAULT 0,
    p_specialization_level INTEGER DEFAULT 1,
    p_custom_description TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_new_id UUID;
BEGIN
    -- إدراج العلاقة الجديدة
    INSERT INTO vendor_major_categories (
        vendor_id,
        major_category_id,
        is_primary,
        priority,
        specialization_level,
        custom_description
    ) VALUES (
        p_vendor_id,
        p_major_category_id,
        p_is_primary,
        p_priority,
        p_specialization_level,
        p_custom_description
    ) RETURNING id INTO v_new_id;
    
    RETURN v_new_id;
END;
$$ LANGUAGE plpgsql;

-- 9. دالة لإزالة فئة من التاجر
-- Function to remove category from vendor

CREATE OR REPLACE FUNCTION remove_vendor_category(
    p_vendor_id UUID,
    p_major_category_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM vendor_major_categories 
    WHERE vendor_id = p_vendor_id 
    AND major_category_id = p_major_category_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- 10. دالة لتحديث أولوية الفئات
-- Function to update category priorities

CREATE OR REPLACE FUNCTION update_vendor_category_priorities(
    p_vendor_id UUID,
    p_category_priorities JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    category_item JSONB;
BEGIN
    -- تحديث أولويات الفئات
    FOR category_item IN SELECT * FROM jsonb_array_elements(p_category_priorities)
    LOOP
        UPDATE vendor_major_categories 
        SET 
            priority = (category_item->>'priority')::INTEGER,
            updated_at = NOW()
        WHERE vendor_id = p_vendor_id 
        AND major_category_id = (category_item->>'major_category_id')::UUID;
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 11. عرض لإحصائيات التخصصات
-- View for specialization statistics

CREATE OR REPLACE VIEW vendor_category_stats AS
SELECT 
    v.id as vendor_id,
    v.organization_name,
    COUNT(vmc.id) as total_categories,
    COUNT(CASE WHEN vmc.is_primary = true THEN 1 END) as primary_categories,
    COUNT(CASE WHEN vmc.is_active = true THEN 1 END) as active_categories,
    MAX(vmc.specialization_level) as max_specialization_level,
    MIN(vmc.priority) as min_priority,
    MAX(vmc.priority) as max_priority
FROM vendors v
LEFT JOIN vendor_major_categories vmc ON v.id = vmc.vendor_id
WHERE v.organization_activated = true 
AND v.organization_deleted = false
GROUP BY v.id, v.organization_name;

-- 12. إدراج بيانات تجريبية (اختياري)
-- Sample data insertion (optional)

-- إدراج فئات رئيسية تجريبية
-- INSERT INTO major_categories (name, arabic_name, is_feature, status) VALUES
-- ('Electronics', 'إلكترونيات', true, 1),
-- ('Fashion', 'أزياء', true, 1),
-- ('Home & Garden', 'المنزل والحديقة', false, 1),
-- ('Sports', 'رياضة', false, 1),
-- ('Books', 'كتب', false, 1);

-- 13. التحقق من الجداول والفهارس
-- Verify tables and indexes

SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('vendor_major_categories', 'major_categories')
ORDER BY tablename, indexname;

-- 14. التحقق من السياسات
-- Verify policies

SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'vendor_major_categories'
ORDER BY policyname;
