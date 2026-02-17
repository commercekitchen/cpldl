import Typography from '@mui/material/Typography';
import type { Lesson } from '../types';
import Box from '@mui/material/Box';
import { LessonCard } from './LessonCard';

type Props = {
  lessons: Lesson[];
  onSelect: (lessonId: string) => void;
};

export function LessonList({ lessons, onSelect }: Props) {
  if (lessons.length === 0) {
    return <Typography variant="body2">No lessons available.</Typography>;
  }

  const cardWidth = 'clamp(216px, 50vw, 488px)';

  return (
    <Box
      role="list"
      aria-label="Lessons"
      sx={{
        display: 'flex',
        alignItems: 'stretch',
        gap: 2,
        overflowX: 'auto',
        pb: 1,
        scrollSnapType: 'x proximity',
      }}
    >
      {lessons.map((l) => (
        <Box
          key={l.id}
          role="listitem"
          sx={{
            flex: '0 0 auto',
            width: cardWidth,
            scrollSnapAlign: 'start',
            height: '100%',
          }}
        >
          <LessonCard onClick={(lesson) => onSelect(lesson.id)} lesson={l} />
        </Box>
      ))}
    </Box>
  );
}
