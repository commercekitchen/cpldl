import { useRef, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import Autocomplete, { createFilterOptions } from '@mui/material/Autocomplete';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormGroup from '@mui/material/FormGroup';
import FormLabel from '@mui/material/FormLabel';
import IconButton from '@mui/material/IconButton';
import InputLabel from '@mui/material/InputLabel';
import Link from '@mui/material/Link';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Snackbar from '@mui/material/Snackbar';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import AttachFileIcon from '@mui/icons-material/AttachFile';
import DeleteIcon from '@mui/icons-material/Delete';
import { apiFetch } from '../../../app/api/apiFetch';
import { RichTextEditor } from '../../../components/RichTextEditor';
import type { CourseAttachment, CourseDetail, FormOptions, ResourceLink } from '../EditCourse';

interface Props {
  courseId: string;
  initialCourse: CourseDetail;
  options: FormOptions;
  onSaved: (updated: CourseDetail) => void;
  onOptionsChanged: (options: FormOptions) => void;
}

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

function initCategoryValue(course: CourseDetail, categories: CategoryOption[]): CategoryOption | null {
  if (!course.categoryId) return null;
  return categories.find((c) => c.id === course.categoryId) ?? null;
}

function SectionHeader({ children }: { children: React.ReactNode }) {
  return (
    <Typography variant="subtitle1" fontWeight={600} sx={{ mt: 3, mb: 1 }}>
      {children}
    </Typography>
  );
}

function AttachmentSection({
  courseId,
  docType,
  label,
  attachments,
  onAdd,
  onRemove,
}: {
  courseId: string;
  docType: string;
  label: string;
  attachments: CourseAttachment[];
  onAdd: (a: CourseAttachment) => void;
  onRemove: (id: number) => void;
}) {
  const { t } = useTranslation();
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleUpload = async (file: File) => {
    setUploading(true);
    setError(null);
    const formData = new FormData();
    formData.append('attachment[document_file]', file);
    formData.append('attachment[doc_type]', docType);

    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}/attachments`, {
        method: 'POST',
        body: formData,
      });
      const data = await res.json() as CourseAttachment & { errors?: string[] };
      if (!res.ok) {
        setError(data.errors?.join(', ') ?? t('admin.editCoursePage.attachments.uploadError'));
        return;
      }
      onAdd(data);
    } catch {
      setError(t('admin.editCoursePage.attachments.uploadError'));
    } finally {
      setUploading(false);
    }
  };

  const handleDelete = async (id: number) => {
    setError(null);
    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}/attachments/${id}`, {
        method: 'DELETE',
      });
      if (!res.ok) {
        setError(t('admin.editCoursePage.attachments.deleteError'));
        return;
      }
      onRemove(id);
    } catch {
      setError(t('admin.editCoursePage.attachments.deleteError'));
    }
  };

  return (
    <Box>
      <Typography variant="body2" fontWeight={500} sx={{ mb: 0.5 }}>
        {label}
      </Typography>
      {error && <Alert severity="error" sx={{ mb: 1 }}>{error}</Alert>}
      {attachments.length === 0 ? (
        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
          {t('admin.editCoursePage.attachments.empty')}
        </Typography>
      ) : (
        <List dense disablePadding sx={{ mb: 1 }}>
          {attachments.map((a) => (
            <ListItem
              key={a.id}
              disableGutters
              secondaryAction={
                <IconButton
                  edge="end"
                  size="small"
                  aria-label={t('admin.editCoursePage.attachments.deleteLabel')}
                  onClick={() => void handleDelete(a.id)}
                >
                  <DeleteIcon fontSize="small" />
                </IconButton>
              }
            >
              <ListItemText
                primary={
                  a.url ? (
                    <Link href={a.url} target="_blank" rel="noopener" variant="body2">
                      {a.filename ?? a.title ?? a.url}
                    </Link>
                  ) : (
                    <Typography variant="body2">{a.filename ?? a.title}</Typography>
                  )
                }
              />
            </ListItem>
          ))}
        </List>
      )}
      <Button
        component="label"
        size="small"
        variant="outlined"
        startIcon={<AttachFileIcon />}
        disabled={uploading}
      >
        {uploading
          ? t('admin.editCoursePage.attachments.uploading')
          : t('admin.editCoursePage.attachments.upload')}
        <input
          ref={fileInputRef}
          type="file"
          hidden
          accept=".pdf,.txt,.xls,.xlsx,.ppt,.pptx,.doc,.docx"
          onChange={(e) => {
            const file = e.target.files?.[0];
            if (file) void handleUpload(file);
            e.target.value = '';
          }}
        />
      </Button>
    </Box>
  );
}

export function EditCourseDetailsTab({ courseId, initialCourse, options, onSaved, onOptionsChanged }: Props) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  const [form, setForm] = useState<CourseDetail>(initialCourse);
  const [categoryValue, setCategoryValue] = useState<CategoryOption | string | null>(() =>
    initCategoryValue(initialCourse, options.categories),
  );
  const [attachments, setAttachments] = useState<CourseAttachment[]>(initialCourse.attachments ?? []);
  const [addingLink, setAddingLink] = useState(false);
  const [newLinkLabel, setNewLinkLabel] = useState('');
  const [newLinkUrl, setNewLinkUrl] = useState('');
  const [saving, setSaving] = useState(false);
  const [saveErrors, setSaveErrors] = useState<string[]>([]);
  const [saveSuccess, setSaveSuccess] = useState(false);

  const handleChange = <K extends keyof CourseDetail>(field: K, value: CourseDetail[K]) => {
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

  const handleAddLink = () => {
    if (!newLinkLabel.trim() || !newLinkUrl.trim()) return;
    const link: ResourceLink = { id: null, label: newLinkLabel.trim(), url: newLinkUrl.trim() };
    setForm((prev) => ({ ...prev, resourceLinks: [...prev.resourceLinks, link] }));
    setNewLinkLabel('');
    setNewLinkUrl('');
    setAddingLink(false);
  };

  const handleRemoveLink = (index: number) => {
    setForm((prev) => {
      const updated = prev.resourceLinks.map((rl, i) => {
        if (i !== index) return rl;
        return rl.id != null ? { ...rl, _destroy: true } : null;
      }).filter(Boolean) as ResourceLink[];
      return { ...prev, resourceLinks: updated };
    });
  };

  const handleDiscard = () => {
    setForm(initialCourse);
    setCategoryValue(initCategoryValue(initialCourse, options.categories));
    setAttachments(initialCourse.attachments ?? []);
  };

  const handleSubmit = async () => {
    setSaving(true);
    setSaveErrors([]);

    const body: Record<string, unknown> = {
      access_level: form.accessLevel,
      pub_status: form.pubStatus,
      notes: form.notes,
      survey_url: form.surveyUrl,
      topic_ids: form.topicIds,
      resource_links_attributes: form.resourceLinks.map((rl) => {
        const attr: Record<string, unknown> = { label: rl.label, url: rl.url };
        if (rl.id != null) attr.id = rl.id;
        if (rl._destroy) attr._destroy = '1';
        return attr;
      }),
    };

    if (typeof categoryValue === 'object' && categoryValue !== null) {
      body.category_id = categoryValue.id;
    } else if (typeof categoryValue === 'string' && categoryValue.trim()) {
      body.category_id = null;
      body.category_attributes = { name: categoryValue.trim() };
    } else {
      body.category_id = null;
    }

    if (!initialCourse.imported) {
      Object.assign(body, {
        title: form.title,
        contributor: form.contributor,
        summary: form.summary,
        description: form.description,
        language_id: form.languageId,
        format: form.format,
        level: form.level,
        seo_page_title: form.seoPageTitle,
        meta_desc: form.metaDesc,
        new_course: form.attCourse,
      });
    }

    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ course: body }),
      });

      const data = await res.json() as { course?: CourseDetail; options?: FormOptions; errors?: string[] };

      if (!res.ok) {
        setSaveErrors(data.errors ?? [t('admin.editCoursePage.saveError')]);
        return;
      }

      if (data.course) {
        setForm(data.course);
        setAttachments(data.course.attachments ?? []);
        onSaved(data.course);

        const newCat = data.course.categoryId
          ? { id: data.course.categoryId, name: data.course.category ?? '' }
          : null;
        setCategoryValue(newCat);
      }

      if (data.options) {
        onOptionsChanged(data.options);
      }

      setSaveSuccess(true);
      void queryClient.invalidateQueries({ queryKey: ['courses'] });
      void queryClient.invalidateQueries({ queryKey: ['course', courseId] });
      void queryClient.invalidateQueries({ queryKey: ['lessons'] });
    } catch {
      setSaveErrors([t('admin.editCoursePage.saveError')]);
    } finally {
      setSaving(false);
    }
  };

  const dis = (importedDisabled: boolean) =>
    saving || (initialCourse.imported && importedDisabled);

  const visibleLinks = form.resourceLinks.filter((rl) => !rl._destroy);
  const textCopies = attachments.filter((a) => a.docType === 'text-copy');
  const additionalResources = attachments.filter((a) => a.docType === 'additional-resource');

  return (
    <Paper variant="outlined" sx={{ p: 3 }}>
      {initialCourse.imported && (
        <Alert severity="info" sx={{ mb: 2 }}>
          {t('admin.editCoursePage.importedNotice')}
        </Alert>
      )}

      {saveErrors.length > 0 && (
        <Alert severity="error" sx={{ mb: 2 }}>
          <ul style={{ margin: 0, paddingLeft: 20 }}>
            {saveErrors.map((e, i) => <li key={i}>{e}</li>)}
          </ul>
        </Alert>
      )}

      {/* Course Content */}
      <SectionHeader>{t('admin.editCoursePage.sectionContent')}</SectionHeader>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <TextField
          label={t('admin.editCoursePage.fieldTitle')}
          value={form.title ?? ''}
          onChange={(e) => handleChange('title', e.target.value)}
          disabled={dis(true)}
          inputProps={{ maxLength: 50 }}
          fullWidth
        />
        <TextField
          label={t('admin.editCoursePage.fieldContributor')}
          value={form.contributor ?? ''}
          onChange={(e) => handleChange('contributor', e.target.value)}
          disabled={dis(true)}
          fullWidth
        />
        <TextField
          label={t('admin.editCoursePage.fieldSummary')}
          value={form.summary ?? ''}
          onChange={(e) => handleChange('summary', e.target.value)}
          disabled={dis(true)}
          inputProps={{ maxLength: 74 }}
          fullWidth
        />
        <RichTextEditor
          label={t('admin.editCoursePage.fieldDescription')}
          value={form.description}
          onChange={(html) => handleChange('description', html)}
          disabled={dis(true)}
        />
      </Box>

      <Divider sx={{ my: 3 }} />

      {/* Content for Further Learning */}
      <SectionHeader>{t('admin.editCoursePage.sectionFurtherLearning')}</SectionHeader>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
        <RichTextEditor
          label={t('admin.editCoursePage.fieldNotes')}
          value={form.notes}
          onChange={(html) => handleChange('notes', html)}
          disabled={saving}
          helperText={t('admin.editCoursePage.fieldNotesHint')}
        />

        <AttachmentSection
          courseId={courseId}
          docType="text-copy"
          label={t('admin.editCoursePage.attachments.textCopies')}
          attachments={textCopies}
          onAdd={(a) => setAttachments((prev) => [...prev, a])}
          onRemove={(id) => setAttachments((prev) => prev.filter((a) => a.id !== id))}
        />

        {/* External Resource Links */}
        <Box>
          <Typography variant="body2" fontWeight={500} sx={{ mb: 0.5 }}>
            {t('admin.editCoursePage.resourceLinks.title')}
          </Typography>
          {visibleLinks.length === 0 ? (
            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
              {t('admin.editCoursePage.resourceLinks.empty')}
            </Typography>
          ) : (
            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 1 }}>
              {visibleLinks.map((rl, index) => (
                <Chip
                  key={index}
                  label={rl.label}
                  component="a"
                  href={rl.url}
                  target="_blank"
                  rel="noopener"
                  clickable
                  onDelete={() => handleRemoveLink(form.resourceLinks.indexOf(rl))}
                  deleteIcon={
                    <DeleteIcon aria-label={t('admin.editCoursePage.resourceLinks.deleteLabel')} />
                  }
                  size="small"
                />
              ))}
            </Box>
          )}
          {addingLink ? (
            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', alignItems: 'flex-start' }}>
              <TextField
                size="small"
                label={t('admin.editCoursePage.resourceLinks.labelPlaceholder')}
                value={newLinkLabel}
                onChange={(e) => setNewLinkLabel(e.target.value)}
                sx={{ flex: 1, minWidth: 140 }}
              />
              <TextField
                size="small"
                label={t('admin.editCoursePage.resourceLinks.urlPlaceholder')}
                value={newLinkUrl}
                onChange={(e) => setNewLinkUrl(e.target.value)}
                sx={{ flex: 2, minWidth: 200 }}
              />
              <Button size="small" variant="contained" onClick={handleAddLink}>
                {t('admin.editCoursePage.resourceLinks.add')}
              </Button>
              <Button size="small" onClick={() => { setAddingLink(false); setNewLinkLabel(''); setNewLinkUrl(''); }}>
                {t('admin.editCoursePage.resourceLinks.cancel')}
              </Button>
            </Box>
          ) : (
            <Button
              size="small"
              startIcon={<AddIcon />}
              onClick={() => setAddingLink(true)}
            >
              {t('admin.editCoursePage.resourceLinks.addLink')}
            </Button>
          )}
        </Box>

        <AttachmentSection
          courseId={courseId}
          docType="additional-resource"
          label={t('admin.editCoursePage.attachments.additionalResources')}
          attachments={additionalResources}
          onAdd={(a) => setAttachments((prev) => [...prev, a])}
          onRemove={(id) => setAttachments((prev) => prev.filter((a) => a.id !== id))}
        />
      </Box>

      <Divider sx={{ my: 3 }} />

      {/* Classification */}
      <SectionHeader>{t('admin.editCoursePage.sectionClassification')}</SectionHeader>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <FormControl fullWidth disabled={dis(true)}>
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

        <FormControl fullWidth disabled={dis(true)}>
          <InputLabel>{t('admin.editCoursePage.fieldFormat')}</InputLabel>
          <Select
            value={form.format ?? ''}
            label={t('admin.editCoursePage.fieldFormat')}
            onChange={(e) => handleChange('format', e.target.value)}
          >
            {FORMAT_OPTIONS.map((o) => (
              <MenuItem key={o.value} value={o.value}>{o.label}</MenuItem>
            ))}
          </Select>
        </FormControl>

        <FormControl fullWidth disabled={dis(true)}>
          <InputLabel>{t('admin.editCoursePage.fieldLevel')}</InputLabel>
          <Select
            value={form.level ?? ''}
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
              // Strip the 'Add "..."' prefix to get just the name
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

        <FormControl component="fieldset" disabled={!form.topicsEditable || saving}>
          <FormLabel component="legend">{t('admin.editCoursePage.fieldTopics')}</FormLabel>
          <FormGroup row>
            {options.topics.map((topic) => (
              <FormControlLabel
                key={topic.id}
                control={
                  <Checkbox
                    checked={form.topicIds.includes(topic.id)}
                    onChange={() => handleTopicToggle(topic.id)}
                    disabled={!form.topicsEditable || saving}
                  />
                }
                label={topic.name}
              />
            ))}
          </FormGroup>
        </FormControl>
      </Box>

      <Divider sx={{ my: 3 }} />

      {/* Access & Publication */}
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
              disabled={dis(true)}
            />
          }
          label={t('admin.editCoursePage.fieldAttCourse')}
        />

        <TextField
          label={t('admin.editCoursePage.fieldSurveyUrl')}
          value={form.surveyUrl ?? ''}
          onChange={(e) => handleChange('surveyUrl', e.target.value)}
          disabled={saving}
          fullWidth
          helperText={t('admin.editCoursePage.fieldSurveyUrlHint')}
        />
      </Box>

      <Divider sx={{ my: 3 }} />

      {/* SEO */}
      <SectionHeader>{t('admin.editCoursePage.sectionSeo')}</SectionHeader>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        <TextField
          label={t('admin.editCoursePage.fieldSeoTitle')}
          value={form.seoPageTitle ?? ''}
          onChange={(e) => handleChange('seoPageTitle', e.target.value)}
          disabled={dis(true)}
          inputProps={{ maxLength: 90 }}
          fullWidth
        />
        <TextField
          label={t('admin.editCoursePage.fieldMetaDesc')}
          value={form.metaDesc ?? ''}
          onChange={(e) => handleChange('metaDesc', e.target.value)}
          disabled={dis(true)}
          inputProps={{ maxLength: 156 }}
          multiline
          minRows={2}
          fullWidth
        />
      </Box>

      <Divider sx={{ my: 3 }} />

      <Box sx={{ display: 'flex', gap: 2 }}>
        <Button variant="contained" onClick={() => void handleSubmit()} disabled={saving}>
          {saving ? t('admin.editCoursePage.saving') : t('admin.editCoursePage.save')}
        </Button>
        <Button variant="outlined" onClick={handleDiscard} disabled={saving}>
          {t('admin.editCoursePage.discard')}
        </Button>
      </Box>

      <Snackbar
        open={saveSuccess}
        autoHideDuration={4000}
        onClose={() => setSaveSuccess(false)}
        message={t('admin.editCoursePage.saveSuccess')}
      />
    </Paper>
  );
}
