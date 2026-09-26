-- ============================================================
-- 耳から覚える N3 - Words 221-240
-- Lesson L12 = words 221-240.
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
    ('飾り', 'かざり', 'decoration', 'Group 1 (Godan)'),
    ('遊び', 'あそび', 'game; play', 'Group 1 (Godan)'),
    ('集まり', 'あつまり', 'gathering', 'Group 1 (Godan)'),
    ('教え', 'おしえ', 'teachings', 'Group 2 (Ichidan)'),
    ('踊り', 'おどり', 'dance', 'Group 1 (Godan)'),
    ('思い', 'おもい', 'thought; feeling', 'Group 1 (Godan)'),
    ('考え', 'かんがえ', 'thought; idea', 'Group 2 (Ichidan)'),
    ('片づけ', 'かたづけ', 'tidying; disposal', 'Group 2 (Ichidan)'),
    ('手伝い', 'てつだい', 'help', 'Group 1 (Godan)'),
    ('働き', 'はたらき', 'function; action', 'Group 1 (Godan)'),
    ('決まり', 'きまり', 'rule', 'Group 1 (Godan)'),
    ('騒ぎ', 'さわぎ', 'commotion; trouble', 'Group 1 (Godan)'),
    ('知らせ', 'しらせ', 'notification; news', 'Group 2 (Ichidan)'),
    ('頼み', 'たのみ', 'request', 'Group 1 (Godan)'),
    ('疲れ', 'つかれ', 'fatigue', 'Group 2 (Ichidan)'),
    ('違い', 'ちがい', 'difference', 'Group 1 (Godan)'),
    ('始め', 'はじめ', 'beginning', 'Group 2 (Ichidan)'),
    ('続き', 'つづき', 'continuation; remainder', 'Group 1 (Godan)'),
    ('暮れ', 'くれ', 'end of the year', 'Group 2 (Ichidan)'),
    ('行き', 'いき', 'going; bound for', 'Group 1 (Godan)')
  ) AS data(word, reading, meaning, source_verb_group)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 12
  FROM public.vocabulary v
  WHERE v.word IN (
    '飾り', '遊び', '集まり', '教え', '踊り', '思い', '考え', '片づけ', '手伝い', '働き',
    '決まり', '騒ぎ', '知らせ', '頼み', '疲れ', '違い', '始め', '続き', '暮れ', '行き'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('飾り', 'クリスマスの飾りを買った。', 'I bought Christmas decorations.'),
    ('遊び', 'かくれんぼは子どもの遊びだ。', 'Hide-and-seek is a children''s game.'),
    ('集まり', 'あした、マンションの住人の集まりがある。', 'There is a gathering of apartment residents tomorrow.'),
    ('教え', '母の教えを今でも思い出す。', 'I still remember my mother''s teachings.'),
    ('踊り', '留学生が各国の踊りを踊った。', 'International students danced dances from their countries.'),
    ('思い', 'あの人に私の思いが届いた。', 'My feelings reached that person.'),
    ('考え', '私にいい考えがある。', 'I have a good idea.'),
    ('片づけ', '私は片づけが苦手だ。', 'I am bad at tidying up.'),
    ('手伝い', '引っ越しの手伝いをする。', 'I help with the move.'),
    ('働き', '血液の働きの一つは、体に栄養を運ぶことだ。', 'One function of blood is to carry nutrients through the body.'),
    ('決まり', '学校で新しい決まりが作られた。', 'A new rule was made at school.'),
    ('騒ぎ', 'きのう、駅前で騒ぎがあった。', 'There was a commotion in front of the station yesterday.'),
    ('知らせ', '父が入院したという知らせがあった。', 'I received news that my father had been hospitalized.'),
    ('頼み', 'あなたに頼みがあるんです。', 'I have a request for you.'),
    ('疲れ', '仕事で疲れがたまっている。', 'Fatigue has built up from work.'),
    ('違い', 'この二つの違いがわからない。', 'I do not understand the difference between these two.'),
    ('始め', '本を始めから終わりまで全部読んだ。', 'I read the entire book from beginning to end.'),
    ('続き', '早く本の続きが読みたい。', 'I want to read the continuation of the book soon.'),
    ('暮れ', '年の暮れは忙しい。', 'The end of the year is busy.'),
    ('行き', '東京行きの電車に乗る。', 'I take a train bound for Tokyo.')
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

-- Verification: L12 must contain exactly 20 noun entries.
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
  AND vb.lesson_number = 12
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '飾り', '遊び', '集まり', '教え', '踊り', '思い', '考え', '片づけ', '手伝い', '働き',
  '決まり', '騒ぎ', '知らせ', '頼み', '疲れ', '違い', '始め', '続き', '暮れ', '行き'
)
ORDER BY word;
