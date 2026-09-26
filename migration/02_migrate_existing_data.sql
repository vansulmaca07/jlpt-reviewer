-- ============================================================
-- STEP 2: Migrate existing data into vocabulary_books
-- This copies book_id + lesson_number from vocabulary into
-- the new junction table. SAFE — does not delete or modify
-- existing vocabulary rows.
-- ============================================================

-- Insert one row per vocabulary entry into the junction table
INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
SELECT id, book_id, lesson_number
FROM public.vocabulary
WHERE book_id IS NOT NULL
ON CONFLICT (vocab_id, book_id) DO NOTHING;

-- ============================================================
-- VERIFY: Run this after the insert to confirm row counts match
-- ============================================================

-- Should return the same count:
-- SELECT COUNT(*) FROM vocabulary WHERE book_id IS NOT NULL;
-- SELECT COUNT(*) FROM vocabulary_books;
