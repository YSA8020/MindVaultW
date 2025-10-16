-- ============================================================================
-- MindVault Complete Database Setup Script
-- ============================================================================
-- This script sets up the entire MindVault database schema
-- Run this in your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- PART 1: Core User Tables
-- ============================================================================

-- Users table (if not already created)
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('user', 'professional', 'admin')) DEFAULT 'user',
    
    -- Subscription details
    plan TEXT CHECK (plan IN ('basic', 'premium', 'professional')) DEFAULT 'basic',
    billing_cycle TEXT CHECK (billing_cycle IN ('monthly', 'annual')) DEFAULT 'monthly',
    payment_status TEXT CHECK (payment_status IN ('trial', 'active', 'expired', 'cancelled')) DEFAULT 'trial',
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    
    -- User preferences
    support_group TEXT,
    experience_level TEXT CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
    journey TEXT,
    newsletter_subscribed BOOLEAN DEFAULT FALSE,
    
    -- Professional fields
    professional_type TEXT CHECK (professional_type IN ('licensed', 'peer_support', NULL)),
    license_type TEXT,
    license_number TEXT,
    years_experience INTEGER,
    specializations TEXT[],
    professional_bio TEXT,
    preferred_support_group TEXT,
    
    -- Verification
    verification_status TEXT CHECK (verification_status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    verified_at TIMESTAMPTZ,
    verified_by TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

-- Create indexes for users
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_verification_status ON users(verification_status);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id::uuid);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id::uuid);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id::uuid);

-- ============================================================================
-- PART 2: Error Logging System
-- ============================================================================

CREATE TABLE IF NOT EXISTS error_logs (
    id BIGSERIAL PRIMARY KEY,
    error_id TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK (type IN ('error', 'warning', 'info')),
    message TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    stack_trace TEXT,
    context JSONB,
    user_id TEXT,
    session_id TEXT,
    url TEXT,
    user_agent TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    filename TEXT,
    line_number INTEGER,
    column_number INTEGER,
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_error_logs_user_id ON error_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_error_logs_type ON error_logs(type);
CREATE INDEX IF NOT EXISTS idx_error_logs_severity ON error_logs(severity);
CREATE INDEX IF NOT EXISTS idx_error_logs_timestamp ON error_logs(timestamp);

ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view all error logs" ON error_logs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id::uuid = auth.uid() 
            AND users.user_type = 'admin'
        )
    );

-- Error stats view
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

-- Cleanup function for old error logs
CREATE OR REPLACE FUNCTION cleanup_old_error_logs()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM error_logs
    WHERE timestamp < NOW() - INTERVAL '30 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PART 3: User Activity Logging System
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_activity_logs (
    activity_id BIGSERIAL PRIMARY KEY,
    user_id TEXT,
    session_id TEXT,
    event_type TEXT NOT NULL,
    event_details JSONB,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    page_url TEXT,
    user_agent TEXT,
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_user_activity_logs_user_id ON user_activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_event_type ON user_activity_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_timestamp ON user_activity_logs(timestamp);

ALTER TABLE user_activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own activity" ON user_activity_logs
    FOR SELECT USING (auth.uid() = user_id::uuid);

-- Activity stats view
CREATE OR REPLACE VIEW user_activity_stats AS
SELECT 
    event_type,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT session_id) as unique_sessions,
    DATE_TRUNC('hour', timestamp) as hour,
    DATE_TRUNC('day', timestamp) as day,
    MAX(timestamp) as latest_timestamp
FROM user_activity_logs
GROUP BY event_type, DATE_TRUNC('hour', timestamp), DATE_TRUNC('day', timestamp)
ORDER BY latest_timestamp DESC;

-- User journey view
CREATE OR REPLACE VIEW user_journey AS
SELECT 
    user_id,
    session_id,
    MIN(timestamp) as session_start,
    MAX(timestamp) as session_end,
    COUNT(*) as events,
    array_agg(event_type ORDER BY timestamp) as event_sequence
FROM user_activity_logs
GROUP BY user_id, session_id;

-- Cleanup function for old activity logs
CREATE OR REPLACE FUNCTION cleanup_old_activity_logs()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_activity_logs
    WHERE timestamp < NOW() - INTERVAL '90 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PART 4: Rate Limiting & Security System
-- ============================================================================

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
    user_id TEXT NOT NULL UNIQUE,
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

-- Create indexes for security tables
CREATE INDEX IF NOT EXISTS idx_rate_limits_user_id ON rate_limits(user_id);
CREATE INDEX IF NOT EXISTS idx_rate_limits_ip_address ON rate_limits(ip_address);
CREATE INDEX IF NOT EXISTS idx_rate_limits_endpoint ON rate_limits(endpoint);
CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_user_id ON failed_login_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_failed_login_attempts_ip_address ON failed_login_attempts(ip_address);
CREATE INDEX IF NOT EXISTS idx_suspicious_activity_user_id ON suspicious_activity(user_id);
CREATE INDEX IF NOT EXISTS idx_suspicious_activity_severity ON suspicious_activity(severity);
CREATE INDEX IF NOT EXISTS idx_ip_blacklist_ip_address ON ip_blacklist(ip_address);
CREATE INDEX IF NOT EXISTS idx_user_security_settings_user_id ON user_security_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_security_events_user_id ON security_events(user_id);

-- Enable RLS
ALTER TABLE rate_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE failed_login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE suspicious_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE ip_blacklist ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_security_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own security settings" ON user_security_settings
    FOR SELECT USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can update own security settings" ON user_security_settings
    FOR UPDATE USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can view own security events" ON security_events
    FOR SELECT USING (auth.uid() = user_id::uuid);

CREATE POLICY "Admins can view all security data" ON rate_limits
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id::uuid = auth.uid() 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can view all failed login attempts" ON failed_login_attempts
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id::uuid = auth.uid() 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can view all suspicious activity" ON suspicious_activity
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id::uuid = auth.uid() 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can manage IP blacklist" ON ip_blacklist
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id::uuid = auth.uid() 
            AND users.user_type = 'admin'
        )
    );

CREATE POLICY "Admins can view all security events" ON security_events
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id::uuid = auth.uid() 
            AND users.user_type = 'admin'
        )
    );

-- Rate limiting function
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
    
    RETURN QUERY SELECT TRUE, p_max_requests - v_current_count - 1, v_window_end;
END;
$$ LANGUAGE plpgsql;

-- Failed login logging function
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

-- Security event logging function
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

-- Cleanup functions
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

-- ============================================================================
-- PART 5: Professional Onboarding System
-- ============================================================================

CREATE TABLE IF NOT EXISTS onboarding_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    stage_completed TEXT CHECK (stage_completed IN ('welcome', 'profile', 'credentials', 'availability', 'preferences', 'completed')),
    current_stage TEXT CHECK (current_stage IN ('welcome', 'profile', 'credentials', 'availability', 'preferences', 'completed')),
    welcome_completed BOOLEAN DEFAULT FALSE,
    profile_completed BOOLEAN DEFAULT FALSE,
    credentials_completed BOOLEAN DEFAULT FALSE,
    availability_completed BOOLEAN DEFAULT FALSE,
    preferences_completed BOOLEAN DEFAULT FALSE,
    completion_percentage INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    last_accessed TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_time_minutes INTEGER DEFAULT 0,
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS professional_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    license_type TEXT,
    license_number TEXT,
    license_state TEXT,
    license_expiry DATE,
    years_experience INTEGER,
    specializations TEXT[],
    treatment_approaches TEXT[],
    client_populations TEXT[],
    bio TEXT,
    education TEXT,
    certifications TEXT[],
    languages TEXT[],
    practice_name TEXT,
    practice_address TEXT,
    practice_phone TEXT,
    practice_website TEXT,
    session_duration_minutes INTEGER DEFAULT 60,
    session_type TEXT CHECK (session_type IN ('individual', 'group', 'couples', 'family')),
    session_format TEXT CHECK (session_format IN ('in-person', 'video', 'phone', 'hybrid')),
    timezone TEXT DEFAULT 'America/New_York',
    working_hours JSONB,
    hourly_rate DECIMAL(10, 2),
    accepts_insurance BOOLEAN DEFAULT FALSE,
    insurance_providers TEXT[],
    sliding_scale BOOLEAN DEFAULT FALSE,
    sliding_scale_details TEXT,
    profile_visible BOOLEAN DEFAULT FALSE,
    profile_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS onboarding_checkpoints (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    checkpoint_name TEXT NOT NULL,
    checkpoint_type TEXT CHECK (checkpoint_type IN ('info', 'action', 'verification', 'test')),
    stage TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    data JSONB,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS onboarding_resources (
    id BIGSERIAL PRIMARY KEY,
    stage TEXT NOT NULL,
    resource_type TEXT CHECK (resource_type IN ('video', 'article', 'guide', 'tip', 'faq')),
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    url TEXT,
    order_index INTEGER DEFAULT 0,
    required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_onboarding_progress_user_id ON onboarding_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_professional_profiles_user_id ON professional_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_onboarding_checkpoints_user_id ON onboarding_checkpoints(user_id);

-- Enable RLS
ALTER TABLE onboarding_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_checkpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_resources ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own onboarding progress" ON onboarding_progress
    FOR SELECT USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can update own onboarding progress" ON onboarding_progress
    FOR UPDATE USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can insert own onboarding progress" ON onboarding_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can view own professional profile" ON professional_profiles
    FOR SELECT USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can update own professional profile" ON professional_profiles
    FOR UPDATE USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can insert own professional profile" ON professional_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can view own onboarding checkpoints" ON onboarding_checkpoints
    FOR ALL USING (auth.uid() = user_id::uuid);

CREATE POLICY "Public can view onboarding resources" ON onboarding_resources
    FOR SELECT USING (true);

-- Onboarding functions
CREATE OR REPLACE FUNCTION initialize_professional_onboarding(p_user_id TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO onboarding_progress (user_id, current_stage, stage_completed)
    VALUES (p_user_id, 'welcome', NULL)
    ON CONFLICT (user_id) DO UPDATE
    SET last_accessed = NOW();
    
    INSERT INTO professional_profiles (user_id, profile_visible, profile_completed)
    VALUES (p_user_id, FALSE, FALSE)
    ON CONFLICT (user_id) DO NOTHING;
    
    INSERT INTO onboarding_checkpoints (user_id, checkpoint_name, checkpoint_type, stage, order_index)
    VALUES
        (p_user_id, 'Welcome Video', 'info', 'welcome', 1),
        (p_user_id, 'Complete Profile', 'action', 'profile', 2),
        (p_user_id, 'Verify Credentials', 'verification', 'credentials', 3),
        (p_user_id, 'Set Availability', 'action', 'availability', 4),
        (p_user_id, 'Configure Preferences', 'action', 'preferences', 5),
        (p_user_id, 'Platform Tour', 'info', 'preferences', 6)
    ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_onboarding_progress(
    p_user_id TEXT,
    p_stage TEXT
)
RETURNS TABLE (
    completion_percentage INTEGER,
    next_stage TEXT
) AS $$
DECLARE
    v_completion INTEGER;
    v_next_stage TEXT;
BEGIN
    UPDATE onboarding_progress
    SET 
        stage_completed = p_stage,
        current_stage = CASE 
            WHEN p_stage = 'welcome' THEN 'profile'
            WHEN p_stage = 'profile' THEN 'credentials'
            WHEN p_stage = 'credentials' THEN 'availability'
            WHEN p_stage = 'availability' THEN 'preferences'
            WHEN p_stage = 'preferences' THEN 'completed'
            ELSE 'completed'
        END,
        welcome_completed = CASE WHEN p_stage = 'welcome' THEN TRUE ELSE welcome_completed END,
        profile_completed = CASE WHEN p_stage = 'profile' THEN TRUE ELSE profile_completed END,
        credentials_completed = CASE WHEN p_stage = 'credentials' THEN TRUE ELSE credentials_completed END,
        availability_completed = CASE WHEN p_stage = 'availability' THEN TRUE ELSE availability_completed END,
        preferences_completed = CASE WHEN p_stage = 'preferences' THEN TRUE ELSE preferences_completed END,
        last_accessed = NOW()
    WHERE user_id = p_user_id;
    
    SELECT 
        CASE 
            WHEN welcome_completed AND profile_completed AND credentials_completed 
                 AND availability_completed AND preferences_completed THEN 100
            WHEN welcome_completed AND profile_completed AND credentials_completed 
                 AND availability_completed THEN 80
            WHEN welcome_completed AND profile_completed AND credentials_completed THEN 60
            WHEN welcome_completed AND profile_completed THEN 40
            WHEN welcome_completed THEN 20
            ELSE 0
        END,
        current_stage
    INTO v_completion, v_next_stage
    FROM onboarding_progress
    WHERE user_id = p_user_id;
    
    UPDATE onboarding_progress
    SET completion_percentage = v_completion
    WHERE user_id = p_user_id;
    
    IF v_completion = 100 THEN
        UPDATE onboarding_progress
        SET completed_at = NOW()
        WHERE user_id = p_user_id;
        
        UPDATE professional_profiles
        SET profile_visible = TRUE, profile_completed = TRUE
        WHERE user_id = p_user_id;
    END IF;
    
    RETURN QUERY SELECT v_completion, v_next_stage;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_onboarding_status(p_user_id TEXT)
RETURNS TABLE (
    current_stage TEXT,
    completion_percentage INTEGER,
    stages_completed JSONB,
    next_checkpoints JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        op.current_stage,
        op.completion_percentage,
        jsonb_build_object(
            'welcome', op.welcome_completed,
            'profile', op.profile_completed,
            'credentials', op.credentials_completed,
            'availability', op.availability_completed,
            'preferences', op.preferences_completed
        ) as stages_completed,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'name', checkpoint_name,
                    'type', checkpoint_type,
                    'completed', completed,
                    'order', order_index
                ) ORDER BY order_index
            )
            FROM onboarding_checkpoints
            WHERE user_id = p_user_id
            AND stage = op.current_stage
            AND completed = FALSE
        ) as next_checkpoints
    FROM onboarding_progress op
    WHERE op.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert default onboarding resources
INSERT INTO onboarding_resources (stage, resource_type, title, description, content, order_index, required)
VALUES
    ('welcome', 'video', 'Welcome to MindVault', 'Get started with your professional journey', 'https://example.com/welcome-video', 1, TRUE),
    ('welcome', 'article', 'Platform Overview', 'Learn about MindVault features', 'MindVault provides a comprehensive platform for mental health professionals...', 2, TRUE),
    ('profile', 'guide', 'Creating Your Profile', 'Step-by-step profile creation guide', 'Your professional profile is your first impression...', 1, TRUE),
    ('profile', 'tip', 'Profile Best Practices', 'Tips for an effective profile', 'Use a professional photo, write a clear bio...', 2, FALSE),
    ('credentials', 'guide', 'Verifying Your Credentials', 'How to verify your professional credentials', 'Upload clear photos of your licenses...', 1, TRUE),
    ('availability', 'guide', 'Setting Your Availability', 'Manage your schedule effectively', 'Set your working hours and timezone...', 1, TRUE),
    ('preferences', 'guide', 'Platform Preferences', 'Customize your experience', 'Configure notification settings...', 1, TRUE),
    ('preferences', 'faq', 'Common Questions', 'Frequently asked questions', 'Q: How do I get matched with clients? A: Clients will be matched based on...', 2, FALSE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- PART 6: Professional Dashboard & Client Management
-- ============================================================================

CREATE TABLE IF NOT EXISTS client_professional_relationships (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    relationship_status TEXT CHECK (relationship_status IN ('pending', 'active', 'paused', 'ended')) DEFAULT 'pending',
    match_score DECIMAL(5, 2),
    matched_on DATE NOT NULL DEFAULT CURRENT_DATE,
    matched_by TEXT CHECK (matched_by IN ('platform', 'manual', 'referral')),
    total_sessions INTEGER DEFAULT 0,
    sessions_this_month INTEGER DEFAULT 0,
    last_session_date DATE,
    initial_assessment_completed BOOLEAN DEFAULT FALSE,
    treatment_plan_created BOOLEAN DEFAULT FALSE,
    goals_set BOOLEAN DEFAULT FALSE,
    professional_notes TEXT,
    client_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    UNIQUE(client_id, professional_id)
);

CREATE TABLE IF NOT EXISTS sessions (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    session_date DATE NOT NULL,
    session_time TIME NOT NULL,
    session_duration_minutes INTEGER DEFAULT 60,
    session_type TEXT CHECK (session_type IN ('individual', 'group', 'couples', 'family')),
    session_format TEXT CHECK (session_format IN ('in-person', 'video', 'phone')),
    session_status TEXT CHECK (session_status IN ('scheduled', 'completed', 'cancelled', 'no-show', 'rescheduled')) DEFAULT 'scheduled',
    location TEXT,
    video_link TEXT,
    phone_number TEXT,
    session_notes TEXT,
    treatment_goals_discussed TEXT[],
    interventions_used TEXT[],
    homework_assigned TEXT,
    client_mood_before INTEGER CHECK (client_mood_before BETWEEN 1 AND 10),
    client_mood_after INTEGER CHECK (client_mood_after BETWEEN 1 AND 10),
    progress_rating INTEGER CHECK (progress_rating BETWEEN 1 AND 10),
    session_fee DECIMAL(10, 2),
    payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'insurance', 'waived')) DEFAULT 'pending',
    insurance_claim_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS treatment_plans (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    plan_name TEXT NOT NULL,
    plan_description TEXT,
    diagnosis TEXT,
    presenting_problems TEXT[],
    primary_goals TEXT[],
    secondary_goals TEXT[],
    measurable_objectives TEXT[],
    treatment_approach TEXT,
    interventions_planned TEXT[],
    estimated_duration_weeks INTEGER,
    start_date DATE NOT NULL,
    end_date DATE,
    status TEXT CHECK (status IN ('active', 'completed', 'on-hold', 'terminated')) DEFAULT 'active',
    outcome_measures TEXT[],
    progress_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS client_assessments (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    assessment_type TEXT NOT NULL CHECK (assessment_type IN ('initial', 'progress', 'outcome', 'custom')),
    assessment_name TEXT NOT NULL,
    assessment_date DATE NOT NULL,
    scores JSONB,
    results_summary TEXT,
    recommendations TEXT,
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS client_notes (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    session_id BIGINT,
    note_type TEXT CHECK (note_type IN ('session', 'phone', 'email', 'general', 'emergency')) DEFAULT 'general',
    note_date DATE NOT NULL,
    note_time TIME NOT NULL,
    subjective TEXT,
    objective TEXT,
    assessment TEXT,
    plan TEXT,
    confidential BOOLEAN DEFAULT TRUE,
    shared_with_client BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS professional_availability (
    id BIGSERIAL PRIMARY KEY,
    professional_id TEXT NOT NULL UNIQUE,
    available_for_new_clients BOOLEAN DEFAULT TRUE,
    max_clients INTEGER DEFAULT 20,
    current_client_count INTEGER DEFAULT 0,
    advance_booking_days INTEGER DEFAULT 30,
    cancellation_policy_hours INTEGER DEFAULT 24,
    reschedule_policy_hours INTEGER DEFAULT 48,
    available_slots JSONB,
    vacation_dates DATE[],
    blackout_dates DATE[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS professional_analytics (
    id BIGSERIAL PRIMARY KEY,
    professional_id TEXT NOT NULL,
    analytics_date DATE NOT NULL,
    total_clients INTEGER DEFAULT 0,
    active_clients INTEGER DEFAULT 0,
    new_clients INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    completed_sessions INTEGER DEFAULT 0,
    cancelled_sessions INTEGER DEFAULT 0,
    no_shows INTEGER DEFAULT 0,
    total_revenue DECIMAL(10, 2) DEFAULT 0,
    insurance_revenue DECIMAL(10, 2) DEFAULT 0,
    cash_revenue DECIMAL(10, 2) DEFAULT 0,
    average_session_duration_minutes INTEGER,
    client_satisfaction_score DECIMAL(3, 2),
    treatment_completion_rate DECIMAL(5, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    UNIQUE(professional_id, analytics_date)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_client_professional_relationships_client_id ON client_professional_relationships(client_id);
CREATE INDEX IF NOT EXISTS idx_client_professional_relationships_professional_id ON client_professional_relationships(professional_id);
CREATE INDEX IF NOT EXISTS idx_sessions_client_id ON sessions(client_id);
CREATE INDEX IF NOT EXISTS idx_sessions_professional_id ON sessions(professional_id);
CREATE INDEX IF NOT EXISTS idx_sessions_session_date ON sessions(session_date);
CREATE INDEX IF NOT EXISTS idx_treatment_plans_client_id ON treatment_plans(client_id);
CREATE INDEX IF NOT EXISTS idx_client_assessments_client_id ON client_assessments(client_id);
CREATE INDEX IF NOT EXISTS idx_client_notes_client_id ON client_notes(client_id);

-- Enable RLS
ALTER TABLE client_professional_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatment_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_analytics ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Professionals can view own client relationships" ON client_professional_relationships
    FOR SELECT USING (auth.uid() = professional_id::uuid);

CREATE POLICY "Professionals can manage own client relationships" ON client_professional_relationships
    FOR ALL USING (auth.uid() = professional_id::uuid);

CREATE POLICY "Clients can view own relationships" ON client_professional_relationships
    FOR SELECT USING (auth.uid() = client_id::uuid);

CREATE POLICY "Professionals can view own sessions" ON sessions
    FOR ALL USING (auth.uid() = professional_id::uuid);

CREATE POLICY "Clients can view own sessions" ON sessions
    FOR SELECT USING (auth.uid() = client_id::uuid);

CREATE POLICY "Professionals can view own treatment plans" ON treatment_plans
    FOR ALL USING (auth.uid() = professional_id::uuid);

CREATE POLICY "Clients can view own treatment plans" ON treatment_plans
    FOR SELECT USING (auth.uid() = client_id::uuid);

CREATE POLICY "Professionals can view own assessments" ON client_assessments
    FOR ALL USING (auth.uid() = professional_id::uuid);

CREATE POLICY "Clients can view own assessments" ON client_assessments
    FOR SELECT USING (auth.uid() = client_id::uuid);

CREATE POLICY "Professionals can view own notes" ON client_notes
    FOR ALL USING (auth.uid() = professional_id::uuid);

CREATE POLICY "Professionals can manage own availability" ON professional_availability
    FOR ALL USING (auth.uid() = professional_id::uuid);

CREATE POLICY "Professionals can view own analytics" ON professional_analytics
    FOR ALL USING (auth.uid() = professional_id::uuid);

-- Professional dashboard functions
CREATE OR REPLACE FUNCTION get_professional_dashboard_stats(p_professional_id TEXT)
RETURNS TABLE (
    total_clients INTEGER,
    active_clients INTEGER,
    pending_clients INTEGER,
    sessions_today INTEGER,
    sessions_this_week INTEGER,
    upcoming_sessions INTEGER,
    total_revenue DECIMAL,
    monthly_revenue DECIMAL,
    completion_rate DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM client_professional_relationships WHERE professional_id = p_professional_id)::INTEGER,
        (SELECT COUNT(*) FROM client_professional_relationships WHERE professional_id = p_professional_id AND relationship_status = 'active')::INTEGER,
        (SELECT COUNT(*) FROM client_professional_relationships WHERE professional_id = p_professional_id AND relationship_status = 'pending')::INTEGER,
        (SELECT COUNT(*) FROM sessions WHERE professional_id = p_professional_id AND session_date = CURRENT_DATE)::INTEGER,
        (SELECT COUNT(*) FROM sessions WHERE professional_id = p_professional_id AND session_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days')::INTEGER,
        (SELECT COUNT(*) FROM sessions WHERE professional_id = p_professional_id AND session_status = 'scheduled' AND session_date >= CURRENT_DATE)::INTEGER,
        (SELECT COALESCE(SUM(session_fee), 0) FROM sessions WHERE professional_id = p_professional_id AND payment_status = 'paid')::DECIMAL,
        (SELECT COALESCE(SUM(session_fee), 0) FROM sessions WHERE professional_id = p_professional_id AND payment_status = 'paid' AND session_date >= DATE_TRUNC('month', CURRENT_DATE))::DECIMAL,
        (SELECT CASE 
            WHEN COUNT(*) > 0 THEN (COUNT(*) FILTER (WHERE session_status = 'completed')::DECIMAL / COUNT(*)::DECIMAL * 100)
            ELSE 0
        END FROM sessions WHERE professional_id = p_professional_id)::DECIMAL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_upcoming_sessions(p_professional_id TEXT, p_limit INTEGER DEFAULT 10)
RETURNS TABLE (
    session_id BIGINT,
    client_name TEXT,
    session_date DATE,
    session_time TIME,
    session_format TEXT,
    session_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        CONCAT(u.first_name, ' ', u.last_name) as client_name,
        s.session_date,
        s.session_time,
        s.session_format,
        s.session_status
    FROM sessions s
    JOIN users u ON s.client_id = u.id
    WHERE s.professional_id = p_professional_id
    AND s.session_status = 'scheduled'
    AND s.session_date >= CURRENT_DATE
    ORDER BY s.session_date ASC, s.session_time ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_professional_clients(p_professional_id TEXT, p_status TEXT DEFAULT 'active')
RETURNS TABLE (
    client_id TEXT,
    client_name TEXT,
    client_email TEXT,
    relationship_status TEXT,
    total_sessions INTEGER,
    last_session_date DATE,
    match_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cpr.client_id,
        CONCAT(u.first_name, ' ', u.last_name) as client_name,
        u.email as client_email,
        cpr.relationship_status,
        cpr.total_sessions,
        cpr.last_session_date,
        cpr.match_score
    FROM client_professional_relationships cpr
    JOIN users u ON cpr.client_id = u.id
    WHERE cpr.professional_id = p_professional_id
    AND (p_status IS NULL OR cpr.relationship_status = p_status)
    ORDER BY cpr.last_session_date DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON users TO anon, authenticated;
GRANT ALL ON error_logs TO anon, authenticated;
GRANT ALL ON user_activity_logs TO anon, authenticated;
GRANT ALL ON rate_limits TO anon, authenticated;
GRANT ALL ON failed_login_attempts TO anon, authenticated;
GRANT ALL ON suspicious_activity TO anon, authenticated;
GRANT ALL ON ip_blacklist TO authenticated;
GRANT ALL ON user_security_settings TO anon, authenticated;
GRANT ALL ON security_events TO anon, authenticated;
GRANT ALL ON onboarding_progress TO anon, authenticated;
GRANT ALL ON professional_profiles TO anon, authenticated;
GRANT ALL ON onboarding_checkpoints TO anon, authenticated;
GRANT ALL ON onboarding_resources TO anon, authenticated;
GRANT ALL ON client_professional_relationships TO anon, authenticated;
GRANT ALL ON sessions TO anon, authenticated;
GRANT ALL ON treatment_plans TO anon, authenticated;
GRANT ALL ON client_assessments TO anon, authenticated;
GRANT ALL ON client_notes TO anon, authenticated;
GRANT ALL ON professional_availability TO anon, authenticated;
GRANT ALL ON professional_analytics TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Grant execute permissions on all functions
GRANT EXECUTE ON FUNCTION check_rate_limit TO anon, authenticated;
GRANT EXECUTE ON FUNCTION log_failed_login TO anon, authenticated;
GRANT EXECUTE ON FUNCTION log_security_event TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_rate_limits TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_failed_logins TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_security_events TO authenticated;
GRANT EXECUTE ON FUNCTION initialize_professional_onboarding TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_onboarding_progress TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_onboarding_status TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_professional_dashboard_stats TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_upcoming_sessions TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_professional_clients TO anon, authenticated;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================
-- Your MindVault database is now fully configured!
-- 
-- Next steps:
-- 1. Verify all tables were created successfully
-- 2. Test the functions
-- 3. Set up your admin user
-- 4. Configure email notifications (optional)
-- 5. Launch your beta!
-- ============================================================================
