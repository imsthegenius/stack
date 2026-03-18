-- STACK — relay_messages seed data
-- Real-toned messages from people who reached each milestone.
-- Run after schema.sql in Supabase SQL Editor.

-- Day 1
INSERT INTO relay_messages (milestone_days, text) VALUES
(1, 'I didn''t sleep. I just waited for morning. Morning came.'),
(1, 'The first few hours felt like a physical thing. Restless, itchy, wrong. That''s normal apparently.'),
(1, 'I had no idea what to do with myself after 8pm. I still don''t. But I made it to midnight.'),
(1, 'I kept picking up my phone expecting something to change. Nothing changed. I went to bed anyway.');

-- Day 7
INSERT INTO relay_messages (milestone_days, text) VALUES
(7, 'The first week felt like a physical illness. It was.'),
(7, 'I didn''t know what to do with my hands for seven days. That passed.'),
(7, 'I slept worse every night until about day five. Then I slept better than I had in years.'),
(7, 'I told nobody. Carried it alone the whole week. That was fine. It still counted.');

-- Day 30
INSERT INTO relay_messages (milestone_days, text) VALUES
(30, 'The social stuff was harder than the cravings. Finding reasons not to go, then going anyway, then standing there sober.'),
(30, 'I stopped waiting to feel like a different person. I''m the same person. Just without the thing.'),
(30, 'The first month I tracked every single day. Checked the counter constantly. That obsession faded.'),
(30, 'Someone asked why I wasn''t drinking. I said I just wasn''t. They moved on. That was it.');

-- Day 60
INSERT INTO relay_messages (milestone_days, text) VALUES
(60, 'Two months felt like crossing some invisible line. Nothing dramatic. Just two months.'),
(60, 'I started noticing things I''d stopped noticing. Early mornings. What I actually wanted to eat.'),
(60, 'The cravings don''t disappear. They just get quieter and shorter.');

-- Day 90
INSERT INTO relay_messages (milestone_days, text) VALUES
(90, 'Three months was the first goal I set. When I got here I set another one.'),
(90, 'I spent the first 90 days white-knuckling it. Around here I stopped needing to.'),
(90, 'My thinking got cleaner. I didn''t notice until I looked back and couldn''t remember the last time I''d spiraled.'),
(90, 'Someone who knew me before told me I seemed different. I didn''t explain. I just said thanks.');

-- Day 180
INSERT INTO relay_messages (milestone_days, text) VALUES
(180, 'Six months in and I stopped framing it as a fight. It stopped feeling like one.'),
(180, 'I forgot to check my count for two weeks. When I remembered, it had been six months. That felt right.'),
(180, 'The version of me that needed this is still in there. I just don''t hand it the wheel anymore.');

-- Day 270
INSERT INTO relay_messages (milestone_days, text) VALUES
(270, 'Nine months. Nobody in my life tracks this the way I do. That''s fine.'),
(270, 'I used to think I''d feel proud by now. I just feel like myself. That turned out to be enough.');

-- Day 365
INSERT INTO relay_messages (milestone_days, text) VALUES
(365, 'I used to think a year sober would feel different. It feels exactly like this.'),
(365, 'Nobody noticed. That was the hardest part at first. Now it''s fine.'),
(365, 'A year ago I couldn''t picture today. Today looks a lot like yesterday. That''s not a bad thing.'),
(365, 'I kept waiting for the part where it got easy. It didn''t get easy. I just got used to it.'),
(365, 'I stopped tracking the days for a while. Then I checked and it had been a year. I sat with that for a minute.');

-- Day 730
INSERT INTO relay_messages (milestone_days, text) VALUES
(730, 'Two years. I barely think about it anymore. That used to feel impossible to imagine.'),
(730, 'I''ve had bad stretches in year two. They passed. Without it, they still passed.'),
(730, 'The people who knew me before treat me the same. The people I met after don''t know there''s a before. Both things are fine.');

-- Day 1000
INSERT INTO relay_messages (milestone_days, text) VALUES
(1000, '1000 days. There''s something about a number with three zeros. I''m not sure what, but I felt it.'),
(1000, 'A thousand days of choosing the same thing, over and over, in every possible mood and season. That''s what it is.'),
(1000, 'I remember day one. I remember day seven. I don''t remember most of the days in between. That means they were ordinary. Ordinary was the goal.');

-- Day 1825 (5 years)
INSERT INTO relay_messages (milestone_days, text) VALUES
(1825, 'Five years. My memory of who I was before is starting to blur a little. I''m not sure how I feel about that.'),
(1825, 'I''ve watched people start and stop around me. I didn''t say anything unless they asked. Sometimes they asked.');

-- Day 3650 (10 years)
INSERT INTO relay_messages (milestone_days, text) VALUES
(3650, 'Ten years. I have kids now who have never seen me drink. That''s strange to think about.'),
(3650, 'A decade is long enough that it''s just part of who I am. Not a thing I''m doing. Just a thing that''s true.');

-- Day 7300 (20 years)
INSERT INTO relay_messages (milestone_days, text) VALUES
(7300, 'Twenty years. I''m a different person than the one who started this. I''m also exactly the same. Both things are true and neither one is the point.');
