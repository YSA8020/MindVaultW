-- Professional Dashboard Tables
-- Client management, sessions, and practice analytics

-- Client relationships
CREATE TABLE IF NOT EXISTS client_professional_relationships (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    
    -- Relationship details
    relationship_status TEXT CHECK (relationship_status IN ('pending', 'active', 'paused', 'ended')) DEFAULT 'pending',
    match_score DECIMAL(5, 2), -- 0-100 compatibility score
    
    -- Match criteria
    matched_on DATE NOT NULL DEFAULT CURRENT_DATE,
    matched_by TEXT CHECK (matched_by IN ('platform', 'manual', 'referral')),
    
    -- Session tracking
    total_sessions INTEGER DEFAULT 0,
    sessions_this_month INTEGER DEFAULT 0,
    last_session_date DATE,
    
    -- Progress tracking
    initial_assessment_completed BOOLEAN DEFAULT FALSE,
    treatment_plan_created BOOLEAN DEFAULT FALSE,
    goals_set BOOLEAN DEFAULT FALSE,
    
    -- Notes
    professional_notes TEXT,
    client_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    UNIQUE(client_id, professional_id)
);

-- Session management
CREATE TABLE IF NOT EXISTS sessions (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    
    -- Session details
    session_date DATE NOT NULL,
    session_time TIME NOT NULL,
    session_duration_minutes INTEGER DEFAULT 60,
    session_type TEXT CHECK (session_type IN ('individual', 'group', 'couples', 'family')),
    session_format TEXT CHECK (session_format IN ('in-person', 'video', 'phone')),
    session_status TEXT CHECK (session_status IN ('scheduled', 'completed', 'cancelled', 'no-show', 'rescheduled')) DEFAULT 'scheduled',
    
    -- Location/Platform
    location TEXT,
    video_link TEXT,
    phone_number TEXT,
    
    -- Session content
    session_notes TEXT,
    treatment_goals_discussed TEXT[],
    interventions_used TEXT[],
    homework_assigned TEXT,
    
    -- Progress tracking
    client_mood_before INTEGER CHECK (client_mood_before BETWEEN 1 AND 10),
    client_mood_after INTEGER CHECK (client_mood_after BETWEEN 1 AND 10),
    progress_rating INTEGER CHECK (progress_rating BETWEEN 1 AND 10),
    
    -- Billing
    session_fee DECIMAL(10, 2),
    payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'insurance', 'waived')) DEFAULT 'pending',
    insurance_claim_id TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Treatment plans
CREATE TABLE IF NOT EXISTS treatment_plans (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    
    -- Plan details
    plan_name TEXT NOT NULL,
    plan_description TEXT,
    diagnosis TEXT,
    presenting_problems TEXT[],
    
    -- Goals
    primary_goals TEXT[],
    secondary_goals TEXT[],
    measurable_objectives TEXT[],
    
    -- Treatment approach
    treatment_approach TEXT,
    interventions_planned TEXT[],
    estimated_duration_weeks INTEGER,
    
    -- Progress
    start_date DATE NOT NULL,
    end_date DATE,
    status TEXT CHECK (status IN ('active', 'completed', 'on-hold', 'terminated')) DEFAULT 'active',
    
    -- Outcomes
    outcome_measures TEXT[],
    progress_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Client assessments
CREATE TABLE IF NOT EXISTS client_assessments (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    
    -- Assessment details
    assessment_type TEXT NOT NULL CHECK (assessment_type IN ('initial', 'progress', 'outcome', 'custom')),
    assessment_name TEXT NOT NULL,
    assessment_date DATE NOT NULL,
    
    -- Results
    scores JSONB, -- Flexible JSON structure for different assessment types
    results_summary TEXT,
    
    -- Recommendations
    recommendations TEXT,
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Client notes (HIPAA compliant)
CREATE TABLE IF NOT EXISTS client_notes (
    id BIGSERIAL PRIMARY KEY,
    client_id TEXT NOT NULL,
    professional_id TEXT NOT NULL,
    session_id BIGINT,
    
    -- Note details
    note_type TEXT CHECK (note_type IN ('session', 'phone', 'email', 'general', 'emergency')) DEFAULT 'general',
    note_date DATE NOT NULL,
    note_time TIME NOT NULL,
    
    -- Content
    subjective TEXT,
    objective TEXT,
    assessment TEXT,
    plan TEXT,
    
    -- Privacy
    confidential BOOLEAN DEFAULT TRUE,
    shared_with_client BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL
);

-- Professional availability
CREATE TABLE IF NOT EXISTS professional_availability (
    id BIGSERIAL PRIMARY KEY,
    professional_id TEXT NOT NULL UNIQUE,
    
    -- General availability
    available_for_new_clients BOOLEAN DEFAULT TRUE,
    max_clients INTEGER DEFAULT 20,
    current_client_count INTEGER DEFAULT 0,
    
    -- Scheduling preferences
    advance_booking_days INTEGER DEFAULT 30,
    cancellation_policy_hours INTEGER DEFAULT 24,
    reschedule_policy_hours INTEGER DEFAULT 48,
    
    -- Time slots
    available_slots JSONB, -- { "monday": ["09:00", "10:00", "14:00"], ... }
    
    -- Time off
    vacation_dates DATE[],
    blackout_dates DATE[],
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Professional analytics
CREATE TABLE IF NOT EXISTS professional_analytics (
    id BIGSERIAL PRIMARY KEY,
    professional_id TEXT NOT NULL,
    analytics_date DATE NOT NULL,
    
    -- Client metrics
    total_clients INTEGER DEFAULT 0,
    active_clients INTEGER DEFAULT 0,
    new_clients INTEGER DEFAULT 0,
    
    -- Session metrics
    total_sessions INTEGER DEFAULT 0,
    completed_sessions INTEGER DEFAULT 0,
    cancelled_sessions INTEGER DEFAULT 0,
    no_shows INTEGER DEFAULT 0,
    
    -- Revenue metrics
    total_revenue DECIMAL(10, 2) DEFAULT 0,
    insurance_revenue DECIMAL(10, 2) DEFAULT 0,
    cash_revenue DECIMAL(10, 2) DEFAULT 0,
    
    -- Engagement metrics
    average_session_duration_minutes INTEGER,
    client_satisfaction_score DECIMAL(3, 2),
    treatment_completion_rate DECIMAL(5, 2),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (professional_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    UNIQUE(professional_id, analytics_date)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_client_professional_relationships_client_id ON client_professional_relationships(client_id);
CREATE INDEX IF NOT EXISTS idx_client_professional_relationships_professional_id ON client_professional_relationships(professional_id);
CREATE INDEX IF NOT EXISTS idx_client_professional_relationships_status ON client_professional_relationships(relationship_status);

CREATE INDEX IF NOT EXISTS idx_sessions_client_id ON sessions(client_id);
CREATE INDEX IF NOT EXISTS idx_sessions_professional_id ON sessions(professional_id);
CREATE INDEX IF NOT EXISTS idx_sessions_session_date ON sessions(session_date);
CREATE INDEX IF NOT EXISTS idx_sessions_session_status ON sessions(session_status);

CREATE INDEX IF NOT EXISTS idx_treatment_plans_client_id ON treatment_plans(client_id);
CREATE INDEX IF NOT EXISTS idx_treatment_plans_professional_id ON treatment_plans(professional_id);
CREATE INDEX IF NOT EXISTS idx_treatment_plans_status ON treatment_plans(status);

CREATE INDEX IF NOT EXISTS idx_client_assessments_client_id ON client_assessments(client_id);
CREATE INDEX IF NOT EXISTS idx_client_assessments_professional_id ON client_assessments(professional_id);
CREATE INDEX IF NOT EXISTS idx_client_assessments_assessment_date ON client_assessments(assessment_date);

CREATE INDEX IF NOT EXISTS idx_client_notes_client_id ON client_notes(client_id);
CREATE INDEX IF NOT EXISTS idx_client_notes_professional_id ON client_notes(professional_id);
CREATE INDEX IF NOT EXISTS idx_client_notes_note_date ON client_notes(note_date);

CREATE INDEX IF NOT EXISTS idx_professional_availability_professional_id ON professional_availability(professional_id);

CREATE INDEX IF NOT EXISTS idx_professional_analytics_professional_id ON professional_analytics(professional_id);
CREATE INDEX IF NOT EXISTS idx_professional_analytics_analytics_date ON professional_analytics(analytics_date);

-- Enable Row Level Security
ALTER TABLE client_professional_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatment_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_analytics ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Professionals can view own client relationships" ON client_professional_relationships
    FOR SELECT USING (auth.uid()::text = professional_id);

CREATE POLICY "Professionals can manage own client relationships" ON client_professional_relationships
    FOR ALL USING (auth.uid()::text = professional_id);

CREATE POLICY "Clients can view own relationships" ON client_professional_relationships
    FOR SELECT USING (auth.uid()::text = client_id);

CREATE POLICY "Professionals can view own sessions" ON sessions
    FOR ALL USING (auth.uid()::text = professional_id);

CREATE POLICY "Clients can view own sessions" ON sessions
    FOR SELECT USING (auth.uid()::text = client_id);

CREATE POLICY "Professionals can view own treatment plans" ON treatment_plans
    FOR ALL USING (auth.uid()::text = professional_id);

CREATE POLICY "Clients can view own treatment plans" ON treatment_plans
    FOR SELECT USING (auth.uid()::text = client_id);

CREATE POLICY "Professionals can view own assessments" ON client_assessments
    FOR ALL USING (auth.uid()::text = professional_id);

CREATE POLICY "Clients can view own assessments" ON client_assessments
    FOR SELECT USING (auth.uid()::text = client_id);

CREATE POLICY "Professionals can view own notes" ON client_notes
    FOR ALL USING (auth.uid()::text = professional_id);

CREATE POLICY "Professionals can manage own availability" ON professional_availability
    FOR ALL USING (auth.uid()::text = professional_id);

CREATE POLICY "Professionals can view own analytics" ON professional_analytics
    FOR ALL USING (auth.uid()::text = professional_id);

-- Functions for professional dashboard

-- Function to get professional dashboard stats
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
        (SELECT COUNT(*) FROM client_professional_relationships WHERE professional_id = p_professional_id)::INTEGER as total_clients,
        (SELECT COUNT(*) FROM client_professional_relationships WHERE professional_id = p_professional_id AND relationship_status = 'active')::INTEGER as active_clients,
        (SELECT COUNT(*) FROM client_professional_relationships WHERE professional_id = p_professional_id AND relationship_status = 'pending')::INTEGER as pending_clients,
        (SELECT COUNT(*) FROM sessions WHERE professional_id = p_professional_id AND session_date = CURRENT_DATE)::INTEGER as sessions_today,
        (SELECT COUNT(*) FROM sessions WHERE professional_id = p_professional_id AND session_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days')::INTEGER as sessions_this_week,
        (SELECT COUNT(*) FROM sessions WHERE professional_id = p_professional_id AND session_status = 'scheduled' AND session_date >= CURRENT_DATE)::INTEGER as upcoming_sessions,
        (SELECT COALESCE(SUM(session_fee), 0) FROM sessions WHERE professional_id = p_professional_id AND payment_status = 'paid')::DECIMAL as total_revenue,
        (SELECT COALESCE(SUM(session_fee), 0) FROM sessions WHERE professional_id = p_professional_id AND payment_status = 'paid' AND session_date >= DATE_TRUNC('month', CURRENT_DATE))::DECIMAL as monthly_revenue,
        (SELECT CASE 
            WHEN COUNT(*) > 0 THEN (COUNT(*) FILTER (WHERE session_status = 'completed')::DECIMAL / COUNT(*)::DECIMAL * 100)
            ELSE 0
        END FROM sessions WHERE professional_id = p_professional_id)::DECIMAL as completion_rate;
END;
$$ LANGUAGE plpgsql;

-- Function to get upcoming sessions
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

-- Function to get client list for professional
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

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON client_professional_relationships TO anon, authenticated;
GRANT ALL ON sessions TO anon, authenticated;
GRANT ALL ON treatment_plans TO anon, authenticated;
GRANT ALL ON client_assessments TO anon, authenticated;
GRANT ALL ON client_notes TO anon, authenticated;
GRANT ALL ON professional_availability TO anon, authenticated;
GRANT ALL ON professional_analytics TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_professional_dashboard_stats TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_upcoming_sessions TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_professional_clients TO anon, authenticated;
