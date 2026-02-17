import { useNavigate, useParams } from 'react-router-dom';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';

export function CourseCompletedPage() {
  const navigate = useNavigate();
  const { courseId = '' } = useParams();

  return (
    <Container sx={{ py: 6 }}>
      <Box
        sx={{
          maxWidth: 720,
          mx: 'auto',
          p: 4,
          border: '1px solid',
          borderColor: 'divider',
          borderRadius: 2,
          textAlign: 'center',
        }}
      >
        <Typography variant="h3" sx={{ mb: 1 }}>
          Course Completed
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
          Nice work. You have completed this course.
        </Typography>

        <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2, flexWrap: 'wrap' }}>
          <Button variant="contained" onClick={() => navigate('/courses')}>
            View All Courses
          </Button>
          {courseId && (
            <Button variant="outlined" onClick={() => navigate(`/courses/${courseId}`)}>
              Back to Course
            </Button>
          )}
        </Box>
      </Box>
    </Container>
  );
}
