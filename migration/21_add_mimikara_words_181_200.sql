-- ============================================================
-- 耳から覚える N3 - Words 181-200
-- Lesson L10 = words 181-200.
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
    ('動く', 'うごく', 'move; work; take action', 'Group 1 (Godan)'),
    ('動かす', 'うごかす', 'move; operate; set in motion', 'Group 1 (Godan)'),
    ('離れる', 'はなれる', 'be away from; be separated from', 'Group 2 (Ichidan)'),
    ('離す', 'はなす', 'move apart; let go; separate', 'Group 1 (Godan)'),
    ('ぶつかる', 'ぶつかる', 'collide; disagree; conflict', 'Group 1 (Godan)'),
    ('ぶつける', 'ぶつける', 'crash into; bump; hit against', 'Group 2 (Ichidan)'),
    ('こぼれる', 'こぼれる', 'be spilled; overflow', 'Group 2 (Ichidan)'),
    ('こぼす', 'こぼす', 'spill; shed (tears)', 'Group 1 (Godan)'),
    ('ふく', 'ふく', 'wipe', 'Group 1 (Godan)'),
    ('片付く', 'かたづく', 'be tidied; be finished; be settled', 'Group 1 (Godan)'),
    ('片付ける', 'かたづける', 'tidy; finish; settle', 'Group 2 (Ichidan)'),
    ('包む', 'つつむ', 'wrap; pack', 'Group 1 (Godan)'),
    ('張る', 'はる', 'put up; affix; stretch', 'Group 1 (Godan)'),
    ('なくなる', 'なくなる', 'be lost; disappear; run out', 'Group 1 (Godan)'),
    ('なくす', 'なくす', 'lose; misplace', 'Group 1 (Godan)'),
    ('足りる', 'たりる', 'be sufficient; be enough', 'Group 2 (Ichidan)'),
    ('残る', 'のこる', 'be left over; remain', 'Group 1 (Godan)'),
    ('残す', 'のこす', 'leave behind; leave unfinished', 'Group 1 (Godan)'),
    ('腐る', 'くさる', 'rot; go bad', 'Group 1 (Godan)'),
    ('剥ける', 'むける', 'peel; become peeled', 'Group 2 (Ichidan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 10
  FROM public.vocabulary v
  WHERE v.word IN (
    '動く', '動かす', '離れる', '離す', 'ぶつかる', 'ぶつける', 'こぼれる', 'こぼす', 'ふく', '片付く',
    '片付ける', '包む', '張る', 'なくなる', 'なくす', '足りる', '残る', '残す', '腐る', '剥ける'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('動く', '写真を撮るから動かないでください。', 'I am going to take a picture, so please do not move.'),
    ('動かす', 'スイッチを入れても機械が動かない。', 'The machine does not work even when I turn on the switch.'),
    ('離れる', '今、家族と離れて暮らしている。', 'I currently live apart from my family.'),
    ('離す', 'テストのときは、机を離して並べる。', 'During tests, we arrange the desks apart from each other.'),
    ('ぶつかる', '道で自転車にぶつかってけがをした。', 'I collided with a bicycle on the road and got injured.'),
    ('ぶつける', '運転していて、車を電柱にぶつけてしまった。', 'While driving, I accidentally crashed the car into a utility pole.'),
    ('こぼれる', 'くやしくて涙がこぼれた。', 'Tears spilled because I was frustrated.'),
    ('こぼす', 'コップを倒して水をこぼしてしまった。', 'I knocked over the glass and spilled the water.'),
    ('ふく', '汗をふく。', 'Wipe away sweat.'),
    ('片付く', '大掃除をして、やっと部屋が片付いた。', 'After doing a thorough cleaning, the room was finally tidied up.'),
    ('片付ける', '机の上を片付ける。', 'Tidy up the desk.'),
    ('包む', 'プレゼントをきれいな紙で包む。', 'Wrap the present in nice paper.'),
    ('張る', '壁にポスターを張る。', 'Put up a poster on the wall.'),
    ('なくなる', '部屋のかさがなくなってしまった。', 'The umbrella in the room disappeared.'),
    ('なくす', 'パスポートをなくして困っている。', 'I lost my passport and am in trouble.'),
    ('足りる', 'この収入では生活するのに全然足りない。', 'This income is not nearly enough to live on.'),
    ('残る', '料理を作りすぎて、たくさん残ってしまった。', 'I made too much food, so a lot was left over.'),
    ('残す', 'ごはんを残してはいけません。', 'You must not leave your food.'),
    ('腐る', '生魚は腐りやすいから、早く食べたほうがいい。', 'Raw fish spoils easily, so you should eat it soon.'),
    ('剥ける', '海で日焼けをして、背中の皮が剥けた。', 'I got sunburned at the beach and the skin on my back peeled.')
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

-- Verification: L10 must contain exactly 20 words, all with a verb group.
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
  AND vb.lesson_number = 10
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  '動く', '動かす', '離れる', '離す', 'ぶつかる', 'ぶつける', 'こぼれる', 'こぼす', 'ふく', '片付く',
  '片付ける', '包む', '張る', 'なくなる', 'なくす', '足りる', '残る', '残す', '腐る', '剥ける'
)
ORDER BY word;