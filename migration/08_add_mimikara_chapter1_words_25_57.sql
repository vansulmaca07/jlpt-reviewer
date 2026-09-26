-- ============================================================
-- 耳から覚える N3 - Chapter 1, Words 25-57
-- Run after 07_add_mimikara_chapter1_words_08_24.sql.
-- Duplicate words reuse the existing vocabulary row and receive
-- a separate link to this book through vocabulary_books.
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
    ('失業', 'しつぎょう', 'unemployment'),
    ('残業', 'ざんぎょう', 'overtime work'),
    ('生活', 'せいかつ', 'life, living'),
    ('通勤', 'つうきん', 'commuting to work'),
    ('学歴', 'がくれき', 'educational background'),
    ('給料', 'きゅうりょう', 'salary, pay'),
    ('面接', 'めんせつ', 'interview'),
    ('休憩', 'きゅうけい', 'break, rest'),
    ('観光', 'かんこう', 'tourism, sightseeing'),
    ('帰国', 'きこく', 'returning to one''s country'),
    ('帰省', 'きせい', 'returning to one''s hometown'),
    ('帰宅', 'きたく', 'going home'),
    ('参加', 'さんか', 'participation'),
    ('出席', 'しゅっせき', 'attendance'),
    ('欠席', 'けっせき', 'absence'),
    ('遅刻', 'ちこく', 'being late'),
    ('化粧', 'けしょう', 'makeup'),
    ('計算', 'けいさん', 'calculation'),
    ('計画', 'けいかく', 'plan'),
    ('成功', 'せいこう', 'success'),
    ('失敗', 'しっぱい', 'failure'),
    ('準備', 'じゅんび', 'preparation'),
    ('整理', 'せいり', 'organizing, arrangement'),
    ('注文', 'ちゅうもん', 'order, request'),
    ('貯金', 'ちょきん', 'savings, depositing'),
    ('徹夜', 'てつや', 'staying up all night'),
    ('引っ越し', 'ひっこし', 'moving house'),
    ('身長', 'しんちょう', 'body height'),
    ('体重', 'たいじゅう', 'body weight'),
    ('けが', 'けが', 'injury'),
    ('会', 'かい', 'party, gathering'),
    ('趣味', 'しゅみ', 'hobby, interest, taste'),
    ('興味', 'きょうみ', 'interest')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, v_chapter
  FROM public.vocabulary v
  WHERE v.word IN (
    '失業', '残業', '生活', '通勤', '学歴', '給料', '面接', '休憩', '観光',
    '帰国', '帰省', '帰宅', '参加', '出席', '欠席', '遅刻', '化粧', '計算',
    '計画', '成功', '失敗', '準備', '整理', '注文', '貯金', '徹夜', '引っ越し',
    '身長', '体重', 'けが', '会', '趣味', '興味'
  )
  ON CONFLICT (vocab_id, book_id) DO NOTHING;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('失業', '会社が倒産して失業しました。', 'The company went bankrupt and I became unemployed.'),
    ('失業', '失業した友人を助けたいです。', 'I want to help my unemployed friend.'),
    ('失業', '失業保険を申請しました。', 'I applied for unemployment insurance.'),
    ('残業', '残業が多くて疲れました。', 'I was tired because I worked a lot of overtime.'),
    ('残業', '今日は残業をしないで帰ります。', 'I will go home without working overtime today.'),
    ('残業', '残業代は出ますか。', 'Will I get overtime pay?'),
    ('生活', '健康的な生活を送っています。', 'I lead a healthy lifestyle.'),
    ('生活', 'もう日本の生活に慣れましたか。', 'Have you gotten used to life in Japan?'),
    ('生活', '外国で生活するのは楽しいです。', 'Living abroad is fun.'),
    ('通勤', '毎日一時間かけて通勤しています。', 'I commute for an hour every day.'),
    ('通勤', '通勤電車はいつも混んでいます。', 'The commuter trains are always crowded.'),
    ('通勤', '自転車で通勤することにしました。', 'I decided to commute by bicycle.'),
    ('学歴', '学歴が高くても実力があるとは限りません。', 'A high educational background does not necessarily mean ability.'),
    ('学歴', '履歴書に学歴を書きました。', 'I wrote my educational background on my resume.'),
    ('学歴', '学歴より経験を重視する会社もあります。', 'Some companies value experience more than education.'),
    ('給料', '会社から給料をもらいました。', 'I received my salary from the company.'),
    ('給料', '給料が上がったのでうれしいです。', 'I am happy because my salary went up.'),
    ('給料', '給料の一部を貯金しています。', 'I save part of my salary.'),
    ('面接', 'きょう、会社の人との面接があります。', 'I have an interview with someone from the company today.'),
    ('面接', '受験者の面接を行いました。', 'We conducted interviews with the applicants.'),
    ('面接', '面接では明るく話してください。', 'Please speak cheerfully during the interview.'),
    ('休憩', 'ではここで、10分間の休憩です。', 'Now, let us take a ten-minute break here.'),
    ('休憩', '疲れたので少し休憩しましょう。', 'I am tired, so let us take a short break.'),
    ('休憩', '昼休みに友人と休憩しました。', 'I took a break with my friend during lunch.'),
    ('観光', '来日の目的は観光です。', 'The purpose of my visit to Japan is sightseeing.'),
    ('観光', '先週、京都を観光してまわりました。', 'I went sightseeing around Kyoto last week.'),
    ('観光', '京都観光には何日必要ですか。', 'How many days do you need for sightseeing in Kyoto?'),
    ('帰国', '今度の正月には帰国するつもりです。', 'I intend to return to my country this New Year.'),
    ('帰国', '卒業したら帰国します。', 'I will return to my country after graduating.'),
    ('帰国', '帰国前に友人へ挨拶しました。', 'I said goodbye to my friends before returning home.'),
    ('帰省', 'お盆にはふるさとに帰省する人が多いです。', 'Many people return to their hometowns during Obon.'),
    ('帰省', '今年の夏は実家に帰省しました。', 'I returned to my parents'' home this summer.'),
    ('帰省', '年末に帰省する予定です。', 'I plan to return to my hometown at the end of the year.'),
    ('帰宅', '毎日忙しくて帰宅が遅いです。', 'I am busy every day and get home late.'),
    ('帰宅', '帰宅したらすぐに手を洗います。', 'I wash my hands as soon as I get home.'),
    ('帰宅', '帰宅時間を家族に連絡しました。', 'I told my family what time I would get home.'),
    ('参加', 'ボランティア活動に参加します。', 'I participate in volunteer activities.'),
    ('参加', '会議には全員が参加しました。', 'Everyone participated in the meeting.'),
    ('参加', 'ぜひパーティーに参加してください。', 'Please join the party by all means.'),
    ('出席', 'ミーティングに出席します。', 'I will attend the meeting.'),
    ('出席', '授業に毎日出席しています。', 'I attend class every day.'),
    ('出席', '出席者の名前を確認しました。', 'I checked the names of the attendees.'),
    ('欠席', '授業を欠席する場合は連絡してください。', 'Please contact us if you will be absent from class.'),
    ('欠席', '高橋さんは今度の同窓会を欠席だそうです。', 'I hear Takahashi will be absent from the next reunion.'),
    ('欠席', '病気のため会議を欠席しました。', 'I was absent from the meeting because I was sick.'),
    ('遅刻', '寝坊して授業に遅刻しました。', 'I overslept and was late for class.'),
    ('遅刻', '面接では一分の遅刻も許されません。', 'Even being one minute late is not allowed for an interview.'),
    ('遅刻', '電車が遅れて会社に遅刻しました。', 'The train was delayed and I was late for work.'),
    ('化粧', 'あなたは毎日、お化粧に何分ぐらいかけていますか。', 'About how many minutes do you spend putting on makeup every day?'),
    ('化粧', '出かける前に化粧をします。', 'I put on makeup before going out.'),
    ('化粧', '化粧を落としてから寝ます。', 'I remove my makeup before going to bed.'),
    ('計算', '私は計算が苦手です。', 'I am bad at calculations.'),
    ('計算', '旅行にいくらかかるか計算します。', 'I will calculate how much the trip will cost.'),
    ('計算', '電卓で計算してください。', 'Please calculate it with a calculator.'),
    ('計画', '来年の計画を立てます。', 'I will make plans for next year.'),
    ('計画', '夏休みに富士山に登ろうと計画しています。', 'I am planning to climb Mount Fuji during summer vacation.'),
    ('計画', '計画どおりに仕事が進みません。', 'The work is not progressing according to plan.'),
    ('成功', '実験に成功しました。', 'The experiment was successful.'),
    ('成功', '実験は大成功でした。', 'The experiment was a great success.'),
    ('成功', '計画を成功させるために努力します。', 'I will work hard to make the plan successful.'),
    ('失敗', '実験に失敗しました。', 'The experiment failed.'),
    ('失敗', 'このパソコンを買ったのは失敗でした。', 'Buying this computer was a mistake.'),
    ('失敗', '入試に失敗したくありません。', 'I do not want to fail the entrance examination.'),
    ('準備', '引っ越しの準備が終わりました。', 'The preparations for moving are finished.'),
    ('準備', '会議の資料を準備しています。', 'I am preparing the materials for the meeting.'),
    ('準備', '旅行の準備を始めましょう。', 'Let us start preparing for the trip.'),
    ('整理', '資料の整理をしました。', 'I organized the documents.'),
    ('整理', '勉強の前に机の上を整理します。', 'I organize my desk before studying.'),
    ('整理', '引っ越しの前に古い物を整理しました。', 'I sorted out old things before moving.'),
    ('注文', '注文の品が届きました。', 'The item I ordered arrived.'),
    ('注文', '喫茶店でコーヒーを注文しました。', 'I ordered coffee at the cafe.'),
    ('注文', '書店に本を注文しました。', 'I ordered a book from the bookstore.'),
    ('貯金', '貯金が増えています。', 'My savings are increasing.'),
    ('貯金', '銀行にボーナスを貯金しました。', 'I deposited my bonus in the bank.'),
    ('貯金', '将来のために貯金しています。', 'I am saving money for the future.'),
    ('徹夜', '徹夜が続いて疲れました。', 'I am tired because I kept staying up all night.'),
    ('徹夜', '徹夜で勉強するのは体によくありません。', 'Studying all night is not good for your health.'),
    ('徹夜', 'きょうは徹夜だと思います。', 'I think I will stay up all night today.'),
    ('引っ越し', '引っ越しを手伝ってください。', 'Please help me move.'),
    ('引っ越し', '東京から横浜へ引っ越しします。', 'I am moving from Tokyo to Yokohama.'),
    ('引っ越し', '引っ越しの荷物をまとめました。', 'I packed up my moving belongings.'),
    ('身長', '身長を測りました。', 'I measured my height.'),
    ('身長', '兄は身長が高いです。', 'My older brother is tall.'),
    ('身長', '身長が高い人が好きです。', 'I like tall people.'),
    ('体重', '体重を測りました。', 'I weighed myself.'),
    ('体重', '父の体重は60キロです。', 'My father weighs 60 kilograms.'),
    ('体重', '健康のために体重を減らしたいです。', 'I want to lose weight for my health.'),
    ('けが', '小さなけがをしました。', 'I got a minor injury.'),
    ('けが', '転んで足にけがをしました。', 'I fell and injured my leg.'),
    ('けが', 'けがが治るまで運動しません。', 'I will not exercise until my injury heals.'),
    ('会', '忘年会を開きました。', 'We held a year-end party.'),
    ('会', '新年会に参加します。', 'I will attend the New Year''s party.'),
    ('会', '同窓会で友人に会いました。', 'I met friends at the school reunion.'),
    ('趣味', '趣味は読書です。', 'My hobby is reading.'),
    ('趣味', '彼女はいつも趣味のいい服を着ています。', 'She always wears tasteful clothes.'),
    ('趣味', '趣味が広いので、いろいろなことを知っています。', 'He has broad interests, so he knows about many things.'),
    ('興味', '私は歴史に興味があります。', 'I am interested in history.'),
    ('興味', '小さな子どもは何にでも興味を持ちます。', 'Small children are interested in everything.'),
    ('興味', '日本の文化に興味を持っています。', 'I am interested in Japanese culture.')
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
    '失業', '残業', '生活', '通勤', '学歴', '給料', '面接', '休憩', '観光',
    '帰国', '帰省', '帰宅', '参加', '出席', '欠席', '遅刻', '化粧', '計算',
    '計画', '成功', '失敗', '準備', '整理', '注文', '貯金', '徹夜', '引っ越し',
    '身長', '体重', 'けが', '会', '趣味', '興味'
  )
GROUP BY v.word, v.reading, wt.type_name, vb.lesson_number
ORDER BY v.word;
