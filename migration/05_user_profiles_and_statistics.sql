-- ============================================================
-- Migration 05: User Profiles & Statistics/Progress Tracking
-- Run this in Supabase SQL Editor
-- SAFE TO RE-RUN: drops and recreates everything cleanly
-- ============================================================

-- Drop everything first so this script is fully re-runnable
DROP VIEW IF EXISTS weakest_words CASCADE;
DROP VIEW IF EXISTS level_progress CASCADE;
DROP VIEW IF EXISTS words_due_for_review CASCADE;
DROP TABLE IF EXISTS grammar_mastery CASCADE;
DROP TABLE IF EXISTS word_mastery CASCADE;
DROP TABLE IF EXISTS word_attempts CASCADE;
DROP TABLE IF EXISTS daily_activity CASCADE;
DROP TABLE IF EXISTS study_streaks CASCADE;
DROP TABLE IF EXISTS review_sessions CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP FUNCTION IF EXISTS update_word_mastery(UUID, UUID, BOOLEAN);
DROP FUNCTION IF EXISTS update_daily_activity(UUID, INT, INT, BOOLEAN);
DROP FUNCTION IF EXISTS handle_new_user();
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- ============================================================
-- 1. USER PROFILES (extends Supabase auth.users)
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  current_level TEXT DEFAULT 'N5' CHECK (current_level IN ('N5', 'N4', 'N3', 'N2', 'N1')),
  study_goal_daily INT DEFAULT 20, -- target words per day
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile when a new user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop if exists to avoid duplicates
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);


-- ============================================================
-- 2. REVIEW SESSIONS (each time user starts a review)
-- ============================================================
CREATE TABLE IF NOT EXISTS review_sessions (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mode TEXT NOT NULL CHECK (mode IN ('flashcard', 'conjugation', 'multiple_choice', 'reading')),
  jlpt_level TEXT,
  book_id INT REFERENCES books(id) ON DELETE SET NULL,
  lesson_from INT,
  lesson_to INT,
  total_cards INT DEFAULT 0,
  correct_count INT DEFAULT 0,
  wrong_count INT DEFAULT 0,
  skipped_count INT DEFAULT 0,
  duration_seconds INT,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_review_sessions_user ON review_sessions(user_id);
CREATE INDEX idx_review_sessions_user_mode ON review_sessions(user_id, mode);
CREATE INDEX idx_review_sessions_started ON review_sessions(started_at DESC);

-- RLS
ALTER TABLE review_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions"
  ON review_sessions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions"
  ON review_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions"
  ON review_sessions FOR UPDATE USING (auth.uid() = user_id);


-- ============================================================
-- 3. WORD ATTEMPTS (per-word result in each session)
-- ============================================================
CREATE TABLE IF NOT EXISTS word_attempts (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id INT REFERENCES review_sessions(id) ON DELETE CASCADE,
  vocab_id UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  mode TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  response_time_ms INT, -- how long user took to answer
  attempted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_word_attempts_user ON word_attempts(user_id);
CREATE INDEX idx_word_attempts_user_vocab ON word_attempts(user_id, vocab_id);
CREATE INDEX idx_word_attempts_session ON word_attempts(session_id);

-- RLS
ALTER TABLE word_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own attempts"
  ON word_attempts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own attempts"
  ON word_attempts FOR INSERT WITH CHECK (auth.uid() = user_id);


-- ============================================================
-- 4. WORD MASTERY (spaced repetition state per word per user)
-- ============================================================
CREATE TABLE IF NOT EXISTS word_mastery (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vocab_id UUID NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  mastery_score INT DEFAULT 0 CHECK (mastery_score >= 0 AND mastery_score <= 100),
  correct_count INT DEFAULT 0,
  wrong_count INT DEFAULT 0,
  streak INT DEFAULT 0, -- consecutive correct answers
  interval_days INT DEFAULT 1, -- current spaced repetition interval
  ease_factor REAL DEFAULT 2.5, -- SM-2 ease factor
  last_reviewed_at TIMESTAMPTZ,
  next_review_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, vocab_id)
);

CREATE INDEX idx_word_mastery_user ON word_mastery(user_id);
CREATE INDEX idx_word_mastery_user_score ON word_mastery(user_id, mastery_score);
CREATE INDEX idx_word_mastery_next_review ON word_mastery(user_id, next_review_at);

-- RLS
ALTER TABLE word_mastery ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own mastery"
  ON word_mastery FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mastery"
  ON word_mastery FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own mastery"
  ON word_mastery FOR UPDATE USING (auth.uid() = user_id);


-- ============================================================
-- 5. GRAMMAR MASTERY (track grammar exercise scores)
-- ============================================================
CREATE TABLE IF NOT EXISTS grammar_mastery (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  grammar_point_id UUID NOT NULL REFERENCES grammar_points(id) ON DELETE CASCADE,
  correct_count INT DEFAULT 0,
  wrong_count INT DEFAULT 0,
  last_score_pct INT, -- last exercise score percentage
  last_attempted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, grammar_point_id)
);

CREATE INDEX idx_grammar_mastery_user ON grammar_mastery(user_id);

-- RLS
ALTER TABLE grammar_mastery ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own grammar mastery"
  ON grammar_mastery FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own grammar mastery"
  ON grammar_mastery FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own grammar mastery"
  ON grammar_mastery FOR UPDATE USING (auth.uid() = user_id);


-- ============================================================
-- 6. DAILY ACTIVITY (for streak & heatmap)
-- ============================================================
CREATE TABLE IF NOT EXISTS daily_activity (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  activity_date DATE NOT NULL DEFAULT CURRENT_DATE,
  words_reviewed INT DEFAULT 0,
  words_correct INT DEFAULT 0,
  new_words_learned INT DEFAULT 0, -- first-time correct
  sessions_count INT DEFAULT 0,
  study_minutes INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, activity_date)
);

CREATE INDEX idx_daily_activity_user ON daily_activity(user_id);
CREATE INDEX idx_daily_activity_user_date ON daily_activity(user_id, activity_date DESC);

-- RLS
ALTER TABLE daily_activity ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own activity"
  ON daily_activity FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activity"
  ON daily_activity FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own activity"
  ON daily_activity FOR UPDATE USING (auth.uid() = user_id);


-- ============================================================
-- 7. STUDY STREAK (maintains user's current/longest streak)
-- ============================================================
CREATE TABLE IF NOT EXISTS study_streaks (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  last_study_date DATE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE study_streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own streak"
  ON study_streaks FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own streak"
  ON study_streaks FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own streak"
  ON study_streaks FOR UPDATE USING (auth.uid() = user_id);


-- ============================================================
-- 8. HELPER FUNCTION: Update mastery after an attempt
--    (call this from the app or as a trigger)
-- ============================================================
CREATE OR REPLACE FUNCTION update_word_mastery(
  p_user_id UUID,
  p_vocab_id UUID,
  p_is_correct BOOLEAN
) RETURNS VOID AS $$
DECLARE
  v_mastery word_mastery%ROWTYPE;
  v_new_streak INT;
  v_new_interval INT;
  v_new_ease REAL;
  v_new_score INT;
BEGIN
  -- Get or create mastery record
  SELECT * INTO v_mastery FROM word_mastery
    WHERE user_id = p_user_id AND vocab_id = p_vocab_id;

  IF NOT FOUND THEN
    INSERT INTO word_mastery (user_id, vocab_id, correct_count, wrong_count, streak, interval_days, ease_factor, mastery_score, last_reviewed_at, next_review_at)
    VALUES (p_user_id, p_vocab_id, 
      CASE WHEN p_is_correct THEN 1 ELSE 0 END,
      CASE WHEN p_is_correct THEN 0 ELSE 1 END,
      CASE WHEN p_is_correct THEN 1 ELSE 0 END,
      CASE WHEN p_is_correct THEN 3 ELSE 1 END,
      2.5,
      CASE WHEN p_is_correct THEN 20 ELSE 0 END,
      NOW(),
      NOW() + (CASE WHEN p_is_correct THEN 3 ELSE 1 END || ' days')::INTERVAL
    );
    RETURN;
  END IF;

  -- SM-2 inspired algorithm
  IF p_is_correct THEN
    v_new_streak := v_mastery.streak + 1;
    v_new_ease := GREATEST(1.3, v_mastery.ease_factor + 0.1);
    IF v_new_streak = 1 THEN
      v_new_interval := 1;
    ELSIF v_new_streak = 2 THEN
      v_new_interval := 3;
    ELSE
      v_new_interval := CEIL(v_mastery.interval_days * v_new_ease);
    END IF;
    -- Cap at 90 days
    v_new_interval := LEAST(v_new_interval, 90);
  ELSE
    v_new_streak := 0;
    v_new_ease := GREATEST(1.3, v_mastery.ease_factor - 0.2);
    v_new_interval := 1;
  END IF;

  -- Calculate mastery score (0-100)
  -- Based on: streak weight + accuracy weight + recency
  v_new_score := LEAST(100, GREATEST(0,
    (LEAST(v_new_streak, 5) * 12) +  -- streak contributes up to 60
    (CASE WHEN (v_mastery.correct_count + v_mastery.wrong_count + 1) > 0
      THEN ((v_mastery.correct_count + CASE WHEN p_is_correct THEN 1 ELSE 0 END)::REAL / 
            (v_mastery.correct_count + v_mastery.wrong_count + 1)::REAL * 40)
      ELSE 0 END)::INT  -- accuracy contributes up to 40
  ));

  UPDATE word_mastery SET
    correct_count = correct_count + CASE WHEN p_is_correct THEN 1 ELSE 0 END,
    wrong_count = wrong_count + CASE WHEN NOT p_is_correct THEN 1 ELSE 0 END,
    streak = v_new_streak,
    interval_days = v_new_interval,
    ease_factor = v_new_ease,
    mastery_score = v_new_score,
    last_reviewed_at = NOW(),
    next_review_at = NOW() + (v_new_interval || ' days')::INTERVAL,
    updated_at = NOW()
  WHERE user_id = p_user_id AND vocab_id = p_vocab_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- 9. HELPER FUNCTION: Update daily activity + streak
-- ============================================================
CREATE OR REPLACE FUNCTION update_daily_activity(
  p_user_id UUID,
  p_words_reviewed INT DEFAULT 1,
  p_words_correct INT DEFAULT 0,
  p_is_new_word BOOLEAN DEFAULT FALSE
) RETURNS VOID AS $$
BEGIN
  INSERT INTO daily_activity (user_id, activity_date, words_reviewed, words_correct, new_words_learned, sessions_count)
  VALUES (p_user_id, CURRENT_DATE, p_words_reviewed, p_words_correct, CASE WHEN p_is_new_word THEN 1 ELSE 0 END, 0)
  ON CONFLICT (user_id, activity_date) DO UPDATE SET
    words_reviewed = daily_activity.words_reviewed + p_words_reviewed,
    words_correct = daily_activity.words_correct + p_words_correct,
    new_words_learned = daily_activity.new_words_learned + CASE WHEN p_is_new_word THEN 1 ELSE 0 END;

  -- Update streak
  INSERT INTO study_streaks (user_id, current_streak, longest_streak, last_study_date)
  VALUES (p_user_id, 1, 1, CURRENT_DATE)
  ON CONFLICT (user_id) DO UPDATE SET
    current_streak = CASE
      WHEN study_streaks.last_study_date = CURRENT_DATE THEN study_streaks.current_streak -- same day
      WHEN study_streaks.last_study_date = CURRENT_DATE - 1 THEN study_streaks.current_streak + 1 -- consecutive
      ELSE 1 -- streak broken
    END,
    longest_streak = GREATEST(
      study_streaks.longest_streak,
      CASE
        WHEN study_streaks.last_study_date = CURRENT_DATE THEN study_streaks.current_streak
        WHEN study_streaks.last_study_date = CURRENT_DATE - 1 THEN study_streaks.current_streak + 1
        ELSE 1
      END
    ),
    last_study_date = CURRENT_DATE,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- 10. VIEWS for easy querying from the app
-- ============================================================

-- Words due for review (spaced repetition)
CREATE OR REPLACE VIEW words_due_for_review AS
SELECT 
  wm.user_id,
  wm.vocab_id,
  v.word,
  v.reading,
  v.meaning,
  wm.mastery_score,
  wm.streak,
  wm.next_review_at,
  wm.last_reviewed_at
FROM word_mastery wm
JOIN vocabulary v ON v.id = wm.vocab_id
WHERE wm.next_review_at <= NOW()
ORDER BY wm.next_review_at ASC;

-- User progress summary per JLPT level
CREATE OR REPLACE VIEW level_progress AS
SELECT
  wm.user_id,
  jl.level AS jlpt_level,
  COUNT(DISTINCT v.id) FILTER (WHERE wm.mastery_score >= 80) AS mastered_count,
  COUNT(DISTINCT v.id) FILTER (WHERE wm.mastery_score BETWEEN 20 AND 79) AS learning_count,
  COUNT(DISTINCT v.id) FILTER (WHERE wm.mastery_score < 20) AS struggling_count,
  (SELECT COUNT(*) FROM vocabulary v2 WHERE v2.jlpt_level_id = jl.id) AS total_words_in_level
FROM word_mastery wm
JOIN vocabulary v ON v.id = wm.vocab_id
JOIN jlpt_levels jl ON jl.id = v.jlpt_level_id
GROUP BY wm.user_id, jl.level, jl.id;

-- Weakest words (top mistakes)
CREATE OR REPLACE VIEW weakest_words AS
SELECT
  wm.user_id,
  wm.vocab_id,
  v.word,
  v.reading,
  v.meaning,
  jl.level AS jlpt_level,
  wm.wrong_count,
  wm.correct_count,
  ROUND(wm.wrong_count::NUMERIC / NULLIF(wm.correct_count + wm.wrong_count, 0) * 100) AS error_rate,
  wm.mastery_score,
  wm.last_reviewed_at
FROM word_mastery wm
JOIN vocabulary v ON v.id = wm.vocab_id
LEFT JOIN jlpt_levels jl ON jl.id = v.jlpt_level_id
WHERE wm.wrong_count > 0
ORDER BY error_rate DESC, wm.wrong_count DESC;
