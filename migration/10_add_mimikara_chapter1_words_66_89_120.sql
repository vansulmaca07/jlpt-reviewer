-- ============================================================
-- 耳から覚える N3 - Chapter 1, Words 66 and 89-120
-- Run after 09_add_mimikara_chapter1_words_58_88.sql.
-- Duplicate words reuse the existing vocabulary row.
-- ============================================================

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_noun_type_id INTEGER;
  v_chapter INTEGER := 1;
BEGIN
  SELECT id INTO v_book_id FROM public.books WHERE book_name = '耳から覚える' LIMIT 1;
  SELECT id INTO v_n3_level_id FROM public.jlpt_levels WHERE level = 'N3' LIMIT 1;
  SELECT id INTO v_noun_type_id FROM public.word_types
  WHERE LOWER(type_name) LIKE '%noun%' OR type_name LIKE '%名詞%'
  ORDER BY id LIMIT 1;

  IF v_book_id IS NULL THEN RAISE EXCEPTION '耳から覚える book not found. Run migration 06 first.'; END IF;
  IF v_n3_level_id IS NULL THEN RAISE EXCEPTION 'N3 not found in jlpt_levels.'; END IF;
  IF v_noun_type_id IS NULL THEN RAISE EXCEPTION 'Noun not found in word_types.'; END IF;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id)
  SELECT data.word, data.reading, data.meaning, v_noun_type_id, v_n3_level_id
  FROM (VALUES
    ('希望', 'きぼう', 'hope, wish'),
    ('ごちそう', 'ごちそう', 'feast, treating someone to a meal'),
    ('作者', 'さくしゃ', 'writer, author, artist'),
    ('作品', 'さくひん', 'work, piece of art or literature'),
    ('制服', 'せいふく', 'uniform'),
    ('洗剤', 'せんざい', 'detergent'),
    ('底', 'そこ', 'bottom'),
    ('地下', 'ちか', 'underground, basement'),
    ('寺', 'てら', 'temple'),
    ('道路', 'どうろ', 'road'),
    ('坂', 'さか', 'hill, slope'),
    ('煙', 'けむり', 'smoke'),
    ('灰', 'はい', 'ash'),
    ('判', 'はん', 'seal, stamp'),
    ('名刺', 'めいし', 'business card, visiting card'),
    ('免許', 'めんきょ', 'license'),
    ('多く', 'おおく', 'many, much'),
    ('前半', 'ぜんはん', 'first half'),
    ('後半', 'こうはん', 'second half'),
    ('最高', 'さいこう', 'highest, best, really'),
    ('最低', 'さいてい', 'lowest, worst'),
    ('最初', 'さいしょ', 'first, beginning'),
    ('最後', 'さいご', 'last, end'),
    ('自動', 'じどう', 'automatic, automation'),
    ('種類', 'しゅるい', 'type, kind'),
    ('性格', 'せいかく', 'personality, character'),
    ('性質', 'せいしつ', 'property, disposition, nature'),
    ('順番', 'じゅんばん', 'order, sequence'),
    ('番', 'ばん', 'one''s turn, watching over'),
    ('方法', 'ほうほう', 'method, way'),
    ('製品', 'せいひん', 'product'),
    ('値上がり', 'ねあがり', 'price rise'),
    ('生', 'なま', 'raw, draft beer')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, v_chapter
  FROM public.vocabulary v
  WHERE v.word IN (
    '希望', 'ごちそう', '作者', '作品', '制服', '洗剤', '底', '地下', '寺',
    '道路', '坂', '煙', '灰', '判', '名刺', '免許', '多く', '前半', '後半',
    '最高', '最低', '最初', '最後', '自動', '種類', '性格', '性質', '順番',
    '番', '方法', '製品', '値上がり', '生'
  )
  ON CONFLICT (vocab_id, book_id) DO NOTHING;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('希望', '最後まで希望を捨ててはいけません。', 'You must not give up hope until the end.'),
    ('希望', '私はふるさとでの就職を希望しています。', 'I hope to find a job in my hometown.'),
    ('希望', '希望する大学に合格しました。', 'I passed the university I hoped to attend.'),
    ('ごちそう', '家族みんなでごちそうを食べました。', 'The whole family ate a feast together.'),
    ('ごちそう', 'チンさんが私たちに手作りの餃子をごちそうしてくれました。', 'Chen treated us to homemade dumplings.'),
    ('ごちそう', 'きのうは先輩にごちそうになりました。', 'Yesterday my senior treated me to a meal.'),
    ('作者', 'この小説の作者は有名な作家です。', 'The author of this novel is a famous writer.'),
    ('作者', '「ハムレット」の作者はシェイクスピアです。', 'The author of Hamlet is Shakespeare.'),
    ('作者', '作者の名前を確認しました。', 'I checked the author’s name.'),
    ('作品', '学生の作品をロビーに展示します。', 'We will display the students’ works in the lobby.'),
    ('作品', 'この作品は世界中で知られています。', 'This work is known around the world.'),
    ('作品', '美術館で有名な作品を見ました。', 'I saw famous works at the art museum.'),
    ('制服', '日本の中学校には制服のある学校が多いです。', 'Many Japanese middle schools have uniforms.'),
    ('制服', '毎朝制服を着て学校へ行きます。', 'I put on my uniform and go to school every morning.'),
    ('制服', '制服をきれいに洗いました。', 'I washed my uniform clean.'),
    ('洗剤', '洗剤で食器を洗います。', 'I wash dishes with detergent.'),
    ('洗剤', 'この洗剤は香りがいいです。', 'This detergent smells nice.'),
    ('洗剤', '洗剤を買うのを忘れました。', 'I forgot to buy detergent.'),
    ('底', 'くつの底に穴があります。', 'There is a hole in the sole of the shoe.'),
    ('底', '箱の底が抜けました。', 'The bottom of the box came out.'),
    ('底', 'コップの底に水が残っています。', 'There is water remaining at the bottom of the cup.'),
    ('地下', '大都市は地下の開発が進んでいます。', 'Underground development is progressing in large cities.'),
    ('地下', '地下2階、地上8階のビルです。', 'It is a building with two basement floors and eight floors above ground.'),
    ('地下', '地下鉄の駅は地下にあります。', 'The subway station is underground.'),
    ('寺', '寺にお参りします。', 'I visit a temple to pray.'),
    ('寺', '京都には古い寺がたくさんあります。', 'There are many old temples in Kyoto.'),
    ('寺', '寺の境内を歩きました。', 'I walked around the temple grounds.'),
    ('道路', '道路が込んでいます。', 'The road is crowded.'),
    ('道路', '日本では、車は道路の左側を走ります。', 'In Japan, cars drive on the left side of the road.'),
    ('道路', '家の前を高速道路が走っています。', 'An expressway runs in front of my house.'),
    ('坂', '坂を上ります。', 'I go up the hill.'),
    ('坂', 'この坂は急なので気をつけてください。', 'This slope is steep, so please be careful.'),
    ('坂', '坂を下ると駅があります。', 'There is a station down the slope.'),
    ('煙', '火事のときは、煙に注意して逃げてください。', 'In case of fire, watch out for smoke and escape.'),
    ('煙', 'たばこの煙は体に悪いです。', 'Cigarette smoke is bad for your body.'),
    ('煙', '煙が空に上がっています。', 'Smoke is rising into the sky.'),
    ('灰', 'たばこの灰を捨てました。', 'I threw away the cigarette ash.'),
    ('灰', '紙が燃えて灰になりました。', 'The paper burned and became ash.'),
    ('灰', '灰色の服を着ています。', 'I am wearing gray clothes.'),
    ('判', '書類に判を押します。', 'I stamp the document.'),
    ('判', 'ここに判を押してください。', 'Please stamp here.'),
    ('判', '印鑑を持ってきました。', 'I brought my seal.'),
    ('名刺', '名刺を交換しました。', 'We exchanged business cards.'),
    ('名刺', 'パーティーで会った人に名刺を配りました。', 'I handed out business cards to people I met at the party.'),
    ('名刺', '名刺に電話番号を書きました。', 'I wrote my phone number on my business card.'),
    ('免許', 'レストランを開くには、調理師の免許が必要です。', 'A cook’s license is necessary to open a restaurant.'),
    ('免許', '運転免許を取るために勉強しています。', 'I am studying to get a driver’s license.'),
    ('免許', '免許証を見せてください。', 'Please show me your license.'),
    ('多く', 'オリンピックには多くの国が参加しました。', 'Many countries participated in the Olympics.'),
    ('多く', '多くの人がこの映画を見ました。', 'Many people watched this movie.'),
    ('多く', 'できるだけ多く食べてください。', 'Please eat as much as possible.'),
    ('前半', '映画の前半は退屈でした。', 'The first half of the movie was boring.'),
    ('前半', '試合の前半は0対0でした。', 'The first half of the game was 0-0.'),
    ('前半', '前半は静かに話を聞いてください。', 'Please listen quietly during the first half.'),
    ('後半', '映画の後半はおもしろかったです。', 'The second half of the movie was interesting.'),
    ('後半', '後半に点を取りました。', 'We scored in the second half.'),
    ('後半', '人生の後半を海外で暮らしたいです。', 'I want to live abroad during the latter half of my life.'),
    ('最高', '最高気温は30度でした。', 'The highest temperature was 30 degrees.'),
    ('最高', 'きょうの試合は最高でした。', 'Today’s game was the best.'),
    ('最高', 'この映画は最高におもしろいです。', 'This movie is extremely interesting.'),
    ('最低', '最低気温は5度でした。', 'The lowest temperature was 5 degrees.'),
    ('最低', 'クラスで最低の点を取ってしまいました。', 'I got the lowest score in the class.'),
    ('最低', 'きょうの試合は最低でした。', 'Today’s game was the worst.'),
    ('最初', '最初にひらがなを、次にカタカナを勉強しました。', 'First I studied hiragana, then katakana.'),
    ('最初', '日本に来たばかりのころ、最初は何もわかりませんでした。', 'When I first came to Japan, I understood nothing at first.'),
    ('最初', '最初の出勤日に花束をもらいました。', 'I received a bouquet on my first day at work.'),
    ('最後', 'あとから来た人は列の最後に並んでください。', 'People who came later, please line up at the end of the line.'),
    ('最後', '最後の出勤日に花束をもらいました。', 'I received a bouquet on my last day at work.'),
    ('最後', '最後まであきらめません。', 'I will not give up until the end.'),
    ('自動', 'このドアは自動だから、手で開けなくてもいいです。', 'This door is automatic, so you do not need to open it by hand.'),
    ('自動', '自動販売機で飲み物を買いました。', 'I bought a drink from a vending machine.'),
    ('自動', 'これは全自動の洗濯機です。', 'This is a fully automatic washing machine.'),
    ('種類', '公園にはいろいろな種類の花があります。', 'There are many kinds of flowers in the park.'),
    ('種類', '形容詞には二種類あります。', 'There are two types of adjectives.'),
    ('種類', 'この店は料理の種類が豊富です。', 'This restaurant has a wide variety of dishes.'),
    ('性格', 'あの人は性格がいいので、みんなに好かれています。', 'That person has a good personality, so everyone likes them.'),
    ('性格', '明るい性格の友人がいます。', 'I have a friend with a cheerful personality.'),
    ('性格', '性格が違っても仲良くできます。', 'Even if our personalities differ, we can get along.'),
    ('性質', 'この布は燃えにくい性質を持っています。', 'This cloth has the property of being difficult to burn.'),
    ('性質', '羊はおとなしい性質の動物です。', 'Sheep are animals with a gentle nature.'),
    ('性質', '人は持って生まれた性質を変えにくいです。', 'It is difficult for people to change their inborn nature.'),
    ('順番', '発表の順番を決めます。', 'We will decide the presentation order.'),
    ('順番', '大きい商品から順番に並べます。', 'We line up the products in order from largest.'),
    ('順番', '順番を待ってください。', 'Please wait your turn.'),
    ('番', '次は私の番です。', 'It is my turn next.'),
    ('番', '席を離れた人の荷物の番をします。', 'I watch the belongings of the person who left their seat.'),
    ('番', '隣の人に留守番を頼みました。', 'I asked my neighbor to watch the house.'),
    ('方法', 'いい方法を探します。', 'I will look for a good method.'),
    ('方法', 'いろいろな方法を試します。', 'I will try various methods.'),
    ('方法', '新しい方法でやってみます。', 'I will try it using a new method.'),
    ('製品', '完成した製品を検査します。', 'We inspect the completed products.'),
    ('製品', '電気製品を買いました。', 'I bought an electrical product.'),
    ('製品', 'この製品は日本製です。', 'This product is made in Japan.'),
    ('値上がり', '食品の値上がりが続いています。', 'Food price increases are continuing.'),
    ('値上がり', '石油が値上がりしました。', 'Oil prices went up.'),
    ('値上がり', '商品の値上がりに驚きました。', 'I was surprised by the price increase of the product.'),
    ('生', '生の魚を食べます。', 'I eat raw fish.'),
    ('生', '肉を生のままで食べてはいけません。', 'You must not eat meat raw.'),
    ('生', '生ビールを一杯ください。', 'One draft beer, please.')
  ) AS examples(word, japanese_sentence, english_translation)
  JOIN public.vocabulary v ON v.word = examples.word
  WHERE NOT EXISTS (
    SELECT 1 FROM public.example_sentences existing
    WHERE existing.vocab_id = v.id
      AND existing.japanese_sentence = examples.japanese_sentence
  );
END $$;

SELECT v.word, v.reading, wt.type_name,
       vb.lesson_number AS chapter_number, COUNT(es.id) AS example_count
FROM public.vocabulary v
JOIN public.vocabulary_books vb ON vb.vocab_id = v.id
JOIN public.books b ON b.id = vb.book_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
LEFT JOIN public.example_sentences es ON es.vocab_id = v.id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 1
  AND v.word IN (
    '希望', 'ごちそう', '作者', '作品', '制服', '洗剤', '底', '地下', '寺',
    '道路', '坂', '煙', '灰', '判', '名刺', '免許', '多く', '前半', '後半',
    '最高', '最低', '最初', '最後', '自動', '種類', '性格', '性質', '順番',
    '番', '方法', '製品', '値上がり', '生'
  )
GROUP BY v.word, v.reading, wt.type_name, vb.lesson_number
ORDER BY v.word;
