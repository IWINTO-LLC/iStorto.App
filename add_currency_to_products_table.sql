-- Add currency column to products table
-- This script adds currency support to the products table

-- Add currency column to products table
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'USD';

-- Add comment to the currency column
COMMENT ON COLUMN public.products.currency IS 'Currency ISO code for the product price (e.g., USD, EUR, GBP)';

-- Create index for currency column for better performance
CREATE INDEX IF NOT EXISTS idx_products_currency ON public.products(currency);

-- Create index for vendor_id and currency combination
CREATE INDEX IF NOT EXISTS idx_products_vendor_currency ON public.products(vendor_id, currency);

-- Update existing products to have USD as default currency (if they don't have one)
UPDATE public.products 
SET currency = 'USD' 
WHERE currency IS NULL OR currency = '';

-- Create a function to get products by currency
CREATE OR REPLACE FUNCTION get_products_by_currency(
    vendor_uuid UUID,
    currency_code TEXT DEFAULT 'USD'
)
RETURNS TABLE (
    id UUID,
    vendor_id UUID,
    title TEXT,
    description TEXT,
    price DECIMAL,
    old_price DECIMAL,
    currency TEXT,
    product_type TEXT,
    thumbnail TEXT,
    images TEXT[],
    category_id UUID,
    vendor_category_id UUID,
    is_feature BOOLEAN,
    is_deleted BOOLEAN,
    min_quantity INTEGER,
    sale_percentage INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.vendor_id,
        p.title,
        p.description,
        p.price,
        p.old_price,
        p.currency,
        p.product_type,
        p.thumbnail,
        p.images,
        p.category_id,
        p.vendor_category_id,
        p.is_feature,
        p.is_deleted,
        p.min_quantity,
        p.sale_percentage,
        p.created_at,
        p.updated_at
    FROM public.products p
    WHERE p.vendor_id = vendor_uuid
    AND p.currency = UPPER(currency_code)
    AND p.is_deleted = false
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_products_by_currency(UUID, TEXT) TO authenticated;

-- Create a function to get currency statistics for a vendor
CREATE OR REPLACE FUNCTION get_vendor_currency_stats(vendor_uuid UUID)
RETURNS TABLE (
    currency TEXT,
    product_count BIGINT,
    total_value DECIMAL,
    average_price DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.currency,
        COUNT(*) as product_count,
        SUM(p.price) as total_value,
        AVG(p.price) as average_price
    FROM public.products p
    WHERE p.vendor_id = vendor_uuid
    AND p.is_deleted = false
    GROUP BY p.currency
    ORDER BY product_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_vendor_currency_stats(UUID) TO authenticated;

-- Create a function to convert product prices to a target currency
CREATE OR REPLACE FUNCTION convert_product_prices_to_currency(
    vendor_uuid UUID,
    target_currency TEXT
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    original_price DECIMAL,
    original_currency TEXT,
    converted_price DECIMAL,
    target_currency TEXT
) AS $$
DECLARE
    currency_rate DECIMAL;
BEGIN
    -- Get the exchange rate for the target currency
    SELECT usd_to_coin_exchange_rate INTO currency_rate
    FROM public.currencies 
    WHERE iso = UPPER(target_currency);
    
    -- If currency not found, return empty result
    IF currency_rate IS NULL THEN
        RETURN;
    END IF;
    
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.price as original_price,
        p.currency as original_currency,
        CASE 
            WHEN p.currency = 'USD' THEN p.price * currency_rate
            ELSE (p.price / (
                SELECT c.usd_to_coin_exchange_rate 
                FROM public.currencies c 
                WHERE c.iso = UPPER(p.currency)
            )) * currency_rate
        END as converted_price,
        target_currency
    FROM public.products p
    WHERE p.vendor_id = vendor_uuid
    AND p.is_deleted = false
    AND p.currency IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION convert_product_prices_to_currency(UUID, TEXT) TO authenticated;

-- Create a view for products with currency information
CREATE OR REPLACE VIEW public.products_with_currency AS
SELECT 
    p.*,
    c.name as currency_name,
    c.symbol as currency_symbol,
    c.usd_to_coin_exchange_rate as currency_rate
FROM public.products p
LEFT JOIN public.currencies c ON p.currency = c.iso
WHERE p.is_deleted = false;

-- Grant access to the view
GRANT SELECT ON public.products_with_currency TO authenticated;

-- Add RLS policy for currency column access
CREATE POLICY "Users can view currency of their own products"
ON public.products FOR SELECT
TO authenticated
USING (
    vendor_id IN (
        SELECT id FROM public.vendors WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Users can update currency of their own products"
ON public.products FOR UPDATE
TO authenticated
USING (
    vendor_id IN (
        SELECT id FROM public.vendors WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    vendor_id IN (
        SELECT id FROM public.vendors WHERE user_id = auth.uid()
    )
);

-- Create a trigger to validate currency codes
CREATE OR REPLACE FUNCTION validate_product_currency()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if currency exists in currencies table
    IF NOT EXISTS (
        SELECT 1 FROM public.currencies 
        WHERE iso = UPPER(NEW.currency)
    ) THEN
        RAISE EXCEPTION 'Invalid currency code: %', NEW.currency;
    END IF;
    
    -- Convert currency to uppercase
    NEW.currency = UPPER(NEW.currency);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for currency validation
CREATE TRIGGER validate_product_currency_trigger
    BEFORE INSERT OR UPDATE ON public.products
    FOR EACH ROW
    EXECUTE FUNCTION validate_product_currency();

-- Add some sample data for testing (optional)
-- UPDATE public.products SET currency = 'EUR' WHERE id IN (
--     SELECT id FROM public.products LIMIT 5
-- );

-- UPDATE public.products SET currency = 'GBP' WHERE id IN (
--     SELECT id FROM public.products OFFSET 5 LIMIT 5
-- );

-- Show the updated table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'products' 
AND column_name = 'currency';

