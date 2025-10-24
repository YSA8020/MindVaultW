-- Add Professional Fields to Users Table
-- Run this in your Supabase SQL Editor to add professional-specific columns

-- Add professional columns to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS professional_type VARCHAR CHECK (professional_type IN ('licensed', 'peer-professional'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS license_type VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS license_number VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS years_experience VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS specializations TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS professional_bio TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS preferred_support_group VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_status VARCHAR DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for professionals
CREATE INDEX IF NOT EXISTS idx_users_verification_status ON users(verification_status);
CREATE INDEX IF NOT EXISTS idx_users_license_type ON users(license_type);
CREATE INDEX IF NOT EXISTS idx_users_professional_type ON users(professional_type);

SELECT 'Professional fields added successfully!' as result;

