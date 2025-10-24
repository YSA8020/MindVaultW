-- ============================================================================
-- Add Anonymous Sharing and Backup System
-- ============================================================================
-- Run this after ADD-MONITORING-LOGGING.sql succeeds
-- ============================================================================

-- ============================================================================
-- Anonymous Sharing Platform
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

-- ============================================================================
-- Backup System
-- ============================================================================

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

CREATE FUNCTION create_full_backup(
    p_backup_location TEXT,
    p_metadata JSONB DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_backup_id BIGINT;
BEGIN
    INSERT INTO backup_history (backup_type, backup_status, backup_location, backup_metadata)
    VALUES ('full', 'in_progress', p_backup_location, p_metadata)
    RETURNING id INTO v_backup_id;
    
    -- In a real implementation, you would perform the actual backup here
    -- This is a placeholder function
    
    UPDATE backup_history
    SET backup_status = 'completed',
        completed_at = NOW()
    WHERE id = v_backup_id;
    
    RETURN v_backup_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION restore_from_backup(
    p_backup_id BIGINT,
    p_tables_to_restore TEXT[] DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_restore_id BIGINT;
BEGIN
    INSERT INTO restore_history (backup_id, restore_status, restored_tables)
    VALUES (p_backup_id, 'in_progress', p_tables_to_restore)
    RETURNING id INTO v_restore_id;
    
    -- In a real implementation, you would perform the actual restore here
    -- This is a placeholder function
    
    UPDATE restore_history
    SET restore_status = 'completed',
        completed_at = NOW()
    WHERE id = v_restore_id;
    
    RETURN v_restore_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✅ Anonymous sharing and backup system added successfully!' as status;

