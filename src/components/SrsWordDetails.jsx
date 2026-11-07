import { useEffect, useState } from 'react'
import {
  Alert, Box, Button, Chip, CircularProgress, Dialog, DialogActions, DialogContent,
  DialogTitle, Divider, Typography, useMediaQuery, useTheme,
} from '@mui/material'
import { getSrsWordDetails } from '../utils/srsService'
import { srsStatusLabel } from '../utils/srsMetrics'

const RATINGS = ['Unknown', 'Again', 'Hard', 'Good', 'Easy']
const dateTime = value => value ? new Date(value).toLocaleString() : 'Never'

function speak(text) {
  window.speechSynthesis.cancel()
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = 'ja-JP'
  window.speechSynthesis.speak(utterance)
}

export default function SrsWordDetails({ userId, row, books, onClose }) {
  const fullScreen = useMediaQuery(useTheme().breakpoints.down('sm'))
  const [result, setResult] = useState({ data: null, error: '' })
  const [retry, setRetry] = useState(0)
  const [visibleLogs, setVisibleLogs] = useState(20)
  const canSpeak = 'speechSynthesis' in window

  useEffect(() => {
    let cancelled = false
    getSrsWordDetails(userId, row.id)
      .then(data => { if (!cancelled) setResult({ data, error: '' }) })
      .catch(error => {
        console.error('SRS word details error:', error)
        if (!cancelled) setResult({ data: null, error: 'Could not load word details. Check your connection and retry.' })
      })
    return () => { cancelled = true }
  }, [userId, row.id, retry])

  const card = row.card
  const vocab = result.data?.vocab
  return (
    <Dialog open onClose={onClose} fullWidth maxWidth="sm" fullScreen={fullScreen} aria-labelledby="word-detail-title">
      <DialogTitle id="word-detail-title">{row.word}</DialogTitle>
      <DialogContent dividers>
        <Typography color="primary">{row.reading}</Typography>
        <Typography fontWeight={700} mb={1}>{row.meaning}</Typography>
        <Button size="small" disabled={!canSpeak} onClick={() => speak(row.reading || row.word)}>Play pronunciation</Button>
        <Box display="flex" gap={1} flexWrap="wrap" my={1}>
          <Chip label={srsStatusLabel(card)} size="small" />
          {(row.vocabulary_books ?? []).map(link => (
            <Chip key={link.book_id} size="small" variant="outlined"
              label={`${books.find(book => book.id === link.book_id)?.book_name ?? 'Book'}${link.lesson_number != null ? ` - L${link.lesson_number}` : ''}`} />
          ))}
        </Box>
        <Typography fontSize={12} color="text.secondary">Read-only. Viewing a word does not rate it or change its schedule.</Typography>
        <Divider sx={{ my: 2 }} />
        {card ? (
          <Box>
            <Typography fontSize={13}>Next review: {card.suspended || card.state === 0 ? 'Not scheduled' : dateTime(card.due)}</Typography>
            <Typography fontSize={13}>Last reviewed: {dateTime(card.last_review)}</Typography>
            <Typography fontSize={13}>Current interval: {card.scheduled_days} days</Typography>
            <Typography fontSize={13}>Repetitions: {card.reps} · Review lapses: {card.lapses}</Typography>
          </Box>
        ) : <Typography fontSize={13}>Not yet introduced to SRS. Practice outside SRS does not create an SRS schedule.</Typography>}
        {result.error ? (
          <Alert severity="error" sx={{ mt: 2 }} action={<Button onClick={() => { setResult({ data: null, error: '' }); setRetry(value => value + 1) }}>Retry</Button>}>
            {result.error}
          </Alert>
        ) : !result.data ? <Box py={2}><CircularProgress size={24} aria-label="Loading word details" /></Box> : (
          <>
            <Typography fontWeight={700} mt={2} mb={1}>Examples</Typography>
            {vocab.example_sentences?.length ? vocab.example_sentences.map(example => (
              <Box key={example.id} mb={1.5}>
                <Typography>{example.japanese_sentence}</Typography>
                <Typography fontSize={13} color="text.secondary">{example.english_translation}</Typography>
              </Box>
            )) : <Typography fontSize={13}>No examples available.</Typography>}
            <Typography fontWeight={700} mt={2} mb={1}>SRS rating history ({result.data.logs.length})</Typography>
            {result.data.logs.length === 0 ? <Typography fontSize={13}>No SRS ratings recorded. Marking a word Known does not add a rating.</Typography> : (
              <>
                {result.data.logs.slice(0, visibleLogs).map(log => (
                  <Box key={log.id} display="flex" justifyContent="space-between" gap={2}
                    sx={{ py: 1, borderBottom: '1px solid', borderColor: 'divider' }}>
                    <Typography fontSize={12}>{dateTime(log.review)}</Typography>
                    <Chip size="small" label={RATINGS[log.rating]} color={log.rating === 1 ? 'error' : 'default'} />
                  </Box>
                ))}
                {visibleLogs < result.data.logs.length && (
                  <Button size="small" onClick={() => setVisibleLogs(value => value + 20)}>Show more ratings</Button>
                )}
              </>
            )}
          </>
        )}
      </DialogContent>
      <DialogActions><Button onClick={onClose}>Close</Button></DialogActions>
    </Dialog>
  )
}
