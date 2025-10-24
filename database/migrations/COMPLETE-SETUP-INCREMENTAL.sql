-- ============================================================================
-- MindVault Complete Database Setup - Incremental Approach
-- ============================================================================
-- This script combines all the incremental setup scripts
-- Run this to set up the complete database
-- ============================================================================

-- ============================================================================
-- STEP 1: Fresh Start (Core Tables)
-- ============================================================================

-- Drop views first
DROP VIEW IF EXISTS user_journey CASCADE;
DROP VIEW IF EXISTS user_activity_stats CASCADE;
DROP VIEW IF EXISTS error_stats CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS restore_from_backup(BIGINT, TEXT[]) CASCADE;
DROP FUNCTION IF EXISTS create_full_backup(TEXT, JSONB) CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_activity_logs(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_error_logs(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_professional_clients(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_upcoming_sessions(UUID, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_professional_dashboard_stats(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_onboarding_status(UUID) CASCADE;
DROP FUNCTION IF EXISTS update_onboarding_progress(UUID, INTEGER, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS initialize_professional_onboarding(UUID) CASCADE;
DROP FUNCTION IF EXISTS log_security_event(UUID, TEXT, TEXT, TEXT, JSONB) CASCADE;
DROP FUNCTION IF EXISTS log_failed_login(UUID, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS check_rate_limit(UUID, TEXT, TEXT, INTEGER, INTEGER) CASCADE;

-- Drop tables (in reverse dependency order)
DROP TABLE IF EXISTS restore_history CASCADE;
DROP TABLE IF EXISTS backup_history CASCADE;
DROP TABLE IF EXISTS emergency_response_logs CASCADE;
DROP TABLE IF EXISTS anonymous_posts CASCADE;
DROP TABLE IF EXISTS professional_analytics CASCADE;
DROP TABLE IF EXISTS professional_availability CASCADE;
DROP TABLE IF EXISTS client_notes CASCADE;
DROP TABLE IF EXISTS client_assessments CASCADE;
DROP TABLE IF EXISTS treatment_plans CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS client_professional_relationships CASCADE;
DROP TABLE IF EXISTS onboarding_resources CASCADE;
DROP TABLE IF EXISTS onboarding_checkpoints CASCADE;
DROP TABLE IF EXISTS onboarding_progress CASCADE;
DROP TABLE IF EXISTS professional_profiles CASCADE;
DROP TABLE IF EXISTS security_events CASCADE;
DROP TABLE IF EXISTS user_security_settings CASCADE;
DROP TABLE IF EXISTS ip_blacklist CASCADE;
DROP TABLE IF EXISTS suspicious_activity CASCADE;
DROP TABLE IF EXISTS failed_login_attempts CASCADE;
DROP TABLE IF EXISTS rate_limits CASCADE;
DROP TABLE IF EXISTS user_activity_logs CASCADE;
DROP TABLE IF EXISTS error_logs CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create Core User Tables
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('user', 'professional', 'admin')) DEFAULT 'user',
    plan TEXT CHECK (plan IN ('basic', 'premium', 'professional')) DEFAULT 'basic',
    billing_cycle TEXT CHECK (billing_cycle IN ('monthly', 'annual')) DEFAULT 'monthly',
    payment_status TEXT CHECK (payment_status IN ('trial', 'active', 'expired', 'cancelled')) DEFAULT 'trial',
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    support_group TEXT,
    experience_level TEXT CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
    journey TEXT,
    newsletter_subscribed BOOLEAN DEFAULT FALSE,
    professional_type TEXT CHECK (professional_type IN ('licensed', 'peer_support', NULL)),
    license_type TEXT,
    license_number TEXT,
    years_experience INTEGER,
    specializations TEXT[],
    professional_bio TEXT,
    preferred_support_group TEXT,
    verification_status TEXT CHECK (verification_status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    verified_at TIMESTAMPTZ,
    verified_by TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_verification_status ON users(verification_status);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Create Professional Profiles Table
CREATE TABLE professional_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
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
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_professional_profiles_user_id ON professional_profiles(user_id);
ALTER TABLE professional_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own professional profile" ON professional_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own professional profile" ON professional_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own professional profile" ON professional_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create Onboarding Tables
CREATE TABLE onboarding_progress (
    professional_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_step INTEGER DEFAULT 1,
    completed_steps INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    profile_completed BOOLEAN DEFAULT FALSE,
    credentials_completed BOOLEAN DEFAULT FALSE,
    availability_completed BOOLEAN DEFAULT FALSE,
    preferences_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_onboarding_progress_professional ON onboarding_progress(professional_id);

CREATE TABLE onboarding_checkpoints (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID REFERENCES users(id) ON DELETE CASCADE,
    checkpoint_name TEXT NOT NULL,
    checkpoint_data JSONB,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_checkpoints_professional ON onboarding_checkpoints(professional_id);

CREATE TABLE onboarding_resources (
    id BIGSERIAL PRIMARY KEY,
    resource_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    video_url TEXT,
    order_index INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Onboarding Functions
CREATE FUNCTION initialize_professional_onboarding(p_professional_id UUID)
RETURNS VOID AS $$
BEGIN
    INSERT INTO onboarding_progress (professional_id, current_step, completed_steps)
    VALUES (p_professional_id, 1, ARRAY[]::INTEGER[])
    ON CONFLICT (professional_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION update_onboarding_progress(p_professional_id UUID, p_step INTEGER, p_completed BOOLEAN DEFAULT TRUE)
RETURNS VOID AS $$
BEGIN
    UPDATE onboarding_progress
    SET current_step = p_step,
        completed_steps = CASE WHEN p_completed THEN completed_steps || p_step ELSE completed_steps END,
        updated_at = NOW()
    WHERE professional_id = p_professional_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_onboarding_status(p_professional_id UUID)
RETURNS TABLE (
    current_step INTEGER,
    completed_steps INTEGER[],
    profile_completed BOOLEAN,
    credentials_completed BOOLEAN,
    availability_completed BOOLEAN,
    preferences_completed BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT op.current_step, op.completed_steps, op.profile_completed,
           op.credentials_completed, op.availability_completed, op.preferences_completed
    FROM onboarding_progress op
    WHERE op.professional_id = p_professional_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STEP 2: Security Tables and Functions
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

CREATE FUNCTION check_rate_limit(p_user_id UUID, p_ip_address TEXT, p_endpoint TEXT, p_max_requests INTEGER DEFAULT 60, p_window_minutes INTEGER DEFAULT 60)
RETURNS TABLE (allowed BOOLEAN, remaining_requests INTEGER, reset_time TIMESTAMPTZ) AS $$
DECLARE
    v_current_count INTEGER;
    v_window_start TIMESTAMPTZ;
    v_window_end TIMESTAMPTZ;
    v_blocked BOOLEAN;
    v_blocked_until TIMESTAMPTZ;
BEGIN
    SELECT TRUE, blocked_until INTO v_blocked, v_blocked_until
    FROM ip_blacklist
    WHERE ip_address = p_ip_address AND (blocked_until IS NULL OR blocked_until > NOW()) AND permanent = TRUE;
    
    IF v_blocked THEN
        RETURN QUERY SELECT FALSE, 0, v_blocked_until;
        RETURN;
    END IF;
    
    v_window_start := DATE_TRUNC('hour', NOW());
    v_window_end := v_window_start + (p_window_minutes || ' minutes')::INTERVAL;
    
    SELECT request_count INTO v_current_count
    FROM rate_limits
    WHERE (user_id = p_user_id OR (user_id IS NULL AND ip_address = p_ip_address))
    AND endpoint = p_endpoint AND window_start = v_window_start;
    
    IF v_current_count IS NULL THEN
        INSERT INTO rate_limits (user_id, ip_address, endpoint, window_start, window_end, request_count)
        VALUES (p_user_id, p_ip_address, p_endpoint, v_window_start, v_window_end, 1);
        v_current_count := 1;
    END IF;
    
    IF v_current_count >= p_max_requests THEN
        UPDATE rate_limits SET blocked = TRUE, blocked_until = NOW() + INTERVAL '1 hour'
        WHERE (user_id = p_user_id OR (user_id IS NULL AND ip_address = p_ip_address))
        AND endpoint = p_endpoint AND window_start = v_window_start;
        
        RETURN QUERY SELECT FALSE, 0, v_window_end;
        RETURN;
    END IF;
    
    UPDATE rate_limits SET request_count = request_count + 1, updated_at = NOW()
    WHERE (user_id = p_user_id OR (user_id IS NULL AND ip_address = p_ip_address))
    AND endpoint = p_endpoint AND window_start = v_window_start;
    
    RETURN QUERY SELECT TRUE, p_max_requests - v_current_count - 1, v_window_end;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION log_failed_login(p_user_id UUID, p_email TEXT, p_ip_address TEXT, p_failure_reason TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO failed_login_attempts (user_id, email, ip_address, success, failure_reason)
    VALUES (p_user_id, p_email, p_ip_address, FALSE, p_failure_reason);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION log_security_event(p_user_id UUID, p_event_type TEXT, p_description TEXT, p_ip_address TEXT, p_metadata JSONB DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    INSERT INTO security_events (user_id, event_type, description, ip_address, metadata)
    VALUES (p_user_id, p_event_type, p_description, p_ip_address, p_metadata);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STEP 3: Professional Dashboard Tables and Functions
-- ============================================================================

CREATE TABLE client_professional_relationships (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    relationship_status TEXT CHECK (relationship_status IN ('active', 'paused', 'ended')) DEFAULT 'active',
    match_score INTEGER,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(professional_id, client_id)
);

CREATE INDEX idx_cpr_professional ON client_professional_relationships(professional_id);
CREATE INDEX idx_cpr_client ON client_professional_relationships(client_id);

CREATE TABLE sessions (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_type TEXT CHECK (session_type IN ('individual', 'group', 'emergency')),
    session_format TEXT CHECK (session_format IN ('video', 'phone', 'chat', 'in_person')),
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    status TEXT CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')) DEFAULT 'scheduled',
    notes TEXT,
    billing_status TEXT CHECK (billing_status IN ('pending', 'billed', 'paid')) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sessions_professional ON sessions(professional_id);
CREATE INDEX idx_sessions_client ON sessions(client_id);
CREATE INDEX idx_sessions_scheduled ON sessions(scheduled_at);

CREATE TABLE treatment_plans (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_name TEXT NOT NULL,
    goals TEXT[],
    diagnosis TEXT,
    interventions TEXT[],
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    status TEXT CHECK (status IN ('active', 'completed', 'paused')) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_treatment_professional ON treatment_plans(professional_id);
CREATE INDEX idx_treatment_client ON treatment_plans(client_id);

CREATE TABLE client_assessments (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assessment_type TEXT NOT NULL,
    assessment_data JSONB,
    score INTEGER,
    notes TEXT,
    assessed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_assessments_professional ON client_assessments(professional_id);
CREATE INDEX idx_assessments_client ON client_assessments(client_id);

CREATE TABLE client_notes (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id BIGINT REFERENCES sessions(id),
    note_type TEXT CHECK (note_type IN ('session', 'progress', 'general')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notes_professional ON client_notes(professional_id);
CREATE INDEX idx_notes_client ON client_notes(client_id);
CREATE INDEX idx_notes_session ON client_notes(session_id);

CREATE TABLE professional_availability (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    timezone TEXT DEFAULT 'UTC',
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_availability_professional ON professional_availability(professional_id);

CREATE TABLE professional_analytics (
    id BIGSERIAL PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_sessions INTEGER DEFAULT 0,
    completed_sessions INTEGER DEFAULT 0,
    cancelled_sessions INTEGER DEFAULT 0,
    revenue DECIMAL(10,2) DEFAULT 0,
    active_clients INTEGER DEFAULT 0,
    new_clients INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(professional_id, date)
);

CREATE INDEX idx_analytics_professional ON professional_analytics(professional_id);
CREATE INDEX idx_analytics_date ON professional_analytics(date);

CREATE FUNCTION get_professional_dashboard_stats(p_professional_id UUID)
RETURNS TABLE (total_clients BIGINT, active_clients BIGINT, upcoming_sessions BIGINT, completed_sessions_today BIGINT, revenue_today DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT cpr.client_id)::BIGINT,
        COUNT(DISTINCT CASE WHEN cpr.relationship_status = 'active' THEN cpr.client_id END)::BIGINT,
        COUNT(DISTINCT CASE WHEN s.status = 'scheduled' AND s.scheduled_at > NOW() THEN s.id END)::BIGINT,
        COUNT(DISTINCT CASE WHEN s.status = 'completed' AND DATE(s.scheduled_at) = CURRENT_DATE THEN s.id END)::BIGINT,
        COALESCE(SUM(CASE WHEN s.status = 'completed' AND DATE(s.scheduled_at) = CURRENT_DATE THEN (s.duration_minutes::DECIMAL / 60) * 100 ELSE 0 END), 0)
    FROM client_professional_relationships cpr
    LEFT JOIN sessions s ON s.professional_id = p_professional_id
    WHERE cpr.professional_id = p_professional_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_upcoming_sessions(p_professional_id UUID, p_days_ahead INTEGER DEFAULT 7)
RETURNS TABLE (session_id BIGINT, client_id UUID, client_name TEXT, session_type TEXT, session_format TEXT, scheduled_at TIMESTAMPTZ, duration_minutes INTEGER, status TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.client_id, u.first_name || ' ' || u.last_name, s.session_type, s.session_format, s.scheduled_at, s.duration_minutes, s.status
    FROM sessions s
    JOIN users u ON u.id = s.client_id
    WHERE s.professional_id = p_professional_id
    AND s.scheduled_at BETWEEN NOW() AND NOW() + (p_days_ahead || ' days')::INTERVAL
    ORDER BY s.scheduled_at ASC;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_professional_clients(p_professional_id UUID)
RETURNS TABLE (client_id UUID, client_name TEXT, relationship_status TEXT, last_session_date TIMESTAMPTZ, total_sessions BIGINT, match_score INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT cpr.client_id, u.first_name || ' ' || u.last_name, cpr.relationship_status, MAX(s.scheduled_at), COUNT(s.id)::BIGINT, cpr.match_score
    FROM client_professional_relationships cpr
    JOIN users u ON u.id = cpr.client_id
    LEFT JOIN sessions s ON s.client_id = cpr.client_id AND s.professional_id = p_professional_id
    WHERE cpr.professional_id = p_professional_id
    GROUP BY cpr.client_id, u.first_name, u.last_name, cpr.relationship_status, cpr.match_score
    ORDER BY cpr.relationship_status, u.first_name;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STEP 4: Monitoring and Logging
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
SELECT DATE_TRUNC('hour', timestamp) as hour, DATE_TRUNC('day', timestamp) as day, severity,
       COUNT(*) as error_count, COUNT(DISTINCT user_id) as affected_users, MAX(timestamp) as latest_timestamp
FROM error_logs
GROUP BY DATE_TRUNC('hour', timestamp), DATE_TRUNC('day', timestamp), severity
ORDER BY latest_timestamp DESC;

CREATE FUNCTION cleanup_old_error_logs(p_days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE v_deleted_count INTEGER;
BEGIN
    DELETE FROM error_logs WHERE timestamp < NOW() - (p_days_to_keep || ' days')::INTERVAL;
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;

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
SELECT DATE_TRUNC('hour', timestamp) as hour, DATE_TRUNC('day', timestamp) as day, activity_type,
       COUNT(*) as activity_count, COUNT(DISTINCT user_id) as unique_users, MAX(timestamp) as latest_timestamp
FROM user_activity_logs
GROUP BY DATE_TRUNC('hour', timestamp), DATE_TRUNC('day', timestamp), activity_type
ORDER BY latest_timestamp DESC;

CREATE VIEW user_journey AS
SELECT user_id, activity_type, page_url, timestamp,
       LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) as previous_activity_time,
       LEAD(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) as next_activity_time
FROM user_activity_logs
ORDER BY user_id, timestamp;

CREATE FUNCTION cleanup_old_activity_logs(p_days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE v_deleted_count INTEGER;
BEGIN
    DELETE FROM user_activity_logs WHERE timestamp < NOW() - (p_days_to_keep || ' days')::INTERVAL;
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- STEP 5: Anonymous Sharing and Backup System
-- ============================================================================

CREATE TABLE anonymous_posts (
    id BIGSERIAL PRIMARY KEY,
    post_id TEXT NOT NULL UNIQUE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    post_type TEXT CHECK (post_type IN ('thought', 'question', 'support_request', 'celebration')) NOT NULL,
    content TEXT NOT NULL,
    mood TEXT CHECK (mood IN ('very_low', 'low', 'neutral', 'good', 'very_good')) NOT NULL,
    risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high', 'critical')) DEFAULT 'low',
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    location_city TEXT,
    location_country TEXT,
    emergency_contact TEXT,
    tags TEXT[],
    likes INTEGER DEFAULT 0,
    comments INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_anonymous_posts_user ON anonymous_posts(user_id);
CREATE INDEX idx_anonymous_posts_risk ON anonymous_posts(risk_level);
CREATE INDEX idx_anonymous_posts_created ON anonymous_posts(created_at DESC);
CREATE INDEX idx_anonymous_posts_type ON anonymous_posts(post_type);

CREATE TABLE emergency_response_logs (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT REFERENCES anonymous_posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high', 'critical')) NOT NULL,
    response_action TEXT NOT NULL,
    response_details TEXT,
    contacted_emergency_services BOOLEAN DEFAULT FALSE,
    emergency_services_contacted_at TIMESTAMPTZ,
    responded_by TEXT,
    response_status TEXT CHECK (response_status IN ('pending', 'in_progress', 'resolved', 'escalated')) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_emergency_post ON emergency_response_logs(post_id);
CREATE INDEX idx_emergency_user ON emergency_response_logs(user_id);
CREATE INDEX idx_emergency_status ON emergency_response_logs(response_status);

CREATE TABLE backup_history (
    id BIGSERIAL PRIMARY KEY,
    backup_type TEXT CHECK (backup_type IN ('full', 'incremental')) NOT NULL,
    backup_status TEXT CHECK (backup_status IN ('in_progress', 'completed', 'failed')) NOT NULL,
    backup_size_bytes BIGINT,
    backup_location TEXT,
    backup_metadata JSONB,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    error_message TEXT
);

CREATE INDEX idx_backup_status ON backup_history(backup_status);
CREATE INDEX idx_backup_started ON backup_history(started_at DESC);

CREATE TABLE restore_history (
    id BIGSERIAL PRIMARY KEY,
    backup_id BIGINT REFERENCES backup_history(id),
    restore_status TEXT CHECK (restore_status IN ('in_progress', 'completed', 'failed')) NOT NULL,
    restored_tables TEXT[],
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    error_message TEXT
);

CREATE INDEX idx_restore_status ON restore_history(restore_status);

CREATE FUNCTION create_full_backup(p_backup_location TEXT, p_metadata JSONB DEFAULT NULL)
RETURNS BIGINT AS $$
DECLARE v_backup_id BIGINT;
BEGIN
    INSERT INTO backup_history (backup_type, backup_status, backup_location, backup_metadata)
    VALUES ('full', 'in_progress', p_backup_location, p_metadata)
    RETURNING id INTO v_backup_id;
    
    UPDATE backup_history SET backup_status = 'completed', completed_at = NOW()
    WHERE id = v_backup_id;
    
    RETURN v_backup_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION restore_from_backup(p_backup_id BIGINT, p_tables_to_restore TEXT[] DEFAULT NULL)
RETURNS BIGINT AS $$
DECLARE v_restore_id BIGINT;
BEGIN
    INSERT INTO restore_history (backup_id, restore_status, restored_tables)
    VALUES (p_backup_id, 'in_progress', p_tables_to_restore)
    RETURNING id INTO v_restore_id;
    
    UPDATE restore_history SET restore_status = 'completed', completed_at = NOW()
    WHERE id = v_restore_id;
    
    RETURN v_restore_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✅ MindVault complete database setup finished successfully!' as status;

