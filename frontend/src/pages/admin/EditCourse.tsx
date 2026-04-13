import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Skeleton from '@mui/material/Skeleton';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { apiFetch } from '../../app/api/apiFetch';
import { EditCourseDetailsTab } from './editCourse/EditCourseDetailsTab';
import { EditCourseLessonsTab } from './editCourse/EditCourseLessonsTab';

export interface ResourceLink {
  id: number | null;
  label: string;
  url: string;
  _destroy?: boolean;
}

export interface CourseAttachment {
  id: number;
  title: string | null;
  docType: string | null;
  fileDescription: string | null;
  filename: string | null;
  url: string | null;
}

export interface CourseDetail {
  id: number;
  title: string;
  contributor: string | null;
  summary: string | null;
  description: string | null;
  notes: string | null;
  languageId: number | null;
  format: string | null;
  level: string | null;
  accessLevel: string;
  seoPageTitle: string | null;
  metaDesc: string | null;
  pubStatus: string;
  attCourse: boolean;
  surveyUrl: string | null;
  categoryId: number | null;
  category: string | null;
  topicIds: number[];
  imported: boolean;
  topicsEditable: boolean;
  resourceLinks: ResourceLink[];
  attachments: CourseAttachment[];
}

export interface FormOptions {
  languages: { id: number; name: string }[];
  categories: { id: number; name: string }[];
  topics: { id: number; name: string }[];
}

export default function AdminEditCourse() {
  const { courseId } = useParams<{ courseId: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();

  const [course, setCourse] = useState<CourseDetail | null>(null);
  const [options, setOptions] = useState<FormOptions>({ languages: [], categories: [], topics: [] });
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [tab, setTab] = useState(0);

  useEffect(() => {
    if (!courseId) return;
    let cancelled = false;

    apiFetch(`/api/v1/admin/courses/${courseId}`)
      .then((res) => {
        if (!res.ok) throw new Error();
        return res.json() as Promise<{ course: CourseDetail; options: FormOptions }>;
      })
      .then((data) => {
        if (!cancelled) {
          setCourse(data.course);
          setOptions(data.options);
        }
      })
      .catch(() => {
        if (!cancelled) setLoadError(t('admin.editCoursePage.loadError'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [courseId, t]);

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
        {loading ? <Skeleton width={300} /> : (course?.title ?? t('admin.editCoursePage.title'))}
      </Typography>

      {loadError && <Alert severity="error">{loadError}</Alert>}
      {loading && <CircularProgress />}

      {!loading && !loadError && course && (
        <>
          <Tabs value={tab} onChange={(_, v: number) => setTab(v)} sx={{ mb: 3, borderBottom: 1, borderColor: 'divider' }}>
            <Tab label={t('admin.editCoursePage.tabDetails')} />
            <Tab label={t('admin.editCoursePage.tabLessons')} />
          </Tabs>

          {tab === 0 && (
            <EditCourseDetailsTab
              courseId={courseId!}
              initialCourse={course}
              options={options}
              onSaved={(updated: CourseDetail) => setCourse(updated)}
              onOptionsChanged={setOptions}
            />
          )}
          {tab === 1 && (
            <EditCourseLessonsTab courseId={courseId!} />
          )}
        </>
      )}
    </Box>
  );
}
