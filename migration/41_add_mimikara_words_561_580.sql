-- ============================================================
-- 耳から覚える N3 - Words 561-580
-- Lesson L29 = words 561-580: 9 い-adjectives and 11 な-adjectives.
-- 固い / 硬い share one entry; the variant is recorded in its meaning.
-- Adjectives use the existing shared Adjective word type.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

ALTER TABLE public.vocabulary
  ADD COLUMN IF NOT EXISTS verb_group TEXT;

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_adjective_type_id INTEGER;
BEGIN
  SELECT id INTO v_book_id
  FROM public.books
  WHERE book_name = '耳から覚える'
  LIMIT 1;

  SELECT id INTO v_n3_level_id
  FROM public.jlpt_levels
  WHERE level = 'N3'
  LIMIT 1;

  SELECT id INTO v_adjective_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%adjective%'
     OR type_name LIKE '%形容詞%'
  ORDER BY id
  LIMIT 1;

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run migrations 06-10 first.';
  END IF;
  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 not found in jlpt_levels.';
  END IF;
  IF v_adjective_type_id IS NULL THEN
    RAISE EXCEPTION 'Adjective not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id, verb_group)
  SELECT data.word, data.reading, data.meaning, v_adjective_type_id, v_n3_level_id, NULL
  FROM (VALUES
    ('浅い', 'あさい', 'shallow; light (sleep); limited (experience or knowledge)'),
    ('固い', 'かたい', 'hard; firm; stiff; strict; resolute (also 硬い for hard materials or stiff expressions)'),
    ('ぬるい', 'ぬるい', 'lukewarm'),
    ('まぶしい', 'まぶしい', 'dazzling; glaring; radiant'),
    ('蒸し暑い', 'むしあつい', 'hot and humid; sultry'),
    ('清潔な', 'せいけつな', 'clean; hygienic'),
    ('新鮮な', 'しんせんな', 'fresh; new; novel'),
    ('豊かな', 'ゆたかな', 'abundant; rich; plentiful'),
    ('立派な', 'りっぱな', 'splendid; admirable; full-fledged; outright (crime, etc.)'),
    ('正確な', 'せいかくな', 'exact; accurate; punctual'),
    ('確かな', 'たしかな', 'certain; definite; reliable; probably (たしか as an adverb)'),
    ('重要な', 'じゅうような', 'important'),
    ('必要な', 'ひつような', 'necessary; needed'),
    ('もったいない', 'もったいない', 'wasteful; too good to waste; what a waste'),
    ('すごい', 'すごい', 'incredible; amazing; great; tremendous; fierce'),
    ('ひどい', 'ひどい', 'terrible; awful; cruel; severe'),
    ('激しい', 'はげしい', 'violent; intense; severe; considerable (change or difference)'),
    ('そっくりな', 'そっくりな', 'look-alike; closely resembling; exactly alike'),
    ('急な', 'きゅうな', 'sudden; urgent; rapid (current); steep; sharp (curve)'),
    ('適当な', 'てきとうな', 'suitable; proper; appropriate; convenient; careless; irresponsible')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 29
  FROM public.vocabulary v
  WHERE v.word IN (
    '浅い', '固い', 'ぬるい', 'まぶしい', '蒸し暑い',
    '清潔な', '新鮮な', '豊かな', '立派な', '正確な',
    '確かな', '重要な', '必要な', 'もったいない', 'すごい',
    'ひどい', '激しい', 'そっくりな', '急な', '適当な'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('浅い', 'この川は浅いので、子どもが泳いでも危なくない。', 'This river is shallow, so it is safe for children to swim in.'),
    ('固い', 'このパンはとても固い。', 'This bread is very hard.'),
    ('固い', 'びんのふたが固くてなかなか開かない。', 'The lid of the jar is tight and will not open easily.'),
    ('固い', 'がんばれば夢は実現すると固く信じている。', 'I firmly believe that my dreams will come true if I work hard.'),
    ('固い', 'ダイヤモンドは非常に硬いので、工業用に使われている。', 'Diamonds are extremely hard, so they are used for industrial purposes.'),
    ('ぬるい', 'ぬるいコーヒーはおいしくない。', 'Lukewarm coffee does not taste good.'),
    ('まぶしい', 'カーテンを開けたら、太陽がまぶしかった。', 'When I opened the curtains, the sunlight was dazzling.'),
    ('蒸し暑い', '日本の夏は、蒸し暑い。', 'Summers in Japan are hot and humid.'),
    ('清潔な', '清潔な服を身につける。', 'Wear clean clothes.'),
    ('新鮮な', '新鮮な魚はおいしい。', 'Fresh fish tastes good.'),
    ('新鮮な', '山で新鮮な空気を胸いっぱいに吸いこんだ。', 'I took a deep breath of fresh mountain air.'),
    ('新鮮な', '新鮮な気持ちで新学期を迎えた。', 'I started the new school term with a fresh outlook.'),
    ('豊かな', 'このあたりは、国でもっとも豊かな地方だ。', 'This area is the richest region in the country.'),
    ('立派な', '彼は最後までりっぱにリーダーとしての役目を果たした。', 'He admirably fulfilled his role as leader until the end.'),
    ('立派な', 'いじめは、りっぱな犯罪だ。', 'Bullying is an outright crime.'),
    ('正確な', '計算は答えを正確に出さなければならない。', 'You must calculate the answer accurately.'),
    ('正確な', '山本さんは時間に正確で、待ち合わせに絶対遅れない。', 'Yamamoto is punctual and never arrives late for appointments.'),
    ('確かな', '新聞は確かな事実だけを伝えなければならない。', 'Newspapers must report only verified facts.'),
    ('確かな', 'レポートのしめ切りは、確か15日でしたね。', 'The report deadline was the fifteenth, if I remember correctly.'),
    ('重要な', 'きょうは午後から重要な会議がある。', 'There is an important meeting this afternoon.'),
    ('必要な', '子どもに必要なのは、親の温かい愛情だ。', 'What children need is warm affection from their parents.'),
    ('もったいない', '流行遅れでもまだ着られる服を捨てるのはもったいない。', 'It is wasteful to throw away clothes that can still be worn, even if they are out of fashion.'),
    ('すごい', 'きのうの台風はすごかった。', 'Yesterday''s typhoon was tremendous.'),
    ('すごい', '演奏が終わると、すごい拍手だった。', 'There was tremendous applause when the performance ended.'),
    ('ひどい', '今学期の成績はひどかった。', 'My grades this term were terrible.'),
    ('ひどい', 'どうしたの、顔色がひどく悪いよ。', 'What is wrong? You look terribly pale.'),
    ('激しい', '入試に失敗して、今まで勉強しなかったことを激しく後悔した。', 'After failing the entrance exam, I deeply regretted not having studied before.'),
    ('そっくりな', '兄は父に顔も声もそっくりだ。', 'My older brother looks and sounds just like our father.'),
    ('そっくりな', '友だちだと思って声をかけたら、そっくりな別人だった。', 'I called out to someone I thought was my friend, but it was a different person who looked exactly like them.'),
    ('急な', '急に歯が痛みだした。', 'My tooth suddenly started to hurt.'),
    ('急な', 'この川は流れが急だ。', 'This river has a rapid current.'),
    ('適当な', '家庭教師を探しているが、適当な人がなかなかいない。', 'I am looking for a private tutor, but I cannot easily find a suitable person.'),
    ('適当な', '肉と野菜を適当な大きさに切ってカレーを作る。', 'Cut the meat and vegetables into appropriately sized pieces to make curry.'),
    ('適当な', '親が結婚しろとうるさくて、そのたびに適当に返事をしている。', 'My parents keep nagging me to get married, and each time I give them a half-hearted reply.')
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

-- Verification: L29 must contain 20 adjectives (9 い, 11 な),
-- no verb groups, and an example for every entry. An empty lesson reports CHECK.
SELECT
  b.book_name,
  29 AS lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%adjective%' OR wt.type_name LIKE '%形容詞%'
  ) AS adjective_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.word NOT LIKE '%な') AS i_adjective_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.word LIKE '%な') AS na_adjective_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NULL) AS ungrouped_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE EXISTS (SELECT 1 FROM public.example_sentences e WHERE e.vocab_id = v.id)
  ) AS words_with_examples,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%adjective%' OR wt.type_name LIKE '%形容詞%'
     ) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.word NOT LIKE '%な') = 9
     AND COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.word LIKE '%な') = 11
     AND COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NULL) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE EXISTS (SELECT 1 FROM public.example_sentences e WHERE e.vocab_id = v.id)
     ) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.books b
LEFT JOIN public.vocabulary_books vb ON vb.book_id = b.id AND vb.lesson_number = 29
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
  AND vb.lesson_number = 29
ORDER BY v.word;
