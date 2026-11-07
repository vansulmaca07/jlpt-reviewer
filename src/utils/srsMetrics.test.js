import { test } from 'node:test'
import assert from 'node:assert/strict'
import {
  buildWordRows, calculateInsights, filterSrsWords, newCardLimit,
  reviewWorkload, srsStatusLabel, studyDayStart,
} from './srsMetrics.js'

const now = new Date('2026-11-05T12:00:00')
const card = (vocab_id, overrides = {}) => ({
  vocab_id, state: 2, suspended: false, due: '2026-11-06T04:00:00',
  created_at: '2026-11-05T05:00:00', first_rating: 3, lapses: 0, ...overrides,
})
const insights = (overrides = {}) => calculateInsights({
  cards: [], links: [], logs: [], totalWords: 880, examDate: '2026-12-06', now, ...overrides,
})

test('study-day rollover is 4 AM local time', () => {
  assert.equal(studyDayStart(new Date('2026-11-05T03:59:59')).getDate(), 4)
  assert.equal(studyDayStart(new Date('2026-11-05T04:00:00')).getDate(), 5)
})

test('forecast counts each scheduled active card once and includes backlog in debt', () => {
  const result = reviewWorkload([
    card('overdue', { due: '2026-10-01T04:00:00' }),
    card('today', { due: '2026-11-06T03:59:59', state: 1 }),
    card('tomorrow'), card('day2', { due: '2026-11-07T04:00:00', state: 3 }),
    card('day3', { due: '2026-11-08T04:00:00' }),
    card('day4', { due: '2026-11-09T04:00:00' }),
    card('day7', { due: '2026-11-12T04:00:00' }),
    card('outside', { due: '2026-11-13T04:00:00' }),
    card('known', { suspended: true }), card('ungraded', { state: 0 }),
  ], now)
  assert.deepEqual(result.forecast.map(day => day.count), [1, 1, 1, 1, 0, 0, 1])
  assert.equal(result.dueToday, 2)
  assert.equal(result.reviewDebt, 5)
})

test('coverage includes Easy and Known, but acquisition excludes them and scopes retention to book', () => {
  const cards = [
    card('learning'), card('easy', { first_rating: 4 }),
    card('known', { first_rating: null, state: 0, suspended: true }),
    card('other'), card('old', { created_at: '2026-10-01T04:00:00' }),
  ]
  const logs = Array.from({ length: 30 }, (_, i) => ({
    vocab_id: 'learning', state: 2, rating: i < 6 ? 1 : 3, review: now.toISOString(),
  }))
  logs.push({ vocab_id: 'other', state: 2, rating: 1, review: now.toISOString() })
  logs.push({ vocab_id: 'learning', state: 1, rating: 1, review: now.toISOString() })
  const result = insights({
    cards, links: ['learning', 'easy', 'known', 'old'].map(vocab_id => ({ vocab_id })),
    logs, totalWords: 10,
  })
  assert.equal(result.introduced, 4)
  assert.equal(result.coverage, 0.4)
  assert.equal(result.retention, 0.8)
  assert.equal(result.retentionSamples, 30)
  assert.equal(result.learningToday, 1)
  assert.equal(result.effectiveAcquisition, 0.8)
  assert.equal(result.pace, 3 / 7)
  assert.equal(result.eta.getDate(), 19)
  assert.equal(result.daysRemaining, 31)
  assert.equal(result.examCoverage, 1)
})

test('empty data produces unknown retention and ETA, not fake successes', () => {
  const result = insights()
  assert.equal(result.coverage, 0)
  assert.equal(result.retention, null)
  assert.equal(result.effectiveAcquisition, null)
  assert.equal(result.eta, null)
  assert.equal(result.examCoverage, 0)
})

test('uploaded-only coverage deduplicates links and completed book has immediate ETA', () => {
  const result = insights({
    cards: [card('one')], links: [{ vocab_id: 'one' }, { vocab_id: 'one' }], totalWords: null,
  })
  assert.equal(result.total, 1)
  assert.equal(result.coverage, 1)
  assert.equal(result.remaining, 0)
  assert.equal(result.eta.getTime(), studyDayStart(now).getTime())
  assert.equal(insights({ totalWords: null }).coverage, null)
  assert.equal(insights({ totalWords: null }).eta, null)
})

test('exam projection rejects missing, impossible and past dates', () => {
  for (const examDate of ['', 'bad', '2026-02-31', '2026-11-04']) {
    const result = insights({ examDate })
    assert.equal(result.daysRemaining, null)
    assert.equal(result.examCoverage, null)
    assert.equal(result.scheduledUntilExam, null)
  }
  assert.equal(insights({ examDate: '2026-11-05' }).daysRemaining, 0)
})

test('leeches use lapse threshold, and scheduled exam count excludes suspended and post-exam cards', () => {
  const result = insights({
    cards: [
      card('five', { lapses: 5 }), card('six', { lapses: 6 }),
      card('nine', { lapses: 9, suspended: true }),
      card('last', { due: '2026-12-07T03:59:59' }),
      card('after', { due: '2026-12-07T04:00:00' }),
    ],
    links: ['five', 'six', 'nine'].map(vocab_id => ({ vocab_id })),
  })
  assert.deepEqual(result.leeches.map(item => item.vocab_id), ['nine', 'six'])
  assert.equal(result.scheduledUntilExam, 3)
})

test('pace uses seven study days, including zero days, with exact boundaries', () => {
  const result = insights({
    cards: [
      card('before', { created_at: '2026-10-30T03:59:59' }),
      card('start', { created_at: '2026-10-30T04:00:00' }),
      card('end', { created_at: '2026-11-06T03:59:59' }),
      card('after', { created_at: '2026-11-06T04:00:00' }),
    ],
    links: ['before', 'start', 'end', 'after'].map(vocab_id => ({ vocab_id })),
  })
  assert.equal(result.pace, 2 / 7)
})

test('effective acquisition matches 40 new learning cards x 77% retention = 30.8', () => {
  const cards = Array.from({ length: 40 }, (_, i) => card(`v${i}`))
  const result = insights({
    cards,
    links: cards.map(item => ({ vocab_id: item.vocab_id })),
    logs: Array.from({ length: 100 }, (_, i) => ({
      vocab_id: 'v0', state: 2, rating: i < 23 ? 1 : 3, review: now.toISOString(),
    })),
  })
  assert.equal(result.effectiveAcquisition, 30.8)
})

test('debt throttle uses exact threshold, never increases a lower quota, and preserves old triggers', () => {
  const policy = { maxDueReviews: 250, minRetention: 0.75, throttledNewPerDay: 15 }
  const limit = overrides => newCardLimit({
    dueReviews: 0, reviewDebt: 250, retention: null, newPerDay: 40, ...overrides,
  }, policy)
  assert.equal(limit({}).effectiveNewPerDay, 40)
  assert.equal(limit({ reviewDebt: 251 }).effectiveNewPerDay, 15)
  assert.match(limit({ reviewDebt: 251 }).throttleReason, /Review debt high/)
  assert.equal(limit({ reviewDebt: 251, newPerDay: 10 }).effectiveNewPerDay, 10)
  assert.equal(limit({ reviewDebt: 251, newPerDay: 0 }).effectiveNewPerDay, 0)
  assert.equal(limit({ retention: 0.77 }).effectiveNewPerDay, 40)
  assert.equal(limit({ retention: 0.75 }).effectiveNewPerDay, 40)
  assert.equal(limit({ retention: 0.749 }).effectiveNewPerDay, 15)
  assert.match(limit({ retention: 0.74 }).throttleReason, /< 75%/)
  assert.match(limit({ dueReviews: 251 }).throttleReason, /reviews due/)
})

const vocabulary = (id, links = [{ book_id: 1, lesson_number: 1 }], overrides = {}) => ({
  id, word: id, reading: '', meaning: '', vocabulary_books: links, ...overrides,
})

test('every overview count drills down to exactly its scheduled cards, for any book', () => {
  const cards = [
    card('overdue', { due: '2026-10-01T04:00:00' }),
    card('today', { due: '2026-11-06T03:59:59', state: 1 }),
    card('tomorrow'), card('two', { due: '2026-11-07T04:00:00', state: 3 }),
    card('three', { due: '2026-11-08T04:00:00' }),
    card('four', { due: '2026-11-09T04:00:00' }),
    card('seven', { due: '2026-11-12T04:00:00' }),
    card('after', { due: '2026-11-13T04:00:00' }),
    card('known', { suspended: true }),
    card('other'), card('shared', { lapses: 6 }),
  ]
  const rows = buildWordRows([
    ...cards.filter(item => !['other', 'shared'].includes(item.vocab_id)).map(item => vocabulary(item.vocab_id)),
    vocabulary('other', [{ book_id: 2, lesson_number: 1 }]),
    vocabulary('shared', [{ book_id: 1, lesson_number: 1 }, { book_id: 2, lesson_number: 2 }]),
    vocabulary('unseen'),
  ], cards)
  for (const bookId of [null, 1, 2]) {
    const scoped = filterSrsWords(rows, { bookId }, now)
    const scopedCards = scoped.flatMap(row => row.card ? [row.card] : [])
    const workload = reviewWorkload(scopedCards, now)
    assert.equal(filterSrsWords(rows, { bookId, status: 'due' }, now).length, workload.dueToday)
    assert.equal(filterSrsWords(rows, { bookId, status: 'debt' }, now).length, workload.reviewDebt)
    workload.forecast.forEach((day, index) => {
      assert.equal(filterSrsWords(rows, { bookId, status: 'scheduled', dayOffset: index + 1 }, now).length, day.count)
    })
    const data = insights({ cards, links: scoped.map(row => ({ vocab_id: row.id })) })
    assert.equal(filterSrsWords(rows, { bookId, status: 'introduced' }, now).length, data.introduced)
    assert.equal(filterSrsWords(rows, { bookId, status: 'unseen' }, now).length, data.loaded - data.introduced)
    assert.equal(filterSrsWords(rows, { bookId, status: 'leeches' }, now).length, data.leeches.length)
  }
})

test('book and lesson must match the same membership; missing target words never become fake rows', () => {
  const rows = buildWordRows([
    vocabulary('shared', [{ book_id: 1, lesson_number: 1 }, { book_id: 2, lesson_number: 2 }]),
    vocabulary('unseen'),
  ], [card('shared')])
  assert.equal(filterSrsWords(rows, { bookId: 1, lesson: 2 }, now).length, 0)
  assert.equal(filterSrsWords(rows, { bookId: 2, lesson: 2 }, now).length, 1)
  assert.equal(filterSrsWords(rows, { status: 'unseen' }, now).length, 1)
  assert.equal(insights({ cards: [card('shared')], links: rows.map(row => ({ vocab_id: row.id })) }).remaining, 879)
})

test('search supports word, reading and case/width-normalized meaning', () => {
  const rows = buildWordRows([
    vocabulary('one', undefined, { word: '傾向', reading: 'けいこう', meaning: 'Tendency' }),
    vocabulary('two', undefined, { word: 'カード', meaning: 'Card' }),
  ], [])
  for (const query of ['傾向', 'けいこう', 'ＴＥＮＤＥＮＣＹ', ' tendency ']) {
    assert.deepEqual(filterSrsWords(rows, { query }, now).map(row => row.id), ['one'])
  }
})

test('word states and sorts distinguish learning, review, known and lapses without mutating schedules', () => {
  const cards = [
    card('review', { lapses: 6 }),
    card('learning', { state: 1, due: '2026-11-05T05:00:00' }),
    card('relearning', { state: 3 }),
    card('known', { state: 0, suspended: true, lapses: 9 }),
  ]
  const before = JSON.stringify(cards)
  const rows = buildWordRows([...cards.map(item => vocabulary(item.vocab_id)), vocabulary('unseen')], cards)
  assert.equal(filterSrsWords(rows, { status: 'learning' }, now).length, 2)
  assert.equal(filterSrsWords(rows, { status: 'review' }, now).length, 1)
  assert.equal(filterSrsWords(rows, { status: 'known' }, now).length, 1)
  assert.equal(filterSrsWords(rows, { sort: 'due' }, now)[0].id, 'learning')
  assert.equal(filterSrsWords(rows, { sort: 'lapses' }, now)[0].id, 'known')
  assert.equal(srsStatusLabel(null), 'Not introduced')
  assert.equal(srsStatusLabel(cards[3]), 'Known / suspended')
  assert.equal(srsStatusLabel(cards[2]), 'Relearning')
  assert.equal(JSON.stringify(cards), before)
})

test('counts and drill-downs agree immediately before and after the 4 AM boundary', () => {
  const cards = [card('boundary', { due: '2026-11-06T04:00:00' })]
  const rows = buildWordRows([vocabulary('boundary')], cards)
  const before = new Date('2026-11-06T03:59:59')
  const after = new Date('2026-11-06T04:00:00')
  assert.equal(reviewWorkload(cards, before).forecast[0].count, 1)
  assert.equal(filterSrsWords(rows, { status: 'scheduled', dayOffset: 1 }, before).length, 1)
  assert.equal(reviewWorkload(cards, after).dueToday, 1)
  assert.equal(filterSrsWords(rows, { status: 'due' }, after).length, 1)
  assert.equal(filterSrsWords(rows, { status: 'scheduled', dayOffset: 1 }, after).length, 0)
})
