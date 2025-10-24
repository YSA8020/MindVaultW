-- ============================================================================
-- Add Security Tables and Functions
-- ============================================================================
-- Run this after FRESH-START-SETUP.sql succeeds
-- ============================================================================

-- ============================================================================
-- Security Tables
-- ============================================================================

CREATE TABLE rate_limits (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
    ip_address TEXT NOT NULL,
    endpoint TEXT NOT NULL,
    window_start TIMESTAMPTZ NOT NULL,
    window_end TIMESTAMPTZ NOT NULL,
    request_count INTEGER NOT NULL DEFAULT 1,
    blocked BOOLEAN DEFAULT FALSE,
    blocked_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (user_id, ip_address, endpoint, window_start)
);

CREATE INDEX idx_rate_limits_user_ip ON rate_limits(user_id, ip_address);
CREATE INDEX idx_rate_limits_window ON rate_limits(window_start);

CREATE TABLE failed_login_attempts (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
    email TEXT NOT NULL,
    ip_address TEXT NOT NULL,
    attempted_at TIMESTAMPTZ DEFAULT NOW(),
    success BOOLEAN DEFAULT FALSE,
    failure_reason TEXT
);

CREATE INDEX idx_failed_login_user ON failed_login_attempts(user_id);
CREATE INDEX idx_failed_login_ip ON failed_login_attempts(ip_address);
CREATE INDEX idx_failed_login_time ON failed_login_attempts(attempted_at);

CREATE TABLE suspicious_activity (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
    ip_address TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    description TEXT,
    severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    detected_at TIMESTAMPTZ DEFAULT NOW(),
    resolved BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_suspicious_user ON suspicious_activity(user_id);
CREATE INDEX idx_suspicious_ip ON suspicious_activity(ip_address);

CREATE TABLE ip_blacklist (
    id BIGSERIAL PRIMARY KEY,
    ip_address TEXT NOT NULL UNIQUE,
    reason TEXT,
    blocked_until TIMESTAMPTZ,
    permanent BOOLEAN DEFAULT FALSE,
    blocked_at TIMESTAMPTZ DEFAULT NOW(),
    blocked_by TEXT
);

CREATE INDEX idx_ip_blacklist_address ON ip_blacklist(ip_address);

CREATE TABLE user_security_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    login_notifications BOOLEAN DEFAULT TRUE,
    session_timeout INTEGER DEFAULT 3600,
    max_failed_attempts INTEGER DEFAULT 5,
    account_locked BOOLEAN DEFAULT FALSE,
    locked_until TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE security_events (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
    event_type TEXT NOT NULL,
    description TEXT,
    ip_address TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_security_events_user ON security_events(user_id);
CREATE INDEX idx_security_events_type ON security_events(event_type);

-- ============================================================================
-- Security Functions
-- ============================================================================

CREATE FUNCTION check_rate_limit(
    p_user_id UUID,
    p_ip_address TEXT,
    p_endpoint TEXT,
    p_max_requests INTEGER DEFAULT 60,
    p_window_minutes INTEGER DEFAULT 60
)
RETURNS TABLE (
    allowed BOOLEAN,
    remaining_requests INTEGER,
    reset_time TIMESTAMPTZ
) AS $$
DECLARE
    v_current_count INTEGER;
    v_window_start TIMESTAMPTZ;
    v_window_end TIMESTAMPTZ;
    v_blocked BOOLEAN;
    v_blocked_until TIMESTAMPTZ;
BEGIN
    -- Check if IP is blacklisted
    SELECT TRUE, blocked_until INTO v_blocked, v_blocked_until
    FROM ip_blacklist
    WHERE ip_address = p_ip_address
    AND (blocked_until IS NULL OR blocked_until > NOW())
    AND permanent = TRUE;
    
    IF v_blocked THEN
        RETURN QUERY SELECT FALSE, 0, v_blocked_until;
        RETURN;
    END IF;
    
    -- Calculate time window
    v_window_start := DATE_TRUNC('hour', NOW());
    v_window_end := v_window_start + (p_window_minutes || ' minutes')::INTERVAL;
    
    -- Get current count
    SELECT request_count INTO v_current_count
    FROM rate_limits
    WHERE (user_id = p_user_id OR (user_id IS NULL AND ip_address = p_ip_address))
    AND endpoint = p_endpoint
    AND window_start = v_window_start;
    
    -- If no record exists, create one
    IF v_current_count IS NULL THEN
        INSERT INTO rate_limits (user_id, ip_address, endpoint, window_start, window_end, request_count)
        VALUES (p_user_id, p_ip_address, p_endpoint, v_window_start, v_window_end, 1);
        v_current_count := 1;
    END IF;
    
    -- Check if limit exceeded
    IF v_current_count >= p_max_requests THEN
        UPDATE rate_limits
        SET blocked = TRUE,
            blocked_until = NOW() + INTERVAL '1 hour'
        WHERE (user_id = p_user_id OR (user_id IS NULL AND ip_address = p_ip_address))
        AND endpoint = p_endpoint
        AND window_start = v_window_start;
        
        RETURN QUERY SELECT FALSE, 0, v_window_end;
        RETURN;
    END IF;
    
    -- Increment request count
    UPDATE rate_limits
    SET request_count = request_count + 1,
        updated_at = NOW()
    WHERE (user_id = p_user_id OR (user_id IS NULL AND ip_address = p_ip_address))
    AND endpoint = p_endpoint
    AND window_start = v_window_start;
    
    RETURN QUERY SELECT TRUE, p_max_requests - v_current_count - 1, v_window_end;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION log_failed_login(
    p_user_id UUID,
    p_email TEXT,
    p_ip_address TEXT,
    p_failure_reason TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO failed_login_attempts (user_id, email, ip_address, success, failure_reason)
    VALUES (p_user_id, p_email, p_ip_address, FALSE, p_failure_reason);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION log_security_event(
    p_user_id UUID,
    p_event_type TEXT,
    p_description TEXT,
    p_ip_address TEXT,
    p_metadata JSONB DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO security_events (user_id, event_type, description, ip_address, metadata)
    VALUES (p_user_id, p_event_type, p_description, p_ip_address, p_metadata);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✅ Security tables and functions added successfully!' as status;

