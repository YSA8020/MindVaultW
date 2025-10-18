# MindVault Database Setup - Complete Instructions

## 🎉 Success! Fresh Start Setup Worked!

The `FRESH-START-SETUP.sql` script succeeded, which means the core tables are now created. Now we need to add the rest of the tables.

## 📋 Two Options for Completing the Setup

### Option 1: Run Everything at Once (Recommended)

**Use: `COMPLETE-SETUP-INCREMENTAL.sql`**

This single script contains the entire database setup:
- ✅ Drops all existing tables/functions/views
- ✅ Creates all tables in the correct order
- ✅ Creates all functions
- ✅ Creates all views
- ✅ Sets up RLS policies

**How to run:**
1. Open Supabase SQL Editor
2. Copy the entire `COMPLETE-SETUP-INCREMENTAL.sql` file
3. Paste and click "Run"
4. Wait for completion (30-60 seconds)

### Option 2: Run Incrementally (If you want more control)

Run these scripts in order:

1. **`FRESH-START-SETUP.sql`** ✅ (Already completed!)
   - Core tables: `users`, `professional_profiles`, `onboarding_progress`
   - Onboarding functions

2. **`ADD-SECURITY-TABLES.sql`** (Next)
   - Security tables: `rate_limits`, `failed_login_attempts`, `suspicious_activity`, `ip_blacklist`, `user_security_settings`, `security_events`
   - Security functions: `check_rate_limit`, `log_failed_login`, `log_security_event`

3. **`ADD-PROFESSIONAL-DASHBOARD.sql`**
   - Professional dashboard tables: `client_professional_relationships`, `sessions`, `treatment_plans`, `client_assessments`, `client_notes`, `professional_availability`, `professional_analytics`
   - Dashboard functions: `get_professional_dashboard_stats`, `get_upcoming_sessions`, `get_professional_clients`

4. **`ADD-MONITORING-LOGGING.sql`**
   - Error logging: `error_logs` table, `error_stats` view, cleanup function
   - User activity logging: `user_activity_logs` table, `user_activity_stats` view, `user_journey` view, cleanup function

5. **`ADD-ANONYMOUS-BACKUP.sql`**
   - Anonymous sharing: `anonymous_posts`, `emergency_response_logs`
   - Backup system: `backup_history`, `restore_history`, backup/restore functions

## 🗄️ Complete Database Schema

### Core Tables (✅ Already Created)
- `users` - User accounts with all types
- `professional_profiles` - Professional information
- `onboarding_progress` - Onboarding tracking
- `onboarding_checkpoints` - Detailed checkpoints
- `onboarding_resources` - Onboarding content

### Security Tables (Pending)
- `rate_limits` - API rate limiting
- `failed_login_attempts` - Login security
- `suspicious_activity` - Threat detection
- `ip_blacklist` - Blocked IPs
- `user_security_settings` - User security preferences
- `security_events` - Security event logging

### Professional Dashboard Tables (Pending)
- `client_professional_relationships` - Client connections
- `sessions` - Session management
- `treatment_plans` - Treatment planning
- `client_assessments` - Client assessments
- `client_notes` - Session notes
- `professional_availability` - Availability management
- `professional_analytics` - Professional metrics

### Monitoring & Logging Tables (Pending)
- `error_logs` - Application errors
- `user_activity_logs` - User activity tracking
- `error_stats` (view) - Error statistics
- `user_activity_stats` (view) - Activity statistics
- `user_journey` (view) - User journey tracking

### Anonymous Sharing Tables (Pending)
- `anonymous_posts` - Anonymous posts with risk assessment
- `emergency_response_logs` - Emergency response tracking

### Backup System Tables (Pending)
- `backup_history` - Backup tracking
- `restore_history` - Restore tracking

## 🚀 Quick Start

**Just run this ONE script:**

```sql
-- Copy and paste COMPLETE-SETUP-INCREMENTAL.sql into Supabase SQL Editor
```

This will create the complete database in one go!

## ✅ Verification

After running the complete setup, verify with:

```sql
-- Check all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check all functions
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
ORDER BY routine_name;

-- Check all views
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see:
- **24 tables**
- **13 functions**
- **3 views**

## 📊 Expected Tables (24 total)

1. users
2. professional_profiles
3. onboarding_progress
4. onboarding_checkpoints
5. onboarding_resources
6. rate_limits
7. failed_login_attempts
8. suspicious_activity
9. ip_blacklist
10. user_security_settings
11. security_events
12. client_professional_relationships
13. sessions
14. treatment_plans
15. client_assessments
16. client_notes
17. professional_availability
18. professional_analytics
19. error_logs
20. user_activity_logs
21. anonymous_posts
22. emergency_response_logs
23. backup_history
24. restore_history

## 🎯 Next Steps

After the database is set up:

1. ✅ Test user registration
2. ✅ Test professional signup
3. ✅ Test login flow
4. ✅ Test professional onboarding
5. ✅ Test professional dashboard
6. ✅ Test anonymous sharing
7. ✅ Test error logging
8. ✅ Test security features

## 📝 Summary

- **FRESH-START-SETUP.sql** ✅ - Core tables (COMPLETED!)
- **COMPLETE-SETUP-INCREMENTAL.sql** - All tables in one script (RECOMMENDED)
- **Individual ADD-*.sql scripts** - Incremental approach (optional)

**Ready to complete the setup!** 🚀

