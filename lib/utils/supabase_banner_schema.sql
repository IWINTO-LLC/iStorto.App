-- Create banners table for Supabase with vendor support
-- This table stores banners for both company and vendors

CREATE TABLE IF NOT EXISTS banners (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  image TEXT NOT NULL,
  target_screen TEXT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT false,
  vendor_id TEXT, -- NULL for company banners, vendor ID for vendor banners
  scope TEXT NOT NULL DEFAULT 'company' CHECK (scope IN ('company', 'vendor')),
  title TEXT,
  description TEXT,
  priority INTEGER DEFAULT 0, -- Higher number = higher priority
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_banners_scope ON banners(scope);
CREATE INDEX IF NOT EXISTS idx_banners_vendor_id ON banners(vendor_id);
CREATE INDEX IF NOT EXISTS idx_banners_active ON banners(active);
CREATE INDEX IF NOT EXISTS idx_banners_priority ON banners(priority DESC);
CREATE INDEX IF NOT EXISTS idx_banners_scope_active ON banners(scope, active);
CREATE INDEX IF NOT EXISTS idx_banners_vendor_active ON banners(vendor_id, active);
CREATE INDEX IF NOT EXISTS idx_banners_target_screen ON banners(target_screen);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_banners_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_banners_updated_at 
    BEFORE UPDATE ON banners 
    FOR EACH ROW 
    EXECUTE FUNCTION update_banners_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Everyone can view active banners
CREATE POLICY "Anyone can view active banners" ON banners
    FOR SELECT USING (active = true);

-- Authenticated users can view all banners (for admin purposes)
CREATE POLICY "Authenticated users can view all banners" ON banners
    FOR SELECT USING (auth.role() = 'authenticated');

-- Only vendors can insert their own banners
CREATE POLICY "Vendors can insert their own banners" ON banners
    FOR INSERT WITH CHECK (
        scope = 'vendor' AND 
        vendor_id IS NOT NULL AND
        vendor_id = auth.uid()::text
    );

-- Only vendors can update their own banners
CREATE POLICY "Vendors can update their own banners" ON banners
    FOR UPDATE USING (
        scope = 'vendor' AND 
        vendor_id IS NOT NULL AND
        vendor_id = auth.uid()::text
    );

-- Only vendors can delete their own banners
CREATE POLICY "Vendors can delete their own banners" ON banners
    FOR DELETE USING (
        scope = 'vendor' AND 
        vendor_id IS NOT NULL AND
        vendor_id = auth.uid()::text
    );

-- Company banners can only be managed by admins (you can add admin role check later)
CREATE POLICY "Admins can manage company banners" ON banners
    FOR ALL USING (
        scope = 'company' AND
        auth.role() = 'authenticated' -- You can add admin role check here
    );

-- Create a view for active banners with priority sorting
CREATE OR REPLACE VIEW active_banners AS
SELECT 
    id,
    image,
    target_screen,
    vendor_id,
    scope,
    title,
    description,
    priority,
    created_at,
    updated_at
FROM banners
WHERE active = true
ORDER BY priority DESC, created_at DESC;

-- Grant access to the view
GRANT SELECT ON active_banners TO authenticated;

-- Create a view for company banners only
CREATE OR REPLACE VIEW company_banners AS
SELECT 
    id,
    image,
    target_screen,
    title,
    description,
    priority,
    created_at,
    updated_at
FROM banners
WHERE active = true AND scope = 'company'
ORDER BY priority DESC, created_at DESC;

-- Grant access to the view
GRANT SELECT ON company_banners TO authenticated;

-- Create a view for vendor banners
CREATE OR REPLACE VIEW vendor_banners AS
SELECT 
    id,
    image,
    target_screen,
    vendor_id,
    title,
    description,
    priority,
    created_at,
    updated_at
FROM banners
WHERE active = true AND scope = 'vendor'
ORDER BY priority DESC, created_at DESC;

-- Grant access to the view
GRANT SELECT ON vendor_banners TO authenticated;

-- Create a function to get banners by scope
CREATE OR REPLACE FUNCTION get_banners_by_scope(banner_scope TEXT)
RETURNS TABLE (
    id UUID,
    image TEXT,
    target_screen TEXT,
    vendor_id TEXT,
    scope TEXT,
    title TEXT,
    description TEXT,
    priority INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.image,
        b.target_screen,
        b.vendor_id,
        b.scope,
        b.title,
        b.description,
        b.priority,
        b.created_at,
        b.updated_at
    FROM banners b
    WHERE b.active = true AND b.scope = banner_scope
    ORDER BY b.priority DESC, b.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_banners_by_scope(TEXT) TO authenticated;

-- Create a function to get banners for a specific vendor
CREATE OR REPLACE FUNCTION get_vendor_banners(vendor_uuid TEXT)
RETURNS TABLE (
    id UUID,
    image TEXT,
    target_screen TEXT,
    title TEXT,
    description TEXT,
    priority INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.image,
        b.target_screen,
        b.title,
        b.description,
        b.priority,
        b.created_at,
        b.updated_at
    FROM banners b
    WHERE b.active = true 
        AND b.scope = 'vendor' 
        AND b.vendor_id = vendor_uuid
    ORDER BY b.priority DESC, b.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_vendor_banners(TEXT) TO authenticated;

-- Create a function to get banners for a specific target screen
CREATE OR REPLACE FUNCTION get_banners_by_target_screen(screen_name TEXT)
RETURNS TABLE (
    id UUID,
    image TEXT,
    target_screen TEXT,
    vendor_id TEXT,
    scope TEXT,
    title TEXT,
    description TEXT,
    priority INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.image,
        b.target_screen,
        b.vendor_id,
        b.scope,
        b.title,
        b.description,
        b.priority,
        b.created_at,
        b.updated_at
    FROM banners b
    WHERE b.active = true AND b.target_screen = screen_name
    ORDER BY b.priority DESC, b.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_banners_by_target_screen(TEXT) TO authenticated;

-- Create a function to get mixed banners (company + vendor) for a specific target screen
CREATE OR REPLACE FUNCTION get_mixed_banners_for_screen(screen_name TEXT, vendor_uuid TEXT DEFAULT NULL)
RETURNS TABLE (
    id UUID,
    image TEXT,
    target_screen TEXT,
    vendor_id TEXT,
    scope TEXT,
    title TEXT,
    description TEXT,
    priority INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.image,
        b.target_screen,
        b.vendor_id,
        b.scope,
        b.title,
        b.description,
        b.priority,
        b.created_at,
        b.updated_at
    FROM banners b
    WHERE b.active = true 
        AND b.target_screen = screen_name
        AND (
            b.scope = 'company' OR 
            (b.scope = 'vendor' AND b.vendor_id = vendor_uuid)
        )
    ORDER BY b.priority DESC, b.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_mixed_banners_for_screen(TEXT, TEXT) TO authenticated;

-- Create a function to get banner statistics
CREATE OR REPLACE FUNCTION get_banner_statistics()
RETURNS TABLE (
    total_banners BIGINT,
    company_banners BIGINT,
    vendor_banners BIGINT,
    active_banners BIGINT,
    inactive_banners BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_banners,
        COUNT(*) FILTER (WHERE scope = 'company') as company_banners,
        COUNT(*) FILTER (WHERE scope = 'vendor') as vendor_banners,
        COUNT(*) FILTER (WHERE active = true) as active_banners,
        COUNT(*) FILTER (WHERE active = false) as inactive_banners
    FROM banners;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_banner_statistics() TO authenticated;

-- Insert some sample data
INSERT INTO banners (image, target_screen, active, scope, title, description, priority) VALUES
('https://example.com/company-banner1.jpg', 'home', true, 'company', 'عرض خاص', 'عرض خاص على جميع المنتجات', 100),
('https://example.com/company-banner2.jpg', 'home', true, 'company', 'توصيل مجاني', 'توصيل مجاني لجميع الطلبات', 90),
('https://example.com/company-banner3.jpg', 'products', true, 'company', 'منتجات جديدة', 'اكتشف أحدث المنتجات', 80);

-- Note: Vendor banners will be inserted by vendors through the application
