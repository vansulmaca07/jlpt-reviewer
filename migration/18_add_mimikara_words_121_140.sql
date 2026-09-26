-- ============================================================
-- 耳から覚える N3 - Words 121-140
-- Lesson L7 = words 121-140.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

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

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT data.word, data.reading, data.meaning, v_verb_type_id, v_n3_level_id
  FROM (VALUES
    ('渇く', 'かわく', 'become thirsty, be parched'),
    ('嗅ぐ', 'かぐ', 'smell, sniff'),
    ('叩く', 'たたく', 'spank, tap, knock, clap'),
    ('殴る', 'なぐる', 'punch, hit'),
    ('蹴る', 'ける', 'kick'),
    ('抱く', 'だく', 'hold, hug'),
    ('倒れる', 'たおれる', 'fall over, collapse'),
    ('倒す', 'たおす', 'knock over, defeat'),
    ('起きる', 'おきる', 'wake up, stay up, occur, arise'),
    ('起こす', 'おこす', 'wake someone, cause'),
    ('尋ねる', 'たずねる', 'ask, inquire'),
    ('呼ぶ', 'よぶ', 'call, summon, attract'),
    ('叫ぶ', 'さけぶ', 'yell, shout'),
    ('黙る', 'だまる', 'be silent, say nothing'),
    ('飼う', 'かう', 'keep, raise a pet'),
    ('数える', 'かぞえる', 'count, number'),
    ('乾く', 'かわく', 'dry, become dry'),
    ('乾かす', 'かわかす', 'dry something'),
    ('畳む', 'たたむ', 'fold'),
    ('誘う', 'さそう', 'invite, encourage')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 7
  FROM public.vocabulary v
  WHERE v.word IN (
    '渇く', '嗅ぐ', '叩く', '殴る', '蹴る', '抱く', '倒れる', '倒す', '起きる', '起こす',
    '尋ねる', '呼ぶ', '叫ぶ', '黙る', '飼う', '数える', '乾く', '乾かす', '畳む', '誘う'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('渇く', '運動したので、のどが渇きました。', 'I got thirsty because I exercised.'),
    ('嗅ぐ', '犬が花のにおいを嗅いでいます。', 'The dog is smelling the flower.'),
    ('叩く', 'ドアを三回叩きました。', 'I knocked on the door three times.'),
    ('殴る', '人を殴ってはいけません。', 'You must not hit people.'),
    ('蹴る', 'ボールを強く蹴りました。', 'I kicked the ball hard.'),
    ('抱く', '母は赤ちゃんを抱いています。', 'The mother is holding the baby.'),
    ('倒れる', '強い風で木が倒れました。', 'The tree fell because of the strong wind.'),
    ('倒す', '弟がコップを倒しました。', 'My younger brother knocked over the cup.'),
    ('起きる', '毎朝六時に起きます。', 'I wake up at six every morning.'),
    ('起こす', '明日七時に起こしてください。', 'Please wake me up at seven tomorrow.'),
    ('尋ねる', '駅員に道を尋ねました。', 'I asked a station employee for directions.'),
    ('呼ぶ', 'タクシーを呼びました。', 'I called a taxi.'),
    ('叫ぶ', '助けてくださいと叫びました。', 'I shouted, Please help me.'),
    ('黙る', '先生が話している間は黙ってください。', 'Please be quiet while the teacher is speaking.'),
    ('飼う', '家で猫を一匹飼っています。', 'I keep one cat at home.'),
    ('数える', '人数を数えてください。', 'Please count the number of people.'),
    ('乾く', '洗濯物がもう乾きました。', 'The laundry is already dry.'),
    ('乾かす', 'ドライヤーで髪を乾かしました。', 'I dried my hair with a hair dryer.'),
    ('畳む', '洗った服を畳みました。', 'I folded the washed clothes.'),
    ('誘う', '友達を誘って映画を見に行きました。', 'I invited my friend to go see a movie.')
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

-- Verification: L7 must contain exactly these 20 words.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20 THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 7
GROUP BY b.book_name, vb.lesson_number;