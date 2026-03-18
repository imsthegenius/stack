-- STACK — relay_messages schema
-- Run in Supabase SQL Editor: https://app.supabase.com → SQL Editor
-- Project: https://wfckqpnxnzzwbgbthtsb.supabase.co

CREATE TABLE relay_messages (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  milestone_days INTEGER NOT NULL,
  text          TEXT NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT now(),
  is_active     BOOLEAN DEFAULT true,
  report_count  INTEGER DEFAULT 0
);

CREATE INDEX idx_relay_milestone ON relay_messages(milestone_days, is_active);

ALTER TABLE relay_messages ENABLE ROW LEVEL SECURITY;

-- Anyone can read active messages (anonymous read)
CREATE POLICY "anon_read" ON relay_messages
  FOR SELECT USING (is_active = true);

-- Anyone can submit their relay message
CREATE POLICY "anon_insert" ON relay_messages
  FOR INSERT WITH CHECK (true);

-- Report function: auto-hides messages with 3+ reports
CREATE OR REPLACE FUNCTION report_relay_message(message_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE relay_messages
  SET report_count = report_count + 1,
      is_active = CASE WHEN report_count + 1 >= 3 THEN false ELSE is_active END
  WHERE id = message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
