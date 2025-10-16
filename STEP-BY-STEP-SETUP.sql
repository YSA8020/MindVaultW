-- Step-by-step setup to identify which function causes the UUID error
-- Run each section one at a time and report which one fails

-- ============================================================================
-- STEP 1: Cleanup
-- ============================================================================
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT 'DROP FUNCTION IF EXISTS ' || n.nspname || '.' || p.proname || 
                     '(' || pg_get_function_arguments(p.oid) || ') CASCADE' as drop_cmd
              FROM pg_proc p
              JOIN pg_namespace n ON p.pronamespace = n.oid
              WHERE n.nspname = 'public')
    LOOP
        BEGIN
            EXECUTE r.drop_cmd;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Could not drop function: %', r.drop_cmd;
        END;
    END LOOP;
END $$;

DROP VIEW IF EXISTS error_stats CASCADE;
DROP VIEW IF EXISTS user_activity_stats CASCADE;
DROP VIEW IF EXISTS user_journey CASCADE;

-- If Step 1 succeeds, continue to Step 2
-- If Step 1 fails, report the error

-- ============================================================================
-- STEP 2: Create Core Tables
-- ============================================================================
-- Run this section after Step 1 succeeds

CREATE TABLE IF NOT EXISTS users (
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

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_verification_status ON users(verification_status);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- If Step 2 succeeds, continue to Step 3
-- If Step 2 fails, report the error

-- ============================================================================
-- STEP 3: Create Security Functions
-- ============================================================================
-- Run this section after Step 2 succeeds

-- Rate limiting function
CREATE OR REPLACE FUNCTION check_rate_limit(
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

-- If Step 3 succeeds, the issue is NOT in check_rate_limit
-- If Step 3 fails, report the error - this is where the problem is!

-- ============================================================================
-- INSTRUCTIONS:
-- ============================================================================
-- 1. Run Step 1 first
-- 2. If successful, run Step 2
-- 3. If successful, run Step 3
-- 4. Report which step fails (if any)
-- 5. If all steps succeed, we'll continue with the remaining functions
-- ============================================================================
