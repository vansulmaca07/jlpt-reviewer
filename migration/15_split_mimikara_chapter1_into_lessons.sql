-- ============================================================
-- 耳から覚える N3 - Split the 120 Chapter 1 words into L1-L6
-- L1 = words 1-20, L2 = 21-40, ..., L6 = 101-120.
-- Safe to re-run: this only updates existing book links.
-- ============================================================

BEGIN;

DO $$
DECLARE
  v_book_id INTEGER;
  v_word_count INTEGER;
BEGIN
  SELECT id INTO v_book_id
  FROM public.books
  WHERE book_name = '耳から覚える'
  LIMIT 1;

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run migrations 06-10 first.';
  END IF;

  SELECT COUNT(DISTINCT vb.vocab_id)::INTEGER INTO v_word_count
  FROM public.vocabulary_books vb
  WHERE vb.book_id = v_book_id;

  IF v_word_count <> 120 THEN
    RAISE EXCEPTION 'Expected 120 耳から覚える vocabulary links, found %', v_word_count;
  END IF;
END $$;

UPDATE public.vocabulary_books vb
SET lesson_number = assignments.lesson_number
FROM public.vocabulary v
JOIN (
  VALUES
    ('男性', 1), ('女性', 1), ('高齢', 1), ('年上', 1), ('目上', 1),
    ('先輩', 1), ('後輩', 1), ('上司', 1), ('相手', 1), ('知り合い', 1),
    ('友人', 1), ('仲', 1), ('生年月日', 1), ('誕生', 1), ('年', 1),
    ('出身', 1), ('故郷', 1), ('成長', 1), ('成人', 1), ('合格', 1),

    ('進学', 2), ('退学', 2), ('就職', 2), ('退職', 2), ('失業', 2),
    ('残業', 2), ('生活', 2), ('通勤', 2), ('学歴', 2), ('給料', 2),
    ('面接', 2), ('休憩', 2), ('観光', 2), ('帰国', 2), ('帰省', 2),
    ('帰宅', 2), ('参加', 2), ('出席', 2), ('欠席', 2), ('遅刻', 2),

    ('化粧', 3), ('計算', 3), ('計画', 3), ('成功', 3), ('失敗', 3),
    ('準備', 3), ('整理', 3), ('注文', 3), ('貯金', 3), ('徹夜', 3),
    ('引っ越し', 3), ('身長', 3), ('体重', 3), ('けが', 3), ('会', 3),
    ('趣味', 3), ('興味', 3), ('思い出', 3), ('冗談', 3), ('目的', 3),

    ('約束', 4), ('おしゃべり', 4), ('遠慮', 4), ('我慢', 4), ('迷惑', 4),
    ('夢', 4), ('賛成', 4), ('反対', 4), ('想像', 4), ('努力', 4),
    ('太陽', 4), ('地球', 4), ('温度', 4), ('湿度', 4), ('湿気', 4),
    ('梅雨', 4), ('かび', 4), ('暖房', 4), ('皮', 4), ('缶', 4),

    ('画面', 5), ('番組', 5), ('記事', 5), ('近所', 5), ('警察', 5),
    ('犯人', 5), ('小銭', 5), ('希望', 5), ('ごちそう', 5), ('作者', 5),
    ('作品', 5), ('制服', 5), ('洗剤', 5), ('底', 5), ('地下', 5),
    ('寺', 5), ('道路', 5), ('坂', 5), ('煙', 5), ('灰', 5),

    ('判', 6), ('名刺', 6), ('免許', 6), ('多く', 6), ('前半', 6),
    ('後半', 6), ('最高', 6), ('最低', 6), ('最初', 6), ('最後', 6),
    ('自動', 6), ('種類', 6), ('性格', 6), ('性質', 6), ('順番', 6),
    ('番', 6), ('方法', 6), ('製品', 6), ('値上がり', 6), ('生', 6)
) AS assignments(word, lesson_number) ON assignments.word = v.word
WHERE vb.vocab_id = v.id
  AND vb.book_id = (
    SELECT id
    FROM public.books
    WHERE book_name = '耳から覚える'
    LIMIT 1
  );

COMMIT;

-- Verification: each lesson must contain exactly 20 words; total must be 120.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20 THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = '耳から覚える'
GROUP BY b.book_name, vb.lesson_number
ORDER BY vb.lesson_number;

SELECT
  b.book_name,
  COUNT(DISTINCT vb.vocab_id) AS total_word_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 120 THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = '耳から覚える'
GROUP BY b.book_name;