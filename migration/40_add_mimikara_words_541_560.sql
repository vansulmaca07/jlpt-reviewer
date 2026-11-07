-- ============================================================
-- 耳から覚える N3 - Words 541-560
-- Lesson L28 = words 541-560: 10 nouns and 10 い-adjectives.
-- アナウンス and インタビュー are nouns that can take する.
-- かっこうがいい is recorded as a variant of かっこいい.
-- Examples for カード and パーセント are original sentences;
-- the screenshots have no full examples for these entries.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

ALTER TABLE public.vocabulary
  ADD COLUMN IF NOT EXISTS verb_group TEXT;

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_noun_type_id INTEGER;
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

  SELECT id INTO v_noun_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%noun%'
     OR type_name LIKE '%名詞%'
  ORDER BY id
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
  IF v_noun_type_id IS NULL THEN
    RAISE EXCEPTION 'Noun not found in word_types.';
  END IF;
  IF v_adjective_type_id IS NULL THEN
    RAISE EXCEPTION 'Adjective not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id, verb_group)
  SELECT data.word, data.reading, data.meaning, data.word_type_id, v_n3_level_id, NULL
  FROM (VALUES
    ('インターネット', 'インターネット', 'Internet', v_noun_type_id),
    ('チャイム', 'チャイム', 'chime', v_noun_type_id),
    ('アナウンス', 'アナウンス', 'announcement (can take する: announce)', v_noun_type_id),
    ('メッセージ', 'メッセージ', 'message; statement', v_noun_type_id),
    ('パンフレット', 'パンフレット', 'pamphlet; brochure', v_noun_type_id),
    ('カード', 'カード', 'card', v_noun_type_id),
    ('インタビュー', 'インタビュー', 'interview (can take する)', v_noun_type_id),
    ('アンケート', 'アンケート', 'questionnaire; survey', v_noun_type_id),
    ('データ', 'データ', 'data', v_noun_type_id),
    ('パーセント', 'パーセント', 'percent (%)', v_noun_type_id),
    ('濃い', 'こい', 'dark (color); strong (flavor); thick; heavy (beard)', v_adjective_type_id),
    ('薄い', 'うすい', 'thin; light (color, flavor, makeup); weak (coffee)', v_adjective_type_id),
    ('酸っぱい', 'すっぱい', 'sour', v_adjective_type_id),
    ('臭い', 'くさい', 'stinky; smelly', v_adjective_type_id),
    ('おかしい', 'おかしい', 'amusing; funny; strange; wrong; unreasonable', v_adjective_type_id),
    ('かっこいい', 'かっこいい', 'cool; stylish; good-looking (also かっこうがいい)', v_adjective_type_id),
    ('うまい', 'うまい', 'skillful; tasty; smooth; successful (informal)', v_adjective_type_id),
    ('親しい', 'したしい', 'close; intimate; friendly', v_adjective_type_id),
    ('詳しい', 'くわしい', 'detailed; knowledgeable', v_adjective_type_id),
    ('細かい', 'こまかい', 'fine; small; detailed; small-denomination (money)', v_adjective_type_id)
  ) AS data(word, reading, meaning, word_type_id)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 28
  FROM public.vocabulary v
  WHERE v.word IN (
    'インターネット', 'チャイム', 'アナウンス', 'メッセージ', 'パンフレット',
    'カード', 'インタビュー', 'アンケート', 'データ', 'パーセント',
    '濃い', '薄い', '酸っぱい', '臭い', 'おかしい',
    'かっこいい', 'うまい', '親しい', '詳しい', '細かい'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('インターネット', 'インターネットで世界の環境問題について調べた。', 'I researched global environmental problems on the Internet.'),
    ('チャイム', '授業が始まるとき、チャイムが鳴る。', 'A chime rings when class begins.'),
    ('アナウンス', '電車の中でアナウンスを聞く。', 'Listen to an announcement on the train.'),
    ('メッセージ', '留守番電話にメッセージをのこす。', 'Leave a message on the answering machine.'),
    ('メッセージ', 'この曲には、平和へのメッセージがこめられている。', 'This song contains a message of peace.'),
    ('パンフレット', '旅行会社でパンフレットをたくさんもらってきた。', 'I picked up many brochures at the travel agency.'),
    ('カード', 'この店ではクレジットカードが使える。', 'You can use a credit card at this store.'),
    ('インタビュー', '勝ったチームの選手にインタビューする。', 'Interview a player from the winning team.'),
    ('アンケート', 'アンケートをして学生の生活を調べる。', 'Conduct a survey to study student life.'),
    ('データ', '研究のために、データを集めている。', 'I am collecting data for my research.'),
    ('パーセント', 'この店では全品十パーセント引きです。', 'Everything at this store is ten percent off.'),
    ('濃い', 'コーヒーが濃い。', 'The coffee is strong.'),
    ('薄い', '薄い本。', 'A thin book.'),
    ('薄い', 'コーヒーが薄い。', 'The coffee is weak.'),
    ('酸っぱい', 'レモンはすっぱい。', 'Lemons are sour.'),
    ('臭い', '魚を焼いたので台所がくさくなった。', 'The kitchen became smelly because I grilled fish.'),
    ('おかしい', '山本君は、授業中にいつもおかしいことを言ってみんなを笑わせる。', 'Yamamoto always says funny things during class and makes everyone laugh.'),
    ('おかしい', 'パソコンの調子がおかしい。', 'Something is wrong with the computer.'),
    ('おかしい', 'うちの会社、子どもができたらやめなきゃいけないの。そんなのおかしいよ。', 'At my company, you have to quit if you have a child. That is unreasonable.'),
    ('かっこいい', 'あの先輩は、かっこいいので人気がある。', 'That senior student is popular because they are good-looking.'),
    ('うまい', '母は料理がうまい。', 'My mother is good at cooking.'),
    ('うまい', '仕事のあとのビールはうまい。', 'Beer tastes good after work.'),
    ('うまい', '面接はうまくいきましたか。まあまあでした。', 'Did the interview go well? It went fairly well.'),
    ('親しい', '私は田中さんと親しい。', 'I am close to Tanaka.'),
    ('詳しい', 'この地図はとてもくわしい。', 'This map is very detailed.'),
    ('詳しい', '姉は映画にとてもくわしい。', 'My older sister knows a lot about movies.'),
    ('細かい', '新聞の字は細かくて、お年よりには読みづらい。', 'The print in newspapers is small and hard for older people to read.'),
    ('細かい', 'この書類を書くときには、細かい注意が必要だ。', 'Careful attention to detail is necessary when filling out this document.'),
    ('細かい', '細かいお金がないので、一万円でおつりをください。', 'I do not have any small change, so please give me change for a ten-thousand-yen note.')
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

-- Verification: L28 must contain 20 entries, 10 nouns, 10 adjectives,
-- no verb groups, and an example for every entry. An empty lesson reports CHECK.
SELECT
  b.book_name,
  28 AS lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%noun%' OR wt.type_name LIKE '%名詞%'
  ) AS noun_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%adjective%' OR wt.type_name LIKE '%形容詞%'
  ) AS adjective_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NULL) AS ungrouped_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE EXISTS (SELECT 1 FROM public.example_sentences e WHERE e.vocab_id = v.id)
  ) AS words_with_examples,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%noun%' OR wt.type_name LIKE '%名詞%'
     ) = 10
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%adjective%' OR wt.type_name LIKE '%形容詞%'
     ) = 10
     AND COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NULL) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE EXISTS (SELECT 1 FROM public.example_sentences e WHERE e.vocab_id = v.id)
     ) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.books b
LEFT JOIN public.vocabulary_books vb ON vb.book_id = b.id AND vb.lesson_number = 28
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
  AND vb.lesson_number = 28
ORDER BY v.word;
