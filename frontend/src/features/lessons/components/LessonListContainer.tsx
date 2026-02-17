import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';
import { useNavigate } from 'react-router-dom';
import { LessonList } from './LessonList';
import type { ListLessonsParams } from '../api/lessonsApi';
import { useLessonsListQuery } from '../queries/useLessonsListQuery';

type Props = { title: string; params?: ListLessonsParams };

export function LessonListContainer({ title, params }: Props) {
  const navigate = useNavigate();
  const { data: lessons = [], isLoading, error } = useLessonsListQuery(params);

  return (
    <Box sx={{ my: 3 }}>
      <Typography variant="h6" sx={{ mb: 1 }}>
        {title}
      </Typography>

      {isLoading && <CircularProgress />}
      {error && <Alert severity="error">{error.message}</Alert>}

      {!isLoading && !error && (
        <LessonList
          lessons={lessons}
          onPlayLesson={(id) => navigate(`/lessons/${id}`)}
          onViewCourse={(courseId) => navigate(`/courses/${courseId}`)}
        />
      )}
    </Box>
  );
}
