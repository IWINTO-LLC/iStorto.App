-- Fix Banner RLS Policies for Company Banners
-- This script adds proper INSERT, UPDATE, and DELETE policies for company banners

-- Drop the incorrect "Admins can manage company banners" policy
DROP POLICY IF EXISTS "Admins can manage company banners" ON banners;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Authenticated users can view company banners" ON banners;
DROP POLICY IF EXISTS "Anyone can view active banners" ON banners;

-- Create separate policies for company banners

-- 1. Allow EVERYONE (including guests) to view ALL banners (active or not)
-- This is useful for admin pages and public viewing
CREATE POLICY "Everyone can view all banners" ON banners
    FOR SELECT USING (true);

-- 2. Allow authenticated users to insert company banners
CREATE POLICY "Authenticated users can insert company banners" ON banners
    FOR INSERT WITH CHECK (
        scope = 'company' AND
        vendor_id IS NULL AND
        auth.role() = 'authenticated'
    );

-- 3. Allow authenticated users to update company banners
CREATE POLICY "Authenticated users can update company banners" ON banners
    FOR UPDATE USING (
        scope = 'company' AND
        auth.role() = 'authenticated'
    )
    WITH CHECK (
        scope = 'company' AND
        auth.role() = 'authenticated'
    );

-- 4. Allow authenticated users to delete company banners
CREATE POLICY "Authenticated users can delete company banners" ON banners
    FOR DELETE USING (
        scope = 'company' AND
        auth.role() = 'authenticated'
    );

-- Note: If you want to restrict to admin users only, you need to:
-- 1. Add an 'is_admin' column to your user_profiles table
-- 2. Update these policies to check: 
--    EXISTS (SELECT 1 FROM user_profiles WHERE user_id = auth.uid() AND is_admin = true)

