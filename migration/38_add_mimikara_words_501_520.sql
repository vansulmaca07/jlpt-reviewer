-- ============================================================
-- 耳から覚える N3 - Words 501-520
-- Lesson L26 = words 501-520: 10 verbs and 10 nouns.
-- Training, massage, and advice are nouns that can take する.
-- アイディア is an alternative spelling of the single entry アイデア.
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
  v_noun_type_id INTEGER;
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

  SELECT id INTO v_noun_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%noun%'
     OR type_name LIKE '%名詞%'
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
  IF v_noun_type_id IS NULL THEN
    RAISE EXCEPTION 'Noun not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id, verb_group)
  SELECT data.word, data.reading, data.meaning,
         CASE WHEN data.verb_group IS NOT NULL THEN v_verb_type_id ELSE v_noun_type_id END,
         v_n3_level_id, data.verb_group
  FROM (VALUES
    ('濡らす', 'ぬらす', 'wet; get something wet', 'Group 1 (Godan)'),
    ('迷う', 'まよう', 'become lost; hesitate; be undecided', 'Group 1 (Godan)'),
    ('悩む', 'なやむ', 'be troubled; worry; suffer', 'Group 1 (Godan)'),
    ('慌てる', 'あわてる', 'hurry; panic', 'Group 2 (Ichidan)'),
    ('覚める', 'さめる', 'wake up; sober up', 'Group 2 (Ichidan)'),
    ('覚ます', 'さます', 'wake someone up; sober up', 'Group 1 (Godan)'),
    ('眠る', 'ねむる', 'sleep', 'Group 1 (Godan)'),
    ('祈る', 'いのる', 'pray', 'Group 1 (Godan)'),
    ('祝う', 'いわう', 'celebrate', 'Group 1 (Godan)'),
    ('感じる', 'かんじる', 'feel; sense', 'Group 2 (Ichidan)'),
    ('クラスメート', 'クラスメート', 'classmate', NULL),
    ('グループ', 'グループ', 'group', NULL),
    ('チーム', 'チーム', 'team', NULL),
    ('プロフェッショナル', 'プロフェッショナル', 'professional; pro (プロ)', NULL),
    ('アマチュア', 'アマチュア', 'amateur (アマ)', NULL),
    ('トレーニング', 'トレーニング', 'training; practice (can take する)', NULL),
    ('マッサージ', 'マッサージ', 'massage (can take する)', NULL),
    ('アドバイス', 'アドバイス', 'advice (can take する: give advice)', NULL),
    ('アイデア', 'アイデア', 'idea (also spelled アイディア)', NULL),
    ('トップ', 'トップ', 'top; first place; leader; first', NULL)
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 26
  FROM public.vocabulary v
  WHERE v.word IN (
    '濡らす', '迷う', '悩む', '慌てる', '覚める', '覚ます', '眠る', '祈る', '祝う', '感じる',
    'クラスメート', 'グループ', 'チーム', 'プロフェッショナル', 'アマチュア',
    'トレーニング', 'マッサージ', 'アドバイス', 'アイデア', 'トップ'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('濡らす', '水をこぼして、服をぬらしてしまった。', 'I spilled water and got my clothes wet.'),
    ('迷う', '日本で就職するか、国に帰るか、迷っている。', 'I am undecided whether to get a job in Japan or return to my country.'),
    ('悩む', '就職するか、進学するか、悩んでいる。', 'I am worried about whether to get a job or continue my studies.'),
    ('慌てる', '学校に遅れそうになって、あわてて家を出た。', 'I was about to be late for school, so I hurried out of the house.'),
    ('覚める', '昨夜は暑くて、夜中に何度も目が覚めた。', 'It was hot last night, and I woke up many times during the night.'),
    ('覚ます', '目を覚ますと、もう10時だった。', 'When I woke up, it was already ten.'),
    ('眠る', '入試の前の日、緊張してよく眠れなかった。', 'The day before the entrance exam, I was nervous and could not sleep well.'),
    ('祈る', '家族の健康を神に祈った。', 'I prayed to God for my family''s health.'),
    ('祝う', '新年を祝って乾杯した。', 'We made a toast to celebrate the New Year.'),
    ('感じる', '私のミスで試合に負けてしまい、責任を感じている。', 'We lost the game because of my mistake, and I feel responsible.'),
    ('クラスメート', 'クラスメートと仲よくする。', 'Get along well with classmates.'),
    ('グループ', '3人のグループで旅行をする。', 'Travel in a group of three.'),
    ('チーム', '私たちのチームが勝った。', 'Our team won.'),
    ('プロフェッショナル', 'プロのサッカー選手になりたい。', 'I want to become a professional soccer player.'),
    ('アマチュア', 'この絵はアマチュアの作品とは思えないほどすばらしい。', 'This painting is so wonderful that it is hard to believe it is the work of an amateur.'),
    ('トレーニング', '勝つためには毎日のトレーニングが必要だ。', 'Daily training is necessary to win.'),
    ('マッサージ', '頭をマッサージしてもらうと気持ちがいい。', 'It feels good to have my head massaged.'),
    ('アドバイス', '後輩に仕事のやり方についてアドバイスをする。', 'Give a junior colleague advice on how to do the job.'),
    ('アイデア', 'いいアイデアが浮かんだ。', 'A good idea came to mind.'),
    ('トップ', '彼はクラスでトップの成績だ。', 'He has the best grades in the class.')
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

-- Verification: L26 must contain 20 entries, 10 grouped verbs, 10 nouns,
-- and at least one example for every entry. An empty lesson reports CHECK.
SELECT
  b.book_name,
  26 AS lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE (LOWER(wt.type_name) LIKE '%verb%' OR wt.type_name LIKE '%動詞%')
      AND v.verb_group IN ('Group 1 (Godan)', 'Group 2 (Ichidan)')
  ) AS grouped_verb_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE (LOWER(wt.type_name) LIKE '%noun%' OR wt.type_name LIKE '%名詞%')
      AND v.verb_group IS NULL
  ) AS noun_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE EXISTS (SELECT 1 FROM public.example_sentences e WHERE e.vocab_id = v.id)
  ) AS words_with_examples,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE (LOWER(wt.type_name) LIKE '%verb%' OR wt.type_name LIKE '%動詞%')
         AND v.verb_group IN ('Group 1 (Godan)', 'Group 2 (Ichidan)')
     ) = 10
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE (LOWER(wt.type_name) LIKE '%noun%' OR wt.type_name LIKE '%名詞%')
         AND v.verb_group IS NULL
     ) = 10
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE EXISTS (SELECT 1 FROM public.example_sentences e WHERE e.vocab_id = v.id)
     ) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.books b
LEFT JOIN public.vocabulary_books vb ON vb.book_id = b.id AND vb.lesson_number = 26
LEFT JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
GROUP BY b.id, b.book_name;

SELECT v.word, v.reading, v.meaning, wt.type_name, v.verb_group
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 26
ORDER BY v.word;
