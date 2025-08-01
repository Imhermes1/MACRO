-- Supabase Database Schema
-- Replaces Firestore collections with PostgreSQL tables
-- Run this in Supabase SQL Editor or via migration

-- User Profiles Table
-- Replaces Firestore 'userProfiles' collection
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT,
  age INTEGER,
  dob DATE,
  height REAL,
  weight REAL,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Groups Table  
-- Replaces Firestore 'groups' collection
CREATE TABLE groups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  members TEXT[] DEFAULT '{}',
  created_by UUID REFERENCES auth.users ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_user_profiles_id ON user_profiles(id);
CREATE INDEX idx_groups_created_by ON groups(created_by);
CREATE INDEX idx_groups_members ON groups USING GIN(members);

-- Create trigger to update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_groups_updated_at
    BEFORE UPDATE ON groups
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create trigger to update user_profiles last_updated timestamp
CREATE TRIGGER update_user_profiles_last_updated
    BEFORE UPDATE ON user_profiles  
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Optional: Create a view for user profiles with additional computed fields
CREATE VIEW user_profiles_view AS
SELECT 
  id,
  first_name,
  last_name,
  CONCAT(first_name, ' ', COALESCE(last_name, '')) as full_name,
  age,
  dob,
  height,
  weight,
  -- Calculate BMI if height and weight are available
  CASE 
    WHEN height > 0 AND weight > 0 THEN 
      ROUND((weight / ((height/100) * (height/100)))::numeric, 2)
    ELSE NULL 
  END as bmi,
  last_updated,
  created_at
FROM user_profiles;

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON user_profiles TO authenticated;
GRANT ALL ON groups TO authenticated;
GRANT SELECT ON user_profiles_view TO authenticated;

-- Insert sample data (optional - remove in production)
-- INSERT INTO user_profiles (id, first_name, last_name, age, height, weight)
-- VALUES 
--   (gen_random_uuid(), 'John', 'Doe', 30, 175.0, 70.0),
--   (gen_random_uuid(), 'Jane', 'Smith', 25, 165.0, 60.0);

-- Security note: RLS policies should be applied separately via supabase_policies.sql