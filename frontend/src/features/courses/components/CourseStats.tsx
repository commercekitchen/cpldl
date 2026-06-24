import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { PlayLesson, Schedule, Speed } from '@mui/icons-material';
import { useTranslation } from 'react-i18next';
import type { Course } from '../types';

type Props = {
  course: Course;
  showLessons?: boolean;
  color?: string;
};

export function CourseStats({ course, showLessons = false, color = 'text.secondary' }: Props) {
  const { t } = useTranslation();
  const durationSeconds = Number(course.totalDuration);
  const durationLabel =
    Number.isFinite(durationSeconds) && durationSeconds > 0
      ? t('courses.durationMins', { count: Math.floor(durationSeconds / 60) })
      : t('courses.durationTbd');
  const levelLabel = course.level?.trim() || t('courses.levelTbd');
  const lessonsCount = course.lessonsCount;
  const lessonsLabel =
    typeof lessonsCount === 'number'
      ? t('courses.lessonCount', { count: lessonsCount })
      : t('courses.lessonsTbd');

  return (
    <Box sx={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Schedule sx={{ color }} aria-hidden="true" />
        <Typography variant="body2" color={color}>{durationLabel}</Typography>
      </Box>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Speed sx={{ color }} aria-hidden="true" />
        <Typography variant="body2" color={color}>{levelLabel}</Typography>
      </Box>
      {showLessons && (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <PlayLesson sx={{ color }} aria-hidden="true" />
          <Typography variant="body2" color={color}>{lessonsLabel}</Typography>
        </Box>
      )}
    </Box>
  );
}
