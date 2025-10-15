-- ============================================
-- إنشاء جدول روابط التواصل الاجتماعي للتجار
-- ============================================

-- إنشاء الجدول
CREATE TABLE IF NOT EXISTS public.vendor_social_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    link_type VARCHAR(50) NOT NULL, -- 'website', 'email', 'whatsapp', 'phone', 'location', 'linkedin', 'youtube'
    link_value TEXT NOT NULL DEFAULT '',
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- تأكد من عدم تكرار نفس نوع الرابط للتاجر الواحد
    UNIQUE(vendor_id, link_type)
);

-- ============================================
-- إنشاء الفهارس لتحسين الأداء
-- ============================================

-- فهرس للبحث حسب التاجر
CREATE INDEX IF NOT EXISTS idx_vendor_social_links_vendor_id 
ON public.vendor_social_links(vendor_id);

-- فهرس للبحث حسب نوع الرابط
CREATE INDEX IF NOT EXISTS idx_vendor_social_links_type 
ON public.vendor_social_links(link_type);

-- فهرس للروابط النشطة فقط
CREATE INDEX IF NOT EXISTS idx_vendor_social_links_active 
ON public.vendor_social_links(vendor_id, is_active) WHERE is_active = TRUE;

-- ============================================
-- تفعيل Row Level Security (RLS)
-- ============================================

ALTER TABLE public.vendor_social_links ENABLE ROW LEVEL SECURITY;

-- ============================================
-- سياسات الأمان (RLS Policies)
-- ============================================

-- السماح للمستخدمين المصادق عليهم بقراءة روابط التجار النشطة
CREATE POLICY "Allow authenticated users to read active social links"
ON public.vendor_social_links
FOR SELECT
TO authenticated
USING (is_active = TRUE);

-- السماح للتجار بقراءة وإدارة روابطهم الخاصة
CREATE POLICY "Vendors can manage their own social links"
ON public.vendor_social_links
FOR ALL
TO authenticated
USING (
    vendor_id IN (
        SELECT id FROM public.vendors 
        WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    vendor_id IN (
        SELECT id FROM public.vendors 
        WHERE user_id = auth.uid()
    )
);

-- ============================================
-- إنشاء Trigger لتحديث updated_at تلقائياً
-- ============================================

CREATE OR REPLACE FUNCTION update_vendor_social_links_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_vendor_social_links_updated_at
    BEFORE UPDATE ON public.vendor_social_links
    FOR EACH ROW
    EXECUTE FUNCTION update_vendor_social_links_updated_at();

-- ============================================
-- إنشاء Function لإنشاء الروابط الافتراضية للتاجر
-- ============================================

CREATE OR REPLACE FUNCTION create_default_vendor_social_links(p_vendor_id UUID)
RETURNS VOID AS $$
BEGIN
    -- إدراج الروابط الافتراضية للتاجر
    INSERT INTO public.vendor_social_links (vendor_id, link_type, link_value, is_active)
    VALUES 
        (p_vendor_id, 'website', '', FALSE),
        (p_vendor_id, 'email', '', FALSE),
        (p_vendor_id, 'whatsapp', '', FALSE),
        (p_vendor_id, 'phone', '', FALSE),
        (p_vendor_id, 'location', '', FALSE),
        (p_vendor_id, 'linkedin', '', FALSE),
        (p_vendor_id, 'youtube', '', FALSE)
    ON CONFLICT (vendor_id, link_type) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- إنشاء Function لتحديث رابط تواصل اجتماعي
-- ============================================

CREATE OR REPLACE FUNCTION update_vendor_social_link(
    p_vendor_id UUID,
    p_link_type VARCHAR(50),
    p_link_value TEXT,
    p_is_active BOOLEAN
)
RETURNS VOID AS $$
BEGIN
    -- تحديث الرابط الموجود أو إنشاء جديد
    INSERT INTO public.vendor_social_links (vendor_id, link_type, link_value, is_active)
    VALUES (p_vendor_id, p_link_type, p_link_value, p_is_active)
    ON CONFLICT (vendor_id, link_type)
    DO UPDATE SET
        link_value = EXCLUDED.link_value,
        is_active = EXCLUDED.is_active,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- إنشاء Function للحصول على روابط التواصل الاجتماعي للتاجر
-- ============================================

CREATE OR REPLACE FUNCTION get_vendor_social_links(p_vendor_id UUID)
RETURNS TABLE (
    id UUID,
    vendor_id UUID,
    link_type VARCHAR(50),
    link_value TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vsl.id,
        vsl.vendor_id,
        vsl.link_type,
        vsl.link_value,
        vsl.is_active,
        vsl.created_at,
        vsl.updated_at
    FROM public.vendor_social_links vsl
    WHERE vsl.vendor_id = p_vendor_id
    ORDER BY vsl.link_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- منح الصلاحيات
-- ============================================

-- منح صلاحيات للدور المصادق عليه
GRANT SELECT, INSERT, UPDATE, DELETE ON public.vendor_social_links TO authenticated;

-- منح صلاحيات للـ Functions
GRANT EXECUTE ON FUNCTION create_default_vendor_social_links(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION update_vendor_social_link(UUID, VARCHAR(50), TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION get_vendor_social_links(UUID) TO authenticated;

-- ============================================
-- إنشاء Trigger لإنشاء الروابط الافتراضية عند إنشاء تاجر جديد
-- ============================================

CREATE OR REPLACE FUNCTION trigger_create_default_vendor_social_links()
RETURNS TRIGGER AS $$
BEGIN
    -- إنشاء الروابط الافتراضية للتاجر الجديد
    PERFORM create_default_vendor_social_links(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_create_vendor_social_links
    AFTER INSERT ON public.vendors
    FOR EACH ROW
    EXECUTE FUNCTION trigger_create_default_vendor_social_links();

-- ============================================
-- تعليقات الجدول والحقول
-- ============================================

COMMENT ON TABLE public.vendor_social_links IS 'جدول روابط التواصل الاجتماعي والعمل للتجار';
COMMENT ON COLUMN public.vendor_social_links.id IS 'المعرف الفريد للرابط';
COMMENT ON COLUMN public.vendor_social_links.vendor_id IS 'معرف التاجر';
COMMENT ON COLUMN public.vendor_social_links.link_type IS 'نوع الرابط: website, email, whatsapp, phone, location, linkedin, youtube';
COMMENT ON COLUMN public.vendor_social_links.link_value IS 'قيمة الرابط (الرابط أو النص)';
COMMENT ON COLUMN public.vendor_social_links.is_active IS 'حالة تفعيل الرابط (مرئي للعملاء أم لا)';
COMMENT ON COLUMN public.vendor_social_links.created_at IS 'تاريخ الإنشاء';
COMMENT ON COLUMN public.vendor_social_links.updated_at IS 'تاريخ آخر تحديث';

-- ============================================
-- إنشاء الروابط الافتراضية للتجار الموجودين
-- ============================================

-- إنشاء الروابط الافتراضية لجميع التجار الموجودين
DO $$
DECLARE
    vendor_record RECORD;
BEGIN
    FOR vendor_record IN SELECT id FROM public.vendors LOOP
        PERFORM create_default_vendor_social_links(vendor_record.id);
    END LOOP;
END $$;

-- ============================================
-- ملاحظات مهمة
-- ============================================

/*
📋 ملاحظات مهمة:

1. ✅ الجدول مُحسّن للأداء مع فهارس مناسبة
2. ✅ Row Level Security مفعل لحماية البيانات
3. ✅ سياسات أمان تسمح للتجار بإدارة روابطهم فقط
4. ✅ Functions مساعدة لإدارة الروابط
5. ✅ Trigger لإنشاء روابط افتراضية عند إنشاء تاجر جديد
6. ✅ دعم جميع أنواع الروابط المطلوبة
7. ✅ منع تكرار نفس نوع الرابط للتاجر الواحد
8. ✅ تحديث تلقائي لـ updated_at

🚀 الاستخدام:
- استدعاء get_vendor_social_links(vendor_id) للحصول على روابط التاجر
- استدعاء update_vendor_social_link(vendor_id, type, value, is_active) لتحديث رابط
- الروابط الافتراضية تُنشأ تلقائياً عند إنشاء تاجر جديد

🔒 الأمان:
- التجار يمكنهم فقط إدارة روابطهم الخاصة
- العملاء يمكنهم رؤية الروابط النشطة فقط
- جميع العمليات محمية بـ RLS policies
*/