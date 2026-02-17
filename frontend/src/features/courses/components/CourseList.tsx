import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Typography from '@mui/material/Typography';
import { Link as RouterLink } from 'react-router-dom';
import type { Course } from '../types';
import { CourseCard } from './CourseCard';

type Props = {
  courses: Course[];
  onViewLessons: (courseId: string) => void;
  onStartCourse: (courseId: string) => void;
  viewAllHref?: string;
};

export function CourseList({ courses, onViewLessons, onStartCourse, viewAllHref }: Props) {
  if (courses.length === 0) {
    return <Typography variant="body2">No courses available.</Typography>;
  }

  const cardWidth = 'clamp(216px, 50vw, 488px)';

  return (
    <Box
      role="list"
      aria-label="Courses"
      sx={{
        display: 'flex',
        alignItems: 'stretch',
        gap: 2,
        overflowX: 'auto',
        pb: 1,
        scrollSnapType: 'x proximity',
      }}
    >
      {courses.map((c) => (
        <Box
          key={c.id}
          role="listitem"
          sx={{
            flex: '0 0 auto',
            width: cardWidth,
            scrollSnapAlign: 'start',
            height: '100%',
          }}
        >
          <CourseCard
            course={c}
            onViewLessons={(course) => onViewLessons(course.id)}
            onStartCourse={(course) => onStartCourse(course.id)}
          />
        </Box>
      ))}
      {viewAllHref && (
        <Box role="listitem" sx={{ flex: '0 0 auto', width: cardWidth, scrollSnapAlign: 'start' }}>
          <ButtonBase
            component={RouterLink}
            to={viewAllHref}
            aria-label="View all courses"
            sx={{
              height: '100%',
              width: '100%',
              border: '1px solid',
              borderColor: 'divider',
              borderRadius: 2,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              p: 3,
            }}
          >
            <Typography variant="subtitle1">View All</Typography>
          </ButtonBase>
        </Box>
      )}
    </Box>
  );
}
