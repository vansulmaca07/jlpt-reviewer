-- ============================================================
-- Migration 28: SRS (Anki-style, FSRS algorithm) tables
-- Run this in Supabase SQL Editor.
-- SAFE TO RE-RUN. Independent of vocabulary uploads (only references vocabulary.id).
-- ============================================================

-- ------------------------------------------------------------
-- 1. SRS CARDS: scheduling state per user per word (mirrors ts-fsrs Card)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.srs_cards (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vocab_id UUID NOT NULL REFERENCES public.vocabulary(id) ON DELETE CASCADE,
  state SMALLINT NOT NULL DEFAULT 0 CHECK (state BETWEEN 0 AND 3), -- 0 New, 1 Learning, 2 Review, 3 Relearning
  due TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  stability DOUBLE PRECISION NOT NULL DEFAULT 0,
  difficulty DOUBLE PRECISION NOT NULL DEFAULT 0,
  elapsed_days INT NOT NULL DEFAULT 0,
  scheduled_days INT NOT NULL DEFAULT 0,
  learning_steps INT NOT NULL DEFAULT 0,
  reps INT NOT NULL DEFAULT 0,
  lapses INT NOT NULL DEFAULT 0,
  last_review TIMESTAMPTZ,
  first_rating SMALLINT CHECK (first_rating BETWEEN 1 AND 4), -- used to count "truly new" words per day
  suspended BOOLEAN NOT NULL DEFAULT FALSE, -- "Known – don't show"
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, vocab_id)
);

CREATE INDEX IF NOT EXISTS idx_srs_cards_user_due ON public.srs_cards(user_id, due) WHERE suspended = FALSE;
CREATE INDEX IF NOT EXISTS idx_srs_cards_user_created ON public.srs_cards(user_id, created_at);

ALTER TABLE public.srs_cards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own srs cards" ON public.srs_cards;
DROP POLICY IF EXISTS "Users can insert own srs cards" ON public.srs_cards;
DROP POLICY IF EXISTS "Users can update own srs cards" ON public.srs_cards;
DROP POLICY IF EXISTS "Users can delete own srs cards" ON public.srs_cards;

CREATE POLICY "Users can view own srs cards"
  ON public.srs_cards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own srs cards"
  ON public.srs_cards FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own srs cards"
  ON public.srs_cards FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own srs cards"
  ON public.srs_cards FOR DELETE USING (auth.uid() = user_id);


-- ------------------------------------------------------------
-- 2. SRS REVIEW LOGS: every rating (needed later for FSRS parameter optimization)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.srs_review_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vocab_id UUID NOT NULL REFERENCES public.vocabulary(id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 4), -- 1 Again, 2 Hard, 3 Good, 4 Easy
  state SMALLINT NOT NULL CHECK (state BETWEEN 0 AND 3), -- card state BEFORE this review
  due TIMESTAMPTZ NOT NULL,
  stability DOUBLE PRECISION NOT NULL,
  difficulty DOUBLE PRECISION NOT NULL,
  elapsed_days INT NOT NULL DEFAULT 0,
  last_elapsed_days INT NOT NULL DEFAULT 0,
  scheduled_days INT NOT NULL DEFAULT 0,
  learning_steps INT NOT NULL DEFAULT 0,
  review TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  duration_ms INT
);

CREATE INDEX IF NOT EXISTS idx_srs_logs_user_review ON public.srs_review_logs(user_id, review DESC);
CREATE INDEX IF NOT EXISTS idx_srs_logs_user_vocab ON public.srs_review_logs(user_id, vocab_id);

ALTER TABLE public.srs_review_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own srs logs" ON public.srs_review_logs;
DROP POLICY IF EXISTS "Users can insert own srs logs" ON public.srs_review_logs;
DROP POLICY IF EXISTS "Users can delete own srs logs" ON public.srs_review_logs;

CREATE POLICY "Users can view own srs logs"
  ON public.srs_review_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own srs logs"
  ON public.srs_review_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own srs logs"
  ON public.srs_review_logs FOR DELETE USING (auth.uid() = user_id);


-- ------------------------------------------------------------
-- 3. SRS SETTINGS on profile (new cards/day, retention, source book + lesson range)
-- ------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS srs_settings JSONB NOT NULL DEFAULT '{}'::jsonb;


-- ------------------------------------------------------------
-- 4. Allow 'srs' as a review_sessions mode (for Stats page history)
-- ------------------------------------------------------------
ALTER TABLE public.review_sessions DROP CONSTRAINT IF EXISTS review_sessions_mode_check;
ALTER TABLE public.review_sessions ADD CONSTRAINT review_sessions_mode_check
  CHECK (mode IN ('flashcard', 'conjugation', 'multiple_choice', 'reading', 'srs'));


-- ------------------------------------------------------------
-- 5. Quick check
-- ------------------------------------------------------------
SELECT
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'srs_cards') AS srs_cards_table,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'srs_review_logs') AS srs_review_logs_table,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'srs_settings') AS profiles_srs_settings;
