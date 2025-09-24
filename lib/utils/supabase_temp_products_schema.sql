-- Create temp_products table for bulk Excel operations
CREATE TABLE temp_products (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  vendor_id UUID NULL,
  title TEXT NOT NULL,
  description TEXT NULL,
  price NUMERIC(10, 2) NOT NULL,
  old_price NUMERIC(10, 2) NULL,
  product_type TEXT NULL,
  thumbnail TEXT NULL,
  images TEXT[] NULL DEFAULT '{}'::TEXT[],
  category_id UUID NULL,
  vendor_category_id UUID NULL,
  is_feature BOOLEAN NULL DEFAULT false,
  is_deleted BOOLEAN NULL DEFAULT false,
  min_quantity INTEGER NULL DEFAULT 1,
  sale_percentage INTEGER NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW(),
  
  CONSTRAINT temp_products_pkey PRIMARY KEY (id),
  CONSTRAINT temp_products_category_id_fkey 
    FOREIGN KEY (category_id) REFERENCES categories (id),
  CONSTRAINT temp_products_vendor_category_id_fkey 
    FOREIGN KEY (vendor_category_id) REFERENCES vendor_categories (id),
  CONSTRAINT temp_products_vendor_id_fkey 
    FOREIGN KEY (vendor_id) REFERENCES vendors (id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- Create indexes for better performance
CREATE INDEX idx_temp_products_vendor_id ON temp_products (vendor_id);
CREATE INDEX idx_temp_products_category_id ON temp_products (category_id);
CREATE INDEX idx_temp_products_vendor_category_id ON temp_products (vendor_category_id);
CREATE INDEX idx_temp_products_is_deleted ON temp_products (is_deleted);
CREATE INDEX idx_temp_products_created_at ON temp_products (created_at);
CREATE INDEX idx_temp_products_title ON temp_products USING gin (to_tsvector('english', title));

-- Enable Row Level Security (RLS)
ALTER TABLE temp_products ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Policy for vendors to manage their own temp products
CREATE POLICY "Vendors can manage their own temp products" ON temp_products
  FOR ALL USING (
    vendor_id IN (
      SELECT id FROM vendors 
      WHERE user_id = auth.uid()
    )
  );

-- Policy for admins to view all temp products
CREATE POLICY "Admins can view all temp products" ON temp_products
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() 
      AND role = 'admin'
    )
  );

-- Policy for admins to manage all temp products
CREATE POLICY "Admins can manage all temp products" ON temp_products
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() 
      AND role = 'admin'
    )
  );

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_temp_products_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER trigger_update_temp_products_updated_at
  BEFORE UPDATE ON temp_products
  FOR EACH ROW
  EXECUTE FUNCTION update_temp_products_updated_at();

-- Create view for active temp products
CREATE VIEW active_temp_products AS
SELECT 
  tp.*,
  c.title as category_title,
  c.color as category_color,
  c.icon as category_icon,
  vc.title as vendor_category_title,
  v.name as vendor_name,
  v.email as vendor_email
FROM temp_products tp
LEFT JOIN categories c ON tp.category_id = c.id
LEFT JOIN vendor_categories vc ON tp.vendor_category_id = vc.id
LEFT JOIN vendors v ON tp.vendor_id = v.id
WHERE tp.is_deleted = false;

-- Grant permissions
GRANT ALL ON temp_products TO authenticated;
GRANT ALL ON active_temp_products TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Create function to get temp products statistics
CREATE OR REPLACE FUNCTION get_temp_products_stats(p_vendor_id UUID)
RETURNS TABLE (
  total_count BIGINT,
  active_count BIGINT,
  deleted_count BIGINT,
  by_category JSONB,
  by_type JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) as total_count,
    COUNT(*) FILTER (WHERE is_deleted = false) as active_count,
    COUNT(*) FILTER (WHERE is_deleted = true) as deleted_count,
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'category_id', category_id,
          'category_title', c.title,
          'count', count
        )
      )
      FROM (
        SELECT 
          category_id,
          COUNT(*) as count
        FROM temp_products 
        WHERE vendor_id = p_vendor_id AND is_deleted = false
        GROUP BY category_id
      ) cat_stats
      LEFT JOIN categories c ON cat_stats.category_id = c.id
    ) as by_category,
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'product_type', product_type,
          'count', count
        )
      )
      FROM (
        SELECT 
          product_type,
          COUNT(*) as count
        FROM temp_products 
        WHERE vendor_id = p_vendor_id AND is_deleted = false
        GROUP BY product_type
      ) type_stats
    ) as by_type
  FROM temp_products 
  WHERE vendor_id = p_vendor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_temp_products_stats(UUID) TO authenticated;


