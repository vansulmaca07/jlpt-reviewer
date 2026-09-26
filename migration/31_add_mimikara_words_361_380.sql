-- ============================================================
-- 耳から覚える N3 - Words 361-380
-- Lesson L19 = words 361-380.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

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

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT data.word, data.reading, data.meaning, v_noun_type_id, v_n3_level_id
  FROM (VALUES
    ('感動', 'かんどう', 'being moved; being touched', 'noun'),
    ('興奮', 'こうふん', 'excitement', 'noun'),
    ('感想', 'かんそう', 'impression; feeling', 'noun'),
    ('予想', 'よそう', 'forecast; prediction', 'noun'),
    ('専門', 'せんもん', 'specialty; expertise', 'noun'),
    ('研究', 'けんきゅう', 'research; study', 'noun'),
    ('調査', 'ちょうさ', 'investigation; survey', 'noun'),
    ('原因', 'げんいん', 'cause', 'noun'),
    ('結果', 'けっか', 'result', 'noun'),
    ('解決', 'かいけつ', 'solution; resolution', 'noun'),
    ('確認', 'かくにん', 'confirmation; checking', 'noun'),
    ('利用', 'りよう', 'use; utilization', 'noun'),
    ('理解', 'りかい', 'understanding', 'noun'),
    ('発見', 'はっけん', 'discovery', 'noun'),
    ('発明', 'はつめい', 'invention', 'noun'),
    ('関係', 'かんけい', 'relationship; connection', 'noun'),
    ('団体', 'だんたい', 'group; organization', 'noun'),
    ('選挙', 'せんきょ', 'election', 'noun'),
    ('税金', 'ぜいきん', 'tax', 'noun'),
    ('責任', 'せきにん', 'responsibility', 'noun')
  ) AS data(word, reading, meaning, word_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 19
  FROM public.vocabulary v
  WHERE v.word IN (
    '感動', '興奮', '感想', '予想', '専門', '研究', '調査', '原因', '結果', '解決',
    '確認', '利用', '理解', '発見', '発明', '関係', '団体', '選挙', '税金', '責任'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('感動', 'パラリンピックを見て、とても感動した。', 'I was deeply moved watching the Paralympics.'),
    ('興奮', '試合を見ていた観客たちは、興奮して大声を出した。', 'The spectators watching the game got excited and shouted loudly.'),
    ('感想', '「ご感想はいかがですか」「すばらしかったです」', '"What did you think?" "It was wonderful."'),
    ('予想', '選挙の結果を予想する。', 'Predict the election results.'),
    ('専門', '専門は言語学です。', 'My specialty is linguistics.'),
    ('研究', '私は大学で日本の政治を研究している。', 'I study Japanese politics at university.'),
    ('調査', '調査を行う。', 'Conduct an investigation.'),
    ('原因', '今、警察が事故の原因を調べている。', 'The police are currently investigating the cause of the accident.'),
    ('結果', '1位になりたかったが、結果は3位だった。', 'I wanted to come in first, but the result was third place.'),
    ('解決', '大きな問題が解決した。', 'A major problem was resolved.'),
    ('確認', 'まちがいがないかどうかを確認する。', 'Check whether there are any mistakes.'),
    ('利用', '水不足なので、水道の利用を減らした。', 'Because of the water shortage, I reduced my use of tap water.'),
    ('理解', '意味の理解や内容を深く理解する。', 'Deeply understand the meaning and content.'),
    ('発見', '大きな発見、新しい種類の動物を発見した。', 'A major discovery: I discovered a new species of animal.'),
    ('発明', 'ベルは電話を発明した。', 'Bell invented the telephone.'),
    ('関係', 'あの二人は先輩・後輩の関係だ。', 'Those two have a senior-junior relationship.'),
    ('団体', '博物館で団体のチケットを買う。', 'Buy a group ticket at the museum.'),
    ('選挙', '1月に選挙が行われる。', 'An election will be held in January.'),
    ('税金', '年度末に税金を払う。', 'Pay taxes at the end of the fiscal year.'),
    ('責任', '事故の責任を追及する。', 'Pursue responsibility for the accident.')
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

-- Verification: L19 must contain exactly 20 noun entries.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%noun%'
       OR wt.type_name LIKE '%名詞%'
  ) AS noun_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%noun%'
          OR wt.type_name LIKE '%名詞%'
     ) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 19
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '感動', '興奮', '感想', '予想', '専門', '研究', '調査', '原因', '結果', '解決',
  '確認', '利用', '理解', '発見', '発明', '関係', '団体', '選挙', '税金', '責任'
)
ORDER BY word;
