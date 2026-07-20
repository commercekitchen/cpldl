import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import Autocomplete, { createFilterOptions } from '@mui/material/Autocomplete';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormGroup from '@mui/material/FormGroup';
import FormLabel from '@mui/material/FormLabel';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { apiFetch } from '../../app/api/apiFetch';
import { RichTextEditor } from '../../components/RichTextEditor';
import type { CourseDetail, FormOptions } from './EditCourse';

const PUB_STATUS_OPTIONS = [
  { value: 'D', label: 'Draft' },
  { value: 'P', label: 'Published' },
  { value: 'C', label: 'Coming Soon' },
  { value: 'A', label: 'Archived' },
];

const FORMAT_OPTIONS = [
  { value: 'D', label: 'Desktop' },
  { value: 'M', label: 'Mobile' },
];

const LEVEL_OPTIONS = ['Beginner', 'Intermediate', 'Advanced'];

const ACCESS_LEVEL_OPTIONS = [
  { value: 'everyone', label: 'Everyone' },
  { value: 'authenticated_users', label: 'Authenticated Users' },
];

type CategoryOption = { id: number; name: string };
const categoryFilter = createFilterOptions<CategoryOption>();

function SectionHeader({ children }: { children: React.ReactNode }) {
  return (
    <Typography variant="subtitle1" fontWeight={600} sx={{ mt: 3, mb: 1 }}>
      {children}
    </Typography>
  );
}

interface FormState {
  title: string;
  contributor: string;
  summary: string;
  description: string | null;
  languageId: number | null;
  format: string;
  level: string;
  accessLevel: string;
  pubStatus: string;
  topicIds: number[];
  surveyUrl: string;
  seoPageTitle: string;
  metaDesc: string;
  attCourse: boolean;
}

const DEFAULT_FORM: FormState = {
  title: '',
  contributor: '',
  summary: '',
  description: null,
  languageId: null,
  format: 'D',
  level: 'Beginner',
  accessLevel: 'everyone',
  pubStatus: 'D',
  topicIds: [],
  surveyUrl: '',
  seoPageTitle: '',
  metaDesc: '',
  attCourse: false,
};

export default function AdminNewCourse() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const [options, setOptions] = useState<FormOptions>({ languages: [], categories: [], topics: [] });
  const [optionsLoading, setOptionsLoading] = useState(true);
  const [optionsError, setOptionsError] = useState<string | null>(null);

  const [form, setForm] = useState<FormState>(DEFAULT_FORM);
  const [categoryValue, setCategoryValue] = useState<CategoryOption | string | null>(null);
  const [saving, setSaving] = useState(false);
  const [saveErrors, setSaveErrors] = useState<string[]>([]);

  useEffect(() => {
    let cancelled = false;
    apiFetch('/api/v1/admin/courses/new_form_options')
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<{ options: FormOptions }>;
      })
      .then((data) => {
        if (!cancelled) setOptions(data.options);
      })
      .catch(() => {
        if (!cancelled) setOptionsError(t('admin.newCoursePage.loadError'));
      })
      .finally(() => {
        if (!cancelled) setOptionsLoading(false);
      });
    return () => { cancelled = true; };
  }, [t]);

  const handleChange = <K extends keyof FormState>(field: K, value: FormState[K]) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleTopicToggle = (topicId: number) => {
    setForm((prev) => {
      const ids = prev.topicIds.includes(topicId)
        ? prev.topicIds.filter((id) => id !== topicId)
        : [...prev.topicIds, topicId];
      return { ...prev, topicIds: ids };
    });
  };

  const handleSubmit = async () => {
    setSaving(true);
    setSaveErrors([]);

    const body: Record<string, unknown> = {
      title: form.title,
      contributor: form.contributor || null,
      summary: form.summary || null,
      description: form.description,
      language_id: form.languageId,
      format: form.format || null,
      level: form.level || null,
      access_level: form.accessLevel,
      pub_status: form.pubStatus,
      topic_ids: form.topicIds,
      survey_url: form.surveyUrl || null,
      seo_page_title: form.seoPageTitle || null,
      meta_desc: form.metaDesc || null,
      new_course: form.attCourse,
    };

    if (typeof categoryValue === 'object' && categoryValue !== null) {
      body.category_id = categoryValue.id;
    } else if (typeof categoryValue === 'string' && categoryValue.trim()) {
      body.category_id = null;
      body.category_attributes = { name: categoryValue.trim() };
    }

    try {
      const res = await apiFetch('/api/v1/admin/courses', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ course: body }),
      });

      const data = await res.json() as { course?: CourseDetail; errors?: string[] };

      if (!res.ok) {
        setSaveErrors(data.errors ?? [t('admin.newCoursePage.saveError')]);
        return;
      }

      if (data.course) {
        void queryClient.invalidateQueries({ queryKey: ['courses'] });
        navigate(`/admin/courses/${data.course.id}/edit?tab=lessons`);
      }
    } catch {
      setSaveErrors([t('admin.newCoursePage.saveError')]);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Box sx={{ maxWidth: 800 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate('/admin/courses')}
        variant="text"
        color="inherit"
        sx={{ mb: 2 }}
      >
        {t('admin.editCoursePage.backToCourses')}
      </Button>

      <Typography variant="h4" gutterBottom>
        {t('admin.newCoursePage.title')}
      </Typography>

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

          <SectionHeader>{t('admin.editCoursePage.sectionContent')}</SectionHeader>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label={t('admin.editCoursePage.fieldTitle')}
              value={form.title}
              onChange={(e) => handleChange('title', e.target.value)}
              disabled={saving}
              inputProps={{ maxLength: 50 }}
              fullWidth
              required
            />
            <TextField
              label={t('admin.editCoursePage.fieldContributor')}
              value={form.contributor}
              onChange={(e) => handleChange('contributor', e.target.value)}
              disabled={saving}
              fullWidth
            />
            <TextField
              label={t('admin.editCoursePage.fieldSummary')}
              value={form.summary}
              onChange={(e) => handleChange('summary', e.target.value)}
              disabled={saving}
              inputProps={{ maxLength: 74 }}
              fullWidth
            />
            <RichTextEditor
              label={t('admin.editCoursePage.fieldDescription')}
              value={form.description}
              onChange={(html) => handleChange('description', html)}
              disabled={saving}
            />
          </Box>

          <Divider sx={{ my: 3 }} />

          <SectionHeader>{t('admin.editCoursePage.sectionClassification')}</SectionHeader>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <FormControl fullWidth disabled={saving}>
              <InputLabel>{t('admin.editCoursePage.fieldLanguage')}</InputLabel>
              <Select
                value={form.languageId ?? ''}
                label={t('admin.editCoursePage.fieldLanguage')}
                onChange={(e) => handleChange('languageId', e.target.value as number)}
              >
                {options.languages.map((l) => (
                  <MenuItem key={l.id} value={l.id}>{l.name}</MenuItem>
                ))}
              </Select>
            </FormControl>

            <FormControl fullWidth disabled={saving}>
              <InputLabel>{t('admin.editCoursePage.fieldFormat')}</InputLabel>
              <Select
                value={form.format}
                label={t('admin.editCoursePage.fieldFormat')}
                onChange={(e) => handleChange('format', e.target.value)}
              >
                {FORMAT_OPTIONS.map((o) => (
                  <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
                ))}
              </Select>
            </FormControl>

            <FormControl fullWidth disabled={saving}>
              <InputLabel>{t('admin.editCoursePage.fieldLevel')}</InputLabel>
              <Select
                value={form.level}
                label={t('admin.editCoursePage.fieldLevel')}
                onChange={(e) => handleChange('level', e.target.value)}
              >
                {LEVEL_OPTIONS.map((l) => (
                  <MenuItem key={l} value={l}>{l}</MenuItem>
                ))}
              </Select>
            </FormControl>

            <Autocomplete<CategoryOption, false, false, true>
              freeSolo
              options={options.categories}
              getOptionLabel={(opt) => (typeof opt === 'string' ? opt : opt.name)}
              filterOptions={(opts, params) => {
                const filtered = categoryFilter(opts, params);
                const { inputValue } = params;
                const isExisting = opts.some((o) => o.name === inputValue);
                if (inputValue !== '' && !isExisting) {
                  filtered.push({ id: -1, name: `Add "${inputValue}"` });
                }
                return filtered;
              }}
              value={categoryValue}
              onChange={(_, newVal) => {
                if (typeof newVal === 'string') {
                  setCategoryValue(newVal);
                } else if (newVal && newVal.id === -1) {
                  const raw = newVal.name.replace(/^Add "(.+)"$/, '$1');
                  setCategoryValue(raw);
                } else {
                  setCategoryValue(newVal);
                }
              }}
              disabled={saving}
              renderInput={(params) => (
                <TextField
                  {...params}
                  label={t('admin.editCoursePage.fieldCategory')}
                  helperText={t('admin.editCoursePage.categoryHint')}
                />
              )}
              isOptionEqualToValue={(opt, val) =>
                typeof val === 'string' ? opt.name === val : opt.id === val.id
              }
            />

            <FormControl component="fieldset" disabled={saving}>
              <FormLabel component="legend">{t('admin.editCoursePage.fieldTopics')}</FormLabel>
              <FormGroup row>
                {options.topics.map((topic) => (
                  <FormControlLabel
                    key={topic.id}
                    control={
                      <Checkbox
                        checked={form.topicIds.includes(topic.id)}
                        onChange={() => handleTopicToggle(topic.id)}
                        disabled={saving}
                      />
                    }
                    label={topic.name}
                  />
                ))}
              </FormGroup>
            </FormControl>
          </Box>

          <Divider sx={{ my: 3 }} />

          <SectionHeader>{t('admin.editCoursePage.sectionPublication')}</SectionHeader>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <FormControl fullWidth disabled={saving}>
              <InputLabel>{t('admin.editCoursePage.fieldAccessLevel')}</InputLabel>
              <Select
                value={form.accessLevel}
                label={t('admin.editCoursePage.fieldAccessLevel')}
                onChange={(e) => handleChange('accessLevel', e.target.value)}
              >
                {ACCESS_LEVEL_OPTIONS.map((o) => (
                  <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
                ))}
              </Select>
            </FormControl>

            <FormControl fullWidth disabled={saving}>
              <InputLabel>{t('admin.editCoursePage.fieldPubStatus')}</InputLabel>
              <Select
                value={form.pubStatus}
                label={t('admin.editCoursePage.fieldPubStatus')}
                onChange={(e) => handleChange('pubStatus', e.target.value)}
              >
                {PUB_STATUS_OPTIONS.map((o) => (
                  <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
                ))}
              </Select>
            </FormControl>

            <FormControlLabel
              control={
                <Checkbox
                  checked={form.attCourse}
                  onChange={(e) => handleChange('attCourse', e.target.checked)}
                  disabled={saving}
                />
              }
              label={t('admin.editCoursePage.fieldAttCourse')}
            />

            <TextField
              label={t('admin.editCoursePage.fieldSurveyUrl')}
              value={form.surveyUrl}
              onChange={(e) => handleChange('surveyUrl', e.target.value)}
              disabled={saving}
              fullWidth
              helperText={t('admin.editCoursePage.fieldSurveyUrlHint')}
            />
          </Box>

          <Divider sx={{ my: 3 }} />

          <SectionHeader>{t('admin.editCoursePage.sectionSeo')}</SectionHeader>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label={t('admin.editCoursePage.fieldSeoTitle')}
              value={form.seoPageTitle}
              onChange={(e) => handleChange('seoPageTitle', e.target.value)}
              disabled={saving}
              inputProps={{ maxLength: 90 }}
              fullWidth
            />
            <TextField
              label={t('admin.editCoursePage.fieldMetaDesc')}
              value={form.metaDesc}
              onChange={(e) => handleChange('metaDesc', e.target.value)}
              disabled={saving}
              inputProps={{ maxLength: 156 }}
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
              disabled={saving || !form.title.trim()}
            >
              {saving ? t('admin.newCoursePage.saving') : t('admin.newCoursePage.create')}
            </Button>
            <Button
              variant="outlined"
              onClick={() => navigate('/admin/courses')}
              disabled={saving}
            >
              {t('admin.newCoursePage.cancel')}
            </Button>
          </Box>
        </Paper>
      )}
    </Box>
  );
}
