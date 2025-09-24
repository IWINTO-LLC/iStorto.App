-- Create table to track currency update history
CREATE TABLE IF NOT EXISTS currency_update_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    update_type TEXT NOT NULL, -- 'cron', 'manual', 'api'
    source TEXT NOT NULL, -- 'exchangerate-api', 'fixer', 'manual'
    currencies_updated INTEGER DEFAULT 0,
    success BOOLEAN DEFAULT false,
    error_message TEXT,
    execution_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_currency_update_history_created_at 
ON currency_update_history(created_at);

-- Create index for update type
CREATE INDEX IF NOT EXISTS idx_currency_update_history_type 
ON currency_update_history(update_type);

-- Enable RLS
ALTER TABLE currency_update_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policy (only authenticated users can view)
CREATE POLICY "Authenticated users can view currency update history" 
ON currency_update_history
FOR SELECT USING (auth.role() = 'authenticated');

-- Create function to log currency updates
CREATE OR REPLACE FUNCTION log_currency_update(
    p_update_type TEXT,
    p_source TEXT,
    p_currencies_updated INTEGER,
    p_success BOOLEAN,
    p_error_message TEXT DEFAULT NULL,
    p_execution_time_ms INTEGER DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    update_id UUID;
BEGIN
    INSERT INTO currency_update_history (
        update_type,
        source,
        currencies_updated,
        success,
        error_message,
        execution_time_ms
    ) VALUES (
        p_update_type,
        p_source,
        p_currencies_updated,
        p_success,
        p_error_message,
        p_execution_time_ms
    ) RETURNING id INTO update_id;
    
    RETURN update_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION log_currency_update(TEXT, TEXT, INTEGER, BOOLEAN, TEXT, INTEGER) TO authenticated;

-- Create function to get update statistics
CREATE OR REPLACE FUNCTION get_currency_update_stats(days_back INTEGER DEFAULT 7)
RETURNS TABLE (
    total_updates BIGINT,
    successful_updates BIGINT,
    failed_updates BIGINT,
    avg_currencies_updated DECIMAL,
    avg_execution_time_ms DECIMAL,
    last_update TIMESTAMP WITH TIME ZONE,
    most_common_source TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_updates,
        COUNT(*) FILTER (WHERE success = true) as successful_updates,
        COUNT(*) FILTER (WHERE success = false) as failed_updates,
        AVG(currencies_updated) as avg_currencies_updated,
        AVG(execution_time_ms) as avg_execution_time_ms,
        MAX(created_at) as last_update,
        MODE() WITHIN GROUP (ORDER BY source) as most_common_source
    FROM currency_update_history
    WHERE created_at >= NOW() - INTERVAL '1 day' * days_back;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_currency_update_stats(INTEGER) TO authenticated;

-- Create function to clean old update history (keep last 30 days)
CREATE OR REPLACE FUNCTION clean_old_currency_updates()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM currency_update_history 
    WHERE created_at < NOW() - INTERVAL '30 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION clean_old_currency_updates() TO authenticated;

-- Create a view for recent updates
CREATE OR REPLACE VIEW recent_currency_updates AS
SELECT 
    id,
    update_type,
    source,
    currencies_updated,
    success,
    error_message,
    execution_time_ms,
    created_at,
    CASE 
        WHEN success THEN '✅ Success'
        ELSE '❌ Failed'
    END as status_display
FROM currency_update_history
ORDER BY created_at DESC
LIMIT 50;

-- Grant access to the view
GRANT SELECT ON recent_currency_updates TO authenticated;

-- Create function to manually trigger currency update
CREATE OR REPLACE FUNCTION trigger_currency_update()
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    execution_time INTEGER;
    update_id UUID;
BEGIN
    start_time := NOW();
    
    -- This function would call the Edge Function
    -- For now, we'll just log a manual trigger
    update_id := log_currency_update(
        'manual',
        'database_function',
        0,
        false,
        'Manual trigger - Edge Function should be called',
        NULL
    );
    
    end_time := NOW();
    execution_time := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
    
    result := jsonb_build_object(
        'success', false,
        'message', 'Manual trigger logged. Call Edge Function separately.',
        'update_id', update_id,
        'execution_time_ms', execution_time
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION trigger_currency_update() TO authenticated;


