import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import { searchAll } from '../features/search/api/searchApi';
import type { SearchResults } from '../features/search/api/searchApi';
import { CourseCard } from '../features/courses/components/CourseCard';
import { LessonCard } from '../features/lessons/components/LessonCard';
import { listLessons } from '../features/lessons/api/lessonsApi';

export default function Search() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const query = params.get('q')?.trim() ?? '';
  const [results, setResults] = useState<SearchResults>({ courses: [], lessons: [] });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

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

  useEffect(() => {
    if (!query) {
      setResults({ courses: [], lessons: [] });
      setError(null);
      return;
    }

    const controller = new AbortController();
    const run = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await searchAll(query, { signal: controller.signal });
        setResults(data);
      } catch (err: unknown) {
        if (!controller.signal.aborted) {
          const message = err instanceof Error ? err.message : 'Search failed';
          setError(message);
        }
      } finally {
        if (!controller.signal.aborted) setLoading(false);
      }
    };

    run();
    return () => controller.abort();
  }, [query]);

  const hasResults = results.courses.length > 0 || results.lessons.length > 0;

  return (
    <Container sx={{ py: 3 }}>
      {query ? (
        <Typography variant="h4" sx={{ mb: 2 }}>
          Results for '{query}'
        </Typography>
      ) : (
        <Typography variant="h4" sx={{ mb: 2 }}>
          Search Results
        </Typography>
      )}

      {!query && (
        <Typography variant="body1" color="text.secondary">
          Enter a search term to see results.
        </Typography>
      )}
      {loading && <CircularProgress />}
      {error && <Alert severity="error">{error}</Alert>}

      {!loading && !error && results.courses.length > 0 && (
        <>
          <Typography variant="h5" sx={{ mt: 2, mb: 1 }}>
            Courses
          </Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
            {results.courses.map((course) => (
              <CourseCard
                key={course.id}
                course={course}
                onViewLessons={() => navigate(`/courses/${course.id}`)}
                onStartCourse={() => {
                  void startCourse(course.id);
                }}
              />
            ))}
          </Box>
        </>
      )}

      {!loading && !error && results.lessons.length > 0 && (
        <>
          <Typography variant="h5" sx={{ mt: 3, mb: 1 }}>
            Lessons
          </Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
            {results.lessons.map((lesson) => (
              <LessonCard
                key={lesson.id}
                lesson={lesson}
                onPlayLesson={() => navigate(`/lessons/${lesson.id}`)}
                onViewCourse={lesson.courseId ? () => navigate(`/courses/${lesson.courseId!}`) : undefined}
              />
            ))}
          </Box>
        </>
      )}

      {!loading && !error && query && !hasResults && (
        <Typography variant="body1" color="text.secondary">
          No results found.
        </Typography>
      )}
    </Container>
  );
}
