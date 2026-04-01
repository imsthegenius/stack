-- STACK — relay_messages seed patch v3
-- Rewrites 6 messages to remove recovery/addiction language for App Store compliance.
-- Run in production Supabase SQL editor.

UPDATE relay_messages
SET text = 'The first week, my body pushed back. Everything felt off. That eased.'
WHERE target_day = 7
  AND text = 'The first week felt like a physical illness. It was.'
  AND is_seed = true;

UPDATE relay_messages
SET text = 'The social stuff was harder than I expected. Finding reasons not to go, then going anyway, then standing there.'
WHERE target_day = 30
  AND text = 'The social stuff was harder than the cravings. Finding reasons not to go, then going anyway, then standing there.'
  AND is_seed = true;

UPDATE relay_messages
SET text = 'The pull doesn''t disappear. It just gets quieter and shorter.'
WHERE target_day = 60
  AND text = 'The cravings don''t disappear. They just get quieter and shorter.'
  AND is_seed = true;

UPDATE relay_messages
SET text = 'I spent the first 90 days holding on. Around here I stopped needing to.'
WHERE target_day = 90
  AND text = 'I spent the first 90 days white-knuckling it. Around here I stopped needing to.'
  AND is_seed = true;

UPDATE relay_messages
SET text = 'The hard part at four months was the boredom. Learning to sit in ordinary time.'
WHERE target_day = 120
  AND text = 'The hard part at four months isn''t the cravings. It''s the boredom. Learning to sit in ordinary time.'
  AND is_seed = true;

UPDATE relay_messages
SET text = 'Five months in and the identity thing started to shift. I stopped being someone who was working on it and started being someone who just is.'
WHERE target_day = 150
  AND text = 'Five months in and the identity thing started to shift. I stopped being someone who was quitting and started being someone who just doesn''t.'
  AND is_seed = true;
