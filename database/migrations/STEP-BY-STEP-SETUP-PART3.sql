-- Step-by-step setup PART 3 - Testing professional functions
-- Run each section one at a time and report which one fails

-- ============================================================================
-- STEP 7: Create Professional Tables
-- ============================================================================
-- Run this section after Step 6 succeeds

CREATE TABLE IF NOT EXISTS onboarding_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
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
    user_id UUID NOT NULL UNIQUE,
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
    user_id UUID NOT NULL,
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

-- If Step 7 succeeds, continue to Step 8
-- If Step 7 fails, report the error

-- ============================================================================
-- STEP 8: Create initialize_professional_onboarding Function
-- ============================================================================
-- Run this section after Step 7 succeeds

CREATE OR REPLACE FUNCTION initialize_professional_onboarding(p_user_id UUID)
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

-- If Step 8 succeeds, continue to Step 9
-- If Step 8 fails, report the error

-- ============================================================================
-- STEP 9: Create update_onboarding_progress Function
-- ============================================================================
-- Run this section after Step 8 succeeds

CREATE OR REPLACE FUNCTION update_onboarding_progress(
    p_user_id UUID,
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

-- If Step 9 succeeds, continue to Step 10
-- If Step 9 fails, report the error

-- ============================================================================
-- STEP 10: Create get_onboarding_status Function
-- ============================================================================
-- Run this section after Step 9 succeeds

CREATE OR REPLACE FUNCTION get_onboarding_status(p_user_id UUID)
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

-- If Step 10 succeeds, the issue is NOT in onboarding functions
-- If Step 10 fails, report the error - this is where the problem is!

-- ============================================================================
-- INSTRUCTIONS:
-- ============================================================================
-- 1. Run Step 7 first
-- 2. If successful, run Step 8
-- 3. If successful, run Step 9
-- 4. If successful, run Step 10
-- 5. Report which step fails (if any)
-- 6. If all steps succeed, we'll test the professional dashboard functions next
-- ============================================================================
