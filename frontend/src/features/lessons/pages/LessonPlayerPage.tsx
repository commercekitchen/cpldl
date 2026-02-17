import { useCallback, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom'; // or your router
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
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
    <Box sx={{ width: '100vw', height: '100vh' }}>
      <Box sx={{ width: '100%', height: '100%', position: 'relative' }}>
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
