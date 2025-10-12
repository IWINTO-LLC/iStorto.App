-- MINIMAL FIX: Only fix the UPDATE policy for vendors table
-- This won't touch any other policies, just fixes the UPDATE issue

-- Drop the incomplete UPDATE policy
DROP POLICY IF EXISTS "Users can update their own vendor" ON vendors;

-- Create complete UPDATE policy with WITH CHECK
CREATE POLICY "Users can update their own vendor"
ON vendors
FOR UPDATE
TO public
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Done! Test it now.





