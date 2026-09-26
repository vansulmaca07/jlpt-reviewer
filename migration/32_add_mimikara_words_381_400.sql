-- ============================================================
-- 耳から覚える N3 - Words 381-400
-- Lesson L20 = words 381-400.
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
    ('書類', 'しょるい', 'form; document', 'noun'),
    ('題名', 'だいめい', 'title', 'noun'),
    ('条件', 'じょうけん', 'condition; terms', 'noun'),
    ('締め切り', 'しめきり', 'deadline; closing date', 'noun'),
    ('期間', 'きかん', 'period', 'noun'),
    ('倍', 'ばい', 'double; times', 'noun'),
    ('くじ', 'くじ', 'lottery; drawing', 'noun'),
    ('近道', 'ちかみち', 'shortcut', 'noun'),
    ('中心', 'ちゅうしん', 'center', 'noun'),
    ('あたり', 'あたり', 'surroundings; around', 'noun'),
    ('周り', 'まわり', 'circumference; surroundings', 'noun'),
    ('穴', 'あな', 'hole', 'noun'),
    ('列', 'れつ', 'line; row', 'noun'),
    ('幅', 'はば', 'width; range', 'noun'),
    ('範囲', 'はんい', 'scope; extent', 'noun'),
    ('内容', 'ないよう', 'content', 'noun'),
    ('中身', 'なかみ', 'contents; gist', 'noun'),
    ('特徴', 'とくちょう', 'feature; distinctiveness', 'noun'),
    ('普通', 'ふつう', 'ordinary; normal', 'noun'),
    ('当たり前', 'あたりまえ', 'natural; obvious; taken for granted', 'noun')
  ) AS data(word, reading, meaning, word_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 20
  FROM public.vocabulary v
  WHERE v.word IN (
    '書類', '題名', '条件', '締め切り', '期間', '倍', 'くじ', '近道', '中心', 'あたり',
    '周り', '穴', '列', '幅', '範囲', '内容', '中身', '特徴', '普通', '当たり前'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('書類', '留学の手続きに必要な書類を準備する。', 'Prepare the documents needed for study-abroad procedures.'),
    ('題名', 'コンクールに出す作品に題名をつける。', 'Give a title to the work submitted to the contest.'),
    ('条件', '運転免許を持っていることが採用の条件だ。', 'Having a driver''s license is a condition for employment.'),
    ('締め切り', 'レポートの締め切りは30日です。', 'The report deadline is the 30th.'),
    ('期間', '申し込み期間は12月1日から3月末までです。', 'The application period is from December 1 through the end of March.'),
    ('倍', '値段が倍になる。', 'The price doubles.'),
    ('くじ', 'スーパーで買い物をしてくじをひいたら、テレビが当たった。', 'After shopping at the supermarket and drawing a lottery ticket, I won a television.'),
    ('近道', '駅への近道を通る。', 'Take a shortcut to the station.'),
    ('中心', '街の中心、仕事中心の生活。', 'The center of town; a work-centered life.'),
    ('あたり', 'このあたり（このへん）は、10年前までは畑だった。', 'This area was farmland until ten years ago.'),
    ('周り', '駅の周りにはビルが多い。', 'There are many buildings around the station.'),
    ('穴', '地面に穴を掘る。', 'Dig a hole in the ground.'),
    ('列', '入り口の前には長い列ができていた。', 'A long line had formed in front of the entrance.'),
    ('幅', 'この道は幅が広い。', 'This road is wide.'),
    ('範囲', '試験の範囲を知らせる。', 'Announce the scope of the exam.'),
    ('内容', 'このレポートは内容はよいが、形式は少し直したほうがいい。', 'The content of this report is good, but the format should be revised a little.'),
    ('中身', '箱を開けて中身を見る。', 'Open the box and look at what is inside.'),
    ('特徴', '商品の特徴を確かめる。', 'Check the features of the product.'),
    ('普通', 'パスポートの申請には1週間ぐらいかかるのが普通だ。', 'It is normal for a passport application to take about a week.'),
    ('当たり前', 'そんなひどいことをされたら、怒るのが当たり前だ。', 'If someone did something that terrible to you, it would be natural to get angry.')
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

-- Verification: L20 must contain exactly 20 noun entries.
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
  AND vb.lesson_number = 20
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '書類', '題名', '条件', '締め切り', '期間', '倍', 'くじ', '近道', '中心', 'あたり',
  '周り', '穴', '列', '幅', '範囲', '内容', '中身', '特徴', '普通', '当たり前'
)
ORDER BY word;
