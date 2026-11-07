-- ============================================================
-- 耳から覚える N3 - Words 461-480
-- Lesson L24 = words 461-480.
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
    ('振る', 'ふる', 'wave; sprinkle; reject', 'Group 1 (Godan)'),
    ('めくる', 'めくる', 'turn over', 'Group 1 (Godan)'),
    ('見かける', 'みかける', 'see; come across', 'Group 2 (Ichidan)'),
    ('確かめる', 'たしかめる', 'check; confirm', 'Group 2 (Ichidan)'),
    ('試す', 'ためす', 'try; test', 'Group 1 (Godan)'),
    ('繰り返す', 'くりかえす', 'repeat', 'Group 1 (Godan)'),
    ('訳す', 'やくす', 'translate', 'Group 1 (Godan)'),
    ('行う', 'おこなう', 'hold; carry out', 'Group 1 (Godan)'),
    ('間違う', 'まちがう', 'be incorrect; make a mistake', 'Group 1 (Godan)'),
    ('間違える', 'まちがえる', 'get wrong; mistake', 'Group 2 (Ichidan)'),
    ('許す', 'ゆるす', 'forgive; allow; permit', 'Group 1 (Godan)'),
    ('慣れる', 'なれる', 'become accustomed to', 'Group 2 (Ichidan)'),
    ('慣らす', 'ならす', 'warm up; tame; accustom', 'Group 1 (Godan)'),
    ('立つ', 'たつ', 'stand; be put up', 'Group 1 (Godan)'),
    ('立てる', 'たてる', 'put up; stand; set up', 'Group 2 (Ichidan)'),
    ('建つ', 'たつ', 'be constructed', 'Group 1 (Godan)'),
    ('建てる', 'たてる', 'construct; build', 'Group 2 (Ichidan)'),
    ('育つ', 'そだつ', 'grow; be raised', 'Group 1 (Godan)'),
    ('育てる', 'そだてる', 'raise; grow; train', 'Group 2 (Ichidan)'),
    ('生える', 'はえる', 'grow; come in (hair, teeth, etc.)', 'Group 2 (Ichidan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 24
  FROM public.vocabulary v
  WHERE v.word IN (
    '振る', 'めくる', '見かける', '確かめる', '試す', '繰り返す', '訳す', '行う', '間違う', '間違える',
    '許す', '慣れる', '慣らす', '立つ', '立てる', '建つ', '建てる', '育つ', '育てる', '生える'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('振る', '手を振る。', 'Wave your hand.'),
    ('めくる', 'カード、ページ、カレンダーなどをめくる。', 'Turn over cards, pages, calendars, and so on.'),
    ('見かける', '街で偶然、昔の友だちを見かけた。', 'I happened to see an old friend in town.'),
    ('確かめる', 'ファックスが届いたかどうか、相手に電話して確かめた。', 'I called the other person to check whether the fax had arrived.'),
    ('試す', '洋服が似合うかどうか、着て試してみた。', 'I tried on the clothes to see whether they suited me.'),
    ('繰り返す', '同じ失敗を繰り返してはいけません。', 'You must not repeat the same mistake.'),
    ('訳す', '英語を日本語に訳す。', 'Translate English into Japanese.'),
    ('行う', '試験、会議、スピーチ、イベントなどを行う。', 'Hold exams, meetings, speeches, events, and so on.'),
    ('間違う', 'この計算は間違っている。', 'This calculation is wrong.'),
    ('間違える', 'テストの答えを間違えた。', 'I got the answer on the test wrong.'),
    ('許す', 'ひどいことを言われてけんかになったが、相手が謝ったので許してあげた。', 'We argued after being told something terrible, but I forgave them because they apologized.'),
    ('慣れる', '日本へ来て半年たって、生活にも慣れた。', 'After six months in Japan, I got used to life here.'),
    ('慣らす', '準備運動をして体を慣らしてからプールに入ったほうがいい。', 'It is better to warm up your body with exercises before entering the pool.'),
    ('立つ', '「名前を呼ばれたら立ってください」', '"Please stand when your name is called."'),
    ('立てる', '屋根の上にアンテナを立てる。', 'Put up an antenna on the roof.'),
    ('建つ', '家の前に大きなマンションが建った。', 'A large apartment building was constructed in front of the house.'),
    ('建てる', '都心に家を建てるのは大変だ。', 'Building a house in the city center is difficult.'),
    ('育つ', '雨が多いと、土がよく育つ。', 'When there is a lot of rain, the soil grows well.'),
    ('育てる', '母は5人の子どもを育てた。', 'My mother raised five children.'),
    ('生える', '髪、歯、草、ひげなどが生える。', 'Hair, teeth, grass, beards, and so on grow.')
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

-- Verification: L24 must contain exactly 20 verbs, all with a verb group.
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
  AND vb.lesson_number = 24
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  '振る', 'めくる', '見かける', '確かめる', '試す', '繰り返す', '訳す', '行う', '間違う', '間違える',
  '許す', '慣れる', '慣らす', '立つ', '立てる', '建つ', '建てる', '育つ', '育てる', '生える'
)
ORDER BY word;
