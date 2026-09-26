-- ============================================================
-- Validate 耳から覚える N3 - Chapter 1
-- Read-only checks. This script does not modify any data.
-- Expected total: 120 distinct vocabulary links.
-- ============================================================

-- 1. Main count: should return 120.
SELECT
  b.book_name,
  vb.lesson_number AS chapter_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 120 THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 1
GROUP BY b.book_name, vb.lesson_number;

-- 2. Count by source batch. Expected: 7, 17, 33, 30, 33.
SELECT
  CASE
    WHEN v.word IN ('男性', '女性', '高齢', '年上', '目上', '先輩', '後輩') THEN '01-07'
    WHEN v.word IN ('上司', '相手', '知り合い', '友人', '仲', '生年月日', '誕生', '年', '出身', '故郷', '成長', '成人', '合格', '進学', '退学', '就職', '退職') THEN '08-24'
    WHEN v.word IN ('失業', '残業', '生活', '通勤', '学歴', '給料', '面接', '休憩', '観光', '帰国', '帰省', '帰宅', '参加', '出席', '欠席', '遅刻', '化粧', '計算', '計画', '成功', '失敗', '準備', '整理', '注文', '貯金', '徹夜', '引っ越し', '身長', '体重', 'けが', '会', '趣味', '興味') THEN '25-57'
    WHEN v.word IN ('思い出', '冗談', '目的', '約束', 'おしゃべり', '遠慮', '我慢', '迷惑', '夢', '賛成', '反対', '想像', '努力', '太陽', '地球', '温度', '湿度', '湿気', '梅雨', 'かび', '暖房', '皮', '缶', '画面', '番組', '記事', '近所', '警察', '犯人', '小銭') THEN '58-88'
    WHEN v.word IN ('希望', 'ごちそう', '作者', '作品', '制服', '洗剤', '底', '地下', '寺', '道路', '坂', '煙', '灰', '判', '名刺', '免許', '多く', '前半', '後半', '最高', '最低', '最初', '最後', '自動', '種類', '性格', '性質', '順番', '番', '方法', '製品', '値上がり', '生') THEN '66, 89-120'
    ELSE 'UNEXPECTED'
  END AS source_batch,
  COUNT(DISTINCT v.id) AS word_count
FROM public.vocabulary v
JOIN public.vocabulary_books vb ON vb.vocab_id = v.id
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 1
GROUP BY source_batch
ORDER BY source_batch;

-- 3. Duplicate word rows. Expected: zero rows.
SELECT word, COUNT(*) AS row_count
FROM public.vocabulary
GROUP BY word
HAVING COUNT(*) > 1
ORDER BY word;

-- 4. Words linked to Chapter 1 with NULL word_type_id. Expected: zero rows.
SELECT v.word, v.reading, v.meaning
FROM public.vocabulary v
JOIN public.vocabulary_books vb ON vb.vocab_id = v.id
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 1
  AND v.word_type_id IS NULL
ORDER BY v.word;

-- 5. Example count per word. Expected: at least 3 for each word.
SELECT
  v.word,
  COUNT(es.id) AS example_count,
  CASE WHEN COUNT(es.id) >= 3 THEN 'PASS' ELSE 'CHECK' END AS validation_status
FROM public.vocabulary v
JOIN public.vocabulary_books vb ON vb.vocab_id = v.id
JOIN public.books b ON b.id = vb.book_id
LEFT JOIN public.example_sentences es ON es.vocab_id = v.id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 1
GROUP BY v.word
ORDER BY v.word;
