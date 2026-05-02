import Typography from '@mui/material/Typography';
import type { Lesson } from '../types';
import Box from '@mui/material/Box';
import { LessonCard } from './LessonCard';

type Props = {
  lessons: Lesson[];
  onPlayLesson: (lessonId: string) => void;
  hideCourseContext?: boolean;
};

export function LessonList({ lessons, onPlayLesson, hideCourseContext }: Props) {
  if (lessons.length === 0) {
    return <Typography variant="body2">No lessons available.</Typography>;
  }

  const cardWidth = 'clamp(216px, 50vw, 488px)';

  const lessonPosition: Record<string, { index: number; total: number }> = {};
  const courseGroups: Record<string, Lesson[]> = {};
  for (const lesson of lessons) {
    if (lesson.courseId) {
      (courseGroups[lesson.courseId] ??= []).push(lesson);
    }
  }
  for (const group of Object.values(courseGroups)) {
    group.sort((a, b) => a.lessonOrder - b.lessonOrder || a.id.localeCompare(b.id));
    group.forEach((lesson, i) => {
      lessonPosition[lesson.id] = { index: i + 1, total: group.length };
    });
  }

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
          <LessonCard
            lesson={l}
            onPlayLesson={(lesson) => onPlayLesson(lesson.id)}
            lessonPosition={lessonPosition[l.id]}
            hideCourseContext={hideCourseContext}
          />
        </Box>
      ))}
    </Box>
  );
}
