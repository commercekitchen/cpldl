import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';
import { useNavigate } from 'react-router-dom';
import { CourseList } from './CourseList';
import type { ListCoursesParams } from '../api/coursesApi';
import { useCoursesListQuery } from '../queries/useCoursesListQuery';

type Props = { title: string; params?: ListCoursesParams };

export function CourseListContainer({ title, params }: Props) {
  const navigate = useNavigate();
  const { data: courses = [], isLoading, error } = useCoursesListQuery(params);

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
          onSelect={(id) => navigate(`/courses/${id}`)}
          viewAllHref="/courses"
        />
      )}
    </Box>
  );
}
