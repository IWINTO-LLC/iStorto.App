-- Create save_for_later table for Supabase
-- This table stores items saved for later by users

CREATE TABLE IF NOT EXISTS save_for_later (
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
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure unique combination of user and product
  UNIQUE(user_id, product_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_save_for_later_user_id ON save_for_later(user_id);
CREATE INDEX IF NOT EXISTS idx_save_for_later_product_id ON save_for_later(product_id);
CREATE INDEX IF NOT EXISTS idx_save_for_later_vendor_id ON save_for_later(vendor_id);
CREATE INDEX IF NOT EXISTS idx_save_for_later_created_at ON save_for_later(created_at);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_save_for_later_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_save_for_later_updated_at 
    BEFORE UPDATE ON save_for_later 
    FOR EACH ROW 
    EXECUTE FUNCTION update_save_for_later_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE save_for_later ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own saved items
CREATE POLICY "Users can view their own saved items" ON save_for_later
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own saved items
CREATE POLICY "Users can insert their own saved items" ON save_for_later
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own saved items
CREATE POLICY "Users can update their own saved items" ON save_for_later
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own saved items
CREATE POLICY "Users can delete their own saved items" ON save_for_later
    FOR DELETE USING (auth.uid() = user_id);

-- Create a view for saved items summary (optional)
CREATE OR REPLACE VIEW saved_items_summary AS
SELECT 
    user_id,
    COUNT(*) as total_saved_items,
    SUM(quantity) as total_quantity,
    SUM(total_price) as total_value,
    COUNT(DISTINCT vendor_id) as unique_vendors,
    MIN(created_at) as first_saved,
    MAX(updated_at) as last_updated
FROM save_for_later
GROUP BY user_id;

-- Grant access to the view
GRANT SELECT ON saved_items_summary TO authenticated;

-- Create a function to clear user's saved items
CREATE OR REPLACE FUNCTION clear_user_saved_items(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    DELETE FROM save_for_later WHERE user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION clear_user_saved_items(UUID) TO authenticated;

-- Create a function to get saved items count for a user
CREATE OR REPLACE FUNCTION get_saved_items_count(user_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM save_for_later 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_saved_items_count(UUID) TO authenticated;

-- Create a function to get saved items total value for a user
CREATE OR REPLACE FUNCTION get_saved_items_total_value(user_uuid UUID)
RETURNS DECIMAL(10,2) AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(total_price), 0.00)
        FROM save_for_later 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_saved_items_total_value(UUID) TO authenticated;

-- Create a function to move item from saved to cart
CREATE OR REPLACE FUNCTION move_saved_item_to_cart(
    user_uuid UUID,
    product_uuid TEXT,
    item_quantity INTEGER DEFAULT 1
)
RETURNS VOID AS $$
DECLARE
    saved_item RECORD;
BEGIN
    -- Get the saved item
    SELECT * INTO saved_item 
    FROM save_for_later 
    WHERE user_id = user_uuid AND product_id = product_uuid;
    
    IF FOUND THEN
        -- Check if item already exists in cart
        IF EXISTS (
            SELECT 1 FROM cart_items 
            WHERE user_id = user_uuid AND product_id = product_uuid
        ) THEN
            -- Update quantity in cart
            UPDATE cart_items 
            SET 
                quantity = quantity + item_quantity,
                total_price = (quantity + item_quantity) * price,
                updated_at = NOW()
            WHERE user_id = user_uuid AND product_id = product_uuid;
        ELSE
            -- Insert new item to cart
            INSERT INTO cart_items (
                user_id, product_id, vendor_id, title, price, 
                quantity, image, total_price, created_at, updated_at
            ) VALUES (
                user_uuid, saved_item.product_id, saved_item.vendor_id, 
                saved_item.title, saved_item.price, item_quantity, 
                saved_item.image, saved_item.price * item_quantity, 
                NOW(), NOW()
            );
        END IF;
        
        -- Remove from saved items
        DELETE FROM save_for_later 
        WHERE user_id = user_uuid AND product_id = product_uuid;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION move_saved_item_to_cart(UUID, TEXT, INTEGER) TO authenticated;
