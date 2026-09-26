-- ============================================================
-- STEP 1: Create vocabulary_books junction table
-- Safe to run — does NOT modify existing tables
-- ============================================================

CREATE TABLE public.vocabulary_books (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  vocab_id uuid NOT NULL,
  book_id integer NOT NULL,
  lesson_number integer,
  CONSTRAINT vocabulary_books_pkey PRIMARY KEY (id),
  CONSTRAINT vocabulary_books_vocab_id_fkey FOREIGN KEY (vocab_id) REFERENCES public.vocabulary(id) ON DELETE CASCADE,
  CONSTRAINT vocabulary_books_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE,
  CONSTRAINT vocabulary_books_unique UNIQUE (vocab_id, book_id)
);

-- Index for fast lookups by book
CREATE INDEX idx_vocabulary_books_book_id ON public.vocabulary_books(book_id);

-- Index for fast lookups by vocab
CREATE INDEX idx_vocabulary_books_vocab_id ON public.vocabulary_books(vocab_id);

-- Index for lesson range queries (most common filter pattern)
CREATE INDEX idx_vocabulary_books_book_lesson ON public.vocabulary_books(book_id, lesson_number);

-- RLS: public read, authenticated write (same as vocabulary)
ALTER TABLE public.vocabulary_books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access" ON public.vocabulary_books
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert" ON public.vocabulary_books
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update" ON public.vocabulary_books
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete" ON public.vocabulary_books
  FOR DELETE USING (auth.role() = 'authenticated');
