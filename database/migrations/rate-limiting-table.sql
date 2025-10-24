-- Rate Limiting and Security Tables
-- Protection against abuse and malicious activity

CREATE TABLE IF NOT EXISTS rate_limits (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT,
    ip_address TEXT,
    endpoint TEXT NOT NULL,
    request_count INTEGER DEFAULT 1,
    window_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    window_end TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '1 hour',
    blocked BOOLEAN DEFAULT FALSE,
    blocked_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Failed login attempts tracking
CREATE TABLE IF NOT EXISTS failed_login_attempts (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT,
    email TEXT,
    ip_address TEXT NOT NULL,
    user_agent TEXT,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    success BOOLEAN DEFAULT FALSE,
    failure_reason TEXT,
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Suspicious activity log
CREATE TABLE IF NOT EXISTS suspicious_activity (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT,
    ip_address TEXT,
    activity_type TEXT NOT NULL CHECK (activity_type IN ('multiple_failed_logins', 'rapid_requests', 'unusual_pattern', 'potential_abuse', 'security_threat')),
    description TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    blocked BOOLEAN DEFAULT FALSE,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    resolved_by TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL
);

-- IP blacklist
CREATE TABLE IF NOT EXISTS ip_blacklist (
    id BIGSERIAL PRIMARY KEY,
    ip_address TEXT NOT NULL UNIQUE,
    reason TEXT NOT NULL,
    blocked_by TEXT NOT NULL,
    blocked_until TIMESTAMPTZ,
    permanent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User security settings
CREATE TABLE IF NOT EXISTS user_security_settings (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    
    -- Login security
    max_login_attempts INTEGER DEFAULT 5,
    lockout_duration_minutes INTEGER DEFAULT 15,
    require_two_factor BOOLEAN DEFAULT FALSE,
    two_factor_secret TEXT,
    
    -- Session security
    session_timeout_minutes INTEGER DEFAULT 1440, -- 24 hours
    max_concurrent_sessions INTEGER DEFAULT 3,
    
    -- Activity monitoring
    last_login_at TIMESTAMPTZ,
    last_login_ip TEXT,
    last_activity_at TIMESTAMPTZ,
    failed_login_count INTEGER DEFAULT 0,
    account_locked BOOLEAN DEFAULT FALSE,
    locked_until TIMESTAMPTZ,
    
    -- Security alerts
    email_security_alerts BOOLEAN DEFAULT TRUE,
    sms_security_alerts BOOLEAN DEFAULT FALSE,
    security_alert_threshold TEXT CHECK (security_alert_threshold IN ('low', 'medium', 'high')),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Security events log
CREATE TABLE IF NOT EXISTS security_events (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT,
    event_type TEXT NOT NULL CHECK (event_type IN ('login', 'logout', 'password_change', 'email_change', 'two_factor_enabled', 'two_factor_disabled', 'suspicious_activity', 'account_locked', 'account_unlocked')),
    ip_address TEXT,
    user_agent TEXT,
    location TEXT,
    success BOOLEAN DEFAULT TRUE,
    failure_reason TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_rate_limits_user_id ON rate_limits(user_id);
CREATE INDEX IF NOT EXISTS idx_rate_limits_ip_address ON rate_limits(ip_address);
CREATE INDEX IF NOT EXISTS idx_rate_limits_endpoint ON rate_limits(endpoint);
CREATE INDEX IF NOT EXISTS idx_rate_limits_window_end ON rate_limits(window_end);
CREATE INDEX IF NOT EXISTS idx_rate_limits_blocked ON rate_limits(blocked);

CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_user_id ON failed_login_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_ip_address ON failed_login_attempts(ip_address);
CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_attempted_at ON failed_login_attempts(attempted_at);
CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_email ON failed_login_attempts(email);

CREATE INDEX IF NOT EXISTS idx_suspicious_activity_user_id ON suspicious_activity(user_id);
CREATE INDEX IF NOT EXISTS idx_suspicious_activity_ip_address ON suspicious_activity(ip_address);
CREATE INDEX IF NOT EXISTS idx_suspicious_activity_severity ON suspicious_activity(severity);
CREATE INDEX IF NOT EXISTS idx_suspicious_activity_resolved ON suspicious_activity(resolved);

CREATE INDEX IF NOT EXISTS idx_ip_blacklist_ip_address ON ip_blacklist(ip_address);
CREATE INDEX IF NOT EXISTS idx_ip_blacklist_blocked_until ON ip_blacklist(blocked_until);

CREATE INDEX IF NOT EXISTS idx_user_security_settings_user_id ON user_security_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_user_security_settings_account_locked ON user_security_settings(account_locked);

CREATE INDEX IF NOT EXISTS idx_security_events_user_id ON security_events(user_id);
CREATE INDEX IF NOT EXISTS idx_security_events_event_type ON security_events(event_type);
CREATE INDEX IF NOT EXISTS idx_security_events_created_at ON security_events(created_at);

-- Enable Row Level Security
ALTER TABLE rate_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE failed_login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE suspicious_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE ip_blacklist ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_security_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own security settings" ON user_security_settings
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can update own security settings" ON user_security_settings
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can view own security events" ON security_events
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Admins can view all security data" ON rate_limits
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can view all failed login attempts" ON failed_login_attempts
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can view all suspicious activity" ON suspicious_activity
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can manage IP blacklist" ON ip_blacklist
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can view all security events" ON security_events
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

-- Function to check rate limit
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_user_id TEXT,
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
    
    -- Get or create rate limit record
    INSERT INTO rate_limits (user_id, ip_address, endpoint, window_start, window_end)
    VALUES (p_user_id, p_ip_address, p_endpoint, v_window_start, v_window_end)
    ON CONFLICT DO NOTHING;
    
    -- Get current count
    SELECT request_count INTO v_current_count
    FROM rate_limits
    WHERE (user_id = p_user_id OR ip_address = p_ip_address)
    AND endpoint = p_endpoint
    AND window_start = v_window_start;
    
    -- Check if limit exceeded
    IF v_current_count >= p_max_requests THEN
        -- Update blocked status
        UPDATE rate_limits
        SET blocked = TRUE,
            blocked_until = NOW() + INTERVAL '1 hour'
        WHERE (user_id = p_user_id OR ip_address = p_ip_address)
        AND endpoint = p_endpoint
        AND window_start = v_window_start;
        
        RETURN QUERY SELECT FALSE, 0, v_window_end;
        RETURN;
    END IF;
    
    -- Increment request count
    UPDATE rate_limits
    SET request_count = request_count + 1,
        updated_at = NOW()
    WHERE (user_id = p_user_id OR ip_address = p_ip_address)
    AND endpoint = p_endpoint
    AND window_start = v_window_start;
    
    -- Return success
    RETURN QUERY SELECT TRUE, p_max_requests - v_current_count - 1, v_window_end;
END;
$$ LANGUAGE plpgsql;

-- Function to log failed login attempt
CREATE OR REPLACE FUNCTION log_failed_login(
    p_email TEXT,
    p_ip_address TEXT,
    p_user_agent TEXT,
    p_reason TEXT
)
RETURNS VOID AS $$
BEGIN
    -- Log failed attempt
    INSERT INTO failed_login_attempts (email, ip_address, user_agent, success, failure_reason)
    VALUES (p_email, p_ip_address, p_user_agent, FALSE, p_reason);
    
    -- Check for suspicious activity
    IF (
        SELECT COUNT(*)
        FROM failed_login_attempts
        WHERE (email = p_email OR ip_address = p_ip_address)
        AND attempted_at > NOW() - INTERVAL '15 minutes'
    ) >= 5 THEN
        -- Log suspicious activity
        INSERT INTO suspicious_activity (ip_address, activity_type, description, severity)
        VALUES (
            p_ip_address,
            'multiple_failed_logins',
            'Multiple failed login attempts detected',
            'high'
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to log security event
CREATE OR REPLACE FUNCTION log_security_event(
    p_user_id TEXT,
    p_event_type TEXT,
    p_ip_address TEXT,
    p_user_agent TEXT,
    p_success BOOLEAN DEFAULT TRUE,
    p_failure_reason TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO security_events (user_id, event_type, ip_address, user_agent, success, failure_reason, metadata)
    VALUES (p_user_id, p_event_type, p_ip_address, p_user_agent, p_success, p_failure_reason, p_metadata);
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup old rate limit records
CREATE OR REPLACE FUNCTION cleanup_old_rate_limits()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM rate_limits
    WHERE window_end < NOW() - INTERVAL '24 hours';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup old failed login attempts
CREATE OR REPLACE FUNCTION cleanup_old_failed_logins()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM failed_login_attempts
    WHERE attempted_at < NOW() - INTERVAL '30 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup old security events
CREATE OR REPLACE FUNCTION cleanup_old_security_events()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM security_events
    WHERE created_at < NOW() - INTERVAL '90 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON rate_limits TO anon, authenticated;
GRANT ALL ON failed_login_attempts TO anon, authenticated;
GRANT ALL ON suspicious_activity TO anon, authenticated;
GRANT ALL ON ip_blacklist TO authenticated;
GRANT ALL ON user_security_settings TO anon, authenticated;
GRANT ALL ON security_events TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_rate_limit TO anon, authenticated;
GRANT EXECUTE ON FUNCTION log_failed_login TO anon, authenticated;
GRANT EXECUTE ON FUNCTION log_security_event TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_rate_limits TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_failed_logins TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_security_events TO authenticated;
