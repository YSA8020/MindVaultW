-- ============================================================================
-- Add Professional Dashboard Tables and Functions
-- ============================================================================
-- Run this after ADD-SECURITY-TABLES.sql succeeds
-- ============================================================================

-- ============================================================================
-- Professional Dashboard Tables
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

-- ============================================================================
-- Professional Dashboard Functions
-- ============================================================================

CREATE FUNCTION get_professional_dashboard_stats(
    p_professional_id UUID
)
RETURNS TABLE (
    total_clients BIGINT,
    active_clients BIGINT,
    upcoming_sessions BIGINT,
    completed_sessions_today BIGINT,
    revenue_today DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT cpr.client_id)::BIGINT as total_clients,
        COUNT(DISTINCT CASE WHEN cpr.relationship_status = 'active' THEN cpr.client_id END)::BIGINT as active_clients,
        COUNT(DISTINCT CASE WHEN s.status = 'scheduled' AND s.scheduled_at > NOW() THEN s.id END)::BIGINT as upcoming_sessions,
        COUNT(DISTINCT CASE WHEN s.status = 'completed' AND DATE(s.scheduled_at) = CURRENT_DATE THEN s.id END)::BIGINT as completed_sessions_today,
        COALESCE(SUM(CASE WHEN s.status = 'completed' AND DATE(s.scheduled_at) = CURRENT_DATE THEN (s.duration_minutes::DECIMAL / 60) * 100 ELSE 0 END), 0) as revenue_today
    FROM client_professional_relationships cpr
    LEFT JOIN sessions s ON s.professional_id = p_professional_id
    WHERE cpr.professional_id = p_professional_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_upcoming_sessions(
    p_professional_id UUID,
    p_days_ahead INTEGER DEFAULT 7
)
RETURNS TABLE (
    session_id BIGINT,
    client_id UUID,
    client_name TEXT,
    session_type TEXT,
    session_format TEXT,
    scheduled_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.client_id,
        u.first_name || ' ' || u.last_name as client_name,
        s.session_type,
        s.session_format,
        s.scheduled_at,
        s.duration_minutes,
        s.status
    FROM sessions s
    JOIN users u ON u.id = s.client_id
    WHERE s.professional_id = p_professional_id
    AND s.scheduled_at BETWEEN NOW() AND NOW() + (p_days_ahead || ' days')::INTERVAL
    ORDER BY s.scheduled_at ASC;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION get_professional_clients(
    p_professional_id UUID
)
RETURNS TABLE (
    client_id UUID,
    client_name TEXT,
    relationship_status TEXT,
    last_session_date TIMESTAMPTZ,
    total_sessions BIGINT,
    match_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cpr.client_id,
        u.first_name || ' ' || u.last_name as client_name,
        cpr.relationship_status,
        MAX(s.scheduled_at) as last_session_date,
        COUNT(s.id)::BIGINT as total_sessions,
        cpr.match_score
    FROM client_professional_relationships cpr
    JOIN users u ON u.id = cpr.client_id
    LEFT JOIN sessions s ON s.client_id = cpr.client_id AND s.professional_id = p_professional_id
    WHERE cpr.professional_id = p_professional_id
    GROUP BY cpr.client_id, u.first_name, u.last_name, cpr.relationship_status, cpr.match_score
    ORDER BY cpr.relationship_status, u.first_name;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✅ Professional dashboard tables and functions added successfully!' as status;

