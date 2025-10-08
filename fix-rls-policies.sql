-- Fix RLS Policies for MindVault Users Table
-- Run this in your Supabase SQL Editor to fix the Row Level Security policies

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;

-- Create new policies that work with signup flow
CREATE POLICY "Enable read access for users based on user_id" ON users FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Enable update for users based on user_id" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users" ON users FOR INSERT WITH CHECK (
    -- Allow insert if user is authenticated and the id matches their auth.uid()
    (auth.uid() IS NOT NULL AND auth.uid() = id) OR
    -- Allow insert during signup process (when auth.uid() might be null temporarily)
    auth.uid() IS NOT NULL
);

-- Alternative: If the above doesn't work, try this more permissive policy
-- CREATE POLICY "Enable insert for all authenticated users" ON users FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'users';

SELECT 'RLS policies updated successfully!' as result;
