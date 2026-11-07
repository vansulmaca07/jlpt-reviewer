import { useEffect, useState } from 'react'
import {
  Box, Card, CardContent, Typography, Button, TextField, MenuItem,
  Alert, CircularProgress, Grid
} from '@mui/material'
import { supabase } from '../supabaseClient'
import { loadSrsSettings, saveSrsSettings, getSrsSummary } from '../utils/srsService'

const RETENTION_OPTIONS = [0.85, 0.9, 0.95]

function Stat({ value, label, color }) {
  return (
    <Box textAlign="center" flex={1}>
      <Typography fontSize="22px" fontWeight={700} color={color} lineHeight={1.1}>{value}</Typography>
      <Typography fontSize="10px" color="text.secondary">{label}</Typography>
    </Box>
  )
}

function SrsPanel({ userId, books, onStart }) {
  const [settings, setSettings] = useState(null)
  const [summary, setSummary] = useState(null)
  const [summaryError, setSummaryError] = useState('')
  const [lessonOptions, setLessonOptions] = useState([])
  const [newPerDayInput, setNewPerDayInput] = useState('')

  useEffect(() => {
    if (!userId) return
    loadSrsSettings(userId).then(s => {
      setSettings(s)
      setNewPerDayInput(String(s.newPerDay))
    }).catch(error => {
      console.error('loadSrsSettings error:', error)
      setSummaryError('Could not load SRS settings. Check your connection and reload.')
    })
  }, [userId])

  useEffect(() => {
    if (!settings?.bookId) return
    supabase.from('vocabulary_books').select('lesson_number').eq('book_id', settings.bookId)
      .order('lesson_number', { ascending: true })
      .then(({ data }) => setLessonOptions([...new Set((data || []).map(d => d.lesson_number).filter(Boolean))]))
  }, [settings?.bookId])

  useEffect(() => {
    if (!settings) return
    let cancelled = false
    const t = setTimeout(async () => {
      try {
        const saved = await saveSrsSettings(userId, settings)
        if (!saved) throw new Error('Could not save SRS settings')
        const s = await getSrsSummary(userId, settings)
        if (!cancelled) { setSummary(s); setSummaryError('') }
      } catch (err) {
        console.error('getSrsSummary error:', err)
        if (!cancelled) setSummaryError('Could not save or load SRS data. Check your connection and SRS migration.')
      }
    }, 400)
    return () => { cancelled = true; clearTimeout(t) }
  }, [settings, userId])

  function update(patch) {
    if ('bookId' in patch) setLessonOptions([])
    setSummary(null)
    setSettings(s => ({ ...s, ...patch }))
  }

  function handleNewPerDay(val) {
    setNewPerDayInput(val)
    const n = parseInt(val)
    if (!isNaN(n) && n >= 0 && n <= 200) update({ newPerDay: n })
  }

  if (!userId) return (
    <Alert severity="info" sx={{ mb: 1.5 }}>Sign in to use SRS. Your review schedule is saved to your account.</Alert>
  )

  if (!settings) return summaryError
    ? <Alert severity="error">{summaryError}</Alert>
    : <Box textAlign="center" py={3}><CircularProgress size={24} /></Box>

  const newToShow = summary ? Math.min(summary.newRemaining, summary.newAvailable) : 0
  const nothingToDo = summary && summary.dueReviews + summary.dueLearning + newToShow === 0

  return (
    <>
      <Card sx={{ mb: 1.5 }} elevation={0} variant="outlined">
        <CardContent sx={{ py: 1.25, px: 1.5, '&:last-child': { pb: 1.25 } }}>
          <Typography fontWeight="bold" fontSize="12px" mb={1}>Today's review</Typography>
          {summaryError ? (
            <Alert severity="error" sx={{ fontSize: '12px' }}>{summaryError}</Alert>
          ) : !summary ? (
            <Box textAlign="center" py={1.5}><CircularProgress size={20} /></Box>
          ) : (
            <>
              <Box display="flex" mb={1}>
                <Stat value={newToShow} label={`New (${summary.newToday}/${summary.effectiveNewPerDay} today)`} color="#1976d2" />
                <Stat value={summary.dueLearning} label="Learning" color="#d32f2f" />
                <Stat value={summary.dueReviews} label="Review" color="#2e7d32" />
              </Box>
              {summary.throttleReason && (
                <Alert severity="warning" sx={{ py: 0, mb: 1, fontSize: '11px' }}>
                  New cards throttled to {summary.effectiveNewPerDay}/day: {summary.throttleReason}
                </Alert>
              )}
              <Typography fontSize="10px" color="text.secondary">
                In SRS: <strong>{summary.activeCards}</strong> · Known: <strong>{summary.knownCards}</strong> · Not yet introduced: <strong>{summary.newAvailable}</strong>
                {summary.retention !== null && <> · 7-day retention: <strong>{Math.round(summary.retention * 100)}%</strong></>}
              </Typography>
            </>
          )}
        </CardContent>
      </Card>

      <Card sx={{ mb: 1.5 }} elevation={0} variant="outlined">
        <CardContent sx={{ py: 1, px: 1.5, '&:last-child': { pb: 1 } }}>
          <Typography fontWeight="bold" fontSize="12px" mb={1}>New cards source</Typography>
          <Grid container spacing={1}>
            <Grid item xs={6}>
              <TextField fullWidth select label="Book" value={settings.bookId ?? ''} size="small"
                onChange={e => update({ bookId: e.target.value === '' ? null : Number(e.target.value), lessonFrom: null, lessonTo: null })}
                SelectProps={{ displayEmpty: true }} InputLabelProps={{ shrink: true }}
                sx={{ '& .MuiInputBase-root': { height: 34, fontSize: '12px' } }}>
                <MenuItem value="" dense><Typography fontSize="12px">None (reviews only)</Typography></MenuItem>
                {books.map(b => <MenuItem key={b.id} value={b.id} dense><Typography fontSize="12px">{b.book_name}</Typography></MenuItem>)}
              </TextField>
            </Grid>
            <Grid item xs={3}>
              <TextField fullWidth select label="From" value={settings.lessonFrom ?? ''} disabled={!settings.bookId} size="small"
                onChange={e => update({ lessonFrom: e.target.value === '' ? null : Number(e.target.value) })}
                SelectProps={{ displayEmpty: true }} InputLabelProps={{ shrink: true }}
                sx={{ '& .MuiInputBase-root': { height: 34, fontSize: '11px' } }}>
                <MenuItem value="" dense><Typography fontSize="11px">–</Typography></MenuItem>
                {lessonOptions.map(l => <MenuItem key={l} value={l} dense><Typography fontSize="11px">L{l}</Typography></MenuItem>)}
              </TextField>
            </Grid>
            <Grid item xs={3}>
              <TextField fullWidth select label="To" value={settings.lessonTo ?? ''} disabled={!settings.bookId} size="small"
                onChange={e => update({ lessonTo: e.target.value === '' ? null : Number(e.target.value) })}
                SelectProps={{ displayEmpty: true }} InputLabelProps={{ shrink: true }}
                sx={{ '& .MuiInputBase-root': { height: 34, fontSize: '11px' } }}>
                <MenuItem value="" dense><Typography fontSize="11px">–</Typography></MenuItem>
                {lessonOptions.filter(l => settings.lessonFrom === null || l >= settings.lessonFrom)
                  .map(l => <MenuItem key={l} value={l} dense><Typography fontSize="11px">L{l}</Typography></MenuItem>)}
              </TextField>
            </Grid>
            <Grid item xs={6}>
              <TextField fullWidth label="New / day" type="number" value={newPerDayInput} size="small"
                onChange={e => handleNewPerDay(e.target.value)} inputProps={{ min: 0, max: 200 }}
                helperText="Easy & Known don't count" FormHelperTextProps={{ sx: { fontSize: '9px', mx: 0 } }}
                sx={{ '& .MuiInputBase-root': { height: 34, fontSize: '12px' } }} />
            </Grid>
            <Grid item xs={6}>
              <TextField fullWidth select label="Target retention" value={settings.retention} size="small"
                onChange={e => update({ retention: Number(e.target.value) })}
                sx={{ '& .MuiInputBase-root': { height: 34, fontSize: '12px' } }}>
                {RETENTION_OPTIONS.map(r => <MenuItem key={r} value={r} dense><Typography fontSize="12px">{Math.round(r * 100)}%</Typography></MenuItem>)}
              </TextField>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Button fullWidth variant="contained" disabled={!summary || nothingToDo} onClick={() => onStart(settings)}
        sx={{ backgroundColor: '#1a3a5c', py: 1, fontSize: '13px', fontWeight: 600, borderRadius: 2 }}>
        {nothingToDo ? 'No cards due today 🎉' : 'Start Today’s Review'}
      </Button>
    </>
  )
}

export default SrsPanel
