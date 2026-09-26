-- ============================================================
-- 耳から覚える N3 - Words 341-360
-- Lesson L18 = words 341-360.
-- Safe to re-run: existing vocabulary, links, and examples are reused.
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
    RAISE EXCEPTION '耳から覚える book not found. Run migrations 06-10 first.';
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
    ('注目', 'ちゅうもく', 'attention', 'noun'),
    ('通訳', 'つうやく', 'interpretation; interpreter', 'noun'),
    ('翻訳', 'ほんやく', 'translation', 'noun'),
    ('伝言', 'でんごん', 'message', 'noun'),
    ('報告', 'ほうこく', 'report', 'noun'),
    ('録画', 'ろくが', 'recording (video)', 'noun'),
    ('混雑', 'こんざつ', 'crowd; congestion', 'noun'),
    ('渋滞', 'じゅうたい', 'traffic jam; congestion', 'noun'),
    ('衝突', 'しょうとつ', 'collision; conflict', 'noun'),
    ('被害', 'ひがい', 'damage; harm', 'noun'),
    ('事故', 'じこ', 'accident', 'noun'),
    ('事件', 'じけん', 'incident; event', 'noun'),
    ('故障', 'こしょう', 'malfunction; breakdown', 'noun'),
    ('修理', 'しゅうり', 'repair', 'noun'),
    ('停電', 'ていでん', 'blackout; power outage', 'noun'),
    ('調子', 'ちょうし', 'condition; tone; state', 'noun'),
    ('緊張', 'きんちょう', 'tension; nervousness', 'noun'),
    ('自信', 'じしん', 'confidence', 'noun'),
    ('自慢', 'じまん', 'pride; boast', 'noun'),
    ('感心', 'かんしん', 'admiration; being impressed', 'noun')
  ) AS data(word, reading, meaning, word_type)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        word_type_id = EXCLUDED.word_type_id;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 18
  FROM public.vocabulary v
  WHERE v.word IN (
    '注目', '通訳', '翻訳', '伝言', '報告', '録画', '混雑', '渋滞', '衝突', '被害',
    '事故', '事件', '故障', '修理', '停電', '調子', '緊張', '自信', '自慢', '感心'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('注目', '有名歌手の結婚が注目を集めている。', 'The marriage of a famous singer is attracting attention.'),
    ('通訳', '英語を日本語に通訳する。', 'Interpret English into Japanese.'),
    ('翻訳', '日本語の小説を英語に翻訳する。', 'Translate a Japanese novel into English.'),
    ('伝言', '留守番電話に伝言を残す。', 'Leave a message on the answering machine.'),
    ('報告', '出張の報告をまとめる。', 'Compile a report on the business trip.'),
    ('録画', 'テレビ番組をビデオに録画する。', 'Record a television program on video.'),
    ('混雑', 'デパートは大勢の人で混雑している。', 'The department store is crowded with many people.'),
    ('渋滞', '道路が渋滞していて、会議に遅刻した。', 'The roads were congested, so I was late for the meeting.'),
    ('衝突', '電車の衝突の場面を見た。', 'I saw the scene of a train collision.'),
    ('被害', '台風の被害、地震で大きな被害が出る。', 'Typhoon damage; a major loss occurs due to an earthquake.'),
    ('事故', '事故の原因を調べる。', 'Investigate the cause of the accident.'),
    ('事件', '近所で子どもが次々といなくなるという事件があった。', 'There was an incident in the neighborhood in which children disappeared one after another.'),
    ('故障', '洗たく機が故障したので、コインランドリーへ行った。', 'The washing machine broke down, so I went to a laundromat.'),
    ('修理', 'パソコンがこわれたので、修理に出した。', 'My computer broke, so I sent it out for repair.'),
    ('停電', '雷が落ちて停電した。', 'Lightning struck and there was a power outage.'),
    ('調子', '体の調子がよくない。', 'I am not feeling well.'),
    ('緊張', '面接では緊張して、うまく答えられなかった。', 'I was nervous during the interview and could not answer well.'),
    ('自信', '体力に自信がある。', 'I am confident in my physical strength.'),
    ('自慢', '自慢の料理を作る。', 'Make my specialty dish.'),
    ('感心', 'チンさんの進歩の速さに感心した。', 'I was impressed by Mr. Chin''s rapid progress.')
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

-- Verification: L18 must contain exactly 20 noun entries.
SELECT
  b.book_name,
  vb.lesson_number,
  COUNT(DISTINCT vb.vocab_id) AS distinct_word_count,
  COUNT(DISTINCT vb.vocab_id) FILTER (
    WHERE LOWER(wt.type_name) LIKE '%noun%'
       OR wt.type_name LIKE '%名詞%'
  ) AS noun_count,
  CASE
    WHEN COUNT(DISTINCT vb.vocab_id) = 20
     AND COUNT(DISTINCT vb.vocab_id) FILTER (
       WHERE LOWER(wt.type_name) LIKE '%noun%'
          OR wt.type_name LIKE '%名詞%'
     ) = 20
    THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM public.vocabulary_books vb
JOIN public.books b ON b.id = vb.book_id
JOIN public.vocabulary v ON v.id = vb.vocab_id
LEFT JOIN public.word_types wt ON wt.id = v.word_type_id
WHERE b.book_name = '耳から覚える'
  AND vb.lesson_number = 18
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, meaning
FROM public.vocabulary
WHERE word IN (
  '注目', '通訳', '翻訳', '伝言', '報告', '録画', '混雑', '渋滞', '衝突', '被害',
  '事故', '事件', '故障', '修理', '停電', '調子', '緊張', '自信', '自慢', '感心'
)
ORDER BY word;
