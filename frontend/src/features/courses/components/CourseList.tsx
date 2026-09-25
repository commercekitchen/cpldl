import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Typography from '@mui/material/Typography';
import { Link as RouterLink } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import type { Course } from '../types';
import { CourseCard } from './CourseCard';
import { useAuth } from '../../../auth/useAuth';
import { useGuestProgress } from '../../progress/useGuestProgress';

type Props = {
  courses: Course[];
  onViewLessons: (courseId: string) => void;
  onStartCourse: (courseId: string) => void;
  viewAllHref?: string;
};

export function CourseList({ courses, onViewLessons, onStartCourse, viewAllHref }: Props) {
  const { t } = useTranslation();
  const { status } = useAuth();
  const { isCourseCompleted } = useGuestProgress();
  const isGuest = status === 'unauthenticated';

  if (courses.length === 0) {
    return <Typography variant="body2">No courses available.</Typography>;
  }

  const displayedCourses = isGuest
    ? courses.map((c) => ({ ...c, completed: c.completed || isCourseCompleted(c.id) }))
    : courses;

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
      {displayedCourses.map((c) => (
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
            aria-label={t('courses.viewAllAriaLabel')}
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
              '&.Mui-focusVisible': {
                outline: '3px solid',
                outlineColor: 'primary.main',
                outlineOffset: -2,
              },
            }}
          >
            <Typography variant="subtitle1">{t('courses.viewAll')}</Typography>
          </ButtonBase>
        </Box>
      )}
    </Box>
  );
}
