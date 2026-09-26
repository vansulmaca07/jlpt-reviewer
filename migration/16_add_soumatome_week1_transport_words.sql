-- ============================================================
-- Soumatome N3 - Week 1 additional vocabulary set
-- Day 1 = L1, Day 2 = L2, ..., Day 6 = L6.
-- Safe to re-run: existing vocabulary and book links are reused.
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
  WHERE book_name = 'Soumatome N3'
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
    RAISE EXCEPTION 'Soumatome N3 book not found';
  END IF;
  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 level not found';
  END IF;
  IF v_noun_type_id IS NULL THEN
    RAISE EXCEPTION 'Noun word type not found';
  END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT data.word, data.reading, data.meaning, v_noun_type_id, v_n3_level_id
  FROM (VALUES
    ('駐車', 'ちゅうしゃ', 'parking (e.g. car)'),
    ('駐車場', 'ちゅうしゃじょう', 'parking lot, parking place'),
    ('無い', 'ない', 'do not exist, do not have'),
    ('無料', 'むりょう', 'free, no charge'),
    ('無理', 'むり', 'unreasonable'),
    ('無休', 'むきゅう', 'work without holiday'),
    ('満員', 'まんいん', 'full of people'),
    ('満車', 'まんしゃ', 'full of cars'),
    ('不満', 'ふまん', 'dissatisfied'),
    ('向こう', 'むこう', 'over there, beyond'),
    ('向かう', 'むかう', 'go forward'),
    ('～向き', '～むき', 'be suitable for ～'),
    ('方向', 'ほうこう', 'direction'),
    ('禁止', 'きんし', 'prohibition'),
    ('関する', 'かんする', 'related'),
    ('関心', 'かんしん', 'interest'),
    ('係', 'かかり', 'person in charge'),
    ('関係', 'かんけい', 'relation, connection'),
    ('断る', 'ことわる', 'refuse'),
    ('断水', 'だんすい', 'suspension of water supply'),
    ('無断', 'むだん', 'without permission'),

    ('横', 'よこ', 'side'),
    ('横断歩道', 'おうだんほどう', 'pedestrian crossing'),
    ('横断', 'おうだん', 'crossing'),
    ('押す', 'おす', 'push'),
    ('押さえる', 'おさえる', 'hold down'),
    ('押し入れ', 'おしいれ', 'a closet'),
    ('入学式', 'にゅうがくしき', 'a ceremony to begin a school term'),
    ('押しボタン式', 'おしボタンしき', 'a push button style'),
    ('数式', 'すうしき', 'a numerical formula'),
    ('信じる', 'しんじる', 'believe'),
    ('信用', 'しんよう', 'trust'),
    ('自信', 'じしん', 'confidence'),
    ('送信', 'そうしん', 'transmission'),
    ('～号車', '～ごうしゃ', 'a carriage number'),
    ('信号', 'しんごう', 'a signal, a traffic light'),
    ('確かめる', 'たしかめる', 'confirm/verify'),
    ('確か', 'たしか', 'certain'),
    ('正確', 'せいかく', 'correct/accurate'),
    ('認める', 'みとめる', 'admit/approve'),
    ('確認', 'かくにん', 'confirmation'),
    ('飛ぶ', 'とぶ', 'fly'),
    ('飛行機', 'ひこうき', 'airplane'),
    ('飛行場', 'ひこうじょう', 'an airport'),

    ('非常に', 'ひじょうに', 'extremely'),
    ('非常', 'ひじょう', 'emergency'),
    ('非常口', 'ひじょうぐち', 'emergency exit'),
    ('正常', 'せいじょう', 'normal'),
    ('日常', 'にちじょう', 'usual, everyday'),
    ('～階', '～かい', 'floor'),
    ('階段', 'かいだん', 'stairs'),
    ('箱', 'はこ', 'box'),
    ('ごみ箱', 'ごみばこ', 'a trash box'),
    ('危ない', 'あぶない', 'dangerous'),
    ('危険', 'きけん', 'danger'),
    ('捨てる', 'すてる', 'throw away'),

    ('～番線', '～ばんせん', 'line (platform) number ～'),
    ('線', 'せん', 'a line'),
    ('画面', 'がめん', 'a screen'),
    ('全面', 'ぜんめん', 'whole'),
    ('～方面', '～ほうめん', 'area'),
    ('普通', 'ふつう', 'ordinary'),
    ('各国', 'かっこく', 'each country'),
    ('各駅', 'かくえき', 'every station'),
    ('各自', 'かくじ', 'respective/each person'),
    ('次', 'つぎ', 'the next'),
    ('次回', 'じかい', 'the next time'),
    ('目次', 'もくじ', 'contents'),
    ('快速', 'かいそく', 'a high speed'),
    ('速い', 'はやい', 'fast'),
    ('速度', 'そくど', 'speed'),
    ('高速道路', 'こうそくどうろ', 'a superhighway'),
    ('過去', 'かこ', 'past'),
    ('過ぎる', 'すぎる', 'pass'),
    ('通過', 'つうか', 'passage, transit'),
    ('鉄道', 'てつどう', 'a railway'),
    ('鉄', 'てつ', 'steel'),
    ('地下鉄', 'ちかてつ', 'a subway train'),

    ('指', 'ゆび', 'a finger'),
    ('指輪', 'ゆびわ', 'a ring'),
    ('指定', 'してい', 'specification, designation'),
    ('指定席', 'していせき', 'a reserved seat'),
    ('安定', 'あんてい', 'stability'),
    ('祝日', 'しゅくじつ', 'a regular holiday'),
    ('席', 'せき', 'a seat'),
    ('欠席', 'けっせき', 'absence'),
    ('出席', 'しゅっせき', 'attendance'),
    ('自由', 'じゆう', 'free'),
    ('自由席', 'じゆうせき', 'a non reserved seat'),
    ('理由', 'りゆう', 'a reason'),
    ('～番', '～ばん', 'number ～'),
    ('一番', 'いちばん', 'line (platform) number'),
    ('番号', 'ばんごう', 'a number'),
    ('窓', 'まど', 'window'),
    ('窓口', 'まどぐち', 'a teller''s window'),
    ('両側', 'りょうがわ', 'both sides'),
    ('窓側', 'まどがわ', 'the window side'),
    ('右側', 'みぎがわ', 'right side'),
    ('通路', 'つうろ', 'an aisle'),
    ('道路', 'どうろ', 'a road'),
    ('線路', 'せんろ', 'a railway track'),

    ('バス停', 'バスてい', 'a bus stop'),
    ('停車', 'ていしゃ', 'stop a vehicle'),
    ('整理', 'せいり', 'tidy, arrangement'),
    ('整理券', 'せいりけん', 'numbered ticket'),
    ('乗車券', 'じょうしゃけん', 'a boarding ticket'),
    ('駐車券', 'ちゅうしゃけん', 'a parking ticket'),
    ('回数券', 'かいすうけん', 'commuter ticket'),
    ('現れる', 'あらわれる', 'appear'),
    ('表現', 'ひょうげん', 'expression'),
    ('現金', 'げんきん', 'cash'),
    ('両親', 'りょうしん', 'parents'),
    ('～両', '～りょう', 'cars on a train'),
    ('取り替える', 'とりかえる', 'exchange (one thing for another)'),
    ('着替える', 'きがえる', 'change clothes'),
    ('両替', 'りょうがえ', 'money changing, exchange'),
    ('優しい', 'やさしい', 'kind'),
    ('女優', 'じょゆう', 'an actress'),
    ('優先席', 'ゆうせんせき', 'a priority seat'),
    ('座る', 'すわる', 'sit'),
    ('正座', 'せいざ', 'sit on the floor Japanese style'),
    ('座席', 'ざせき', 'a seat'),
    ('降りる', 'おりる', 'get off'),
    ('以降', 'いこう', 'on and after...'),
    ('降る', 'ふる', 'fall'),
    ('降車口', 'こうしゃぐち', 'exit for getting off')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, assignments.lesson_number
  FROM public.vocabulary v
  JOIN (
    SELECT data.word, data.lesson_number
    FROM (VALUES
      ('駐車', 1), ('駐車場', 1), ('無い', 1), ('無料', 1), ('無理', 1), ('無休', 1),
      ('満員', 1), ('満車', 1), ('不満', 1), ('向こう', 1), ('向かう', 1), ('～向き', 1),
      ('方向', 1), ('禁止', 1), ('関する', 1), ('関心', 1), ('係', 1), ('関係', 1),
      ('断る', 1), ('断水', 1), ('無断', 1),
      ('横', 2), ('横断歩道', 2), ('横断', 2), ('押す', 2), ('押さえる', 2), ('押し入れ', 2),
      ('入学式', 2), ('押しボタン式', 2), ('数式', 2), ('信じる', 2), ('信用', 2), ('自信', 2),
      ('送信', 2), ('～号車', 2), ('信号', 2), ('確かめる', 2), ('確か', 2), ('正確', 2),
      ('認める', 2), ('確認', 2), ('飛ぶ', 2), ('飛行機', 2), ('飛行場', 2),
      ('非常に', 3), ('非常', 3), ('非常口', 3), ('正常', 3), ('日常', 3), ('～階', 3),
      ('階段', 3), ('箱', 3), ('ごみ箱', 3), ('危ない', 3), ('危険', 3), ('捨てる', 3),
      ('～番線', 4), ('線', 4), ('画面', 4), ('全面', 4), ('～方面', 4), ('普通', 4),
      ('各国', 4), ('各駅', 4), ('各自', 4), ('次', 4), ('次回', 4), ('目次', 4), ('快速', 4),
      ('速い', 4), ('速度', 4), ('高速道路', 4), ('過去', 4), ('過ぎる', 4), ('通過', 4),
      ('鉄道', 4), ('鉄', 4), ('地下鉄', 4),
      ('指', 5), ('指輪', 5), ('指定', 5), ('指定席', 5), ('安定', 5), ('祝日', 5), ('席', 5),
      ('欠席', 5), ('出席', 5), ('自由', 5), ('自由席', 5), ('理由', 5), ('～番', 5), ('一番', 5),
      ('番号', 5), ('窓', 5), ('窓口', 5), ('両側', 5), ('窓側', 5), ('右側', 5), ('通路', 5),
      ('道路', 5), ('線路', 5),
      ('バス停', 6), ('停車', 6), ('整理', 6), ('整理券', 6), ('乗車券', 6), ('駐車券', 6),
      ('回数券', 6), ('現れる', 6), ('表現', 6), ('現金', 6), ('両親', 6), ('～両', 6),
      ('取り替える', 6), ('着替える', 6), ('両替', 6), ('優しい', 6), ('女優', 6), ('優先席', 6),
      ('座る', 6), ('正座', 6), ('座席', 6), ('降りる', 6), ('以降', 6), ('降る', 6), ('降車口', 6)
    ) AS data(word, lesson_number)
  ) assignments ON assignments.word = v.word
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  -- Migration 13 placed the original kitchen Day 2 entries in L1.
  -- Move only those existing entries to their correct lesson, L2.
  UPDATE public.vocabulary_books vb
  SET lesson_number = 2
  FROM public.vocabulary v
  WHERE vb.vocab_id = v.id
    AND vb.book_id = v_book_id
    AND v.word IN (
      '大さじ', '小さじ', '1カップ=200cc', '1リットル=1000cc', '包丁', 'まな板',
      'はかり', '100グラム［g］', '夕食のおかず', '栄養のバランスを考える',
      'カロリーが高い食品', 'はかりで量る', '塩を少々入れる', '調味料', '酒', '酢',
      'サラダ油', '天ぷら油', '皮をむく', '材料を刻む', '大きさに切る',
      '3センチ幅に切る', 'みそ汁が熱くなる', 'ラップをかぶせる', 'ラップをかける',
      'ラップでくるむ', 'アルミホイル'
    );
END $$;

COMMIT;

SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = 'Soumatome N3'
GROUP BY b.book_name, vb.lesson_number
ORDER BY vb.lesson_number;