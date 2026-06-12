import { useRef, useState } from 'react';
import { useRouteLoaderData, useRevalidator } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import type { OrganizationConfig } from '../../app/organization/types';
import { organizationClient } from '../../app/organization/organizationClient';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import IconButton from '@mui/material/IconButton';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Snackbar from '@mui/material/Snackbar';
import Switch from '@mui/material/Switch';
import Tab from '@mui/material/Tab';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Tabs from '@mui/material/Tabs';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import SaveIcon from '@mui/icons-material/Save';
import CloseIcon from '@mui/icons-material/Close';
import { apiFetch } from '../../app/api/apiFetch';

interface Language {
  id: number;
  name: string;
}

interface FooterLink {
  id: number;
  label: string;
  url: string;
  languageId: number | null;
  languageName: string | null;
}

interface GeneralSettings {
  logoUrl: string | null;
  footerLogoUrl: string | null;
  footerLogoLink: string | null;
  loginRequired: boolean;
}

interface ThemeSettings {
  primaryColor: string;
  secondaryColor: string;
}

interface SurveySettings {
  userSurveyEnabled: boolean;
  userSurveyLink: string | null;
  spanishSurveyLink: string | null;
  enButtonText: string | null;
  esButtonText: string | null;
}

interface LibraryLocation {
  id: number;
  name: string;
  zipcode: number | null;
  sortOrder: number;
}

interface BranchesSettings {
  enabled: boolean;
  locations: LibraryLocation[];
}

interface SettingsData {
  isMainSite: boolean;
  general: GeneralSettings;
  theme: ThemeSettings;
  footerLinks: FooterLink[];
  survey: SurveySettings;
  branches: BranchesSettings;
  languages: Language[];
}

export default function AdminSettings() {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const [tab, setTab] = useState(0);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const { data, isLoading, isError } = useQuery<SettingsData>({
    queryKey: ['admin-settings'],
    queryFn: async () => {
      const res = await apiFetch('/api/v1/admin/settings');
      if (!res.ok) throw new Error();
      return res.json() as Promise<SettingsData>;
    },
    staleTime: 30_000,
    refetchOnWindowFocus: false,
  });

  const showSuccess = (msg: string) => setSuccessMsg(msg);
  const showError = (msg: string) => setErrorMsg(msg);

  if (isLoading) return <CircularProgress />;
  if (isError || !data) return <Alert severity="error">{t('admin.settingsPage.loadError')}</Alert>;

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>
        {t('admin.settings')}
      </Typography>

      <Tabs value={tab} onChange={(_, v: number) => setTab(v)} sx={{ mb: 3 }}>
        <Tab label={t('admin.settingsPage.tabGeneral')} />
        <Tab label={t('admin.settingsPage.tabFooterLinks')} />
        <Tab label={t('admin.settingsPage.tabSurvey')} />
        {!data.isMainSite && <Tab label={t('admin.settingsPage.tabBranches')} />}
      </Tabs>

      {tab === 0 && (
        <GeneralSection
          data={data.general}
          theme={data.theme}
          onSuccess={showSuccess}
          onError={showError}
          queryClient={queryClient}
        />
      )}
      {tab === 1 && (
        <FooterLinksSection
          links={data.footerLinks}
          languages={data.languages}
          onSuccess={showSuccess}
          onError={showError}
          queryClient={queryClient}
        />
      )}
      {tab === 2 && (
        <SurveySection
          data={data.survey}
          onSuccess={showSuccess}
          onError={showError}
          queryClient={queryClient}
        />
      )}
      {tab === 3 && !data.isMainSite && (
        <BranchesSection
          data={data.branches}
          onSuccess={showSuccess}
          onError={showError}
          queryClient={queryClient}
        />
      )}

      <Snackbar
        open={Boolean(successMsg)}
        autoHideDuration={4000}
        onClose={() => setSuccessMsg(null)}
        message={successMsg}
      />
      <Snackbar
        open={Boolean(errorMsg)}
        autoHideDuration={5000}
        onClose={() => setErrorMsg(null)}
        message={errorMsg}
      />
    </Box>
  );
}

// ─── Color Field ─────────────────────────────────────────────────────────────

function ColorField({
  label,
  value,
  onChange,
  disabled,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  disabled: boolean;
}) {
  return (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
      <Box
        component="label"
        sx={{
          width: 44,
          height: 44,
          borderRadius: 1,
          bgcolor: value,
          cursor: disabled ? 'default' : 'pointer',
          border: '1px solid',
          borderColor: 'divider',
          flexShrink: 0,
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <input
          type="color"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          disabled={disabled}
          style={{
            position: 'absolute',
            inset: 0,
            opacity: 0,
            width: '100%',
            height: '100%',
            cursor: disabled ? 'default' : 'pointer',
          }}
        />
      </Box>
      <TextField
        label={label}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        disabled={disabled}
        size="small"
        sx={{ width: 160 }}
        inputProps={{ maxLength: 7 }}
      />
    </Box>
  );
}

// ─── General Section ──────────────────────────────────────────────────────────

function GeneralSection({
  data,
  theme,
  onSuccess,
  onError,
  queryClient,
}: {
  data: GeneralSettings;
  theme: ThemeSettings;
  onSuccess: (m: string) => void;
  onError: (m: string) => void;
  queryClient: ReturnType<typeof useQueryClient>;
}) {
  const { t } = useTranslation();
  const { orgConfig } = useRouteLoaderData('org') as { orgConfig: OrganizationConfig };
  const secondaryColor = orgConfig.theme.secondaryColor;
  const { revalidate } = useRevalidator();
  const footerLogoInputRef = useRef<HTMLInputElement>(null);
  const headerLogoInputRef = useRef<HTMLInputElement>(null);
  const [form, setForm] = useState({
    footerLogoLink: data.footerLogoLink ?? '',
    loginRequired: data.loginRequired,
    primaryColor: theme.primaryColor,
    secondaryColor: theme.secondaryColor,
  });
  const [saving, setSaving] = useState(false);
  const [uploadingFooterLogo, setUploadingFooterLogo] = useState(false);
  const [uploadingHeaderLogo, setUploadingHeaderLogo] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await apiFetch('/api/v1/admin/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          general: { footer_logo_link: form.footerLogoLink, login_required: form.loginRequired },
          theme: { primary_color: form.primaryColor, secondary_color: form.secondaryColor },
        }),
      });
      if (!res.ok) throw new Error();
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      organizationClient.clearCache();
      revalidate();
      onSuccess(t('admin.settingsPage.saveSuccess'));
    } catch {
      onError(t('admin.settingsPage.saveError'));
    } finally {
      setSaving(false);
    }
  };

  const handleFooterLogoUpload = async (file: File) => {
    setUploadingFooterLogo(true);
    const formData = new FormData();
    formData.append('footer_logo_file', file);
    try {
      const res = await apiFetch('/api/v1/admin/settings/footer_logo', {
        method: 'PATCH',
        body: formData,
      });
      if (!res.ok) {
        const body = (await res.json().catch(() => null)) as { errors?: string[] } | null;
        onError(body?.errors?.[0] ?? t('admin.settingsPage.logoUploadError'));
        return;
      }
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      organizationClient.clearCache();
      revalidate();
      onSuccess(t('admin.settingsPage.logoUploaded'));
    } catch {
      onError(t('admin.settingsPage.logoUploadError'));
    } finally {
      setUploadingFooterLogo(false);
    }
  };

  const handleHeaderLogoUpload = async (file: File) => {
    setUploadingHeaderLogo(true);
    const formData = new FormData();
    formData.append('header_logo_file', file);
    try {
      const res = await apiFetch('/api/v1/admin/settings/header_logo', {
        method: 'PATCH',
        body: formData,
      });
      if (!res.ok) {
        const body = (await res.json().catch(() => null)) as { errors?: string[] } | null;
        onError(body?.errors?.[0] ?? t('admin.settingsPage.headerLogoUploadError'));
        return;
      }
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      organizationClient.clearCache();
      revalidate();
      onSuccess(t('admin.settingsPage.headerLogoUploaded'));
    } catch {
      onError(t('admin.settingsPage.headerLogoUploadError'));
    } finally {
      setUploadingHeaderLogo(false);
    }
  };

  return (
    <Paper variant="outlined" sx={{ p: 3, maxWidth: 600 }}>
      <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>
        {t('admin.settingsPage.headerLogo')}
      </Typography>

      <Box sx={{ mb: 3 }}>
        {data.logoUrl && (
          <Box sx={{ mb: 1 }}>
            <img
              src={data.logoUrl}
              alt="Header logo"
              style={{ maxHeight: 60, maxWidth: 200, display: 'block' }}
            />
          </Box>
        )}
        <Button
          component="label"
          variant="outlined"
          size="small"
          startIcon={uploadingHeaderLogo ? <CircularProgress size={14} /> : <CloudUploadIcon />}
          disabled={uploadingHeaderLogo}
        >
          {uploadingHeaderLogo
            ? t('admin.settingsPage.uploading')
            : data.logoUrl
              ? t('admin.settingsPage.replaceHeaderLogo')
              : t('admin.settingsPage.uploadHeaderLogo')}
          <input
            ref={headerLogoInputRef}
            type="file"
            hidden
            accept="image/png,image/jpeg,image/svg+xml"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) void handleHeaderLogoUpload(file);
              e.target.value = '';
            }}
          />
        </Button>
      </Box>

      <Divider sx={{ mb: 3 }} />

      <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>
        {t('admin.settingsPage.footerLogo')}
      </Typography>

      <Box sx={{ mb: 3 }}>
        {data.footerLogoUrl && (
          <Box
            sx={{
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              bgcolor: secondaryColor,
              borderRadius: 1,
              p: 1.5,
              mb: 1,
            }}
          >
            <img
              src={data.footerLogoUrl}
              alt="Footer logo"
              style={{ maxHeight: 60, maxWidth: 200, display: 'block' }}
            />
          </Box>
        )}
        <Box>
          <Button
            component="label"
            variant="outlined"
            size="small"
            startIcon={uploadingFooterLogo ? <CircularProgress size={14} /> : <CloudUploadIcon />}
            disabled={uploadingFooterLogo}
          >
            {uploadingFooterLogo
              ? t('admin.settingsPage.uploading')
              : data.footerLogoUrl
                ? t('admin.settingsPage.replaceLogo')
                : t('admin.settingsPage.uploadLogo')}
            <input
              ref={footerLogoInputRef}
              type="file"
              hidden
              accept="image/png,image/jpeg"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) void handleFooterLogoUpload(file);
                e.target.value = '';
              }}
            />
          </Button>
        </Box>
      </Box>

      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <TextField
          label={t('admin.settingsPage.footerLogoLink')}
          value={form.footerLogoLink}
          onChange={(e) => setForm((f) => ({ ...f, footerLogoLink: e.target.value }))}
          disabled={saving}
          fullWidth
          placeholder="https://"
        />
      </Box>

      <Divider sx={{ my: 3 }} />
      <Box sx={{ mt: 3, display: 'flex', alignItems: 'center' }}>
        <FormControlLabel
          control={
            <Switch
              checked={form.loginRequired}
              onChange={(e) => setForm((f) => ({ ...f, loginRequired: e.target.checked }))}
              disabled={saving}
            />
          }
          label={t('admin.settingsPage.loginRequired')}
        />
      </Box>

      <Divider sx={{ my: 3 }} />

      <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>
        {t('admin.settingsPage.theme.title')}
      </Typography>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <ColorField
          label={t('admin.settingsPage.theme.primaryColor')}
          value={form.primaryColor}
          onChange={(v) => setForm((f) => ({ ...f, primaryColor: v }))}
          disabled={saving}
        />
        <ColorField
          label={t('admin.settingsPage.theme.secondaryColor')}
          value={form.secondaryColor}
          onChange={(v) => setForm((f) => ({ ...f, secondaryColor: v }))}
          disabled={saving}
        />
        <Typography variant="caption" color="text.secondary">
          {t('admin.settingsPage.theme.hint')}
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Button variant="contained" onClick={() => void handleSave()} disabled={saving}>
          {saving ? t('admin.settingsPage.saving') : t('admin.settingsPage.save')}
        </Button>
      </Box>
    </Paper>
  );
}

// ─── Footer Links Section ─────────────────────────────────────────────────────

function FooterLinksSection({
  links,
  languages,
  onSuccess,
  onError,
  queryClient,
}: {
  links: FooterLink[];
  languages: Language[];
  onSuccess: (m: string) => void;
  onError: (m: string) => void;
  queryClient: ReturnType<typeof useQueryClient>;
}) {
  const { t } = useTranslation();
  const [form, setForm] = useState({ label: '', url: '', languageId: '' });
  const [adding, setAdding] = useState(false);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [formError, setFormError] = useState<string | null>(null);

  const handleAdd = async () => {
    setFormError(null);
    if (!form.label.trim() || !form.url.trim()) {
      setFormError(t('admin.settingsPage.footerLinks.validationError'));
      return;
    }
    setAdding(true);
    try {
      const res = await apiFetch('/api/v1/admin/footer_links', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          footer_link: { label: form.label, url: form.url, language_id: form.languageId || null },
        }),
      });
      if (!res.ok) {
        const d = (await res.json()) as { errors?: string[] };
        onError(d.errors?.join(', ') ?? t('admin.settingsPage.footerLinks.addError'));
        return;
      }
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      setForm({ label: '', url: '', languageId: '' });
      onSuccess(t('admin.settingsPage.footerLinks.addSuccess'));
    } catch {
      onError(t('admin.settingsPage.footerLinks.addError'));
    } finally {
      setAdding(false);
    }
  };

  const handleDelete = async (id: number) => {
    setDeletingId(id);
    try {
      const res = await apiFetch(`/api/v1/admin/footer_links/${id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error();
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      onSuccess(t('admin.settingsPage.footerLinks.deleteSuccess'));
    } catch {
      onError(t('admin.settingsPage.footerLinks.deleteError'));
    } finally {
      setDeletingId(null);
    }
  };

  return (
    <Box sx={{ maxWidth: 700 }}>
      <Paper variant="outlined" sx={{ mb: 3 }}>
        <TableContainer>
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>{t('admin.settingsPage.footerLinks.colLabel')}</TableCell>
                <TableCell>{t('admin.settingsPage.footerLinks.colUrl')}</TableCell>
                <TableCell>{t('admin.settingsPage.footerLinks.colLanguage')}</TableCell>
                <TableCell />
              </TableRow>
            </TableHead>
            <TableBody>
              {links.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={4} align="center" sx={{ py: 3, color: 'text.secondary' }}>
                    {t('admin.settingsPage.footerLinks.empty')}
                  </TableCell>
                </TableRow>
              ) : (
                links.map((link) => (
                  <TableRow key={link.id}>
                    <TableCell>{link.label}</TableCell>
                    <TableCell sx={{ maxWidth: 250, wordBreak: 'break-all' }}>{link.url}</TableCell>
                    <TableCell>{link.languageName ?? '—'}</TableCell>
                    <TableCell align="right">
                      <IconButton
                        size="small"
                        onClick={() => void handleDelete(link.id)}
                        disabled={deletingId === link.id}
                        aria-label={t('admin.settingsPage.footerLinks.delete')}
                      >
                        {deletingId === link.id ? (
                          <CircularProgress size={16} />
                        ) : (
                          <DeleteIcon fontSize="small" />
                        )}
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      <Paper variant="outlined" sx={{ p: 3 }}>
        <Typography variant="subtitle2" sx={{ mb: 2 }}>
          {t('admin.settingsPage.footerLinks.addTitle')}
        </Typography>
        {formError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {formError}
          </Alert>
        )}
        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'flex-start' }}>
          <TextField
            label={t('admin.settingsPage.footerLinks.colLabel')}
            value={form.label}
            onChange={(e) => setForm((f) => ({ ...f, label: e.target.value }))}
            size="small"
            sx={{ flex: 1, minWidth: 150 }}
            disabled={adding}
          />
          <TextField
            label={t('admin.settingsPage.footerLinks.colUrl')}
            value={form.url}
            onChange={(e) => setForm((f) => ({ ...f, url: e.target.value }))}
            size="small"
            sx={{ flex: 2, minWidth: 200 }}
            disabled={adding}
            placeholder="https://"
          />
          <FormControl size="small" sx={{ minWidth: 130 }} disabled={adding}>
            <InputLabel>{t('admin.settingsPage.footerLinks.colLanguage')}</InputLabel>
            <Select
              value={form.languageId}
              label={t('admin.settingsPage.footerLinks.colLanguage')}
              onChange={(e) => setForm((f) => ({ ...f, languageId: String(e.target.value) }))}
            >
              <MenuItem value="">
                <em>{t('admin.settingsPage.footerLinks.anyLanguage')}</em>
              </MenuItem>
              {languages.map((l) => (
                <MenuItem key={l.id} value={String(l.id)}>
                  {l.name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          <Button
            variant="contained"
            onClick={() => void handleAdd()}
            disabled={adding}
            size="medium"
            sx={{ mt: 0.5 }}
          >
            {adding
              ? t('admin.settingsPage.footerLinks.adding')
              : t('admin.settingsPage.footerLinks.add')}
          </Button>
        </Box>
      </Paper>
    </Box>
  );
}

// ─── Survey Section ───────────────────────────────────────────────────────────

function SurveySection({
  data,
  onSuccess,
  onError,
  queryClient,
}: {
  data: SurveySettings;
  onSuccess: (m: string) => void;
  onError: (m: string) => void;
  queryClient: ReturnType<typeof useQueryClient>;
}) {
  const { t } = useTranslation();
  const [form, setForm] = useState({
    userSurveyEnabled: data.userSurveyEnabled,
    userSurveyLink: data.userSurveyLink ?? '',
    spanishSurveyLink: data.spanishSurveyLink ?? '',
    enButtonText: data.enButtonText ?? '',
    esButtonText: data.esButtonText ?? '',
  });
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await apiFetch('/api/v1/admin/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          survey: {
            user_survey_enabled: form.userSurveyEnabled,
            user_survey_link: form.userSurveyLink,
            spanish_survey_link: form.spanishSurveyLink,
            enButtonText: form.enButtonText,
            esButtonText: form.esButtonText,
          },
        }),
      });
      if (!res.ok) throw new Error();
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      onSuccess(t('admin.settingsPage.saveSuccess'));
    } catch {
      onError(t('admin.settingsPage.saveError'));
    } finally {
      setSaving(false);
    }
  };

  return (
    <Paper variant="outlined" sx={{ p: 3, maxWidth: 600 }}>
      <FormControlLabel
        control={
          <Switch
            checked={form.userSurveyEnabled}
            onChange={(e) => setForm((f) => ({ ...f, userSurveyEnabled: e.target.checked }))}
            disabled={saving}
          />
        }
        label={t('admin.settingsPage.survey.enabled')}
        sx={{ mb: 2 }}
      />

      {form.userSurveyEnabled && (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <Divider />
          <Typography variant="body2" color="text.secondary" fontWeight={500}>
            {t('admin.settingsPage.survey.surveyLinks')}
          </Typography>
          <TextField
            label={t('admin.settingsPage.survey.enLink')}
            value={form.userSurveyLink}
            onChange={(e) => setForm((f) => ({ ...f, userSurveyLink: e.target.value }))}
            disabled={saving}
            fullWidth
            placeholder="https://"
          />
          <TextField
            label={t('admin.settingsPage.survey.esLink')}
            value={form.spanishSurveyLink}
            onChange={(e) => setForm((f) => ({ ...f, spanishSurveyLink: e.target.value }))}
            disabled={saving}
            fullWidth
            placeholder="https://"
          />
          <Divider />
          <Typography variant="body2" color="text.secondary" fontWeight={500}>
            {t('admin.settingsPage.survey.buttonText')}
          </Typography>
          <TextField
            label={t('admin.settingsPage.survey.enButtonText')}
            value={form.enButtonText}
            onChange={(e) => setForm((f) => ({ ...f, enButtonText: e.target.value }))}
            disabled={saving}
            fullWidth
          />
          <TextField
            label={t('admin.settingsPage.survey.esButtonText')}
            value={form.esButtonText}
            onChange={(e) => setForm((f) => ({ ...f, esButtonText: e.target.value }))}
            disabled={saving}
            fullWidth
          />
        </Box>
      )}

      <Box sx={{ mt: 3 }}>
        <Button variant="contained" onClick={() => void handleSave()} disabled={saving}>
          {saving ? t('admin.settingsPage.saving') : t('admin.settingsPage.save')}
        </Button>
      </Box>
    </Paper>
  );
}

// ─── Branches Section ─────────────────────────────────────────────────────────

function BranchesSection({
  data,
  onSuccess,
  onError,
  queryClient,
}: {
  data: BranchesSettings;
  onSuccess: (m: string) => void;
  onError: (m: string) => void;
  queryClient: ReturnType<typeof useQueryClient>;
}) {
  const { t } = useTranslation();
  const [enabled, setEnabled] = useState(data.enabled);
  const [togglingEnabled, setTogglingEnabled] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editForm, setEditForm] = useState({ name: '', zipcode: '' });
  const [savingId, setSavingId] = useState<number | null>(null);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [addForm, setAddForm] = useState({ name: '', zipcode: '' });
  const [adding, setAdding] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);

  const handleToggleEnabled = async (checked: boolean) => {
    setTogglingEnabled(true);
    try {
      const res = await apiFetch('/api/v1/admin/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ general: { branches: checked } }),
      });
      if (!res.ok) throw new Error();
      setEnabled(checked);
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
    } catch {
      onError(t('admin.settingsPage.saveError'));
    } finally {
      setTogglingEnabled(false);
    }
  };

  const startEdit = (loc: LibraryLocation) => {
    setEditingId(loc.id);
    setEditForm({ name: loc.name, zipcode: String(loc.zipcode ?? '') });
  };

  const cancelEdit = () => setEditingId(null);

  const handleSaveEdit = async (id: number) => {
    setSavingId(id);
    try {
      const res = await apiFetch(`/api/v1/admin/library_locations/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          library_location: { name: editForm.name, zipcode: editForm.zipcode },
        }),
      });
      if (!res.ok) {
        const d = (await res.json()) as { errors?: string[] };
        onError(d.errors?.join(', ') ?? t('admin.settingsPage.branches.saveError'));
        return;
      }
      setEditingId(null);
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      onSuccess(t('admin.settingsPage.branches.saveSuccess'));
    } catch {
      onError(t('admin.settingsPage.branches.saveError'));
    } finally {
      setSavingId(null);
    }
  };

  const handleDelete = async (id: number) => {
    setDeletingId(id);
    try {
      const res = await apiFetch(`/api/v1/admin/library_locations/${id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error();
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      onSuccess(t('admin.settingsPage.branches.deleteSuccess'));
    } catch {
      onError(t('admin.settingsPage.branches.deleteError'));
    } finally {
      setDeletingId(null);
    }
  };

  const handleAdd = async () => {
    setAddError(null);
    if (!addForm.name.trim() || !addForm.zipcode.trim()) {
      setAddError(t('admin.settingsPage.branches.validationError'));
      return;
    }
    setAdding(true);
    try {
      const res = await apiFetch('/api/v1/admin/library_locations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          library_location: { name: addForm.name, zipcode: addForm.zipcode },
        }),
      });
      if (!res.ok) {
        const d = (await res.json()) as { errors?: string[] };
        onError(d.errors?.join(', ') ?? t('admin.settingsPage.branches.addError'));
        return;
      }
      setAddForm({ name: '', zipcode: '' });
      await queryClient.invalidateQueries({ queryKey: ['admin-settings'] });
      onSuccess(t('admin.settingsPage.branches.addSuccess'));
    } catch {
      onError(t('admin.settingsPage.branches.addError'));
    } finally {
      setAdding(false);
    }
  };

  return (
    <Box sx={{ maxWidth: 700 }}>
      <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
        <FormControlLabel
          control={
            <Switch
              checked={enabled}
              onChange={(e) => void handleToggleEnabled(e.target.checked)}
              disabled={togglingEnabled}
            />
          }
          label={t('admin.settingsPage.branches.enabledLabel')}
        />
      </Paper>

      {enabled && (
        <>
          <Paper variant="outlined" sx={{ mb: 3 }}>
            <TableContainer>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>{t('admin.settingsPage.branches.colName')}</TableCell>
                    <TableCell>{t('admin.settingsPage.branches.colZipcode')}</TableCell>
                    <TableCell />
                  </TableRow>
                </TableHead>
                <TableBody>
                  {data.locations.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={3} align="center" sx={{ py: 3, color: 'text.secondary' }}>
                        {t('admin.settingsPage.branches.empty')}
                      </TableCell>
                    </TableRow>
                  ) : (
                    data.locations.map((loc) => (
                      <TableRow key={loc.id}>
                        {editingId === loc.id ? (
                          <>
                            <TableCell>
                              <TextField
                                value={editForm.name}
                                onChange={(e) =>
                                  setEditForm((f) => ({ ...f, name: e.target.value }))
                                }
                                size="small"
                                fullWidth
                                disabled={savingId === loc.id}
                              />
                            </TableCell>
                            <TableCell>
                              <TextField
                                value={editForm.zipcode}
                                onChange={(e) =>
                                  setEditForm((f) => ({ ...f, zipcode: e.target.value }))
                                }
                                size="small"
                                sx={{ width: 120 }}
                                disabled={savingId === loc.id}
                                inputProps={{ inputMode: 'numeric' }}
                              />
                            </TableCell>
                            <TableCell align="right" sx={{ whiteSpace: 'nowrap' }}>
                              <IconButton
                                size="small"
                                onClick={() => void handleSaveEdit(loc.id)}
                                disabled={savingId === loc.id}
                                color="primary"
                                aria-label={t('admin.settingsPage.branches.save')}
                              >
                                {savingId === loc.id ? (
                                  <CircularProgress size={16} />
                                ) : (
                                  <SaveIcon fontSize="small" />
                                )}
                              </IconButton>
                              <IconButton
                                size="small"
                                onClick={cancelEdit}
                                disabled={savingId === loc.id}
                                aria-label={t('admin.settingsPage.branches.cancel')}
                              >
                                <CloseIcon fontSize="small" />
                              </IconButton>
                            </TableCell>
                          </>
                        ) : (
                          <>
                            <TableCell>{loc.name}</TableCell>
                            <TableCell>{loc.zipcode ?? '—'}</TableCell>
                            <TableCell align="right" sx={{ whiteSpace: 'nowrap' }}>
                              <IconButton
                                size="small"
                                onClick={() => startEdit(loc)}
                                aria-label={t('admin.settingsPage.branches.edit')}
                              >
                                <EditIcon fontSize="small" />
                              </IconButton>
                              <IconButton
                                size="small"
                                onClick={() => void handleDelete(loc.id)}
                                disabled={deletingId === loc.id}
                                aria-label={t('admin.settingsPage.branches.delete')}
                              >
                                {deletingId === loc.id ? (
                                  <CircularProgress size={16} />
                                ) : (
                                  <DeleteIcon fontSize="small" />
                                )}
                              </IconButton>
                            </TableCell>
                          </>
                        )}
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>

          <Paper variant="outlined" sx={{ p: 3 }}>
            <Typography variant="subtitle2" sx={{ mb: 2 }}>
              {t('admin.settingsPage.branches.addTitle')}
            </Typography>
            {addError && (
              <Alert severity="error" sx={{ mb: 2 }}>
                {addError}
              </Alert>
            )}
            <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start', flexWrap: 'wrap' }}>
              <TextField
                label={t('admin.settingsPage.branches.colName')}
                value={addForm.name}
                onChange={(e) => setAddForm((f) => ({ ...f, name: e.target.value }))}
                size="small"
                sx={{ flex: 2, minWidth: 200 }}
                disabled={adding}
              />
              <TextField
                label={t('admin.settingsPage.branches.colZipcode')}
                value={addForm.zipcode}
                onChange={(e) => setAddForm((f) => ({ ...f, zipcode: e.target.value }))}
                size="small"
                sx={{ width: 130 }}
                disabled={adding}
                inputProps={{ inputMode: 'numeric' }}
              />
              <Button
                variant="contained"
                onClick={() => void handleAdd()}
                disabled={adding}
                sx={{ mt: 0.5 }}
              >
                {adding
                  ? t('admin.settingsPage.branches.adding')
                  : t('admin.settingsPage.branches.add')}
              </Button>
            </Box>
          </Paper>
        </>
      )}
    </Box>
  );
}
