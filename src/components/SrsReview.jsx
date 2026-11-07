import { useEffect, useMemo, useRef, useState } from 'react'
import { Rating, State } from 'ts-fsrs'
import {
  Box, Card, CardContent, Typography, Button, Chip, CircularProgress,
  IconButton, Alert, useMediaQuery, useTheme
} from '@mui/material'
import ArrowBackIcon from '@mui/icons-material/ArrowBack'
import VolumeUpIcon from '@mui/icons-material/VolumeUp'
import DoNotDisturbOnOutlinedIcon from '@mui/icons-material/DoNotDisturbOnOutlined'
import {
  createScheduler, loadSrsSession, persistGrade, suspendCard,
  formatInterval, isLeech, nextDayStart
} from '../utils/srsService'
import { startSession, completeSession, logAttempt } from '../utils/statsService'

const GRADE_BUTTONS = [
  { rating: Rating.Again, label: 'Again', key: '1', color: 'error' },
  { rating: Rating.Hard, label: 'Hard', key: '2', color: 'warning' },
  { rating: Rating.Good, label: 'Good', key: '3', color: 'success' },
  { rating: Rating.Easy, label: 'Easy', key: '4', color: 'info' },
]

const STATE_CHIP = {
  [State.New]: { label: 'NEW', color: '#1976d2' },
  [State.Learning]: { label: 'LEARNING', color: '#d32f2f' },
  [State.Relearning]: { label: 'RELEARNING', color: '#d32f2f' },
  [State.Review]: { label: 'REVIEW', color: '#2e7d32' },
}

function speak(text) {
  window.speechSynthesis.cancel()
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = 'ja-JP'
  window.speechSynthesis.speak(utterance)
}

// Learning cards due now first, then reviews, then new (within quota), then learn-ahead.
function takeNext(q) {
  const now = Date.now()
  if (q.learning.length && q.learning[0].card.due.getTime() <= now) {
    return { item: q.learning[0], q: { ...q, learning: q.learning.slice(1) } }
  }
  if (q.reviews.length) return { item: q.reviews[0], q: { ...q, reviews: q.reviews.slice(1) } }
  if (q.news.length && q.newIntroduced < q.newQuota) return { item: q.news[0], q: { ...q, news: q.news.slice(1) } }
  if (q.learning.length) return { item: q.learning[0], q: { ...q, learning: q.learning.slice(1) } }
  return { item: null, q }
}

function insertByDue(list, item) {
  const idx = list.findIndex(i => i.card.due > item.card.due)
  return idx === -1 ? [...list, item] : [...list.slice(0, idx), item, ...list.slice(idx)]
}

function SrsReview({ userId, settings, onBack }) {
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const isDark = theme.palette.mode === 'dark'

  const scheduler = useMemo(() => createScheduler(settings.retention), [settings.retention])
  const [loading, setLoading] = useState(true)
  const [loadError, setLoadError] = useState('')
  const [saveError, setSaveError] = useState('')
  const [queues, setQueues] = useState(null)
  const [current, setCurrent] = useState(null)
  const [flipped, setFlipped] = useState(false)
  const [done, setDone] = useState(false)
  const [tally, setTally] = useState({ [Rating.Again]: 0, [Rating.Hard]: 0, [Rating.Good]: 0, [Rating.Easy]: 0, known: 0 })
  const [sessionId, setSessionId] = useState(null)

  const shownAt = useRef(0)
  const sessionStart = useRef(0)
  const saveChain = useRef(Promise.resolve())

  function advance(q) {
    const { item, q: next } = takeNext(q)
    setQueues(next)
    setCurrent(item)
    setFlipped(false)
    shownAt.current = Date.now()
    if (!item) setDone(true)
  }

  useEffect(() => {
    let cancelled = false
    loadSrsSession(userId, settings)
      .then(data => {
        if (cancelled) return
        sessionStart.current = Date.now()
        advance({
          learning: [...data.learning].sort((a, b) => a.card.due - b.card.due),
          reviews: data.reviews,
          news: data.newItems,
          newIntroduced: 0,
          newQuota: data.summary.newRemaining,
        })
        startSession(userId, 'srs').then(id => !cancelled && setSessionId(id))
      })
      .catch(err => {
        console.error('loadSrsSession error:', err)
        if (!cancelled) setLoadError('Could not load SRS data. Check your connection and run migration/28_srs_fsrs_tables.sql in Supabase if needed.')
      })
      .finally(() => !cancelled && setLoading(false))
    return () => { cancelled = true }
  }, [])

  const reviewedCount = tally[Rating.Again] + tally[Rating.Hard] + tally[Rating.Good] + tally[Rating.Easy]

  useEffect(() => {
    if (done && sessionId) {
      completeSession(sessionId, {
        total: reviewedCount,
        correct: reviewedCount - tally[Rating.Again],
        wrong: tally[Rating.Again],
        skipped: tally.known,
        durationSeconds: Math.round((Date.now() - sessionStart.current) / 1000),
      })
    }
  }, [done])

  function enqueueSave(task) {
    saveChain.current = saveChain.current.then(task).catch(err => {
      console.error('SRS save error:', err)
      setSaveError('Some review data could not be saved. Check your connection.')
    })
  }

  const preview = useMemo(() => {
    if (!current || !flipped) return null
    return scheduler.repeat(current.card, new Date())
  }, [current, flipped, scheduler])

  function handleGrade(rating) {
    if (!current || !flipped) return
    const now = new Date()
    const { card, log } = scheduler.next(current.card, now, rating)
    const durationMs = Date.now() - shownAt.current
    const isFirstSeen = !current.row
    const graded = { ...current, card, row: current.row || { pending: true } }

    enqueueSave(() => persistGrade(userId, current, card, log, durationMs))
    if (sessionId) logAttempt(userId, sessionId, current.vocab.id, 'srs', rating !== Rating.Again)

    setTally(t => ({ ...t, [rating]: t[rating] + 1 }))

    let q = { ...queues }
    if (isFirstSeen && rating !== Rating.Easy) q.newIntroduced += 1
    const stillLearning = card.state === State.Learning || card.state === State.Relearning
    if (stillLearning && card.due < nextDayStart(now)) q.learning = insertByDue(q.learning, graded)
    advance(q)
  }

  function handleKnown() {
    if (!current) return
    const item = current
    enqueueSave(() => suspendCard(userId, item))
    setTally(t => ({ ...t, known: t.known + 1 }))
    advance({ ...queues })
  }

  useEffect(() => {
    function onKeyDown(e) {
      if (e.target instanceof HTMLElement && (e.target.isContentEditable || ['INPUT', 'SELECT', 'TEXTAREA'].includes(e.target.tagName))) return
      if (loading || done || !current) return
      if (!flipped && [' ', 'Enter', 'ArrowRight'].includes(e.key)) { e.preventDefault(); setFlipped(true); return }
      const btn = flipped && GRADE_BUTTONS.find(b => b.key === e.key)
      if (btn) { e.preventDefault(); handleGrade(btn.rating) }
    }
    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [current, flipped, loading, done, queues, sessionId])

  if (loading) return <Box textAlign="center" mt={10}><CircularProgress /></Box>

  if (loadError) return (
    <Box sx={{ maxWidth: 500, mx: 'auto', mt: 4 }}>
      <Alert severity="error" sx={{ mb: 2 }}>{loadError}</Alert>
      <Button variant="outlined" startIcon={<ArrowBackIcon />} onClick={onBack}>Back</Button>
    </Box>
  )

  if (done) {
    const againPct = reviewedCount ? Math.round((tally[Rating.Again] / reviewedCount) * 100) : 0
    return (
      <Box sx={{ maxWidth: 500, mx: 'auto', textAlign: 'center', mt: isMobile ? 2 : 4 }}>
        <Typography variant="h4" mb={1}>🎉</Typography>
        <Typography variant={isMobile ? 'h6' : 'h5'} fontWeight="bold" mb={1}>
          {reviewedCount + tally.known === 0 ? 'No cards due today!' : "Today's review is complete!"}
        </Typography>
        <Typography color="text.secondary" mb={2} fontSize="13px">
          Come back tomorrow. FSRS schedules when each word will appear again.
        </Typography>
        {saveError && <Alert severity="warning" sx={{ mb: 2, textAlign: 'left' }}>{saveError}</Alert>}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="h3" fontWeight="bold" color="#1a3a5c">{reviewedCount}</Typography>
            <Typography color="text.secondary" fontSize="13px" mb={1.5}>ratings ({againPct}% Again)</Typography>
            <Box display="flex" justifyContent="center" gap={1} flexWrap="wrap">
              {GRADE_BUTTONS.map(b => (
                <Chip key={b.rating} label={`${b.label}: ${tally[b.rating]}`} color={b.color} variant="outlined" size="small" />
              ))}
              {tally.known > 0 && <Chip label={`Known: ${tally.known}`} variant="outlined" size="small" />}
            </Box>
          </CardContent>
        </Card>
        <Button variant="outlined" startIcon={<ArrowBackIcon />} onClick={onBack}>Back</Button>
      </Box>
    )
  }

  const newLeft = Math.min(queues.news.length, Math.max(0, queues.newQuota - queues.newIntroduced))
  const stateChip = STATE_CHIP[current.card.state]
  const vocab = current.vocab
  const bookEntry = vocab.vocabulary_books?.find(vb => vb.book_id === settings.bookId) || vocab.vocabulary_books?.[0]
  const example = vocab.example_sentences?.[0]

  return (
    <Box sx={{ maxWidth: 500, mx: 'auto' }}>
      <Box display="flex" alignItems="center" justifyContent="space-between" mb={1.5}>
        <Button size="small" startIcon={<ArrowBackIcon />} onClick={onBack}>Back</Button>
        <Box display="flex" gap={1.5} fontSize="14px" fontWeight={700}>
          <Typography component="span" fontWeight={700} color="#1976d2" title="New">{newLeft}</Typography>
          <Typography component="span" fontWeight={700} color="#d32f2f" title="Learning">{queues.learning.length + (current.card.state === State.Learning || current.card.state === State.Relearning ? 1 : 0)}</Typography>
          <Typography component="span" fontWeight={700} color="#2e7d32" title="Review">{queues.reviews.length + (current.card.state === State.Review ? 1 : 0)}</Typography>
        </Box>
      </Box>

      {saveError && <Alert severity="warning" sx={{ mb: 1.5 }} onClose={() => setSaveError('')}>{saveError}</Alert>}

      <Card onClick={() => !flipped && setFlipped(true)}
        sx={{
          mb: 1.5, cursor: flipped ? 'default' : 'pointer',
          minHeight: isMobile ? 200 : 240,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: 3, '&:hover': !flipped ? { boxShadow: 6 } : {}
        }}>
        <CardContent sx={{ textAlign: 'center', width: '100%', py: isMobile ? 2 : 3 }}>
          <Box display="flex" justifyContent="center" gap={0.75} mb={1}>
            <Chip label={stateChip.label} size="small" sx={{ height: 18, fontSize: '10px', fontWeight: 700, color: 'white', backgroundColor: stateChip.color }} />
            {isLeech(current) && <Chip label="LEECH" size="small" color="warning" sx={{ height: 18, fontSize: '10px', fontWeight: 700 }} />}
          </Box>
          <Typography variant={isMobile ? 'h4' : 'h3'} fontWeight="bold">{vocab.word}</Typography>

          {!flipped ? (
            <Typography variant="caption" color="text.disabled" mt={2} display="block">
              Reading + meaning? Tap / Space to reveal
            </Typography>
          ) : (
            <Box mt={0.5}>
              <Box display="flex" alignItems="center" justifyContent="center" gap={0.5}>
                {vocab.reading && <Typography variant="body1" color="primary">{vocab.reading}</Typography>}
                <IconButton size="small" onClick={e => { e.stopPropagation(); speak(vocab.reading || vocab.word) }} sx={{ color: '#1a3a5c' }}>
                  <VolumeUpIcon fontSize="small" />
                </IconButton>
              </Box>
              <Typography variant={isMobile ? 'h6' : 'h5'} fontWeight="bold" mb={1}>{vocab.meaning}</Typography>
              <Box display="flex" justifyContent="center" gap={1} flexWrap="wrap">
                {vocab.jlpt_levels?.level && <Chip label={vocab.jlpt_levels.level} size="small" color="primary" />}
                {vocab.word_types?.type_name && <Chip label={vocab.word_types.type_name} size="small" variant="outlined" />}
                {bookEntry?.lesson_number && <Chip label={`L${bookEntry.lesson_number}`} size="small" variant="outlined" />}
                {bookEntry?.books?.book_name && <Chip label={bookEntry.books.book_name} size="small" variant="outlined" sx={{ color: 'text.secondary' }} />}
              </Box>
              {example && (
                <Box sx={{ backgroundColor: isDark ? 'rgba(255,255,255,0.05)' : '#f8fafc', borderRadius: 1, p: 1.5, mt: 1.5, textAlign: 'left' }}>
                  <Box display="flex" alignItems="flex-start" justifyContent="space-between">
                    <Typography variant="body2" color="warning.dark" sx={{ flex: 1 }}>{example.japanese_sentence}</Typography>
                    <IconButton size="small" onClick={() => speak(example.japanese_sentence)} sx={{ color: '#b0bec5', ml: 0.5, mt: '-4px', flexShrink: 0 }}>
                      <VolumeUpIcon sx={{ fontSize: 16 }} />
                    </IconButton>
                  </Box>
                  <Typography variant="caption" color="text.secondary">{example.english_translation}</Typography>
                </Box>
              )}
            </Box>
          )}
        </CardContent>
      </Card>

      {flipped ? (
        <Box display="grid" gridTemplateColumns="repeat(4, 1fr)" gap={1}>
          {GRADE_BUTTONS.map(b => (
            <Button key={b.rating} variant={b.rating === Rating.Good ? 'contained' : 'outlined'} color={b.color}
              onClick={() => handleGrade(b.rating)}
              sx={{ flexDirection: 'column', py: isMobile ? 0.75 : 1, lineHeight: 1.2, minWidth: 0 }}>
              <Typography fontSize="10px" sx={{ opacity: 0.85 }}>{preview && formatInterval(preview[b.rating].card.due)}</Typography>
              <Typography fontSize={isMobile ? '13px' : '14px'} fontWeight={700}>{b.label}</Typography>
              {!isMobile && <Typography fontSize="9px" sx={{ opacity: 0.6 }}>{b.key}</Typography>}
            </Button>
          ))}
        </Box>
      ) : (
        <Button fullWidth variant="contained" onClick={() => setFlipped(true)}
          sx={{ backgroundColor: '#1a3a5c', py: isMobile ? 1.2 : 1.5 }}>
          Show Answer
        </Button>
      )}

      <Box textAlign="center" mt={1.5}>
        <Button size="small" startIcon={<DoNotDisturbOnOutlinedIcon sx={{ fontSize: 16 }} />} onClick={handleKnown}
          sx={{ color: 'text.secondary', textTransform: 'none', fontSize: '11px' }}>
          Known – don&apos;t show again
        </Button>
      </Box>
    </Box>
  )
}

export default SrsReview
