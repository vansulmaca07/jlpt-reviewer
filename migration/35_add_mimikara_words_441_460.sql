-- ============================================================
-- 耳から覚える N3 - Words 441-460
-- Lesson L23 = words 441-460.
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

  INSERT INTO public.vocabulary (word, reading, meaning, word_type_id, jlpt_level_id, verb_group)
  SELECT data.word, data.reading, data.meaning, v_verb_type_id, v_n3_level_id, data.verb_group
  FROM (VALUES
    ('譲る', 'ゆずる', 'give up; yield; hand over', 'Group 1 (Godan)'),
    ('助かる', 'たすかる', 'survive; be helpful', 'Group 1 (Godan)'),
    ('助ける', 'たすける', 'save; help', 'Group 2 (Ichidan)'),
    ('いじめる', 'いじめる', 'bully', 'Group 2 (Ichidan)'),
    ('だます', 'だます', 'deceive; trick', 'Group 1 (Godan)'),
    ('盗む', 'ぬすむ', 'steal', 'Group 1 (Godan)'),
    ('刺さる', 'ささる', 'be stuck in', 'Group 1 (Godan)'),
    ('刺す', 'さす', 'stick; stab', 'Group 1 (Godan)'),
    ('殺す', 'ころす', 'kill', 'Group 1 (Godan)'),
    ('隠れる', 'かくれる', 'hide; be hidden', 'Group 2 (Ichidan)'),
    ('隠す', 'かくす', 'hide; conceal', 'Group 1 (Godan)'),
    ('埋まる', 'うまる', 'be buried; be filled', 'Group 1 (Godan)'),
    ('埋める', 'うめる', 'bury; fill; make up', 'Group 2 (Ichidan)'),
    ('囲む', 'かこむ', 'surround; circle', 'Group 1 (Godan)'),
    ('詰まる', 'つまる', 'be packed; be clogged', 'Group 1 (Godan)'),
    ('詰める', 'つめる', 'pack; fill; reduce; shorten', 'Group 2 (Ichidan)'),
    ('開く', 'ひらく', 'open; bloom; hold an event', 'Group 1 (Godan)'),
    ('閉じる', 'とじる', 'close', 'Group 2 (Ichidan)'),
    ('飛ぶ', 'とぶ', 'fly; splash; rush', 'Group 1 (Godan)'),
    ('飛ばす', 'とばす', 'fly; let fly; blow away; skip', 'Group 1 (Godan)')
  ) AS data(word, reading, meaning, verb_group)
  ON CONFLICT (word) DO UPDATE
    SET reading = EXCLUDED.reading,
        meaning = EXCLUDED.meaning,
        verb_group = EXCLUDED.verb_group;

  INSERT INTO public.vocabulary_books (vocab_id, book_id, lesson_number)
  SELECT v.id, v_book_id, 23
  FROM public.vocabulary v
  WHERE v.word IN (
    '譲る', '助かる', '助ける', 'いじめる', 'だます', '盗む', '刺さる', '刺す', '殺す', '隠れる',
    '隠す', '埋まる', '埋める', '囲む', '詰まる', '詰める', '開く', '閉じる', '飛ぶ', '飛ばす'
  )
  ON CONFLICT (vocab_id, book_id) DO UPDATE
    SET lesson_number = EXCLUDED.lesson_number;

  INSERT INTO public.example_sentences (vocab_id, japanese_sentence, english_translation)
  SELECT v.id, examples.japanese_sentence, examples.english_translation
  FROM (VALUES
    ('譲る', '電車の中で、お年寄りに席を譲った。', 'I gave up my seat to an elderly person on the train.'),
    ('助かる', '飛行機が落ちたが、3人が助かった。', 'The plane crashed, but three people survived.'),
    ('助ける', '川に落ちた子どもを助けた。', 'I saved a child who fell into the river.'),
    ('いじめる', '弟や妹をいじめる。', 'Bully my younger brother or sister.'),
    ('だます', '彼は「独身だ」とだまして5人の女性とつきあっていた。', 'He deceived five women by telling them he was single.'),
    ('盗む', '留守中にどろぼうに入られて、お金を盗まれてしまった。', 'While I was away, a burglar broke in and stole my money.'),
    ('刺さる', '指にとげが刺さって痛い。', 'A thorn is stuck in my finger and it hurts.'),
    ('刺す', '指にとげを刺してしまった。', 'I accidentally stuck a thorn into my finger.'),
    ('殺す', '戦争で、多くの人が殺された。', 'Many people were killed in the war.'),
    ('隠れる', '逃げた犯人は空き家に隠れていた。', 'The escaped criminal was hiding in an empty house.'),
    ('隠す', 'お金を引き出しの奥に隠した。', 'I hid the money in the back of the drawer.'),
    ('埋まる', '山がくずれて家が埋まってしまった。', 'The mountain collapsed and the house was buried.'),
    ('埋める', '穴を掘ってごみを埋めた。', 'I dug a hole and buried the garbage.'),
    ('囲む', 'テーブルを囲んで座る。', 'Sit around the table.'),
    ('詰まる', 'かばんにたくさん荷物がつまって重い。', 'The bag is packed with luggage and is heavy.'),
    ('詰める', 'かばんに荷物をつめる。', 'Pack luggage into a bag.'),
    ('開く', 'ドアが開く。', 'The door opens.'),
    ('閉じる', 'エレベーターのドアが閉じた。', 'The elevator doors closed.'),
    ('飛ぶ', '鳥が空を飛んでいる。', 'A bird is flying in the sky.'),
    ('飛ばす', '紙飛行機を飛ばす。', 'Fly a paper airplane.')
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

-- Verification: L23 must contain exactly 20 verbs, all with a verb group.
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
  AND vb.lesson_number = 23
GROUP BY b.book_name, vb.lesson_number;

SELECT word, reading, verb_group
FROM public.vocabulary
WHERE word IN (
  '譲る', '助かる', '助ける', 'いじめる', 'だます', '盗む', '刺さる', '刺す', '殺す', '隠れる',
  '隠す', '埋まる', '埋める', '囲む', '詰まる', '詰める', '開く', '閉じる', '飛ぶ', '飛ばす'
)
ORDER BY word;
