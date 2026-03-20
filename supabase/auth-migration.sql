-- STACK Auth Migration: user_data table
-- Run this in Supabase SQL Editor AFTER enabling Apple provider in Auth settings.

-- Table for syncing user chapters + relay history to server
CREATE TABLE IF NOT EXISTS user_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  chapters JSONB NOT NULL DEFAULT '[]',
  received_relay_days INTEGER[] DEFAULT '{}',
  written_relay_days INTEGER[] DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_user UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE user_data ENABLE ROW LEVEL SECURITY;

-- Users can only read their own row
CREATE POLICY "users_read_own_data" ON user_data
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own row
CREATE POLICY "users_insert_own_data" ON user_data
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own row
CREATE POLICY "users_update_own_data" ON user_data
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own row
CREATE POLICY "users_delete_own_data" ON user_data
  FOR DELETE
  USING (auth.uid() = user_id);

-- Auto-update updated_at on changes
CREATE OR REPLACE FUNCTION update_user_data_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_user_data_updated_at
  BEFORE UPDATE ON user_data
  FOR EACH ROW
  EXECUTE FUNCTION update_user_data_timestamp();
