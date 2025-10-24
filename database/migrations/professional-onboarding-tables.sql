-- Professional Onboarding Tables
-- Track onboarding progress and provide guided setup

CREATE TABLE IF NOT EXISTS onboarding_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    
    -- Onboarding stages
    stage_completed TEXT CHECK (stage_completed IN ('welcome', 'profile', 'credentials', 'availability', 'preferences', 'completed')),
    current_stage TEXT CHECK (current_stage IN ('welcome', 'profile', 'credentials', 'availability', 'preferences', 'completed')),
    
    -- Progress tracking
    welcome_completed BOOLEAN DEFAULT FALSE,
    profile_completed BOOLEAN DEFAULT FALSE,
    credentials_completed BOOLEAN DEFAULT FALSE,
    availability_completed BOOLEAN DEFAULT FALSE,
    preferences_completed BOOLEAN DEFAULT FALSE,
    
    -- Completion tracking
    completion_percentage INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    
    -- Metadata
    last_accessed TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_time_minutes INTEGER DEFAULT 0,
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Professional profile details (extended)
CREATE TABLE IF NOT EXISTS professional_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    
    -- Professional information
    license_type TEXT,
    license_number TEXT,
    license_state TEXT,
    license_expiry DATE,
    years_experience INTEGER,
    
    -- Specializations
    specializations TEXT[], -- Array of specialization tags
    treatment_approaches TEXT[], -- CBT, DBT, etc.
    client_populations TEXT[], -- Adults, Teens, Couples, etc.
    
    -- Professional bio
    bio TEXT,
    education TEXT,
    certifications TEXT[],
    languages TEXT[],
    
    -- Practice details
    practice_name TEXT,
    practice_address TEXT,
    practice_phone TEXT,
    practice_website TEXT,
    
    -- Session preferences
    session_duration_minutes INTEGER DEFAULT 60,
    session_type TEXT CHECK (session_type IN ('individual', 'group', 'couples', 'family')),
    session_format TEXT CHECK (session_format IN ('in-person', 'video', 'phone', 'hybrid')),
    
    -- Availability
    timezone TEXT DEFAULT 'America/New_York',
    working_hours JSONB, -- { "monday": { "start": "09:00", "end": "17:00" }, ... }
    
    -- Rates and billing
    hourly_rate DECIMAL(10, 2),
    accepts_insurance BOOLEAN DEFAULT FALSE,
    insurance_providers TEXT[],
    sliding_scale BOOLEAN DEFAULT FALSE,
    sliding_scale_details TEXT,
    
    -- Profile visibility
    profile_visible BOOLEAN DEFAULT FALSE,
    profile_completed BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Onboarding checkpoints
CREATE TABLE IF NOT EXISTS onboarding_checkpoints (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    
    checkpoint_name TEXT NOT NULL,
    checkpoint_type TEXT CHECK (checkpoint_type IN ('info', 'action', 'verification', 'test')),
    stage TEXT NOT NULL,
    
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    
    -- Checkpoint data
    data JSONB,
    
    -- Ordering
    order_index INTEGER NOT NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Onboarding resources and tips
CREATE TABLE IF NOT EXISTS onboarding_resources (
    id BIGSERIAL PRIMARY KEY,
    
    stage TEXT NOT NULL,
    resource_type TEXT CHECK (resource_type IN ('video', 'article', 'guide', 'tip', 'faq')),
    
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    url TEXT,
    
    -- Display settings
    order_index INTEGER DEFAULT 0,
    required BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_onboarding_progress_user_id ON onboarding_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_onboarding_progress_stage ON onboarding_progress(current_stage);
CREATE INDEX IF NOT EXISTS idx_professional_profiles_user_id ON professional_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_professional_profiles_visible ON professional_profiles(profile_visible);
CREATE INDEX IF NOT EXISTS idx_onboarding_checkpoints_user_id ON onboarding_checkpoints(user_id);
CREATE INDEX IF NOT EXISTS idx_onboarding_checkpoints_stage ON onboarding_checkpoints(stage);
CREATE INDEX IF NOT EXISTS idx_onboarding_resources_stage ON onboarding_resources(stage);

-- Enable Row Level Security
ALTER TABLE onboarding_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_checkpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_resources ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own onboarding progress" ON onboarding_progress
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can update own onboarding progress" ON onboarding_progress
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own onboarding progress" ON onboarding_progress
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can view own professional profile" ON professional_profiles
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can update own professional profile" ON professional_profiles
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own professional profile" ON professional_profiles
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can view own onboarding checkpoints" ON onboarding_checkpoints
    FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Public can view onboarding resources" ON onboarding_resources
    FOR SELECT USING (true);

-- Function to initialize onboarding for a professional
CREATE OR REPLACE FUNCTION initialize_professional_onboarding(p_user_id TEXT)
RETURNS VOID AS $$
BEGIN
    -- Insert onboarding progress
    INSERT INTO onboarding_progress (user_id, current_stage, stage_completed)
    VALUES (p_user_id, 'welcome', NULL)
    ON CONFLICT (user_id) DO UPDATE
    SET last_accessed = NOW();
    
    -- Create professional profile placeholder
    INSERT INTO professional_profiles (user_id, profile_visible, profile_completed)
    VALUES (p_user_id, FALSE, FALSE)
    ON CONFLICT (user_id) DO NOTHING;
    
    -- Create default checkpoints
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

-- Function to update onboarding progress
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
    -- Update progress
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
    
    -- Calculate completion percentage
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
    
    -- Update completion percentage
    UPDATE onboarding_progress
    SET completion_percentage = v_completion
    WHERE user_id = p_user_id;
    
    -- Mark as completed
    IF v_completion = 100 THEN
        UPDATE onboarding_progress
        SET completed_at = NOW()
        WHERE user_id = p_user_id;
        
        -- Mark profile as visible
        UPDATE professional_profiles
        SET profile_visible = TRUE, profile_completed = TRUE
        WHERE user_id = p_user_id;
    END IF;
    
    RETURN QUERY SELECT v_completion, v_next_stage;
END;
$$ LANGUAGE plpgsql;

-- Function to get onboarding status
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
    ('preferences', 'faq', 'Common Questions', 'Frequently asked questions', 'Q: How do I get matched with clients? A: Clients will be matched based on...', 2, FALSE);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON onboarding_progress TO anon, authenticated;
GRANT ALL ON professional_profiles TO anon, authenticated;
GRANT ALL ON onboarding_checkpoints TO anon, authenticated;
GRANT ALL ON onboarding_resources TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON FUNCTION initialize_professional_onboarding TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_onboarding_progress TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_onboarding_status TO anon, authenticated;
