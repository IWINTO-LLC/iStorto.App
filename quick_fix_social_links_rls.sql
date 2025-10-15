-- QUICK FIX: Social Links Table RLS Policies
-- Run this in Supabase SQL Editor to allow users to update their social links

-- 1. Drop all existing policies
DROP POLICY IF EXISTS "Users can view their own social links" ON social_links;
DROP POLICY IF EXISTS "Users can insert their own social links" ON social_links;
DROP POLICY IF EXISTS "Users can update their own social links" ON social_links;
DROP POLICY IF EXISTS "Users can delete their own social links" ON social_links;

-- 2. Create SELECT policy
CREATE POLICY "Users can view their own social links"
ON social_links
FOR SELECT
TO public
USING (auth.uid() = user_id);

-- 3. Create INSERT policy
CREATE POLICY "Users can insert their own social links"
ON social_links
FOR INSERT
TO public
WITH CHECK (auth.uid() = user_id);

-- 4. Create UPDATE policy (CRITICAL: Must have BOTH USING and WITH CHECK)
CREATE POLICY "Users can update their own social links"
ON social_links
FOR UPDATE
TO public
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. Create DELETE policy
CREATE POLICY "Users can delete their own social links"
ON social_links
FOR DELETE
TO public
USING (auth.uid() = user_id);

-- 6. Enable RLS
ALTER TABLE social_links ENABLE ROW LEVEL SECURITY;

-- 7. Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON social_links TO authenticated;
GRANT SELECT ON social_links TO anon;

-- 8. Verify policies
SELECT 
    policyname,
    cmd,
    qual::text as using_clause,
    with_check::text as with_check_clause,
    CASE
      WHEN cmd = 'UPDATE' AND with_check IS NOT NULL THEN '✅ Complete'
      WHEN cmd = 'UPDATE' AND with_check IS NULL THEN '❌ Missing WITH CHECK'
      ELSE '✅ OK'
    END as status
FROM pg_policies
WHERE tablename = 'social_links'
ORDER BY cmd;

-- Expected: All policies should show ✅ status






