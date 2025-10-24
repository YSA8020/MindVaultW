-- Step-by-step setup PART 2 - Testing remaining functions
-- Run each section one at a time and report which one fails

-- ============================================================================
-- STEP 4: Create Security Tables
-- ============================================================================
-- Run this section after Step 3 succeeds

CREATE TABLE IF NOT EXISTS rate_limits (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
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

CREATE TABLE IF NOT EXISTS failed_login_attempts (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
    email TEXT,
    ip_address TEXT NOT NULL,
    user_agent TEXT,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    success BOOLEAN DEFAULT FALSE,
    failure_reason TEXT,
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS suspicious_activity (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
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

CREATE TABLE IF NOT EXISTS user_security_settings (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    max_login_attempts INTEGER DEFAULT 5,
    lockout_duration_minutes INTEGER DEFAULT 15,
    require_two_factor BOOLEAN DEFAULT FALSE,
    two_factor_secret TEXT,
    session_timeout_minutes INTEGER DEFAULT 1440,
    max_concurrent_sessions INTEGER DEFAULT 3,
    last_login_at TIMESTAMPTZ,
    last_login_ip TEXT,
    last_activity_at TIMESTAMPTZ,
    failed_login_count INTEGER DEFAULT 0,
    account_locked BOOLEAN DEFAULT FALSE,
    locked_until TIMESTAMPTZ,
    email_security_alerts BOOLEAN DEFAULT TRUE,
    sms_security_alerts BOOLEAN DEFAULT FALSE,
    security_alert_threshold TEXT CHECK (security_alert_threshold IN ('low', 'medium', 'high')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS security_events (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID,
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

-- If Step 4 succeeds, continue to Step 5
-- If Step 4 fails, report the error

-- ============================================================================
-- STEP 5: Create log_failed_login Function
-- ============================================================================
-- Run this section after Step 4 succeeds

CREATE OR REPLACE FUNCTION log_failed_login(
    p_email TEXT,
    p_ip_address TEXT,
    p_user_agent TEXT,
    p_reason TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO failed_login_attempts (email, ip_address, user_agent, success, failure_reason)
    VALUES (p_email, p_ip_address, p_user_agent, FALSE, p_reason);
    
    IF (
        SELECT COUNT(*)
        FROM failed_login_attempts
        WHERE (email = p_email OR ip_address = p_ip_address)
        AND attempted_at > NOW() - INTERVAL '15 minutes'
    ) >= 5 THEN
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

-- If Step 5 succeeds, continue to Step 6
-- If Step 5 fails, report the error

-- ============================================================================
-- STEP 6: Create log_security_event Function
-- ============================================================================
-- Run this section after Step 5 succeeds

CREATE OR REPLACE FUNCTION log_security_event(
    p_user_id UUID,
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

-- If Step 6 succeeds, the issue is NOT in these security functions
-- If Step 6 fails, report the error - this is where the problem is!

-- ============================================================================
-- INSTRUCTIONS:
-- ============================================================================
-- 1. Run Step 4 first
-- 2. If successful, run Step 5
-- 3. If successful, run Step 6
-- 4. Report which step fails (if any)
-- 5. If all steps succeed, we'll test the professional functions next
-- ============================================================================
