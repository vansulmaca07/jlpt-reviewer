-- ============================================================
-- 耳から覚える N3 - Chapter 1, Words 8-24
-- Run after 06_add_mimikara_unit1.sql.
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
  SELECT id INTO v_book_id
  FROM public.books
  WHERE book_name = '耳から覚える'
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
    RAISE EXCEPTION '耳から覚える book not found. Run migration 06 first.';
  END IF;

  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 not found in jlpt_levels.';
  END IF;

  IF v_noun_type_id IS NULL THEN
    RAISE EXCEPTION 'Noun not found in word_types.';
  END IF;

  INSERT INTO public.vocabulary (
    word,
    reading,
    meaning,
    word_type_id,
    jlpt_level_id
  )
  SELECT
    data.word,
    data.reading,
    data.meaning,
    v_noun_type_id,
    v_n3_level_id
  FROM (VALUES
    ('上司', 'じょうし', 'boss, superior'),
    ('相手', 'あいて', 'other person, partner, opponent'),
    ('知り合い', 'しりあい', 'acquaintance'),
    ('友人', 'ゆうじん', 'friend'),
    ('仲', 'なか', 'relationship, terms'),
    ('生年月日', 'せいねんがっぴ', 'date of birth'),
    ('誕生', 'たんじょう', 'birth'),
    ('年', 'とし', 'year, age'),
    ('出身', 'しゅっしん', 'origin, hometown'),
    ('故郷', 'こきょう', 'hometown'),
    ('成長', 'せいちょう', 'growth, development'),
    ('成人', 'せいじん', 'adult'),
    ('合格', 'ごうかく', 'passing, acceptance'),
    ('進学', 'しんがく', 'advancing to higher education'),
    ('退学', 'たいがく', 'dropping out, withdrawal from school'),
    ('就職', 'しゅうしょく', 'finding employment'),
    ('退職', 'たいしょく', 'resignation, retirement')
  ) AS data(word, reading, meaning)
  ON CONFLICT (word) DO NOTHING;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, v_chapter
  FROM public.vocabulary v
  WHERE v.word IN (
    '上司', '相手', '知り合い', '友人', '仲', '生年月日', '誕生', '年',
    '出身', '故郷', '成長', '成人', '合格', '進学', '退学', '就職', '退職'
  )
  ON CONFLICT (vocab_id, book_id) DO NOTHING;

  INSERT INTO public.example_sentences (
    vocab_id,
    japanese_sentence,
    english_translation
  )
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('上司', '上司に相談してから決定します。', 'I will decide after consulting my boss.'),
    ('上司', '新しい上司はとても話しやすいです。', 'My new boss is very easy to talk to.'),
    ('上司', '上司から仕事を頼まれました。', 'My boss asked me to do some work.'),
    ('相手', '相手の目を見て話してください。', 'Please look the other person in the eye when speaking.'),
    ('相手', '今度の試合の相手は強そうです。', 'Our opponent in the next match looks strong.'),
    ('相手', '相手の気持ちを考えることが大切です。', 'It is important to consider the other person’s feelings.'),
    ('知り合い', '知り合いに息子の就職を頼みました。', 'I asked an acquaintance to help my son find a job.'),
    ('知り合い', '駅で昔の知り合いに会いました。', 'I met an old acquaintance at the station.'),
    ('知り合い', 'この町には知り合いが一人もいません。', 'I do not have a single acquaintance in this town.'),
    ('友人', '田中さんは学生時代の友人です。', 'Tanaka is a friend from my school days.'),
    ('友人', '週末に友人と映画を見ました。', 'I watched a movie with a friend over the weekend.'),
    ('友人', '困ったとき、友人が助けてくれました。', 'A friend helped me when I was in trouble.'),
    ('仲', '私は山本さんと仲がいいです。', 'I am on good terms with Yamamoto.'),
    ('仲', '二人はけんかをして仲が悪くなりました。', 'The two had a fight and their relationship worsened.'),
    ('仲', '同じチームの仲間とは仲よくしています。', 'I get along well with my teammates.'),
    ('生年月日', '書類に生年月日を記入してください。', 'Please enter your date of birth on the form.'),
    ('生年月日', '本人確認のため、生年月日を伺います。', 'We ask for your date of birth to verify your identity.'),
    ('生年月日', 'この欄には生年月日を書きます。', 'Write your date of birth in this field.'),
    ('誕生', '新しい命の誕生を祝いました。', 'We celebrated the birth of a new life.'),
    ('誕生', '結婚二年目に子どもが誕生しました。', 'Our child was born in the second year of our marriage.'),
    ('誕生', 'この町に新しい会社が誕生しました。', 'A new company was established in this town.'),
    ('年', '年の初めに一年の計画を立てます。', 'I make a plan for the year at the beginning of the year.'),
    ('年', '父は年より若く見えます。', 'My father looks younger than his age.'),
    ('年', '年を取っても元気でいたいです。', 'I want to stay healthy even as I grow older.'),
    ('出身', 'ご出身はどちらですか。', 'Where are you from?'),
    ('出身', '私は東京の出身です。', 'I am from Tokyo.'),
    ('出身', '彼女は東京大学の出身です。', 'She graduated from the University of Tokyo.'),
    ('故郷', '仕事が忙しくて、何年も故郷に帰っていません。', 'I have been too busy with work to return to my hometown for years.'),
    ('故郷', '休みには故郷の家族に会いに行きます。', 'During vacation, I go to my hometown to see my family.'),
    ('故郷', 'この歌を聞くと故郷を思い出します。', 'This song reminds me of my hometown.'),
    ('成長', '子どもの成長を喜びました。', 'We were delighted by our child’s growth.'),
    ('成長', 'りっぱな大人に成長してほしいです。', 'I hope you grow into a fine adult.'),
    ('成長', 'この会社は十年間で大きく成長しました。', 'This company grew significantly over ten years.'),
    ('成人', '日本では十八歳以上の人を成人といいます。', 'In Japan, people aged eighteen and over are considered adults.'),
    ('成人', '息子は成人して働いています。', 'My son is an adult and is working.'),
    ('成人', '来年、妹は成人式に出ます。', 'My younger sister will attend the coming-of-age ceremony next year.'),
    ('合格', '大学の入学試験に合格しました。', 'I passed the university entrance examination.'),
    ('合格', '合格するために毎日勉強しています。', 'I study every day in order to pass.'),
    ('合格', '試験の合格者が発表されました。', 'The successful exam candidates were announced.'),
    ('進学', '子どもの進学について家族で話しました。', 'Our family discussed our child’s further education.'),
    ('進学', '卒業後は大学院に進学する予定です。', 'I plan to advance to graduate school after graduation.'),
    ('進学', '彼は進学のために東京へ引っ越しました。', 'He moved to Tokyo to continue his education.'),
    ('退学', '彼は病気で大学を退学しました。', 'He withdrew from university because of illness.'),
    ('退学', '退学の理由を先生に説明しました。', 'I explained the reason for leaving school to my teacher.'),
    ('退学', '学校を退学する前によく考えてください。', 'Please think carefully before dropping out of school.'),
    ('就職', '卒業後、旅行会社に就職しました。', 'After graduating, I found a job at a travel agency.'),
    ('就職', '兄は銀行への就職を希望しています。', 'My older brother hopes to find employment at a bank.'),
    ('就職', '就職の面接に行ってきました。', 'I went to a job interview.'),
    ('退職', '母の介護のため、退職を決めました。', 'I decided to resign to care for my mother.'),
    ('退職', '父は長年勤めた会社を退職しました。', 'My father retired from the company where he had worked for many years.'),
    ('退職', '退職後は田舎で暮らすつもりです。', 'I intend to live in the countryside after retirement.')
  ) AS examples(word, japanese_sentence, english_translation)
  JOIN public.vocabulary v ON v.word = examples.word
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.example_sentences existing
    WHERE existing.vocab_id = v.id
      AND existing.japanese_sentence = examples.japanese_sentence
  );
END $$;

SELECT
  v.word,
  v.reading,
  wt.type_name,
  vb.lesson_number AS chapter_number,
  COUNT(es.id) AS example_count
FROM public.vocabulary v
JOIN public.vocabulary_books vb ON vb.vocab_id = v.id
JOIN public.books b ON b.id = vb.book_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
LEFT JOIN public.example_sentences es ON es.vocab_id = v.id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 1
  AND v.word IN (
    '上司', '相手', '知り合い', '友人', '仲', '生年月日', '誕生', '年',
    '出身', '故郷', '成長', '成人', '合格', '進学', '退学', '就職', '退職'
  )
GROUP BY v.word, v.reading, wt.type_name, vb.lesson_number
ORDER BY v.word;