import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import type { Lesson } from '../types';
import { PlayArrow, Replay, Schedule, Speed } from '@mui/icons-material';
import { previewImageForRecord } from '../../../app/images/previewImages';
import { CourseCompletedBadge } from '../../courses/components/CourseCompletedBadge';

type Props = {
  lesson: Lesson;
  metadata?: React.ReactNode;
  onPlayLesson?: (lesson: Lesson) => void;
  onViewCourse?: (lesson: Lesson) => void;
};

export function LessonCard({ lesson, metadata, onPlayLesson, onViewCourse }: Props) {
  const imageUrl = previewImageForRecord(lesson.id);
  const durationLabel = lesson.duration
    ? `${Math.floor(lesson.duration / 60).toString()} mins`
    : 'Unknown';
  const levelLabel = lesson.level?.trim() || 'Level TBD';

  const content = (
    <>
      <Box sx={{ position: 'relative' }}>
        <CardMedia
          component="img"
          image={imageUrl}
          alt={`${lesson.title} preview`}
          sx={{
            height: 180,
            minHeight: 120,
            flexShrink: 1,
            objectFit: 'cover',
          }}
        />
        {onPlayLesson ? (
          <Box
            sx={{
              position: 'absolute',
              inset: 0,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: 'linear-gradient(180deg, rgba(0,0,0,0.08) 0%, rgba(0,0,0,0.45) 100%)',
            }}
          >
            <Button
              variant="text"
              color="inherit"
              startIcon={lesson.completed ? <Replay /> : <PlayArrow />}
              onClick={() => onPlayLesson(lesson)}
              aria-label={
                lesson.completed ? `Replay lesson ${lesson.title}` : `Play lesson ${lesson.title}`
              }
              sx={{
                color: '#fff',
                fontWeight: 700,
                textTransform: 'none',
                backgroundColor: 'rgba(0, 0, 0, 0.35)',
                '&:hover, &:focus-visible': {
                  backgroundColor: 'rgba(0, 0, 0, 0.5)',
                },
              }}
            >
              {lesson.completed ? 'Replay' : 'Play Lesson'}
            </Button>
          </Box>
        ) : null}
      </Box>
      <CardContent
        sx={{ flex: '1 1 auto', display: 'flex', flexDirection: 'column', minHeight: 0 }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: 1, mb: 1 }}>
          <Typography variant="h6">{lesson.title}</Typography>
          {lesson.completed && <CourseCompletedBadge />}
        </Box>
        {lesson.summary && (
          <Typography
            variant="body2"
            color="text.secondary"
            sx={{
              mb: 2,
              display: '-webkit-box',
              WebkitLineClamp: 2,
              WebkitBoxOrient: 'vertical',
              overflow: 'hidden',
            }}
          >
            {lesson.summary}
          </Typography>
        )}
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'row',
            alignItems: 'center',
            gap: 2,
            flexWrap: 'wrap',
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Schedule />
            <Typography variant="body2" color="text.secondary">
              {durationLabel}
            </Typography>
          </Box>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Speed />
            <Typography variant="body2" color="text.secondary">
              {levelLabel}
            </Typography>
          </Box>
        </Box>
        {metadata && <Box>{metadata}</Box>}
        {onViewCourse && lesson.courseId ? (
          <Button
            variant="outlined"
            color="primary"
            size="small"
            onClick={() => onViewCourse(lesson)}
            sx={{ mt: 2 }}
          >
            View Full Course
          </Button>
        ) : null}
      </CardContent>
    </>
  );

  return (
    <Card
      sx={{
        minHeight: 'clamp(376px, 40vh, 460px)',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {content}
    </Card>
  );
}
