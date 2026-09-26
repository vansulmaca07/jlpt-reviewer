-- ============================================================
-- Check 日本語総まとめ Week 1 - Day 1 and Day 2
-- Read-only. This script does not insert or modify any data.
-- Both days belong to lesson L1. Week 2 will use lesson L2.
-- ============================================================

WITH source_words (day_number, word) AS (
  VALUES
  (1, 'ワイングラス'),
  (1, 'お茶'),
  (1, '急須'),
  (1, 'コーヒーカップ'),
  (1, '電子レンジ'),
  (1, '冷蔵庫'),
  (1, 'ガスレンジ'),
  (1, 'ガスコンロ'),
  (1, 'ガラスコップ'),
  (1, 'レバー'),
  (1, '流し'),
  (1, 'コンセント'),
  (1, 'コード'),
  (1, 'エアコン'),
  (1, 'ヒーター'),
  (1, 'じゅうたん'),
  (1, 'カーペット'),
  (1, '床'),
  (1, '天井'),
  (1, '窓ガラス'),
  (1, '雨戸'),
  (1, '網戸'),
  (1, '水道の蛇口をひねる'),
  (1, '水が凍る'),
  (1, '氷になる'),
  (1, '冷凍して保存する'),
  (1, '残り物を温める'),
  (1, 'ビールを冷やす'),
  (1, 'ビールが冷えている'),
  (1, 'エアコンのリモコン'),
  (1, 'スイッチ'),
  (1, '電源を入れる'),
  (1, '電源を切る'),
  (1, 'じゅうたんを敷く'),
  (1, '部屋を暖める'),
  (1, '暖房をつける'),
  (1, 'クーラーが効いている'),
  (1, '冷房が効いている'),
  (1, '日当たりがいい'),
  (2, '大さじ'),
  (2, '小さじ'),
  (2, '1カップ=200cc'),
  (2, '1リットル=1000cc'),
  (2, '包丁'),
  (2, 'まな板'),
  (2, 'はかり'),
  (2, '100グラム［g］'),
  (2, '夕食のおかず'),
  (2, '栄養のバランスを考える'),
  (2, 'カロリーが高い食品'),
  (2, 'はかりで量る'),
  (2, '塩を少々入れる'),
  (2, '調味料'),
  (2, '酒'),
  (2, '酢'),
  (2, 'サラダ油'),
  (2, '天ぷら油'),
  (2, '皮をむく'),
  (2, '材料を刻む'),
  (2, '大きさに切る'),
  (2, '3センチ幅に切る'),
  (2, 'みそ汁が熱くなる'),
  (2, 'ラップをかぶせる'),
  (2, 'ラップをかける'),
  (2, 'ラップでくるむ'),
  (2, 'アルミホイル')
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