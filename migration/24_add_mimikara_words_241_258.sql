-- ============================================================
-- 耳から覚える N3 - Words 241-258
-- Lesson L13 = words 241-258.
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
    ('帰り', 'かえり', 'return; going home', 'Group 1 (Godan)'),
    ('急ぎ', 'いそぎ', 'urgency', 'Group 1 (Godan)'),
    ('遅れ', 'おくれ', 'delay', 'Group 2 (Ichidan)'),
    ('貸し', 'かし', 'loan; lending', 'Group 1 (Godan)'),
    ('借り', 'かり', 'debt; borrowing', 'Group 1 (Godan)'),
    ('勝ち', 'かち', 'victory', 'Group 1 (Godan)'),
    ('負け', 'まけ', 'defeat', 'Group 2 (Ichidan)'),
    ('迎え', 'むかえ', 'picking up; going to meet', 'Group 2 (Ichidan)'),
    ('始まり', 'はじまり', 'beginning', 'Group 1 (Godan)'),
    ('終わり', 'おわり', 'end', 'Group 1 (Godan)'),
    ('戻り', 'もどり', 'return', 'Group 1 (Godan)'),
    ('別れ', 'わかれ', 'parting', 'Group 2 (Ichidan)'),
    ('喜び', 'よろこび', 'joy', 'Group 1 (Godan)'),
    ('楽しみ', 'たのしみ', 'fun; enjoyment', 'Group 1 (Godan)'),
    ('笑い', 'わらい', 'laughter', 'Group 1 (Godan)'),
    ('驚き', 'おどろき', 'surprise', 'Group 2 (Ichidan)'),
    ('怒り', 'いかり', 'anger', 'Group 1 (Godan)'),
    ('悲しみ', 'かなしみ', 'sadness', 'Group 1 (Godan)')
  ) AS data(word, reading, meaning, source_verb_group)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 13
  FROM public.vocabulary v
  WHERE v.word IN (
    '帰り', '急ぎ', '遅れ', '貸し', '借り', '勝ち', '負け', '迎え', '始まり', '終わり',
    '戻り', '別れ', '喜び', '楽しみ', '笑い', '驚き', '怒り', '悲しみ'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('帰り', '旅行は、行きは新幹線、帰りは飛行機だった。', 'For the trip, I took the bullet train there and a plane back.'),
    ('急ぎ', '急ぎの仕事が入った。', 'An urgent job came in.'),
    ('遅れ', '電車に3分の遅れが出た。', 'The train was delayed by three minutes.'),
    ('貸し', 'あの人には10万円の貸しがある。', 'That person owes me 100,000 yen.'),
    ('借り', '借りは返さなければならない。', 'A debt must be repaid.'),
    ('勝ち', 'きのうの試合はAチームの勝ちだった。', 'Yesterday''s game was a victory for Team A.'),
    ('負け', '負けが続いて、いやになった。', 'I got fed up after a string of losses.'),
    ('迎え', '迎えの車がなかなか来ない。', 'The car coming to pick me up is not arriving.'),
    ('始まり', '映画の始まりに間に合わなかった。', 'I did not make it in time for the beginning of the movie.'),
    ('終わり', '夏休みはもうすぐ終わりだ。', 'Summer vacation will end soon.'),
    ('戻り', 'きょうの戻りは3時ごろになります。', 'I will return around three today.'),
    ('別れ', '日本では3月が別れの季節だ。', 'In Japan, March is the season of farewells.'),
    ('喜び', '優勝できて、喜びでいっぱいだ。', 'I am full of joy because I won the championship.'),
    ('楽しみ', '来週のパーティーを楽しみにしている。', 'I am looking forward to next week''s party.'),
    ('笑い', '歌手の冗談で会場に笑いが起きた。', 'The singer''s joke caused laughter in the venue.'),
    ('驚き', 'この大きな家がたったの100万円とは驚きだ。', 'It is surprising that this large house costs only one million yen.'),
    ('怒り', '殺人のニュースに怒りを感じた。', 'I felt anger at the news of the murder.'),
    ('悲しみ', '愛犬を亡くした悲しみが消えない。', 'The sadness of losing my beloved dog will not go away.')
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

-- Verification: L13 must contain exactly 18 noun entries.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%noun%'
       OR wt.type_name LIKE '%名詞%'
  ) AS noun_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 18
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%noun%'
          OR wt.type_name LIKE '%名詞%'
     ) = 18
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 13
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '帰り', '急ぎ', '遅れ', '貸し', '借り', '勝ち', '負け', '迎え', '始まり', '終わり',
  '戻り', '別れ', '喜び', '楽しみ', '笑い', '驚き', '怒り', '悲しみ'
)
ORDER BY word;
