-- ============================================================
-- 耳から覚える N3 - Words 281-300
-- Lesson L15 = words 281-300.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_adjective_type_id INTEGER;
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

  SELECT id INTO v_adjective_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%adjective%'
     OR type_name LIKE '%形容詞%'
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
  IF v_adjective_type_id IS NULL THEN
    RAISE EXCEPTION 'Adjective not found in word_types.';
  END IF;
  IF v_verb_type_id IS NULL THEN
    RAISE EXCEPTION 'Verb not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT
    data.word,
    data.reading,
    data.meaning,
    CASE WHEN data.word_type = 'adjective' THEN v_adjective_type_id ELSE v_verb_type_id END,
    v_n3_level_id
  FROM (VALUES
    ('大変な', 'たいへんな', 'tough; awful; difficult', 'adjective'),
    ('無理な', 'むりな', 'impossible; unreasonable; forced', 'adjective'),
    ('不注意な', 'ふちゅういな', 'careless; inattentive', 'adjective'),
    ('楽な', 'らくな', 'easy; comfortable', 'adjective'),
    ('めんどうな', 'めんどうな', 'troublesome; bothersome', 'adjective'),
    ('失礼な', 'しつれいな', 'rude; impolite', 'adjective'),
    ('当然な', 'とうぜんな', 'natural; expected; only reasonable', 'adjective'),
    ('意外な', 'いがいな', 'unexpected; surprising', 'adjective'),
    ('けっこうな', 'けっこうな', 'nice; fine; no, thank you', 'adjective'),
    ('派手な', 'はでな', 'flashy; fancy', 'adjective'),
    ('地味な', 'じみな', 'plain; subdued', 'adjective'),
    ('おしゃれな', 'おしゃれな', 'stylish; fashionable', 'adjective'),
    ('変な', 'へんな', 'strange; odd', 'adjective'),
    ('不思議な', 'ふしぎな', 'strange; mysterious; miraculous', 'adjective'),
    ('ましな', 'ましな', 'preferable; better', 'adjective'),
    ('むだな', 'むだな', 'futile; wasteful', 'adjective'),
    ('自由な', 'じゆうな', 'free; unrestricted', 'adjective'),
    ('不自由な', 'ふじゆうな', 'inconvenient; impaired', 'adjective'),
    ('暖まる', 'あたたまる', 'become warm', 'verb'),
    ('暖める', 'あたためる', 'warm; heat', 'verb')
  ) AS data(word, reading, meaning, word_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 15
  FROM public.vocabulary v
  WHERE v.word IN (
    '大変な', '無理な', '不注意な', '楽な', 'めんどうな', '失礼な', '当然な', '意外な', 'けっこうな', '派手な',
    '地味な', 'おしゃれな', '変な', '不思議な', 'ましな', 'むだな', '自由な', '不自由な', '暖まる', '暖める'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('大変な', '子育て中のお母さんは大変だ。', 'Mothers raising children have a tough time.'),
    ('無理な', 'たった100万円で家を建てるなんて無理な話だ。', 'Building a house for only one million yen is impossible.'),
    ('不注意な', '疲れると不注意なミスが多くなる。', 'When I get tired, I make more careless mistakes.'),
    ('楽な', 'もう少し楽な暮らしがしたい。', 'I want to live a more comfortable life.'),
    ('めんどうな', '雨が降っているので、出かけるのがめんどうだ。', 'It is troublesome to go out because it is raining.'),
    ('失礼な', 'あいさつしても返事をしない。なんて失礼な人だろう。', 'He does not reply even when I greet him. What a rude person.'),
    ('当然な', 'お金を借りたら、返すのが当然だ。', 'If you borrow money, it is only natural to repay it.'),
    ('意外な', '事故を調査するうちに意外な事実がわかった。', 'While investigating the accident, an unexpected fact came to light.'),
    ('けっこうな', '「お味はどうですか」「けっこうです」', '"How does it taste?" "It is fine, thank you."'),
    ('派手な', 'この服は派手すぎる。', 'These clothes are too flashy.'),
    ('地味な', 'あの人は若いのに、地味な格好ばかりしている。', 'Although that person is young, they always dress plainly.'),
    ('おしゃれな', '彼女はいつもスーツをおしゃれに着こなしている。', 'She always wears her suits stylishly.'),
    ('変な', '変なメールが届いたので、すぐに消した。', 'A strange email arrived, so I deleted it immediately.'),
    ('不思議な', 'この村には不思議な話が伝わっている。', 'A mysterious story has been passed down in this village.'),
    ('ましな', 'せきがひどかったが、うがいをしたら前よりましになった。', 'My cough was bad, but gargling made it better than before.'),
    ('むだな', '落ちるとわかっているのに試験を受けるのはむだなことだ。', 'Taking an exam when you know you will fail is pointless.'),
    ('自由な', '赤ちゃんがいるので、自由な時間がほとんどない。', 'Because I have a baby, I have almost no free time.'),
    ('不自由な', '地震でガスと電気が止まり、しばらく不自由な生活をした。', 'The earthquake stopped the gas and electricity, so I lived inconveniently for a while.'),
    ('暖まる', 'お風呂に入ると体が暖まる。', 'When you take a bath, your body warms up.'),
    ('暖める', 'エアコンをつけて部屋を暖める。', 'Turn on the air conditioner and warm the room.')
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

-- Verification: L15 must contain exactly 20 entries: 18 adjectives and 2 verbs.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%adjective%'
       OR wt.type_name LIKE '%形容詞%'
  ) AS adjective_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%verb%'
       OR wt.type_name LIKE '%動詞%'
  ) AS verb_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%adjective%'
          OR wt.type_name LIKE '%形容詞%'
     ) = 18
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%verb%'
          OR wt.type_name LIKE '%動詞%'
     ) = 2
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 15
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '大変な', '無理な', '不注意な', '楽な', 'めんどうな', '失礼な', '当然な', '意外な', 'けっこうな', '派手な',
  '地味な', 'おしゃれな', '変な', '不思議な', 'ましな', 'むだな', '自由な', '不自由な', '暖まる', '暖める'
)
ORDER BY word;
