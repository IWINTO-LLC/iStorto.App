-- ============================================
-- إنشاء الأقسام لجميع التجار المسجلين سابقاً
-- Create sections for all existing vendors
-- ============================================

-- الطريقة 1: إنشاء الأقسام لجميع التجار دفعة واحدة
-- ============================================

DO $$
DECLARE
    vendor_record RECORD;
    sections_created INTEGER := 0;
    vendors_processed INTEGER := 0;
BEGIN
    -- المرور على كل تاجر في قاعدة البيانات
    FOR vendor_record IN 
        SELECT id, organization_name FROM public.vendors
    LOOP
        -- محاولة إنشاء الأقسام الافتراضية
        PERFORM create_default_vendor_sections(vendor_record.id);
        
        vendors_processed := vendors_processed + 1;
        
        -- عد الأقسام المنشأة
        SELECT COUNT(*) INTO sections_created 
        FROM public.vendor_sections 
        WHERE vendor_id = vendor_record.id;
        
        RAISE NOTICE 'Vendor: % (%) - Sections: %', 
            vendor_record.organization_name, 
            vendor_record.id, 
            sections_created;
    END LOOP;
    
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'إجمالي التجار: %', vendors_processed;
    RAISE NOTICE 'تم إنشاء الأقسام بنجاح!';
    RAISE NOTICE '==========================================';
END $$;

-- ============================================
-- الطريقة 2: التحقق من النتائج
-- ============================================

-- عرض إحصائيات الأقسام لكل تاجر
SELECT 
    v.id,
    v.organization_name,
    COUNT(vs.id) as sections_count
FROM public.vendors v
LEFT JOIN public.vendor_sections vs ON v.id = vs.vendor_id
GROUP BY v.id, v.organization_name
ORDER BY sections_count DESC, v.organization_name;

-- ============================================
-- الطريقة 3: إنشاء الأقسام لتاجر واحد محدد
-- ============================================

-- إذا كنت تريد إنشاء الأقسام لتاجر واحد فقط:
-- استبدل 'vendor-id-here' بمعرف التاجر الفعلي

-- SELECT create_default_vendor_sections('vendor-id-here');

-- ثم تحقق من النتيجة:
-- SELECT * FROM vendor_sections WHERE vendor_id = 'vendor-id-here';

-- ============================================
-- الطريقة 4: إنشاء الأقسام فقط للتجار الذين لا يملكون أقسام
-- ============================================

DO $$
DECLARE
    vendor_record RECORD;
    sections_count INTEGER;
BEGIN
    FOR vendor_record IN 
        SELECT v.id, v.organization_name 
        FROM public.vendors v
        LEFT JOIN public.vendor_sections vs ON v.id = vs.vendor_id
        GROUP BY v.id, v.organization_name
        HAVING COUNT(vs.id) = 0  -- فقط التجار بدون أقسام
    LOOP
        PERFORM create_default_vendor_sections(vendor_record.id);
        
        RAISE NOTICE 'تم إنشاء الأقسام للتاجر: % (%)', 
            vendor_record.organization_name, 
            vendor_record.id;
    END LOOP;
END $$;

-- ============================================
-- التحقق النهائي
-- ============================================

-- التأكد من أن جميع التجار لديهم أقسام
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ جميع التجار لديهم أقسام!'
        ELSE '⚠️ يوجد ' || COUNT(*) || ' تاجر بدون أقسام'
    END as status
FROM public.vendors v
LEFT JOIN public.vendor_sections vs ON v.id = vs.vendor_id
GROUP BY v.id
HAVING COUNT(vs.id) = 0;

-- عرض التجار الذين لا يملكون أقسام (إن وجدوا)
SELECT 
    v.id,
    v.organization_name,
    v.organization_logo,
    COUNT(vs.id) as sections_count
FROM public.vendors v
LEFT JOIN public.vendor_sections vs ON v.id = vs.vendor_id
GROUP BY v.id, v.organization_name, v.organization_logo
HAVING COUNT(vs.id) = 0;

-- ============================================
-- إحصائيات شاملة
-- ============================================

-- عدد التجار الإجمالي
SELECT 'إجمالي التجار' as metric, COUNT(*) as count FROM public.vendors
UNION ALL
-- عدد التجار الذين لديهم أقسام
SELECT 'تجار لديهم أقسام', COUNT(DISTINCT vendor_id) FROM public.vendor_sections
UNION ALL
-- إجمالي الأقسام
SELECT 'إجمالي الأقسام', COUNT(*) FROM public.vendor_sections
UNION ALL
-- متوسط الأقسام لكل تاجر
SELECT 'متوسط الأقسام/تاجر', ROUND(AVG(section_count))::INTEGER
FROM (
    SELECT vendor_id, COUNT(*) as section_count
    FROM public.vendor_sections
    GROUP BY vendor_id
) as avg_calc;

-- ============================================
-- ملاحظات مهمة
-- ============================================

/*
✅ ما يفعله هذا السكريبت:
1. ينشئ 12 قسم افتراضي لكل تاجر موجود
2. لا ينشئ أقسام مكررة (بفضل ON CONFLICT)
3. يعرض تقرير مفصل عن كل تاجر
4. يعرض إحصائيات شاملة

⚠️ تحذيرات:
- يمكن تشغيله أكثر من مرة بأمان (لن يكرر الأقسام)
- قد يستغرق وقتاً إذا كان لديك عدد كبير من التجار
- تأكد من تشغيل create_vendor_sections_system.sql أولاً

📝 خطوات التنفيذ:
1. شغّل create_vendor_sections_system.sql (إذا لم تكن قد شغلته)
2. شغّل add_auto_sections_trigger.sql (للتجار الجدد)
3. شغّل هذا الملف (للتجار الحاليين)
4. تحقق من النتائج في نهاية السكريبت
*/

