-- ============================================================================
-- Inspect existing database structure
-- ============================================================================
-- Run this to see what tables, columns, and views already exist
-- ============================================================================

-- Check all tables in public schema
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check all columns in tables that contain 'professional' or 'onboarding'
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND (
    table_name LIKE '%professional%' 
    OR table_name LIKE '%onboarding%'
    OR column_name LIKE '%professional%'
)
ORDER BY table_name, ordinal_position;

-- Check all views
SELECT 
    table_name as view_name,
    view_definition
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check all functions
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Check for any existing onboarding_progress table structure
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'onboarding_progress'
ORDER BY ordinal_position;

-- Check for any existing professional_profiles table structure
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'professional_profiles'
ORDER BY ordinal_position;

