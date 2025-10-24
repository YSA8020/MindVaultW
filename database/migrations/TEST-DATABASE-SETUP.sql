-- Minimal test to identify the error
-- Run this first to see where the error occurs

-- Drop existing functions
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT 'DROP FUNCTION IF EXISTS ' || n.nspname || '.' || p.proname || 
                     '(' || pg_get_function_arguments(p.oid) || ') CASCADE' as drop_cmd
              FROM pg_proc p
              JOIN pg_namespace n ON p.pronamespace = n.oid
              WHERE n.nspname = 'public')
    LOOP
        BEGIN
            EXECUTE r.drop_cmd;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Could not drop function: %', r.drop_cmd;
        END;
    END LOOP;
END $$;

-- Test 1: Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Test 2: Create a simple function
CREATE OR REPLACE FUNCTION test_function(p_user_id UUID)
RETURNS TABLE (
    user_id UUID,
    email TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.email
    FROM users u
    WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Test 3: Grant permissions
GRANT EXECUTE ON FUNCTION test_function(UUID) TO anon, authenticated;

-- If this works, the issue is in a specific function in the main script
-- If this fails, the issue is in the table creation or basic setup
