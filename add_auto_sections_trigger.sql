-- ============================================
-- Trigger تلقائي لإنشاء الأقسام عند تسجيل تاجر جديد
-- Auto-create sections when a new vendor is created
-- ============================================

-- 1. إنشاء Function للتشغيل التلقائي
-- ============================================

CREATE OR REPLACE FUNCTION auto_create_vendor_sections()
RETURNS TRIGGER AS $$
BEGIN
    -- إنشاء الأقسام الافتراضية للتاجر الجديد
    INSERT INTO public.vendor_sections (vendor_id, section_key, display_name, arabic_name, display_type, sort_order)
    VALUES
        (NEW.id, 'offers', 'Offers', 'العروض', 'grid', 1),
        (NEW.id, 'all', 'All Products', 'جميع المنتجات', 'grid', 2),
        (NEW.id, 'sales', 'Sales', 'التخفيضات', 'slider', 3),
        (NEW.id, 'newArrival', 'New Arrival', 'الوافد الجديد', 'grid', 4),
        (NEW.id, 'featured', 'Featured', 'المميز', 'grid', 5),
        (NEW.id, 'foryou', 'For You', 'لك خصيصاً', 'grid', 6),
        (NEW.id, 'mixlin1', 'Try This', 'جرّب هذا', 'custom', 7),
        (NEW.id, 'mixone', 'Mix Items', 'عناصر مختلطة', 'slider', 8),
        (NEW.id, 'mixlin2', 'Voutures', 'مغامرات', 'grid', 9),
        (NEW.id, 'all1', 'Product A', 'منتجات أ', 'grid', 10),
        (NEW.id, 'all2', 'Product B', 'منتجات ب', 'grid', 11),
        (NEW.id, 'all3', 'Product C', 'منتجات ج', 'grid', 12)
    ON CONFLICT (vendor_id, section_key) DO NOTHING;
    
    RAISE NOTICE 'Auto-created default sections for vendor: %', NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. إنشاء Trigger على جدول vendors
-- ============================================

DROP TRIGGER IF EXISTS trigger_auto_create_vendor_sections ON public.vendors;

CREATE TRIGGER trigger_auto_create_vendor_sections
    AFTER INSERT ON public.vendors
    FOR EACH ROW
    EXECUTE FUNCTION auto_create_vendor_sections();

-- 3. منح الصلاحيات
-- ============================================

GRANT EXECUTE ON FUNCTION auto_create_vendor_sections() TO authenticated;

-- 4. إضافة تعليق توضيحي
-- ============================================

COMMENT ON FUNCTION auto_create_vendor_sections IS 'يتم تشغيل هذه الدالة تلقائياً عند إنشاء تاجر جديد لإنشاء الأقسام الافتراضية';
COMMENT ON TRIGGER trigger_auto_create_vendor_sections ON public.vendors IS 'ينشئ الأقسام الافتراضية تلقائياً عند تسجيل تاجر جديد';

-- ============================================
-- اختبار Trigger
-- ============================================

-- للاختبار (لا تشغله إذا لم تكن تريد إنشاء تاجر تجريبي):
-- INSERT INTO vendors (user_id, organization_name, organization_logo, brief)
-- VALUES ('test-user-id', 'Test Store', 'url', 'Test Brief')
-- RETURNING id;

-- ثم تحقق:
-- SELECT * FROM vendor_sections WHERE vendor_id = 'returned-vendor-id';

-- ============================================
-- ملاحظات مهمة
-- ============================================

-- ✅ الآن عند إنشاء تاجر جديد، سيتم إنشاء 12 قسم تلقائياً
-- ✅ التجار الجدد لن يحتاجوا لأي إعداد يدوي
-- ⚠️ التجار الحاليين يحتاجون لتشغيل السكريبت اليدوي (انظر للملف التالي)

