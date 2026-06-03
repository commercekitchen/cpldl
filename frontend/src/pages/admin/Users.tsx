import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import FormControl from '@mui/material/FormControl';
import InputAdornment from '@mui/material/InputAdornment';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Snackbar from '@mui/material/Snackbar';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import DownloadIcon from '@mui/icons-material/Download';
import SearchIcon from '@mui/icons-material/Search';
import { apiFetch } from '../../app/api/apiFetch';

interface User {
  id: number;
  firstName: string | null;
  lastName: string | null;
  email: string | null;
  role: 'user' | 'admin' | 'trainer';
  createdAt: string;
}

interface UsersResponse {
  users: User[];
  meta: { total: number; page: number; perPage: number };
}

const ROLES = ['user', 'admin', 'trainer'] as const;
const PER_PAGE = 25;

function useDebounce(value: string, delay: number) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(t);
  }, [value, delay]);
  return debounced;
}

export default function AdminUsers() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const [page, setPage] = useState(0); // MUI TablePagination is 0-indexed
  const [searchInput, setSearchInput] = useState('');
  const [roleError, setRoleError] = useState<string | null>(null);
  const [updatingRoles, setUpdatingRoles] = useState<Set<number>>(new Set());

  const search = useDebounce(searchInput, 400);

  // Reset to first page when search changes
  useEffect(() => {
    setPage(0);
  }, [search]);

  const queryKey = ['admin-users', page + 1, search] as const;

  const { data, isLoading, isError } = useQuery<UsersResponse>({
    queryKey,
    queryFn: async () => {
      const params = new URLSearchParams({ page: String(page + 1), per_page: String(PER_PAGE) });
      if (search) params.set('q', search);
      const res = await apiFetch(`/api/v1/admin/users?${params.toString()}`);
      if (!res.ok) throw new Error();
      return res.json() as Promise<UsersResponse>;
    },
    staleTime: 30_000,
    refetchOnWindowFocus: false,
  });

  const handleRoleChange = async (userId: number, newRole: string) => {
    setUpdatingRoles((prev) => new Set(prev).add(userId));
    setRoleError(null);
    try {
      const res = await apiFetch(`/api/v1/admin/users/${userId}/update_role`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ role: newRole }),
      });
      if (!res.ok) throw new Error();
      await queryClient.invalidateQueries({ queryKey: ['admin-users'] });
    } catch {
      setRoleError(t('admin.usersPage.roleError'));
    } finally {
      setUpdatingRoles((prev) => {
        const next = new Set(prev);
        next.delete(userId);
        return next;
      });
    }
  };

  const handleExport = () => {
    const link = document.createElement('a');
    link.href = '/api/v1/admin/users/export';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const roleLabel = (role: string) => {
    if (role === 'admin') return t('admin.usersPage.roleAdmin');
    if (role === 'trainer') return t('admin.usersPage.roleTrainer');
    return t('admin.usersPage.roleUser');
  };

  const total = data?.meta.total ?? 0;
  const users = data?.users ?? [];

  return (
    <Box>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
        <Typography variant="h4">{t('admin.usersPage.title')}</Typography>
        <Button variant="outlined" startIcon={<DownloadIcon />} onClick={handleExport}>
          {t('admin.usersPage.export')}
        </Button>
      </Box>

      <TextField
        placeholder={t('admin.usersPage.searchPlaceholder')}
        value={searchInput}
        onChange={(e) => setSearchInput(e.target.value)}
        size="small"
        sx={{ mb: 2, width: 320 }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchIcon fontSize="small" />
            </InputAdornment>
          ),
        }}
      />

      {isError && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {t('admin.usersPage.loadError')}
        </Alert>
      )}

      <Paper variant="outlined">
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>{t('admin.usersPage.colFirstName')}</TableCell>
                <TableCell>{t('admin.usersPage.colLastName')}</TableCell>
                <TableCell>{t('admin.usersPage.colEmail')}</TableCell>
                <TableCell>{t('admin.usersPage.colRole')}</TableCell>
                <TableCell>{t('admin.usersPage.colJoined')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={5} align="center" sx={{ py: 4 }}>
                    <CircularProgress size={28} />
                  </TableCell>
                </TableRow>
              ) : users.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} align="center" sx={{ py: 4, color: 'text.secondary' }}>
                    {t('admin.usersPage.empty')}
                  </TableCell>
                </TableRow>
              ) : (
                users.map((user) => (
                  <TableRow key={user.id} hover>
                    <TableCell>{user.firstName ?? '—'}</TableCell>
                    <TableCell>{user.lastName ?? '—'}</TableCell>
                    <TableCell>{user.email ?? '—'}</TableCell>
                    <TableCell sx={{ minWidth: 130 }}>
                      <FormControl size="small" fullWidth disabled={updatingRoles.has(user.id)}>
                        <Select
                          value={user.role}
                          onChange={(e) => void handleRoleChange(user.id, e.target.value)}
                        >
                          {ROLES.map((r) => (
                            <MenuItem key={r} value={r}>
                              {roleLabel(r)}
                            </MenuItem>
                          ))}
                        </Select>
                      </FormControl>
                    </TableCell>
                    <TableCell>{user.createdAt}</TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>

        <TablePagination
          component="div"
          count={total}
          rowsPerPage={PER_PAGE}
          rowsPerPageOptions={[PER_PAGE]}
          page={page}
          onPageChange={(_, newPage) => setPage(newPage)}
        />
      </Paper>

      <Snackbar
        open={Boolean(roleError)}
        autoHideDuration={4000}
        onClose={() => setRoleError(null)}
        message={roleError}
      />
    </Box>
  );
}
