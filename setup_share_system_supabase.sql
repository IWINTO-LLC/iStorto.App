-- =====================================================
-- إعداد نظام المشاركة في Supabase
-- Setup Share System for Supabase
-- =====================================================

-- الخطوة 0: إضافة حقل is_deleted لجدول vendors (إذا لم يكن موجوداً)
-- Step 0: Add is_deleted field to vendors table (if not exists)
-- =====================================================

ALTER TABLE public.vendors
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;

-- إنشاء فهرس للأداء
CREATE INDEX IF NOT EXISTS idx_vendors_is_deleted ON public.vendors(is_deleted);

COMMENT ON COLUMN public.vendors.is_deleted IS 'هل المتجر محذوف - Is vendor deleted';

-- =====================================================
-- الخطوة 1: إنشاء جدول المشاركات
-- Step 1: Create shares table
-- =====================================================

CREATE TABLE IF NOT EXISTS public.shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    share_type TEXT NOT NULL CHECK (share_type IN ('product', 'vendor')),
    entity_id TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    shared_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_type TEXT,
    share_method TEXT
);

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_shares_entity ON public.shares(share_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_shares_user ON public.shares(user_id);
CREATE INDEX IF NOT EXISTS idx_shares_date ON public.shares(shared_at DESC);
CREATE INDEX IF NOT EXISTS idx_shares_type_date ON public.shares(share_type, shared_at DESC);

-- تعليق على الجدول
COMMENT ON TABLE public.shares IS 'تتبع عمليات مشاركة المنتجات والمتاجر - Track product and vendor shares';

-- =====================================================
-- الخطوة 2: تفعيل RLS وإنشاء السياسات
-- Step 2: Enable RLS and create policies
-- =====================================================

ALTER TABLE public.shares ENABLE ROW LEVEL SECURITY;

-- سياسة: السماح لأي شخص بقراءة إحصائيات المشاركة
DROP POLICY IF EXISTS "Allow public read access to share counts" ON public.shares;
CREATE POLICY "Allow public read access to share counts"
ON public.shares
FOR SELECT
TO public
USING (true);

-- سياسة: السماح للمستخدمين المصادقين بإضافة مشاركات
DROP POLICY IF EXISTS "Allow authenticated users to insert shares" ON public.shares;
CREATE POLICY "Allow authenticated users to insert shares"
ON public.shares
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- سياسة: السماح للمستخدمين برؤية مشاركاتهم فقط
DROP POLICY IF EXISTS "Users can view their own shares" ON public.shares;
CREATE POLICY "Users can view their own shares"
ON public.shares
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- =====================================================
-- الخطوة 3: إنشاء دالة لتسجيل المشاركة
-- Step 3: Create function to log shares
-- =====================================================

CREATE OR REPLACE FUNCTION public.log_share(
    p_share_type TEXT,
    p_entity_id TEXT,
    p_user_id UUID DEFAULT NULL,
    p_device_type TEXT DEFAULT NULL,
    p_share_method TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_share_id UUID;
BEGIN
    -- التحقق من صحة نوع المشاركة
    IF p_share_type NOT IN ('product', 'vendor') THEN
        RAISE EXCEPTION 'Invalid share type: %', p_share_type;
    END IF;

    -- إدراج سجل المشاركة
    INSERT INTO public.shares (
        share_type,
        entity_id,
        user_id,
        device_type,
        share_method
    )
    VALUES (
        p_share_type,
        p_entity_id,
        COALESCE(p_user_id, auth.uid()),
        p_device_type,
        p_share_method
    )
    RETURNING id INTO v_share_id;
    
    RETURN v_share_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error logging share: %', SQLERRM;
        RETURN NULL;
END;
$$;

COMMENT ON FUNCTION public.log_share IS 'تسجيل عملية مشاركة منتج أو متجر - Log a product or vendor share';

-- =====================================================
-- الخطوة 4: إنشاء دوال الإحصائيات
-- Step 4: Create statistics functions
-- =====================================================

-- دالة للحصول على عدد المشاركات
CREATE OR REPLACE FUNCTION public.get_share_count(
    p_share_type TEXT,
    p_entity_id TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM public.shares
    WHERE share_type = p_share_type
      AND entity_id = p_entity_id;
    
    RETURN COALESCE(v_count, 0);
END;
$$;

COMMENT ON FUNCTION public.get_share_count IS 'الحصول على عدد المشاركات لمنتج أو متجر - Get share count for a product or vendor';

-- دالة للحصول على أكثر المنتجات مشاركة
CREATE OR REPLACE FUNCTION public.get_most_shared_products(
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    product_id TEXT,
    share_count BIGINT,
    last_shared TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.entity_id AS product_id,
        COUNT(*) AS share_count,
        MAX(s.shared_at) AS last_shared
    FROM public.shares s
    WHERE s.share_type = 'product'
    GROUP BY s.entity_id
    ORDER BY share_count DESC, last_shared DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION public.get_most_shared_products IS 'الحصول على أكثر المنتجات مشاركة - Get most shared products';

-- دالة للحصول على أكثر المتاجر مشاركة
CREATE OR REPLACE FUNCTION public.get_most_shared_vendors(
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    vendor_id TEXT,
    share_count BIGINT,
    last_shared TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.entity_id AS vendor_id,
        COUNT(*) AS share_count,
        MAX(s.shared_at) AS last_shared
    FROM public.shares s
    WHERE s.share_type = 'vendor'
    GROUP BY s.entity_id
    ORDER BY share_count DESC, last_shared DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION public.get_most_shared_vendors IS 'الحصول على أكثر المتاجر مشاركة - Get most shared vendors';

-- =====================================================
-- الخطوة 5: إضافة عمود share_count
-- Step 5: Add share_count columns
-- =====================================================

-- إضافة عمود share_count في جدول products
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;

-- إنشاء فهرس
CREATE INDEX IF NOT EXISTS idx_products_share_count 
ON public.products(share_count DESC);

-- تحديث القيم الموجودة
UPDATE public.products p
SET share_count = (
    SELECT COUNT(*)
    FROM public.shares s
    WHERE s.share_type = 'product' AND s.entity_id = p.id::TEXT
);

-- إضافة عمود share_count في جدول vendors
ALTER TABLE public.vendors
ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;

-- إنشاء فهرس
CREATE INDEX IF NOT EXISTS idx_vendors_share_count 
ON public.vendors(share_count DESC);

-- تحديث القيم الموجودة
UPDATE public.vendors v
SET share_count = (
    SELECT COUNT(*)
    FROM public.shares s
    WHERE s.share_type = 'vendor' AND s.entity_id = v.id::TEXT
);

-- =====================================================
-- الخطوة 6: إنشاء Trigger لتحديث العداد تلقائياً
-- Step 6: Create trigger to update count automatically
-- =====================================================

-- دالة لتحديث عداد المشاركات
CREATE OR REPLACE FUNCTION public.update_share_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.share_type = 'product' THEN
        -- تحديث عداد المشاركات للمنتج
        UPDATE public.products
        SET share_count = share_count + 1
        WHERE id = NEW.entity_id;
    ELSIF NEW.share_type = 'vendor' THEN
        -- تحديث عداد المشاركات للمتجر
        UPDATE public.vendors
        SET share_count = share_count + 1
        WHERE id = NEW.entity_id;
    END IF;
    
    RETURN NEW;
END;
$$;

-- إنشاء Trigger
DROP TRIGGER IF EXISTS trigger_update_share_count ON public.shares;
CREATE TRIGGER trigger_update_share_count
AFTER INSERT ON public.shares
FOR EACH ROW
EXECUTE FUNCTION public.update_share_count();

COMMENT ON FUNCTION public.update_share_count IS 'تحديث عداد المشاركات تلقائياً - Auto update share count';

-- =====================================================
-- الخطوة 7: إنشاء Views للمشاركة
-- Step 7: Create share views
-- =====================================================

-- حذف Views القديمة إذا وجدت
DROP VIEW IF EXISTS public.product_share_view CASCADE;
DROP VIEW IF EXISTS public.vendor_share_view CASCADE;
DROP VIEW IF EXISTS public.daily_share_stats CASCADE;
DROP VIEW IF EXISTS public.top_shared_products CASCADE;
DROP VIEW IF EXISTS public.top_shared_vendors CASCADE;

-- View للمنتجات الظاهرة في الروابط المشاركة
CREATE VIEW public.product_share_view AS
SELECT 
    p.id,
    p.title,
    p.description,
    p.price,
    p.old_price,
    p.images,
    p.vendor_id,
    p.share_count,
    v.organization_name AS vendor_name,
    v.organization_logo AS vendor_logo
FROM public.products p
LEFT JOIN public.vendors v ON p.vendor_id = v.id
WHERE p.is_deleted = false;

GRANT SELECT ON public.product_share_view TO anon, authenticated;

-- View للمتاجر الظاهرة في الروابط المشاركة
CREATE VIEW public.vendor_share_view AS
SELECT 
    v.id,
    v.user_id,
    v.organization_name,
    v.organization_logo,
    v.organization_cover,
    v.organization_bio,
    v.brief,
    v.share_count,
    COUNT(DISTINCT p.id) AS products_count,
    COUNT(DISTINCT uf.user_id) AS followers_count
FROM public.vendors v
LEFT JOIN public.products p ON v.id = p.vendor_id AND p.is_deleted = false
LEFT JOIN public.user_follows uf ON v.id = uf.vendor_id
WHERE v.is_deleted = false
GROUP BY v.id, v.user_id, v.organization_name, v.organization_logo, 
         v.organization_cover, v.organization_bio, v.brief, v.share_count;

GRANT SELECT ON public.vendor_share_view TO anon, authenticated;

-- View لإحصائيات المشاركة اليومية
CREATE VIEW public.daily_share_stats AS
SELECT 
    DATE(shared_at) AS share_date,
    share_type,
    COUNT(*) AS total_shares,
    COUNT(DISTINCT entity_id) AS unique_entities,
    COUNT(DISTINCT user_id) AS unique_users
FROM public.shares
GROUP BY DATE(shared_at), share_type
ORDER BY share_date DESC;

GRANT SELECT ON public.daily_share_stats TO authenticated;

-- View لأفضل المنتجات حسب المشاركة
CREATE VIEW public.top_shared_products AS
SELECT 
    p.id,
    p.title,
    p.price,
    p.images[1] AS thumbnail,
    v.organization_name AS vendor_name,
    p.share_count,
    COUNT(s.id) AS recent_shares
FROM public.products p
LEFT JOIN public.shares s ON s.entity_id = p.id::TEXT
    AND s.share_type = 'product' 
    AND s.shared_at > NOW() - INTERVAL '30 days'
LEFT JOIN public.vendors v ON p.vendor_id = v.id
WHERE p.is_deleted = false
GROUP BY p.id, p.title, p.price, p.images, v.organization_name, p.share_count
ORDER BY p.share_count DESC, recent_shares DESC;

GRANT SELECT ON public.top_shared_products TO anon, authenticated;

-- View لأفضل المتاجر حسب المشاركة
CREATE VIEW public.top_shared_vendors AS
SELECT 
    v.id,
    v.organization_name,
    v.organization_logo,
    v.share_count,
    COUNT(s.id) AS recent_shares
FROM public.vendors v
LEFT JOIN public.shares s ON s.entity_id = v.id::TEXT
    AND s.share_type = 'vendor'
    AND s.shared_at > NOW() - INTERVAL '30 days'
WHERE v.is_deleted = false
GROUP BY v.id, v.organization_name, v.organization_logo, v.share_count
ORDER BY v.share_count DESC, recent_shares DESC;

GRANT SELECT ON public.top_shared_vendors TO anon, authenticated;

-- =====================================================
-- الخطوة 8: إنشاء دالة لتنظيف البيانات القديمة
-- Step 8: Create cleanup function for old data
-- =====================================================

CREATE OR REPLACE FUNCTION public.cleanup_old_shares(
    p_days_old INTEGER DEFAULT 365
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    DELETE FROM public.shares
    WHERE shared_at < NOW() - (p_days_old || ' days')::INTERVAL;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    RETURN v_deleted_count;
END;
$$;

COMMENT ON FUNCTION public.cleanup_old_shares IS 'تنظيف سجلات المشاركة القديمة - Cleanup old share records';

-- =====================================================
-- اختبارات سريعة
-- Quick Tests
-- =====================================================

-- اختبار 1: تسجيل مشاركة منتج
DO $$
DECLARE
    v_share_id UUID;
BEGIN
    -- تسجيل مشاركة
    v_share_id := public.log_share('product', 'test-product-123', NULL, 'android', 'test');
    
    IF v_share_id IS NOT NULL THEN
        RAISE NOTICE '✅ Test 1 Passed: Share logged successfully with ID %', v_share_id;
        
        -- حذف سجل الاختبار
        DELETE FROM public.shares WHERE id = v_share_id;
    ELSE
        RAISE WARNING '❌ Test 1 Failed: Share logging returned NULL';
    END IF;
END $$;

-- اختبار 2: الحصول على عدد المشاركات
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    v_count := public.get_share_count('product', 'test-product-123');
    RAISE NOTICE '✅ Test 2 Passed: get_share_count returned %', v_count;
END $$;

-- اختبار 3: الحصول على أكثر المنتجات مشاركة
DO $$
DECLARE
    v_result RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_result IN 
        SELECT * FROM public.get_most_shared_products(5)
    LOOP
        v_count := v_count + 1;
    END LOOP;
    
    RAISE NOTICE '✅ Test 3 Passed: get_most_shared_products returned % records', v_count;
END $$;

-- =====================================================
-- عرض الإحصائيات
-- Display Statistics
-- =====================================================

-- عرض ملخص النظام
DO $$
DECLARE
    v_total_shares BIGINT;
    v_total_products BIGINT;
    v_total_vendors BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total_shares FROM public.shares;
    SELECT COUNT(*) INTO v_total_products FROM public.shares WHERE share_type = 'product';
    SELECT COUNT(*) INTO v_total_vendors FROM public.shares WHERE share_type = 'vendor';
    
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '📊 نظام المشاركة - Share System';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '✅ إجمالي المشاركات: %', v_total_shares;
    RAISE NOTICE '📦 مشاركات المنتجات: %', v_total_products;
    RAISE NOTICE '🏪 مشاركات المتاجر: %', v_total_vendors;
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '✅ تم إعداد نظام المشاركة بنجاح!';
    RAISE NOTICE '✅ Share System Setup Complete!';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

-- عرض جميع الجداول والدوال والـ Views المنشأة
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;
SELECT '📊 النظام جاهز للاستخدام - System Ready!' AS status;
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS separator;

-- =====================================================
-- نهاية السكريبت
-- End of Script
-- =====================================================

