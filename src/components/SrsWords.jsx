import { useState } from 'react'
import {
  Alert, Box, Button, Card, CardActionArea, CardContent, Chip, MenuItem,
  Table, TableBody, TableCell, TableContainer, TableHead, TablePagination,
  TableRow, TextField, Typography,
} from '@mui/material'
import { filterSrsWords, srsStatusLabel, studyDayRange } from '../utils/srsMetrics'
import { LEECH_LAPSES } from '../utils/srsService'

const FILTERS = [
  ['all', 'All words'], ['introduced', 'Introduced'], ['unseen', 'Not introduced'],
  ['learning', 'Learning / relearning'], ['review', 'Review'], ['known', 'Known / suspended'],
  ['leeches', `Leeches (${LEECH_LAPSES}+ lapses)`], ['due', 'Due through today'], ['scheduled', 'Scheduled day'],
  ['debt', 'Review Debt (all due + next 3 days)'],
]

function dueLabel(row) {
  return row.card && !row.card.suspended && row.card.state !== 0
    ? new Date(row.card.due).toLocaleString() : 'Not scheduled'
}

function debtGroup(row, now) {
  if (new Date(row.card.due) < studyDayRange(now).end) return 'Due through today'
  for (let offset = 1; offset <= 3; offset++) {
    if (new Date(row.card.due) < studyDayRange(now, offset).end) return `+${offset} study day${offset > 1 ? 's' : ''}`
  }
}

export default function SrsWords({ rows, filters, now, onFilter, onOpen }) {
  const [page, setPage] = useState(0)
  const [pageSize, setPageSize] = useState(25)
  const filtered = filterSrsWords(rows, filters, now, LEECH_LAPSES)
  const currentPage = Math.min(page, Math.max(0, Math.ceil(filtered.length / pageSize) - 1))
  const visible = filtered.slice(currentPage * pageSize, (currentPage + 1) * pageSize)
  const lessons = filters.bookId ? [...new Set(rows.flatMap(row =>
    (row.vocabulary_books ?? []).filter(link => link.book_id === filters.bookId)
      .map(link => link.lesson_number).filter(value => value != null)))].sort((a, b) => a - b) : []

  function change(patch) {
    setPage(0)
    onFilter(patch)
  }

  return (
    <Box>
      <Typography variant="h6" fontWeight={700} mb={1}>Word collection</Typography>
      <TextField fullWidth size="small" label="Search word, reading or meaning" value={filters.query}
        onChange={event => change({ query: event.target.value })} sx={{ mb: 1.5 }} />
      <Box display="flex" gap={1} flexWrap="wrap" mb={1.5}>
        <TextField select size="small" label="Status" value={filters.status} sx={{ minWidth: 180, flex: 1 }}
          onChange={event => change({ status: event.target.value })}>
          {FILTERS.map(([value, label]) => <MenuItem value={value} key={value}>{label}</MenuItem>)}
        </TextField>
        <TextField select size="small" label="Lesson" value={filters.lesson ?? ''} disabled={!filters.bookId}
          SelectProps={{ displayEmpty: true }} InputLabelProps={{ shrink: true }}
          sx={{ minWidth: 100 }} onChange={event => change({ lesson: event.target.value === '' ? null : Number(event.target.value) })}>
          <MenuItem value="">All lessons</MenuItem>
          {lessons.map(lesson => <MenuItem key={lesson} value={lesson}>L{lesson}</MenuItem>)}
        </TextField>
        <TextField select size="small" label="Sort" value={filters.sort} sx={{ minWidth: 120 }}
          onChange={event => change({ sort: event.target.value })}>
          <MenuItem value="due">Next due</MenuItem><MenuItem value="lapses">Most lapses</MenuItem><MenuItem value="word">Word</MenuItem>
        </TextField>
        {filters.status === 'scheduled' && (
          <TextField select size="small" label="Study day" value={filters.dayOffset} sx={{ minWidth: 120 }}
            onChange={event => change({ dayOffset: Number(event.target.value) })}>
            {Array.from({ length: 7 }, (_, index) => (
              <MenuItem key={index} value={index + 1}>{index === 0 ? 'Tomorrow' : `+${index + 1} days`}</MenuItem>
            ))}
          </TextField>
        )}
      </Box>
      <Box display="flex" alignItems="center" justifyContent="space-between" mb={1}>
        <Typography fontSize={13}>{filtered.length} matching {filtered.length === 1 ? 'word' : 'words'}</Typography>
        <Button size="small" onClick={() => change({ status: 'all', lesson: null, query: '', sort: 'due', dayOffset: 1 })}>Clear filters</Button>
      </Box>
      {filtered.length === 0 ? (
        <Alert severity="info">No uploaded words match these filters. Words not uploaded yet cannot appear here.</Alert>
      ) : (
        <>
          <TableContainer sx={{ display: { xs: 'none', sm: 'block' } }}>
            <Table size="small" aria-label="SRS word collection">
              <TableHead><TableRow>
                <TableCell>Word / meaning</TableCell><TableCell>Status</TableCell><TableCell>Next due</TableCell><TableCell align="right">Lapses</TableCell>
              </TableRow></TableHead>
              <TableBody>{visible.map(row => (
                <TableRow key={row.id} hover>
                  <TableCell sx={{ maxWidth: 260, overflowWrap: 'anywhere' }}>
                    <Button size="small" onClick={() => onOpen(row)} sx={{ p: 0, minWidth: 0, textTransform: 'none', fontSize: 17 }}>{row.word}</Button>
                    <Typography fontSize={12}>{row.reading}</Typography>
                    <Typography fontSize={12} color="text.secondary">{row.meaning}</Typography>
                  </TableCell>
                  <TableCell><Typography fontSize={12}>{srsStatusLabel(row.card)}</Typography></TableCell>
                  <TableCell>
                    {filters.status === 'debt' && <Typography fontSize={11} fontWeight={700}>{debtGroup(row, now)}</Typography>}
                    <Typography fontSize={12}>{dueLabel(row)}</Typography>
                  </TableCell>
                  <TableCell align="right">{row.card?.lapses ?? 0}</TableCell>
                </TableRow>
              ))}</TableBody>
            </Table>
          </TableContainer>
          <Box sx={{ display: { xs: 'block', sm: 'none' } }}>
            {visible.map(row => (
              <Card variant="outlined" sx={{ mb: 1 }} key={row.id}>
                <CardActionArea onClick={() => onOpen(row)}>
                  <CardContent>
                    <Typography fontWeight={700}>{row.word} <Typography component="span" fontSize={13} color="text.secondary">{row.reading}</Typography></Typography>
                    <Typography fontSize={13} mb={1}>{row.meaning}</Typography>
                    <Chip label={srsStatusLabel(row.card)} size="small" />
                    {filters.status === 'debt' && <Typography fontSize={12} mt={1}>{debtGroup(row, now)}</Typography>}
                    <Typography fontSize={12} color="text.secondary" mt={1}>{dueLabel(row)} · {row.card?.lapses ?? 0} lapses</Typography>
                  </CardContent>
                </CardActionArea>
              </Card>
            ))}
          </Box>
        </>
      )}
      <TablePagination component="div" count={filtered.length} page={currentPage} rowsPerPage={pageSize}
        rowsPerPageOptions={[10, 25, 50]} onPageChange={(_, value) => setPage(value)}
        onRowsPerPageChange={event => { setPageSize(Number(event.target.value)); setPage(0) }}
        sx={{ '& .MuiTablePagination-toolbar': { px: 0, flexWrap: 'wrap' } }} />
    </Box>
  )
}
