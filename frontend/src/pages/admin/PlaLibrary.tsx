import { useState, useEffect, useCallback } from 'react';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TableSortLabel from '@mui/material/TableSortLabel';
import Typography from '@mui/material/Typography';
import Paper from '@mui/material/Paper';
import { useTranslation } from 'react-i18next';
import { apiFetch } from '../../app/api/apiFetch';

interface PlaCourse {
  id: number;
  title: string;
  category: string | null;
  topics: string[];
  language: string | null;
  imported: boolean;
  importedCourseId: number | null;
  importedPubStatus: string | null;
}

const PUB_STATUS_OPTIONS = [
  { value: 'D', label: 'Draft' },
  { value: 'P', label: 'Published' },
  { value: 'C', label: 'Coming Soon' },
  { value: 'A', label: 'Archived' },
];

type SortKey = 'title' | 'category' | 'topics' | 'language' | 'imported';
type SortDir = 'asc' | 'desc';

function sortCourses(courses: PlaCourse[], key: SortKey, dir: SortDir): PlaCourse[] {
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

export default function AdminPlaLibrary() {
  const { t } = useTranslation();

  const [courses, setCourses] = useState<PlaCourse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortKey, setSortKey] = useState<SortKey>('title');
  const [sortDir, setSortDir] = useState<SortDir>('asc');
  const [importing, setImporting] = useState<number | null>(null);
  const [importError, setImportError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiFetch('/api/v1/admin/pla_courses')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load courses');
        return res.json() as Promise<{ courses: PlaCourse[] }>;
      })
      .then((data) => {
        if (!cancelled) setCourses(data.courses);
      })
      .catch(() => {
        if (!cancelled) setError(t('admin.plaLibraryPage.loadError'));
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

  const handleImport = useCallback(async (courseId: number) => {
    setImporting(courseId);
    setImportError(null);
    try {
      const res = await apiFetch(`/api/v1/admin/pla_courses/${courseId}/import`, { method: 'POST' });
      if (!res.ok) {
        const body = await res.json() as { message?: string };
        throw new Error(body.message ?? 'Import failed');
      }
      const { importedCourseId, importedPubStatus } = await res.json() as {
        importedCourseId: number;
        importedPubStatus: string;
      };
      setCourses((prev) =>
        prev.map((c) =>
          c.id === courseId
            ? { ...c, imported: true, importedCourseId, importedPubStatus }
            : c
        )
      );
    } catch (err) {
      setImportError(err instanceof Error ? err.message : t('admin.plaLibraryPage.importError'));
    } finally {
      setImporting(null);
    }
  }, [t]);

  const handlePubStatus = useCallback(async (courseId: number, importedCourseId: number, pubStatus: string) => {
    // Optimistic update
    setCourses((prev) =>
      prev.map((c) =>
        c.id === courseId ? { ...c, importedPubStatus: pubStatus } : c
      )
    );
    try {
      const res = await apiFetch(`/api/v1/admin/pla_courses/${importedCourseId}/pub_status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pub_status: pubStatus }),
      });
      if (!res.ok) throw new Error('Failed to update status');
    } catch {
      // Revert on failure — refetch would be cleaner but keep it simple
      setCourses((prev) =>
        prev.map((c) =>
          c.id === courseId ? { ...c, importedPubStatus: null } : c
        )
      );
    }
  }, []);

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
        {t('admin.plaLibrary')}
      </Typography>

      {loading && <CircularProgress />}
      {error && <Alert severity="error">{error}</Alert>}
      {importError && <Alert severity="error" sx={{ mb: 2 }}>{importError}</Alert>}

      {!loading && !error && (
        <TableContainer component={Paper} variant="outlined">
          <Table size="small">
            <TableHead>
              <TableRow>
                {col('title', t('admin.plaLibraryPage.colTitle'))}
                {col('category', t('admin.plaLibraryPage.colCategory'))}
                {col('topics', t('admin.plaLibraryPage.colTopics'))}
                {col('language', t('admin.plaLibraryPage.colLanguage'))}
                {col('imported', t('admin.plaLibraryPage.colStatus'))}
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
                      <Chip label={t('admin.plaLibraryPage.imported')} color="success" size="small" />
                    ) : (
                      <Chip label={t('admin.plaLibraryPage.notImported')} size="small" />
                    )}
                  </TableCell>
                  <TableCell align="right">
                    {course.imported && course.importedCourseId !== null ? (
                      <Select
                        size="small"
                        value={course.importedPubStatus ?? ''}
                        onChange={(e) =>
                          handlePubStatus(course.id, course.importedCourseId!, e.target.value)
                        }
                        sx={{ minWidth: 130 }}
                      >
                        {PUB_STATUS_OPTIONS.map((opt) => (
                          <MenuItem key={opt.value} value={opt.value}>
                            {opt.label}
                          </MenuItem>
                        ))}
                      </Select>
                    ) : (
                      <Button
                        variant="contained"
                        size="small"
                        disabled={importing === course.id}
                        onClick={() => handleImport(course.id)}
                      >
                        {importing === course.id
                          ? t('admin.plaLibraryPage.importing')
                          : t('admin.plaLibraryPage.import')}
                      </Button>
                    )}
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
