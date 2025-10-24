# 🗄️ Complete Database Setup Guide

## Overview

This guide will walk you through setting up the complete MindVault database in Supabase.

## Prerequisites

- ✅ Supabase account created
- ✅ Supabase project created
- ✅ Project URL and anon key available

---

## Step-by-Step Setup

### Step 1: Access Supabase SQL Editor

1. **Login to Supabase**: Go to [https://supabase.com](https://supabase.com)
2. **Select Your Project**: Choose your MindVault project
3. **Navigate to SQL Editor**: Click on "SQL Editor" in the left sidebar
4. **Create New Query**: Click "New Query"

### Step 2: Run the Complete Setup Script

1. **Open the Script**: Open `COMPLETE-DATABASE-SETUP.sql` in your text editor
2. **Copy All Content**: Select all (Ctrl+A / Cmd+A) and copy (Ctrl+C / Cmd+C)
3. **Paste into Supabase**: Paste into the SQL Editor
4. **Run the Script**: Click "Run" or press Ctrl+Enter / Cmd+Enter

### Step 3: Verify Setup

After running the script, verify that all tables were created:

```sql
-- Check all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see these tables:
- ✅ `users`
- ✅ `error_logs`
- ✅ `user_activity_logs`
- ✅ `rate_limits`
- ✅ `failed_login_attempts`
- ✅ `suspicious_activity`
- ✅ `ip_blacklist`
- ✅ `user_security_settings`
- ✅ `security_events`
- ✅ `onboarding_progress`
- ✅ `professional_profiles`
- ✅ `onboarding_checkpoints`
- ✅ `onboarding_resources`
- ✅ `client_professional_relationships`
- ✅ `sessions`
- ✅ `treatment_plans`
- ✅ `client_assessments`
- ✅ `client_notes`
- ✅ `professional_availability`
- ✅ `professional_analytics`

### Step 4: Test Functions

Test that the functions work correctly:

```sql
-- Test rate limiting function
SELECT * FROM check_rate_limit('test-user-id', '127.0.0.1', '/api/test', 60, 60);

-- Test security event logging
SELECT log_security_event(
    'test-user-id',
    'login',
    '127.0.0.1',
    'Mozilla/5.0',
    true
);

-- Test professional dashboard stats (will return empty for new setup)
SELECT * FROM get_professional_dashboard_stats('test-professional-id');
```

### Step 5: Create Your Admin User

```sql
-- Insert an admin user (replace with your details)
INSERT INTO users (
    id,
    email,
    first_name,
    last_name,
    user_type,
    plan,
    payment_status,
    verification_status
) VALUES (
    'your-admin-user-id', -- Get this from auth.users after signup
    'admin@mindvault.fit',
    'Admin',
    'User',
    'admin',
    'professional',
    'active',
    'approved'
)
ON CONFLICT (id) DO UPDATE
SET user_type = 'admin',
    verification_status = 'approved';
```

---

## Troubleshooting

### Error: "relation already exists"

**Solution**: Some tables may already exist from previous setup attempts. This is okay! The script uses `CREATE TABLE IF NOT EXISTS`, so it will skip existing tables.

### Error: "permission denied"

**Solution**: Make sure you're running the script as the project owner or with appropriate permissions.

### Error: "function already exists"

**Solution**: Functions may already exist. The script will skip existing functions. To replace them, drop them first:

```sql
DROP FUNCTION IF EXISTS check_rate_limit CASCADE;
DROP FUNCTION IF EXISTS log_failed_login CASCADE;
-- etc.
```

### Error: "column already exists"

**Solution**: The table may have been partially created. Drop the table and recreate:

```sql
DROP TABLE IF EXISTS users CASCADE;
-- Then run the full script again
```

---

## Post-Setup Configuration

### 1. Configure RLS Policies

All tables have RLS enabled by default. Verify policies are working:

```sql
-- Check RLS status
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

### 2. Set Up Automated Cleanup

Create a scheduled job to clean up old data:

```sql
-- Run daily at 2 AM
SELECT cleanup_old_error_logs();        -- Cleans error logs older than 30 days
SELECT cleanup_old_activity_logs();     -- Cleans activity logs older than 90 days
SELECT cleanup_old_rate_limits();       -- Cleans rate limits older than 24 hours
SELECT cleanup_old_failed_logins();     -- Cleans failed logins older than 30 days
SELECT cleanup_old_security_events();   -- Cleans security events older than 90 days
```

### 3. Test Row Level Security

```sql
-- Test as authenticated user
SET ROLE authenticated;
SELECT * FROM users WHERE id = auth.uid()::text;
RESET ROLE;

-- Test as admin
-- (You'll need to be logged in as admin)
```

---

## Verification Checklist

After setup, verify:

- [ ] All 20 tables created successfully
- [ ] All functions created successfully
- [ ] All views created successfully
- [ ] RLS policies enabled on all tables
- [ ] Test functions work correctly
- [ ] Admin user can be created
- [ ] No errors in Supabase logs

---

## Next Steps

Once your database is set up:

1. ✅ **Test User Signup**: Create a test user account
2. ✅ **Test Professional Signup**: Create a test professional account
3. ✅ **Test Admin Panel**: Access the admin dashboard
4. ✅ **Test Security**: Verify rate limiting works
5. ✅ **Test Onboarding**: Complete the professional onboarding
6. ✅ **Launch Beta**: Make your site live!

---

## Support

If you encounter issues:

1. **Check Supabase Logs**: Go to Logs in your Supabase dashboard
2. **Review Error Messages**: Copy the exact error message
3. **Check Documentation**: Review this guide and SQL comments
4. **Contact Support**: Reach out to the MindVault team

---

## Database Schema Overview

### Core Tables (6)
- `users` - User accounts and profiles
- `error_logs` - Error tracking and logging
- `user_activity_logs` - User behavior tracking
- `rate_limits` - API rate limiting
- `failed_login_attempts` - Login security
- `suspicious_activity` - Security monitoring

### Security Tables (4)
- `ip_blacklist` - Blocked IP addresses
- `user_security_settings` - User security preferences
- `security_events` - Security event log
- `user_security_settings` - Security configuration

### Professional Tables (9)
- `onboarding_progress` - Onboarding tracking
- `professional_profiles` - Professional details
- `onboarding_checkpoints` - Onboarding steps
- `onboarding_resources` - Onboarding materials
- `client_professional_relationships` - Client-professional pairs
- `sessions` - Therapy sessions
- `treatment_plans` - Treatment planning
- `client_assessments` - Client assessments
- `client_notes` - Clinical notes

### Management Tables (2)
- `professional_availability` - Schedule management
- `professional_analytics` - Practice analytics

---

**Your database is now ready for production! 🚀**
