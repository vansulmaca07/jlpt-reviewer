-- ============================================================
-- 耳から覚える N3 - Words 481-500
-- Lesson L25 = words 481-500.
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
    ('生やす', 'はやす', 'grow (a beard, etc.)', 'Group 1 (Godan)'),
    ('汚れる', 'よごれる', 'be dirty', 'Group 2 (Ichidan)'),
    ('汚す', 'よごす', 'dirty; pollute', 'Group 1 (Godan)'),
    ('壊れる', 'こわれる', 'break; be broken', 'Group 2 (Ichidan)'),
    ('壊す', 'こわす', 'break; damage', 'Group 1 (Godan)'),
    ('割れる', 'われる', 'break; split; crack', 'Group 2 (Ichidan)'),
    ('割る', 'わる', 'break; divide; crack', 'Group 1 (Godan)'),
    ('折れる', 'おれる', 'break; snap', 'Group 2 (Ichidan)'),
    ('折る', 'おる', 'break; fold', 'Group 1 (Godan)'),
    ('破れる', 'やぶれる', 'be ripped; tear', 'Group 2 (Ichidan)'),
    ('破る', 'やぶる', 'rip; break; violate', 'Group 1 (Godan)'),
    ('曲がる', 'まがる', 'bend; curve', 'Group 1 (Godan)'),
    ('曲げる', 'まげる', 'bend; curve', 'Group 2 (Ichidan)'),
    ('外れる', 'はずれる', 'come off; be wrong; drop out', 'Group 2 (Ichidan)'),
    ('外す', 'はずす', 'take off; get wrong; exclude', 'Group 1 (Godan)'),
    ('揺れる', 'ゆれる', 'shake; waver', 'Group 2 (Ichidan)'),
    ('揺らす', 'ゆらす', 'shake; swing', 'Group 1 (Godan)'),
    ('流れる', 'ながれる', 'flow; drift; be spread', 'Group 2 (Ichidan)'),
    ('流す', 'ながす', 'flush; shed; let flow; spread', 'Group 1 (Godan)'),
    ('濡れる', 'ぬれる', 'become wet', 'Group 2 (Ichidan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 25
  FROM public.vocabulary v
  WHERE v.word IN (
    '生やす', '汚れる', '汚す', '壊れる', '壊す', '割れる', '割る', '折れる', '折る', '破れる',
    '破る', '曲がる', '曲げる', '外れる', '外す', '揺れる', '揺らす', '流れる', '流す', '濡れる'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('生やす', 'ひげを生やす。', 'Grow a beard.'),
    ('汚れる', '空気の汚れたところには住みたくない。', 'I do not want to live somewhere with polluted air.'),
    ('汚す', 'どろ遊びをして服を汚した。', 'I played in the mud and dirtied my clothes.'),
    ('壊れる', '家、家具、電気製品などが壊れる。', 'Houses, furniture, electrical appliances, and so on break.'),
    ('壊す', '飲み過ぎて、時計を壊してしまった。', 'I drank too much and broke my watch.'),
    ('割れる', 'ガラス、皿、コップなどが割れる。', 'Glass, plates, cups, and so on break.'),
    ('割る', '卵を割ってボウルに入れる。', 'Crack an egg into a bowl.'),
    ('折れる', '強い風で枝が折れた。', 'A branch broke in the strong wind.'),
    ('折る', 'スキーをして、足の骨を折った。', 'I went skiing and broke a leg bone.'),
    ('破れる', '紙、服、本などが破れる。', 'Paper, clothes, books, and so on tear.'),
    ('破る', '約束、規則などを破る。', 'Break a promise, rule, and so on.'),
    ('曲がる', 'この角を曲がって50mほど行くと、銀行があります。', 'Turn at this corner and go about 50 meters; there is a bank.'),
    ('曲げる', '貯金、税金、腹などを曲げる。', 'Bend savings, taxes, the abdomen, and so on.'),
    ('外れる', 'ボタンが外れる。', 'The button comes off.'),
    ('外す', 'メガネ、腕時計、ボタンなどを外す。', 'Take off glasses, a wristwatch, buttons, and so on.'),
    ('揺れる', '風で木の葉が揺れている。', 'The leaves on the tree are swaying in the wind.'),
    ('揺らす', '子どもの乗ったブランコを揺らして遊ばせた。', 'I pushed the swing the child was riding on.'),
    ('流れる', '町の中心を大きな川が流れている。', 'A large river flows through the center of town.'),
    ('流す', '汚れた水を川に流してはいけない。', 'You must not let dirty water flow into the river.'),
    ('濡れる', '雨にぬれて、かぜをひいた。', 'I got wet in the rain and caught a cold.')
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

-- Verification: L25 must contain exactly 20 verbs, all with a verb group.
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
  AND vb.lesson_number = 25
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  '生やす', '汚れる', '汚す', '壊れる', '壊す', '割れる', '割る', '折れる', '折る', '破れる',
  '破る', '曲がる', '曲げる', '外れる', '外す', '揺れる', '揺らす', '流れる', '流す', '濡れる'
)
ORDER BY word;
