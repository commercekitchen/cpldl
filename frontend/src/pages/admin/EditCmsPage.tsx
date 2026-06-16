import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Divider from '@mui/material/Divider';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Skeleton from '@mui/material/Skeleton';
import Snackbar from '@mui/material/Snackbar';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import DeleteIcon from '@mui/icons-material/Delete';
import { apiFetch } from '../../app/api/apiFetch';
import { RichTextEditor } from '../../components/RichTextEditor';

const PUB_STATUS_OPTIONS = [
  { value: 'D', label: 'Draft' },
  { value: 'P', label: 'Published' },
  { value: 'A', label: 'Archived' },
];

interface FormState {
  title: string;
  languageId: number | null;
  body: string | null;
  author: string;
  pubStatus: string;
  seoPageTitle: string;
  metaDesc: string;
}

interface FormOptions {
  languages: { id: number; name: string }[];
}

function SectionHeader({ children }: { children: React.ReactNode }) {
  return (
    <Typography variant="subtitle1" fontWeight={600} sx={{ mt: 3, mb: 1 }}>
      {children}
    </Typography>
  );
}

export default function AdminEditCmsPage() {
  const { pageId } = useParams<{ pageId: string }>();
  const navigate = useNavigate();

  const [form, setForm] = useState<FormState | null>(null);
  const [options, setOptions] = useState<FormOptions>({ languages: [] });
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [saving, setSaving] = useState(false);
  const [saveErrors, setSaveErrors] = useState<string[]>([]);
  const [saveSuccess, setSaveSuccess] = useState(false);

  const [deleting, setDeleting] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  useEffect(() => {
    if (!pageId) return;
    let cancelled = false;

    apiFetch(`/api/v1/admin/cms_pages/${pageId}`)
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<{ cms_page: Record<string, unknown>; options: FormOptions }>;
      })
      .then((data) => {
        if (cancelled) return;
        const p = data.cms_page;
        setForm({
          title: (p.title as string) ?? '',
          languageId: (p.language_id as number | null) ?? null,
          body: (p.body as string | null) ?? null,
          author: (p.author as string) ?? '',
          pubStatus: (p.pub_status as string) ?? 'D',
          seoPageTitle: (p.seo_page_title as string | null) ?? '',
          metaDesc: (p.meta_desc as string | null) ?? '',
        });
        setOptions(data.options);
      })
      .catch(() => {
        if (!cancelled) setLoadError('Failed to load page.');
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [pageId]);

  const handleChange = <K extends keyof FormState>(field: K, value: FormState[K]) => {
    setForm((prev) => (prev ? { ...prev, [field]: value } : prev));
  };

  const handleSave = async () => {
    if (!form || !pageId) return;
    setSaving(true);
    setSaveErrors([]);

    try {
      const res = await apiFetch(`/api/v1/admin/cms_pages/${pageId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          cms_page: {
            title: form.title,
            language_id: form.languageId,
            body: form.body,
            audience: 'All',
            author: form.author,
            pub_status: form.pubStatus,
            seo_page_title: form.seoPageTitle || null,
            meta_desc: form.metaDesc || null,
          },
        }),
      });

      const data = (await res.json()) as { cms_page?: Record<string, unknown>; errors?: string[] };

      if (!res.ok) {
        setSaveErrors(data.errors ?? ['Failed to save page.']);
        return;
      }

      setSaveSuccess(true);
    } catch {
      setSaveErrors(['Failed to save page.']);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!pageId) return;
    setDeleting(true);

    try {
      const res = await apiFetch(`/api/v1/admin/cms_pages/${pageId}`, { method: 'DELETE' });
      if (res.ok) {
        navigate('/admin/cms_pages');
      } else {
        setSaveErrors(['Failed to delete page.']);
        setConfirmDelete(false);
      }
    } catch {
      setSaveErrors(['Failed to delete page.']);
      setConfirmDelete(false);
    } finally {
      setDeleting(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ maxWidth: 800 }}>
        <Skeleton width={120} height={36} sx={{ mb: 2 }} />
        <Skeleton width={200} height={48} sx={{ mb: 3 }} />
        <Skeleton variant="rectangular" height={400} />
      </Box>
    );
  }

  if (loadError || !form) {
    return <Alert severity="error">{loadError ?? 'Page not found.'}</Alert>;
  }

  return (
    <Box sx={{ maxWidth: 800 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate('/admin/cms_pages')}
        variant="text"
        color="inherit"
        sx={{ mb: 2 }}
      >
        Back to Pages
      </Button>

      <Typography variant="h4" gutterBottom>
        Edit Page
      </Typography>

      <Paper variant="outlined" sx={{ p: 3 }}>
        {saveErrors.length > 0 && (
          <Alert severity="error" sx={{ mb: 2 }}>
            <ul style={{ margin: 0, paddingLeft: 20 }}>
              {saveErrors.map((e, i) => (
                <li key={i}>{e}</li>
              ))}
            </ul>
          </Alert>
        )}

        <SectionHeader>Page Content</SectionHeader>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField
            label="Title"
            value={form.title}
            onChange={(e) => handleChange('title', e.target.value)}
            disabled={saving}
            inputProps={{ maxLength: 90 }}
            fullWidth
            required
          />
          <FormControl fullWidth disabled={saving}>
            <InputLabel>Language</InputLabel>
            <Select
              value={form.languageId ?? ''}
              label="Language"
              onChange={(e) => handleChange('languageId', e.target.value as number)}
            >
              {options.languages.map((l) => (
                <MenuItem key={l.id} value={l.id}>
                  {l.name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          <RichTextEditor
            label="Page Content"
            value={form.body}
            onChange={(html) => handleChange('body', html)}
            disabled={saving}
          />
        </Box>

        <Divider sx={{ my: 3 }} />

        <SectionHeader>Publication</SectionHeader>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField
            label="Author"
            value={form.author}
            onChange={(e) => handleChange('author', e.target.value)}
            disabled={saving}
            fullWidth
            required
          />
          <FormControl fullWidth disabled={saving}>
            <InputLabel>Publication Status</InputLabel>
            <Select
              value={form.pubStatus}
              label="Publication Status"
              onChange={(e) => handleChange('pubStatus', e.target.value)}
            >
              {PUB_STATUS_OPTIONS.map((o) => (
                <MenuItem key={o.value} value={o.value}>
                  {o.label}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </Box>

        <Divider sx={{ my: 3 }} />

        <SectionHeader>SEO</SectionHeader>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField
            label="SEO Page Title"
            value={form.seoPageTitle}
            onChange={(e) => handleChange('seoPageTitle', e.target.value)}
            disabled={saving}
            inputProps={{ maxLength: 90 }}
            helperText={`${form.seoPageTitle.length}/90`}
            fullWidth
          />
          <TextField
            label="Meta Description"
            value={form.metaDesc}
            onChange={(e) => handleChange('metaDesc', e.target.value)}
            disabled={saving}
            inputProps={{ maxLength: 156 }}
            helperText={`${form.metaDesc.length}/156`}
            multiline
            minRows={2}
            fullWidth
          />
        </Box>

        <Divider sx={{ my: 3 }} />

        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box sx={{ display: 'flex', gap: 2 }}>
            <Button
              variant="contained"
              onClick={() => void handleSave()}
              disabled={saving || !form.title.trim() || !form.author.trim()}
            >
              {saving ? 'Saving…' : 'Save Page'}
            </Button>
            <Button
              variant="outlined"
              onClick={() => navigate('/admin/cms_pages')}
              disabled={saving}
            >
              Cancel
            </Button>
          </Box>

          {confirmDelete ? (
            <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
              <Typography variant="body2" color="error">
                Are you sure?
              </Typography>
              <Button
                size="small"
                color="error"
                variant="contained"
                onClick={() => void handleDelete()}
                disabled={deleting}
              >
                {deleting ? 'Deleting…' : 'Yes, Delete'}
              </Button>
              <Button size="small" onClick={() => setConfirmDelete(false)} disabled={deleting}>
                Cancel
              </Button>
            </Box>
          ) : (
            <Button
              startIcon={<DeleteIcon />}
              color="error"
              onClick={() => setConfirmDelete(true)}
              disabled={saving}
            >
              Delete Page
            </Button>
          )}
        </Box>
      </Paper>

      <Snackbar
        open={saveSuccess}
        autoHideDuration={3000}
        onClose={() => setSaveSuccess(false)}
        message="Page saved."
      />
    </Box>
  );
}
