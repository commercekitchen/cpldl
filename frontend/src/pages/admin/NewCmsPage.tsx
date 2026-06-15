import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { apiFetch } from '../../app/api/apiFetch';
import { RichTextEditor } from '../../components/RichTextEditor';

const PUB_STATUS_OPTIONS = [
  { value: 'D', label: 'Draft' },
  { value: 'P', label: 'Published' },
  { value: 'A', label: 'Archived' },
];

const AUDIENCE_OPTIONS = [
  { value: 'All', label: 'Everyone' },
  { value: 'Unauth', label: 'Unauthenticated Users' },
  { value: 'Auth', label: 'Authenticated Users' },
  { value: 'Admin', label: 'Administrators' },
];

interface FormState {
  title: string;
  languageId: number | null;
  body: string | null;
  audience: string;
  author: string;
  pubStatus: string;
  seoPageTitle: string;
  metaDesc: string;
}

const DEFAULT_FORM: FormState = {
  title: '',
  languageId: null,
  body: null,
  audience: 'All',
  author: '',
  pubStatus: 'D',
  seoPageTitle: '',
  metaDesc: '',
};

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

export default function AdminNewCmsPage() {
  const navigate = useNavigate();

  const [options, setOptions] = useState<FormOptions>({ languages: [] });
  const [optionsLoading, setOptionsLoading] = useState(true);
  const [optionsError, setOptionsError] = useState<string | null>(null);

  const [form, setForm] = useState<FormState>(DEFAULT_FORM);
  const [saving, setSaving] = useState(false);
  const [saveErrors, setSaveErrors] = useState<string[]>([]);

  useEffect(() => {
    let cancelled = false;
    apiFetch('/api/v1/admin/cms_pages/form_options')
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<{ options: FormOptions }>;
      })
      .then((data) => { if (!cancelled) setOptions(data.options); })
      .catch(() => { if (!cancelled) setOptionsError('Failed to load form options.'); })
      .finally(() => { if (!cancelled) setOptionsLoading(false); });
    return () => { cancelled = true; };
  }, []);

  const handleChange = <K extends keyof FormState>(field: K, value: FormState[K]) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async () => {
    setSaving(true);
    setSaveErrors([]);

    try {
      const res = await apiFetch('/api/v1/admin/cms_pages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          cms_page: {
            title: form.title,
            language_id: form.languageId,
            body: form.body,
            audience: form.audience,
            author: form.author,
            pub_status: form.pubStatus,
            seo_page_title: form.seoPageTitle || null,
            meta_desc: form.metaDesc || null,
          },
        }),
      });

      const data = await res.json() as { cms_page?: { id: number }; errors?: string[] };

      if (!res.ok) {
        setSaveErrors(data.errors ?? ['Failed to save page.']);
        return;
      }

      if (data.cms_page) {
        navigate(`/admin/cms_pages/${data.cms_page.id}/edit`);
      }
    } catch {
      setSaveErrors(['Failed to save page.']);
    } finally {
      setSaving(false);
    }
  };

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

      <Typography variant="h4" gutterBottom>New Page</Typography>

      {optionsLoading && <CircularProgress />}
      {optionsError && <Alert severity="error">{optionsError}</Alert>}

      {!optionsLoading && !optionsError && (
        <Paper variant="outlined" sx={{ p: 3 }}>
          {saveErrors.length > 0 && (
            <Alert severity="error" sx={{ mb: 2 }}>
              <ul style={{ margin: 0, paddingLeft: 20 }}>
                {saveErrors.map((e, i) => <li key={i}>{e}</li>)}
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
                  <MenuItem key={l.id} value={l.id}>{l.name}</MenuItem>
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
            <FormControl fullWidth disabled={saving}>
              <InputLabel>Audience</InputLabel>
              <Select
                value={form.audience}
                label="Audience"
                onChange={(e) => handleChange('audience', e.target.value)}
              >
                {AUDIENCE_OPTIONS.map((o) => (
                  <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
                ))}
              </Select>
            </FormControl>
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
                  <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
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

          <Box sx={{ display: 'flex', gap: 2 }}>
            <Button
              variant="contained"
              onClick={() => void handleSubmit()}
              disabled={saving || !form.title.trim() || !form.author.trim()}
            >
              {saving ? 'Saving…' : 'Create Page'}
            </Button>
            <Button
              variant="outlined"
              onClick={() => navigate('/admin/cms_pages')}
              disabled={saving}
            >
              Cancel
            </Button>
          </Box>
        </Paper>
      )}
    </Box>
  );
}
