-- =============================================
-- User Follows System Setup
-- =============================================
-- This script creates the user_follows table and related functionality
-- for managing user-vendor following relationships

-- Drop existing table if it exists (be careful in production)
DROP TABLE IF EXISTS user_follows CASCADE;

-- Create user_follows table
CREATE TABLE IF NOT EXISTS user_follows (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure a user can only follow a vendor once
    UNIQUE(user_id, vendor_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_follows_user_id ON user_follows(user_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_vendor_id ON user_follows(vendor_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_created_at ON user_follows(created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_user_follows_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER trigger_update_user_follows_updated_at
    BEFORE UPDATE ON user_follows
    FOR EACH ROW
    EXECUTE FUNCTION update_user_follows_updated_at();

-- =============================================
-- RLS (Row Level Security) Policies
-- =============================================

-- Enable RLS on user_follows table
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own follow relationships
CREATE POLICY "Users can view their own follows" ON user_follows
    FOR SELECT
    USING (auth.uid() = user_id OR auth.uid() = vendor_id);

-- Policy: Users can insert their own follow relationships
CREATE POLICY "Users can follow vendors" ON user_follows
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own follow relationships
CREATE POLICY "Users can unfollow vendors" ON user_follows
    FOR DELETE
    USING (auth.uid() = user_id);

-- Policy: Users can update their own follow relationships (if needed)
CREATE POLICY "Users can update their own follows" ON user_follows
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- =============================================
-- Helper Functions
-- =============================================

-- Function to check if a user follows a vendor
CREATE OR REPLACE FUNCTION is_user_following_vendor(user_uuid UUID, vendor_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_follows 
        WHERE user_id = user_uuid AND vendor_id = vendor_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get followers count for a vendor
CREATE OR REPLACE FUNCTION get_vendor_followers_count(vendor_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)::INTEGER 
        FROM user_follows 
        WHERE vendor_id = vendor_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get following count for a user
CREATE OR REPLACE FUNCTION get_user_following_count(user_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)::INTEGER 
        FROM user_follows 
        WHERE user_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to follow a vendor
CREATE OR REPLACE FUNCTION follow_vendor(user_uuid UUID, vendor_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if already following
    IF is_user_following_vendor(user_uuid, vendor_uuid) THEN
        RETURN FALSE; -- Already following
    END IF;
    
    -- Insert follow relationship
    INSERT INTO user_follows (user_id, vendor_id)
    VALUES (user_uuid, vendor_uuid);
    
    RETURN TRUE; -- Successfully followed
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE; -- Error occurred
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to unfollow a vendor
CREATE OR REPLACE FUNCTION unfollow_vendor(user_uuid UUID, vendor_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Delete follow relationship
    DELETE FROM user_follows 
    WHERE user_id = user_uuid AND vendor_id = vendor_uuid;
    
    RETURN FOUND; -- Returns TRUE if a row was deleted
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to toggle follow status
CREATE OR REPLACE FUNCTION toggle_follow_vendor(user_uuid UUID, vendor_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    IF is_user_following_vendor(user_uuid, vendor_uuid) THEN
        RETURN unfollow_vendor(user_uuid, vendor_uuid);
    ELSE
        RETURN follow_vendor(user_uuid, vendor_uuid);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Views for Easy Data Access
-- =============================================

-- View: User's followed vendors with details
CREATE OR REPLACE VIEW user_followed_vendors AS
SELECT 
    uf.user_id,
    uf.vendor_id,
    uf.created_at as followed_at,
    v.organization_name,
    v.organization_bio,
    v.organization_logo,
    v.organization_cover,
    v.is_verified,
    v.organization_activated,
    v.created_at as vendor_created_at
FROM user_follows uf
JOIN vendors v ON uf.vendor_id = v.id
WHERE v.organization_activated = true
ORDER BY uf.created_at DESC;

-- View: Vendor's followers with details
CREATE OR REPLACE VIEW vendor_followers AS
SELECT 
    uf.vendor_id,
    uf.user_id,
    uf.created_at as followed_at,
    u.email,
    u.raw_user_meta_data->>'name' as name,
    u.raw_user_meta_data->>'username' as username,
    u.email_confirmed_at IS NOT NULL as is_active,
    u.created_at as user_created_at
FROM user_follows uf
JOIN auth.users u ON uf.user_id = u.id
ORDER BY uf.created_at DESC;

-- =============================================
-- Grant Permissions
-- =============================================

-- Grant permissions to authenticated users
GRANT SELECT, INSERT, DELETE ON user_follows TO authenticated;
GRANT SELECT ON user_followed_vendors TO authenticated;
GRANT SELECT ON vendor_followers TO authenticated;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION is_user_following_vendor(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_vendor_followers_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_following_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION follow_vendor(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION unfollow_vendor(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_follow_vendor(UUID, UUID) TO authenticated;

-- =============================================
-- Sample Data (Optional - for testing)
-- =============================================

-- Uncomment the following lines to insert sample data
/*
-- Sample follows (replace with actual user and vendor IDs)
INSERT INTO user_follows (user_id, vendor_id) VALUES
    ('user-uuid-1', 'vendor-uuid-1'),
    ('user-uuid-1', 'vendor-uuid-2'),
    ('user-uuid-2', 'vendor-uuid-1');
*/

-- =============================================
-- Usage Examples
-- =============================================

/*
-- Check if user follows a vendor
SELECT is_user_following_vendor('user-uuid', 'vendor-uuid');

-- Get followers count for a vendor
SELECT get_vendor_followers_count('vendor-uuid');

-- Get following count for a user
SELECT get_user_following_count('user-uuid');

-- Follow a vendor
SELECT follow_vendor('user-uuid', 'vendor-uuid');

-- Unfollow a vendor
SELECT unfollow_vendor('user-uuid', 'vendor-uuid');

-- Toggle follow status
SELECT toggle_follow_vendor('user-uuid', 'vendor-uuid');

-- Get user's followed vendors
SELECT * FROM user_followed_vendors WHERE user_id = 'user-uuid';

-- Get vendor's followers
SELECT * FROM vendor_followers WHERE vendor_id = 'vendor-uuid';
*/

-- =============================================
-- Setup Complete
-- =============================================
-- The user_follows system is now ready to use!
-- 
-- Key Features:
-- 1. Secure follow/unfollow functionality
-- 2. Row Level Security (RLS) policies
-- 3. Helper functions for common operations
-- 4. Optimized views for data access
-- 5. Performance indexes
-- 6. Automatic timestamp updates
-- 
-- The Flutter app can now use the FollowController to:
-- - Follow/unfollow vendors
-- - Check follow status
-- - Get followers/following lists
-- - Get counts for statistics
