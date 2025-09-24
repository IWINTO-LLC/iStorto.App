-- Vendor Analytics Views and Functions for Supabase
-- This file contains views and functions to help vendors track their products

-- ==============================================
-- VENDOR SAVED ITEMS ANALYTICS
-- ==============================================

-- View: Products saved by users (for vendors to see their products)
CREATE OR REPLACE VIEW vendor_saved_products AS
SELECT 
    sfl.vendor_id,
    sfl.product_id,
    sfl.title as product_title,
    sfl.price,
    sfl.image,
    COUNT(sfl.id) as times_saved,
    COUNT(DISTINCT sfl.user_id) as unique_users_saved,
    SUM(sfl.quantity) as total_quantity_saved,
    SUM(sfl.total_price) as total_value_saved,
    MIN(sfl.created_at) as first_saved,
    MAX(sfl.created_at) as last_saved,
    AVG(sfl.price) as average_price
FROM save_for_later sfl
WHERE sfl.vendor_id IS NOT NULL
GROUP BY sfl.vendor_id, sfl.product_id, sfl.title, sfl.price, sfl.image
ORDER BY times_saved DESC;

-- Grant access to the view
GRANT SELECT ON vendor_saved_products TO authenticated;

-- ==============================================
-- VENDOR CART ANALYTICS
-- ==============================================

-- View: Products in user carts (for vendors to see their products in carts)
CREATE OR REPLACE VIEW vendor_cart_products AS
SELECT 
    ci.vendor_id,
    ci.product_id,
    ci.title as product_title,
    ci.price,
    ci.image,
    COUNT(ci.id) as times_in_cart,
    COUNT(DISTINCT ci.user_id) as unique_users_in_cart,
    SUM(ci.quantity) as total_quantity_in_cart,
    SUM(ci.total_price) as total_value_in_cart,
    MIN(ci.created_at) as first_added_to_cart,
    MAX(ci.updated_at) as last_updated_in_cart,
    AVG(ci.price) as average_price
FROM cart_items ci
WHERE ci.vendor_id IS NOT NULL
GROUP BY ci.vendor_id, ci.product_id, ci.title, ci.price, ci.image
ORDER BY times_in_cart DESC;

-- Grant access to the view
GRANT SELECT ON vendor_cart_products TO authenticated;

-- ==============================================
-- VENDOR COMBINED ANALYTICS
-- ==============================================

-- View: Combined analytics for vendors (saved + cart)
CREATE OR REPLACE VIEW vendor_product_analytics AS
SELECT 
    COALESCE(saved.vendor_id, cart.vendor_id) as vendor_id,
    COALESCE(saved.product_id, cart.product_id) as product_id,
    COALESCE(saved.product_title, cart.product_title) as product_title,
    COALESCE(saved.price, cart.price) as price,
    COALESCE(saved.image, cart.image) as image,
    
    -- Saved items stats
    COALESCE(saved.times_saved, 0) as times_saved,
    COALESCE(saved.unique_users_saved, 0) as unique_users_saved,
    COALESCE(saved.total_quantity_saved, 0) as total_quantity_saved,
    COALESCE(saved.total_value_saved, 0) as total_value_saved,
    
    -- Cart items stats
    COALESCE(cart.times_in_cart, 0) as times_in_cart,
    COALESCE(cart.unique_users_in_cart, 0) as unique_users_in_cart,
    COALESCE(cart.total_quantity_in_cart, 0) as total_quantity_in_cart,
    COALESCE(cart.total_value_in_cart, 0) as total_value_in_cart,
    
    -- Combined metrics
    (COALESCE(saved.times_saved, 0) + COALESCE(cart.times_in_cart, 0)) as total_interactions,
    (COALESCE(saved.unique_users_saved, 0) + COALESCE(cart.unique_users_in_cart, 0)) as total_unique_users,
    (COALESCE(saved.total_value_saved, 0) + COALESCE(cart.total_value_in_cart, 0)) as total_potential_value,
    
    -- Engagement score (weighted combination)
    (COALESCE(saved.times_saved, 0) * 1.0 + COALESCE(cart.times_in_cart, 0) * 2.0) as engagement_score

FROM vendor_saved_products saved
FULL OUTER JOIN vendor_cart_products cart 
    ON saved.vendor_id = cart.vendor_id AND saved.product_id = cart.product_id
ORDER BY engagement_score DESC;

-- Grant access to the view
GRANT SELECT ON vendor_product_analytics TO authenticated;

-- ==============================================
-- VENDOR SUMMARY ANALYTICS
-- ==============================================

-- View: Overall vendor performance summary
CREATE OR REPLACE VIEW vendor_summary_analytics AS
SELECT 
    vendor_id,
    COUNT(DISTINCT product_id) as total_products,
    SUM(times_saved) as total_saves,
    SUM(unique_users_saved) as total_unique_savers,
    SUM(times_in_cart) as total_cart_additions,
    SUM(unique_users_in_cart) as total_unique_cart_users,
    SUM(total_potential_value) as total_potential_revenue,
    AVG(engagement_score) as average_engagement_score,
    MAX(GREATEST(
        COALESCE(first_saved, '1900-01-01'::timestamp),
        COALESCE(first_added_to_cart, '1900-01-01'::timestamp)
    )) as most_recent_activity
FROM vendor_product_analytics
GROUP BY vendor_id
ORDER BY total_potential_revenue DESC;

-- Grant access to the view
GRANT SELECT ON vendor_summary_analytics TO authenticated;

-- ==============================================
-- FUNCTIONS FOR VENDORS
-- ==============================================

-- Function: Get products saved by users for a specific vendor
CREATE OR REPLACE FUNCTION get_vendor_saved_products(vendor_uuid TEXT)
RETURNS TABLE (
    product_id TEXT,
    product_title TEXT,
    price DECIMAL,
    image TEXT,
    times_saved BIGINT,
    unique_users_saved BIGINT,
    total_quantity_saved BIGINT,
    total_value_saved DECIMAL,
    first_saved TIMESTAMP,
    last_saved TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vsp.product_id,
        vsp.product_title,
        vsp.price,
        vsp.image,
        vsp.times_saved,
        vsp.unique_users_saved,
        vsp.total_quantity_saved,
        vsp.total_value_saved,
        vsp.first_saved,
        vsp.last_saved
    FROM vendor_saved_products vsp
    WHERE vsp.vendor_id = vendor_uuid
    ORDER BY vsp.times_saved DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_vendor_saved_products(TEXT) TO authenticated;

-- Function: Get products in carts for a specific vendor
CREATE OR REPLACE FUNCTION get_vendor_cart_products(vendor_uuid TEXT)
RETURNS TABLE (
    product_id TEXT,
    product_title TEXT,
    price DECIMAL,
    image TEXT,
    times_in_cart BIGINT,
    unique_users_in_cart BIGINT,
    total_quantity_in_cart BIGINT,
    total_value_in_cart DECIMAL,
    first_added_to_cart TIMESTAMP,
    last_updated_in_cart TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vcp.product_id,
        vcp.product_title,
        vcp.price,
        vcp.image,
        vcp.times_in_cart,
        vcp.unique_users_in_cart,
        vcp.total_quantity_in_cart,
        vcp.total_value_in_cart,
        vcp.first_added_to_cart,
        vcp.last_updated_in_cart
    FROM vendor_cart_products vcp
    WHERE vcp.vendor_id = vendor_uuid
    ORDER BY vcp.times_in_cart DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_vendor_cart_products(TEXT) TO authenticated;

-- Function: Get combined analytics for a specific vendor
CREATE OR REPLACE FUNCTION get_vendor_analytics(vendor_uuid TEXT)
RETURNS TABLE (
    product_id TEXT,
    product_title TEXT,
    price DECIMAL,
    image TEXT,
    times_saved BIGINT,
    unique_users_saved BIGINT,
    times_in_cart BIGINT,
    unique_users_in_cart BIGINT,
    total_interactions BIGINT,
    total_unique_users BIGINT,
    total_potential_value DECIMAL,
    engagement_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vpa.product_id,
        vpa.product_title,
        vpa.price,
        vpa.image,
        vpa.times_saved,
        vpa.unique_users_saved,
        vpa.times_in_cart,
        vpa.unique_users_in_cart,
        vpa.total_interactions,
        vpa.total_unique_users,
        vpa.total_potential_value,
        vpa.engagement_score
    FROM vendor_product_analytics vpa
    WHERE vpa.vendor_id = vendor_uuid
    ORDER BY vpa.engagement_score DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_vendor_analytics(TEXT) TO authenticated;

-- Function: Get vendor summary
CREATE OR REPLACE FUNCTION get_vendor_summary(vendor_uuid TEXT)
RETURNS TABLE (
    total_products BIGINT,
    total_saves BIGINT,
    total_unique_savers BIGINT,
    total_cart_additions BIGINT,
    total_unique_cart_users BIGINT,
    total_potential_revenue DECIMAL,
    average_engagement_score DECIMAL,
    most_recent_activity TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vsa.total_products,
        vsa.total_saves,
        vsa.total_unique_savers,
        vsa.total_cart_additions,
        vsa.total_unique_cart_users,
        vsa.total_potential_revenue,
        vsa.average_engagement_score,
        vsa.most_recent_activity
    FROM vendor_summary_analytics vsa
    WHERE vsa.vendor_id = vendor_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_vendor_summary(TEXT) TO authenticated;

-- ==============================================
-- REAL-TIME NOTIFICATIONS (Optional)
-- ==============================================

-- Function: Get recent activity for vendors (last 24 hours)
CREATE OR REPLACE FUNCTION get_vendor_recent_activity(vendor_uuid TEXT)
RETURNS TABLE (
    activity_type TEXT,
    product_id TEXT,
    product_title TEXT,
    user_count BIGINT,
    total_quantity BIGINT,
    total_value DECIMAL,
    activity_time TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'saved' as activity_type,
        sfl.product_id,
        sfl.title as product_title,
        COUNT(DISTINCT sfl.user_id) as user_count,
        SUM(sfl.quantity) as total_quantity,
        SUM(sfl.total_price) as total_value,
        MAX(sfl.created_at) as activity_time
    FROM save_for_later sfl
    WHERE sfl.vendor_id = vendor_uuid 
        AND sfl.created_at >= NOW() - INTERVAL '24 hours'
    GROUP BY sfl.product_id, sfl.title
    
    UNION ALL
    
    SELECT 
        'cart' as activity_type,
        ci.product_id,
        ci.title as product_title,
        COUNT(DISTINCT ci.user_id) as user_count,
        SUM(ci.quantity) as total_quantity,
        SUM(ci.total_price) as total_value,
        MAX(ci.updated_at) as activity_time
    FROM cart_items ci
    WHERE ci.vendor_id = vendor_uuid 
        AND ci.updated_at >= NOW() - INTERVAL '24 hours'
    GROUP BY ci.product_id, ci.title
    
    ORDER BY activity_time DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_vendor_recent_activity(TEXT) TO authenticated;

-- ==============================================
-- INDEXES FOR PERFORMANCE
-- ==============================================

-- Create indexes for better performance on vendor analytics
CREATE INDEX IF NOT EXISTS idx_save_for_later_vendor_created ON save_for_later(vendor_id, created_at);
CREATE INDEX IF NOT EXISTS idx_cart_items_vendor_updated ON cart_items(vendor_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_save_for_later_vendor_product ON save_for_later(vendor_id, product_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_vendor_product ON cart_items(vendor_id, product_id);
