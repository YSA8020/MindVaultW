-- ============================================================================
-- Test script to isolate the professional_id error
-- ============================================================================

-- Step 1: Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    user_type TEXT NOT NULL CHECK (user_type IN ('user', 'professional', 'admin')) DEFAULT 'user',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Step 2: Create professional_profiles table
CREATE TABLE IF NOT EXISTS professional_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    license_type TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Step 3: Create onboarding_progress table
CREATE TABLE IF NOT EXISTS onboarding_progress (
    professional_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_step INTEGER DEFAULT 1,
    completed_steps INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 4: Create index on onboarding_progress
CREATE INDEX IF NOT EXISTS idx_onboarding_progress_professional ON onboarding_progress(professional_id);

-- Step 5: Test function that uses professional_id
CREATE OR REPLACE FUNCTION test_professional_id(
    p_professional_id UUID
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO onboarding_progress (professional_id, current_step, completed_steps)
    VALUES (p_professional_id, 1, ARRAY[]::INTEGER[])
    ON CONFLICT (professional_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- If all steps succeed, the issue is elsewhere
-- If any step fails, that's where the problem is!

