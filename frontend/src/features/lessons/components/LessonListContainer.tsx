import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';
import { useNavigate } from 'react-router-dom';
import { LessonList } from './LessonList';
import type { ListLessonsParams } from '../api/lessonsApi';
import { useLessonsListQuery } from '../queries/useLessonsListQuery';
import { useAuth } from '../../../auth/useAuth';
import { useGuestProgress } from '../../progress/useGuestProgress';

type Props = { title: string; params?: ListLessonsParams };

export function LessonListContainer({ title, params }: Props) {
  const navigate = useNavigate();
  const { status } = useAuth();
  const { data: lessons = [], isLoading, error } = useLessonsListQuery(params);
  const { isCompleted } = useGuestProgress();

  const isGuest = status === 'unauthenticated';

  const displayedLessons = isGuest
    ? lessons.map((l) => ({ ...l, completed: l.completed || isCompleted(l.id) }))
    : lessons;

  return (
    <Box sx={{ my: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 2, mb: 1 }}>
        <Typography variant="h6">{title}</Typography>
      </Box>

      {isLoading && <CircularProgress />}
      {error && <Alert severity="error">{error.message}</Alert>}

      {!isLoading && !error && (
        <LessonList
          lessons={displayedLessons}
          onPlayLesson={(id) => navigate(`/lessons/${id}`)}
          hideCourseContext={!!params?.courseId}
        />
      )}
    </Box>
  );
}
