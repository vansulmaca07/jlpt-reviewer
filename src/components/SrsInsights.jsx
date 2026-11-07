import { useState } from 'react'
import {
  Accordion, AccordionDetails, AccordionSummary, Alert, Box, Button, Card,
  CardActionArea, CardContent, Grid, LinearProgress, TextField, Typography,
} from '@mui/material'
import ExpandMoreIcon from '@mui/icons-material/ExpandMore'
import { THROTTLE } from '../utils/srsService'

const percent = value => value === null ? 'Not enough data' : `${(value * 100).toFixed(1)}%`
const dateLabel = date => date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })

function Metric({ label, value, detail, onClick }) {
  const content = (
    <CardContent>
      <Typography fontSize={12} color="text.secondary">{label}</Typography>
      <Typography fontSize={24} fontWeight={700}>{value}</Typography>
      {detail && <Typography fontSize={12} color="text.secondary">{detail}</Typography>}
    </CardContent>
  )
  return (
    <Grid size={{ xs: 12, sm: 4 }}>
      <Card variant="outlined" sx={{ height: '100%' }}>
        {onClick ? <CardActionArea onClick={onClick} sx={{ height: '100%' }} aria-label={`View ${label.toLowerCase()} words`}>{content}</CardActionArea> : content}
      </Card>
    </Grid>
  )
}

export default function SrsInsights({
  data, workload, globalWorkload, configuredTotal, settings, bookId, scopeLabel,
  onUpdate, onSave, saving, onBrowse,
}) {
  const [targetInput, setTargetInput] = useState(() => configuredTotal == null ? '' : String(configuredTotal))
  const targetValue = Number(targetInput)
  const targetError = targetInput !== '' && (!Number.isInteger(targetValue) || targetValue <= 0)

  return (
    <Box>
      <Typography variant="h6" fontWeight={700}>SRS overview</Typography>
      <Typography fontSize={12} color="text.secondary" mb={2}>
        Whole-book progress. Select a number to inspect its words. Introduced does not mean mastered.
      </Typography>
      <Grid container spacing={1.5}>
        <Metric label="Coverage" value={percent(data.coverage)}
          detail={`${data.introduced} introduced / ${data.total} ${configuredTotal ? 'target' : 'uploaded'} words`}
          onClick={() => onBrowse({ status: 'introduced' })} />
        <Metric label="Due today" value={workload.dueToday} detail="Includes overdue and learning cards"
          onClick={() => onBrowse({ status: 'due' })} />
        <Metric label="Tomorrow" value={workload.forecast[0].count} detail="Currently scheduled cards"
          onClick={() => onBrowse({ status: 'scheduled', dayOffset: 1 })} />
      </Grid>
      <LinearProgress variant="determinate" value={(data.coverage ?? 0) * 100} sx={{ height: 8, borderRadius: 1, my: 1.5 }} />
      <Box display="flex" gap={1} flexWrap="wrap" mb={1}>
        <Button size="small" onClick={() => onBrowse({ status: 'unseen' })}>
          {data.loaded - data.introduced} uploaded, not introduced
        </Button>
        <Button size="small" onClick={() => onBrowse({ status: 'leeches', sort: 'lapses' })}>
          {data.leeches.length} leech {data.leeches.length === 1 ? 'word' : 'words'}
        </Button>
      </Box>
      {data.loaded < data.total && (
        <Alert severity="info" sx={{ mb: 1.5 }}>
          {data.total - data.loaded} target words are not uploaded yet. They are not included in word lists.
          Completion estimates assume they will be added.
        </Alert>
      )}
      {data.loaded > data.total && (
        <Alert severity="warning" sx={{ mb: 1.5 }}>The target is smaller than the uploaded count. Update it under Estimates.</Alert>
      )}
      <Card variant="outlined" sx={{ my: 1.5 }}>
        <CardContent>
          <Typography fontWeight={700} fontSize={14} mb={1}>Next 7 study days - {scopeLabel}</Typography>
          <Grid container spacing={1}>
            {workload.forecast.map((day, index) => (
              <Grid size={{ xs: 6, sm: 3 }} key={day.date.toISOString()}>
                <Button fullWidth variant="outlined" onClick={() => onBrowse({ status: 'scheduled', dayOffset: index + 1 })}
                  sx={{ flexDirection: 'column', textTransform: 'none' }}>
                  <Typography fontSize={11}>{index === 0 ? 'Tomorrow' : `+${index + 1} days`} ({dateLabel(day.date)})</Typography>
                  <Typography fontWeight={700}>{day.count} {day.count === 1 ? 'card' : 'cards'}</Typography>
                </Button>
              </Grid>
            ))}
          </Grid>
          <Typography fontSize={11} color="text.secondary" mt={1}>
            Current schedules only; future repeat reviews and future introductions are not included.
            Study days start at 4 AM local time.
          </Typography>
        </CardContent>
      </Card>
      <Alert severity={globalWorkload.reviewDebt > THROTTLE.maxDueReviews ? 'warning' : 'info'}
        action={<Button color="inherit" size="small" onClick={() => onBrowse({ status: 'debt', bookId: null })}>View cards</Button>}>
        <strong>Review Debt: {globalWorkload.reviewDebt} - all books.</strong> {globalWorkload.dueToday} due through today
        {' '}+ next 3 days.
        {globalWorkload.reviewDebt > THROTTLE.maxDueReviews
          ? ` Above ${THROTTLE.maxDueReviews}: new learning is capped at ${Math.min(settings.newPerDay, THROTTLE.throttledNewPerDay)}/day.`
          : ` High-debt threshold: ${THROTTLE.maxDueReviews}.`}
      </Alert>
      <Accordion disableGutters sx={{ mt: 2 }} elevation={0} variant="outlined">
        <AccordionSummary expandIcon={<ExpandMoreIcon />}>
          <Box>
            <Typography fontWeight={700}>Estimates and exam plan</Typography>
            <Typography fontSize={12} color="text.secondary">
              Completion ETA: {data.eta ? data.eta.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' }) : 'Need introduction history'} - not a guarantee
            </Typography>
          </Box>
        </AccordionSummary>
        <AccordionDetails>
          <Box display="flex" flexDirection={{ xs: 'column', sm: 'row' }} gap={2} mb={1}>
            <TextField fullWidth size="small" type="number" label="Full-book word target"
              disabled={!bookId || saving} value={targetInput} inputProps={{ min: 1, step: 1 }}
              error={targetError}
              helperText={targetError ? 'Enter a positive whole number.' : bookId ? 'Blank = uploaded words only' : 'Choose one book to set a target'}
              onChange={event => {
                const raw = event.target.value
                const value = Number(raw)
                setTargetInput(raw)
                if (raw === '' || (Number.isInteger(value) && value > 0)) {
                  onUpdate({ bookTotals: { [bookId]: raw === '' ? null : value } })
                }
              }} />
            <TextField fullWidth size="small" type="date" label="Exam date"
              disabled={saving} value={settings.examDate} InputLabelProps={{ shrink: true }}
              onChange={event => onUpdate({ examDate: event.target.value })} />
          </Box>
          <Button size="small" variant="outlined" disabled={saving || targetError} onClick={onSave}>
            {saving ? 'Saving...' : 'Save exam plan'}
          </Button>
          <Typography fontSize={13} mt={2}>
            Completion ETA: {data.eta ? data.eta.toLocaleDateString() : 'Not enough introduction history'}.
            {' '}{data.remaining} remaining at {data.pace.toFixed(1)} introductions/day.
          </Typography>
          <Typography fontSize={12} color="text.secondary">
            Pace includes Easy and Known introductions over seven study days, including today and zero-activity days.
          </Typography>
          <Typography fontSize={13} mt={1}>
            Effective acquisition estimate: {data.effectiveAcquisition === null ? 'Not enough data' : `${data.effectiveAcquisition.toFixed(1)} words/day`}.
            {' '}{data.learningToday} new learning cards today x {percent(data.retention)} observed retention.
          </Typography>
          <Typography fontSize={12} color="text.secondary">
            A rough indicator, not proven memorization. Retention uses {data.retentionSamples} review-state ratings
            over seven rolling days (minimum 30). Again = failure; Hard/Good/Easy = success.
          </Typography>
          <Typography fontWeight={700} fontSize={14} mt={2}>Exam projection - {settings.examDate || 'set a date'}</Typography>
          {data.daysRemaining === null ? <Alert severity="info">Choose today or a future exam date.</Alert> : (
            <>
              <Typography fontSize={13}>{data.daysRemaining} days remaining. Projected coverage: {percent(data.examCoverage)}.</Typography>
              <Typography fontSize={13}>Unchanged-retention assumption: {percent(data.retention)}.</Typography>
              <Typography fontSize={13}>Currently scheduled through exam day: {data.scheduledUntilExam} cards (all books).</Typography>
              <Typography fontSize={12} color="text.secondary">
                Assumes the same introduction pace and observed retention. Not a predicted JLPT score.
                Scheduled cards include backlog but exclude future repeat reviews and future introductions.
              </Typography>
            </>
          )}
        </AccordionDetails>
      </Accordion>
    </Box>
  )
}
