-- STACK — relay_messages v2 seed data
-- ~97 messages across 25 relay points. All behavior-agnostic.
-- Run after schema.sql (fresh install) or migrate-v1-to-v2.sql (existing DB).

-- ============================================================
-- Day 1 (5 seeds)
-- Voice: Raw, present-tense, physical. 1-3 sentences max.
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(1, 7, 'I didn''t sleep. I just waited for morning. Morning came.', true),
(1, 7, 'The first few hours felt like a physical thing. Restless, itchy, wrong. That''s normal.', true),
(1, 7, 'I had no idea what to do with myself after 8pm. I still don''t. But I made it to midnight.', true),
(1, 7, 'I kept picking up my phone expecting something to change. Nothing changed. I went to bed anyway.', true),
(1, 7, 'I told myself just today. Just get through today. That was enough.', true);

-- ============================================================
-- Day 2 (5 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(2, 7, 'Second day. I slept strange. Not bad, just different. Like my body knew something had changed.', true),
(2, 7, 'I kept reaching for it without thinking. Like a phantom limb. Then I''d remember and put my hand down.', true),
(2, 7, 'The first day had this energy to it. The second day was just... a day. That was actually harder.', true),
(2, 7, 'I noticed how loud everything was. The house, my thoughts, the evening. It used to be quieter.', true),
(2, 7, 'Two days. Nobody knows but me. That felt strange and also kind of powerful.', true);

-- ============================================================
-- Day 3 (5 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(3, 14, 'By day three the novelty of it was gone. It was just me and the hours.', true),
(3, 14, 'I told myself I''d take it one day at a time. Three felt like a lot of days at once.', true),
(3, 14, 'I woke up and for a second forgot I was doing this. Then I remembered. That moment was the hardest part of the day.', true),
(3, 14, 'Three days in and I started cleaning things. Drawers, counters. I think my hands just needed something to do.', true),
(3, 14, 'I almost broke today. I didn''t. That''s the whole story.', true);

-- ============================================================
-- Day 4 (5 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(4, 14, 'Day four. The middle of the first week. I stopped thinking about it every minute. Now it''s every ten minutes.', true),
(4, 14, 'I ate dinner slowly for the first time in I don''t know how long. That was unexpected.', true),
(4, 14, 'Someone asked if I was okay. I said yes. I wasn''t sure if it was true but I said it anyway.', true),
(4, 14, 'Four days. I keep doing math in my head. That''s almost a hundred hours. That''s something.', true),
(4, 14, 'I went for a walk just to get out of the house. Walked for an hour. Came back. Felt different.', true);

-- ============================================================
-- Day 5 (5 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(5, 14, 'Five days in and I started noticing the evenings. They''re longer now. I don''t know what to do with them yet.', true),
(5, 14, 'I almost didn''t open this today. Then I did. That''s all it took.', true),
(5, 14, 'The weekend was different this time. I just sat with it. Didn''t love it. Didn''t hate it.', true),
(5, 14, 'Five days. I keep looking at the number like it''s going to tell me something. It doesn''t. But it''s there.', true),
(5, 14, 'I slept through the night for the first time. Woke up surprised.', true);

-- ============================================================
-- Day 6 (5 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(6, 14, 'Tomorrow is a week. I kept thinking about that all day. Not because it matters. Just because I can see it.', true),
(6, 14, 'Six days. Nothing looks different from the outside. Everything feels different from the inside.', true),
(6, 14, 'I had a moment today where I forgot about it entirely. For maybe twenty minutes. That was new.', true),
(6, 14, 'Someone was doing the thing in front of me. I watched them the way you watch traffic. It just moved past.', true),
(6, 14, 'Almost a week. I didn''t think I could do almost a week. I was wrong about that.', true);

-- ============================================================
-- Day 7 — One Week (5 seeds)
-- Voice: Noticing, adjusting. 2-4 sentences.
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(7, 30, 'The first week, my body pushed back. Everything felt off. That eased.', true),
(7, 30, 'I didn''t know what to do with my hands for seven days. That passed.', true),
(7, 30, 'I slept worse every night until about day five. Then I slept better than I had in years.', true),
(7, 30, 'I told nobody. Carried it alone the whole week. That was fine. It still counted.', true),
(7, 30, 'Seven days. I thought it would feel like an achievement. It just felt like seven days. That was enough.', true);

-- ============================================================
-- Day 10 (3 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(10, 30, 'Double digits. I looked at the number and felt something I didn''t expect. Not pride exactly. More like surprise.', true),
(10, 30, 'Ten days in and the routine started to feel like a routine. That''s when it got a little easier.', true),
(10, 30, 'I stopped counting hours and started counting days. That shift happened around here.', true);

-- ============================================================
-- Day 14 — Two Weeks (5 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(14, 30, 'Two weeks felt like crossing something. Not a finish line. Just a point where I stopped counting every single day.', true),
(14, 30, 'I had my first real test around here. Someone offered. I said no. It was surprisingly easy. Then I went home and it wasn''t.', true),
(14, 30, 'The second week was quieter than the first. Less drama. More just... being in it.', true),
(14, 30, 'I noticed I was starting to trust myself a little. Not a lot. Just a little. That was new.', true),
(14, 30, 'Two weeks. The initial willpower faded. Something else took its place. I don''t have a word for it.', true);

-- ============================================================
-- Day 21 — Three Weeks (3 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(21, 60, 'Three weeks. The folk wisdom says this is when habits form. I don''t know about that. But I''m still here.', true),
(21, 60, 'Around here I stopped needing a reason. It just became what I do now.', true),
(21, 60, 'I had a bad day at three weeks. A genuinely bad day. And I got through it without the thing. That meant something.', true);

-- ============================================================
-- Day 30 — One Month (4 seeds, existing retagged + fixed)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(30, 90, 'The social stuff was harder than I expected. Finding reasons not to go, then going anyway, then standing there.', true),
(30, 90, 'I stopped waiting to feel like a different person. I''m the same person. Just without the thing.', true),
(30, 90, 'The first month I tracked every single day. Checked the counter constantly. That obsession faded.', true),
(30, 90, 'Someone asked why I wasn''t. I said I just wasn''t. They moved on. That was it.', true);

-- ============================================================
-- Day 45 (3 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(45, 90, 'Forty-five days. No milestone. No badge. Just the middle of the stretch. That''s where most of it happens.', true),
(45, 90, 'I hit a wall around here. The excitement was gone. The habit wasn''t solid yet. Just this flat stretch of doing it anyway.', true),
(45, 90, 'Between one month and two months there''s nothing to celebrate. You just keep going. That''s what I did.', true);

-- ============================================================
-- Day 60 — Two Months (3 seeds, existing retagged)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(60, 180, 'Two months felt like crossing some invisible line. Nothing dramatic. Just two months.', true),
(60, 180, 'I started noticing things I''d stopped noticing. Early mornings. What I actually wanted to eat.', true),
(60, 180, 'The pull doesn''t disappear. It just gets quieter and shorter.', true);

-- ============================================================
-- Day 90 — Three Months (4 seeds, existing retagged)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(90, 180, 'Three months was the first goal I set. When I got here I set another one.', true),
(90, 180, 'I spent the first 90 days holding on. Around here I stopped needing to.', true),
(90, 180, 'My thinking got cleaner. I didn''t notice until I looked back and couldn''t remember the last time I''d spiraled.', true),
(90, 180, 'Someone who knew me before told me I seemed different. I didn''t explain. I just said thanks.', true);

-- ============================================================
-- Day 120 — Four Months (3 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(120, 270, 'Four months. I started forgetting to check the counter. When I did check, the number surprised me.', true),
(120, 270, 'The hard part at four months was the boredom. Learning to sit in ordinary time.', true),
(120, 270, 'I looked at someone struggling with it and remembered what that felt like. I didn''t say anything. I just remembered.', true);

-- ============================================================
-- Day 150 — Five Months (3 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(150, 365, 'Halfway to a year. I did the math and sat with it for a minute.', true),
(150, 365, 'Five months in and the identity thing started to shift. I stopped being someone who was working on it and started being someone who just is.', true),
(150, 365, 'I had a dream about it around here. Woke up guilty. Then relieved. Then annoyed that I was still thinking about it.', true);

-- ============================================================
-- Day 180 — Six Months (3 seeds, existing retagged)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(180, 365, 'Six months in and I stopped framing it as a fight. It stopped feeling like one.', true),
(180, 365, 'I forgot to check my count for two weeks. When I remembered, it had been six months. That felt right.', true),
(180, 365, 'The version of me that needed this is still in there. I just don''t hand it the wheel anymore.', true);

-- ============================================================
-- Day 270 — Nine Months (2 seeds, existing retagged)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(270, 365, 'Nine months. Nobody in my life tracks this the way I do. That''s fine.', true),
(270, 365, 'I used to think I''d feel proud by now. I just feel like myself. That turned out to be enough.', true),
(270, 365, 'Nine months. Long enough that it''s not a project anymore. It''s just how things are.', true);

-- ============================================================
-- Day 365 — One Year (5 seeds, existing retagged)
-- Voice: Quiet perspective. 2-4 sentences.
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(365, 730, 'I used to think a year would feel different. It feels exactly like this.', true),
(365, 730, 'Nobody noticed. That was the hardest part at first. Now it''s fine.', true),
(365, 730, 'A year ago I couldn''t picture today. Today looks a lot like yesterday. That''s not a bad thing.', true),
(365, 730, 'I kept waiting for the part where it got easy. It didn''t get easy. I just got used to it.', true),
(365, 730, 'I stopped tracking the days for a while. Then I checked and it had been a year. I sat with that for a minute.', true);

-- ============================================================
-- Day 500 (3 seeds)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(500, 1000, '500 days. The number is big enough now that it almost doesn''t feel like mine.', true),
(500, 1000, 'Somewhere between a year and two years the thing stopped being a thing. It just... stopped.', true),
(500, 1000, 'I don''t think about it most days. When I do, it''s more like remembering a place I used to live.', true);

-- ============================================================
-- Day 730 — Two Years (3 seeds, existing retagged)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(730, 1825, 'Two years. I barely think about it anymore. That used to feel impossible to imagine.', true),
(730, 1825, 'I''ve had bad stretches in year two. They passed. Without it, they still passed.', true),
(730, 1825, 'The people who knew me before treat me the same. The people I met after don''t know there''s a before. Both things are fine.', true);

-- ============================================================
-- Day 1000 — The Comma Club (3 seeds, existing retagged)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(1000, 1825, '1000 days. There''s something about a number with three zeros. I''m not sure what, but I felt it.', true),
(1000, 1825, 'A thousand days of choosing the same thing, over and over, in every possible mood and season. That''s what it is.', true),
(1000, 1825, 'I remember day one. I remember day seven. I don''t remember most of the days in between. That means they were ordinary. Ordinary was the goal.', true);

-- ============================================================
-- Day 1825 — Five Years (3 seeds, existing + 1 new)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(1825, 3650, 'Five years. My memory of who I was before is starting to blur a little. I''m not sure how I feel about that.', true),
(1825, 3650, 'I''ve watched people start and stop around me. I didn''t say anything unless they asked. Sometimes they asked.', true),
(1825, 3650, 'Five years is long enough that I stopped measuring. It''s just part of who I am now.', true);

-- ============================================================
-- Day 3650 — Ten Years (3 seeds, existing fixed + 1 new)
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(3650, 7300, 'Ten years. I have kids now who have never seen me do the thing. That''s strange to think about.', true),
(3650, 7300, 'A decade is long enough that it''s just part of who I am. Not a thing I''m doing. Just a thing that''s true.', true),
(3650, 7300, 'I almost forgot this anniversary. That felt like the most honest measure of how far I''ve come.', true);

-- ============================================================
-- Day 7300 — Twenty Years (2 seeds, existing + 1 new)
-- Voice: Sparse, almost offhand.
-- ============================================================
INSERT INTO relay_messages (target_day, writer_day, text, is_seed) VALUES
(7300, 7300, 'Twenty years. I''m a different person than the one who started this. I''m also exactly the same. Both things are true and neither one is the point.', true),
(7300, 7300, 'Twenty years. It''s been so long that I don''t think of it as a streak. It''s just my life.', true);
