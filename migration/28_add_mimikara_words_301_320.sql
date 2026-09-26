-- ============================================================
-- 耳から覚える N3 - Words 301-320
-- Lesson L16 = words 301-320.
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
    ('高まる', 'たかまる', 'rise; grow higher', 'verb'),
    ('高める', 'たかめる', 'raise; enhance', 'verb'),
    ('強まる', 'つよまる', 'strengthen; grow stronger', 'verb'),
    ('強める', 'つよめる', 'strengthen; reinforce; confirm', 'verb'),
    ('弱まる', 'よわまる', 'weaken', 'verb'),
    ('弱める', 'よわめる', 'weaken; reduce', 'verb'),
    ('広まる', 'ひろまる', 'spread', 'verb'),
    ('広める', 'ひろめる', 'spread; popularize', 'verb'),
    ('深まる', 'ふかまる', 'deepen', 'verb'),
    ('深める', 'ふかめる', 'deepen; cultivate', 'verb'),
    ('世話', 'せわ', 'care; support', 'noun'),
    ('家庭', 'かてい', 'home; household', 'noun'),
    ('協力', 'きょうりょく', 'cooperation', 'noun'),
    ('感謝', 'かんしゃ', 'gratitude; thanks', 'noun'),
    ('お礼', 'おれい', 'token of gratitude; appreciation', 'noun'),
    ('お詫び', 'おわび', 'apology', 'noun'),
    ('おじぎ', 'おじぎ', 'bow', 'noun'),
    ('握手', 'あくしゅ', 'handshake', 'noun'),
    ('いじわる', 'いじわる', 'spite; meanness', 'noun'),
    ('いたずら', 'いたずら', 'prank; mischief', 'noun')
  ) AS data(word, reading, meaning, word_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 16
  FROM public.vocabulary v
  WHERE v.word IN (
    '高まる', '高める', '強まる', '強める', '弱まる', '弱める', '広まる', '広める', '深まる', '深める',
    '世話', '家庭', '協力', '感謝', 'お礼', 'お詫び', 'おじぎ', '握手', 'いじわる', 'いたずら'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('高まる', '台風が近づき、波が高まっている。', 'A typhoon is approaching, and the waves are rising.'),
    ('高める', '若者はもっとコミュニケーション能力を高める必要がある。', 'Young people need to further improve their communication skills.'),
    ('強まる', '台風の勢力はますます強まっている。', 'The typhoon is growing stronger and stronger.'),
    ('強める', '火、力、自信などを強める。', 'Strengthen a fire, force, confidence, and so on.'),
    ('弱まる', '疲れていると抵抗力が弱まって、かぜにかかりやすくなる。', 'When you are tired, your resistance weakens and you become more susceptible to colds.'),
    ('弱める', '材料がやわらかくなったら、火を弱めてゆっくり煮込んでください。', 'When the ingredients become soft, lower the heat and simmer them slowly.'),
    ('広まる', 'そのうわさは1日で会社中に広まった。', 'The rumor spread throughout the company in one day.'),
    ('広める', '明治時代に、ヨーロッパから帰国した留学生たちが、日本に西洋文化を広めた。', 'During the Meiji era, students returning from Europe spread Western culture in Japan.'),
    ('深まる', '子どもができて、二人の愛情はますます深まった。', 'After having a child, the couple''s love deepened further.'),
    ('深める', '交流、友情、理解などを深める。', 'Deepen exchanges, friendship, understanding, and so on.'),
    ('世話', 'うちではペットの世話は私の仕事だ。', 'Taking care of the pets is my job at home.'),
    ('家庭', '早く結婚して、あたたかい家庭を持ちたい。', 'I want to get married soon and have a warm family home.'),
    ('協力', '家族で協力して祖母の介護をした。', 'The family cooperated to care for our grandmother.'),
    ('感謝', 'アドバイスをしてくれた先輩に、とても感謝している。', 'I am very grateful to my senior for giving me advice.'),
    ('お礼', 'お世話になった方にお礼をした。', 'I expressed my gratitude to the person who helped me.'),
    ('お詫び', '迷惑をかけた人にお詫びをした。', 'I apologized to the person I caused trouble for.'),
    ('おじぎ', 'お客様にはていねいにおじぎをしましょう。', 'Let us bow politely to customers.'),
    ('握手', 'コンサートで歌手と握手した。', 'I shook hands with the singer at the concert.'),
    ('いじわる', '好きな子にはついいじわるをしてしまう。', 'I end up teasing the person I like.'),
    ('いたずら', 'いたずらをして、先生に怒られた。', 'I played a prank and was scolded by the teacher.')
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

-- Verification: L16 must contain exactly 20 entries: 10 verbs and 10 nouns.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%verb%'
       OR wt.type_name LIKE '%動詞%'
  ) AS verb_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%noun%'
       OR wt.type_name LIKE '%名詞%'
  ) AS noun_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%verb%'
          OR wt.type_name LIKE '%動詞%'
     ) = 10
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%noun%'
          OR wt.type_name LIKE '%名詞%'
     ) = 10
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 16
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '高まる', '高める', '強まる', '強める', '弱まる', '弱める', '広まる', '広める', '深まる', '深める',
  '世話', '家庭', '協力', '感謝', 'お礼', 'お詫び', 'おじぎ', '握手', 'いじわる', 'いたずら'
)
ORDER BY word;
