-- Supabase Row Level Security (RLS) Policies
-- Replaces firestore.rules for database security
-- Documentation: https://supabase.com/docs/guides/auth/row-level-security

-- Enable RLS on tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

-- User Profiles Table Policies
-- Users can only read and write their own profile data
CREATE POLICY "Users can view own profile"
ON user_profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
USING (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
ON user_profiles FOR DELETE
USING (auth.uid() = id);

-- Groups Table Policies
-- Authenticated users can read and write groups (existing functionality)
CREATE POLICY "Authenticated users can view groups"
ON groups FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert groups"
ON groups FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update groups"
ON groups FOR UPDATE
USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete groups"
ON groups FOR DELETE
USING (auth.role() = 'authenticated');

-- Additional security considerations:
-- 1. Only authenticated users can access any data
-- 2. Users can only access their own profile data
-- 3. Group access can be further restricted based on membership if needed

-- Example table schemas (adjust based on your actual data models):

-- CREATE TABLE user_profiles (
--   id UUID REFERENCES auth.users PRIMARY KEY,
--   first_name TEXT NOT NULL,
--   last_name TEXT,
--   age INTEGER,
--   dob DATE,
--   height REAL,
--   weight REAL,
--   last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );

-- CREATE TABLE groups (
--   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
--   name TEXT NOT NULL,
--   members TEXT[] DEFAULT '{}',
--   created_by UUID REFERENCES auth.users,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );