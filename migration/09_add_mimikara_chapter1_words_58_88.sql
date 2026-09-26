-- ============================================================
-- 耳から覚える N3 - Chapter 1, Words 58-65 and 67-88
-- Run after 08_add_mimikara_chapter1_words_25_57.sql.
-- Item 66 was not present in the supplied pages and is intentionally omitted.
-- Duplicate words reuse the existing vocabulary row.
-- ============================================================

DO $$
DECLARE
  v_book_id      INTEGER;
  v_n3_level_id  INTEGER;
  v_noun_type_id INTEGER;
  v_chapter      INTEGER := 1;
BEGIN
  SELECT id INTO v_book_id FROM public.books
  WHERE book_name = '耳から覚える' LIMIT 1;

  SELECT id INTO v_n3_level_id FROM public.jlpt_levels
  WHERE level = 'N3' LIMIT 1;

  SELECT id INTO v_noun_type_id FROM public.word_types
  WHERE LOWER(type_name) LIKE '%noun%' OR type_name LIKE '%名詞%'
  ORDER BY id LIMIT 1;

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run migration 06 first.';
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
    ('思い出', 'おもいで', 'memory, recollection'),
    ('冗談', 'じょうだん', 'joke'),
    ('目的', 'もくてき', 'purpose'),
    ('約束', 'やくそく', 'promise, appointment'),
    ('おしゃべり', 'おしゃべり', 'chatting, talkativeness'),
    ('遠慮', 'えんりょ', 'reserve, refraining'),
    ('我慢', 'がまん', 'endurance, patience'),
    ('迷惑', 'めいわく', 'nuisance, annoyance'),
    ('夢', 'ゆめ', 'dream'),
    ('賛成', 'さんせい', 'agreement, support'),
    ('反対', 'はんたい', 'opposition, opposite'),
    ('想像', 'そうぞう', 'imagination'),
    ('努力', 'どりょく', 'effort'),
    ('太陽', 'たいよう', 'sun'),
    ('地球', 'ちきゅう', 'earth'),
    ('温度', 'おんど', 'temperature'),
    ('湿度', 'しつど', 'humidity'),
    ('湿気', 'しっけ', 'moisture, humidity'),
    ('梅雨', 'つゆ', 'rainy season'),
    ('かび', 'かび', 'mold'),
    ('暖房', 'だんぼう', 'heater, heating'),
    ('皮', 'かわ', 'skin, hide'),
    ('缶', 'かん', 'can'),
    ('画面', 'がめん', 'screen'),
    ('番組', 'ばんぐみ', 'TV/radio program'),
    ('記事', 'きじ', 'article'),
    ('近所', 'きんじょ', 'neighborhood'),
    ('警察', 'けいさつ', 'police'),
    ('犯人', 'はんにん', 'criminal'),
    ('小銭', 'こぜに', 'small change')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, v_chapter
  FROM public.vocabulary v
  WHERE v.word IN (
    '思い出', '冗談', '目的', '約束', 'おしゃべり', '遠慮', '我慢', '迷惑',
    '夢', '賛成', '反対', '想像', '努力', '太陽', '地球', '温度', '湿度',
    '湿気', '梅雨', 'かび', '暖房', '皮', '缶', '画面', '番組', '記事',
    '近所', '警察', '犯人', '小銭'
  )
  ON CONFLICT (vocab_id, book_id) DO NOTHING;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('思い出', '子どものころの思い出がたくさんあります。', 'I have many memories from childhood.'),
    ('思い出', '日本で富士山に登ったのはいい思い出です。', 'Climbing Mount Fuji in Japan is a good memory.'),
    ('思い出', '写真を見ると思い出します。', 'Looking at the photos reminds me.'),
    ('冗談', '冗談を言ったら、みんなが本気にしました。', 'When I made a joke, everyone took it seriously.'),
    ('冗談', '冗談を言わないでください。', 'Please do not make jokes.'),
    ('冗談', '彼の話は冗談だと思います。', 'I think what he said was a joke.'),
    ('目的', '日本に来た目的は大学への入学です。', 'The purpose of coming to Japan was to enter university.'),
    ('目的', '旅行の目的を教えてください。', 'Please tell me the purpose of your trip.'),
    ('目的', '目的地に着くまで二時間かかります。', 'It takes two hours to reach the destination.'),
    ('約束', '彼と結婚の約束をしました。', 'I promised to marry him.'),
    ('約束', '再会を約束して別れました。', 'We parted after promising to meet again.'),
    ('約束', '約束の時間に間に合うか心配です。', 'I am worried whether I will make it on time for the appointment.'),
    ('おしゃべり', '授業中に隣の人とおしゃべりして、先生に怒られました。', 'I chatted with the person next to me during class and was scolded.'),
    ('おしゃべり', '彼女はおしゃべりな人です。', 'She is a talkative person.'),
    ('おしゃべり', '友人とおしゃべりを楽しみました。', 'I enjoyed chatting with my friend.'),
    ('遠慮', '遠慮しないで食べてください。', 'Please help yourself and eat.'),
    ('遠慮', '上司に遠慮して、自分の意見が言えませんでした。', 'I held back before my boss and could not express my opinion.'),
    ('遠慮', 'ここではたばこはご遠慮ください。', 'Please refrain from smoking here.'),
    ('我慢', '痛くても我慢します。', 'I will endure it even if it hurts.'),
    ('我慢', '眠いのを我慢して勉強しました。', 'I studied while enduring my sleepiness.'),
    ('我慢', 'もう我慢できません。', 'I cannot stand it anymore.'),
    ('迷惑', '人に迷惑をかけてはいけません。', 'You must not cause trouble for others.'),
    ('迷惑', '夜中に騒がれて迷惑しました。', 'I was bothered by the noise at midnight.'),
    ('迷惑', '迷惑な人にならないようにしましょう。', 'Let us avoid becoming bothersome people.'),
    ('夢', 'きのう、こわい夢を見ました。', 'I had a scary dream yesterday.'),
    ('夢', 'あなたの将来の夢は何ですか。', 'What is your dream for the future?'),
    ('夢', '夢をかなえるために努力します。', 'I will work hard to make my dream come true.'),
    ('賛成', '賛成の人は手を挙げてください。', 'Those who agree, please raise your hands.'),
    ('賛成', '私はその提案に賛成です。', 'I agree with that proposal.'),
    ('賛成', 'みんな賛成してくれました。', 'Everyone agreed with me.'),
    ('反対', 'プラスの反対はマイナスです。', 'The opposite of plus is minus.'),
    ('反対', '彼の意見には反対です。', 'I am opposed to his opinion.'),
    ('反対', 'その計画に反対する人もいます。', 'Some people oppose that plan.'),
    ('想像', '想像と現実は違います。', 'Imagination and reality are different.'),
    ('想像', '100年後の未来を想像します。', 'I imagine the future 100 years from now.'),
    ('想像', '想像以上に難しい仕事でした。', 'It was a more difficult job than I imagined.'),
    ('努力', '一生懸命、努力しています。', 'I am making a great effort.'),
    ('努力', '努力を重ねれば夢が実ります。', 'If you keep making efforts, your dream will come true.'),
    ('努力', '合格するために努力しました。', 'I worked hard to pass.'),
    ('太陽', '太陽が昇って、暖かくなりました。', 'The sun rose and it became warm.'),
    ('太陽', '太陽が沈む前に帰りましょう。', 'Let us return before the sun sets.'),
    ('太陽', '太陽の光がまぶしいです。', 'The sunlight is dazzling.'),
    ('地球', '地球の環境が悪化しています。', 'The Earth''s environment is getting worse.'),
    ('地球', '地球は太陽の周りを回っています。', 'The Earth revolves around the sun.'),
    ('地球', '地球を大切にしましょう。', 'Let us take care of the Earth.'),
    ('温度', '温度を測ります。', 'I will measure the temperature.'),
    ('温度', '部屋の温度が高すぎます。', 'The room temperature is too high.'),
    ('温度', '温度を少し下げてください。', 'Please lower the temperature a little.'),
    ('湿度', '今年の夏は特に湿度が高いです。', 'This summer, the humidity is especially high.'),
    ('湿度', '今日は湿度が60％で蒸し暑いです。', 'Today the humidity is 60 percent and it is hot and humid.'),
    ('湿度', '湿度を下げるために窓を開けました。', 'I opened the window to lower the humidity.'),
    ('湿気', '日本の夏は湿気が多いです。', 'Japanese summers are humid.'),
    ('湿気', '湿気が多いとカビが生えやすいです。', 'Mold grows easily when there is a lot of moisture.'),
    ('湿気', '部屋の湿気を取ります。', 'I remove the moisture from the room.'),
    ('梅雨', '6月から7月は梅雨の時期です。', 'June to July is the rainy season.'),
    ('梅雨', '梅雨に入ると雨の日が続きます。', 'When the rainy season begins, rainy days continue.'),
    ('梅雨', '梅雨が明けたら海へ行きたいです。', 'I want to go to the sea when the rainy season ends.'),
    ('かび', '梅雨の時期はかびが生えやすいです。', 'Mold tends to grow during the rainy season.'),
    ('かび', 'パンにかびが生えていました。', 'There was mold growing on the bread.'),
    ('かび', 'かびをきれいに取りました。', 'I cleaned off the mold.'),
    ('暖房', '寒いので暖房をつけます。', 'It is cold, so I will turn on the heater.'),
    ('暖房', 'この部屋は暖房がきいていて暖かいです。', 'This room is warm because the heating is on.'),
    ('暖房', '寝る前に暖房を止めました。', 'I turned off the heater before going to bed.'),
    ('皮', 'りんごの皮をむいて食べます。', 'I peel an apple and eat it.'),
    ('皮', '動物の皮でかばんを作りました。', 'A bag was made from animal hide.'),
    ('皮', 'じゃがいもの皮をむきます。', 'I peel the potatoes.'),
    ('缶', 'おかしを缶に入れて保存します。', 'I store the sweets in a can.'),
    ('缶', '缶ビールを一本飲みました。', 'I drank one can of beer.'),
    ('缶', '空き缶はここに捨ててください。', 'Please throw empty cans away here.'),
    ('画面', 'パソコンの画面をずっと見ていると、目が疲れます。', 'My eyes get tired if I keep looking at the computer screen.'),
    ('画面', '画面に名前を入力してください。', 'Please enter your name on the screen.'),
    ('画面', '画面が暗くて見えません。', 'The screen is too dark to see.'),
    ('番組', 'テレビの番組を見ます。', 'I watch a television program.'),
    ('番組', '新聞の番組欄を確認しました。', 'I checked the TV listings in the newspaper.'),
    ('番組', '好きな番組を録画しました。', 'I recorded my favorite program.'),
    ('記事', 'この記事によると、日本に住む外国人が増えているそうです。', 'According to this article, the number of foreigners living in Japan is increasing.'),
    ('記事', '新聞の記事を読みました。', 'I read an article in the newspaper.'),
    ('記事', 'その記事はとても興味深かったです。', 'That article was very interesting.'),
    ('近所', '近所の人とは仲良くしたほうがいいです。', 'It is better to get along with your neighbors.'),
    ('近所', '私はよく近所の公園を散歩します。', 'I often take walks in the neighborhood park.'),
    ('近所', '近所に新しい店ができました。', 'A new shop opened in the neighborhood.'),
    ('警察', '自転車を盗まれたので、警察に届けました。', 'My bicycle was stolen, so I reported it to the police.'),
    ('警察', '警察に道を聞きました。', 'I asked the police for directions.'),
    ('警察', '警察官が事故の現場に来ました。', 'A police officer came to the scene of the accident.'),
    ('犯人', '事件の犯人が捕まりました。', 'The criminal in the case was arrested.'),
    ('犯人', '犯人をつかまえるために捜査しています。', 'They are investigating to catch the criminal.'),
    ('犯人', '犯人はまだ見つかっていません。', 'The criminal has not been found yet.'),
    ('小銭', 'バスに乗ってから小銭がないことに気づきました。', 'After getting on the bus, I realized I had no small change.'),
    ('小銭', '小銭を財布に入れました。', 'I put the coins in my wallet.'),
    ('小銭', '小銭で払ってもいいですか。', 'May I pay with coins?')
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
    '思い出', '冗談', '目的', '約束', 'おしゃべり', '遠慮', '我慢', '迷惑',
    '夢', '賛成', '反対', '想像', '努力', '太陽', '地球', '温度', '湿度',
    '湿気', '梅雨', 'かび', '暖房', '皮', '缶', '画面', '番組', '記事',
    '近所', '警察', '犯人', '小銭'
  )
GROUP BY v.word, v.reading, wt.type_name, vb.lesson_number
ORDER BY v.word;
