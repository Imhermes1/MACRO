-- Nutrition Data Tables for Supabase
-- Add these tables to your existing Supabase database

-- Function to automatically update the 'updated_at' timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Nutrition Entries Table
-- Stores user's food log entries
CREATE TABLE IF NOT EXISTS nutrition_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  food_name TEXT NOT NULL,
  calories REAL NOT NULL DEFAULT 0,
  protein REAL NOT NULL DEFAULT 0,
  carbs REAL NOT NULL DEFAULT 0,
  fat REAL NOT NULL DEFAULT 0,
  fiber REAL,
  sugar REAL,
  sodium REAL,
  confidence REAL NOT NULL DEFAULT 1.0,
  source TEXT NOT NULL DEFAULT 'manual',
  barcode TEXT,
  serving_size TEXT,
  serving_unit TEXT,
  meal_type TEXT DEFAULT 'other',
  quantity REAL NOT NULL DEFAULT 1.0,
  input_method TEXT DEFAULT 'text',
  logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Australian Food Database Cache Table
-- Caches Australian food database entries for quick lookup
CREATE TABLE IF NOT EXISTS australian_foods (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  public_food_key TEXT UNIQUE NOT NULL,
  food_name TEXT NOT NULL,
  food_description TEXT,
  classification_name TEXT,
  calories REAL,
  protein REAL,
  carbs REAL,
  fat REAL,
  fiber REAL,
  sugar REAL,
  sodium REAL,
  search_terms TEXT[], -- For efficient searching
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Nutrition Goals Table
-- Stores personalized nutrition goals
CREATE TABLE IF NOT EXISTS nutrition_goals (
  user_id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  daily_calories REAL NOT NULL DEFAULT 2000,
  protein_grams REAL NOT NULL DEFAULT 150,
  carbs_grams REAL NOT NULL DEFAULT 250,
  fat_grams REAL NOT NULL DEFAULT 65,
  weight_goal TEXT DEFAULT 'maintain',
  activity_level TEXT DEFAULT 'moderate',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_nutrition_entries_user_id ON nutrition_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_entries_logged_at ON nutrition_entries(logged_at);
CREATE INDEX IF NOT EXISTS idx_nutrition_entries_user_date ON nutrition_entries(user_id, logged_at);
CREATE INDEX IF NOT EXISTS idx_australian_foods_key ON australian_foods(public_food_key);
CREATE INDEX IF NOT EXISTS idx_australian_foods_search ON australian_foods USING GIN(search_terms);
CREATE INDEX IF NOT EXISTS idx_nutrition_goals_user ON nutrition_goals(user_id);

-- Enable RLS
ALTER TABLE nutrition_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE australian_foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_goals ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Nutrition Entries
DROP POLICY IF EXISTS "Users can view own nutrition entries" ON nutrition_entries;
CREATE POLICY "Users can view own nutrition entries"
ON nutrition_entries FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own nutrition entries" ON nutrition_entries;
CREATE POLICY "Users can insert own nutrition entries"
ON nutrition_entries FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own nutrition entries" ON nutrition_entries;
CREATE POLICY "Users can update own nutrition entries"
ON nutrition_entries FOR UPDATE
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own nutrition entries" ON nutrition_entries;
CREATE POLICY "Users can delete own nutrition entries"
ON nutrition_entries FOR DELETE
USING (auth.uid() = user_id);

-- RLS Policies for Australian Foods (read-only for all authenticated users)
DROP POLICY IF EXISTS "Authenticated users can view australian foods" ON australian_foods;
CREATE POLICY "Authenticated users can view australian foods"
ON australian_foods FOR SELECT
USING (auth.role() = 'authenticated');

-- RLS Policies for Nutrition Goals
DROP POLICY IF EXISTS "Users can view own nutrition goals" ON nutrition_goals;
CREATE POLICY "Users can view own nutrition goals"
ON nutrition_goals FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own nutrition goals" ON nutrition_goals;
CREATE POLICY "Users can insert own nutrition goals"
ON nutrition_goals FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own nutrition goals" ON nutrition_goals;
CREATE POLICY "Users can update own nutrition goals"
ON nutrition_goals FOR UPDATE
USING (auth.uid() = user_id);

-- Trigger to update timestamps
DROP TRIGGER IF EXISTS update_nutrition_goals_updated_at ON nutrition_goals;
CREATE TRIGGER update_nutrition_goals_updated_at
    BEFORE UPDATE ON nutrition_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create views for easier querying
CREATE OR REPLACE VIEW daily_nutrition_summary AS
SELECT 
  user_id,
  DATE(logged_at) as log_date,
  COUNT(*) as entry_count,
  SUM(calories * quantity) as total_calories,
  SUM(protein * quantity) as total_protein,
  SUM(carbs * quantity) as total_carbs,
  SUM(fat * quantity) as total_fat,
  AVG(confidence) as avg_confidence
FROM nutrition_entries
GROUP BY user_id, DATE(logged_at);

GRANT SELECT ON daily_nutrition_summary TO authenticated;
