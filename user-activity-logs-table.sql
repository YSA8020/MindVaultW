-- User Activity Logs Table for Production Monitoring
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    log_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    event_data JSONB,
    user_id TEXT,
    session_id TEXT NOT NULL,
    url TEXT,
    user_agent TEXT,
    viewport JSONB,
    screen JSONB,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_event_type ON user_activity_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_user_id ON user_activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_session_id ON user_activity_logs(session_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_timestamp ON user_activity_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_created_at ON user_activity_logs(created_at);

-- Enable Row Level Security
ALTER TABLE user_activity_logs ENABLE ROW LEVEL SECURITY;

-- Create policy to allow inserts (for activity logging)
CREATE POLICY "Allow activity log inserts" ON user_activity_logs
    FOR INSERT WITH CHECK (true);

-- Create policy to allow reads for authenticated users (for admin dashboard)
CREATE POLICY "Allow activity log reads for authenticated users" ON user_activity_logs
    FOR SELECT USING (auth.role() = 'authenticated');

-- Create a view for user activity statistics
CREATE OR REPLACE VIEW user_activity_stats AS
SELECT 
    event_type,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT session_id) as unique_sessions,
    DATE_TRUNC('hour', timestamp) as hour,
    DATE_TRUNC('day', timestamp) as day
FROM user_activity_logs
GROUP BY event_type, DATE_TRUNC('hour', timestamp), DATE_TRUNC('day', timestamp)
ORDER BY timestamp DESC;

-- Create a view for user journey analysis
CREATE OR REPLACE VIEW user_journey AS
SELECT 
    session_id,
    user_id,
    COUNT(*) as total_events,
    MIN(timestamp) as session_start,
    MAX(timestamp) as session_end,
    EXTRACT(EPOCH FROM (MAX(timestamp) - MIN(timestamp))) as session_duration_seconds,
    array_agg(DISTINCT event_type ORDER BY event_type) as event_types,
    array_agg(DISTINCT url ORDER BY url) as pages_visited
FROM user_activity_logs
GROUP BY session_id, user_id
ORDER BY session_start DESC;

-- Create a function to get user activity summary
CREATE OR REPLACE FUNCTION get_user_activity_summary(days_back INTEGER DEFAULT 7)
RETURNS TABLE (
    total_events BIGINT,
    unique_users BIGINT,
    unique_sessions BIGINT,
    avg_session_duration NUMERIC,
    most_common_event TEXT,
    most_visited_page TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_events,
        COUNT(DISTINCT user_id) as unique_users,
        COUNT(DISTINCT session_id) as unique_sessions,
        AVG(EXTRACT(EPOCH FROM (session_end - session_start))) as avg_session_duration,
        (SELECT event_type FROM user_activity_logs 
         WHERE created_at >= NOW() - (days_back || ' days')::INTERVAL 
         GROUP BY event_type ORDER BY COUNT(*) DESC LIMIT 1) as most_common_event,
        (SELECT url FROM user_activity_logs 
         WHERE created_at >= NOW() - (days_back || ' days')::INTERVAL 
         GROUP BY url ORDER BY COUNT(*) DESC LIMIT 1) as most_visited_page
    FROM user_activity_logs ual
    LEFT JOIN user_journey uj ON ual.session_id = uj.session_id
    WHERE ual.created_at >= NOW() - (days_back || ' days')::INTERVAL;
END;
$$ LANGUAGE plpgsql;

-- Create a function to clean up old activity logs (older than 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_activity_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM user_activity_logs 
    WHERE created_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON user_activity_logs TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE user_activity_logs_id_seq TO anon, authenticated;
GRANT SELECT ON user_activity_stats TO anon, authenticated;
GRANT SELECT ON user_journey TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_user_activity_summary TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_activity_logs TO authenticated;
