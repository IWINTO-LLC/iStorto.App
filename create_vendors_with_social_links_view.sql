-- إنشاء view لدمج بيانات التاجر مع روابط السوشال
-- هذا السكريبت يركز على إنشاء الـ view فقط

-- أولاً، تأكد من وجود جدول vendor_social_links أو أنشئه إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS vendor_social_links (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    
    -- روابط السوشال ميديا
    facebook TEXT DEFAULT '',
    x TEXT DEFAULT '',
    instagram TEXT DEFAULT '',
    website TEXT DEFAULT '',
    linkedin TEXT DEFAULT '',
    whatsapp TEXT DEFAULT '',
    tiktok TEXT DEFAULT '',
    youtube TEXT DEFAULT '',
    location TEXT DEFAULT '',
    
    -- قائمة أرقام الهواتف (TEXT array بدلاً من JSON)
    phones TEXT[] DEFAULT '{}',
    
    -- حالات الإظهار (visibility)
    visible_facebook BOOLEAN DEFAULT true,
    visible_x BOOLEAN DEFAULT true,
    visible_instagram BOOLEAN DEFAULT true,
    visible_website BOOLEAN DEFAULT true,
    visible_linkedin BOOLEAN DEFAULT true,
    visible_whatsapp BOOLEAN DEFAULT true,
    visible_tiktok BOOLEAN DEFAULT true,
    visible_youtube BOOLEAN DEFAULT true,
    visible_phones BOOLEAN DEFAULT true,
    
    -- تواريخ الإنشاء والتحديث
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- فهرس فريد للتاجر (تاجر واحد = سجل واحد)
    CONSTRAINT unique_vendor_social_links UNIQUE(vendor_id)
);

-- إنشاء فهرس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_vendor_social_links_vendor_id ON vendor_social_links(vendor_id);

-- إضافة RLS (Row Level Security) إذا لم يكن مفعلاً
ALTER TABLE vendor_social_links ENABLE ROW LEVEL SECURITY;

-- حذف السياسات الموجودة مسبقاً (إذا كانت موجودة)
DROP POLICY IF EXISTS "Anyone can read vendor social links" ON vendor_social_links;
DROP POLICY IF EXISTS "Vendors can insert their own social links" ON vendor_social_links;
DROP POLICY IF EXISTS "Vendors can update their own social links" ON vendor_social_links;
DROP POLICY IF EXISTS "Vendors can delete their own social links" ON vendor_social_links;

-- إنشاء السياسات الجديدة
CREATE POLICY "Anyone can read vendor social links" ON vendor_social_links
    FOR SELECT USING (true);

CREATE POLICY "Vendors can insert their own social links" ON vendor_social_links
    FOR INSERT WITH CHECK (
        vendor_id IN (
            SELECT id FROM vendors WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Vendors can update their own social links" ON vendor_social_links
    FOR UPDATE USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Vendors can delete their own social links" ON vendor_social_links
    FOR DELETE USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE user_id = auth.uid()
        )
    );

-- حذف الـ view إذا كان موجوداً مسبقاً
DROP VIEW IF EXISTS vendors_with_social_links;

-- إنشاء الـ view الجديد (هذا هو الجزء الأساسي)
CREATE VIEW vendors_with_social_links AS
SELECT 
    v.*,
    COALESCE(vsl.facebook, '') AS facebook,
    COALESCE(vsl.x, '') AS x,
    COALESCE(vsl.instagram, '') AS instagram,
    COALESCE(vsl.website, '') AS website,
    COALESCE(vsl.linkedin, '') AS linkedin,
    COALESCE(vsl.whatsapp, '') AS whatsapp,
    COALESCE(vsl.tiktok, '') AS tiktok,
    COALESCE(vsl.youtube, '') AS youtube,
    COALESCE(vsl.location, '') AS location,
    COALESCE(vsl.phones, '{}') AS phones,
    COALESCE(vsl.visible_facebook, true) AS visible_facebook,
    COALESCE(vsl.visible_x, true) AS visible_x,
    COALESCE(vsl.visible_instagram, true) AS visible_instagram,
    COALESCE(vsl.visible_website, true) AS visible_website,
    COALESCE(vsl.visible_linkedin, true) AS visible_linkedin,
    COALESCE(vsl.visible_whatsapp, true) AS visible_whatsapp,
    COALESCE(vsl.visible_tiktok, true) AS visible_tiktok,
    COALESCE(vsl.visible_youtube, true) AS visible_youtube,
    COALESCE(vsl.visible_phones, true) AS visible_phones
FROM vendors v
LEFT JOIN vendor_social_links vsl ON v.id = vsl.vendor_id;

-- تعليقات
COMMENT ON VIEW vendors_with_social_links IS 'View لدمج بيانات التاجر مع روابط السوشال ميديا';
COMMENT ON TABLE vendor_social_links IS 'جدول ربط التاجر مع روابط السوشال ميديا ومعلومات التواصل';
