-- QUICK FIX: Vendors Table RLS UPDATE Policy
-- Run this in Supabase SQL Editor to allow vendors to update their own records
-- CRITICAL: Adds missing WITH CHECK clause to UPDATE policy

-- 1. Drop the incomplete UPDATE policy
DROP POLICY IF EXISTS "Users can update their own vendor" ON vendors;
DROP POLICY IF EXISTS "Users can update their own vendor records" ON vendors;
DROP POLICY IF EXISTS "Vendors can update own profile" ON vendors;
DROP POLICY IF EXISTS "Enable update for vendors" ON vendors;
DROP POLICY IF EXISTS "Allow vendors to update own data" ON vendors;
DROP POLICY IF EXISTS "Enable update for vendor owners" ON vendors;

-- 2. Create complete UPDATE policy with BOTH USING and WITH CHECK
CREATE POLICY "Users can update their own vendor"
ON vendors
FOR UPDATE
TO public
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 3. Fix SELECT policy to allow public viewing of vendor profiles
DROP POLICY IF EXISTS "Users can view their own vendor" ON vendors;
DROP POLICY IF EXISTS "Enable read access for vendors" ON vendors;

CREATE POLICY "Enable read access for vendors"
ON vendors
FOR SELECT
TO public
USING (
  auth.uid() = user_id
  OR
  (organization_activated = true AND organization_deleted = false)
);

-- 4. Ensure RLS is enabled
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

-- 5. Grant permissions
GRANT SELECT, UPDATE ON vendors TO authenticated;
GRANT SELECT ON vendors TO anon;

-- 6. Verify the UPDATE policy was created correctly
SELECT 
    policyname,
    cmd,
    qual::text as using_clause,
    with_check::text as with_check_clause
FROM pg_policies
WHERE tablename = 'vendors' AND cmd = 'UPDATE';

-- Expected output:
-- policyname: "Users can update their own vendor"
-- cmd: UPDATE
-- using_clause: (auth.uid() = user_id) ✅
-- with_check_clause: (auth.uid() = user_id) ✅ MUST BE PRESENT!

-- 7. Verify all policies
SELECT 
    policyname,
    cmd,
    CASE 
      WHEN with_check IS NOT NULL OR cmd != 'UPDATE' THEN '✅'
      ELSE '❌ MISSING WITH CHECK'
    END as status
FROM pg_policies
WHERE tablename = 'vendors'
ORDER BY cmd;

