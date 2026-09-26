-- ============================================================
-- Check Soumatome N3 - Week 1, Days 1 through 4
-- Read-only. No permanent data is inserted or modified.
-- All Week 1 days belong to L1 (lesson_number = 1).
-- ============================================================

WITH source_words (day_number, word) AS (
  VALUES
    (1, '駐車'),
    (1, '駐車場'),
    (1, '無い'),
    (1, '無料'),
    (1, '無理'),
    (1, '無休'),
    (1, '満員'),
    (1, '満車'),
    (1, '不満'),
    (1, '向こう'),
    (1, '向かう'),
    (1, '～向き'),
    (1, '方向'),
    (1, '禁止'),
    (1, '関する'),
    (1, '関心'),
    (1, '係'),
    (1, '関係'),
    (1, '断る'),
    (1, '断水'),
    (1, '無断'),
    (2, '横'),
    (2, '横断歩道'),
    (2, '横断'),
    (2, '押す'),
    (2, '押さえる'),
    (2, '押し入れ'),
    (2, '入学式'),
    (2, '押しボタン式'),
    (2, '数式'),
    (2, '信じる'),
    (2, '信用'),
    (2, '自信'),
    (2, '送信'),
    (2, '～号車'),
    (2, '信号'),
    (2, '確かめる'),
    (2, '確か'),
    (2, '正確'),
    (2, '認める'),
    (2, '確認'),
    (2, '飛ぶ'),
    (2, '飛行機'),
    (2, '飛行場'),
    (3, '非常に'),
    (3, '非常'),
    (3, '非常口'),
    (3, '正常'),
    (3, '日常'),
    (3, '～階'),
    (3, '階段'),
    (3, '箱'),
    (3, 'ごみ箱'),
    (3, '危ない'),
    (3, '危険'),
    (3, '捨てる'),
    (4, '～番線'),
    (4, '線'),
    (4, '画面'),
    (4, '全面'),
    (4, '～方面'),
    (4, '普通'),
    (4, '各国'),
    (4, '各駅'),
    (4, '各自'),
    (4, '次'),
    (4, '次回'),
    (4, '目次'),
    (4, '快速'),
    (4, '速い'),
    (4, '速度'),
    (4, '高速道路'),
    (4, '過去'),
    (4, '過ぎる'),
    (4, '通過'),
    (4, '鉄道'),
    (4, '鉄'),
    (4, '地下鉄')
), source_counts AS (
  SELECT day_number, word, COUNT(*) AS source_occurrences
  FROM source_words
  GROUP BY day_number, word
), book_candidates AS (
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object('id', id, 'book_name', book_name, 'jlpt_level_id', jlpt_level_id)
      ORDER BY id
    ),
    '[]'::jsonb
  ) AS books
  FROM public.books
  WHERE book_name ILIKE '%総まとめ%'
     OR book_name ILIKE '%soumatome%'
), word_report AS (
  SELECT
    s.day_number,
    s.word,
    s.source_occurrences,
    v.id AS vocabulary_id,
    v.reading,
    v.meaning,
    COALESCE(
      jsonb_agg(
        DISTINCT jsonb_build_object(
          'book_id', b.id,
          'book_name', b.book_name,
          'lesson_number', vb.lesson_number
        )
      ) FILTER (WHERE b.id IS NOT NULL),
      '[]'::jsonb
    ) AS existing_soumatome_links
  FROM source_counts s
  LEFT JOIN public.vocabulary v ON v.word = s.word
  LEFT JOIN public.vocabulary_books vb ON vb.vocab_id = v.id
  LEFT JOIN public.books b
    ON b.id = vb.book_id
   AND (b.book_name ILIKE '%総まとめ%' OR b.book_name ILIKE '%soumatome%')
  GROUP BY s.day_number, s.word, s.source_occurrences, v.id, v.reading, v.meaning
)
SELECT
  r.day_number,
  r.word,
  r.source_occurrences,
  r.vocabulary_id,
  r.reading,
  r.meaning,
  (r.vocabulary_id IS NOT NULL) AS already_in_vocabulary,
  (r.existing_soumatome_links <> '[]'::jsonb) AS already_linked_to_soumatome,
  r.existing_soumatome_links,
  c.books AS existing_soumatome_book_candidates
FROM word_report r
CROSS JOIN book_candidates c
ORDER BY r.day_number, r.word;
