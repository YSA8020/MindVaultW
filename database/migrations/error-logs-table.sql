-- Error Logs Table for Production Error Handling
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS error_logs (
    id BIGSERIAL PRIMARY KEY,
    error_id TEXT NOT NULL,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    stack_trace TEXT,
    context JSONB,
    user_id TEXT,
    session_id TEXT,
    url TEXT,
    user_agent TEXT,
    filename TEXT,
    line_number INTEGER,
    column_number INTEGER,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_error_logs_type ON error_logs(type);
CREATE INDEX IF NOT EXISTS idx_error_logs_severity ON error_logs(severity);
CREATE INDEX IF NOT EXISTS idx_error_logs_user_id ON error_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_error_logs_timestamp ON error_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_error_logs_created_at ON error_logs(created_at);

-- Enable Row Level Security
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- Create policy to allow inserts (for error logging)
CREATE POLICY "Allow error log inserts" ON error_logs
    FOR INSERT WITH CHECK (true);

-- Create policy to allow reads for authenticated users (for admin dashboard)
CREATE POLICY "Allow error log reads for authenticated users" ON error_logs
    FOR SELECT USING (auth.role() = 'authenticated');

-- Create a view for error statistics
CREATE OR REPLACE VIEW error_stats AS
SELECT 
    type,
    severity,
    COUNT(*) as error_count,
    DATE_TRUNC('hour', timestamp) as hour,
    DATE_TRUNC('day', timestamp) as day,
    MAX(timestamp) as latest_timestamp
FROM error_logs
GROUP BY type, severity, DATE_TRUNC('hour', timestamp), DATE_TRUNC('day', timestamp)
ORDER BY latest_timestamp DESC;

-- Create a function to clean up old error logs (older than 30 days)
CREATE OR REPLACE FUNCTION cleanup_old_error_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM error_logs 
    WHERE created_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- Create a function to get error summary
CREATE OR REPLACE FUNCTION get_error_summary(days_back INTEGER DEFAULT 7)
RETURNS TABLE (
    total_errors BIGINT,
    critical_errors BIGINT,
    high_errors BIGINT,
    medium_errors BIGINT,
    low_errors BIGINT,
    unique_users BIGINT,
    most_common_type TEXT,
    most_common_message TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_errors,
        COUNT(*) FILTER (WHERE severity = 'critical') as critical_errors,
        COUNT(*) FILTER (WHERE severity = 'high') as high_errors,
        COUNT(*) FILTER (WHERE severity = 'medium') as medium_errors,
        COUNT(*) FILTER (WHERE severity = 'low') as low_errors,
        COUNT(DISTINCT user_id) as unique_users,
        (SELECT type FROM error_logs 
         WHERE created_at >= NOW() - (days_back || ' days')::INTERVAL 
         GROUP BY type ORDER BY COUNT(*) DESC LIMIT 1) as most_common_type,
        (SELECT message FROM error_logs 
         WHERE created_at >= NOW() - (days_back || ' days')::INTERVAL 
         GROUP BY message ORDER BY COUNT(*) DESC LIMIT 1) as most_common_message
    FROM error_logs
    WHERE created_at >= NOW() - (days_back || ' days')::INTERVAL;
END;
$$ LANGUAGE plpgsql;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON error_logs TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE error_logs_id_seq TO anon, authenticated;
GRANT SELECT ON error_stats TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_error_summary TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_error_logs TO authenticated;
