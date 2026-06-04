import { useEffect, useRef, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import FormControlLabel from '@mui/material/FormControlLabel';
import Paper from '@mui/material/Paper';
import Skeleton from '@mui/material/Skeleton';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import HourglassEmptyIcon from '@mui/icons-material/HourglassEmpty';
import { apiFetch } from '../../app/api/apiFetch';

type UnzipStatus = 'queued' | 'processing' | 'complete' | 'failed' | null;

interface LessonDetail {
  id: number;
  title: string;
  summary: string | null;
  duration: number | null;
  lessonOrder: number;
  isAssessment: boolean;
  seoPageTitle: string | null;
  metaDesc: string | null;
  storylineFilename: string | null;
  storylineUnzipStatus: UnzipStatus;
  storylineUnzipError: string | null;
  storylineTracked: boolean;
}

type StorylineStatus = Pick<
  LessonDetail,
  'storylineFilename' | 'storylineUnzipStatus' | 'storylineUnzipError' | 'storylineTracked'
>;

const POLL_STATUSES: UnzipStatus[] = ['queued', 'processing'];
const POLL_INTERVAL_MS = 3000;

function StorylineStatusBadge({ lesson }: { lesson: LessonDetail }) {
  const { t } = useTranslation();

  if (!lesson.storylineFilename) return null;

  if (!lesson.storylineTracked) {
    return (
      <Chip
        icon={<CheckCircleIcon />}
        label={t('admin.editLessonPage.storyline.statusComplete')}
        color="success"
        size="small"
        variant="outlined"
      />
    );
  }

  switch (lesson.storylineUnzipStatus) {
    case 'queued':
    case 'processing':
      return (
        <Chip
          icon={<HourglassEmptyIcon />}
          label={t('admin.editLessonPage.storyline.statusProcessing')}
          color="warning"
          size="small"
          variant="outlined"
        />
      );
    case 'complete':
      return (
        <Chip
          icon={<CheckCircleIcon />}
          label={t('admin.editLessonPage.storyline.statusComplete')}
          color="success"
          size="small"
          variant="outlined"
        />
      );
    case 'failed':
      return (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, flexWrap: 'wrap' }}>
          <Chip
            icon={<ErrorIcon />}
            label={t('admin.editLessonPage.storyline.statusFailed')}
            color="error"
            size="small"
            variant="outlined"
          />
          {lesson.storylineUnzipError && (
            <Typography variant="caption" color="error">
              {lesson.storylineUnzipError}
            </Typography>
          )}
        </Box>
      );
    default:
      return null;
  }
}

export default function AdminEditLesson() {
  const { courseId, lessonId } = useParams<{ courseId: string; lessonId: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [lesson, setLesson] = useState<LessonDetail | null>(null);
  const [form, setForm] = useState<LessonDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [saveErrors, setSaveErrors] = useState<string[]>([]);
  const [uploadingStoryline, setUploadingStoryline] = useState(false);
  const [storylineUploadError, setStorylineUploadError] = useState<string | null>(null);

  // Load lesson on mount
  useEffect(() => {
    if (!courseId || !lessonId) return;
    let cancelled = false;

    apiFetch(`/api/v1/admin/courses/${courseId}/lessons/${lessonId}`)
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<LessonDetail>;
      })
      .then((data) => {
        if (cancelled) return;
        setLesson(data);
        setForm(data);
      })
      .catch(() => {
        if (!cancelled) setLoadError(t('admin.editLessonPage.loadError'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [courseId, lessonId, t]);

  // Stable ref so the interval always sees the latest lesson without being in the dep array
  const lessonRef = useRef<LessonDetail | null>(null);
  lessonRef.current = lesson;

  // Poll while storyline is processing — interval is stable for the lifetime of the page
  useEffect(() => {
    if (!courseId || !lessonId) return;

    const timer = setInterval(async () => {
      const current = lessonRef.current;
      if (!current || !POLL_STATUSES.includes(current.storylineUnzipStatus)) return;

      try {
        const res = await apiFetch(
          `/api/v1/admin/courses/${courseId}/lessons/${lessonId}/storyline_status`,
        );
        if (!res.ok) return;
        const data = await res.json() as StorylineStatus;
        setLesson((prev) => (prev ? { ...prev, ...data } : prev));
      } catch { /* ignore polling errors */ }
    }, POLL_INTERVAL_MS);

    return () => clearInterval(timer);
  }, [courseId, lessonId]);

  const handleChange = <K extends keyof LessonDetail>(field: K, value: LessonDetail[K]) => {
    setForm((prev) => (prev ? { ...prev, [field]: value } : prev));
  };

  const handleSave = async () => {
    if (!form || !courseId || !lessonId) return;
    setSaving(true);
    setSaveErrors([]);

    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}/lessons/${lessonId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          lesson: {
            title: form.title,
            summary: form.summary,
            duration: form.duration,
            seo_page_title: form.seoPageTitle,
            meta_desc: form.metaDesc,
            is_assessment: form.isAssessment,
          },
        }),
      });

      const data = await res.json() as LessonDetail & { errors?: string[] };

      if (!res.ok) {
        setSaveErrors(data.errors ?? [t('admin.editLessonPage.saveError')]);
        return;
      }

      navigate(`/admin/courses/${courseId}/edit?tab=lessons`);
    } catch {
      setSaveErrors([t('admin.editLessonPage.saveError')]);
    } finally {
      setSaving(false);
    }
  };

  const handleStorylineUpload = async (file: File) => {
    if (!courseId || !lessonId) return;
    setUploadingStoryline(true);
    setStorylineUploadError(null);

    const formData = new FormData();
    formData.append('lesson[story_line_archive]', file);

    try {
      const res = await apiFetch(`/api/v1/admin/courses/${courseId}/lessons/${lessonId}`, {
        method: 'PATCH',
        body: formData,
      });

      const data = await res.json() as LessonDetail & { errors?: string[] };

      if (!res.ok) {
        setStorylineUploadError(
          data.errors?.join(', ') ?? t('admin.editLessonPage.storyline.uploadError'),
        );
        return;
      }

      setLesson(data);
      setForm(data);
    } catch {
      setStorylineUploadError(t('admin.editLessonPage.storyline.uploadError'));
    } finally {
      setUploadingStoryline(false);
    }
  };

  return (
    <Box sx={{ maxWidth: 800 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate(`/admin/courses/${courseId}/edit?tab=lessons`)}
        variant="text"
        color="inherit"
        sx={{ mb: 2 }}
      >
        {t('admin.editLessonPage.backToCourse')}
      </Button>

      <Typography variant="h4" gutterBottom>
        {loading ? <Skeleton width={300} /> : (lesson?.title ?? t('admin.editLessonPage.title'))}
      </Typography>

      {loadError && <Alert severity="error">{loadError}</Alert>}
      {loading && <CircularProgress />}

      {!loading && !loadError && form && lesson && (
        <Paper variant="outlined" sx={{ p: 3 }}>
          {saveErrors.length > 0 && (
            <Alert severity="error" sx={{ mb: 2 }}>
              <ul style={{ margin: 0, paddingLeft: 20 }}>
                {saveErrors.map((e, i) => <li key={i}>{e}</li>)}
              </ul>
            </Alert>
          )}

          {/* Basic fields */}
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label={t('admin.editLessonPage.fieldTitle')}
              value={form.title ?? ''}
              onChange={(e) => handleChange('title', e.target.value)}
              disabled={saving}
              inputProps={{ maxLength: 100 }}
              fullWidth
            />
            <TextField
              label={t('admin.editLessonPage.fieldSummary')}
              value={form.summary ?? ''}
              onChange={(e) => handleChange('summary', e.target.value)}
              disabled={saving}
              inputProps={{ maxLength: 255 }}
              multiline
              minRows={2}
              fullWidth
            />
            <TextField
              label={t('admin.editLessonPage.fieldDuration')}
              type="number"
              value={form.duration ?? ''}
              onChange={(e) => handleChange('duration', e.target.value ? Number(e.target.value) : null)}
              disabled={saving}
              inputProps={{ min: 1 }}
              sx={{ maxWidth: 220 }}
            />
            <FormControlLabel
              control={
                <Checkbox
                  checked={form.isAssessment ?? false}
                  onChange={(e) => handleChange('isAssessment', e.target.checked)}
                  disabled={saving}
                />
              }
              label={t('admin.editLessonPage.fieldAssessment')}
            />
          </Box>

          <Divider sx={{ my: 3 }} />

          {/* Storyline upload */}
          <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 1 }}>
            {t('admin.editLessonPage.storyline.label')}
          </Typography>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {lesson.storylineFilename && (
              <Typography variant="body2" color="text.secondary">
                {t('admin.editLessonPage.storyline.currentFile')}:{' '}
                <strong>{lesson.storylineFilename}</strong>
              </Typography>
            )}

            <StorylineStatusBadge lesson={lesson} />

            {storylineUploadError && (
              <Alert severity="error" sx={{ mt: 0.5 }}>{storylineUploadError}</Alert>
            )}

            <Box sx={{ mt: 1 }}>
              <Button
                component="label"
                variant="outlined"
                startIcon={
                  uploadingStoryline
                    ? <CircularProgress size={16} />
                    : <CloudUploadIcon />
                }
                disabled={uploadingStoryline}
                size="small"
              >
                {uploadingStoryline
                  ? t('admin.editLessonPage.storyline.uploading')
                  : lesson.storylineFilename
                    ? t('admin.editLessonPage.storyline.replace')
                    : t('admin.editLessonPage.storyline.upload')}
                <input
                  ref={fileInputRef}
                  type="file"
                  hidden
                  accept=".zip,application/zip,application/x-zip"
                  onChange={(e) => {
                    const file = e.target.files?.[0];
                    if (file) void handleStorylineUpload(file);
                    e.target.value = '';
                  }}
                />
              </Button>
            </Box>
          </Box>

          <Divider sx={{ my: 3 }} />

          {/* SEO */}
          <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 2 }}>
            SEO
          </Typography>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label={t('admin.editLessonPage.fieldSeoTitle')}
              value={form.seoPageTitle ?? ''}
              onChange={(e) => handleChange('seoPageTitle', e.target.value)}
              disabled={saving}
              inputProps={{ maxLength: 90 }}
              fullWidth
            />
            <TextField
              label={t('admin.editLessonPage.fieldMetaDesc')}
              value={form.metaDesc ?? ''}
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
              onClick={() => void handleSave()}
              disabled={saving}
            >
              {saving ? t('admin.editLessonPage.saving') : t('admin.editLessonPage.save')}
            </Button>
            <Button
              variant="outlined"
              onClick={() => form && setForm(lesson)}
              disabled={saving}
            >
              {t('admin.editLessonPage.discard')}
            </Button>
          </Box>
        </Paper>
      )}

    </Box>
  );
}
