-- إنشاء جدول vendor_social_links لربط التاجر مع روابط السوشال ميديا
CREATE TABLE IF NOT EXISTS vendor_social_links (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    
    -- روابط السوشال ميديا
    facebook TEXT,
    x TEXT,
    instagram TEXT,
    website TEXT,
    linkedin TEXT,
    whatsapp TEXT,
    tiktok TEXT,
    youtube TEXT,
    location TEXT,
    
    -- قائمة أرقام الهواتف (JSON array)
    phones JSONB DEFAULT '[]'::jsonb,
    
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

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_vendor_social_links_vendor_id ON vendor_social_links(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_social_links_created_at ON vendor_social_links(created_at);

-- إنشاء دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_vendor_social_links_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء trigger لتحديث updated_at
CREATE TRIGGER trigger_vendor_social_links_updated_at
    BEFORE UPDATE ON vendor_social_links
    FOR EACH ROW
    EXECUTE FUNCTION update_vendor_social_links_updated_at();

-- إضافة RLS (Row Level Security)
ALTER TABLE vendor_social_links ENABLE ROW LEVEL SECURITY;

-- سياسة للقراءة: يمكن للجميع قراءة روابط السوشال
CREATE POLICY "Anyone can read vendor social links" ON vendor_social_links
    FOR SELECT USING (true);

-- سياسة للإدراج: يمكن للتاجر إدراج روابطه فقط
CREATE POLICY "Vendors can insert their own social links" ON vendor_social_links
    FOR INSERT WITH CHECK (
        vendor_id IN (
            SELECT id FROM vendors WHERE user_id = auth.uid()
        )
    );

-- سياسة للتحديث: يمكن للتاجر تحديث روابطه فقط
CREATE POLICY "Vendors can update their own social links" ON vendor_social_links
    FOR UPDATE USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE user_id = auth.uid()
        )
    );

-- سياسة للحذف: يمكن للتاجر حذف روابطه فقط
CREATE POLICY "Vendors can delete their own social links" ON vendor_social_links
    FOR DELETE USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE user_id = auth.uid()
        )
    );

-- إنشاء view لدمج بيانات التاجر مع روابط السوشال
CREATE OR REPLACE VIEW vendors_with_social_links AS
SELECT 
    v.*,
    vsl.facebook,
    vsl.x,
    vsl.instagram,
    vsl.website,
    vsl.linkedin,
    vsl.whatsapp,
    vsl.tiktok,
    vsl.youtube,
    vsl.location,
    vsl.phones,
    vsl.visible_facebook,
    vsl.visible_x,
    vsl.visible_instagram,
    vsl.visible_website,
    vsl.visible_linkedin,
    vsl.visible_whatsapp,
    vsl.visible_tiktok,
    vsl.visible_youtube,
    vsl.visible_phones,
    vsl.created_at as social_links_created_at,
    vsl.updated_at as social_links_updated_at
FROM vendors v
LEFT JOIN vendor_social_links vsl ON v.id = vsl.vendor_id;

-- تعليقات على الجدول والأعمدة
COMMENT ON TABLE vendor_social_links IS 'جدول ربط التاجر مع روابط السوشال ميديا ومعلومات التواصل';
COMMENT ON COLUMN vendor_social_links.vendor_id IS 'معرف التاجر';
COMMENT ON COLUMN vendor_social_links.phones IS 'قائمة أرقام الهواتف بصيغة JSON';
COMMENT ON COLUMN vendor_social_links.visible_facebook IS 'إظهار رابط الفيسبوك في صفحة المتجر';
COMMENT ON COLUMN vendor_social_links.visible_phones IS 'إظهار أرقام الهواتف في صفحة المتجر';
