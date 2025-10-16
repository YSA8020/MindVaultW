-- Step-by-step setup PART 4 - Testing professional dashboard functions
-- Run each section one at a time and report which one fails

-- ============================================================================
-- STEP 11: Create Professional Dashboard Tables
-- ============================================================================
-- Run this section after Step 10 succeeds

CREATE TABLE IF NOT EXISTS client_professional_relationships (
    id BIGSERIAL PRIMARY KEY,
    client_id UUID NOT NULL,
    professional_id UUID NOT NULL,
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
    client_id UUID NOT NULL,
    professional_id UUID NOT NULL,
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

-- If Step 11 succeeds, continue to Step 12
-- If Step 11 fails, report the error

-- ============================================================================
-- STEP 12: Create get_professional_dashboard_stats Function
-- ============================================================================
-- Run this section after Step 11 succeeds

CREATE OR REPLACE FUNCTION get_professional_dashboard_stats(p_professional_id UUID)
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

-- If Step 12 succeeds, continue to Step 13
-- If Step 12 fails, report the error - THIS IS LIKELY WHERE THE PROBLEM IS!

-- ============================================================================
-- STEP 13: Create get_upcoming_sessions Function
-- ============================================================================
-- Run this section after Step 12 succeeds

CREATE OR REPLACE FUNCTION get_upcoming_sessions(p_professional_id UUID, p_limit INTEGER DEFAULT 10)
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

-- If Step 13 succeeds, continue to Step 14
-- If Step 13 fails, report the error

-- ============================================================================
-- STEP 14: Create get_professional_clients Function
-- ============================================================================
-- Run this section after Step 13 succeeds

CREATE OR REPLACE FUNCTION get_professional_clients(p_professional_id UUID, p_status TEXT DEFAULT 'active')
RETURNS TABLE (
    client_id UUID,
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

-- If Step 14 succeeds, ALL FUNCTIONS WORK!
-- If Step 14 fails, report the error - this is where the problem is!

-- ============================================================================
-- INSTRUCTIONS:
-- ============================================================================
-- 1. Run Step 11 first
-- 2. If successful, run Step 12
-- 3. If successful, run Step 13
-- 4. If successful, run Step 14
-- 5. Report which step fails (if any)
-- 6. If all steps succeed, we've found the issue!
-- ============================================================================
