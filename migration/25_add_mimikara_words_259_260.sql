-- ============================================================
-- 耳から覚える N3 - Words 259-260
-- Lesson L13 continuation = words 259-260.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_adjective_type_id INTEGER;
BEGIN
  SELECT id INTO v_book_id
  FROM public.books
  WHERE book_name = '耳から覚える'
  LIMIT 1;

  SELECT id INTO v_n3_level_id
  FROM public.jlpt_levels
  WHERE level = 'N3'
  LIMIT 1;

  SELECT id INTO v_adjective_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%adjective%'
     OR type_name LIKE '%形容詞%'
  ORDER BY id
  LIMIT 1;

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run migrations 06-10 first.';
  END IF;
  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 not found in jlpt_levels.';
  END IF;
  IF v_adjective_type_id IS NULL THEN
    RAISE EXCEPTION 'Adjective not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT data.word, data.reading, data.meaning, v_adjective_type_id, v_n3_level_id
  FROM (VALUES
    ('幸せな', 'しあわせな', 'happy; fortunate', 'な-adjective'),
    ('得意な', 'とくいな', 'good at; proud; smug', 'な-adjective')
  ) AS data(word, reading, meaning, adjective_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 13
  FROM public.vocabulary v
  WHERE v.word IN ('幸せな', '得意な')
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('幸せな', '幸せな人生を送る。', 'Live a happy life.'),
    ('得意な', '彼女はギター、作文、料理などが得意だ。', 'She is good at guitar, writing, cooking, and so on.')
  ) AS examples(word, japanese_sentence, english_translation)
  JOIN public.vocabulary v ON v.word = examples.word
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.example_sentences existing
    WHERE existing.vocab_id = v.id
      AND existing.japanese_sentence = examples.japanese_sentence
  );
END $$;

COMMIT;

-- Verification: L13 must contain 20 entries: 18 nouns and 2 adjectives.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%noun%'
       OR wt.type_name LIKE '%名詞%'
  ) AS noun_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%adjective%'
       OR wt.type_name LIKE '%形容詞%'
  ) AS adjective_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%noun%'
          OR wt.type_name LIKE '%名詞%'
     ) = 18
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%adjective%'
          OR wt.type_name LIKE '%形容詞%'
     ) = 2
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 13
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN ('幸せな', '得意な')
ORDER BY word;
