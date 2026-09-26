-- ============================================================
-- 耳から覚える N3 - Words 321-340
-- Lesson L17 = words 321-340.
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
    ('節約', 'せつやく', 'saving; economizing', 'noun'),
    ('経営', 'けいえい', 'management; operation', 'noun'),
    ('反省', 'はんせい', 'reflection; remorse', 'noun'),
    ('実行', 'じっこう', 'implementation; practice', 'noun'),
    ('進歩', 'しんぽ', 'progress', 'noun'),
    ('変化', 'へんか', 'change', 'noun'),
    ('発達', 'はったつ', 'development', 'noun'),
    ('体力', 'たいりょく', 'physical strength', 'noun'),
    ('出場', 'しゅつじょう', 'participation; appearance', 'noun'),
    ('活躍', 'かつやく', 'activity; active performance', 'noun'),
    ('競争', 'きょうそう', 'competition', 'noun'),
    ('応援', 'おうえん', 'cheering; support', 'noun'),
    ('拍手', 'はくしゅ', 'applause', 'noun'),
    ('人気', 'にんき', 'popularity', 'noun'),
    ('うわさ', 'うわさ', 'rumor', 'noun'),
    ('情報', 'じょうほう', 'information', 'noun'),
    ('交換', 'こうかん', 'exchange; replacement', 'noun'),
    ('流行', 'りゅうこう', 'fashion; trend; spread', 'noun'),
    ('宣伝', 'せんでん', 'publicity; advertising', 'noun'),
    ('広告', 'こうこく', 'advertisement', 'noun')
  ) AS data(word, reading, meaning, word_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 17
  FROM public.vocabulary v
  WHERE v.word IN (
    '節約', '経営', '反省', '実行', '進歩', '変化', '発達', '体力', '出場', '活躍',
    '競争', '応援', '拍手', '人気', 'うわさ', '情報', '交換', '流行', '宣伝', '広告'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('節約', '生活費の節約をする。', 'Save on living expenses.'),
    ('経営', '父はスーパーを経営している。', 'My father runs a supermarket.'),
    ('反省', '1日の反省を日記に書く。', 'Write a reflection on the day in a diary.'),
    ('実行', 'この計画は実行が難しい。', 'This plan is difficult to implement.'),
    ('進歩', '英語を勉強しているが、進歩がない。', 'I am studying English, but I am making no progress.'),
    ('変化', '大きな変化が起きた。', 'A major change occurred.'),
    ('発達', '文明が発達する。', 'Civilization develops.'),
    ('体力', '若者の体力が低下している。', 'Young people''s physical strength is declining.'),
    ('出場', 'オリンピックへの出場が決まった。', 'My participation in the Olympics has been decided.'),
    ('活躍', '友だちは運動会で大活躍した。', 'My friend performed very actively at the sports day.'),
    ('競争', 'どちらがいい成績を取るか、友だちと競争した。', 'I competed with my friend to see who could get the better grades.'),
    ('応援', '自分の学校のチームを応援する。', 'Cheer for my school team.'),
    ('拍手', 'ステージの歌手に拍手をする。', 'Applaud the singer on stage.'),
    ('人気', '彼はクラスで一番人気がある。', 'He is the most popular person in the class.'),
    ('うわさ', 'クラスメートのうわさをしていたら、そこに本人が現れた。', 'While we were gossiping about a classmate, that person appeared there.'),
    ('情報', 'テレビからいろいろな情報を得る。', 'Get various kinds of information from television.'),
    ('交換', 'プレゼントを名刺や情報などと交換する。', 'Exchange presents for business cards, information, and so on.'),
    ('流行', '新しい流行の服が若者の間で流行している。', 'New fashionable clothes are in style among young people.'),
    ('宣伝', 'バーゲンセールの宣伝が始まった。', 'Advertising for the bargain sale has begun.'),
    ('広告', '新聞に新製品の広告がのっていた。', 'There was an advertisement for a new product in the newspaper.')
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

-- Verification: L17 must contain exactly 20 noun entries.
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
  AND vb.lesson_number = 17
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '節約', '経営', '反省', '実行', '進歩', '変化', '発達', '体力', '出場', '活躍',
  '競争', '応援', '拍手', '人気', 'うわさ', '情報', '交換', '流行', '宣伝', '広告'
)
ORDER BY word;
