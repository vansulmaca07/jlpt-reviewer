-- ============================================================
-- STEP 6: Add the N3 "耳から覚える" vocabulary book
-- Safe to re-run: the book is inserted only if it does not exist.
-- ============================================================

BEGIN;

-- Reset the sequence only if the target database already has rows.
-- This prevents duplicate key errors when inserting a new book record.
SELECT setval('books_id_seq', (SELECT COALESCE(MAX(id), 1) FROM public.books));

INSERT INTO public.books (book_name, jlpt_level_id)
SELECT '耳から覚える', jl.id
FROM public.jlpt_levels jl
WHERE jl.level = 'N3'
  AND NOT EXISTS (
    SELECT 1
    FROM public.books b
    WHERE b.book_name = '耳から覚える'
  );

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.books b
    JOIN public.jlpt_levels jl ON jl.id = b.jlpt_level_id
    WHERE b.book_name = '耳から覚える'
      AND jl.level = 'N3'
  ) THEN
    RAISE EXCEPTION 'Could not add 耳から覚える: JLPT level N3 was not found';
  END IF;
END $$;

COMMIT;

-- ============================================================
-- 耳から覚える N3 - Chapter 1
-- Duplicate words reuse the existing vocabulary row and receive
-- a separate link to this book through vocabulary_books.
-- ============================================================

DO $$
DECLARE
  v_book_id      INTEGER;
  v_n3_level_id  INTEGER;
  v_noun_type_id INTEGER;
  v_chapter      INTEGER := 1;
BEGIN
  SELECT id INTO v_book_id
  FROM public.books
  WHERE book_name = '耳から覚える'
  LIMIT 1;

  SELECT id INTO v_n3_level_id
  FROM public.jlpt_levels
  WHERE level = 'N3'
  LIMIT 1;

  SELECT id INTO v_noun_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%noun%'
     OR type_name LIKE '%名詞%'
  ORDER BY id
  LIMIT 1;

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run the book insert first.';
  END IF;

  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 not found in jlpt_levels.';
  END IF;

  IF v_noun_type_id IS NULL THEN
    RAISE EXCEPTION 'Noun not found in word_types.';
  END IF;

  -- Insert only words that do not exist yet.
  INSERT INTO public.vocabulary (
    word,
    reading,
    meaning,
    word_type_id,
    jlpt_level_id
  )
  SELECT
    data.word,
    data.reading,
    data.meaning,
    v_noun_type_id,
    v_n3_level_id
  FROM (VALUES
    ('男性', 'だんせい', 'man, male'),
    ('女性', 'じょせい', 'woman, female'),
    ('高齢', 'こうれい', 'old age, advanced age'),
    ('年上', 'としうえ', 'older, senior in age'),
    ('目上', 'めうえ', 'superior, senior'),
    ('先輩', 'せんぱい', 'senior, mentor'),
    ('後輩', 'こうはい', 'junior')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  -- Link both newly inserted and pre-existing words to Chapter 1.
  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, v_chapter
  FROM public.vocabulary v
  WHERE v.word IN ('男性', '女性', '高齢', '年上', '目上', '先輩', '後輩')
  ON CONFLICT (vocab_id, book_id) DO NOTHING;

  -- Add three examples per word without duplicating existing sentences.
  INSERT INTO public.example_sentences (
    vocab_id,
    japanese_sentence,
    english_translation
  )
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('男性', 'あの男性は私の日本語の先生です。', 'That man is my Japanese teacher.'),
    ('男性', '男性の参加者は十人でした。', 'There were ten male participants.'),
    ('男性', '理想の男性と結婚したいと思っています。', 'I hope to marry my ideal man.'),
    ('女性', 'あの女性はだれですか。', 'Who is that woman?'),
    ('女性', '女性の社員が増えています。', 'The number of female employees is increasing.'),
    ('女性', '女性も働きやすい会社を目指しています。', 'The company aims to be a workplace where women can work comfortably.'),
    ('高齢', '祖母は高齢だが、まだとても元気です。', 'My grandmother is elderly, but she is still very healthy.'),
    ('高齢', '高齢の方に席を譲りました。', 'I gave my seat to an elderly person.'),
    ('高齢', '日本では高齢化が進んでいます。', 'The population is aging in Japan.'),
    ('年上', '兄は私より三つ年上です。', 'My older brother is three years older than I am.'),
    ('年上', '年上の友達と旅行に行きました。', 'I went on a trip with an older friend.'),
    ('年上', '彼女は夫より二歳年上です。', 'She is two years older than her husband.'),
    ('目上', '目上の人には敬語で話したほうがいいです。', 'You should use polite language when speaking to your superiors.'),
    ('目上', '目上の人を呼び捨てにしてはいけません。', 'You should not address a superior without an honorific.'),
    ('目上', '彼は目上の人にも自分の意見をはっきり言います。', 'He clearly expresses his opinion even to his superiors.'),
    ('先輩', '田中さんは私の高校の先輩です。', 'Tanaka is my senior from high school.'),
    ('先輩', '先輩に仕事のやり方を教えてもらいました。', 'A senior colleague taught me how to do the job.'),
    ('先輩', '困ったときは先輩に相談します。', 'I consult my senior when I have a problem.'),
    ('後輩', '後輩に日本語を教えています。', 'I teach Japanese to my junior.'),
    ('後輩', '彼は大学の後輩です。', 'He is my junior from university.'),
    ('後輩', '先輩と後輩が一緒に練習しました。', 'The seniors and juniors practiced together.')
  ) AS examples(word, japanese_sentence, english_translation)
  JOIN public.vocabulary v ON v.word = examples.word
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.example_sentences existing
    WHERE existing.vocab_id = v.id
      AND existing.japanese_sentence = examples.japanese_sentence
  );
END $$;

-- Verify the Chapter 1 words and their example counts.
SELECT
  v.word,
  v.reading,
  wt.type_name,
  vb.lesson_number AS chapter_number,
  COUNT(es.id) AS example_count
FROM public.vocabulary v
JOIN public.vocabulary_books vb ON vb.vocab_id = v.id
JOIN public.books b ON b.id = vb.book_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
LEFT JOIN public.example_sentences es ON es.vocab_id = v.id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 1
  AND v.word IN ('男性', '女性', '高齢', '年上', '目上', '先輩', '後輩')
GROUP BY v.word, v.reading, wt.type_name, vb.lesson_number
ORDER BY v.word;