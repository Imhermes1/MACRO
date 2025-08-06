-- Verification Script for Existing Nutrition Tables
-- Run this to check what's already set up in your Supabase database

-- Check if tables exist and their structure
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name IN ('nutrition_entries', 'australian_foods', 'nutrition_goals')
ORDER BY table_name, ordinal_position;

-- Check if RLS is enabled
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('nutrition_entries', 'australian_foods', 'nutrition_goals');

-- Check existing policies
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd as operation
FROM pg_policies 
WHERE tablename IN ('nutrition_entries', 'australian_foods', 'nutrition_goals');

-- Check if indexes exist
SELECT 
  schemaname,
  tablename,
  indexname
FROM pg_indexes 
WHERE tablename IN ('nutrition_entries', 'australian_foods', 'nutrition_goals');

-- Check if the view exists
SELECT 
  table_name,
  view_definition
FROM information_schema.views 
WHERE table_name = 'daily_nutrition_summary';

-- Check if update function exists
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines 
WHERE routine_name = 'update_updated_at_column';
