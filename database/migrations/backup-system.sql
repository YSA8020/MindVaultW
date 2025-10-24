-- MindVault Backup and Recovery System
-- Comprehensive database backup and recovery procedures

-- =====================================================
-- BACKUP FUNCTIONS
-- =====================================================

-- Function to create a full database backup
CREATE OR REPLACE FUNCTION create_full_backup()
RETURNS TEXT AS $$
DECLARE
    backup_id TEXT;
    backup_timestamp TIMESTAMPTZ;
BEGIN
    -- Generate backup ID
    backup_id := 'backup_' || to_char(NOW(), 'YYYYMMDD_HH24MISS');
    backup_timestamp := NOW();
    
    -- Log backup start
    INSERT INTO backup_logs (backup_id, backup_type, status, started_at, metadata)
    VALUES (backup_id, 'full', 'started', backup_timestamp, 
            jsonb_build_object('tables', array['users', 'posts', 'insights', 'mood_entries', 'error_logs', 'user_activity_logs']));
    
    -- Create backup records for each table
    PERFORM create_table_backup('users', backup_id);
    PERFORM create_table_backup('posts', backup_id);
    PERFORM create_table_backup('insights', backup_id);
    PERFORM create_table_backup('mood_entries', backup_id);
    PERFORM create_table_backup('error_logs', backup_id);
    PERFORM create_table_backup('user_activity_logs', backup_id);
    
    -- Update backup status
    UPDATE backup_logs 
    SET status = 'completed', completed_at = NOW()
    WHERE backup_id = backup_id;
    
    RETURN backup_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create backup for a specific table
CREATE OR REPLACE FUNCTION create_table_backup(table_name TEXT, backup_id TEXT)
RETURNS VOID AS $$
DECLARE
    row_count INTEGER;
    backup_data JSONB;
BEGIN
    -- Get row count
    EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO row_count;
    
    -- Create backup data
    EXECUTE format('SELECT jsonb_agg(to_jsonb(t)) FROM %I t', table_name) INTO backup_data;
    
    -- Insert backup record
    INSERT INTO table_backups (backup_id, table_name, row_count, backup_data, created_at)
    VALUES (backup_id, table_name, row_count, backup_data, NOW());
    
    -- Log table backup
    INSERT INTO backup_logs (backup_id, backup_type, status, started_at, completed_at, metadata)
    VALUES (backup_id || '_' || table_name, 'table', 'completed', NOW(), NOW(),
            jsonb_build_object('table', table_name, 'rows', row_count));
END;
$$ LANGUAGE plpgsql;

-- Function to create incremental backup (only changed data)
CREATE OR REPLACE FUNCTION create_incremental_backup()
RETURNS TEXT AS $$
DECLARE
    backup_id TEXT;
    backup_timestamp TIMESTAMPTZ;
    last_backup_time TIMESTAMPTZ;
BEGIN
    -- Generate backup ID
    backup_id := 'incremental_' || to_char(NOW(), 'YYYYMMDD_HH24MISS');
    backup_timestamp := NOW();
    
    -- Get last backup time
    SELECT MAX(completed_at) INTO last_backup_time 
    FROM backup_logs 
    WHERE backup_type = 'full' AND status = 'completed';
    
    -- If no previous backup, create full backup
    IF last_backup_time IS NULL THEN
        RETURN create_full_backup();
    END IF;
    
    -- Log backup start
    INSERT INTO backup_logs (backup_id, backup_type, status, started_at, metadata)
    VALUES (backup_id, 'incremental', 'started', backup_timestamp,
            jsonb_build_object('since', last_backup_time));
    
    -- Create incremental backups for each table
    PERFORM create_incremental_table_backup('users', backup_id, last_backup_time);
    PERFORM create_incremental_table_backup('posts', backup_id, last_backup_time);
    PERFORM create_incremental_table_backup('insights', backup_id, last_backup_time);
    PERFORM create_incremental_table_backup('mood_entries', backup_id, last_backup_time);
    
    -- Update backup status
    UPDATE backup_logs 
    SET status = 'completed', completed_at = NOW()
    WHERE backup_id = backup_id;
    
    RETURN backup_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create incremental backup for a specific table
CREATE OR REPLACE FUNCTION create_incremental_table_backup(table_name TEXT, backup_id TEXT, since_time TIMESTAMPTZ)
RETURNS VOID AS $$
DECLARE
    row_count INTEGER;
    backup_data JSONB;
BEGIN
    -- Get changed rows count
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE created_at > $1 OR updated_at > $1', table_name)
    USING since_time INTO row_count;
    
    -- If no changes, skip
    IF row_count = 0 THEN
        RETURN;
    END IF;
    
    -- Create backup data for changed rows
    EXECUTE format('SELECT jsonb_agg(to_jsonb(t)) FROM %I t WHERE t.created_at > $1 OR t.updated_at > $1', table_name)
    USING since_time INTO backup_data;
    
    -- Insert backup record
    INSERT INTO table_backups (backup_id, table_name, row_count, backup_data, created_at)
    VALUES (backup_id, table_name, row_count, backup_data, NOW());
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- RECOVERY FUNCTIONS
-- =====================================================

-- Function to restore from backup
CREATE OR REPLACE FUNCTION restore_from_backup(restore_backup_id TEXT)
RETURNS TEXT AS $$
DECLARE
    restore_id TEXT;
    restore_timestamp TIMESTAMPTZ;
    table_record RECORD;
BEGIN
    -- Generate restore ID
    restore_id := 'restore_' || to_char(NOW(), 'YYYYMMDD_HH24MISS');
    restore_timestamp := NOW();
    
    -- Log restore start
    INSERT INTO restore_logs (restore_id, backup_id, status, started_at)
    VALUES (restore_id, restore_backup_id, 'started', restore_timestamp);
    
    -- Restore each table
    FOR table_record IN 
        SELECT DISTINCT table_name 
        FROM table_backups 
        WHERE backup_id = restore_backup_id
    LOOP
        PERFORM restore_table_from_backup(table_record.table_name, restore_backup_id, restore_id);
    END LOOP;
    
    -- Update restore status
    UPDATE restore_logs 
    SET status = 'completed', completed_at = NOW()
    WHERE restore_id = restore_id;
    
    RETURN restore_id;
END;
$$ LANGUAGE plpgsql;

-- Function to restore a specific table from backup
CREATE OR REPLACE FUNCTION restore_table_from_backup(table_name TEXT, backup_id TEXT, restore_id TEXT)
RETURNS VOID AS $$
DECLARE
    backup_record RECORD;
    row_count INTEGER;
BEGIN
    -- Get backup data
    SELECT * INTO backup_record 
    FROM table_backups 
    WHERE backup_id = backup_id AND table_name = table_name;
    
    IF backup_record IS NULL THEN
        RAISE EXCEPTION 'Backup not found for table % and backup %', table_name, backup_id;
    END IF;
    
    -- Clear existing data (be careful with this!)
    EXECUTE format('TRUNCATE TABLE %I CASCADE', table_name);
    
    -- Restore data
    IF backup_record.backup_data IS NOT NULL THEN
        EXECUTE format('INSERT INTO %I SELECT * FROM jsonb_populate_recordset(null::%I, $1)', 
                      table_name, table_name) 
        USING backup_record.backup_data;
        
        GET DIAGNOSTICS row_count = ROW_COUNT;
        
        -- Log restore
        INSERT INTO restore_logs (restore_id, backup_id, status, started_at, completed_at, metadata)
        VALUES (restore_id, backup_id, 'completed', NOW(), NOW(),
                jsonb_build_object('table', table_name, 'rows_restored', row_count));
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- BACKUP TABLES
-- =====================================================

-- Backup logs table
CREATE TABLE IF NOT EXISTS backup_logs (
    id BIGSERIAL PRIMARY KEY,
    backup_id TEXT NOT NULL UNIQUE,
    backup_type TEXT NOT NULL CHECK (backup_type IN ('full', 'incremental', 'table')),
    status TEXT NOT NULL CHECK (status IN ('started', 'completed', 'failed')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table backups storage
CREATE TABLE IF NOT EXISTS table_backups (
    id BIGSERIAL PRIMARY KEY,
    backup_id TEXT NOT NULL,
    table_name TEXT NOT NULL,
    row_count INTEGER NOT NULL DEFAULT 0,
    backup_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (backup_id) REFERENCES backup_logs(backup_id) ON DELETE CASCADE
);

-- Restore logs table
CREATE TABLE IF NOT EXISTS restore_logs (
    id BIGSERIAL PRIMARY KEY,
    restore_id TEXT NOT NULL UNIQUE,
    backup_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('started', 'completed', 'failed')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (backup_id) REFERENCES backup_logs(backup_id)
);

-- =====================================================
-- INDEXES AND CONSTRAINTS
-- =====================================================

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_backup_logs_backup_id ON backup_logs(backup_id);
CREATE INDEX IF NOT EXISTS idx_backup_logs_type ON backup_logs(backup_type);
CREATE INDEX IF NOT EXISTS idx_backup_logs_status ON backup_logs(status);
CREATE INDEX IF NOT EXISTS idx_backup_logs_created_at ON backup_logs(created_at);

CREATE INDEX IF NOT EXISTS idx_table_backups_backup_id ON table_backups(backup_id);
CREATE INDEX IF NOT EXISTS idx_table_backups_table_name ON table_backups(table_name);
CREATE INDEX IF NOT EXISTS idx_table_backups_created_at ON table_backups(created_at);

CREATE INDEX IF NOT EXISTS idx_restore_logs_restore_id ON restore_logs(restore_id);
CREATE INDEX IF NOT EXISTS idx_restore_logs_backup_id ON restore_logs(backup_id);
CREATE INDEX IF NOT EXISTS idx_restore_logs_status ON restore_logs(status);

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Function to get backup status
CREATE OR REPLACE FUNCTION get_backup_status(backup_id_param TEXT)
RETURNS TABLE (
    backup_id TEXT,
    backup_type TEXT,
    status TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration INTERVAL,
    tables_backed_up INTEGER,
    total_rows INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bl.backup_id,
        bl.backup_type,
        bl.status,
        bl.started_at,
        bl.completed_at,
        bl.completed_at - bl.started_at as duration,
        COUNT(DISTINCT tb.table_name)::INTEGER as tables_backed_up,
        COALESCE(SUM(tb.row_count), 0)::INTEGER as total_rows
    FROM backup_logs bl
    LEFT JOIN table_backups tb ON bl.backup_id = tb.backup_id
    WHERE bl.backup_id = backup_id_param
    GROUP BY bl.backup_id, bl.backup_type, bl.status, bl.started_at, bl.completed_at;
END;
$$ LANGUAGE plpgsql;

-- Function to list all backups
CREATE OR REPLACE FUNCTION list_backups(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    backup_id TEXT,
    backup_type TEXT,
    status TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration INTERVAL,
    tables_backed_up INTEGER,
    total_rows INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bl.backup_id,
        bl.backup_type,
        bl.status,
        bl.started_at,
        bl.completed_at,
        bl.completed_at - bl.started_at as duration,
        COUNT(DISTINCT tb.table_name)::INTEGER as tables_backed_up,
        COALESCE(SUM(tb.row_count), 0)::INTEGER as total_rows
    FROM backup_logs bl
    LEFT JOIN table_backups tb ON bl.backup_id = tb.backup_id
    GROUP BY bl.backup_id, bl.backup_type, bl.status, bl.started_at, bl.completed_at
    ORDER BY bl.started_at DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup old backups
CREATE OR REPLACE FUNCTION cleanup_old_backups(retention_days INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete old backup logs and associated table backups
    DELETE FROM backup_logs 
    WHERE created_at < NOW() - (retention_days || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

-- Enable RLS on backup tables
ALTER TABLE backup_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE table_backups ENABLE ROW LEVEL SECURITY;
ALTER TABLE restore_logs ENABLE ROW LEVEL SECURITY;

-- Create policies (only authenticated users can access)
CREATE POLICY "Allow backup access for authenticated users" ON backup_logs
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow table backup access for authenticated users" ON table_backups
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow restore access for authenticated users" ON restore_logs
    FOR ALL USING (auth.role() = 'authenticated');

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON backup_logs TO anon, authenticated;
GRANT ALL ON table_backups TO anon, authenticated;
GRANT ALL ON restore_logs TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;
