-- Enhanced Supabase Database Schema
-- Includes automatic profile creation, weight tracking, and analytics support
-- Run this in Supabase SQL Editor or via migration

-- Enhanced User Profiles Table
-- Replaces Firestore 'userProfiles' collection with analytics support
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  first_name TEXT NOT NULL DEFAULT '',
  last_name TEXT,
  age INTEGER,
  dob DATE,
  height REAL, -- in cm
  weight REAL, -- in kg, current weight
  initial_weight REAL, -- starting weight for progress tracking
  goal_weight REAL, -- target weight
  goal_type TEXT CHECK (goal_type IN ('lose_weight', 'gain_weight', 'maintain_weight', 'build_muscle')) DEFAULT 'maintain_weight',
  activity_level TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')) DEFAULT 'moderate',
  profile_completed BOOLEAN DEFAULT FALSE, -- tracks if onboarding is complete
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Weight History Table for Analytics
-- Tracks weight changes over time for progress analysis
CREATE TABLE weight_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  weight REAL NOT NULL, -- weight in kg
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT, -- optional user notes about the weigh-in
  source TEXT DEFAULT 'manual' -- manual, smart_scale, estimated, etc.
);

-- Measurement History Table (for comprehensive tracking)
-- Tracks body measurements over time
CREATE TABLE measurement_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  measurement_type TEXT NOT NULL, -- 'weight', 'body_fat', 'muscle_mass', 'waist', 'chest', etc.
  value REAL NOT NULL,
  unit TEXT NOT NULL, -- kg, cm, %, etc.
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT
);

-- Groups Table (unchanged)
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
CREATE INDEX idx_user_profiles_profile_completed ON user_profiles(profile_completed);
CREATE INDEX idx_weight_history_user_id ON weight_history(user_id);
CREATE INDEX idx_weight_history_recorded_at ON weight_history(recorded_at DESC);
CREATE INDEX idx_measurement_history_user_id ON measurement_history(user_id);
CREATE INDEX idx_measurement_history_type_date ON measurement_history(user_id, measurement_type, recorded_at DESC);
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

-- Create trigger to automatically create user profile on signup
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (
    id,
    first_name,
    last_name,
    created_at
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically add weight history when weight changes
CREATE OR REPLACE FUNCTION track_weight_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Only track if weight actually changed and is not null
  IF NEW.weight IS NOT NULL AND (OLD.weight IS NULL OR NEW.weight != OLD.weight) THEN
    INSERT INTO weight_history (user_id, weight, recorded_at, source)
    VALUES (NEW.id, NEW.weight, NOW(), 'profile_update');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER create_profile_on_signup
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_profile();

CREATE TRIGGER update_groups_updated_at
  BEFORE UPDATE ON groups
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_last_updated
  BEFORE UPDATE ON user_profiles  
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER track_profile_weight_changes
  AFTER UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION track_weight_change();

-- Enhanced views for analytics
CREATE VIEW user_profiles_analytics AS
SELECT 
  p.id,
  p.first_name,
  p.last_name,
  CONCAT(p.first_name, ' ', COALESCE(p.last_name, '')) as full_name,
  p.age,
  p.dob,
  p.height,
  p.weight as current_weight,
  p.initial_weight,
  p.goal_weight,
  p.goal_type,
  p.activity_level,
  p.profile_completed,
  -- Calculate BMI
  CASE 
    WHEN p.height > 0 AND p.weight > 0 THEN 
      ROUND((p.weight / ((p.height/100) * (p.height/100)))::numeric, 2)
    ELSE NULL 
  END as current_bmi,
  -- Calculate progress
  CASE 
    WHEN p.initial_weight IS NOT NULL AND p.weight IS NOT NULL THEN
      ROUND((p.weight - p.initial_weight)::numeric, 2)
    ELSE NULL
  END as weight_change,
  -- Calculate goal progress percentage
  CASE 
    WHEN p.initial_weight IS NOT NULL AND p.goal_weight IS NOT NULL AND p.weight IS NOT NULL THEN
      ROUND(((p.initial_weight - p.weight) / (p.initial_weight - p.goal_weight) * 100)::numeric, 1)
    ELSE NULL
  END as goal_progress_percent,
  -- Get latest weight entry date
  (SELECT MAX(recorded_at) FROM weight_history WHERE user_id = p.id) as last_weigh_in,
  -- Count total weight entries
  (SELECT COUNT(*) FROM weight_history WHERE user_id = p.id) as total_weigh_ins,
  p.last_updated,
  p.created_at
FROM user_profiles p;

-- Weight progress view for charts and analytics
CREATE VIEW weight_progress_view AS
SELECT 
  wh.user_id,
  wh.weight,
  wh.recorded_at,
  wh.notes,
  wh.source,
  p.goal_weight,
  p.initial_weight,
  -- Calculate days since start
  EXTRACT(DAYS FROM (wh.recorded_at - p.created_at)) as days_since_start,
  -- Calculate weight difference from initial
  CASE 
    WHEN p.initial_weight IS NOT NULL THEN
      ROUND((wh.weight - p.initial_weight)::numeric, 2)
    ELSE NULL
  END as weight_change_from_start,
  -- Calculate BMI for this weight entry
  CASE 
    WHEN p.height > 0 AND wh.weight > 0 THEN 
      ROUND((wh.weight / ((p.height/100) * (p.height/100)))::numeric, 2)
    ELSE NULL 
  END as bmi_at_time
FROM weight_history wh
JOIN user_profiles p ON wh.user_id = p.id
ORDER BY wh.user_id, wh.recorded_at DESC;

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON user_profiles TO authenticated;
GRANT ALL ON weight_history TO authenticated;
GRANT ALL ON measurement_history TO authenticated;
GRANT ALL ON groups TO authenticated;
GRANT SELECT ON user_profiles_analytics TO authenticated;
GRANT SELECT ON weight_progress_view TO authenticated;

-- Row Level Security (RLS) Policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE weight_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE measurement_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;

-- Users can only see/edit their own profiles
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- Users can only see/edit their own weight history
CREATE POLICY "Users can view own weight history" ON weight_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own weight history" ON weight_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own weight history" ON weight_history
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can only see/edit their own measurement history
CREATE POLICY "Users can view own measurements" ON measurement_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own measurements" ON measurement_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own measurements" ON measurement_history
  FOR UPDATE USING (auth.uid() = user_id);

-- Groups policies (members can view, creators can edit)
CREATE POLICY "Users can view groups they belong to" ON groups
  FOR SELECT USING (
    auth.uid()::text = ANY(members) OR 
    auth.uid() = created_by
  );

CREATE POLICY "Users can create groups" ON groups
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group creators can update their groups" ON groups
  FOR UPDATE USING (auth.uid() = created_by);

-- Useful functions for analytics
CREATE OR REPLACE FUNCTION get_user_weight_trend(user_uuid UUID, days_back INTEGER DEFAULT 30)
RETURNS TABLE(
  recorded_date DATE,
  weight REAL,
  weight_change REAL,
  trend_direction TEXT
) AS $$
BEGIN
  RETURN QUERY
  WITH weight_data AS (
    SELECT 
      wh.recorded_at::DATE as recorded_date,
      wh.weight,
      LAG(wh.weight) OVER (ORDER BY wh.recorded_at) as prev_weight
    FROM weight_history wh
    WHERE wh.user_id = user_uuid
      AND wh.recorded_at >= NOW() - INTERVAL '1 day' * days_back
    ORDER BY wh.recorded_at
  )
  SELECT 
    wd.recorded_date,
    wd.weight,
    CASE 
      WHEN wd.prev_weight IS NOT NULL THEN 
        ROUND((wd.weight - wd.prev_weight)::numeric, 2)
      ELSE NULL
    END as weight_change,
    CASE 
      WHEN wd.prev_weight IS NULL THEN 'baseline'
      WHEN wd.weight > wd.prev_weight THEN 'up'
      WHEN wd.weight < wd.prev_weight THEN 'down'
      ELSE 'stable'
    END as trend_direction
  FROM weight_data wd;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get weight statistics
CREATE OR REPLACE FUNCTION get_user_weight_stats(user_uuid UUID)
RETURNS TABLE(
  current_weight REAL,
  initial_weight REAL,
  goal_weight REAL,
  total_change REAL,
  goal_progress_percent REAL,
  avg_weekly_change REAL,
  days_tracking INTEGER,
  total_entries INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.weight as current_weight,
    p.initial_weight,
    p.goal_weight,
    CASE 
      WHEN p.initial_weight IS NOT NULL AND p.weight IS NOT NULL THEN
        ROUND((p.weight - p.initial_weight)::numeric, 2)
      ELSE NULL
    END as total_change,
    CASE 
      WHEN p.initial_weight IS NOT NULL AND p.goal_weight IS NOT NULL AND p.weight IS NOT NULL THEN
        ROUND(((p.initial_weight - p.weight) / (p.initial_weight - p.goal_weight) * 100)::numeric, 1)
      ELSE NULL
    END as goal_progress_percent,
    CASE 
      WHEN p.created_at IS NOT NULL AND p.weight IS NOT NULL AND p.initial_weight IS NOT NULL THEN
        ROUND(((p.weight - p.initial_weight) / GREATEST(EXTRACT(DAYS FROM (NOW() - p.created_at)) / 7, 1))::numeric, 3)
      ELSE NULL
    END as avg_weekly_change,
    EXTRACT(DAYS FROM (NOW() - p.created_at))::INTEGER as days_tracking,
    (SELECT COUNT(*) FROM weight_history WHERE user_id = user_uuid)::INTEGER as total_entries
  FROM user_profiles p
  WHERE p.id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
