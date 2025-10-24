-- Quick Database Setup for MindVault
-- Run this in your Supabase SQL Editor to create the essential tables

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table (essential for signup/login)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR UNIQUE NOT NULL,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    user_type VARCHAR NOT NULL CHECK (user_type IN ('user', 'peer', 'professional')),
    plan VARCHAR NOT NULL DEFAULT 'basic' CHECK (plan IN ('basic', 'premium', 'professional')),
    billing_cycle VARCHAR NOT NULL DEFAULT 'monthly' CHECK (billing_cycle IN ('monthly', 'annual')),
    support_group VARCHAR,
    experience_level VARCHAR,
    journey TEXT,
    newsletter_subscribed BOOLEAN DEFAULT false,
    payment_method VARCHAR,
    payment_status VARCHAR DEFAULT 'trial' CHECK (payment_status IN ('trial', 'active', 'expired', 'cancelled')),
    payment_date TIMESTAMP WITH TIME ZONE,
    billing_first_name VARCHAR,
    billing_last_name VARCHAR,
    billing_email VARCHAR,
    billing_address VARCHAR,
    billing_city VARCHAR,
    billing_state VARCHAR,
    billing_zip VARCHAR,
    trial_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    trial_end TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '14 days'),
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_plan ON users(plan);

-- Success message
SELECT 'Database setup completed successfully! Users table created with RLS policies.' as status;
