-- ============================================================
-- STEP 3: Add new books (run AFTER code is updated to use junction table)
-- Example: Adding Genki textbooks
-- ============================================================

-- First, check existing books:
-- SELECT * FROM books ORDER BY id;

-- Fix sequence to match existing data (prevents duplicate key error)
SELECT setval('books_id_seq', (SELECT MAX(id) FROM books));

-- Add Genki books (adjust jlpt_level_id based on your jlpt_levels table)
-- Assuming: jlpt_levels id=1 is N5, id=2 is N4

INSERT INTO public.books (book_name, jlpt_level_id) VALUES
  ('Genki I', 1),   -- N5
  ('Genki II', 2);  -- N4

-- NOTE: After adding books, you can link existing vocabulary to them:
-- Example: Link 食べる (which exists in both Minna and Genki) to Genki I
--
-- INSERT INTO vocabulary_books (vocab_id, book_id, lesson_number)
-- SELECT v.id, (SELECT id FROM books WHERE book_name = 'Genki I'), 14
-- FROM vocabulary v WHERE v.word = '食べる'
-- ON CONFLICT (vocab_id, book_id) DO NOTHING;
