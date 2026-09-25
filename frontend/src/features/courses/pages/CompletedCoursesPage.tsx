import { useMemo } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Container from '@mui/material/Container';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import { CheckCircle, Download, Schedule } from '@mui/icons-material';
import { usePageMetadata } from '../../../app/metadata/usePageMetadata';
import { useAuth } from '../../../auth/useAuth';
import { useLocale } from '../../../app/locale/LocaleContext';
import { useCoursesListQuery } from '../queries/useCoursesListQuery';
import { CourseList } from '../components/CourseList';
import { formatDurationLong } from '../utils/duration';
import { formatCompletedDate } from '../utils/formatCompletedDate';
import { downloadCsv } from '../utils/csv';
import { listLessons } from '../../lessons/api/lessonsApi';

export function CompletedCoursesPage() {
  const { t } = useTranslation();
  const { status } = useAuth();
  const { locale } = useLocale();
  const navigate = useNavigate();
  usePageMetadata({ title: t('courses.completedCoursesPageTitle') });

  const { data: courses = [], isLoading, error } = useCoursesListQuery({ scope: 'completed' });

  const totalDurationSeconds = useMemo(
    () => courses.reduce((sum, course) => sum + (Number(course.totalDuration) || 0), 0),
    [courses],
  );

  const handleDownloadCsv = () => {
    const rows = [
      [t('courses.csvCourseColumn'), t('courses.csvCompletedColumn'), t('courses.csvTimeSpentColumn')],
      ...courses.map((course) => [
        course.title,
        course.completedAt ? formatCompletedDate(course.completedAt, locale) : '',
        formatDurationLong(Number(course.totalDuration) || 0, t),
      ]),
    ];
    downloadCsv('completed-courses.csv', rows);
  };

  const startCourse = async (courseId: string) => {
    try {
      const lessons = await listLessons({ courseId }, {});
      const firstLesson = [...lessons].sort((a, b) => {
        if (a.lessonOrder !== b.lessonOrder) return a.lessonOrder - b.lessonOrder;
        return a.id.localeCompare(b.id);
      })[0];
      if (firstLesson) {
        navigate(`/lessons/${firstLesson.id}`);
        return;
      }
    } catch {
      // Fall through to course detail page.
    }

    navigate(`/courses/${courseId}`);
  };

  if (status === 'unauthenticated') return <Navigate to="/login" replace />;
  if (isLoading) return <CircularProgress />;
  if (error) return <Alert severity="error">{error.message}</Alert>;

  return (
    <Container sx={{ py: 3 }}>
      <Box
        sx={{
          display: 'flex',
          alignItems: { xs: 'flex-start', sm: 'center' },
          flexDirection: { xs: 'column', sm: 'row' },
          justifyContent: 'space-between',
          gap: 1.5,
          mb: 3,
        }}
      >
        <Typography variant="h4" component="h1">
          {t('courses.completedCoursesPageTitle')}
        </Typography>
        {courses.length > 0 && (
          <Button variant="outlined" size="small" startIcon={<Download />} onClick={handleDownloadCsv}>
            {t('courses.downloadCsv')}
          </Button>
        )}
      </Box>

      <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mb: 4 }}>
        <Paper
          variant="outlined"
          sx={{ p: 2, flex: '1 1 200px', display: 'flex', alignItems: 'center', gap: 1.5 }}
        >
          <CheckCircle color="primary" />
          <Box>
            <Typography variant="h6">{courses.length}</Typography>
            <Typography variant="body2" color="text.secondary">
              {t('courses.totalCoursesCompleted')}
            </Typography>
          </Box>
        </Paper>
        <Paper
          variant="outlined"
          sx={{ p: 2, flex: '1 1 200px', display: 'flex', alignItems: 'center', gap: 1.5 }}
        >
          <Schedule color="primary" />
          <Box>
            <Typography variant="h6">{formatDurationLong(totalDurationSeconds, t)}</Typography>
            <Typography variant="body2" color="text.secondary">
              {t('courses.totalTimeSpent')}
            </Typography>
          </Box>
        </Paper>
      </Box>

      {courses.length === 0 ? (
        <Typography variant="body1" color="text.secondary">
          {t('courses.noCompletedCourses')}
        </Typography>
      ) : (
        <CourseList
          courses={courses}
          onViewLessons={(id) => navigate(`/courses/${id}`)}
          onStartCourse={(id) => {
            void startCourse(id);
          }}
        />
      )}
    </Container>
  );
}
