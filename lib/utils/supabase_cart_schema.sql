-- Create cart_items table for Supabase
-- This table stores individual cart items for each user

CREATE TABLE IF NOT EXISTS cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  vendor_id TEXT,
  title TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  quantity INTEGER NOT NULL DEFAULT 1,
  image TEXT,
  total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_vendor_id ON cart_items(vendor_id);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_cart_items_updated_at 
    BEFORE UPDATE ON cart_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own cart items
CREATE POLICY "Users can view their own cart items" ON cart_items
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own cart items
CREATE POLICY "Users can insert their own cart items" ON cart_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own cart items
CREATE POLICY "Users can update their own cart items" ON cart_items
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own cart items
CREATE POLICY "Users can delete their own cart items" ON cart_items
    FOR DELETE USING (auth.uid() = user_id);

-- Create a view for cart summary (optional)
CREATE OR REPLACE VIEW cart_summary AS
SELECT 
    user_id,
    COUNT(*) as total_items,
    SUM(quantity) as total_quantity,
    SUM(total_price) as total_value,
    COUNT(DISTINCT vendor_id) as unique_vendors,
    MIN(created_at) as first_added,
    MAX(updated_at) as last_updated
FROM cart_items
GROUP BY user_id;

-- Grant access to the view
GRANT SELECT ON cart_summary TO authenticated;

-- Create a function to clear user's cart
CREATE OR REPLACE FUNCTION clear_user_cart(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    DELETE FROM cart_items WHERE user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION clear_user_cart(UUID) TO authenticated;

-- Create a function to get cart items count for a user
CREATE OR REPLACE FUNCTION get_cart_items_count(user_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(quantity), 0)
        FROM cart_items 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_cart_items_count(UUID) TO authenticated;

-- Create a function to get cart total value for a user
CREATE OR REPLACE FUNCTION get_cart_total_value(user_uuid UUID)
RETURNS DECIMAL(10,2) AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(total_price), 0.00)
        FROM cart_items 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_cart_total_value(UUID) TO authenticated;
