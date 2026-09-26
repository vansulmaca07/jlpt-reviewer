-- ============================================================
-- 耳から覚える N3 - Words 261-280
-- Lesson L14 = words 261-280.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

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

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT data.word, data.reading, data.meaning, v_adjective_type_id, v_n3_level_id
  FROM (VALUES
    ('苦手な', 'にがてな', 'weak at; uncomfortable; unable to take', 'な-adjective'),
    ('熱心な', 'ねっしんな', 'passionate; enthusiastic', 'な-adjective'),
    ('夢中な', 'むちゅうな', 'crazy about; enamored', 'な-adjective'),
    ('退屈な', 'たいくつな', 'boring; bored', 'な-adjective'),
    ('健康な', 'けんこうな', 'healthy', 'な-adjective'),
    ('苦しい', 'くるしい', 'rough; agonizing; painful', 'い-adjective'),
    ('平気な', 'へいきな', 'unfazed; brazen; unconcerned', 'な-adjective'),
    ('悔しい', 'くやしい', 'frustrating; regrettable', 'い-adjective'),
    ('うらやましい', 'うらやましい', 'envious', 'い-adjective'),
    ('かゆい', 'かゆい', 'itchy', 'い-adjective'),
    ('おとなしい', 'おとなしい', 'quiet; subdued', 'い-adjective'),
    ('がまん強い', 'がまんづよい', 'perseverant; patient', 'い-adjective'),
    ('正直な', 'しょうじきな', 'honest', 'な-adjective'),
    ('けちな', 'けちな', 'stingy; miserly', 'な-adjective'),
    ('わがままな', 'わがままな', 'selfish', 'な-adjective'),
    ('積極的な', 'せっきょくてきな', 'active; positive; proactive', 'な-adjective'),
    ('消極的な', 'しょうきょくてきな', 'passive; negative', 'な-adjective'),
    ('満足な', 'まんぞくな', 'satisfying; contented', 'な-adjective'),
    ('不満な', 'ふまんな', 'dissatisfying; discontented', 'な-adjective'),
    ('不安な', 'ふあんな', 'worrisome; uneasy', 'な-adjective')
  ) AS data(word, reading, meaning, adjective_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 14
  FROM public.vocabulary v
  WHERE v.word IN (
    '苦手な', '熱心な', '夢中な', '退屈な', '健康な', '苦しい', '平気な', '悔しい', 'うらやましい', 'かゆい',
    'おとなしい', 'がまん強い', '正直な', 'けちな', 'わがままな', '積極的な', '消極的な', '満足な', '不満な', '不安な'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('苦手な', '私は山本さんが苦手だ。', 'I am uncomfortable around Yamamoto.'),
    ('熱心な', '熱心な仕事ぶりが認められて昇進した。', 'My enthusiastic work was recognized and I was promoted.'),
    ('夢中な', '子どものころ、SF漫画に夢中になった。', 'When I was a child, I was crazy about science-fiction manga.'),
    ('退屈な', 'きょうは、何もすることがなくて退屈だ。', 'Today I am bored because there is nothing to do.'),
    ('健康な', '毎日運動をしていたら、とても健康になった。', 'I became very healthy after exercising every day.'),
    ('苦しい', '苦しい試合だったが、なんとか勝つことができた。', 'It was a difficult match, but somehow we managed to win.'),
    ('平気な', '彼女は、どんなに悪口を言われても平気な顔をしている。', 'No matter how much people insult her, she keeps an unfazed expression.'),
    ('悔しい', '何度練習してもうまくできなくて、悔しい。', 'It is frustrating that I cannot do it well no matter how many times I practice.'),
    ('うらやましい', '才能の豊かな人がうらやましい。', 'I envy people who are rich in talent.'),
    ('かゆい', '蚊に刺されて首がかゆい。', 'My neck is itchy from a mosquito bite.'),
    ('おとなしい', 'うちの犬はおとなしくて、決して人にほえない。', 'My dog is quiet and never barks at people.'),
    ('がまん強い', 'チャンスがやって来るのをがまん強く待つ。', 'Wait patiently for an opportunity to come.'),
    ('正直な', '彼は正直な人だから、うそをつくことができない。', 'He is an honest person, so he cannot tell lies.'),
    ('けちな', 'あの人はとてもけちだ。', 'That person is very stingy.'),
    ('わがままな', '彼女はわがままだ。', 'She is selfish.'),
    ('積極的な', '日本語を身につけるため、積極的に日本人の友だちを作った。', 'To learn Japanese, I proactively made Japanese friends.'),
    ('消極的な', '今の首相は、教育問題に消極的だ。', 'The current prime minister is passive about education issues.'),
    ('満足な', 'アルバイトだけでは満足な収入は得られない。', 'You cannot earn a satisfactory income from a part-time job alone.'),
    ('不満な', 'この仕事に不満な点はない。', 'There are no points about this job that I am dissatisfied with.'),
    ('不安な', '新しい仕事がなかなか見つからず、不安な毎日を過ごしている。', 'I spend uneasy days because I cannot find a new job.')
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

-- Verification: L14 must contain exactly 20 adjective entries.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%adjective%'
       OR wt.type_name LIKE '%形容詞%'
  ) AS adjective_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%adjective%'
          OR wt.type_name LIKE '%形容詞%'
     ) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 14
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '苦手な', '熱心な', '夢中な', '退屈な', '健康な', '苦しい', '平気な', '悔しい', 'うらやましい', 'かゆい',
  'おとなしい', 'がまん強い', '正直な', 'けちな', 'わがままな', '積極的な', '消極的な', '満足な', '不満な', '不安な'
)
ORDER BY word;
