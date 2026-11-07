-- ============================================================
-- 耳から覚える N3 - Words 421-440
-- Lesson L22 = words 421-440.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

ALTER TABLE public.vocabulary
  ADD COLUMN IF NOT EXISTS verb_group TEXT;

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_verb_type_id INTEGER;
BEGIN
  SELECT id INTO v_book_id
  FROM public.books
  WHERE book_name = '耳から覚える'
  LIMIT 1;

  SELECT id INTO v_n3_level_id
  FROM public.jlpt_levels
  WHERE level = 'N3'
  LIMIT 1;

  SELECT id INTO v_verb_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%verb%'
     OR type_name LIKE '%動詞%'
  ORDER BY id
  LIMIT 1;

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run migrations 06-10 first.';
  END IF;
  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 not found in jlpt_levels.';
  END IF;
  IF v_verb_type_id IS NULL THEN
    RAISE EXCEPTION 'Verb not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id, verb_group)
  SELECT data.word, data.reading, data.meaning, v_verb_type_id, v_n3_level_id, data.verb_group
  FROM (VALUES
    ('当たる', 'あたる', 'be hit; prove true; win', 'Group 1 (Godan)'),
    ('当てる', 'あてる', 'hit; get right; expose to', 'Group 2 (Ichidan)'),
    ('比べる', 'くらべる', 'compare', 'Group 2 (Ichidan)'),
    ('似合う', 'にあう', 'look good on; suit; match', 'Group 1 (Godan)'),
    ('似る', 'にる', 'resemble', 'Group 2 (Ichidan)'),
    ('似せる', 'にせる', 'imitate', 'Group 2 (Ichidan)'),
    ('分かれる', 'わかれる', 'be divided; split up', 'Group 2 (Ichidan)'),
    ('分ける', 'わける', 'divide; share; distribute', 'Group 2 (Ichidan)'),
    ('足す', 'たす', 'add', 'Group 1 (Godan)'),
    ('引く', 'ひく', 'pull; subtract; draw', 'Group 1 (Godan)'),
    ('増える', 'ふえる', 'increase', 'Group 2 (Ichidan)'),
    ('増やす', 'ふやす', 'increase; add to', 'Group 1 (Godan)'),
    ('減る', 'へる', 'decrease', 'Group 1 (Godan)'),
    ('減らす', 'へらす', 'decrease; reduce', 'Group 1 (Godan)'),
    ('変わる', 'かわる', 'change', 'Group 1 (Godan)'),
    ('変える', 'かえる', 'change; alter', 'Group 2 (Ichidan)'),
    ('替わる', 'かわる', 'change; substitute; replace', 'Group 1 (Godan)'),
    ('替える', 'かえる', 'change; replace; exchange', 'Group 2 (Ichidan)'),
    ('返る', 'かえる', 'return; come back', 'Group 1 (Godan)'),
    ('返す', 'かえす', 'return; give back', 'Group 1 (Godan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 22
  FROM public.vocabulary v
  WHERE v.word IN (
    '当たる', '当てる', '比べる', '似合う', '似る', '似せる', '分かれる', '分ける', '足す', '引く',
    '増える', '増やす', '減る', '減らす', '変わる', '変える', '替わる', '替える', '返る', '返す'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('当たる', 'ボールが当たって窓ガラスが割れた。', 'The ball hit the window and broke the glass.'),
    ('当てる', '相手選手のボールが速いので、ラケットに当てるのも大変だ。', 'The opposing player''s ball is fast, so it is difficult even to hit it with the racket.'),
    ('比べる', '東京と大阪の面積を比べる。', 'Compare the areas of Tokyo and Osaka.'),
    ('似合う', '彼女は着物がよく似合う。', 'A kimono suits her well.'),
    ('似る', '彼女は弟とよく似ている。', 'She closely resembles her younger brother.'),
    ('似せる', 'アイドルに髪型を似せる。', 'Imitate the idol''s hairstyle.'),
    ('分かれる', 'トイレは、男性用と女性用に分かれている。', 'The toilets are divided into men''s and women''s.'),
    ('分ける', '財産を3人の子どもに分ける。', 'Divide the property among the three children.'),
    ('足す', '味が薄かったので塩を足した。', 'The flavor was weak, so I added salt.'),
    ('引く', 'このドアは押すのではなく、引いて開けるんです。', 'This door is opened by pulling, not pushing.'),
    ('増える', '貯金、体重、人口などが増える。', 'Savings, weight, population, and so on increase.'),
    ('増やす', '貯金、体重、人口などを増やす。', 'Increase savings, weight, population, and so on.'),
    ('減る', '貯金、体重、人口などが減る。', 'Savings, weight, population, and so on decrease.'),
    ('減らす', '貯金、体重、人口などを減らす。', 'Decrease savings, weight, population, and so on.'),
    ('変わる', '季節、時代、場所、法律、性格などが変わる。', 'Seasons, eras, places, laws, personalities, and so on change.'),
    ('変える', '髪型、時間、場所、法律などを変える。', 'Change a hairstyle, time, place, law, and so on.'),
    ('替わる', '4月に店長が替わった。', 'The store manager changed in April.'),
    ('替える', '古くなった電球を新しいのと替えた。', 'I replaced the old light bulb with a new one.'),
    ('返る', '友だちに貸したお金が返ってきた。', 'The money I lent my friend came back.'),
    ('返す', 'この本は2週間以内に図書館に返さなければならない。', 'This book must be returned to the library within two weeks.')
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

-- Verification: L22 must contain exactly 20 verbs, all with a verb group.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NOT NULL) AS grouped_word_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NOT NULL) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 22
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  '当たる', '当てる', '比べる', '似合う', '似る', '似せる', '分かれる', '分ける', '足す', '引く',
  '増える', '増やす', '減る', '減らす', '変わる', '変える', '替わる', '替える', '返る', '返す'
)
ORDER BY word;
