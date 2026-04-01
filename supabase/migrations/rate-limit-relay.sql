-- TWO-83: Rate limiting on relay message submissions
-- Run in Supabase SQL editor after schema.sql

-- Step 1: Add user_id column to track who wrote each message
ALTER TABLE relay_messages
  ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE INDEX idx_relay_user ON relay_messages(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_relay_user_created ON relay_messages(user_id, created_at) WHERE user_id IS NOT NULL;

-- Step 2: Unique constraint — max 1 message per user per target_day
CREATE UNIQUE INDEX idx_relay_one_per_user_per_day
  ON relay_messages(user_id, target_day)
  WHERE user_id IS NOT NULL AND is_seed = false;

-- Step 3: Rate limit trigger — max 5 messages per user per 24 hours
CREATE OR REPLACE FUNCTION check_relay_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
  -- Skip seed messages
  IF NEW.is_seed = true THEN
    RETURN NEW;
  END IF;

  -- Require authenticated user
  IF NEW.user_id IS NULL THEN
    RAISE EXCEPTION 'AUTHENTICATION_REQUIRED'
      USING HINT = 'You must be signed in to submit a relay message.';
  END IF;

  -- Check 24-hour rate limit
  IF (
    SELECT COUNT(*)
    FROM relay_messages
    WHERE user_id = NEW.user_id
      AND is_seed = false
      AND created_at > now() - interval '24 hours'
  ) >= 5 THEN
    RAISE EXCEPTION 'RATE_LIMIT_EXCEEDED'
      USING HINT = 'You can submit up to 5 relay messages per day. Try again tomorrow.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_relay_rate_limit
  BEFORE INSERT ON relay_messages
  FOR EACH ROW
  EXECUTE FUNCTION check_relay_rate_limit();

-- Step 4: Tighten RLS — replace wide-open insert with authenticated-only
DROP POLICY IF EXISTS "anon_insert" ON relay_messages;

CREATE POLICY "auth_insert_own" ON relay_messages
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Step 5: RPC function for clean error handling from the client
CREATE OR REPLACE FUNCTION submit_relay_message(
  p_text TEXT,
  p_target_day INTEGER,
  p_writer_day INTEGER
)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RETURN json_build_object('ok', false, 'error', 'AUTHENTICATION_REQUIRED');
  END IF;

  -- Validate text length
  IF char_length(p_text) < 10 OR char_length(p_text) > 500 THEN
    RETURN json_build_object('ok', false, 'error', 'INVALID_TEXT_LENGTH');
  END IF;

  -- Validate target_day
  IF p_target_day <= 0 THEN
    RETURN json_build_object('ok', false, 'error', 'INVALID_TARGET_DAY');
  END IF;

  -- Validate writer_day > target_day for non-seed
  IF p_writer_day <= p_target_day THEN
    RETURN json_build_object('ok', false, 'error', 'INVALID_WRITER_DAY');
  END IF;

  -- Attempt insert (trigger handles rate limit, unique index handles duplicates)
  BEGIN
    INSERT INTO relay_messages (target_day, writer_day, text, is_seed, user_id)
    VALUES (p_target_day, p_writer_day, p_text, false, v_user_id);
  EXCEPTION
    WHEN unique_violation THEN
      RETURN json_build_object('ok', false, 'error', 'DUPLICATE_TARGET_DAY');
    WHEN OTHERS THEN
      IF SQLERRM = 'RATE_LIMIT_EXCEEDED' THEN
        RETURN json_build_object('ok', false, 'error', 'RATE_LIMIT_EXCEEDED');
      END IF;
      RETURN json_build_object('ok', false, 'error', SQLERRM);
  END;

  RETURN json_build_object('ok', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only authenticated users can call this function
REVOKE EXECUTE ON FUNCTION submit_relay_message FROM anon;
GRANT EXECUTE ON FUNCTION submit_relay_message TO authenticated;
