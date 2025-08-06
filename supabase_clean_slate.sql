-- Clean Slate Script (ONLY run if you want to start over)
-- WARNING: This will delete all existing nutrition data!

-- Drop existing tables (in correct order due to dependencies)
DROP VIEW IF EXISTS daily_nutrition_summary;
DROP TABLE IF EXISTS nutrition_entries CASCADE;
DROP TABLE IF EXISTS australian_foods CASCADE;
DROP TABLE IF EXISTS nutrition_goals CASCADE;

-- Drop function
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

-- Now you can run your full schema again
