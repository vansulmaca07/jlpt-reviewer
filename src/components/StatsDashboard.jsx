import { useEffect, useState } from 'react'
import {
  Accordion, AccordionDetails, AccordionSummary, Alert, Box, Button,
  CircularProgress, MenuItem, Tab, Tabs, TextField, Typography,
} from '@mui/material'
import ExpandMoreIcon from '@mui/icons-material/ExpandMore'
import {
  getSrsStatsData, LEECH_LAPSES, loadSrsSettings, saveSrsSettings, THROTTLE,
} from '../utils/srsService'
import { buildWordRows, calculateInsights, filterSrsWords, reviewWorkload } from '../utils/srsMetrics'
import SrsInsights from './SrsInsights'
import SrsWords from './SrsWords'
import SrsWordDetails from './SrsWordDetails'

const INITIAL_FILTERS = { status: 'all', lesson: null, query: '', sort: 'due', dayOffset: 1 }

export default function StatsDashboard({ userId, practiceStats }) {
  const [result, setResult] = useState({ data: null, error: '' })
  const [refresh, setRefresh] = useState(0)
  const [tab, setTab] = useState('overview')
  const [filters, setFilters] = useState(INITIAL_FILTERS)
  const [projection, setProjection] = useState({})
  const [saving, setSaving] = useState(false)
  const [saveMessage, setSaveMessage] = useState(null)
  const [selectedWord, setSelectedWord] = useState(null)
  const [now, setNow] = useState(() => new Date())

  useEffect(() => {
    let cancelled = false
    getSrsStatsData(userId)
      .then(data => {
        if (!cancelled) {
          setResult({ data, error: '' })
          setNow(new Date())
        }
      })
      .catch(error => {
        console.error('Stats dashboard error:', error)
        if (!cancelled) setResult({ data: null, error: 'Could not load statistics. Check your connection and the SRS migration, then retry.' })
      })
    return () => { cancelled = true }
  }, [userId, refresh])

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 60000)
    return () => clearInterval(timer)
  }, [])

  function reload() {
    setResult({ data: null, error: '' })
    setSelectedWord(null)
    setRefresh(value => value + 1)
  }

  if (result.error) return <Alert severity="error" action={<Button onClick={reload}>Retry</Button>}>{result.error}</Alert>
  if (!result.data) return <Box textAlign="center" py={5}><CircularProgress aria-label="Loading statistics" /></Box>

  const source = result.data
  const settings = {
    ...source.settings, ...projection,
    bookTotals: { ...source.settings.bookTotals, ...projection.bookTotals },
  }
  const preferred = source.books.find(book => book.id === source.settings.bookId)
    ?? source.books.find(book => book.book_name === '耳から覚える')
  const bookId = filters.bookId === undefined ? preferred?.id ?? null : filters.bookId
  const book = source.books.find(item => item.id === bookId)
  const activeFilters = { ...filters, bookId }
  const configuredTotal = bookId && Object.hasOwn(settings.bookTotals, bookId)
    ? settings.bookTotals[bookId] : book?.book_name === '耳から覚える' ? 880 : null
  const rows = buildWordRows(source.vocabulary, source.cards)
  const scopedRows = filterSrsWords(rows, { bookId }, now)
  const scopedCards = scopedRows.flatMap(row => row.card ? [row.card] : [])
  const workload = reviewWorkload(scopedCards, now)
  const globalWorkload = reviewWorkload(source.cards, now)
  const insights = calculateInsights({
    cards: source.cards, links: scopedRows.map(row => ({ vocab_id: row.id })),
    logs: source.logs, totalWords: configuredTotal, examDate: settings.examDate, now,
    minRetentionLogs: THROTTLE.minLogsForRetention, leechLapses: LEECH_LAPSES,
  })

  function browse(patch) {
    setFilters({ ...INITIAL_FILTERS, bookId, ...patch })
    setTab('words')
  }

  function updateProjection(patch) {
    setSaveMessage(null)
    setProjection(current => ({
      ...current, ...patch,
      bookTotals: { ...current.bookTotals, ...patch.bookTotals },
    }))
  }

  async function saveProjection() {
    setSaving(true)
    setSaveMessage(null)
    try {
      // Merge only plan edits, never the independent Stats book selection.
      const latest = await loadSrsSettings(userId)
      const next = {
        ...latest,
        ...(projection.examDate !== undefined ? { examDate: projection.examDate } : {}),
        bookTotals: { ...latest.bookTotals, ...projection.bookTotals },
      }
      if (!await saveSrsSettings(userId, next)) throw new Error('Could not save exam plan')
      setResult(current => ({ ...current, data: { ...current.data, settings: next } }))
      setProjection({})
      setSaveMessage({ severity: 'success', text: 'Exam plan saved. Your review source and schedule are unchanged.' })
    } catch (error) {
      console.error('Save exam plan error:', error)
      setSaveMessage({ severity: 'error', text: 'Could not save the exam plan. Your edits are still shown; please retry.' })
    } finally {
      setSaving(false)
    }
  }

  return (
    <Box sx={{ maxWidth: 850, mx: 'auto' }}>
      <Box display="flex" justifyContent="space-between" alignItems="center" gap={1} mb={1}>
        <Typography variant="h5" fontWeight={700}>Statistics</Typography>
        <Button size="small" onClick={reload} disabled={saving}>Refresh</Button>
      </Box>
      <Typography fontSize={11} color="text.secondary" mb={2}>
        Snapshot loaded {source.loadedAt.toLocaleTimeString()}. Refresh for changes made in other sessions.
      </Typography>
      <TextField select fullWidth size="small" label="Stats book" value={bookId ?? ''} disabled={saving}
        SelectProps={{ displayEmpty: true }} InputLabelProps={{ shrink: true }}
        helperText="Browsing does not change your Review source. The All books view counts uploaded words only."
        onChange={event => setFilters({ ...INITIAL_FILTERS, bookId: event.target.value === '' ? null : Number(event.target.value) })}>
        <MenuItem value="">All books / uploaded words</MenuItem>
        {source.books.map(item => <MenuItem key={item.id} value={item.id}>{item.book_name}</MenuItem>)}
      </TextField>
      <Tabs value={tab} onChange={(_, value) => setTab(value)} aria-label="Statistics sections" sx={{ mb: 2, mt: 1 }}>
        <Tab value="overview" label="Overview" id="stats-overview-tab" aria-controls="stats-overview-panel" />
        <Tab value="words" label="Words" id="stats-words-tab" aria-controls="stats-words-panel" />
      </Tabs>
      {saveMessage && <Alert severity={saveMessage.severity} sx={{ mb: 1.5 }}>{saveMessage.text}</Alert>}
      {tab === 'overview' ? (
        <Box role="tabpanel" id="stats-overview-panel" aria-labelledby="stats-overview-tab">
          <SrsInsights key={bookId ?? 'all'} data={insights} workload={workload} globalWorkload={globalWorkload}
            configuredTotal={configuredTotal} settings={settings} bookId={bookId} scopeLabel={book?.book_name ?? 'All books'}
            onUpdate={updateProjection} onSave={saveProjection} saving={saving} onBrowse={browse} />
          <Accordion sx={{ mt: 2 }} elevation={0} variant="outlined" slotProps={{ transition: { unmountOnExit: true } }}>
            <AccordionSummary expandIcon={<ExpandMoreIcon />}>
              <Typography fontWeight={700}>Practice activity and recent sessions</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Alert severity="info" sx={{ mb: 2 }}>
                Practice accuracy and legacy mastery scores are separate from FSRS card states.
                Activity includes recorded SRS and non-SRS practice; it is not a no-missed-review streak.
                These summaries use their own level filter, not the Stats book filter.
              </Alert>
              {practiceStats}
            </AccordionDetails>
          </Accordion>
        </Box>
      ) : (
        <Box role="tabpanel" id="stats-words-panel" aria-labelledby="stats-words-tab">
          <SrsWords rows={rows} filters={activeFilters} now={now}
            onFilter={patch => setFilters(current => ({ ...current, ...patch }))} onOpen={setSelectedWord} />
        </Box>
      )}
      {selectedWord && (
        <SrsWordDetails key={selectedWord.id} userId={userId} row={selectedWord} books={source.books} onClose={() => setSelectedWord(null)} />
      )}
    </Box>
  )
}
