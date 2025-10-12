-- Fix Vendors Table RLS Policy for Updates
-- Issue: Users cannot update their own vendor records due to RLS policy
-- Solution: Add proper UPDATE policy that allows vendors to update their own records

-- ============================================
-- STEP 1: Check Current Policies
-- ============================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'vendors'
ORDER BY policyname;

-- ============================================
-- STEP 2: Drop Existing UPDATE Policy (if any)
-- ============================================
DROP POLICY IF EXISTS "Users can update their own vendor records" ON vendors;
DROP POLICY IF EXISTS "Vendors can update own profile" ON vendors;
DROP POLICY IF EXISTS "Enable update for vendors" ON vendors;
DROP POLICY IF EXISTS "Allow vendors to update own data" ON vendors;

-- ============================================
-- STEP 3: Create Proper UPDATE Policy
-- ============================================

-- Allow users to update their own vendor records
CREATE POLICY "Enable update for vendor owners"
ON vendors
FOR UPDATE
TO authenticated
USING (
  auth.uid() = user_id
)
WITH CHECK (
  auth.uid() = user_id
);

-- ============================================
-- STEP 4: Verify SELECT Policy Exists
-- ============================================

-- Ensure users can read their own vendor data
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'vendors' 
    AND policyname = 'Enable read access for all users'
  ) THEN
    CREATE POLICY "Enable read access for all users"
    ON vendors
    FOR SELECT
    TO authenticated
    USING (true);
  END IF;
END $$;

-- ============================================
-- STEP 5: Verify INSERT Policy Exists
-- ============================================

-- Ensure users can insert their own vendor records
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'vendors' 
    AND policyname = 'Enable insert for authenticated users'
  ) THEN
    CREATE POLICY "Enable insert for authenticated users"
    ON vendors
    FOR INSERT
    TO authenticated
    WITH CHECK (
      auth.uid() = user_id
    );
  END IF;
END $$;

-- ============================================
-- STEP 6: Verify DELETE Policy (Soft Delete)
-- ============================================

-- Allow vendors to soft delete (set organization_deleted = true)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'vendors' 
    AND policyname LIKE '%delete%'
  ) THEN
    CREATE POLICY "Enable delete for vendor owners"
    ON vendors
    FOR DELETE
    TO authenticated
    USING (
      auth.uid() = user_id
    );
  END IF;
END $$;

-- ============================================
-- STEP 7: Verify RLS is Enabled
-- ============================================

-- Ensure RLS is enabled on vendors table
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 8: Grant Necessary Permissions
-- ============================================

-- Grant permissions to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON vendors TO authenticated;

-- ============================================
-- STEP 9: Test the Policy
-- ============================================

-- Test query to verify policies work
-- Replace 'YOUR_USER_ID' with an actual user_id from your user_profiles table
/*
SELECT 
  id, 
  user_id, 
  organization_name,
  organization_bio,
  organization_activated,
  organization_deleted
FROM vendors 
WHERE user_id = 'YOUR_USER_ID';
*/

-- ============================================
-- STEP 10: Verify All Policies
-- ============================================

SELECT 
    policyname,
    cmd as operation,
    CASE 
      WHEN qual IS NOT NULL THEN 'USING: ' || qual::text
      ELSE 'No USING clause'
    END as using_clause,
    CASE 
      WHEN with_check IS NOT NULL THEN 'WITH CHECK: ' || with_check::text
      ELSE 'No WITH CHECK clause'
    END as with_check_clause
FROM pg_policies
WHERE tablename = 'vendors'
ORDER BY cmd, policyname;

-- ============================================
-- TROUBLESHOOTING
-- ============================================

-- If issues persist, you can temporarily disable RLS for testing:
-- ALTER TABLE vendors DISABLE ROW LEVEL SECURITY;

-- Then enable it back after fixing:
-- ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- ============================================
-- NOTES
-- ============================================

/*
The key points for the UPDATE policy:
1. USING clause: Determines which rows can be updated
   - auth.uid() = user_id means users can only update records where they are the owner

2. WITH CHECK clause: Validates the updated data
   - auth.uid() = user_id ensures the user_id cannot be changed to someone else

3. This allows vendors to:
   - Update their organization_name, organization_bio, etc.
   - Toggle organization_activated, organization_deleted
   - Update payment settings (enable_cod, enable_iwinto_payment)
   - Update images and other vendor-specific fields

4. This prevents:
   - Users from updating other vendors' records
   - Users from changing the user_id to someone else
   - Unauthorized modifications
*/

