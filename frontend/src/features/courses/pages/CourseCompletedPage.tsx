import { useNavigate, useParams } from 'react-router-dom';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Divider from '@mui/material/Divider';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';
import { ArrowBack, CheckCircle, Search } from '@mui/icons-material';
import { useCourseQuery } from '../queries/courseQuery';
import { CourseCategoryPill } from '../components/CourseCategoryPill';
import { CourseStats } from '../components/CourseStats';

export function CourseCompletedPage() {
  const { courseId = '' } = useParams();
  const navigate = useNavigate();
  const { data: course, isLoading } = useCourseQuery(courseId);

  if (isLoading) return <CircularProgress />;

  return (
    <Box>
      {/* Banner */}
      <Box
        sx={{
          bgcolor: 'primary.main',
          py: { xs: 10, md: 14 },
          textAlign: 'center',
          px: 2,
        }}
      >
        <CheckCircle sx={{ fontSize: 80, color: 'primary.contrastText', mb: 3 }} />
        <Typography variant="h5" color="primary.contrastText" sx={{ fontWeight: 400, mb: 0.5 }}>
          Congratulations
        </Typography>
        <Typography variant="body1" color="primary.contrastText" sx={{ opacity: 0.85, mb: 1.5 }}>
          You've Completed
        </Typography>
        <Typography variant="h4" color="primary.contrastText" sx={{ fontWeight: 700, mb: 3 }}>
          {course?.title ?? 'this course'}
        </Typography>
        {course?.categoryName && (
          <CourseCategoryPill label={course.categoryName.trim()} variant="outlined" />
        )}
      </Box>

      {/* Body */}
      <Container sx={{ py: 6, maxWidth: 720 }}>
        {/* Course Overview */}
        <Typography variant="h6" sx={{ mb: 2 }}>
          Course Overview
        </Typography>
        {course?.description && (
          <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
            {course.description}
          </Typography>
        )}
        {course && <CourseStats course={course} showLessons />}

        <Divider sx={{ my: 4 }} />

        {/* Next Steps */}
        <Typography variant="h6" sx={{ mb: 2 }}>
          Next Steps
        </Typography>
        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center' }}>
          {courseId && (
            <Button
              variant="outlined"
              startIcon={<ArrowBack />}
              onClick={() => navigate(`/courses/${courseId}`)}
            >
              {course?.title ?? 'Back to Course'}
            </Button>
          )}
          <Button
            variant="contained"
            startIcon={<Search />}
            onClick={() => navigate('/courses')}
          >
            Search for more courses
          </Button>
        </Box>
      </Container>
    </Box>
  );
}
