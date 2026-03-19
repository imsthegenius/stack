-- STACK — migrate relay_messages from v1 to v2
-- Run in Supabase SQL Editor AFTER backing up existing data.
-- This preserves the milestone_days column (deprecated) so old app versions don't crash.

-- Step 1: Add new columns
ALTER TABLE relay_messages ADD COLUMN IF NOT EXISTS target_day INTEGER;
ALTER TABLE relay_messages ADD COLUMN IF NOT EXISTS writer_day INTEGER;
ALTER TABLE relay_messages ADD COLUMN IF NOT EXISTS is_seed BOOLEAN DEFAULT false;
ALTER TABLE relay_messages ADD COLUMN IF NOT EXISTS flagged_at TIMESTAMPTZ;

-- Step 2: Migrate existing data (all existing messages are seeds)
UPDATE relay_messages SET
  target_day = milestone_days,
  writer_day = milestone_days,
  is_seed = true
WHERE target_day IS NULL;

-- Step 3: Make columns NOT NULL after migration
ALTER TABLE relay_messages ALTER COLUMN target_day SET NOT NULL;
ALTER TABLE relay_messages ALTER COLUMN writer_day SET NOT NULL;

-- Step 4: Add new indexes
CREATE INDEX IF NOT EXISTS idx_relay_target_active ON relay_messages(target_day, is_active);
CREATE INDEX IF NOT EXISTS idx_relay_writer ON relay_messages(writer_day);
CREATE INDEX IF NOT EXISTS idx_relay_flagged ON relay_messages(is_active, report_count);

-- Step 5: Add constraints (only on new rows — existing data may not satisfy writer > target for seeds)
-- These are enforced at the application level for now.

-- Step 6: Keep milestone_days column alive (deprecated, DO NOT DROP)
-- Old app versions query milestone_days=eq.X — dropping it would crash them.
-- Drop in v1.2+ after force-update.

-- Step 7: Create relay_points config table
CREATE TABLE IF NOT EXISTS relay_points (
  target_day          INTEGER PRIMARY KEY,
  writer_day          INTEGER NOT NULL,
  label               TEXT NOT NULL,
  presentation        TEXT NOT NULL,
  is_free             BOOLEAN DEFAULT false,
  is_milestone        BOOLEAN DEFAULT false,
  write_prompt        TEXT NOT NULL,
  write_placeholder   TEXT NOT NULL
);

-- Insert relay points (upsert to be idempotent)
INSERT INTO relay_points VALUES
(1,    7,    'Day 1',          'inline',     true,  true,  'Someone is on Day 1 right now. The very first day. What do you remember about yours?', 'What was Day 1 like?'),
(2,    7,    'Day 2',          'inline',     true,  false, 'Someone just finished Day 2. Still very early. What was that like for you?', 'What do you remember about the second day?'),
(3,    14,   'Day 3',          'inline',     true,  false, 'Write something for someone on Day 3. They''ve been at this for three days.', 'What would you tell someone on Day 3?'),
(4,    14,   'Day 4',          'inline',     true,  false, 'Someone is on Day 4. The middle of the first week. What would you tell them?', 'What was the middle of the first week like?'),
(5,    14,   'Day 5',          'inline',     true,  false, 'Write something for someone on Day 5. Almost through the first week.', 'What do you remember about Day 5?'),
(6,    14,   'Day 6',          'inline',     true,  false, 'Someone is on Day 6. Tomorrow is a full week. What do you remember about this point?', 'The day before a full week. What was that like?'),
(7,    30,   'One Week',       'fullscreen', false, true,  'Someone just hit one week. Write something for them.', 'What do you remember about the first week?'),
(10,   30,   'Day 10',         'inline',     false, false, 'Write something for someone on Day 10. Their first double-digit day.', 'What was it like hitting double digits?'),
(14,   30,   'Two Weeks',      'fullscreen', false, false, 'Someone just finished two weeks. What was that stretch like for you?', 'What would you tell someone at two weeks?'),
(21,   60,   'Three Weeks',    'inline',     false, false, 'Write something for someone at three weeks.', 'What do you remember about three weeks in?'),
(30,   90,   'One Month',      'fullscreen', false, true,  'Someone just hit one month. What would you want them to know?', 'What would you tell someone at one month?'),
(45,   90,   '45 Days',        'inline',     false, false, 'Write something for someone at 45 days. They''re between milestones.', 'What was it like between one month and two?'),
(60,   180,  'Two Months',     'fullscreen', false, true,  'Someone just reached two months. Write something for them.', 'What do you remember about two months?'),
(90,   180,  'Three Months',   'fullscreen', false, true,  'Write something for someone at three months. The first big number.', 'What was three months like?'),
(120,  270,  'Four Months',    'inline',     false, false, 'Someone is at four months. Write something for them.', 'What do you remember about four months in?'),
(150,  365,  'Five Months',    'inline',     false, false, 'Write something for someone at five months. They''re halfway to a year.', 'What was it like halfway to a year?'),
(180,  365,  'Six Months',     'fullscreen', false, true,  'Someone just hit six months. What do you remember about that point?', 'What do you remember about six months?'),
(270,  365,  'Nine Months',    'fullscreen', false, true,  'Write something for someone at nine months.', 'What was nine months like?'),
(365,  730,  'One Year',       'fullscreen', false, true,  'Someone just hit one year. You''ve been there. What would you tell them?', 'What would you tell someone at one year?'),
(500,  1000, '500 Days',       'fullscreen', false, false, 'Write something for someone at 500 days.', 'What do you remember about 500 days?'),
(730,  1825, 'Two Years',      'fullscreen', false, true,  'Someone just hit two years. Write something for them.', 'What would you tell someone at two years?'),
(1000, 1825, 'The Comma Club', 'fullscreen', false, true,  'Write something for someone at 1000 days. The Comma Club.', 'What would you tell someone at 1000 days?'),
(1825, 3650, 'Five Years',     'fullscreen', false, true,  'Someone just reached five years. Write something for them.', 'What would you tell someone at five years?'),
(3650, 7300, 'Ten Years',      'fullscreen', false, true,  'Write something for someone at ten years.', 'What would you tell someone at ten years?'),
(7300, 7300, 'Twenty Years',   'fullscreen', false, true,  'You''re one of the longest-standing people in STACK. Write something for someone behind you.', 'What would you say to someone on this path?')
ON CONFLICT (target_day) DO NOTHING;

-- Step 8: Update RLS (policies are idempotent — drop and recreate if they exist)
-- The existing anon_read and anon_insert policies still work for the new columns.

-- Step 9: Update report function to include flagged_at
CREATE OR REPLACE FUNCTION report_relay_message(message_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE relay_messages
  SET report_count = report_count + 1,
      is_active = CASE WHEN report_count + 1 >= 3 THEN false ELSE is_active END,
      flagged_at = CASE WHEN report_count + 1 >= 3 THEN now() ELSE flagged_at END
  WHERE id = message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
