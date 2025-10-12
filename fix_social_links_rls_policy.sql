-- FIX: Social Links Table RLS Policies
-- Issue: Users cannot update social_links table due to missing or incomplete RLS policies
-- Solution: Add proper policies for SELECT, INSERT, UPDATE, DELETE

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
WHERE tablename = 'social_links'
ORDER BY policyname;

-- ============================================
-- STEP 2: Drop All Existing Policies
-- ============================================
DROP POLICY IF EXISTS "Enable read access for all users" ON social_links;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON social_links;
DROP POLICY IF EXISTS "Enable update for social link owners" ON social_links;
DROP POLICY IF EXISTS "Enable delete for social link owners" ON social_links;
DROP POLICY IF EXISTS "Users can view their own social links" ON social_links;
DROP POLICY IF EXISTS "Users can insert their own social links" ON social_links;
DROP POLICY IF EXISTS "Users can update their own social links" ON social_links;
DROP POLICY IF EXISTS "Users can delete their own social links" ON social_links;

-- ============================================
-- STEP 3: Create Complete Policies
-- ============================================

-- SELECT: Users can view their own social links
CREATE POLICY "Users can view their own social links"
ON social_links
FOR SELECT
TO public
USING (auth.uid() = user_id);

-- INSERT: Users can insert their own social links
CREATE POLICY "Users can insert their own social links"
ON social_links
FOR INSERT
TO public
WITH CHECK (auth.uid() = user_id);

-- UPDATE: Users can update their own social links
-- CRITICAL: Must have BOTH USING and WITH CHECK
CREATE POLICY "Users can update their own social links"
ON social_links
FOR UPDATE
TO public
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- DELETE: Users can delete their own social links
CREATE POLICY "Users can delete their own social links"
ON social_links
FOR DELETE
TO public
USING (auth.uid() = user_id);

-- ============================================
-- STEP 4: Enable RLS
-- ============================================
ALTER TABLE social_links ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 5: Grant Permissions
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON social_links TO authenticated;
GRANT SELECT ON social_links TO anon;

-- ============================================
-- STEP 6: Verify Policies
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
WHERE tablename = 'social_links'
ORDER BY cmd, policyname;

-- ============================================
-- STEP 7: Test the Policies
-- ============================================

-- Test INSERT (should succeed for authenticated user)
/*
INSERT INTO social_links (user_id, facebook, instagram)
VALUES (auth.uid(), 'https://facebook.com/test', 'https://instagram.com/test');
*/

-- Test UPDATE (should succeed for own records)
/*
UPDATE social_links 
SET facebook = 'https://facebook.com/updated'
WHERE user_id = auth.uid();
*/

-- Test SELECT (should see own records)
/*
SELECT * FROM social_links WHERE user_id = auth.uid();
*/

-- ============================================
-- NOTES
-- ============================================

/*
Key Requirements for social_links RLS:

1. SELECT Policy:
   - Users can view their own social links
   - USING (auth.uid() = user_id)

2. INSERT Policy:
   - Users can create social links for themselves
   - WITH CHECK (auth.uid() = user_id)

3. UPDATE Policy (CRITICAL):
   - USING: Determines which rows can be updated
   - WITH CHECK: Validates updated values
   - Both must check (auth.uid() = user_id)

4. DELETE Policy:
   - Users can delete their own social links
   - USING (auth.uid() = user_id)

Why WITH CHECK is Critical for UPDATE:
- Without it, PostgreSQL cannot verify the updated row is valid
- RLS rejects the operation as "potentially unsafe"
- This is the most common cause of RLS errors on UPDATE

The social_links table structure:
- id: UUID (PK)
- user_id: UUID (FK to user_profiles.id)
- facebook, instagram, x, etc.: text fields
- visible_facebook, visible_instagram, etc.: boolean fields
- phones: text[] array

RLS policies use user_id to match auth.uid() for security.
*/



