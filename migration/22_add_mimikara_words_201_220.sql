-- ============================================================
-- 耳から覚える N3 - Words 201-220
-- Lesson L11 = words 201-220.
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
    ('むく', 'むく', 'peel', 'Group 1 (Godan)'),
    ('滑る', 'すべる', 'skate; slip', 'Group 1 (Godan)'),
    ('積もる', 'つもる', 'accumulate; pile up', 'Group 1 (Godan)'),
    ('積む', 'つむ', 'pile; load; accumulate', 'Group 1 (Godan)'),
    ('空く', 'あく', 'open; become vacant; be available', 'Group 1 (Godan)'),
    ('空ける', 'あける', 'open; empty; keep open', 'Group 2 (Ichidan)'),
    ('下がる', 'さがる', 'go down; fall; step back', 'Group 1 (Godan)'),
    ('下げる', 'さげる', 'lower; take down', 'Group 2 (Ichidan)'),
    ('冷える', 'ひえる', 'be chilled; feel chilly', 'Group 2 (Ichidan)'),
    ('冷やす', 'ひやす', 'chill; cool; calm down', 'Group 1 (Godan)'),
    ('冷める', 'さめる', 'get cold; lose passion', 'Group 2 (Ichidan)'),
    ('冷ます', 'さます', 'allow something to cool', 'Group 1 (Godan)'),
    ('燃える', 'もえる', 'burn; be passionate', 'Group 2 (Ichidan)'),
    ('燃やす', 'もやす', 'burn something; burn with passion', 'Group 1 (Godan)'),
    ('沸く', 'わく', 'boil; become excited', 'Group 1 (Godan)'),
    ('沸かす', 'わかす', 'boil; prepare a bath; excite', 'Group 1 (Godan)'),
    ('鳴る', 'なる', 'ring; sound; rumble', 'Group 1 (Godan)'),
    ('鳴らす', 'ならす', 'sound; ring; honk', 'Group 1 (Godan)'),
    ('役立つ', 'やくだつ', 'be helpful; be useful', 'Group 1 (Godan)'),
    ('役立てる', 'やくだてる', 'put to use; make use of', 'Group 2 (Ichidan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 11
  FROM public.vocabulary v
  WHERE v.word IN (
    'むく', '滑る', '積もる', '積む', '空く', '空ける', '下がる', '下げる', '冷える', '冷やす',
    '冷める', '冷ます', '燃える', '燃やす', '沸く', '沸かす', '鳴る', '鳴らす', '役立つ', '役立てる'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('むく', '果物の皮をむく。', 'Peel the skin of the fruit.'),
    ('滑る', '新しいスケート場はきれいで、楽しく滑ることができた。', 'The new skating rink was beautiful, and I was able to skate happily.'),
    ('積もる', 'きのう降った雪が積もっている。', 'The snow that fell yesterday has piled up.'),
    ('積む', '車に荷物を積む。', 'Load the luggage into the car.'),
    ('空く', 'くつしたに穴が空いてしまった。', 'A hole opened in my sock.'),
    ('空ける', '電車でお年寄りのために席を空けた。', 'I gave up my seat on the train for an elderly person.'),
    ('下がる', '熱、温度、値段、成績などが下がる。', 'Fever, temperature, prices, and grades go down.'),
    ('下げる', 'お皿をお下げしてもよろしいですか。', 'May I clear away your plate?'),
    ('冷える', '寒いところに長くいたので、手足が冷えてしまった。', 'My hands and feet got cold because I stayed in a cold place for a long time.'),
    ('冷やす', 'この果物は冷やして食べたほうがおいしい。', 'This fruit tastes better chilled.'),
    ('冷める', 'この料理は冷めるとおいしくない。', 'This dish does not taste good when it gets cold.'),
    ('冷ます', 'お風呂のお湯が熱くなりすぎた。少し冷ましてから入ろう。', 'The bathwater got too hot. Let us let it cool a little before getting in.'),
    ('燃える', '火が燃えている。', 'The fire is burning.'),
    ('燃やす', '火で紙を燃やす。', 'Burn paper with fire.'),
    ('沸く', '湯が沸く。', 'The water boils.'),
    ('沸かす', '湯を沸かす。', 'Boil water.'),
    ('鳴る', '雷が鳴っている。', 'Thunder is rumbling.'),
    ('鳴らす', 'ブザーを鳴らす。', 'Sound the buzzer.'),
    ('役立つ', 'インターネットの情報は、勉強や仕事に役立つ。', 'Information on the internet is useful for studying and work.'),
    ('役立てる', 'インターネットの情報を、勉強や仕事に役立てる。', 'Put information from the internet to use for studying and work.')
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

-- Verification: L11 must contain exactly 20 words, all with a verb group.
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
  AND vb.lesson_number = 11
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  'むく', '滑る', '積もる', '積む', '空く', '空ける', '下がる', '下げる', '冷える', '冷やす',
  '冷める', '冷ます', '燃える', '燃やす', '沸く', '沸かす', '鳴る', '鳴らす', '役立つ', '役立てる'
)
ORDER BY word;
