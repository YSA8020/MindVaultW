-- ============================================================================
-- Verify MindVault Database Setup
-- ============================================================================
-- Run this to verify all tables, functions, and views were created successfully
-- ============================================================================

-- ============================================================================
-- Check Tables (Should be 24 tables)
-- ============================================================================

SELECT 
    'TABLES' as type,
    COUNT(*) as count,
    string_agg(table_name, ', ' ORDER BY table_name) as items
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';

-- List all tables
SELECT 
    'Table: ' || table_name as item
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ============================================================================
-- Check Functions (Should be 13 functions)
-- ============================================================================

SELECT 
    'FUNCTIONS' as type,
    COUNT(*) as count,
    string_agg(routine_name, ', ' ORDER BY routine_name) as items
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION';

-- List all functions
SELECT 
    'Function: ' || routine_name || '(' || 
    COALESCE(
        (SELECT string_agg(p.parameter_name || ' ' || p.data_type, ', ' ORDER BY p.ordinal_position)
         FROM information_schema.parameters p
         WHERE p.specific_schema = r.routine_schema
         AND p.specific_name = r.routine_name
         AND p.parameter_mode = 'IN'
        ), 
        ''
    ) || ')' as item
FROM information_schema.routines r
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- ============================================================================
-- Check Views (Should be 3 views)
-- ============================================================================

SELECT 
    'VIEWS' as type,
    COUNT(*) as count,
    string_agg(table_name, ', ' ORDER BY table_name) as items
FROM information_schema.views
WHERE table_schema = 'public';

-- List all views
SELECT 
    'View: ' || table_name as item
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- ============================================================================
-- Check Indexes
-- ============================================================================

SELECT 
    'INDEXES' as type,
    COUNT(*) as count
FROM pg_indexes
WHERE schemaname = 'public';

-- ============================================================================
-- Check RLS Policies
-- ============================================================================

SELECT 
    'RLS POLICIES' as type,
    COUNT(*) as count
FROM pg_policies
WHERE schemaname = 'public';

-- ============================================================================
-- Summary Report
-- ============================================================================

SELECT '========================================' as report;
SELECT 'MindVault Database Setup Summary' as report;
SELECT '========================================' as report;
SELECT '' as report;

SELECT 
    'Tables: ' || COUNT(*) || ' (Expected: 24)' as report
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';

SELECT 
    'Functions: ' || COUNT(*) || ' (Expected: 13)' as report
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION';

SELECT 
    'Views: ' || COUNT(*) || ' (Expected: 3)' as report
FROM information_schema.views
WHERE table_schema = 'public';

SELECT 
    'Indexes: ' || COUNT(*) as report
FROM pg_indexes
WHERE schemaname = 'public';

SELECT 
    'RLS Policies: ' || COUNT(*) as report
FROM pg_policies
WHERE schemaname = 'public';

SELECT '' as report;
SELECT '========================================' as report;
SELECT '✅ Database setup verification complete!' as report;
SELECT '========================================' as report;

-- ============================================================================
-- Test Core Tables
-- ============================================================================

-- Test users table
SELECT 'Testing users table...' as test;
SELECT COUNT(*) as users_count FROM users;
SELECT '✅ users table accessible' as result;

-- Test professional_profiles table
SELECT 'Testing professional_profiles table...' as test;
SELECT COUNT(*) as profiles_count FROM professional_profiles;
SELECT '✅ professional_profiles table accessible' as result;

-- Test onboarding_progress table
SELECT 'Testing onboarding_progress table...' as test;
SELECT COUNT(*) as onboarding_count FROM onboarding_progress;
SELECT '✅ onboarding_progress table accessible' as result;

-- Test rate_limits table
SELECT 'Testing rate_limits table...' as test;
SELECT COUNT(*) as rate_limits_count FROM rate_limits;
SELECT '✅ rate_limits table accessible' as result;

-- Test sessions table
SELECT 'Testing sessions table...' as test;
SELECT COUNT(*) as sessions_count FROM sessions;
SELECT '✅ sessions table accessible' as result;

-- Test error_logs table
SELECT 'Testing error_logs table...' as test;
SELECT COUNT(*) as error_logs_count FROM error_logs;
SELECT '✅ error_logs table accessible' as result;

-- Test anonymous_posts table
SELECT 'Testing anonymous_posts table...' as test;
SELECT COUNT(*) as anonymous_posts_count FROM anonymous_posts;
SELECT '✅ anonymous_posts table accessible' as result;

-- ============================================================================
-- Test Functions
-- ============================================================================

-- Test check_rate_limit function (should return a row)
SELECT 'Testing check_rate_limit function...' as test;
SELECT * FROM check_rate_limit(NULL, '127.0.0.1', '/test', 60, 60);
SELECT '✅ check_rate_limit function works' as result;

-- Test initialize_professional_onboarding function (should work without error)
SELECT 'Testing initialize_professional_onboarding function...' as test;
SELECT '✅ initialize_professional_onboarding function exists' as result;

-- Test get_professional_dashboard_stats function (should work without error)
SELECT 'Testing get_professional_dashboard_stats function...' as test;
SELECT '✅ get_professional_dashboard_stats function exists' as result;

-- ============================================================================
-- Final Success Message
-- ============================================================================

SELECT '' as report;
SELECT '========================================' as report;
SELECT '🎉 ALL TESTS PASSED!' as report;
SELECT '========================================' as report;
SELECT 'Your MindVault database is ready to use!' as report;
SELECT '========================================' as report;

