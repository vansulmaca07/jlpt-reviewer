-- ============================================================
-- 耳から覚える N3 - Words 401-420
-- Lesson L21 = words 401-420.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_noun_type_id INTEGER;
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

  SELECT id INTO v_noun_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%noun%'
     OR type_name LIKE '%名詞%'
  ORDER BY id
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
  IF v_noun_type_id IS NULL THEN
    RAISE EXCEPTION 'Noun not found in word_types.';
  END IF;
  IF v_verb_type_id IS NULL THEN
    RAISE EXCEPTION 'Verb not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT
    data.word,
    data.reading,
    data.meaning,
    CASE WHEN data.word_type = 'verb' THEN v_verb_type_id ELSE v_noun_type_id END,
    v_n3_level_id
  FROM (VALUES
    ('にせ', 'にせ', 'fake; counterfeit', 'noun'),
    ('別', 'べつ', 'difference; distinction', 'noun'),
    ('国籍', 'こくせき', 'nationality; citizenship', 'noun'),
    ('東洋', 'とうよう', 'the East; the Orient', 'noun'),
    ('西洋', 'せいよう', 'the West; the Occident', 'noun'),
    ('国際', 'こくさい', 'international', 'noun'),
    ('自然', 'しぜん', 'nature; natural', 'noun'),
    ('景色', 'けしき', 'scenery; landscape', 'noun'),
    ('宗教', 'しゅうきょう', 'religion', 'noun'),
    ('愛', 'あい', 'love', 'noun'),
    ('届く', 'とどく', 'be delivered; reach', 'verb'),
    ('届ける', 'とどける', 'deliver; notify', 'verb'),
    ('かく', 'かく', 'scratch; emit; draw', 'verb'),
    ('つかむ', 'つかむ', 'grab; grasp; seize', 'verb'),
    ('にぎる', 'にぎる', 'grip; squeeze; hold', 'verb'),
    ('押さえる', 'おさえる', 'put one''s hands on; hold down', 'verb'),
    ('近づく', 'ちかづく', 'approach; draw near', 'verb'),
    ('近づける', 'ちかづける', 'move something nearer', 'verb'),
    ('合う', 'あう', 'meet; suit; match', 'verb'),
    ('合わせる', 'あわせる', 'combine; adapt; match; set', 'verb')
  ) AS data(word, reading, meaning, word_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 21
  FROM public.vocabulary v
  WHERE v.word IN (
    'にせ', '別', '国籍', '東洋', '西洋', '国際', '自然', '景色', '宗教', '愛',
    '届く', '届ける', 'かく', 'つかむ', 'にぎる', '押さえる', '近づく', '近づける', '合う', '合わせる'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('にせ', 'にせの紙幣を使ってお金を取られた。', 'Someone used counterfeit bills and took my money.'),
    ('別', '「米」は「ごはん」とは別のものだ。', 'Kome is something different from gohan.'),
    ('国籍', '私はずっとアメリカで暮らしているが、国籍は日本だ。', 'I have lived in America for a long time, but my nationality is Japanese.'),
    ('東洋', '東洋の文化と西洋の文化を比べる。', 'Compare Eastern and Western cultures.'),
    ('西洋', '東洋の文化と西洋の文化を比べる。', 'Compare Eastern and Western cultures.'),
    ('国際', '日本企業の海外支社でのトラブルが国際問題に発展した。', 'A problem at the overseas branch of a Japanese company developed into an international issue.'),
    ('自然', '山や海へ行って、自然の中で過ごす。', 'Go to the mountains or sea and spend time in nature.'),
    ('景色', '初めて日本の山に行った。すばらしい景色だった。', 'I went to a Japanese mountain for the first time. The scenery was wonderful.'),
    ('宗教', '世界にはいろいろな宗教がある。', 'There are many different religions in the world.'),
    ('愛', '私は家族、先生、国などを愛している。', 'I love my family, teachers, country, and so on.'),
    ('届く', '父から手紙が届いた。', 'A letter from my father arrived.'),
    ('届ける', '隣の家に旅行のおみやげを届けた。', 'I delivered a souvenir from my trip to the neighboring house.'),
    ('かく', '頭をかく。', 'Scratch my head.'),
    ('つかむ', '電車で突然腕をつかまれてびっくりした。', 'I was surprised when someone suddenly grabbed my arm on the train.'),
    ('にぎる', '子どもはこわがって母親の手を強くにぎった。', 'The child was scared and tightly gripped their mother''s hand.'),
    ('押さえる', '後ろの人のためにドアを押さえて待った。', 'I held the door open for the person behind me.'),
    ('近づく', '台風が日本列島に近づく。', 'A typhoon approaches the Japanese archipelago.'),
    ('近づける', '車を道のわきに近づける。', 'Move the car closer to the side of the road.'),
    ('合う', 'ふと顔を上げると、先生と目が合ってしまった。', 'When I suddenly looked up, my eyes met the teacher''s.'),
    ('合わせる', 'みんなで力を合わせてがんばりましょう。', 'Let us all combine our strength and do our best.')
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

-- Verification: L21 must contain exactly 20 entries: 10 nouns and 10 verbs.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%noun%'
       OR wt.type_name LIKE '%名詞%'
  ) AS noun_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%verb%'
       OR wt.type_name LIKE '%動詞%'
  ) AS verb_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%noun%'
          OR wt.type_name LIKE '%名詞%'
     ) = 10
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%verb%'
          OR wt.type_name LIKE '%動詞%'
     ) = 10
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 21
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  'にせ', '別', '国籍', '東洋', '西洋', '国際', '自然', '景色', '宗教', '愛',
  '届く', '届ける', 'かく', 'つかむ', 'にぎる', '押さえる', '近づく', '近づける', '合う', '合わせる'
)
ORDER BY word;
