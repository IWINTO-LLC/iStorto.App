-- =============================================
-- Test User Follows System
-- =============================================
-- This script tests the user_follows functionality

-- =============================================
-- Test 1: Check if tables exist
-- =============================================
SELECT 
    'user_follows table exists' as test_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_follows')
        THEN 'PASS'
        ELSE 'FAIL'
    END as result;

-- =============================================
-- Test 2: Check if indexes exist
-- =============================================
SELECT 
    'Indexes exist' as test_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'user_follows' AND indexname = 'idx_user_follows_user_id')
        AND EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'user_follows' AND indexname = 'idx_user_follows_vendor_id')
        THEN 'PASS'
        ELSE 'FAIL'
    END as result;

-- =============================================
-- Test 3: Check if RLS is enabled
-- =============================================
SELECT 
    'RLS is enabled' as test_name,
    CASE 
        WHEN relrowsecurity = true
        THEN 'PASS'
        ELSE 'FAIL'
    END as result
FROM pg_class 
WHERE relname = 'user_follows';

-- =============================================
-- Test 4: Check if functions exist
-- =============================================
SELECT 
    'Helper functions exist' as test_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_user_following_vendor')
        AND EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_vendor_followers_count')
        AND EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_user_following_count')
        AND EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'follow_vendor')
        AND EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'unfollow_vendor')
        AND EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'toggle_follow_vendor')
        THEN 'PASS'
        ELSE 'FAIL'
    END as result;

-- =============================================
-- Test 5: Check if views exist
-- =============================================
SELECT 
    'Views exist' as test_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'user_followed_vendors')
        AND EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'vendor_followers')
        THEN 'PASS'
        ELSE 'FAIL'
    END as result;

-- =============================================
-- Test 6: Check if policies exist
-- =============================================
SELECT 
    'RLS policies exist' as test_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'user_follows' 
            AND policyname = 'Users can view their own follows'
        )
        AND EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'user_follows' 
            AND policyname = 'Users can follow vendors'
        )
        AND EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'user_follows' 
            AND policyname = 'Users can unfollow vendors'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END as result;

-- =============================================
-- Test 7: Sample data test (if you have test data)
-- =============================================
-- Uncomment and modify these tests if you have sample data

/*
-- Test follow functionality
DO $$
DECLARE
    test_user_id UUID := 'your-test-user-id';
    test_vendor_id UUID := 'your-test-vendor-id';
    follow_result BOOLEAN;
    unfollow_result BOOLEAN;
    is_following BOOLEAN;
    followers_count INTEGER;
    following_count INTEGER;
BEGIN
    -- Test following a vendor
    follow_result := follow_vendor(test_user_id, test_vendor_id);
    RAISE NOTICE 'Follow result: %', follow_result;
    
    -- Test checking follow status
    is_following := is_user_following_vendor(test_user_id, test_vendor_id);
    RAISE NOTICE 'Is following: %', is_following;
    
    -- Test getting counts
    followers_count := get_vendor_followers_count(test_vendor_id);
    following_count := get_user_following_count(test_user_id);
    RAISE NOTICE 'Followers count: %, Following count: %', followers_count, following_count;
    
    -- Test unfollowing
    unfollow_result := unfollow_vendor(test_user_id, test_vendor_id);
    RAISE NOTICE 'Unfollow result: %', unfollow_result;
    
    RAISE NOTICE 'All tests completed successfully!';
END $$;
*/

-- =============================================
-- Test 8: Check permissions
-- =============================================
SELECT 
    'Permissions granted' as test_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.table_privileges 
            WHERE table_name = 'user_follows' 
            AND privilege_type IN ('SELECT', 'INSERT', 'DELETE')
            AND grantee = 'authenticated'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END as result;

-- =============================================
-- Summary
-- =============================================
SELECT 'User Follows System Tests Complete' as summary;
