-- FIX: Add WITH CHECK clause to vendors UPDATE policy
-- Current Issue: UPDATE policy has USING but no WITH CHECK
-- This causes RLS violations when updating records

-- ============================================
-- ANALYSIS OF CURRENT POLICIES
-- ============================================

/*
Current UPDATE policy:
  policyname: "Users can update their own vendor"
  cmd: UPDATE
  qual (USING): (auth.uid() = user_id) ✅
  with_check: null ❌ MISSING!

This is the problem! The UPDATE policy needs BOTH:
1. USING clause - to determine which rows can be updated
2. WITH CHECK clause - to validate the new values

Without WITH CHECK, PostgreSQL cannot verify the updated row
meets the security requirements, causing the RLS violation.
*/

-- ============================================
-- SOLUTION: Recreate UPDATE Policy with WITH CHECK
-- ============================================

-- Step 1: Drop the incomplete UPDATE policy
DROP POLICY IF EXISTS "Users can update their own vendor" ON vendors;

-- Step 2: Create complete UPDATE policy with BOTH clauses
CREATE POLICY "Users can update their own vendor"
ON vendors
FOR UPDATE
TO public
USING (auth.uid() = user_id)           -- Can update rows I own
WITH CHECK (auth.uid() = user_id);     -- New values must preserve ownership

-- ============================================
-- ALSO FIX: SELECT Policy is Too Restrictive
-- ============================================

/*
Current SELECT policy only allows users to view their own vendor.
This prevents customers from viewing vendor profiles!

We need to allow:
1. Everyone can view active, non-deleted vendors (public profiles)
2. Vendors can view their own records (even if inactive)
*/

-- Drop restrictive SELECT policy
DROP POLICY IF EXISTS "Users can view their own vendor" ON vendors;

-- Create new SELECT policy that allows public viewing
CREATE POLICY "Enable read access for vendors"
ON vendors
FOR SELECT
TO public
USING (
  -- Users can always see their own vendor
  auth.uid() = user_id
  OR
  -- Everyone can see active, non-deleted vendors
  (organization_activated = true AND organization_deleted = false)
);

-- ============================================
-- VERIFICATION
-- ============================================

-- Check all policies are correct
SELECT 
    policyname,
    cmd as operation,
    CASE 
      WHEN qual IS NOT NULL THEN qual::text
      ELSE 'No USING clause'
    END as using_clause,
    CASE 
      WHEN with_check IS NOT NULL THEN with_check::text
      ELSE 'No WITH CHECK clause'
    END as with_check_clause,
    CASE
      WHEN cmd = 'UPDATE' AND with_check IS NOT NULL THEN '✅ Complete'
      WHEN cmd = 'UPDATE' AND with_check IS NULL THEN '❌ Missing WITH CHECK'
      WHEN cmd = 'INSERT' AND with_check IS NOT NULL THEN '✅ Complete'
      WHEN cmd = 'SELECT' THEN '✅ OK'
      WHEN cmd = 'DELETE' THEN '✅ OK'
      ELSE '⚠️ Check manually'
    END as status
FROM pg_policies
WHERE tablename = 'vendors'
ORDER BY cmd, policyname;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON vendors TO authenticated;
GRANT SELECT ON vendors TO anon;

-- ============================================
-- FINAL VERIFICATION
-- ============================================

-- This should show the UPDATE policy with both USING and WITH CHECK
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
-- using_clause: (auth.uid() = user_id)
-- with_check_clause: (auth.uid() = user_id) ✅

COMMIT;

