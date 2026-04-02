-- TWO-343: Update live Supabase relay_messages — clean recovery language
-- Run this in the Supabase SQL editor at https://supabase.com/dashboard/project/wfckqpnxnzzwbgbthtsb/sql
-- 5 messages found with "craving", "cravings", "white-knuckling", "quitting"

BEGIN;

-- Day 1: "craving" → "urge"
UPDATE relay_messages
SET text = 'The hardest part wasn''t the urge. It was the empty space where the habit used to be. I didn''t know what to do with my hands.'
WHERE id = '0791a5a6-d058-4243-8377-94e2aff984df';

-- Day 60: "cravings" → "the pull"
UPDATE relay_messages
SET text = 'The pull doesn''t disappear at two months. It just gets quieter and shorter. You''ll barely notice when it stops.'
WHERE id = '90270987-31ab-49f1-8cb1-546807d8d42e';

-- Day 90: "white-knuckling" → "holding on"
UPDATE relay_messages
SET text = 'I spent the first 90 days holding on. Around here, I stopped needing to. That freedom is coming for you.'
WHERE id = '9c062a36-52fb-4870-ab48-c9d43ce7becb';

-- Day 120: "craving" → "pull"
UPDATE relay_messages
SET text = 'The hard part at four months isn''t the pull. It''s the boredom. Learning to sit in ordinary time. But ordinary starts to feel good.'
WHERE id = 'd0a2d8d5-ed61-419e-8039-5a9c38cf379c';

-- Day 150: "quitting" → "working on it"
UPDATE relay_messages
SET text = 'Five months in, the identity shifted. I stopped being someone who was working on it and started being someone who just is. That shift is permanent.'
WHERE id = 'aeea5c7f-4010-49ca-b5d1-5e4c3857ab1e';

COMMIT;

-- Verify: should return 0 rows
SELECT id, target_day, text FROM relay_messages
WHERE text ILIKE '%crav%'
   OR text ILIKE '%physical illness%'
   OR text ILIKE '%white-knuckl%'
   OR text ILIKE '%quitting%'
   OR text ILIKE '%sober%'
   OR text ILIKE '%relapse%'
   OR text ILIKE '%withdrawal%';
