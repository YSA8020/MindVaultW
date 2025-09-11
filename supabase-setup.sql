-- MindVault Supabase Database Setup Script
-- Run this in your Supabase SQL editor to set up the database schema

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    user_type VARCHAR NOT NULL CHECK (user_type IN ('user', 'peer', 'counselor')),
    plan VARCHAR NOT NULL DEFAULT 'basic' CHECK (plan IN ('basic', 'premium', 'professional')),
    billing VARCHAR NOT NULL DEFAULT 'monthly' CHECK (billing IN ('monthly', 'annual')),
    support_group VARCHAR,
    experience_level VARCHAR,
    journey TEXT,
    newsletter BOOLEAN DEFAULT false,
    payment_completed BOOLEAN DEFAULT false,
    payment_method VARCHAR,
    payment_date TIMESTAMP,
    trial_start TIMESTAMP DEFAULT now(),
    trial_end TIMESTAMP DEFAULT (now() + interval '14 days'),
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    category VARCHAR NOT NULL,
    is_anonymous BOOLEAN DEFAULT true,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- Create mood_entries table
CREATE TABLE IF NOT EXISTS mood_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    mood_score INTEGER NOT NULL CHECK (mood_score >= 1 AND mood_score <= 10),
    mood VARCHAR NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT now()
);

-- Create insights table
CREATE TABLE IF NOT EXISTS insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR NOT NULL,
    content TEXT NOT NULL,
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    created_at TIMESTAMP DEFAULT now()
);

-- Create comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now()
);

-- Create counselor_profiles table
CREATE TABLE IF NOT EXISTS counselor_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    specialization VARCHAR NOT NULL,
    experience_years INTEGER NOT NULL,
    bio TEXT,
    hourly_rate DECIMAL(10,2),
    availability JSONB,
    rating DECIMAL(3,2) DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- Create sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    counselor_id UUID REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled')),
    scheduled_at TIMESTAMP NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_plan ON users(plan);

CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_entries_created_at ON mood_entries(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_insights_user_id ON insights(user_id);
CREATE INDEX IF NOT EXISTS idx_insights_type ON insights(type);
CREATE INDEX IF NOT EXISTS idx_insights_created_at ON insights(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);

CREATE INDEX IF NOT EXISTS idx_counselor_profiles_user_id ON counselor_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_counselor_profiles_specialization ON counselor_profiles(specialization);

CREATE INDEX IF NOT EXISTS idx_sessions_counselor_id ON sessions(counselor_id);
CREATE INDEX IF NOT EXISTS idx_sessions_client_id ON sessions(client_id);
CREATE INDEX IF NOT EXISTS idx_sessions_scheduled_at ON sessions(scheduled_at);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE counselor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for users table
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Create RLS policies for posts table
CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (true);
CREATE POLICY "Users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for mood_entries table
CREATE POLICY "Users can view own mood entries" ON mood_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create mood entries" ON mood_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own mood entries" ON mood_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own mood entries" ON mood_entries FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for insights table
CREATE POLICY "Users can view own insights" ON insights FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create insights" ON insights FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create RLS policies for comments table
CREATE POLICY "Anyone can view comments" ON comments FOR SELECT USING (true);
CREATE POLICY "Users can create comments" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own comments" ON comments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for counselor_profiles table
CREATE POLICY "Anyone can view counselor profiles" ON counselor_profiles FOR SELECT USING (true);
CREATE POLICY "Counselors can manage own profile" ON counselor_profiles FOR ALL USING (auth.uid() = user_id);

-- Create RLS policies for sessions table
CREATE POLICY "Users can view own sessions" ON sessions FOR SELECT USING (auth.uid() = counselor_id OR auth.uid() = client_id);
CREATE POLICY "Users can create sessions" ON sessions FOR INSERT WITH CHECK (auth.uid() = counselor_id OR auth.uid() = client_id);
CREATE POLICY "Users can update own sessions" ON sessions FOR UPDATE USING (auth.uid() = counselor_id OR auth.uid() = client_id);

-- Create functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_counselor_profiles_updated_at BEFORE UPDATE ON counselor_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for testing (optional)
INSERT INTO users (email, password_hash, first_name, last_name, user_type, plan) VALUES
('demo@mindvault.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Demo', 'User', 'user', 'premium'),
('counselor@mindvault.com', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Dr. Jane', 'Smith', 'counselor', 'professional')
ON CONFLICT (email) DO NOTHING;

-- Insert sample counselor profile
INSERT INTO counselor_profiles (user_id, specialization, experience_years, bio, hourly_rate, is_verified) 
SELECT id, 'Cognitive Behavioral Therapy', 10, 'Experienced therapist specializing in CBT and anxiety management.', 150.00, true
FROM users WHERE email = 'counselor@mindvault.com'
ON CONFLICT (user_id) DO NOTHING;

-- Create a function to get user statistics
CREATE OR REPLACE FUNCTION get_user_stats(user_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'totalMoodEntries', (SELECT COUNT(*) FROM mood_entries WHERE user_id = user_uuid),
        'totalPosts', (SELECT COUNT(*) FROM posts WHERE user_id = user_uuid),
        'averageMood', (SELECT AVG(mood_score) FROM mood_entries WHERE user_id = user_uuid),
        'lastActivity', (SELECT MAX(created_at) FROM mood_entries WHERE user_id = user_uuid)
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_user_stats(UUID) TO anon, authenticated;
