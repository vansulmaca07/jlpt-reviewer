import { fsrs, createEmptyCard, State } from 'ts-fsrs'
import { supabase } from '../supabaseClient'
import { newCardLimit, reviewWorkload, studyDayStart } from './srsMetrics'

export const DEFAULT_SRS_SETTINGS = {
  newPerDay: 40,
  retention: 0.9,
  bookId: null,
  lessonFrom: null,
  lessonTo: null,
  examDate: '2026-12-06',
  bookTotals: {},
}

export const THROTTLE = {
  maxDueReviews: 250,
  minRetention: 0.75,
  minLogsForRetention: 30,
  throttledNewPerDay: 15,
}

export const LEECH_LAPSES = 6
const PAGE_SIZE = 1000
const IN_CHUNK = 100

const VOCAB_SELECT = `*, word_types(type_name), jlpt_levels(level), vocabulary_books(book_id, lesson_number, books(id, book_name)), example_sentences(*)`

export function createScheduler(retention = DEFAULT_SRS_SETTINGS.retention) {
  return fsrs({ request_retention: retention, enable_fuzz: true, maximum_interval: 365 })
}

export function dayStart(now = new Date()) {
  return studyDayStart(now)
}

export function nextDayStart(now = new Date()) {
  const d = dayStart(now)
  d.setDate(d.getDate() + 1)
  return d
}

export function isLeech(item) {
  return (item.card?.lapses ?? 0) >= LEECH_LAPSES
}

export function formatInterval(due, now = new Date()) {
  const mins = Math.max(1, Math.round((due - now) / 60000))
  if (mins < 60) return `${mins}m`
  const hours = mins / 60
  if (hours < 24) return `${Math.round(hours)}h`
  const days = hours / 24
  if (days < 30) return `${Math.round(days)}d`
  if (days < 365) return `${(days / 30).toFixed(1).replace('.0', '')}mo`
  return `${(days / 365).toFixed(1).replace('.0', '')}y`
}

// Supabase caps responses at 1000 rows, so page through.
async function fetchAll(buildQuery) {
  let rows = []
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data, error } = await buildQuery().range(from, from + PAGE_SIZE - 1)
    if (error) throw error
    rows = rows.concat(data || [])
    if (!data || data.length < PAGE_SIZE) return rows
  }
}

function shuffle(arr) {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

function rowToCard(row) {
  return {
    due: new Date(row.due),
    stability: row.stability,
    difficulty: row.difficulty,
    elapsed_days: row.elapsed_days,
    scheduled_days: row.scheduled_days,
    learning_steps: row.learning_steps,
    reps: row.reps,
    lapses: row.lapses,
    state: row.state,
    last_review: row.last_review ? new Date(row.last_review) : undefined,
  }
}

function cardToRow(card) {
  return {
    due: card.due.toISOString(),
    stability: card.stability,
    difficulty: card.difficulty,
    elapsed_days: card.elapsed_days,
    scheduled_days: card.scheduled_days,
    learning_steps: card.learning_steps,
    reps: card.reps,
    lapses: card.lapses,
    state: card.state,
    last_review: card.last_review ? card.last_review.toISOString() : null,
  }
}

// ============================================================
// SETTINGS
// ============================================================

export async function loadSrsSettings(userId) {
  const { data, error } = await supabase.from('profiles').select('srs_settings').eq('id', userId).maybeSingle()
  if (error) throw error
  return { ...DEFAULT_SRS_SETTINGS, ...(data?.srs_settings || {}) }
}

export async function saveSrsSettings(userId, settings) {
  const { error } = await supabase.from('profiles').upsert({ id: userId, srs_settings: settings })
  if (error) console.error('saveSrsSettings error:', error)
  return !error
}

// ============================================================
// QUEUE BUILDING
// ============================================================

async function getNewCandidateIds(userId, settings) {
  if (!settings.bookId) return []
  const [links, existing] = await Promise.all([
    fetchAll(() => {
      let q = supabase.from('vocabulary_books').select('id, vocab_id, lesson_number').eq('book_id', settings.bookId)
      if (settings.lessonFrom !== null) q = q.gte('lesson_number', settings.lessonFrom)
      if (settings.lessonTo !== null) q = q.lte('lesson_number', settings.lessonTo)
      return q.order('lesson_number', { ascending: true, nullsFirst: false }).order('id')
    }),
    fetchAll(() => supabase.from('srs_cards').select('vocab_id').eq('user_id', userId).order('id')),
  ])
  const seen = new Set(existing.map(r => r.vocab_id))
  const byLesson = new Map()
  for (const link of links) {
    if (seen.has(link.vocab_id)) continue
    seen.add(link.vocab_id)
    const key = link.lesson_number ?? Number.MAX_SAFE_INTEGER
    if (!byLesson.has(key)) byLesson.set(key, [])
    byLesson.get(key).push(link.vocab_id)
  }
  // Lesson order preserved; shuffled within a lesson so position doesn't become a cue.
  return [...byLesson.keys()].sort((a, b) => a - b).flatMap(k => shuffle(byLesson.get(k)))
}

export async function getSrsSummary(userId, settings) {
  const now = new Date()
  const cutoff = nextDayStart(now).toISOString()
  const today = dayStart(now).toISOString()
  const weekAgo = new Date(now.getTime() - 7 * 86400000).toISOString()

  const base = () => supabase.from('srs_cards').select('id', { count: 'exact', head: true }).eq('user_id', userId)
  const logs = () => supabase.from('srs_review_logs').select('id', { count: 'exact', head: true })
    .eq('user_id', userId).eq('state', State.Review).gte('review', weekAgo)

  const [dueRes, learnRes, newTodayRes, activeRes, knownRes, logTotalRes, logAgainRes, newIds, scheduledCards] = await Promise.all([
    base().eq('suspended', false).eq('state', State.Review).lt('due', cutoff),
    base().eq('suspended', false).in('state', [State.Learning, State.Relearning]).lt('due', cutoff),
    base().gte('created_at', today).in('first_rating', [1, 2, 3]),
    base().eq('suspended', false),
    base().eq('suspended', true),
    logs(),
    logs().eq('rating', 1),
    getNewCandidateIds(userId, settings),
    fetchAll(() => supabase.from('srs_cards').select('id, due, state, suspended')
      .eq('user_id', userId).eq('suspended', false).order('id')),
  ])

  for (const result of [dueRes, learnRes, newTodayRes, activeRes, knownRes, logTotalRes, logAgainRes]) {
    if (result.error) throw result.error
  }
  const workload = reviewWorkload(scheduledCards, now)
  const dueReviews = dueRes.count || 0
  const logTotal = logTotalRes.count || 0
  const retention = logTotal >= THROTTLE.minLogsForRetention ? 1 - (logAgainRes.count || 0) / logTotal : null

  const { throttleReason, effectiveNewPerDay } = newCardLimit({
    dueReviews, reviewDebt: workload.reviewDebt, retention, newPerDay: settings.newPerDay,
  }, THROTTLE)
  const newToday = newTodayRes.count || 0

  return {
    ...workload,
    dueReviews,
    dueLearning: learnRes.count || 0,
    newToday,
    newRemaining: Math.max(0, effectiveNewPerDay - newToday),
    effectiveNewPerDay,
    throttleReason,
    retention,
    activeCards: activeRes.count || 0,
    knownCards: knownRes.count || 0,
    newAvailable: newIds.length,
    newCandidateIds: newIds,
  }
}

export async function getSrsStatsData(userId) {
  const weekAgo = new Date(Date.now() - 7 * 86400000).toISOString()
  const [cards, vocabulary, logs, books, settings] = await Promise.all([
    fetchAll(() => supabase.from('srs_cards').select('*').eq('user_id', userId).order('id')),
    fetchAll(() => supabase.from('vocabulary').select('id, word, reading, meaning, vocabulary_books(book_id, lesson_number)').order('id')),
    fetchAll(() => supabase.from('srs_review_logs').select('id, vocab_id, rating, state, review')
      .eq('user_id', userId).eq('state', State.Review).gte('review', weekAgo).order('id')),
    fetchAll(() => supabase.from('books').select('id, book_name').order('id')),
    loadSrsSettings(userId),
  ])
  return { cards, vocabulary, logs, books, settings, loadedAt: new Date() }
}

export async function getSrsWordDetails(userId, vocabId) {
  const [vocabulary, logs] = await Promise.all([
    fetchVocabByIds([vocabId]),
    fetchAll(() => supabase.from('srs_review_logs').select('id, rating, state, review, scheduled_days, duration_ms')
      .eq('user_id', userId).eq('vocab_id', vocabId).order('review', { ascending: false }).order('id')),
  ])
  const vocab = vocabulary.get(vocabId)
  if (!vocab) throw new Error('This word is no longer available. Refresh the collection.')
  return { vocab, logs }
}

async function fetchVocabByIds(ids) {
  const chunks = []
  for (let i = 0; i < ids.length; i += IN_CHUNK) chunks.push(ids.slice(i, i + IN_CHUNK))
  const results = await Promise.all(chunks.map(async chunk => {
    const { data, error } = await supabase.from('vocabulary').select(VOCAB_SELECT).in('id', chunk)
    if (error) throw error
    return data || []
  }))
  return new Map(results.flat().map(v => [v.id, v]))
}

export async function loadSrsSession(userId, settings) {
  const summary = await getSrsSummary(userId, settings)
  const now = new Date()
  const dueRows = await fetchAll(() => supabase.from('srs_cards').select('*')
    .eq('user_id', userId).eq('suspended', false).lt('due', nextDayStart(now).toISOString())
    .order('due').order('id'))

  // Known/Easy words do not use the quota, so scan all selected candidates.
  const newIds = summary.newRemaining > 0
    ? summary.newCandidateIds
    : []

  const vocabMap = await fetchVocabByIds([...dueRows.map(r => r.vocab_id), ...newIds])

  const dueItems = dueRows
    .filter(r => vocabMap.has(r.vocab_id))
    .map(r => ({ vocab: vocabMap.get(r.vocab_id), row: r, card: rowToCard(r) }))

  return {
    summary,
    learning: dueItems.filter(i => i.card.state === State.Learning || i.card.state === State.Relearning),
    reviews: dueItems.filter(i => i.card.state === State.Review),
    newItems: newIds.filter(id => vocabMap.has(id)).map(id => ({ vocab: vocabMap.get(id), row: null, card: createEmptyCard(now) })),
  }
}

// ============================================================
// GRADING
// ============================================================

export function gradeLocally(scheduler, item, rating, now = new Date()) {
  return scheduler.next(item.card, now, rating)
}

export async function persistGrade(userId, item, card, log, durationMs) {
  const payload = { user_id: userId, vocab_id: item.vocab.id, ...cardToRow(card), updated_at: new Date().toISOString() }
  if (!item.row) payload.first_rating = log.rating

  const { data, error } = await supabase.from('srs_cards')
    .upsert(payload, { onConflict: 'user_id,vocab_id' }).select().single()
  if (error) throw error

  const { error: logError } = await supabase.from('srs_review_logs').insert({
    user_id: userId,
    vocab_id: item.vocab.id,
    rating: log.rating,
    state: log.state,
    due: log.due.toISOString(),
    stability: log.stability,
    difficulty: log.difficulty,
    elapsed_days: log.elapsed_days,
    last_elapsed_days: log.last_elapsed_days,
    scheduled_days: log.scheduled_days,
    learning_steps: log.learning_steps,
    review: log.review.toISOString(),
    duration_ms: durationMs ?? null,
  })
  if (logError) throw logError
  return data
}

export async function suspendCard(userId, item) {
  const payload = { user_id: userId, vocab_id: item.vocab.id, suspended: true, updated_at: new Date().toISOString() }
  if (!item.row) Object.assign(payload, cardToRow(item.card))
  const { error } = await supabase.from('srs_cards').upsert(payload, { onConflict: 'user_id,vocab_id' })
  if (error) throw error
}
