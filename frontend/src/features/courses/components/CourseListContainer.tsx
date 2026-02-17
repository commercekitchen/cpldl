import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';
import { useNavigate } from 'react-router-dom';
import { CourseList } from './CourseList';
import type { ListCoursesParams } from '../api/coursesApi';
import { useCoursesListQuery } from '../queries/useCoursesListQuery';
import { listLessons } from '../../lessons/api/lessonsApi';

type Props = { title: string; params?: ListCoursesParams };

export function CourseListContainer({ title, params }: Props) {
  const navigate = useNavigate();
  const { data: courses = [], isLoading, error } = useCoursesListQuery(params);

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

  return (
    <Box sx={{ my: 3 }}>
      <Typography variant="h6" sx={{ mb: 1 }}>
        {title}
      </Typography>

      {isLoading && <CircularProgress />}
      {error && <Alert severity="error">{error.message}</Alert>}

      {!isLoading && !error && (
        <CourseList
          courses={courses}
          onViewLessons={(id) => navigate(`/courses/${id}`)}
          onStartCourse={(id) => {
            void startCourse(id);
          }}
          viewAllHref="/courses"
        />
      )}
    </Box>
  );
}
