-- ============================================================
-- Soumatome N3 - Week 1 (Day 1 and Day 2)
-- Both days belong to L1 (lesson_number = 1).
-- Safe to re-run: existing vocabulary and links are reused.
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
    ('ワイングラス', 'ワイングラス', 'wine glass'),
    ('お茶', 'おちゃ', 'tea'),
    ('急須', 'きゅうす', 'teapot'),
    ('コーヒーカップ', 'コーヒーカップ', 'coffee cup'),
    ('ガスコンロ', 'ガスコンロ', 'gas stove'),
    ('ガラスコップ', 'ガラスコップ', 'glass'),
    ('レバー', 'レバー', 'lever'),
    ('コンセント', 'コンセント', 'electrical outlet'),
    ('コード', 'コード', 'cord'),
    ('エアコン', 'エアコン', 'air conditioner'),
    ('ヒーター', 'ヒーター', 'heater'),
    ('カーペット', 'カーペット', 'carpet'),
    ('床', 'ゆか', 'floor'),
    ('窓ガラス', 'まどガラス', 'window glass'),
    ('雨戸', 'あまど', 'shutter'),
    ('網戸', 'あみど', 'screen'),
    ('水道の蛇口をひねる', 'すいどうのじゃぐちをひねる', 'turn on a tap'),
    ('水が凍る', 'みずがこおる', 'water freezes'),
    ('氷になる', 'こおりになる', 'turn into ice'),
    ('冷凍して保存する', 'れいとうしてほぞんする', 'freeze to store'),
    ('残り物を温める', 'のこりものをあたためる', 'warm up leftover food in a microwave'),
    ('ビールを冷やす', 'ビールをひやす', 'chill the beer'),
    ('ビールが冷えている', 'ビールがひえている', 'the beer is chilled'),
    ('エアコンのリモコン', 'エアコンのリモコン', 'remote control for an air conditioner'),
    ('スイッチ', 'スイッチ', 'switch'),
    ('電源を入れる', 'でんげんをいれる', 'turn on the power'),
    ('電源を切る', 'でんげんをきる', 'turn off the power'),
    ('じゅうたんを敷く', 'じゅうたんをしく', 'lay a carpet'),
    ('部屋を暖める', 'へやをあたためる', 'heat the room'),
    ('暖房をつける', 'だんぼうをつける', 'turn on the heater'),
    ('クーラーが効いている', 'クーラーがきいている', 'the cooler is working'),
    ('冷房が効いている', 'れいぼうがきいている', 'the air conditioner is working'),
    ('日当たりがいい', 'ひあたりがいい', 'have good exposure to the sun'),
    ('大さじ', 'おおさじ', 'tablespoon'),
    ('小さじ', 'こさじ', 'teaspoon'),
    ('1カップ=200cc', 'いちカップにひゃくシーシー', '1 cup'),
    ('1リットル=1000cc', 'いちリットルせんシーシー', '1 liter'),
    ('包丁', 'ほうちょう', 'kitchen knife'),
    ('まな板', 'まないた', 'cutting board'),
    ('はかり', 'はかり', 'scale'),
    ('100グラム［g］', 'ひゃくグラム', '100 grams'),
    ('夕食のおかず', 'ゆうしょくのおかず', 'dish for an evening meal'),
    ('栄養のバランスを考える', 'えいようのバランスをかんがえる', 'think about the nutritional balance'),
    ('カロリーが高い食品', 'カロリーがたかいしょくひん', 'high-calorie food'),
    ('はかりで量る', 'はかりではかる', 'weigh on a scale'),
    ('塩を少々入れる', 'しおをしょうしょういれる', 'add a little salt'),
    ('調味料', 'ちょうみりょう', 'seasoning'),
    ('酒', 'さけ', 'rice wine'),
    ('酢', 'す', 'vinegar'),
    ('サラダ油', 'サラダゆ', 'salad oil'),
    ('天ぷら油', 'てんぷらあぶら', 'tempura oil'),
    ('皮をむく', 'かわをむく', 'peel'),
    ('材料を刻む', 'ざいりょうをきざむ', 'chop the ingredients'),
    ('大きさに切る', 'おおきさにきる', 'cut in big pieces'),
    ('3センチ幅に切る', 'さんセンチはばにきる', 'cut into 3-centimeter pieces'),
    ('みそ汁が熱くなる', 'みそしるがあつくなる', 'the miso soup is lukewarm'),
    ('ラップをかぶせる', 'ラップをかぶせる', 'cover with plastic wrap'),
    ('ラップをかける', 'ラップをかける', 'cover with plastic wrap'),
    ('ラップでくるむ', 'ラップでくるむ', 'wrap with plastic wrap'),
    ('アルミホイル', 'アルミホイル', 'aluminium foil')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 1
  FROM public.vocabulary v
  WHERE v.word IN (
    'ワイングラス', 'お茶', '急須', 'コーヒーカップ', '電子レンジ', '冷蔵庫',
    'ガスレンジ', 'ガスコンロ', 'ガラスコップ', 'レバー', '流し', 'コンセント',
    'コード', 'エアコン', 'ヒーター', 'じゅうたん', 'カーペット', '床', '天井',
    '窓ガラス', '雨戸', '網戸', '水道の蛇口をひねる', '水が凍る', '氷になる',
    '冷凍して保存する', '残り物を温める', 'ビールを冷やす', 'ビールが冷えている',
    'エアコンのリモコン', 'スイッチ', '電源を入れる', '電源を切る', 'じゅうたんを敷く',
    '部屋を暖める', '暖房をつける', 'クーラーが効いている', '冷房が効いている',
    '日当たりがいい', '大さじ', '小さじ', '1カップ=200cc', '1リットル=1000cc',
    '包丁', 'まな板', 'はかり', '100グラム［g］', '夕食のおかず',
    '栄養のバランスを考える', 'カロリーが高い食品', 'はかりで量る', '塩を少々入れる',
    '調味料', '酒', '酢', 'サラダ油', '天ぷら油', '皮をむく', '材料を刻む',
    '大きさに切る', '3センチ幅に切る', 'みそ汁が熱くなる', 'ラップをかぶせる',
    'ラップをかける', 'ラップでくるむ', 'アルミホイル'
  )
  ON CONFLICT (vocab_id, book_id) DO NOTHING;
END $$;

COMMIT;

-- Verify: all Week 1 entries must be linked to L1.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
WHERE b.book_name = 'Soumatome N3'
  AND vb.lesson_number = 1
GROUP BY b.book_name, vb.lesson_number;
