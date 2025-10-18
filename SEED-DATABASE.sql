-- MindVault Database Seeding Script
-- This script creates initial admin accounts and seed data for testing

-- ============================================
-- PART 1: ADMIN ACCOUNTS
-- ============================================

-- Note: Admin accounts must be created through Supabase Auth
-- This script creates the corresponding user records in the database

-- Admin Account 1: System Administrator
INSERT INTO users (id, email, full_name, user_type, is_admin, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'admin@mindvault.fit',
    'System Administrator',
    'admin',
    true,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Admin Account 2: Support Administrator
INSERT INTO users (id, email, full_name, user_type, is_admin, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'support@mindvault.fit',
    'Support Administrator',
    'admin',
    true,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Admin Account 3: Technical Administrator
INSERT INTO users (id, email, full_name, user_type, is_admin, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'tech@mindvault.fit',
    'Technical Administrator',
    'admin',
    true,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- PART 2: TEST USER ACCOUNTS
-- ============================================

-- Test User 1: Regular User
INSERT INTO users (id, email, full_name, user_type, is_admin, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'testuser@mindvault.fit',
    'Test User',
    'user',
    false,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Test User 2: Regular User
INSERT INTO users (id, email, full_name, user_type, is_admin, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'user2@test.com',
    'Test User 2',
    'user',
    false,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- PART 3: TEST PROFESSIONAL ACCOUNTS
-- ============================================

-- Test Professional 1: Licensed Counselor
INSERT INTO users (id, email, full_name, user_type, is_admin, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'testprofessional@mindvault.fit',
    'Dr. Jane Smith',
    'professional',
    false,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Test Professional 2: Licensed Therapist
INSERT INTO users (id, email, full_name, user_type, is_admin, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'professional2@test.com',
    'Dr. John Doe',
    'professional',
    false,
    NOW(),
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- PART 4: USER SETTINGS
-- ============================================

-- Create user settings for test users
INSERT INTO user_settings (user_id, theme, language, notifications_enabled, email_notifications, sms_notifications, created_at, updated_at)
SELECT 
    id,
    'light',
    'en',
    true,
    true,
    false,
    NOW(),
    NOW()
FROM users
WHERE email IN ('testuser@mindvault.fit', 'user2@test.com')
ON CONFLICT (user_id) DO NOTHING;

-- ============================================
-- PART 5: PROFESSIONAL PROFILES
-- ============================================

-- Professional Profile 1
INSERT INTO professional_profiles (
    professional_id,
    license_number,
    license_type,
    license_state,
    license_expiry,
    specialization,
    bio,
    years_of_experience,
    education,
    certifications,
    languages_spoken,
    hourly_rate,
    is_verified,
    created_at,
    updated_at
)
SELECT 
    id,
    'LCSW-12345',
    'Licensed Clinical Social Worker',
    'California',
    '2025-12-31',
    'Anxiety, Depression, PTSD',
    'Dr. Jane Smith is a licensed clinical social worker with over 10 years of experience helping individuals overcome anxiety, depression, and trauma-related disorders.',
    10,
    'MSW, University of California, Berkeley',
    'EMDR Certified, CBT Certified',
    'English, Spanish',
    150.00,
    true,
    NOW(),
    NOW()
FROM users
WHERE email = 'testprofessional@mindvault.fit'
ON CONFLICT (professional_id) DO NOTHING;

-- Professional Profile 2
INSERT INTO professional_profiles (
    professional_id,
    license_number,
    license_type,
    license_state,
    license_expiry,
    specialization,
    bio,
    years_of_experience,
    education,
    certifications,
    languages_spoken,
    hourly_rate,
    is_verified,
    created_at,
    updated_at
)
SELECT 
    id,
    'LMFT-67890',
    'Licensed Marriage and Family Therapist',
    'New York',
    '2026-06-30',
    'Couples Therapy, Family Therapy',
    'Dr. John Doe specializes in couples and family therapy, helping families navigate relationship challenges and improve communication.',
    8,
    'PhD in Marriage and Family Therapy, Columbia University',
    'Gottman Method Level 2, Emotionally Focused Therapy',
    'English, French',
    175.00,
    true,
    NOW(),
    NOW()
FROM users
WHERE email = 'professional2@test.com'
ON CONFLICT (professional_id) DO NOTHING;

-- ============================================
-- PART 6: ONBOARDING PROGRESS
-- ============================================

-- Onboarding Progress for Professional 1
INSERT INTO onboarding_progress (
    professional_id,
    current_step,
    completed_steps,
    is_complete,
    started_at,
    completed_at,
    updated_at
)
SELECT 
    id,
    5,
    ARRAY[1, 2, 3, 4, 5],
    true,
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '1 day',
    NOW()
FROM users
WHERE email = 'testprofessional@mindvault.fit'
ON CONFLICT (professional_id) DO NOTHING;

-- ============================================
-- PART 7: NOTIFICATION PREFERENCES
-- ============================================

-- Notification preferences for all users
INSERT INTO notification_preferences (
    user_id,
    email_enabled,
    sms_enabled,
    push_enabled,
    session_reminders,
    appointment_updates,
    system_notifications,
    marketing_emails,
    created_at,
    updated_at
)
SELECT 
    id,
    true,
    false,
    true,
    true,
    true,
    true,
    false,
    NOW(),
    NOW()
FROM users
ON CONFLICT (user_id) DO NOTHING;

-- ============================================
-- PART 8: SAMPLE CLIENT-PROFESSIONAL RELATIONSHIPS
-- ============================================

-- Create relationship between test user and professional
INSERT INTO client_professional_relationships (
    client_id,
    professional_id,
    status,
    started_at,
    created_at,
    updated_at
)
SELECT 
    u1.id,
    u2.id,
    'active',
    NOW() - INTERVAL '1 week',
    NOW() - INTERVAL '1 week',
    NOW()
FROM users u1, users u2
WHERE u1.email = 'testuser@mindvault.fit'
  AND u2.email = 'testprofessional@mindvault.fit'
ON CONFLICT (client_id, professional_id) DO NOTHING;

-- ============================================
-- PART 9: SAMPLE SESSIONS
-- ============================================

-- Create sample session
INSERT INTO sessions (
    client_id,
    professional_id,
    session_date,
    session_time,
    duration_minutes,
    session_type,
    status,
    notes,
    created_at,
    updated_at
)
SELECT 
    u1.id,
    u2.id,
    CURRENT_DATE + INTERVAL '1 day',
    '14:00:00',
    60,
    'individual',
    'scheduled',
    'Initial consultation session',
    NOW(),
    NOW()
FROM users u1, users u2
WHERE u1.email = 'testuser@mindvault.fit'
  AND u2.email = 'testprofessional@mindvault.fit'
ON CONFLICT DO NOTHING;

-- ============================================
-- PART 10: SAMPLE TREATMENT PLANS
-- ============================================

-- Create sample treatment plan
INSERT INTO treatment_plans (
    client_id,
    professional_id,
    plan_name,
    diagnosis,
    goals,
    interventions,
    start_date,
    end_date,
    status,
    created_at,
    updated_at
)
SELECT 
    u1.id,
    u2.id,
    'Anxiety Management Plan',
    'Generalized Anxiety Disorder',
    ARRAY[
        'Reduce anxiety symptoms by 50%',
        'Improve daily functioning',
        'Develop coping strategies'
    ],
    ARRAY[
        'Cognitive Behavioral Therapy',
        'Mindfulness exercises',
        'Progressive muscle relaxation'
    ],
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '3 months',
    'active',
    NOW(),
    NOW()
FROM users u1, users u2
WHERE u1.email = 'testuser@mindvault.fit'
  AND u2.email = 'testprofessional@mindvault.fit'
ON CONFLICT DO NOTHING;

-- ============================================
-- PART 11: SAMPLE USER ACTIVITY LOG
-- ============================================

-- Log some sample activities
INSERT INTO user_activity_log (user_id, activity_type, activity_description, ip_address, user_agent, created_at)
SELECT 
    id,
    'login',
    'User logged in successfully',
    '192.168.1.1',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    NOW() - INTERVAL '1 hour'
FROM users
WHERE email = 'testuser@mindvault.fit'
ON CONFLICT DO NOTHING;

-- ============================================
-- PART 12: SAMPLE ANONYMOUS POSTS
-- ============================================

-- Create sample anonymous post
INSERT INTO anonymous_posts (
    content,
    mood_level,
    risk_level,
    tags,
    created_at,
    updated_at
)
VALUES (
    'Feeling overwhelmed today. Work stress is getting to me.',
    3,
    'low',
    ARRAY['stress', 'work'],
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '2 hours'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- PART 13: VERIFICATION QUERIES
-- ============================================

-- Verify seeded data
SELECT 'Admin Accounts' as category, COUNT(*) as count
FROM users
WHERE is_admin = true

UNION ALL

SELECT 'Regular Users' as category, COUNT(*) as count
FROM users
WHERE user_type = 'user'

UNION ALL

SELECT 'Professionals' as category, COUNT(*) as count
FROM users
WHERE user_type = 'professional'

UNION ALL

SELECT 'Professional Profiles' as category, COUNT(*) as count
FROM professional_profiles

UNION ALL

SELECT 'Client Relationships' as category, COUNT(*) as count
FROM client_professional_relationships

UNION ALL

SELECT 'Sessions' as category, COUNT(*) as count
FROM sessions

UNION ALL

SELECT 'Treatment Plans' as category, COUNT(*) as count
FROM treatment_plans

UNION ALL

SELECT 'Anonymous Posts' as category, COUNT(*) as count
FROM anonymous_posts;

-- ============================================
-- END OF SEEDING SCRIPT
-- ============================================

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Database seeding completed successfully!';
    RAISE NOTICE '📊 Check the verification queries above for counts.';
    RAISE NOTICE '🔑 Admin accounts created (must be created through Supabase Auth):';
    RAISE NOTICE '   - admin@mindvault.fit';
    RAISE NOTICE '   - support@mindvault.fit';
    RAISE NOTICE '   - tech@mindvault.fit';
    RAISE NOTICE '👤 Test accounts created:';
    RAISE NOTICE '   - testuser@mindvault.fit';
    RAISE NOTICE '   - testprofessional@mindvault.fit';
END $$;

