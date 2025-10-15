-- ============================================
-- نظام الأقسام (Sections/Sectors) للتجار
-- Vendor Sections Management System
-- ============================================

-- 1. إنشاء جدول الأقسام (Sections)
-- ============================================

CREATE TABLE IF NOT EXISTS public.vendor_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    
    -- معلومات القسم
    section_key TEXT NOT NULL,  -- المفتاح الداخلي (مثل: offers, sales, newArrival)
    display_name TEXT NOT NULL,  -- الاسم المعروض للزبائن
    arabic_name TEXT,  -- الاسم بالعربية (اختياري)
    
    -- إعدادات العرض
    display_type TEXT DEFAULT 'grid' CHECK (display_type IN ('grid', 'list', 'slider', 'carousel', 'custom')),
    card_width DOUBLE PRECISION,  -- عرض البطاقة (اختياري)
    card_height DOUBLE PRECISION,  -- ارتفاع البطاقة (اختياري)
    items_per_row INTEGER DEFAULT 3,  -- عدد العناصر في الصف
    
    -- حالة القسم
    is_active BOOLEAN DEFAULT TRUE,
    is_visible_to_customers BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,  -- ترتيب العرض
    
    -- أيقونة ولون
    icon_name TEXT,  -- اسم الأيقونة (اختياري)
    color_hex TEXT,  -- لون القسم (اختياري)
    
    -- تواريخ الإنشاء والتحديث
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- قيد فريد لضمان عدم تكرار القسم لنفس التاجر
    UNIQUE (vendor_id, section_key)
);

-- 2. إنشاء Indexes للأداء
-- ============================================

CREATE INDEX IF NOT EXISTS idx_vendor_sections_vendor_id ON public.vendor_sections(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_sections_section_key ON public.vendor_sections(section_key);
CREATE INDEX IF NOT EXISTS idx_vendor_sections_is_active ON public.vendor_sections(vendor_id, is_active);
CREATE INDEX IF NOT EXISTS idx_vendor_sections_sort_order ON public.vendor_sections(vendor_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_vendor_sections_visible ON public.vendor_sections(vendor_id, is_visible_to_customers);

-- 3. إنشاء Function لتحديث updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_vendor_sections_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. إنشاء Trigger لتحديث updated_at
-- ============================================

DROP TRIGGER IF EXISTS update_vendor_sections_updated_at_trigger ON public.vendor_sections;
CREATE TRIGGER update_vendor_sections_updated_at_trigger
    BEFORE UPDATE ON public.vendor_sections
    FOR EACH ROW
    EXECUTE FUNCTION update_vendor_sections_updated_at();

-- 5. Function لإنشاء الأقسام الافتراضية عند تسجيل تاجر جديد
-- ============================================

CREATE OR REPLACE FUNCTION create_default_vendor_sections(p_vendor_id UUID)
RETURNS void AS $$
BEGIN
    -- إدراج الأقسام الافتراضية
    INSERT INTO public.vendor_sections (vendor_id, section_key, display_name, arabic_name, display_type, sort_order)
    VALUES
        (p_vendor_id, 'offers', 'Offers', 'العروض', 'grid', 1),
        (p_vendor_id, 'all', 'All Products', 'جميع المنتجات', 'grid', 2),
        (p_vendor_id, 'sales', 'Sales', 'التخفيضات', 'slider', 3),
        (p_vendor_id, 'newArrival', 'New Arrival', 'الوافد الجديد', 'grid', 4),
        (p_vendor_id, 'featured', 'Featured', 'المميز', 'grid', 5),
        (p_vendor_id, 'foryou', 'For You', 'لك خصيصاً', 'grid', 6),
        (p_vendor_id, 'mixlin1', 'Try This', 'جرّب هذا', 'custom', 7),
        (p_vendor_id, 'mixone', 'Mix Items', 'عناصر مختلطة', 'slider', 8),
        (p_vendor_id, 'mixlin2', 'Voutures', 'مغامرات', 'grid', 9),
        (p_vendor_id, 'all1', 'Product A', 'منتجات أ', 'grid', 10),
        (p_vendor_id, 'all2', 'Product B', 'منتجات ب', 'grid', 11),
        (p_vendor_id, 'all3', 'Product C', 'منتجات ج', 'grid', 12)
    ON CONFLICT (vendor_id, section_key) DO NOTHING;
    
    RAISE NOTICE 'Default sections created for vendor: %', p_vendor_id;
END;
$$ LANGUAGE plpgsql;

-- 6. تفعيل Row Level Security (RLS)
-- ============================================

ALTER TABLE public.vendor_sections ENABLE ROW LEVEL SECURITY;

-- 7. إنشاء RLS Policies للأقسام
-- ============================================

-- حذف Policies القديمة إن وجدت
DROP POLICY IF EXISTS "Anyone can view active sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can view their own sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can create their own sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can update their own sections" ON public.vendor_sections;
DROP POLICY IF EXISTS "Vendors can delete their own sections" ON public.vendor_sections;

-- Policy: الجميع يمكنهم رؤية الأقسام النشطة والمرئية
CREATE POLICY "Anyone can view active sections"
    ON public.vendor_sections
    FOR SELECT
    USING (is_active = true AND is_visible_to_customers = true);

-- Policy: التجار يمكنهم رؤية جميع أقساهم (حتى غير النشطة)
CREATE POLICY "Vendors can view their own sections"
    ON public.vendor_sections
    FOR SELECT
    USING (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- Policy: التجار يمكنهم إنشاء أقسام جديدة
CREATE POLICY "Vendors can create their own sections"
    ON public.vendor_sections
    FOR INSERT
    WITH CHECK (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- Policy: التجار يمكنهم تحديث أقسامهم
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

-- Policy: التجار يمكنهم حذف أقسامهم
CREATE POLICY "Vendors can delete their own sections"
    ON public.vendor_sections
    FOR DELETE
    USING (
        vendor_id IN (
            SELECT id FROM public.vendors WHERE user_id = auth.uid()
        )
    );

-- 8. منح الصلاحيات
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.vendor_sections TO authenticated;
GRANT SELECT ON public.vendor_sections TO anon;  -- للزبائن غير المسجلين
GRANT EXECUTE ON FUNCTION create_default_vendor_sections(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION update_vendor_sections_updated_at() TO authenticated;

-- 9. إضافة تعليقات توضيحية
-- ============================================

COMMENT ON TABLE public.vendor_sections IS 'جدول الأقسام (Sections) لكل تاجر';
COMMENT ON COLUMN public.vendor_sections.section_key IS 'المفتاح الداخلي للقسم (offers, sales, etc)';
COMMENT ON COLUMN public.vendor_sections.display_name IS 'الاسم المعروض للزبائن بالإنجليزية';
COMMENT ON COLUMN public.vendor_sections.arabic_name IS 'الاسم المعروض للزبائن بالعربية';
COMMENT ON COLUMN public.vendor_sections.display_type IS 'نوع العرض: grid, list, slider, carousel, custom';
COMMENT ON COLUMN public.vendor_sections.sort_order IS 'ترتيب العرض في صفحة المتجر';
COMMENT ON FUNCTION create_default_vendor_sections IS 'دالة لإنشاء الأقسام الافتراضية عند تسجيل تاجر جديد';

-- ============================================
-- انتهى سكريبت إنشاء نظام الأقسام
-- ============================================

-- للاستخدام:
-- 1. بعد إنشاء تاجر جديد، استدعِ:
--    SELECT create_default_vendor_sections('vendor-uuid-here');
--
-- 2. للحصول على أقسام تاجر:
--    SELECT * FROM vendor_sections WHERE vendor_id = 'vendor-uuid' ORDER BY sort_order;
--
-- 3. لتحديث اسم قسم:
--    UPDATE vendor_sections SET display_name = 'New Name' WHERE id = 'section-uuid';
--
-- 4. لتغيير ترتيب الأقسام:
--    UPDATE vendor_sections SET sort_order = 5 WHERE id = 'section-uuid';

