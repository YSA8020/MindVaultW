-- ============================================================================
-- MindVault Database Setup - DROP AND RECREATE
-- ============================================================================
-- This script drops existing tables and recreates them fresh
-- ⚠️ WARNING: This will delete all existing data!
-- ============================================================================

-- Drop all tables in reverse dependency order
DROP TABLE IF EXISTS restore_history CASCADE;
DROP TABLE IF EXISTS backup_history CASCADE;
DROP TABLE IF EXISTS emergency_response_logs CASCADE;
DROP TABLE IF EXISTS anonymous_posts CASCADE;
DROP TABLE IF EXISTS professional_analytics CASCADE;
DROP TABLE IF EXISTS professional_availability CASCADE;
DROP TABLE IF EXISTS client_notes CASCADE;
DROP TABLE IF EXISTS client_assessments CASCADE;
DROP TABLE IF EXISTS treatment_plans CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS client_professional_relationships CASCADE;
DROP TABLE IF EXISTS onboarding_resources CASCADE;
DROP TABLE IF EXISTS onboarding_checkpoints CASCADE;
DROP TABLE IF EXISTS onboarding_progress CASCADE;
DROP TABLE IF EXISTS professional_profiles CASCADE;
DROP TABLE IF EXISTS security_events CASCADE;
DROP TABLE IF EXISTS user_security_settings CASCADE;
DROP TABLE IF EXISTS ip_blacklist CASCADE;
DROP TABLE IF EXISTS suspicious_activity CASCADE;
DROP TABLE IF EXISTS failed_login_attempts CASCADE;
DROP TABLE IF EXISTS rate_limits CASCADE;
DROP TABLE IF EXISTS user_activity_logs CASCADE;
DROP TABLE IF EXISTS error_logs CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop all views
DROP VIEW IF EXISTS user_journey CASCADE;
DROP VIEW IF EXISTS user_activity_stats CASCADE;
DROP VIEW IF EXISTS error_stats CASCADE;

-- Drop all functions
DROP FUNCTION IF EXISTS restore_from_backup(BIGINT, TEXT[]) CASCADE;
DROP FUNCTION IF EXISTS create_full_backup(TEXT, JSONB) CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_activity_logs(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_error_logs(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_professional_clients(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_upcoming_sessions(UUID, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_professional_dashboard_stats(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_onboarding_status(UUID) CASCADE;
DROP FUNCTION IF EXISTS update_onboarding_progress(UUID, INTEGER, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS initialize_professional_onboarding(UUID) CASCADE;
DROP FUNCTION IF EXISTS log_security_event(UUID, TEXT, TEXT, TEXT, JSONB) CASCADE;
DROP FUNCTION IF EXISTS log_failed_login(UUID, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS check_rate_limit(UUID, TEXT, TEXT, INTEGER, INTEGER) CASCADE;

-- Now run the SIMPLE-SETUP-NO-CLEANUP.sql script
-- (Copy and paste the contents of SIMPLE-SETUP-NO-CLEANUP.sql here)

