-- =====================================================
-- إنشاء جدول صور المنتجات
-- Create Product Images Table
-- =====================================================

-- الخطوة 1: إنشاء جدول product_images
-- Step 1: Create product_images table
-- =====================================================

CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    image_order INTEGER DEFAULT 0,
    is_thumbnail BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign Key (without strict constraint for flexibility)
    CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) 
    REFERENCES public.products(id) ON DELETE CASCADE
);

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON public.product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_product_images_created_at ON public.product_images(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_images_thumbnail ON public.product_images(is_thumbnail) WHERE is_thumbnail = true;
CREATE INDEX IF NOT EXISTS idx_product_images_order ON public.product_images(product_id, image_order);

-- تعليق على الجدول
COMMENT ON TABLE public.product_images IS 'جدول روابط صور المنتجات - Product images URLs table';
COMMENT ON COLUMN public.product_images.product_id IS 'معرف المنتج - Product ID';
COMMENT ON COLUMN public.product_images.image_url IS 'رابط الصورة في Supabase Storage';
COMMENT ON COLUMN public.product_images.image_order IS 'ترتيب الصورة - Image display order';
COMMENT ON COLUMN public.product_images.is_thumbnail IS 'هل هي الصورة الرئيسية - Is main thumbnail';

-- =====================================================
-- الخطوة 2: تفعيل RLS وإنشاء السياسات
-- Step 2: Enable RLS and create policies
-- =====================================================

ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;

-- سياسة: السماح للجميع بقراءة صور المنتجات
DROP POLICY IF EXISTS "Allow public read access to product images" ON public.product_images;
CREATE POLICY "Allow public read access to product images"
ON public.product_images
FOR SELECT
TO public
USING (true);

-- سياسة: السماح للمستخدمين المصادقين بإضافة صور
DROP POLICY IF EXISTS "Allow authenticated users to insert product images" ON public.product_images;
CREATE POLICY "Allow authenticated users to insert product images"
ON public.product_images
FOR INSERT
TO authenticated
WITH CHECK (true);

-- سياسة: السماح لصاحب المنتج بتحديث صوره
DROP POLICY IF EXISTS "Allow product owner to update images" ON public.product_images;
CREATE POLICY "Allow product owner to update images"
ON public.product_images
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.products p
        JOIN public.vendors v ON p.vendor_id = v.id
        WHERE p.id = product_id AND v.user_id = auth.uid()
    )
);

-- سياسة: السماح لصاحب المنتج بحذف صوره
DROP POLICY IF EXISTS "Allow product owner to delete images" ON public.product_images;
CREATE POLICY "Allow product owner to delete images"
ON public.product_images
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.products p
        JOIN public.vendors v ON p.vendor_id = v.id
        WHERE p.id = product_id AND v.user_id = auth.uid()
    )
);

-- =====================================================
-- الخطوة 3: إنشاء دوال مساعدة
-- Step 3: Create helper functions
-- =====================================================

-- دالة لإضافة صور منتج
CREATE OR REPLACE FUNCTION public.add_product_images(
    p_product_id UUID,
    p_image_urls TEXT[]
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_image_url TEXT;
    v_order INTEGER := 0;
    v_inserted_count INTEGER := 0;
BEGIN
    -- حذف الصور القديمة للمنتج (اختياري)
    -- DELETE FROM public.product_images WHERE product_id = p_product_id;
    
    -- إضافة الصور الجديدة
    FOREACH v_image_url IN ARRAY p_image_urls
    LOOP
        INSERT INTO public.product_images (
            product_id,
            image_url,
            image_order,
            is_thumbnail
        ) VALUES (
            p_product_id,
            v_image_url,
            v_order,
            v_order = 0  -- الصورة الأولى هي thumbnail
        );
        
        v_order := v_order + 1;
        v_inserted_count := v_inserted_count + 1;
    END LOOP;
    
    RETURN v_inserted_count;
END;
$$;

COMMENT ON FUNCTION public.add_product_images IS 'إضافة صور لمنتج - Add images to a product';

-- دالة للحصول على صور منتج
CREATE OR REPLACE FUNCTION public.get_product_images(
    p_product_id UUID
)
RETURNS TABLE (
    id UUID,
    image_url TEXT,
    image_order INTEGER,
    is_thumbnail BOOLEAN
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pi.id,
        pi.image_url,
        pi.image_order,
        pi.is_thumbnail
    FROM public.product_images pi
    WHERE pi.product_id = p_product_id
    ORDER BY pi.image_order ASC;
END;
$$;

COMMENT ON FUNCTION public.get_product_images IS 'الحصول على صور منتج - Get product images';

-- دالة للحصول على جميع الصور (للمعرض)
CREATE OR REPLACE FUNCTION public.get_all_product_images(
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    product_id UUID,
    image_url TEXT,
    product_title TEXT,
    product_price NUMERIC,
    vendor_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pi.id,
        pi.product_id,
        pi.image_url,
        p.title AS product_title,
        p.price AS product_price,
        v.organization_name AS vendor_name,
        pi.created_at
    FROM public.product_images pi
    JOIN public.products p ON pi.product_id = p.id
    LEFT JOIN public.vendors v ON p.vendor_id = v.id
    WHERE p.is_deleted = false
    ORDER BY pi.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

COMMENT ON FUNCTION public.get_all_product_images IS 'الحصول على جميع صور المنتجات للمعرض - Get all product images for gallery';

-- =====================================================
-- الخطوة 4: إنشاء View لمعرض الصور
-- Step 4: Create gallery view
-- =====================================================

DROP VIEW IF EXISTS public.product_images_gallery CASCADE;

CREATE VIEW public.product_images_gallery AS
SELECT 
    pi.id,
    pi.product_id,
    pi.image_url,
    pi.image_order,
    pi.created_at,
    p.title AS product_title,
    p.price AS product_price,
    p.old_price AS product_old_price,
    p.vendor_id,
    v.organization_name AS vendor_name,
    v.organization_logo AS vendor_logo
FROM public.product_images pi
JOIN public.products p ON pi.product_id = p.id
LEFT JOIN public.vendors v ON p.vendor_id = v.id
WHERE p.is_deleted = false
ORDER BY pi.created_at DESC;

GRANT SELECT ON public.product_images_gallery TO anon, authenticated;

COMMENT ON VIEW public.product_images_gallery IS 'معرض صور المنتجات - Product images gallery view';

-- =====================================================
-- الخطوة 5: إنشاء Trigger لتحديث timestamp
-- Step 5: Create trigger for timestamp update
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_product_images_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_update_product_images_timestamp ON public.product_images;

CREATE TRIGGER trigger_update_product_images_timestamp
BEFORE UPDATE ON public.product_images
FOR EACH ROW
EXECUTE FUNCTION public.update_product_images_timestamp();

-- =====================================================
-- الخطوة 6: ملء البيانات من جدول products الموجود
-- Step 6: Populate data from existing products table
-- =====================================================

-- نقل الصور الموجودة في products.images إلى product_images
INSERT INTO public.product_images (product_id, image_url, image_order, is_thumbnail)
SELECT 
    p.id,
    unnest(p.images) AS image_url,
    generate_series(1, array_length(p.images, 1)) - 1 AS image_order,
    generate_series(1, array_length(p.images, 1)) = 1 AS is_thumbnail
FROM public.products p
WHERE p.images IS NOT NULL 
  AND array_length(p.images, 1) > 0
  AND p.is_deleted = false
ON CONFLICT DO NOTHING;

-- =====================================================
-- الخطوة 7: إنشاء دالة لمزامنة الصور
-- Step 7: Create function to sync images
-- =====================================================

-- دالة لمزامنة صور المنتج عند التحديث
CREATE OR REPLACE FUNCTION public.sync_product_images()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- حذف الصور القديمة
    DELETE FROM public.product_images WHERE product_id = NEW.id;
    
    -- إضافة الصور الجديدة إذا وُجدت
    IF NEW.images IS NOT NULL AND array_length(NEW.images, 1) > 0 THEN
        INSERT INTO public.product_images (product_id, image_url, image_order, is_thumbnail)
        SELECT 
            NEW.id,
            unnest(NEW.images),
            generate_series(1, array_length(NEW.images, 1)) - 1,
            generate_series(1, array_length(NEW.images, 1)) = 1;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Trigger لمزامنة الصور عند إضافة أو تحديث منتج
DROP TRIGGER IF EXISTS trigger_sync_product_images ON public.products;

CREATE TRIGGER trigger_sync_product_images
AFTER INSERT OR UPDATE OF images ON public.products
FOR EACH ROW
EXECUTE FUNCTION public.sync_product_images();

COMMENT ON FUNCTION public.sync_product_images IS 'مزامنة صور المنتج تلقائياً - Auto sync product images';

-- =====================================================
-- اختبارات سريعة
-- Quick Tests
-- =====================================================

-- عرض عدد الصور
SELECT 
    'إجمالي الصور' AS metric,
    COUNT(*) AS value
FROM public.product_images;

-- عرض عدد المنتجات التي لها صور
SELECT 
    'منتجات بصور' AS metric,
    COUNT(DISTINCT product_id) AS value
FROM public.product_images;

-- عرض آخر 5 صور
SELECT 
    pi.product_id,
    p.title AS product_title,
    pi.image_url,
    pi.image_order
FROM public.product_images pi
JOIN public.products p ON pi.product_id = p.id
ORDER BY pi.created_at DESC
LIMIT 5;

-- =====================================================
-- عرض ملخص النظام
-- Display System Summary
-- =====================================================

DO $$
DECLARE
    v_total_images BIGINT;
    v_total_products_with_images BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total_images FROM public.product_images;
    SELECT COUNT(DISTINCT product_id) INTO v_total_products_with_images FROM public.product_images;
    
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '📸 نظام صور المنتجات - Product Images System';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '✅ إجمالي الصور: %', v_total_images;
    RAISE NOTICE '📦 منتجات بصور: %', v_total_products_with_images;
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '✅ تم إعداد نظام صور المنتجات بنجاح!';
    RAISE NOTICE '✅ Product Images System Setup Complete!';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

-- =====================================================
-- نهاية السكريبت
-- End of Script
-- =====================================================

