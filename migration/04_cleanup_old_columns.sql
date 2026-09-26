-- ============================================================
-- STEP 4: (OPTIONAL — run only AFTER all code is fully migrated)
-- Remove old columns from vocabulary table
-- DO NOT RUN until the app is 100% using vocabulary_books
-- ============================================================

-- Make book_id nullable first (safety step)
ALTER TABLE public.vocabulary ALTER COLUMN book_id DROP NOT NULL;

-- Eventually drop the columns:
-- ALTER TABLE public.vocabulary DROP COLUMN book_id;
-- ALTER TABLE public.vocabulary DROP COLUMN lesson_number;

-- NOTE: Only run the DROP statements after you've confirmed:
-- 1. All app code uses vocabulary_books for book/lesson data
-- 2. No queries reference vocabulary.book_id or vocabulary.lesson_number
-- 3. You've tested thoroughly on staging/local
