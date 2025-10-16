-- Anonymous Posts Table for Safe Sharing
-- Users can share thoughts anonymously while admins can access for emergency response

CREATE TABLE IF NOT EXISTS anonymous_posts (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL, -- Hidden from other users, only visible to admins
    post_content TEXT NOT NULL,
    post_type TEXT NOT NULL CHECK (post_type IN ('thought', 'question', 'support_request', 'crisis')),
    mood_level INTEGER CHECK (mood_level >= 1 AND mood_level <= 10),
    risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    
    -- Geolocation (for emergency response)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location_address TEXT,
    location_city TEXT,
    location_state TEXT,
    location_country TEXT,
    
    -- Emergency contact information (encrypted)
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    emergency_contact_relationship TEXT,
    
    -- Anonymous display
    anonymous_username TEXT, -- User-generated anonymous name (e.g., "HopefulSoul123")
    display_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Engagement metrics
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    
    -- Status
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'flagged', 'removed', 'emergency_response')),
    flagged_by TEXT, -- Admin who flagged
    flagged_reason TEXT,
    flagged_at TIMESTAMPTZ,
    
    -- Emergency response tracking
    emergency_response_initiated BOOLEAN DEFAULT FALSE,
    emergency_response_time TIMESTAMPTZ,
    emergency_responder_id TEXT,
    emergency_response_status TEXT CHECK (emergency_response_status IN ('pending', 'contacted', 'in_progress', 'resolved')),
    emergency_response_notes TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Foreign key to users table (for admin access only)
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Comments on anonymous posts
CREATE TABLE IF NOT EXISTS anonymous_post_comments (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id TEXT NOT NULL, -- Hidden from other users
    comment_content TEXT NOT NULL,
    anonymous_username TEXT,
    risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    likes_count INTEGER DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'flagged', 'removed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (post_id) REFERENCES anonymous_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Likes on anonymous posts
CREATE TABLE IF NOT EXISTS anonymous_post_likes (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES anonymous_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Emergency response log
CREATE TABLE IF NOT EXISTS emergency_response_log (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id TEXT NOT NULL,
    risk_level TEXT NOT NULL CHECK (risk_level IN ('medium', 'high', 'critical')),
    
    -- Location information
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location_address TEXT,
    
    -- Emergency contact
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    
    -- Response details
    response_initiated_by TEXT NOT NULL, -- Admin user ID
    response_initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    response_method TEXT CHECK (response_method IN ('phone', 'text', 'email', 'in_person', 'emergency_services')),
    response_status TEXT NOT NULL DEFAULT 'initiated' CHECK (response_status IN ('initiated', 'contacted', 'in_progress', 'resolved', 'escalated')),
    
    -- Response notes
    responder_notes TEXT,
    outcome TEXT,
    
    -- Follow-up
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_scheduled_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (post_id) REFERENCES anonymous_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- User risk assessment
CREATE TABLE IF NOT EXISTS user_risk_assessment (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    
    -- Current risk level
    current_risk_level TEXT NOT NULL CHECK (current_risk_level IN ('low', 'medium', 'high', 'critical')),
    
    -- Risk factors
    recent_crisis_posts INTEGER DEFAULT 0,
    mood_trend TEXT CHECK (mood_trend IN ('improving', 'stable', 'declining', 'critical')),
    engagement_level TEXT CHECK (engagement_level IN ('active', 'moderate', 'low', 'none')),
    
    -- Location tracking
    last_known_location TEXT,
    last_known_latitude DECIMAL(10, 8),
    last_known_longitude DECIMAL(11, 8),
    last_location_update TIMESTAMPTZ,
    
    -- Emergency contacts
    primary_emergency_contact_name TEXT,
    primary_emergency_contact_phone TEXT,
    primary_emergency_contact_relationship TEXT,
    secondary_emergency_contact_name TEXT,
    secondary_emergency_contact_phone TEXT,
    secondary_emergency_contact_relationship TEXT,
    
    -- Monitoring settings
    geolocation_enabled BOOLEAN DEFAULT FALSE,
    emergency_alert_enabled BOOLEAN DEFAULT TRUE,
    risk_alert_threshold TEXT CHECK (risk_alert_threshold IN ('medium', 'high', 'critical')),
    
    -- Last assessment
    last_assessment_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    next_assessment_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_anonymous_posts_user_id ON anonymous_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_anonymous_posts_risk_level ON anonymous_posts(risk_level);
CREATE INDEX IF NOT EXISTS idx_anonymous_posts_status ON anonymous_posts(status);
CREATE INDEX IF NOT EXISTS idx_anonymous_posts_emergency_response ON anonymous_posts(emergency_response_initiated);
CREATE INDEX IF NOT EXISTS idx_anonymous_posts_created_at ON anonymous_posts(created_at);
CREATE INDEX IF NOT EXISTS idx_anonymous_posts_post_type ON anonymous_posts(post_type);

CREATE INDEX IF NOT EXISTS idx_anonymous_post_comments_post_id ON anonymous_post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_anonymous_post_comments_user_id ON anonymous_post_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_anonymous_post_likes_post_id ON anonymous_post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_anonymous_post_likes_user_id ON anonymous_post_likes(user_id);

CREATE INDEX IF NOT EXISTS idx_emergency_response_log_user_id ON emergency_response_log(user_id);
CREATE INDEX IF NOT EXISTS idx_emergency_response_log_risk_level ON emergency_response_log(risk_level);
CREATE INDEX IF NOT EXISTS idx_emergency_response_log_status ON emergency_response_log(response_status);
CREATE INDEX IF NOT EXISTS idx_emergency_response_log_initiated_at ON emergency_response_log(response_initiated_at);

CREATE INDEX IF NOT EXISTS idx_user_risk_assessment_user_id ON user_risk_assessment(user_id);
CREATE INDEX IF NOT EXISTS idx_user_risk_assessment_risk_level ON user_risk_assessment(current_risk_level);

-- Enable Row Level Security
ALTER TABLE anonymous_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE anonymous_post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE anonymous_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_response_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_risk_assessment ENABLE ROW LEVEL SECURITY;

-- RLS Policies for anonymous_posts
-- Users can only see anonymous versions (no user_id)
CREATE POLICY "Users can view anonymous posts" ON anonymous_posts
    FOR SELECT USING (true);

-- Users can create posts (user_id is set by backend)
CREATE POLICY "Users can create anonymous posts" ON anonymous_posts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Users can update their own posts (via anonymous_username)
CREATE POLICY "Users can update own posts" ON anonymous_posts
    FOR UPDATE USING (auth.uid()::text = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete own posts" ON anonymous_posts
    FOR DELETE USING (auth.uid()::text = user_id);

-- Admins can see all data including user_id
CREATE POLICY "Admins can view all post data" ON anonymous_posts
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

-- RLS Policies for comments
CREATE POLICY "Users can view anonymous comments" ON anonymous_post_comments
    FOR SELECT USING (true);

CREATE POLICY "Users can create comments" ON anonymous_post_comments
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own comments" ON anonymous_post_comments
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Users can delete own comments" ON anonymous_post_comments
    FOR DELETE USING (auth.uid()::text = user_id);

-- RLS Policies for likes
CREATE POLICY "Users can view likes" ON anonymous_post_likes
    FOR SELECT USING (true);

CREATE POLICY "Users can create likes" ON anonymous_post_likes
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can delete own likes" ON anonymous_post_likes
    FOR DELETE USING (auth.uid()::text = user_id);

-- RLS Policies for emergency response log (admin only)
CREATE POLICY "Admins can view emergency logs" ON emergency_response_log
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

-- RLS Policies for user risk assessment
CREATE POLICY "Users can view own risk assessment" ON user_risk_assessment
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can update own risk assessment" ON user_risk_assessment
    FOR UPDATE USING (auth.uid()::text = user_id);

CREATE POLICY "Admins can view all risk assessments" ON user_risk_assessment
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::text 
            AND users.user_type = 'admin'
        )
    );

-- Function to automatically assess risk level
CREATE OR REPLACE FUNCTION assess_post_risk_level()
RETURNS TRIGGER AS $$
BEGIN
    -- Assess risk based on content and mood
    IF NEW.mood_level <= 3 THEN
        NEW.risk_level := 'high';
    ELSIF NEW.mood_level <= 5 THEN
        NEW.risk_level := 'medium';
    ELSE
        NEW.risk_level := 'low';
    END IF;
    
    -- Override for crisis posts
    IF NEW.post_type = 'crisis' THEN
        NEW.risk_level := 'critical';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically assess risk
CREATE TRIGGER assess_risk_on_post_insert
    BEFORE INSERT ON anonymous_posts
    FOR EACH ROW
    EXECUTE FUNCTION assess_post_risk_level();

-- Function to update user risk assessment
CREATE OR REPLACE FUNCTION update_user_risk_assessment(p_user_id TEXT)
RETURNS VOID AS $$
DECLARE
    v_risk_level TEXT;
    v_crisis_count INTEGER;
    v_recent_posts INTEGER;
BEGIN
    -- Count recent crisis posts
    SELECT COUNT(*) INTO v_crisis_count
    FROM anonymous_posts
    WHERE user_id = p_user_id
    AND post_type = 'crisis'
    AND created_at > NOW() - INTERVAL '7 days';
    
    -- Count recent posts
    SELECT COUNT(*) INTO v_recent_posts
    FROM anonymous_posts
    WHERE user_id = p_user_id
    AND created_at > NOW() - INTERVAL '7 days';
    
    -- Determine risk level
    IF v_crisis_count >= 3 THEN
        v_risk_level := 'critical';
    ELSIF v_crisis_count >= 1 OR v_recent_posts >= 10 THEN
        v_risk_level := 'high';
    ELSIF v_recent_posts >= 5 THEN
        v_risk_level := 'medium';
    ELSE
        v_risk_level := 'low';
    END IF;
    
    -- Update or insert risk assessment
    INSERT INTO user_risk_assessment (user_id, current_risk_level, recent_crisis_posts, last_assessment_at)
    VALUES (p_user_id, v_risk_level, v_crisis_count, NOW())
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        current_risk_level = v_risk_level,
        recent_crisis_posts = v_crisis_count,
        last_assessment_at = NOW(),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Trigger to update risk assessment after post creation
CREATE TRIGGER update_risk_after_post
    AFTER INSERT ON anonymous_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_user_risk_assessment(NEW.user_id);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON anonymous_posts TO anon, authenticated;
GRANT ALL ON anonymous_post_comments TO anon, authenticated;
GRANT ALL ON anonymous_post_likes TO anon, authenticated;
GRANT ALL ON emergency_response_log TO authenticated;
GRANT ALL ON user_risk_assessment TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_user_risk_assessment TO anon, authenticated;
