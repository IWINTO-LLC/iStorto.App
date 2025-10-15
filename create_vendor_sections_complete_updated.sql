-- ============================================
-- نظام الأقسام الكامل والمحدث للتجار
-- Complete & Updated Vendor Sections System
-- النسخة: 2.0 (محدثة بجميع الحقول الجديدة)
-- ============================================

-- ============================================
-- الخطوة 1: حذف الجدول القديم إذا كان موجوداً (اختياري)
-- ============================================

-- ⚠️ تحذير: هذا سيحذف جميع البيانات الموجودة!
-- احذف التعليق فقط إذا كنت متأكداً

-- DROP TABLE IF EXISTS public.vendor_sections CASCADE;

-- ============================================
-- الخطوة 2: إنشاء جدول الأقسام الكامل
-- ============================================

CREATE TABLE IF NOT EXISTS public.vendor_sections (
    -- المعرفات الأساسية
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    
    -- معلومات القسم الأساسية
    section_key TEXT NOT NULL,  -- المفتاح الداخلي (مثل: offers, sales, newArrival)
    display_name TEXT NOT NULL,  -- الاسم المعروض بالإنجليزية
    arabic_name TEXT,  -- الاسم المعروض بالعربية
    
    -- إعدادات طريقة العرض
    display_type TEXT DEFAULT 'grid' CHECK (display_type IN ('grid', 'list', 'slider', 'carousel', 'custom')),
    
    -- إعدادات البطاقات
    card_width DOUBLE PRECISION,  -- عرض البطاقة (optional)
    card_height DOUBLE PRECISION,  -- ارتفاع البطاقة (optional)
    items_per_row INTEGER DEFAULT 3,  -- عدد العناصر في الصف
    
    -- حالات القسم
    is_active BOOLEAN DEFAULT TRUE,  -- هل القسم مفعّل؟
    is_visible_to_customers BOOLEAN DEFAULT TRUE,  -- هل يظهر للزبائن؟
    
    -- الترتيب والتنظيم
    sort_order INTEGER DEFAULT 0,  -- ترتيب العرض
    
    -- التخصيص المرئي
    icon_name TEXT,  -- اسم الأيقونة (optional)
    color_hex TEXT,  -- لون القسم بصيغة HEX (optional) مثل: #FF5722
    
    -- التواريخ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- قيد فريد: لا يمكن تكرار نفس القسم لنفس التاجر
    UNIQUE (vendor_id, section_key)
);

-- ============================================
-- الخطوة 3: إنشاء Indexes للأداء الأمثل
-- ============================================

-- Index على vendor_id (الأكثر استخداماً)
CREATE INDEX IF NOT EXISTS idx_vendor_sections_vendor_id 
    ON public.vendor_sections(vendor_id);

-- Index على section_key للبحث السريع
CREATE INDEX IF NOT EXISTS idx_vendor_sections_section_key 
    ON public.vendor_sections(section_key);

-- Index مركب على vendor_id و is_active
CREATE INDEX IF NOT EXISTS idx_vendor_sections_active 
    ON public.vendor_sections(vendor_id, is_active);

-- Index على sort_order للترتيب السريع
CREATE INDEX IF NOT EXISTS idx_vendor_sections_sort_order 
    ON public.vendor_sections(vendor_id, sort_order);

-- Index مركب على vendor_id و is_visible_to_customers
CREATE INDEX IF NOT EXISTS idx_vendor_sections_visible 
    ON public.vendor_sections(vendor_id, is_visible_to_customers);

-- Index على display_type للتصفية
CREATE INDEX IF NOT EXISTS idx_vendor_sections_display_type 
    ON public.vendor_sections(display_type);

-- ============================================
-- الخطوة 4: Functions المساعدة
-- ============================================

-- 4.1: Function لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_vendor_sections_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4.2: Function لإنشاء الأقسام الافتراضية (12 قسم)
CREATE OR REPLACE FUNCTION create_default_vendor_sections(p_vendor_id UUID)
RETURNS void AS $$
BEGIN
    -- إدراج 12 قسم افتراضي
    INSERT INTO public.vendor_sections (
        vendor_id, 
        section_key, 
        display_name, 
        arabic_name, 
        display_type, 
        items_per_row,
        sort_order,
        is_active,
        is_visible_to_customers
    )
    VALUES
        -- 1. العروض
        (p_vendor_id, 'offers', 'Offers', 'العروض', 'grid', 4, 1, true, true),
        
        -- 2. جميع المنتجات
        (p_vendor_id, 'all', 'All Products', 'جميع المنتجات', 'grid', 3, 2, true, true),
        
        -- 3. التخفيضات
        (p_vendor_id, 'sales', 'Sales', 'التخفيضات', 'slider', 1, 3, true, true),
        
        -- 4. الوافد الجديد
        (p_vendor_id, 'newArrival', 'New Arrival', 'الوافد الجديد', 'grid', 3, 4, true, true),
        
        -- 5. المميز
        (p_vendor_id, 'featured', 'Featured', 'المميز', 'grid', 3, 5, true, true),
        
        -- 6. لك خصيصاً
        (p_vendor_id, 'foryou', 'For You', 'لك خصيصاً', 'grid', 4, 6, true, true),
        
        -- 7. جرّب هذا
        (p_vendor_id, 'mixlin1', 'Try This', 'جرّب هذا', 'custom', 2, 7, true, true),
        
        -- 8. عناصر مختلطة
        (p_vendor_id, 'mixone', 'Mix Items', 'عناصر مختلطة', 'slider', 1, 8, true, true),
        
        -- 9. مغامرات
        (p_vendor_id, 'mixlin2', 'Voutures', 'مغامرات', 'grid', 3, 9, true, true),
        
        -- 10. منتجات أ
        (p_vendor_id, 'all1', 'Product A', 'منتجات أ', 'grid', 3, 10, true, true),
        
        -- 11. منتجات ب
        (p_vendor_id, 'all2', 'Product B', 'منتجات ب', 'grid', 3, 11, true, true),
        
        -- 12. منتجات ج
        (p_vendor_id, 'all3', 'Product C', 'منتجات ج', 'grid', 3, 12, true, true)
    
    ON CONFLICT (vendor_id, section_key) DO NOTHING;
    
    RAISE NOTICE 'تم إنشاء الأقسام الافتراضية للتاجر: %', p_vendor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4.3: Function للإنشاء التلقائي عند إضافة تاجر جديد
CREATE OR REPLACE FUNCTION auto_create_vendor_sections()
RETURNS TRIGGER AS $$
BEGIN
    -- استدعاء Function الإنشاء
    PERFORM create_default_vendor_sections(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- الخطوة 5: Triggers
-- ============================================

-- 5.1: Trigger لتحديث updated_at تلقائياً
DROP TRIGGER IF EXISTS trigger_update_vendor_sections_updated_at ON public.vendor_sections;

CREATE TRIGGER trigger_update_vendor_sections_updated_at
    BEFORE UPDATE ON public.vendor_sections
    FOR EACH ROW
    EXECUTE FUNCTION update_vendor_sections_updated_at();

-- 5.2: Trigger لإنشاء الأقسام تلقائياً عند إضافة تاجر جديد
DROP TRIGGER IF EXISTS trigger_auto_create_vendor_sections ON public.vendors;

CREATE TRIGGER trigger_auto_create_vendor_sections
    AFTER INSERT ON public.vendors
    FOR EACH ROW
    EXECUTE FUNCTION auto_create_vendor_sections();

-- ============================================
-- الخطوة 6: Row Level Security (RLS)
-- ============================================

-- تفعيل RLS
ALTER TABLE public.vendor_sections ENABLE ROW LEVEL SECURITY;

-- حذف Policies القديمة
DROP POLICY IF EXISTS "Anyone can view active sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can view their own sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can create their own sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can update their own sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can delete their own sections" ON public.vendor_sections;

-- Policy 1: الجميع يرون الأقسام النشطة والمرئية
CREATE POLICY "Anyone can view active sections"
    ON public.vendor_sections
    FOR SELECT
    USING (is_active = true AND is_visible_to_customers = true);

-- Policy 2: التجار يرون جميع أقسامهم
CREATE POLICY "Vendors can view their own sections"
    ON public.vendor_sections
    FOR SELECT
    USING (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- Policy 3: التجار يمكنهم إنشاء أقسام جديدة
CREATE POLICY "Vendors can create their own sections"
    ON public.vendor_sections
    FOR INSERT
    WITH CHECK (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- Policy 4: التجار يمكنهم تحديث أقسامهم
CREATE POLICY "Vendors can update their own sections"
    ON public.vendor_sections
    FOR UPDATE
    USING (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- Policy 5: التجار يمكنهم حذف أقسامهم
CREATE POLICY "Vendors can delete their own sections"
    ON public.vendor_sections
    FOR DELETE
    USING (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- ============================================
-- الخطوة 7: منح الصلاحيات
-- ============================================

-- صلاحيات الجدول
GRANT SELECT, INSERT, UPDATE, DELETE ON public.vendor_sections TO authenticated;
GRANT SELECT ON public.vendor_sections TO anon;

-- صلاحيات Functions
GRANT EXECUTE ON FUNCTION update_vendor_sections_updated_at() TO authenticated;
GRANT EXECUTE ON FUNCTION create_default_vendor_sections(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION auto_create_vendor_sections() TO authenticated;

-- ============================================
-- الخطوة 8: التعليقات التوضيحية
-- ============================================

COMMENT ON TABLE public.vendor_sections IS 'جدول الأقسام (Sections) لكل تاجر - يحتوي على جميع إعدادات العرض والتخصيص';

COMMENT ON COLUMN public.vendor_sections.id IS 'المعرف الفريد للقسم';
COMMENT ON COLUMN public.vendor_sections.vendor_id IS 'معرف التاجر (Foreign Key)';
COMMENT ON COLUMN public.vendor_sections.section_key IS 'المفتاح الداخلي للقسم (offers, sales, newArrival, etc)';
COMMENT ON COLUMN public.vendor_sections.display_name IS 'الاسم المعروض للزبائن بالإنجليزية';
COMMENT ON COLUMN public.vendor_sections.arabic_name IS 'الاسم المعروض للزبائن بالعربية';
COMMENT ON COLUMN public.vendor_sections.display_type IS 'نوع العرض: grid, list, slider, carousel, custom';
COMMENT ON COLUMN public.vendor_sections.card_width IS 'عرض البطاقة (بالبكسل أو النسبة المئوية)';
COMMENT ON COLUMN public.vendor_sections.card_height IS 'ارتفاع البطاقة';
COMMENT ON COLUMN public.vendor_sections.items_per_row IS 'عدد العناصر في الصف الواحد';
COMMENT ON COLUMN public.vendor_sections.is_active IS 'هل القسم مفعّل؟';
COMMENT ON COLUMN public.vendor_sections.is_visible_to_customers IS 'هل يظهر للزبائن؟';
COMMENT ON COLUMN public.vendor_sections.sort_order IS 'ترتيب العرض في صفحة المتجر';
COMMENT ON COLUMN public.vendor_sections.icon_name IS 'اسم الأيقونة (اختياري)';
COMMENT ON COLUMN public.vendor_sections.color_hex IS 'لون القسم بصيغة HEX (اختياري) - مثل: #FF5722';
COMMENT ON COLUMN public.vendor_sections.created_at IS 'تاريخ الإنشاء';
COMMENT ON COLUMN public.vendor_sections.updated_at IS 'تاريخ آخر تحديث';

COMMENT ON FUNCTION create_default_vendor_sections IS 'ينشئ 12 قسم افتراضي لتاجر معين';
COMMENT ON FUNCTION auto_create_vendor_sections IS 'يتم تشغيلها تلقائياً عند إنشاء تاجر جديد';
COMMENT ON FUNCTION update_vendor_sections_updated_at IS 'تحدث updated_at تلقائياً عند التعديل';

-- ============================================
-- الخطوة 9: اختبار النظام
-- ============================================

-- اختبار 1: التحقق من وجود الجدول
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendor_sections') THEN
        RAISE NOTICE '✅ جدول vendor_sections موجود';
    ELSE
        RAISE EXCEPTION '❌ جدول vendor_sections غير موجود!';
    END IF;
END $$;

-- اختبار 2: عرض عدد الـ Indexes
SELECT 
    tablename,
    COUNT(*) as index_count
FROM pg_indexes
WHERE tablename = 'vendor_sections'
GROUP BY tablename;

-- اختبار 3: عرض الـ Functions
SELECT 
    proname as function_name,
    prokind as kind
FROM pg_proc
WHERE proname LIKE '%vendor_section%'
ORDER BY proname;

-- اختبار 4: عرض الـ Triggers
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE event_object_table IN ('vendor_sections', 'vendors')
    AND trigger_name LIKE '%vendor_section%'
ORDER BY trigger_name;

-- اختبار 5: عرض الـ Policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'vendor_sections'
ORDER BY policyname;

-- ============================================
-- الخطوة 10: إنشاء الأقسام للتجار الموجودين
-- ============================================

-- ⚠️ هذا سينشئ الأقسام لجميع التجار الموجودين
-- احذف التعليق إذا كنت تريد التنفيذ الآن

/*
DO $$
DECLARE
    vendor_record RECORD;
    vendors_count INTEGER := 0;
BEGIN
    FOR vendor_record IN 
        SELECT id, organization_name FROM public.vendors
    LOOP
        PERFORM create_default_vendor_sections(vendor_record.id);
        vendors_count := vendors_count + 1;
        
        RAISE NOTICE 'تم إنشاء الأقسام للتاجر: % (%)', 
            vendor_record.organization_name, 
            vendor_record.id;
    END LOOP;
    
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'إجمالي التجار الذين تم إنشاء أقسام لهم: %', vendors_count;
    RAISE NOTICE '==========================================';
END $$;
*/

-- ============================================
-- الخطوة 11: استعلامات مفيدة
-- ============================================

-- عرض هيكل الجدول الكامل
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'vendor_sections'
ORDER BY ordinal_position;

-- عرض إحصائيات الأقسام
SELECT 
    COUNT(*) as total_sections,
    COUNT(DISTINCT vendor_id) as vendors_with_sections,
    ROUND(AVG(sections_per_vendor)::NUMERIC, 2) as avg_sections_per_vendor
FROM (
    SELECT vendor_id, COUNT(*) as sections_per_vendor
    FROM vendor_sections
    GROUP BY vendor_id
) as stats;

-- ============================================
-- ملاحظات نهائية مهمة
-- ============================================

/*
✅ ما تم إنشاؤه:
1. جدول vendor_sections بـ 17 حقل
2. 6 Indexes للأداء الأمثل
3. 3 Functions (تحديث، إنشاء يدوي، إنشاء تلقائي)
4. 2 Triggers (تحديث التاريخ، إنشاء تلقائي للتجار الجدد)
5. 5 RLS Policies للأمان الكامل
6. تعليقات توضيحية شاملة

📋 الأقسام الافتراضية (12 قسم):
- offers (العروض)
- all (جميع المنتجات)
- sales (التخفيضات)
- newArrival (الوافد الجديد)
- featured (المميز)
- foryou (لك خصيصاً)
- mixlin1 (جرّب هذا)
- mixone (عناصر مختلطة)
- mixlin2 (مغامرات)
- all1 (منتجات أ)
- all2 (منتجات ب)
- all3 (منتجات ج)

🔧 للتجار الجدد:
- يتم إنشاء 12 قسم تلقائياً عند التسجيل (بفضل Trigger)

🔧 للتجار الحاليين:
- شغّل السكريبت في الخطوة 10 أعلاه
- أو شغّل: create_sections_for_existing_vendors.sql

📚 للمزيد من المعلومات:
- راجع: VENDOR_SECTIONS_SYSTEM_GUIDE.md
- راجع: SECTIONS_COMPLETE_SETUP_GUIDE.md
*/

-- ============================================
-- انتهى السكريبت - النظام جاهز! 🎉
-- ============================================

