const DAY_MS = 86400000

export function studyDayStart(now = new Date()) {
  const date = new Date(now)
  date.setHours(4, 0, 0, 0)
  if (now < date) date.setDate(date.getDate() - 1)
  return date
}

function addDays(date, days) {
  const result = new Date(date)
  result.setDate(result.getDate() + days)
  return result
}

function calendarNumber(date) {
  return Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()) / DAY_MS
}

export function studyDayRange(now = new Date(), offset = 0) {
  const start = addDays(studyDayStart(now), offset)
  return { start, end: addDays(start, 1) }
}

export function cardMatchesStatus(card, status, now = new Date(), dayOffset = 1, leechLapses = 6) {
  if (status === 'all') return true
  if (status === 'unseen') return !card
  if (status === 'introduced') return Boolean(card)
  if (status === 'known') return Boolean(card?.suspended)
  if (status === 'leeches') return (card?.lapses ?? 0) >= leechLapses
  if (!card || card.suspended || card.state === 0) return false
  if (status === 'learning') return card.state === 1 || card.state === 3
  if (status === 'review') return card.state === 2
  const due = new Date(card.due)
  if (status === 'due') return due < studyDayRange(now).end
  if (status === 'debt') return due < studyDayRange(now, 3).end
  if (status === 'scheduled') {
    const { start, end } = studyDayRange(now, dayOffset)
    return due >= start && due < end
  }
  throw new Error(`Unknown card filter: ${status}`)
}

export function srsStatusLabel(card) {
  if (!card) return 'Not introduced'
  if (card.suspended) return 'Known / suspended'
  return ['New', 'Learning', 'Review', 'Relearning'][card.state]
}

export function buildWordRows(vocabulary, cards) {
  const byId = new Map(cards.map(card => [card.vocab_id, card]))
  return vocabulary.map(vocab => ({ ...vocab, card: byId.get(vocab.id) ?? null }))
}

export function filterSrsWords(rows, {
  bookId = null, lesson = null, status = 'all', query = '', sort = 'due', dayOffset = 1,
} = {}, now = new Date(), leechLapses = 6) {
  const search = query.normalize('NFKC').trim().toLowerCase()
  const filtered = rows.filter(row => {
    const inScope = !bookId || row.vocabulary_books?.some(link =>
      link.book_id === bookId && (lesson === null || link.lesson_number === lesson))
    return inScope && cardMatchesStatus(row.card, status, now, dayOffset, leechLapses)
      && (!search || [row.word, row.reading, row.meaning].some(text =>
        text?.normalize('NFKC').toLowerCase().includes(search)))
  })
  const dueTime = row => row.card && !row.card.suspended && row.card.state !== 0
    ? new Date(row.card.due).getTime() : Infinity
  return filtered.sort((a, b) => {
    if (sort === 'lapses') {
      const difference = (b.card?.lapses ?? 0) - (a.card?.lapses ?? 0)
      if (difference) return difference
    } else if (sort === 'due') {
      const first = dueTime(a)
      const second = dueTime(b)
      if (first !== second) return first < second ? -1 : 1
    }
    return (a.word || '').localeCompare(b.word || '', 'ja') || a.id.localeCompare(b.id)
  })
}

export function reviewWorkload(cards, now = new Date()) {
  const forecast = Array.from({ length: 7 }, (_, index) => {
    return {
      date: studyDayRange(now, index + 1).start,
      count: cards.filter(card => cardMatchesStatus(card, 'scheduled', now, index + 1)).length,
    }
  })
  const dueToday = cards.filter(card => cardMatchesStatus(card, 'due', now)).length
  return {
    forecast,
    dueToday,
    reviewDebt: dueToday + forecast.slice(0, 3).reduce((sum, day) => sum + day.count, 0),
  }
}

export function newCardLimit({ dueReviews, reviewDebt, retention, newPerDay }, policy) {
  let throttleReason = null
  if (dueReviews > policy.maxDueReviews) throttleReason = `${dueReviews} reviews due (limit ${policy.maxDueReviews})`
  else if (reviewDebt > policy.maxDueReviews) throttleReason = `Review debt high: ${reviewDebt} cards (limit ${policy.maxDueReviews})`
  else if (retention !== null && retention < policy.minRetention) {
    throttleReason = `7-day retention ${Math.round(retention * 100)}% (< ${policy.minRetention * 100}%)`
  }
  return {
    throttleReason,
    effectiveNewPerDay: throttleReason ? Math.min(newPerDay, policy.throttledNewPerDay) : newPerDay,
  }
}

export function calculateInsights({ cards, links, logs, totalWords, examDate, now = new Date(), minRetentionLogs = 30, leechLapses = 6 }) {
  const ids = new Set(links.map(link => link.vocab_id))
  const bookCards = cards.filter(card => ids.has(card.vocab_id))
  const today = studyDayStart(now)
  const tomorrow = addDays(today, 1)
  const weekStart = addDays(today, -6)
  const recentCards = bookCards.filter(card => new Date(card.created_at) >= weekStart
    && new Date(card.created_at) < tomorrow)
  const introduced = bookCards.length
  const loaded = ids.size
  const total = totalWords || loaded
  const remaining = Math.max(0, total - introduced)
  const pace = recentCards.length / 7
  const learningToday = bookCards.filter(card => [1, 2, 3].includes(card.first_rating)
    && new Date(card.created_at) >= today && new Date(card.created_at) < tomorrow).length
  const reviewLogs = logs.filter(log => ids.has(log.vocab_id) && log.state === 2
    && new Date(log.review) >= new Date(now.getTime() - 7 * DAY_MS) && new Date(log.review) <= now)
  const retention = reviewLogs.length >= minRetentionLogs
    ? reviewLogs.filter(log => log.rating !== 1).length / reviewLogs.length : null
  const eta = total === 0 ? null : remaining === 0 ? today : pace > 0 ? addDays(today, Math.ceil(remaining / pace)) : null
  const exam = /^\d{4}-\d{2}-\d{2}$/.test(examDate || '') ? new Date(`${examDate}T04:00:00`) : null
  const validExam = exam && Number.isFinite(exam.getTime())
    && exam.getFullYear() === Number(examDate.slice(0, 4))
    && exam.getMonth() + 1 === Number(examDate.slice(5, 7))
    && exam.getDate() === Number(examDate.slice(8, 10))
    && calendarNumber(exam) >= calendarNumber(today)
  const daysRemaining = validExam ? calendarNumber(exam) - calendarNumber(today) : null
  const examEnd = validExam ? addDays(exam, 1) : null
  return {
    introduced, loaded, total, remaining, pace, retention,
    retentionSamples: reviewLogs.length,
    coverage: total > 0 ? Math.min(1, introduced / total) : null,
    effectiveAcquisition: retention === null ? null : learningToday * retention,
    learningToday,
    eta,
    daysRemaining,
    examCoverage: validExam && total > 0 ? Math.min(1, (introduced + pace * daysRemaining) / total) : null,
    scheduledUntilExam: validExam ? cards.filter(card => !card.suspended && card.state !== 0
      && new Date(card.due) < examEnd).length : null,
    leeches: bookCards.filter(card => card.lapses >= leechLapses).sort((a, b) => b.lapses - a.lapses),
  }
}
