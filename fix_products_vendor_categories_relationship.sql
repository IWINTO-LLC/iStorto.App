-- Fix Products and Vendor Categories Relationship
-- This script fixes the foreign key relationship issue between products and categories

-- 1. First, check if vendor_categories table exists and has the right structure
CREATE TABLE IF NOT EXISTS vendor_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(255),
    color VARCHAR(7) DEFAULT '#000000',
    is_active BOOLEAN DEFAULT true,
    vendor_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT vendor_categories_vendor_id_fkey 
        FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
);

-- 2. Drop the old foreign key constraint if it exists
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_id_fkey;

-- 3. Add or update the foreign key constraint to use vendor_categories
ALTER TABLE products 
DROP CONSTRAINT IF EXISTS products_vendor_category_id_fkey;

ALTER TABLE products 
ADD CONSTRAINT products_vendor_category_id_fkey 
FOREIGN KEY (vendor_category_id) 
REFERENCES vendor_categories(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- 4. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_products_vendor_category_id ON products(vendor_category_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);

-- 5. Enable RLS on vendor_categories if not already enabled
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS policies for vendor_categories
DROP POLICY IF EXISTS "vendor_categories_read" ON vendor_categories;
CREATE POLICY "vendor_categories_read" ON vendor_categories
    FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "vendor_categories_insert" ON vendor_categories;
CREATE POLICY "vendor_categories_insert" ON vendor_categories
    FOR INSERT
    WITH CHECK (
        vendor_id IN (
            SELECT id FROM vendors 
            WHERE user_id = auth.uid()
        ) OR auth.role() = 'authenticated'
    );

DROP POLICY IF EXISTS "vendor_categories_update" ON vendor_categories;
CREATE POLICY "vendor_categories_update" ON vendor_categories
    FOR UPDATE
    USING (
        vendor_id IN (
            SELECT id FROM vendors 
            WHERE user_id = auth.uid()
        ) OR auth.role() = 'authenticated'
    )
    WITH CHECK (
        vendor_id IN (
            SELECT id FROM vendors 
            WHERE user_id = auth.uid()
        ) OR auth.role() = 'authenticated'
    );

DROP POLICY IF EXISTS "vendor_categories_delete" ON vendor_categories;
CREATE POLICY "vendor_categories_delete" ON vendor_categories
    FOR DELETE
    USING (
        vendor_id IN (
            SELECT id FROM vendors 
            WHERE user_id = auth.uid()
        ) OR auth.role() = 'authenticated'
    );

-- 7. Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_vendor_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_vendor_categories_updated_at ON vendor_categories;
CREATE TRIGGER update_vendor_categories_updated_at 
    BEFORE UPDATE ON vendor_categories 
    FOR EACH ROW 
    EXECUTE FUNCTION update_vendor_categories_updated_at();

-- 9. Insert some default vendor categories if none exist
INSERT INTO vendor_categories (id, title, description, icon, color, vendor_id) VALUES
    (gen_random_uuid(), 'General', 'General products', 'category', '#FF5722', NULL)
ON CONFLICT (id) DO NOTHING;

-- 10. Verify the setup
SELECT 
    'Products-VendorCategories relationship fixed successfully' as status,
    COUNT(*) as vendor_categories_count
FROM vendor_categories;

-- 11. Check foreign key constraints
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name IN ('products', 'vendor_categories')
ORDER BY tc.table_name, tc.constraint_name;


