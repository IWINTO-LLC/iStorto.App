-- Create currencies table for Supabase
-- This table stores currency information and exchange rates

CREATE TABLE IF NOT EXISTS currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    iso TEXT NOT NULL UNIQUE,
    usd_to_coin_exchange_rate DECIMAL(10,6) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_currencies_iso ON currencies(iso);
CREATE INDEX IF NOT EXISTS idx_currencies_name ON currencies(name);
CREATE INDEX IF NOT EXISTS idx_currencies_exchange_rate ON currencies(usd_to_coin_exchange_rate);
CREATE INDEX IF NOT EXISTS idx_currencies_created_at ON currencies(created_at);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_currencies_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_currencies_updated_at 
    BEFORE UPDATE ON currencies 
    FOR EACH ROW 
    EXECUTE FUNCTION update_currencies_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE currencies ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Everyone can view currencies (for public exchange rates)
CREATE POLICY "Anyone can view currencies" ON currencies
    FOR SELECT USING (true);

-- Only authenticated users can insert currencies (admin function)
CREATE POLICY "Authenticated users can insert currencies" ON currencies
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Only authenticated users can update currencies (admin function)
CREATE POLICY "Authenticated users can update currencies" ON currencies
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Only authenticated users can delete currencies (admin function)
CREATE POLICY "Authenticated users can delete currencies" ON currencies
    FOR DELETE USING (auth.role() = 'authenticated');

-- Create a view for popular currencies
CREATE OR REPLACE VIEW popular_currencies AS
SELECT 
    id,
    name,
    iso,
    usd_to_coin_exchange_rate,
    created_at,
    updated_at
FROM currencies
WHERE iso IN ('USD', 'EUR', 'GBP', 'JPY', 'SAR', 'AED', 'EGP', 'CAD', 'AUD', 'CHF')
ORDER BY 
    CASE iso
        WHEN 'USD' THEN 1
        WHEN 'EUR' THEN 2
        WHEN 'GBP' THEN 3
        WHEN 'JPY' THEN 4
        WHEN 'SAR' THEN 5
        WHEN 'AED' THEN 6
        WHEN 'EGP' THEN 7
        ELSE 8
    END;

-- Grant access to the view
GRANT SELECT ON popular_currencies TO authenticated;

-- Create a function to get currency by ISO
CREATE OR REPLACE FUNCTION get_currency_by_iso(currency_iso TEXT)
RETURNS TABLE (
    id UUID,
    name TEXT,
    iso TEXT,
    usd_to_coin_exchange_rate DECIMAL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.iso,
        c.usd_to_coin_exchange_rate,
        c.created_at,
        c.updated_at
    FROM currencies c
    WHERE c.iso = UPPER(currency_iso);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_currency_by_iso(TEXT) TO authenticated;

-- Create a function to convert between currencies
CREATE OR REPLACE FUNCTION convert_currency(
    from_iso TEXT,
    to_iso TEXT,
    amount DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    from_rate DECIMAL;
    to_rate DECIMAL;
    result DECIMAL;
BEGIN
    -- Get exchange rates
    SELECT usd_to_coin_exchange_rate INTO from_rate
    FROM currencies 
    WHERE iso = UPPER(from_iso);
    
    SELECT usd_to_coin_exchange_rate INTO to_rate
    FROM currencies 
    WHERE iso = UPPER(to_iso);
    
    -- Check if both currencies exist
    IF from_rate IS NULL OR to_rate IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Convert to USD first, then to target currency
    result := (amount / from_rate) * to_rate;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION convert_currency(TEXT, TEXT, DECIMAL) TO authenticated;

-- Create a function to get currency statistics
CREATE OR REPLACE FUNCTION get_currency_statistics()
RETURNS TABLE (
    total_currencies BIGINT,
    average_rate DECIMAL,
    highest_rate DECIMAL,
    lowest_rate DECIMAL,
    most_recent_update TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_currencies,
        AVG(usd_to_coin_exchange_rate) as average_rate,
        MAX(usd_to_coin_exchange_rate) as highest_rate,
        MIN(usd_to_coin_exchange_rate) as lowest_rate,
        MAX(updated_at) as most_recent_update
    FROM currencies;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_currency_statistics() TO authenticated;

-- Create a function to search currencies
CREATE OR REPLACE FUNCTION search_currencies(search_term TEXT)
RETURNS TABLE (
    id UUID,
    name TEXT,
    iso TEXT,
    usd_to_coin_exchange_rate DECIMAL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.iso,
        c.usd_to_coin_exchange_rate,
        c.created_at,
        c.updated_at
    FROM currencies c
    WHERE 
        c.name ILIKE '%' || search_term || '%' OR
        c.iso ILIKE '%' || search_term || '%'
    ORDER BY c.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION search_currencies(TEXT) TO authenticated;

-- Create a function to update exchange rates
CREATE OR REPLACE FUNCTION update_exchange_rates(
    rate_updates JSONB
)
RETURNS INTEGER AS $$
DECLARE
    update_count INTEGER := 0;
    rate_record JSONB;
BEGIN
    -- Loop through the JSONB array of rate updates
    FOR rate_record IN SELECT * FROM jsonb_array_elements(rate_updates)
    LOOP
        UPDATE currencies 
        SET 
            usd_to_coin_exchange_rate = (rate_record->>'rate')::DECIMAL,
            updated_at = NOW()
        WHERE iso = UPPER(rate_record->>'iso');
        
        IF FOUND THEN
            update_count := update_count + 1;
        END IF;
    END LOOP;
    
    RETURN update_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION update_exchange_rates(JSONB) TO authenticated;

-- Insert some sample currencies
INSERT INTO currencies (name, iso, usd_to_coin_exchange_rate) VALUES
('US Dollar', 'USD', 1.000000),
('Euro', 'EUR', 0.850000),
('British Pound', 'GBP', 0.730000),
('Japanese Yen', 'JPY', 110.000000),
('Saudi Riyal', 'SAR', 3.750000),
('UAE Dirham', 'AED', 3.670000),
('Egyptian Pound', 'EGP', 15.700000),
('Canadian Dollar', 'CAD', 1.250000),
('Australian Dollar', 'AUD', 1.350000),
('Swiss Franc', 'CHF', 0.920000),
('Chinese Yuan', 'CNY', 6.450000),
('Indian Rupee', 'INR', 74.000000),
('Brazilian Real', 'BRL', 5.200000),
('Russian Ruble', 'RUB', 73.000000),
('South Korean Won', 'KRW', 1180.000000),
('Mexican Peso', 'MXN', 20.000000),
('Turkish Lira', 'TRY', 8.500000),
('South African Rand', 'ZAR', 14.500000),
('New Zealand Dollar', 'NZD', 1.400000),
('Norwegian Krone', 'NOK', 8.500000);

-- Create a function to get exchange rate history (for future implementation)
CREATE OR REPLACE FUNCTION get_exchange_rate_history(
    currency_iso TEXT,
    days_back INTEGER DEFAULT 30
)
RETURNS TABLE (
    date DATE,
    rate DECIMAL,
    change_percent DECIMAL
) AS $$
BEGIN
    -- This would require a separate history table
    -- For now, return empty result
    RETURN QUERY
    SELECT NULL::DATE, NULL::DECIMAL, NULL::DECIMAL
    WHERE FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_exchange_rate_history(TEXT, INTEGER) TO authenticated;
