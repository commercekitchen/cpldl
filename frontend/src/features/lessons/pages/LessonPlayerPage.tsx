import { useCallback, useRef, useState } from 'react';
import { useNavigate, useParams, Link as RouterLink } from 'react-router-dom'; // or your router
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';
import Link from '@mui/material/Link';
import { ArrowBack } from '@mui/icons-material';
import { StorylinePlayer } from '../components/StorylinePlayer';
import { useLessonCompletionListener } from '../hooks/useLessonCompletionListener';
import { completeLesson, listLessons } from '../api/lessonsApi';
import { usePageMetadata } from '../../../app/metadata/usePageMetadata';
import type { Lesson } from '../types';
import { useLessonQuery } from '../queries/lessonQuery';

function buildLessonTitle(lesson: Lesson) {
  return lesson.seoPageTitle?.trim() || lesson.title.trim() || 'Lesson';
}

function buildLessonDescription(lesson: Lesson) {
  return lesson.seoMetaDescription?.trim() || lesson.summary?.trim() || undefined;
}

export function LessonPlayerPage() {
  const { lessonId = '' } = useParams();
  const { data: lesson, isLoading, error: loadError } = useLessonQuery(lessonId);

  const navigate = useNavigate();
  const iframeRef = useRef<HTMLIFrameElement | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [completing, setCompleting] = useState(false);

  usePageMetadata(
    lesson
      ? {
          title: buildLessonTitle(lesson),
          description: buildLessonDescription(lesson),
        }
      : { title: 'Lesson' },
  );

  const onCompleted = useCallback(async () => {
    if (!lesson) return;

    try {
      setCompleting(true);
      const resp = await completeLesson({
        lessonId: lesson.id,
        courseId: lesson.courseId,
      });

      if (resp.course_completed) {
        if (lesson.courseId) {
          navigate(`/courses/${lesson.courseId}/completed`);
          return;
        }

        navigate('/courses');
        return;
      }

      if (lesson.courseId) {
        const lessons = await listLessons({ courseId: lesson.courseId }, {});
        const ordered = [...lessons].sort((a, b) => {
          if (a.lessonOrder !== b.lessonOrder) return a.lessonOrder - b.lessonOrder;
          return a.id.localeCompare(b.id);
        });
        const currentIndex = ordered.findIndex((item) => item.id === lesson.id);
        const nextLesson = currentIndex >= 0 ? ordered[currentIndex + 1] : null;

        if (nextLesson) {
          navigate(`/lessons/${nextLesson.id}`);
          return;
        }

        navigate(`/courses/${lesson.courseId}/completed`);
        return;
      }

      if (resp.redirect_path) {
        // If your server tells you where to go, obey it.
        window.location.assign(resp.redirect_path);
        return;
      }

      // Otherwise, navigate somewhere sane (course page, etc.)
      navigate(-1);
    } catch (e) {
      // Don’t block the user; show an error and allow retry (refresh).
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setCompleting(false);
    }
  }, [lesson, navigate]);

  // Install listener only once lesson is loaded and iframe is present.
  useLessonCompletionListener({
    iframeRef,
    onCompleted,
    enabled: Boolean(lesson),
  });

  const iframeTitle = lesson?.title ?? 'Lesson';

  if (isLoading) return <CircularProgress />;
  if (loadError || !lesson)
    return <Alert severity="error">{loadError?.message ?? 'Lesson not found'}</Alert>;
  if (error) return <Alert severity="error">{error ?? 'Error completing lesson'}</Alert>;

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        width: '100vw',
        height: { xs: '70vh', sm: '100vh' },
      }}
    >
      <Box
        sx={{
          display: 'flex',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: { xs: 0.5, sm: 2 },
          px: 2,
          py: 1,
          borderBottom: '1px solid',
          borderColor: 'divider',
          bgcolor: 'background.paper',
          flexShrink: 0,
        }}
      >
        {lesson.courseId && (
          <Link
            component={RouterLink}
            to={`/courses/${lesson.courseId}`}
            underline="hover"
            color="text.secondary"
            sx={{ display: 'flex', alignItems: 'center', gap: 0.5, flexShrink: 0 }}
          >
            <ArrowBack fontSize="small" />
            <Typography variant="body2">{lesson.courseTitle ?? 'Back to Course'}</Typography>
          </Link>
        )}
        {lesson.courseId && (
          <Typography variant="body2" color="divider" sx={{ userSelect: 'none', flexShrink: 0 }}>
            /
          </Typography>
        )}
        <Typography variant="body2" fontWeight={600} sx={{ wordBreak: 'break-word', minWidth: 0 }}>
          {lesson.title}
        </Typography>
      </Box>
      <Box sx={{ flex: 1, position: 'relative', minHeight: 0 }}>
        <StorylinePlayer ref={iframeRef} src={lesson.storylineUrl} title={iframeTitle} />

        {completing && (
          <Box
            sx={{
              position: 'absolute',
              inset: 0,
              display: 'grid',
              placeItems: 'center',
              bgcolor: 'rgba(0,0,0,0.2)',
            }}
          >
            <CircularProgress />
          </Box>
        )}
      </Box>
    </Box>
  );
}
