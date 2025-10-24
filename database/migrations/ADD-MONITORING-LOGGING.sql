-- ============================================================================
-- Add Monitoring and Logging Tables
-- ============================================================================
-- Run this after ADD-PROFESSIONAL-DASHBOARD.sql succeeds
-- ============================================================================

-- ============================================================================
-- Error Logging System
-- ============================================================================

CREATE TABLE error_logs (
    id BIGSERIAL PRIMARY KEY,
    error_id TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK (type IN ('error', 'warning', 'info')),
    message TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    stack_trace TEXT,
    context JSONB,
    user_id UUID,
    session_id TEXT,
    url TEXT,
    user_agent TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_error_logs_user ON error_logs(user_id);
CREATE INDEX idx_error_logs_severity ON error_logs(severity);
CREATE INDEX idx_error_logs_timestamp ON error_logs(timestamp);

CREATE VIEW error_stats AS
SELECT 
    DATE_TRUNC('hour', timestamp) as hour,
    DATE_TRUNC('day', timestamp) as day,
    severity,
    COUNT(*) as error_count,
    COUNT(DISTINCT user_id) as affected_users,
    MAX(timestamp) as latest_timestamp
FROM error_logs
GROUP BY DATE_TRUNC('hour', timestamp), DATE_TRUNC('day', timestamp), severity
ORDER BY latest_timestamp DESC;

CREATE FUNCTION cleanup_old_error_logs(p_days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    DELETE FROM error_logs
    WHERE timestamp < NOW() - (p_days_to_keep || ' days')::INTERVAL;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- User Activity Logging
-- ============================================================================

CREATE TABLE user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
    activity_type TEXT NOT NULL,
    activity_details JSONB,
    page_url TEXT,
    referrer TEXT,
    user_agent TEXT,
    ip_address TEXT,
    session_id TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activity_user ON user_activity_logs(user_id);
CREATE INDEX idx_activity_type ON user_activity_logs(activity_type);
CREATE INDEX idx_activity_timestamp ON user_activity_logs(timestamp);

CREATE VIEW user_activity_stats AS
SELECT 
    DATE_TRUNC('hour', timestamp) as hour,
    DATE_TRUNC('day', timestamp) as day,
    activity_type,
    COUNT(*) as activity_count,
    COUNT(DISTINCT user_id) as unique_users,
    MAX(timestamp) as latest_timestamp
FROM user_activity_logs
GROUP BY DATE_TRUNC('hour', timestamp), DATE_TRUNC('day', timestamp), activity_type
ORDER BY latest_timestamp DESC;

CREATE VIEW user_journey AS
SELECT 
    user_id,
    activity_type,
    page_url,
    timestamp,
    LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) as previous_activity_time,
    LEAD(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) as next_activity_time
FROM user_activity_logs
ORDER BY user_id, timestamp;

CREATE FUNCTION cleanup_old_activity_logs(p_days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    DELETE FROM user_activity_logs
    WHERE timestamp < NOW() - (p_days_to_keep || ' days')::INTERVAL;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✅ Monitoring and logging tables added successfully!' as status;

