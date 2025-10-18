-- ============================================================================
-- MindVault FRESH START Database Setup
-- ============================================================================
-- ⚠️ WARNING: This will DELETE ALL existing data and start fresh!
-- Run this if you want a completely clean database setup
-- ============================================================================

-- ============================================================================
-- STEP 1: Drop Everything (in reverse dependency order)
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

-- ============================================================================
-- STEP 2: Create Core User Tables
-- ============================================================================

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

CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================================
-- STEP 3: Create Professional Profiles Table
-- ============================================================================

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

CREATE POLICY "Users can view own professional profile" ON professional_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own professional profile" ON professional_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own professional profile" ON professional_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- STEP 4: Create Onboarding Tables
-- ============================================================================

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

-- ============================================================================
-- STEP 5: Create Onboarding Functions
-- ============================================================================

CREATE FUNCTION initialize_professional_onboarding(
    p_professional_id UUID
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO onboarding_progress (professional_id, current_step, completed_steps)
    VALUES (p_professional_id, 1, ARRAY[]::INTEGER[])
    ON CONFLICT (professional_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION update_onboarding_progress(
    p_professional_id UUID,
    p_step INTEGER,
    p_completed BOOLEAN DEFAULT TRUE
)
RETURNS VOID AS $$
BEGIN
    UPDATE onboarding_progress
    SET current_step = p_step,
        completed_steps = CASE 
            WHEN p_completed THEN completed_steps || p_step
            ELSE completed_steps
        END,
        updated_at = NOW()
    WHERE professional_id = p_professional_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_onboarding_status(
    p_professional_id UUID
)
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
    SELECT 
        op.current_step,
        op.completed_steps,
        op.profile_completed,
        op.credentials_completed,
        op.availability_completed,
        op.preferences_completed
    FROM onboarding_progress op
    WHERE op.professional_id = p_professional_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✅ Fresh start setup completed successfully!' as status;

