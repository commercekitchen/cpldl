import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import IconButton from '@mui/material/IconButton';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Snackbar from '@mui/material/Snackbar';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import { apiFetch } from '../../app/api/apiFetch';

interface AdminCmsPage {
  id: number;
  slug: string;
  title: string;
  pub_status: string;
  language: string | null;
}

const PUB_STATUS_OPTIONS = [
  { value: 'D', label: 'Draft' },
  { value: 'P', label: 'Published' },
  { value: 'A', label: 'Archived' },
];

const PUB_STATUS_COLORS: Record<string, 'default' | 'success' | 'warning'> = {
  P: 'success',
  D: 'warning',
  A: 'default',
};

export default function AdminCmsPages() {
  const navigate = useNavigate();

  const [pages, setPages] = useState<AdminCmsPage[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pubStatusError, setPubStatusError] = useState(false);

  const load = useCallback(() => {
    setLoading(true);
    apiFetch('/api/v1/admin/cms_pages')
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<{ cms_pages: AdminCmsPage[] }>;
      })
      .then((data) => setPages(data.cms_pages))
      .catch(() => setError('Failed to load pages.'))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  const handlePubStatusChange = async (pageId: number, newStatus: string) => {
    const original = pages;
    setPages((prev) =>
      prev.map((p) => (p.id === pageId ? { ...p, pub_status: newStatus } : p)),
    );

    const res = await apiFetch(`/api/v1/admin/cms_pages/${pageId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ cms_page: { pub_status: newStatus } }),
    });

    if (!res.ok) {
      setPages(original);
      setPubStatusError(true);
    }
  };

  if (loading) return <CircularProgress />;
  if (error) return <Alert severity="error">{error}</Alert>;

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="h5">CMS Pages</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/admin/cms_pages/new')}
        >
          New Page
        </Button>
      </Box>

      <TableContainer component={Paper} variant="outlined">
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>Title</TableCell>
              <TableCell>Language</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right" />
            </TableRow>
          </TableHead>
          <TableBody>
            {pages.length === 0 && (
              <TableRow>
                <TableCell colSpan={5}>
                  <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
                    No pages yet.
                  </Typography>
                </TableCell>
              </TableRow>
            )}
            {pages.map((page) => (
              <TableRow key={page.id} hover>
                <TableCell>{page.title}</TableCell>
                <TableCell>{page.language ?? '—'}</TableCell>
                <TableCell>
                  <Select
                    size="small"
                    value={page.pub_status}
                    onChange={(e) => void handlePubStatusChange(page.id, e.target.value)}
                    renderValue={(v) => (
                      <Chip
                        size="small"
                        label={PUB_STATUS_OPTIONS.find((o) => o.value === v)?.label ?? v}
                        color={PUB_STATUS_COLORS[v] ?? 'default'}
                      />
                    )}
                    sx={{ minWidth: 130 }}
                  >
                    {PUB_STATUS_OPTIONS.map((o) => (
                      <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
                    ))}
                  </Select>
                </TableCell>
                <TableCell align="right">
                  <IconButton
                    size="small"
                    onClick={() => navigate(`/admin/cms_pages/${page.id}/edit`)}
                  >
                    <EditIcon fontSize="small" />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <Snackbar
        open={pubStatusError}
        autoHideDuration={4000}
        onClose={() => setPubStatusError(false)}
        message="Failed to update status."
      />
    </Box>
  );
}
