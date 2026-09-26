-- ============================================================
-- 耳から覚える N3 - Words 161-180
-- Lesson L9 = words 161-180.
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
    ('直す', 'なおす', 'fix; correct; translate', 'Group 1 (Godan)'),
    ('治る', 'なおる', 'get better; heal; recover', 'Group 1 (Godan)'),
    ('治す', 'なおす', 'cure; heal; treat', 'Group 1 (Godan)'),
    ('亡くなる', 'なくなる', 'die; pass away', 'Group 1 (Godan)'),
    ('亡くす', 'なくす', 'lose someone through death', 'Group 1 (Godan)'),
    ('生まれる', 'うまれる', 'be born; be created', 'Group 2 (Ichidan)'),
    ('産む', 'うむ', 'give birth; produce; create', 'Group 1 (Godan)'),
    ('出会う', 'であう', 'meet by chance', 'Group 1 (Godan)'),
    ('訪ねる', 'たずねる', 'visit', 'Group 2 (Ichidan)'),
    ('付き合う', 'つきあう', 'associate with; keep company with; date', 'Group 1 (Godan)'),
    ('効く', 'きく', 'be effective; work', 'Group 1 (Godan)'),
    ('流行る', 'はやる', 'be popular; spread (a disease)', 'Group 1 (Godan)'),
    ('経つ', 'たつ', 'elapse; pass (time)', 'Group 1 (Godan)'),
    ('間に合う', 'まにあう', 'be in time', 'Group 1 (Godan)'),
    ('間に合わせる', 'まにあわせる', 'finish in time', 'Group 2 (Ichidan)'),
    ('通う', 'かよう', 'commute; attend regularly', 'Group 1 (Godan)'),
    ('込む', 'こむ', 'be crowded', 'Group 1 (Godan)'),
    ('すれ違う', 'すれちがう', 'pass each other; miss each other', 'Group 1 (Godan)'),
    ('掛かる', 'かかる', 'take (time/money); cost; be subject to', 'Group 1 (Godan)'),
    ('掛ける', 'かける', 'hang; pour; spend; multiply', 'Group 2 (Ichidan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 9
  FROM public.vocabulary v
  WHERE v.word IN (
    '直す', '治る', '治す', '亡くなる', '亡くす', '生まれる', '産む', '出会う', '訪ねる', '付き合う',
    '効く', '流行る', '経つ', '間に合う', '間に合わせる', '通う', '込む', 'すれ違う', '掛かる', '掛ける'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('直す', 'こわれた時計を直す。', 'Fix the broken clock.'),
    ('治る', 'なかなか頭痛が治らない。', 'My headache will not go away easily.'),
    ('治す', 'よく休んで早くかぜを治してください。', 'Please rest well and recover from your cold soon.'),
    ('亡くなる', '社長が90歳で亡くなった。', 'The company president passed away at age 90.'),
    ('亡くす', '彼は子どものとき、父親を亡くした。', 'He lost his father when he was a child.'),
    ('生まれる', '先月子どもが生まれた。', 'A child was born last month.'),
    ('産む', '妻が先日元気な女の子を産んだ。', 'My wife gave birth to a healthy girl the other day.'),
    ('出会う', '駅で偶然大学時代の友人に出会った。', 'I happened to meet a friend from university at the station.'),
    ('訪ねる', '友人の家を訪ねた。', 'I visited my friend''s house.'),
    ('付き合う', '隣の家の人と親しく付き合っている。', 'I associate closely with my neighbor.'),
    ('効く', 'この薬は頭痛によく効く。', 'This medicine works well for headaches.'),
    ('流行る', 'この冬は赤い色が流行っている。', 'Red is popular this winter.'),
    ('経つ', '日本へ来てから10年が経った。', 'Ten years have passed since I came to Japan.'),
    ('間に合う', '電車が遅れたが、駅から走って授業に間に合った。', 'The train was late, but I ran from the station and made it to class on time.'),
    ('間に合わせる', 'レポートを、がんばって締め切りに間に合わせた。', 'I worked hard and finished the report on time.'),
    ('通う', '学校に通う。', 'Attend school.'),
    ('込む', '電車が込む。', 'The train is crowded.'),
    ('すれ違う', '上り列車と下り列車がすれ違った。', 'The up train and down train passed each other.'),
    ('掛かる', 'この調査には時間と費用がかかる。', 'This research takes time and costs money.'),
    ('掛ける', '料理にしょうゆをかけて食べる。', 'Pour soy sauce over the dish and eat it.')
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

-- Verification: L9 must contain exactly 20 words, all with a verb group.
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
  AND vb.lesson_number = 9
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  '直す', '治る', '治す', '亡くなる', '亡くす', '生まれる', '産む', '出会う', '訪ねる', '付き合う',
  '効く', '流行る', '経つ', '間に合う', '間に合わせる', '通う', '込む', 'すれ違う', '掛かる', '掛ける'
)
ORDER BY word;