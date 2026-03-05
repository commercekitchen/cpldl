import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { PlayLesson, Schedule, Speed } from '@mui/icons-material';
import type { Course } from '../types';

type Props = {
  course: Course;
  showLessons?: boolean;
  color?: string;
};

export function CourseStats({ course, showLessons = false, color = 'text.secondary' }: Props) {
  const durationSeconds = Number(course.totalDuration);
  const durationLabel =
    Number.isFinite(durationSeconds) && durationSeconds > 0
      ? `${Math.floor(durationSeconds / 60)} mins`
      : 'Duration TBD';
  const levelLabel = course.level?.trim() || 'Level TBD';
  const lessonsCount = course.lessonsCount;
  const lessonsLabel =
    typeof lessonsCount === 'number'
      ? `${lessonsCount} lesson${lessonsCount === 1 ? '' : 's'}`
      : 'Lessons TBD';

  return (
    <Box sx={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Schedule sx={{ color }} />
        <Typography variant="body2" color={color}>{durationLabel}</Typography>
      </Box>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <Speed sx={{ color }} />
        <Typography variant="body2" color={color}>{levelLabel}</Typography>
      </Box>
      {showLessons && (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <PlayLesson sx={{ color }} />
          <Typography variant="body2" color={color}>{lessonsLabel}</Typography>
        </Box>
      )}
    </Box>
  );
}
