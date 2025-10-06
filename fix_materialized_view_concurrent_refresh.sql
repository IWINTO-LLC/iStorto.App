-- Fix for comprehensive_search_materialized concurrent refresh error
-- This script adds the required unique index to enable concurrent refresh

-- First, let's check if the materialized view exists and its current structure
DO $$
BEGIN
    -- Check if the materialized view exists
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'comprehensive_search_materialized') THEN
        RAISE NOTICE 'Materialized view comprehensive_search_materialized exists';
        
        -- Check if there's already a unique index
        IF NOT EXISTS (
            SELECT 1 FROM pg_indexes 
            WHERE tablename = 'comprehensive_search_materialized' 
            AND indexname LIKE '%unique%'
        ) THEN
            RAISE NOTICE 'No unique index found, creating one...';
            
            -- Create a unique index on product_id (assuming it's unique)
            -- This is required for CONCURRENTLY refresh operations
            CREATE UNIQUE INDEX IF NOT EXISTS idx_comprehensive_search_unique_product_id 
            ON comprehensive_search_materialized (product_id);
            
            RAISE NOTICE 'Unique index created successfully';
        ELSE
            RAISE NOTICE 'Unique index already exists';
        END IF;
    ELSE
        RAISE NOTICE 'Materialized view comprehensive_search_materialized does not exist';
    END IF;
END $$;

-- Alternative approach: Create a unique index on a combination of columns if product_id is not unique
-- Uncomment the following if the above doesn't work due to non-unique product_id

/*
DO $$
BEGIN
    -- Drop the previous unique index if it exists
    DROP INDEX IF EXISTS idx_comprehensive_search_unique_product_id;
    
    -- Create a unique index on a combination of columns
    CREATE UNIQUE INDEX IF NOT EXISTS idx_comprehensive_search_unique_combined 
    ON comprehensive_search_materialized (product_id, vendor_id, vendor_category_vc_id);
    
    RAISE NOTICE 'Unique combined index created successfully';
END $$;
*/

-- Test the concurrent refresh capability
DO $$
BEGIN
    RAISE NOTICE 'Testing concurrent refresh capability...';
    
    -- Try to refresh the materialized view concurrently
    BEGIN
        REFRESH MATERIALIZED VIEW CONCURRENTLY comprehensive_search_materialized;
        RAISE NOTICE 'Concurrent refresh successful!';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Concurrent refresh failed: %', SQLERRM;
        RAISE NOTICE 'Falling back to regular refresh...';
        REFRESH MATERIALIZED VIEW comprehensive_search_materialized;
        RAISE NOTICE 'Regular refresh completed';
    END;
END $$;

-- Grant necessary permissions
GRANT SELECT ON comprehensive_search_materialized TO authenticated;
GRANT SELECT ON comprehensive_search_materialized TO anon;

-- Show final status
SELECT 
    schemaname,
    matviewname,
    definition
FROM pg_matviews 
WHERE matviewname = 'comprehensive_search_materialized';

-- Show indexes on the materialized view
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'comprehensive_search_materialized'
ORDER BY indexname;
