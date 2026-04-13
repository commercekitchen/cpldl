import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import Snackbar from '@mui/material/Snackbar';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TableSortLabel from '@mui/material/TableSortLabel';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import Paper from '@mui/material/Paper';
import EditIcon from '@mui/icons-material/Edit';
import { useTranslation } from 'react-i18next';
import { apiFetch } from '../../app/api/apiFetch';

interface AdminCourse {
  id: number;
  title: string;
  category: string | null;
  topics: string[];
  language: string | null;
  imported: boolean;
  pubStatus: string;
}

const PUB_STATUS_OPTIONS = [
  { value: 'D', label: 'Draft' },
  { value: 'P', label: 'Published' },
  { value: 'C', label: 'Coming Soon' },
  { value: 'A', label: 'Archived' },
];

type SortKey = 'title' | 'category' | 'topics' | 'language' | 'imported' | 'pubStatus';
type SortDir = 'asc' | 'desc';

function sortCourses(courses: AdminCourse[], key: SortKey, dir: SortDir): AdminCourse[] {
  return [...courses].sort((a, b) => {
    let av: string;
    let bv: string;
    switch (key) {
      case 'topics':
        av = a.topics.join(', ');
        bv = b.topics.join(', ');
        break;
      case 'imported':
        av = a.imported ? '0' : '1';
        bv = b.imported ? '0' : '1';
        break;
      default:
        av = (a[key] ?? '').toLowerCase();
        bv = (b[key] ?? '').toLowerCase();
    }
    const cmp = av.localeCompare(bv);
    return dir === 'asc' ? cmp : -cmp;
  });
}

export default function AdminCourses() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const [courses, setCourses] = useState<AdminCourse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortKey, setSortKey] = useState<SortKey>('title');
  const [sortDir, setSortDir] = useState<SortDir>('asc');
  const [pubStatusError, setPubStatusError] = useState(false);

  useEffect(() => {
    let cancelled = false;
    apiFetch('/api/v1/admin/courses')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load courses');
        return res.json() as Promise<{ courses: AdminCourse[] }>;
      })
      .then((data) => {
        if (!cancelled) setCourses(data.courses);
      })
      .catch(() => {
        if (!cancelled) setError(t('admin.adminCoursesPage.loadError'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => { cancelled = true; };
  }, [t]);

  const handleSort = (key: SortKey) => {
    if (key === sortKey) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDir('asc');
    }
  };

  const handlePubStatus = useCallback(
    async (courseId: number, pubStatus: string, previousPubStatus: string) => {
      setCourses((prev) =>
        prev.map((c) => (c.id === courseId ? { ...c, pubStatus } : c)),
      );
      try {
        const res = await apiFetch(`/api/v1/admin/courses/${courseId}/pub_status`, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ pub_status: pubStatus }),
        });
        if (!res.ok) throw new Error('Failed to update status');
        void queryClient.invalidateQueries({ queryKey: ['courses'] });
        void queryClient.invalidateQueries({ queryKey: ['lessons'] });
      } catch {
        setCourses((prev) =>
          prev.map((c) => (c.id === courseId ? { ...c, pubStatus: previousPubStatus } : c)),
        );
        setPubStatusError(true);
      }
    },
    [queryClient],
  );

  const sorted = sortCourses(courses, sortKey, sortDir);

  const col = (key: SortKey, label: string) => (
    <TableCell sortDirection={sortKey === key ? sortDir : false}>
      <TableSortLabel
        active={sortKey === key}
        direction={sortKey === key ? sortDir : 'asc'}
        onClick={() => handleSort(key)}
      >
        {label}
      </TableSortLabel>
    </TableCell>
  );

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {t('admin.courses')}
      </Typography>

      {loading && <CircularProgress />}
      {error && <Alert severity="error">{error}</Alert>}

      <Snackbar
        open={pubStatusError}
        autoHideDuration={4000}
        onClose={() => setPubStatusError(false)}
        message={t('admin.adminCoursesPage.pubStatusError')}
      />

      {!loading && !error && (
        <TableContainer component={Paper} variant="outlined">
          <Table size="small">
            <TableHead>
              <TableRow>
                {col('title', t('admin.adminCoursesPage.colTitle'))}
                {col('category', t('admin.adminCoursesPage.colCategory'))}
                {col('topics', t('admin.adminCoursesPage.colTopics'))}
                {col('language', t('admin.adminCoursesPage.colLanguage'))}
                {col('imported', t('admin.adminCoursesPage.colType'))}
                {col('pubStatus', t('admin.adminCoursesPage.colPubStatus'))}
                <TableCell />
              </TableRow>
            </TableHead>
            <TableBody>
              {sorted.map((course) => (
                <TableRow key={course.id} hover>
                  <TableCell>{course.title}</TableCell>
                  <TableCell>{course.category ?? '—'}</TableCell>
                  <TableCell>{course.topics.join(', ') || '—'}</TableCell>
                  <TableCell>{course.language ?? '—'}</TableCell>
                  <TableCell>
                    {course.imported ? (
                      <Chip label={t('admin.adminCoursesPage.imported')} color="primary" size="small" />
                    ) : (
                      <Chip label={t('admin.adminCoursesPage.custom')} size="small" />
                    )}
                  </TableCell>
                  <TableCell align="left">
                    <Select
                      size="small"
                      value={course.pubStatus}
                      onChange={(e) => handlePubStatus(course.id, e.target.value, course.pubStatus)}
                      sx={{ minWidth: 130 }}
                    >
                      {PUB_STATUS_OPTIONS.map((opt) => (
                        <MenuItem key={opt.value} value={opt.value}>
                          {opt.label}
                        </MenuItem>
                      ))}
                    </Select>
                  </TableCell>
                  <TableCell align="right" padding="checkbox">
                    <IconButton
                      size="small"
                      onClick={() => navigate(`/admin/courses/${course.id}/edit`)}
                      aria-label={t('admin.adminCoursesPage.editCourse')}
                    >
                      <EditIcon fontSize="small" />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  );
}
