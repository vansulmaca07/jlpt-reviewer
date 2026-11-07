-- ============================================================
-- 耳から覚える N3 - Words 521-540
-- Lesson L27 = words 521-540: 20 noun entries.
-- デザイン is a noun that can take する.
-- Abbreviations are recorded in meanings, not as separate entries.
-- Examples for バイク, コンタクトレンズ, and コンビニエンスストア
-- are original sentences; the screenshots have no full examples for them.
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

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run migrations 06-10 first.';
  END IF;
  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 not found in jlpt_levels.';
  END IF;
  IF v_noun_type_id IS NULL THEN
    RAISE EXCEPTION 'Noun not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id, verb_group)
  SELECT data.word, data.reading, data.meaning, v_noun_type_id, v_n3_level_id, NULL
  FROM (VALUES
    ('スピード', 'スピード', 'speed'),
    ('ラッシュ', 'ラッシュ', 'rush; rush hour; peak travel rush'),
    ('バイク', 'バイク', 'motorcycle; motorbike'),
    ('ヘルメット', 'ヘルメット', 'helmet'),
    ('コンタクトレンズ', 'コンタクトレンズ', 'contact lens (コンタクト)'),
    ('ガラス', 'ガラス', 'glass; pane of glass'),
    ('プラスチック', 'プラスチック', 'plastic'),
    ('ベランダ', 'ベランダ', 'balcony; veranda'),
    ('ペット', 'ペット', 'pet'),
    ('ベンチ', 'ベンチ', 'bench'),
    ('デザイン', 'デザイン', 'design (can take する: design something)'),
    ('バーゲンセール', 'バーゲンセール', 'bargain sale; sale (バーゲン; セール)'),
    ('パート', 'パート', 'part-time job; part (in music, etc.)'),
    ('コンビニエンスストア', 'コンビニエンスストア', 'convenience store (コンビニ)'),
    ('レジ', 'レジ', 'cash register; checkout (short for レジスター)'),
    ('レシート', 'レシート', 'receipt'),
    ('インスタント', 'インスタント', 'instant (food, coffee, etc.)'),
    ('ファストフード', 'ファストフード', 'fast food'),
    ('フルーツ', 'フルーツ', 'fruit'),
    ('デザート', 'デザート', 'dessert')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 27
  FROM public.vocabulary v
  WHERE v.word IN (
    'スピード', 'ラッシュ', 'バイク', 'ヘルメット', 'コンタクトレンズ',
    'ガラス', 'プラスチック', 'ベランダ', 'ペット', 'ベンチ',
    'デザイン', 'バーゲンセール', 'パート', 'コンビニエンスストア', 'レジ',
    'レシート', 'インスタント', 'ファストフード', 'フルーツ', 'デザート'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('スピード', '先生の話すスピードが速すぎて理解できない。', 'The teacher speaks too fast for me to understand.'),
    ('ラッシュ', '年末年始は、帰省ラッシュでチケットがとりにくい。', 'It is hard to get tickets during the year-end and New Year holidays because of the rush of people returning to their hometowns.'),
    ('ラッシュ', 'ラッシュの時間帯に電車に乗るのは大変だ。', 'It is tough to ride the train during rush hour.'),
    ('バイク', '週末はバイクで海まで行く。', 'On weekends, I ride my motorcycle to the sea.'),
    ('ヘルメット', 'バイクに乗るときは、ヘルメットをかぶる。', 'Wear a helmet when riding a motorcycle.'),
    ('コンタクトレンズ', '寝る前にコンタクトレンズをはずす。', 'Take out your contact lenses before going to bed.'),
    ('ガラス', 'ボールをぶつけて窓ガラスを割ってしまった。', 'I accidentally broke a windowpane by hitting it with a ball.'),
    ('プラスチック', 'プラスチック製品は生ごみの中に入れないでください。', 'Please do not put plastic products in with food waste.'),
    ('ベランダ', 'ベランダに洗たく物を干す。', 'Hang the laundry on the balcony.'),
    ('ペット', 'アパートなので、ペットが飼えない。', 'I cannot keep a pet because I live in an apartment.'),
    ('ベンチ', '公園のベンチで休む。', 'Rest on a bench in the park.'),
    ('デザイン', 'あのドレスは色もデザインもいい。', 'That dress has both a nice color and a nice design.'),
    ('バーゲンセール', 'デパートで今バーゲンセールをしている。', 'The department store is having a sale now.'),
    ('パート', '母は週三日、スーパーでパートをしている。', 'My mother works part-time at a supermarket three days a week.'),
    ('パート', '合唱でソプラノのパートを歌っている。', 'I sing the soprano part in a choir.'),
    ('コンビニエンスストア', '駅前のコンビニエンスストアでおにぎりを買った。', 'I bought a rice ball at the convenience store in front of the station.'),
    ('レジ', 'スーパーでレジのアルバイトをしている。', 'I work part-time at the checkout in a supermarket.'),
    ('レシート', 'レジでお金を払って、レシートを受け取る。', 'Pay at the checkout and receive a receipt.'),
    ('インスタント', 'インスタント食品は便利だ。', 'Instant foods are convenient.'),
    ('ファストフード', 'そばは江戸時代のファストフードだった。', 'Soba was the fast food of the Edo period.'),
    ('フルーツ', '暖かいところには、いろいろなフルーツがある。', 'There are many kinds of fruit in warm places.'),
    ('デザート', 'デザートにアイスクリームを食べる。', 'Eat ice cream for dessert.')
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

-- Verification: L27 must contain 20 nouns with no verb groups,
-- and at least one example for every entry. An empty lesson reports CHECK.
SELECT
  b.book_name,
  27 AS lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
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
       WHERE (LOWER(wt.type_name) LIKE '%noun%' OR wt.type_name LIKE '%名詞%')
         AND v.verb_group IS NULL
     ) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE EXISTS (SELECT 1 FROM public.example_sentences e WHERE e.vocab_id = v.id)
     ) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.books b
LEFT JOIN public.vocabulary_books vb ON vb.book_id = b.id AND vb.lesson_number = 27
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
  AND vb.lesson_number = 27
ORDER BY v.word;
