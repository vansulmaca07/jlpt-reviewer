-- ============================================================
-- 耳から覚える N3 - Words 141-160
-- Lesson L8 = words 141-160.
-- Also records verb groups for the L7/L8 conjugation drills.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
-- ============================================================

BEGIN;

ALTER TABLE public.vocabulary
  ADD COLUMN IF NOT EXISTS verb_group TEXT;

DO $$
DECLARE
  v_book_id INTEGER;
  v_n3_level_id INTEGER;
  v_verb_type_id INTEGER;
BEGIN
  SELECT id INTO v_book_id
  FROM public.books
  WHERE book_name = '耳から覚える'
  LIMIT 1;

  SELECT id INTO v_n3_level_id
  FROM public.jlpt_levels
  WHERE level = 'N3'
  LIMIT 1;

  SELECT id INTO v_verb_type_id
  FROM public.word_types
  WHERE LOWER(type_name) LIKE '%verb%'
     OR type_name LIKE '%動詞%'
  ORDER BY id
  LIMIT 1;

  IF v_book_id IS NULL THEN
    RAISE EXCEPTION '耳から覚える book not found. Run migrations 06-10 first.';
  END IF;
  IF v_n3_level_id IS NULL THEN
    RAISE EXCEPTION 'N3 not found in jlpt_levels.';
  END IF;
  IF v_verb_type_id IS NULL THEN
    RAISE EXCEPTION 'Verb not found in word_types.';
  END IF;

  -- Correct L7 groups, including 尋ねる = Group 2 (ichidan).
  UPDATE public.vocabulary AS v
  SET verb_group = groups.verb_group
  FROM (VALUES
    ('渇く', 'Group 1 (Godan)'), ('嗅ぐ', 'Group 1 (Godan)'),
    ('叩く', 'Group 1 (Godan)'), ('殴る', 'Group 1 (Godan)'),
    ('蹴る', 'Group 1 (Godan)'), ('抱く', 'Group 1 (Godan)'),
    ('倒れる', 'Group 2 (Ichidan)'), ('倒す', 'Group 1 (Godan)'),
    ('起きる', 'Group 2 (Ichidan)'), ('起こす', 'Group 1 (Godan)'),
    ('尋ねる', 'Group 2 (Ichidan)'), ('呼ぶ', 'Group 1 (Godan)'),
    ('叫ぶ', 'Group 1 (Godan)'), ('黙る', 'Group 1 (Godan)'),
    ('飼う', 'Group 1 (Godan)'), ('数える', 'Group 2 (Ichidan)'),
    ('乾く', 'Group 1 (Godan)'), ('乾かす', 'Group 1 (Godan)'),
    ('畳む', 'Group 1 (Godan)'), ('誘う', 'Group 1 (Godan)')
  ) AS groups(word, verb_group)
  WHERE v.word = groups.word;

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id, verb_group)
  SELECT data.word, data.reading, data.meaning, v_verb_type_id, v_n3_level_id, data.verb_group
  FROM (VALUES
    ('おごる', 'おごる', 'treat someone to something', 'Group 1 (Godan)'),
    ('預かる', 'あずかる', 'look after; keep in custody', 'Group 1 (Godan)'),
    ('預ける', 'あずける', 'deposit; leave in someone''s care', 'Group 2 (Ichidan)'),
    ('決まる', 'きまる', 'be decided; be settled', 'Group 1 (Godan)'),
    ('決める', 'きめる', 'decide; determine', 'Group 2 (Ichidan)'),
    ('写る', 'うつる', 'be photographed; appear in a photo', 'Group 1 (Godan)'),
    ('写す', 'うつす', 'take a photo; copy', 'Group 1 (Godan)'),
    ('思い出す', 'おもいだす', 'remember; recall', 'Group 1 (Godan)'),
    ('教わる', 'おそわる', 'learn; be taught', 'Group 1 (Godan)'),
    ('申し込む', 'もうしこむ', 'apply; sign up; propose marriage', 'Group 1 (Godan)'),
    ('断る', 'ことわる', 'decline; refuse; ask permission', 'Group 1 (Godan)'),
    ('見つかる', 'みつかる', 'be found; be caught doing something', 'Group 1 (Godan)'),
    ('見つける', 'みつける', 'find; discover', 'Group 2 (Ichidan)'),
    ('捕まる', 'つかまる', 'be arrested; be caught', 'Group 1 (Godan)'),
    ('捕まえる', 'つかまえる', 'arrest; catch', 'Group 2 (Ichidan)'),
    ('乗る', 'のる', 'ride', 'Group 1 (Godan)'),
    ('乗せる', 'のせる', 'give someone a ride; put on', 'Group 2 (Ichidan)'),
    ('降りる', 'おりる', 'get off; go down; receive approval', 'Group 2 (Ichidan)'),
    ('降ろす', 'おろす', 'drop someone off; lower; withdraw', 'Group 1 (Godan)'),
    ('直る', 'なおる', 'be fixed; improve', 'Group 1 (Godan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 8
  FROM public.vocabulary v
  WHERE v.word IN (
    'おごる', '預かる', '預ける', '決まる', '決める', '写る', '写す', '思い出す', '教わる', '申し込む',
    '断る', '見つかる', '見つける', '捕まる', '捕まえる', '乗る', '乗せる', '降りる', '降ろす', '直る'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('おごる', '昨日は後輩に焼き肉をおごった。', 'Yesterday I treated my junior to yakiniku.'),
    ('預かる', '旅行に行く友達から犬を預かることになった。', 'I will look after my friend''s dog while they travel.'),
    ('預ける', '銀行にお金を預けると、利子がつく。', 'If you deposit money in a bank, it earns interest.'),
    ('決まる', 'みんなで話し合って、旅行の行き先は北海道に決まった。', 'After discussing it, the destination was decided to be Hokkaido.'),
    ('決める', '進学か就職か、早く決めたほうがいいです。', 'You should decide soon whether to continue school or get a job.'),
    ('写る', 'このカメラは暗いところでもよく写る。', 'This camera takes good pictures even in dark places.'),
    ('写す', '写真を写す。', 'Take a photo.'),
    ('思い出す', '毎年春になると、高校の入学式を思い出します。', 'Every spring, I remember my high school entrance ceremony.'),
    ('教わる', 'この料理の作り方は母から教わりました。', 'I learned how to make this dish from my mother.'),
    ('申し込む', 'パーティーに参加を申し込む。', 'Apply to participate in the party.'),
    ('断る', '頼まれた仕事を断った。', 'I declined the work I was asked to do.'),
    ('見つかる', 'なくなったと思っていた指輪が、ソファーの下で見つかった。', 'The ring I thought was lost was found under the sofa.'),
    ('見つける', 'なくなったと思っていた指輪を、ソファーの下で見つけた。', 'I found the ring I thought was lost under the sofa.'),
    ('捕まる', '犯人が警察に捕まった。', 'The criminal was arrested by the police.'),
    ('捕まえる', '警察が泥棒を捕まえた。', 'The police caught the thief.'),
    ('乗る', '毎朝、電車に乗って学校に通っている。', 'Every morning, I take the train to school.'),
    ('乗せる', '子どもを車に乗せて、学校まで送って行った。', 'I put my child in the car and drove them to school.'),
    ('降りる', '電車を降りる。', 'Get off the train.'),
    ('降ろす', 'タクシーの客を駅の前で降ろしてください。', 'Please drop the taxi passenger off in front of the station.'),
    ('直る', 'こわれたパソコンが直った。', 'The broken computer was fixed.')
  ) AS examples(word, japanese_sentence, english_translation)
  JOIN public.vocabulary v ON v.word = examples.word
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.example_sentences existing
    WHERE existing.vocab_id = v.id
      AND existing.japanese_sentence = examples.japanese_sentence
  );
END $$;

COMMIT;

-- Verification: L7/L8 counts and expected verb groups.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NOT NULL) AS grouped_word_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (WHERE v.verb_group IS NOT NULL) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number IN (7, 8)
GROUP BY b.book_name, vb.lesson_number
ORDER BY vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  '尋ねる', 'おごる', '預かる', '預ける', '決まる', '決める', '写る', '写す', '思い出す', '教わる',
  '申し込む', '断る', '見つかる', '見つける', '捕まる', '捕まえる', '乗る', '乗せる', '降りる', '降ろす', '直る'
)
ORDER BY word;