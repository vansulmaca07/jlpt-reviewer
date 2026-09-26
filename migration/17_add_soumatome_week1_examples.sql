-- ============================================================
-- Soumatome N3 - Week 1 additional example sentences
-- Examples use N5-N3-level vocabulary and grammar.
-- Safe to re-run: duplicate word/sentence pairs are skipped.
-- ============================================================

BEGIN;

INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
SELECT v.id, examples.japanese_sentence, examples.english_translation
FROM (VALUES
  ('駐車', 'ここに駐車してもいいですか。', 'May I park here?'),
  ('駐車場', '駅の近くに駐車場があります。', 'There is a parking lot near the station.'),
  ('無い', '冷蔵庫に牛乳が無いです。', 'There is no milk in the refrigerator.'),
  ('無料', 'このイベントは無料です。', 'This event is free.'),
  ('無理', '今日は忙しいので、参加するのは無理です。', 'I am busy today, so it is impossible for me to participate.'),
  ('無休', 'この店は年中無休です。', 'This shop is open every day of the year.'),
  ('満員', '電車が満員で乗れませんでした。', 'The train was full, so I could not get on.'),
  ('満車', '駐車場は満車でした。', 'The parking lot was full.'),
  ('不満', '今の仕事に少し不満があります。', 'I have some dissatisfaction with my current job.'),
  ('向こう', '駅は川の向こうにあります。', 'The station is on the other side of the river.'),
  ('向かう', 'これから学校へ向かいます。', 'I am heading to school now.'),
  ('～向き', 'この本は初級者向きです。', 'This book is suitable for beginners.'),
  ('方向', '駅の方向を教えてください。', 'Please tell me the direction of the station.'),
  ('禁止', 'ここでは写真撮影が禁止されています。', 'Taking photographs is prohibited here.'),
  ('関する', '日本の歴史に関する本を読みました。', 'I read a book about Japanese history.'),
  ('関心', '環境問題に関心があります。', 'I am interested in environmental issues.'),
  ('係', '受付の係に聞いてください。', 'Please ask the person in charge at reception.'),
  ('関係', 'その問題は仕事と関係があります。', 'That problem is related to work.'),
  ('断る', '忙しかったので、誘いを断りました。', 'I was busy, so I refused the invitation.'),
  ('断水', '工事のため、明日は断水します。', 'The water will be shut off tomorrow because of construction.'),
  ('無断', '無断で写真を使わないでください。', 'Please do not use the photo without permission.'),

  ('横', '道の横に小さな店があります。', 'There is a small shop beside the road.'),
  ('横断歩道', '横断歩道を渡ってください。', 'Please cross at the pedestrian crossing.'),
  ('横断', '道路を横断するときは気をつけてください。', 'Please be careful when crossing the road.'),
  ('押す', 'このボタンを押してください。', 'Please press this button.'),
  ('押さえる', 'ドアを手で押さえてください。', 'Please hold the door down with your hand.'),
  ('押し入れ', '布団を押し入れに入れました。', 'I put the futon in the closet.'),
  ('入学式', '来週、大学の入学式があります。', 'There is a university entrance ceremony next week.'),
  ('押しボタン式', 'この信号は押しボタン式です。', 'This traffic light is push-button operated.'),
  ('数式', '黒板に数式を書きました。', 'I wrote a mathematical formula on the blackboard.'),
  ('信じる', '私は友達を信じています。', 'I believe in my friend.'),
  ('信用', 'あの店は信用できます。', 'That shop can be trusted.'),
  ('自信', '日本語を話す自信がつきました。', 'I have gained confidence in speaking Japanese.'),
  ('送信', 'メールを確認してから送信してください。', 'Please send the email after checking it.'),
  ('～号車', '東京行きの電車の三号車に乗りました。', 'I got on car number three of the train bound for Tokyo.'),
  ('信号', '信号が青になったら渡りましょう。', 'Let us cross when the traffic light turns green.'),
  ('確かめる', '時間をもう一度確かめました。', 'I checked the time once more.'),
  ('確か', '確か、会議は三時からです。', 'If I remember correctly, the meeting starts at three.'),
  ('正確', '正確な住所を書いてください。', 'Please write the exact address.'),
  ('認める', '先生は私の努力を認めてくれました。', 'My teacher recognized my effort.'),
  ('確認', '予約の確認メールが届きました。', 'A reservation confirmation email arrived.'),
  ('飛ぶ', '鳥が空を飛んでいます。', 'A bird is flying in the sky.'),
  ('飛行機', '飛行機で大阪へ行きます。', 'I will go to Osaka by airplane.'),
  ('飛行場', '飛行場までバスで一時間かかります。', 'It takes an hour by bus to the airport.'),

  ('非常に', '今日は非常に暑いです。', 'It is extremely hot today.'),
  ('非常', '非常のときは落ち着いてください。', 'Please stay calm in an emergency.'),
  ('非常口', '非常口はあちらです。', 'The emergency exit is over there.'),
  ('正常', '機械は正常に動いています。', 'The machine is working normally.'),
  ('日常', '日常の会話を練習しています。', 'I am practicing everyday conversation.'),
  ('～階', '私の部屋は三階です。', 'My room is on the third floor.'),
  ('階段', '階段を使って二階へ行きました。', 'I used the stairs to go to the second floor.'),
  ('箱', '大きな箱が届きました。', 'A large box arrived.'),
  ('ごみ箱', '紙をごみ箱に捨ててください。', 'Please throw the paper in the trash bin.'),
  ('危ない', 'そこは危ないので入らないでください。', 'That place is dangerous, so please do not enter.'),
  ('危険', 'この道は夜になると危険です。', 'This road is dangerous at night.'),
  ('捨てる', '古い服を捨てました。', 'I threw away my old clothes.'),

  ('～番線', '電車は三番線から出ます。', 'The train leaves from platform number three.'),
  ('線', '紙にまっすぐな線を引きました。', 'I drew a straight line on the paper.'),
  ('画面', '画面に名前を入力してください。', 'Please enter your name on the screen.'),
  ('全面', '道路は全面通行止めです。', 'The road is completely closed to traffic.'),
  ('～方面', '京都方面の電車に乗ります。', 'I will take the train bound for the Kyoto area.'),
  ('普通', '普通の電車に乗りました。', 'I took a local train.'),
  ('各国', '各国の料理を食べてみたいです。', 'I want to try food from each country.'),
  ('各駅', 'この電車は各駅に止まります。', 'This train stops at every station.'),
  ('各自', '荷物は各自で管理してください。', 'Please manage your own luggage.'),
  ('次', '次の駅で降ります。', 'I will get off at the next station.'),
  ('次回', '次回はもっと早く来ます。', 'I will come earlier next time.'),
  ('目次', 'まず本の目次を見ました。', 'First, I looked at the table of contents.'),
  ('快速', '快速電車は早く着きます。', 'The rapid train arrives quickly.'),
  ('速い', 'この電車はとても速いです。', 'This train is very fast.'),
  ('速度', '車の速度を下げてください。', 'Please reduce the speed of the car.'),
  ('高速道路', '高速道路を使って旅行しました。', 'We traveled using the expressway.'),
  ('過去', '過去の写真を見ました。', 'I looked at photos from the past.'),
  ('過ぎる', '駅を過ぎてから右に曲がります。', 'After passing the station, turn right.'),
  ('通過', '電車が駅を通過しました。', 'The train passed through the station.'),
  ('鉄道', '日本の鉄道は便利です。', 'Japan’s railways are convenient.'),
  ('鉄', 'この橋は鉄でできています。', 'This bridge is made of iron.'),
  ('地下鉄', '地下鉄で会社へ通っています。', 'I commute to work by subway.'),

  ('指', '指をけがしました。', 'I injured my finger.'),
  ('指輪', '母に指輪を買いました。', 'I bought a ring for my mother.'),
  ('指定', '指定された場所に集まってください。', 'Please gather at the designated place.'),
  ('指定席', '指定席の切符を買いました。', 'I bought a reserved-seat ticket.'),
  ('安定', '会社の仕事は安定しています。', 'The company job is stable.'),
  ('祝日', '祝日は学校が休みです。', 'School is closed on public holidays.'),
  ('席', '空いている席に座ってください。', 'Please sit in an empty seat.'),
  ('欠席', '病気で授業を欠席しました。', 'I was absent from class because I was sick.'),
  ('出席', '会議には全員が出席しました。', 'Everyone attended the meeting.'),
  ('自由', 'この時間は自由に使ってください。', 'Please use this time freely.'),
  ('自由席', '自由席は後ろの車両です。', 'The non-reserved seats are in the rear car.'),
  ('理由', '遅れた理由を説明しました。', 'I explained the reason I was late.'),
  ('～番', '受付で番号を呼ばれるまで待ちます。', 'I will wait until my number is called at reception.'),
  ('一番', '一番線の電車に乗ってください。', 'Please take the train at platform one.'),
  ('番号', '電話番号を教えてください。', 'Please tell me your telephone number.'),
  ('窓', '窓を開けてもいいですか。', 'May I open the window?'),
  ('窓口', '窓口で切符を買いました。', 'I bought a ticket at the service window.'),
  ('両側', '道の両側に木があります。', 'There are trees on both sides of the road.'),
  ('窓側', '窓側の席をお願いします。', 'A window-side seat, please.'),
  ('右側', '駅は道の右側にあります。', 'The station is on the right side of the road.'),
  ('通路', '通路をふさがないでください。', 'Please do not block the aisle.'),
  ('道路', 'この道路は車が多いです。', 'There are many cars on this road.'),
  ('線路', '線路に入ってはいけません。', 'You must not enter the railway tracks.'),

  ('バス停', 'バス停で友達を待っています。', 'I am waiting for my friend at the bus stop.'),
  ('停車', 'バスが駅前に停車しました。', 'The bus stopped in front of the station.'),
  ('整理', '机の上を整理しました。', 'I organized the top of my desk.'),
  ('整理券', '整理券を取って順番を待ちます。', 'I will take a numbered ticket and wait my turn.'),
  ('乗車券', '乗車券をなくしてしまいました。', 'I lost my boarding ticket.'),
  ('駐車券', '駐車券を入口でもらいました。', 'I received a parking ticket at the entrance.'),
  ('回数券', '回数券を買うと少し安くなります。', 'It becomes a little cheaper if you buy a book of tickets.'),
  ('現れる', '駅に友達が現れました。', 'My friend appeared at the station.'),
  ('表現', 'この表現の意味を教えてください。', 'Please tell me the meaning of this expression.'),
  ('現金', '現金で払います。', 'I will pay in cash.'),
  ('両親', '週末に両親へ電話します。', 'I will call my parents on the weekend.'),
  ('～両', 'この電車は十両編成です。', 'This train has ten cars.'),
  ('取り替える', '電池を新しいものに取り替えました。', 'I replaced the battery with a new one.'),
  ('着替える', '家に帰ってから服を着替えます。', 'I will change clothes after returning home.'),
  ('両替', '銀行でドルを円に両替しました。', 'I exchanged dollars for yen at the bank.'),
  ('優しい', '店員さんがとても優しいです。', 'The shop clerk is very kind.'),
  ('女優', 'その女優は有名です。', 'That actress is famous.'),
  ('優先席', '優先席の近くでは静かにしてください。', 'Please be quiet near the priority seats.'),
  ('座る', 'ここに座ってください。', 'Please sit here.'),
  ('正座', '畳の上で正座しました。', 'I sat formally on the tatami.'),
  ('座席', '座席番号を確認してください。', 'Please check your seat number.'),
  ('降りる', '次の駅で電車を降ります。', 'I will get off the train at the next station.'),
  ('以降', '午後六時以降は入れません。', 'You cannot enter after six p.m.'),
  ('降る', '午後から雨が降るそうです。', 'I hear it will rain from the afternoon.'),
  ('降車口', '降車口はバスの後ろです。', 'The exit for getting off is at the back of the bus.')
) AS examples(word, japanese_sentence, english_translation)
JOIN public.vocabulary v ON v.word = examples.word
WHERE NOT EXISTS (
  SELECT 1
  FROM public.example_sentences existing
  WHERE existing.vocab_id = v.id
    AND existing.japanese_sentence = examples.japanese_sentence
);

COMMIT;

SELECT
  COUNT(*) AS examples_added_or_existing,
  COUNT(DISTINCT es.vocab_id) AS words_with_examples
FROM public.example_sentences es
JOIN public.vocabulary v ON v.id = es.vocab_id
WHERE v.word IN (
  '駐車', '駐車場', '無い', '無料', '無理', '無休', '満員', '満車', '不満', '向こう',
  '向かう', '～向き', '方向', '禁止', '関する', '関心', '係', '関係', '断る', '断水', '無断',
  '横', '横断歩道', '横断', '押す', '押さえる', '押し入れ', '入学式', '押しボタン式', '数式',
  '信じる', '信用', '自信', '送信', '～号車', '信号', '確かめる', '確か', '正確', '認める',
  '確認', '飛ぶ', '飛行機', '飛行場', '非常に', '非常', '非常口', '正常', '日常', '～階',
  '階段', '箱', 'ごみ箱', '危ない', '危険', '捨てる', '～番線', '線', '画面', '全面', '～方面',
  '普通', '各国', '各駅', '各自', '次', '次回', '目次', '快速', '速い', '速度', '高速道路',
  '過去', '過ぎる', '通過', '鉄道', '鉄', '地下鉄', '指', '指輪', '指定', '指定席', '安定',
  '祝日', '席', '欠席', '出席', '自由', '自由席', '理由', '～番', '一番', '番号', '窓', '窓口',
  '両側', '窓側', '右側', '通路', '道路', '線路', 'バス停', '停車', '整理', '整理券', '乗車券',
  '駐車券', '回数券', '現れる', '表現', '現金', '両親', '～両', '取り替える', '着替える', '両替',
  '優しい', '女優', '優先席', '座る', '正座', '座席', '降りる', '以降', '降る', '降車口'
);