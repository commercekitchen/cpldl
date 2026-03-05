import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import type { Course } from '../types';
import { PlayArrow, PlayLesson, Schedule, Speed } from '@mui/icons-material';
import { CourseCategoryPill } from './CourseCategoryPill';
import { CourseCompletedBadge } from './CourseCompletedBadge';
import { previewImageForRecord } from '../../../app/images/previewImages';
import attLogo from '../../../assets/att_logo.svg';

type Props = {
  course: Course;
  metadata?: React.ReactNode;
  onViewLessons?: (course: Course) => void;
  onStartCourse?: (course: Course) => void;
};

export function CourseCard({ course, metadata, onViewLessons, onStartCourse }: Props) {
  const imageUrl = previewImageForRecord(course.id);
  const categoryLabel = course.categoryName?.trim();
  const durationSeconds = Number(course.totalDuration);
  const durationLabel =
    Number.isFinite(durationSeconds) && durationSeconds > 0
      ? `${Math.floor(durationSeconds / 60).toString()} mins`
      : 'Duration TBD';
  const levelLabel = course.level?.trim() || 'Level TBD';
  const lessonsLabel =
    typeof course.lessonsCount === 'number'
      ? `${course.lessonsCount} lesson${course.lessonsCount === 1 ? '' : 's'}`
      : 'Lessons TBD';

  const content = (
    <>
      <Box sx={{ position: 'relative' }}>
        <CardMedia
          component="img"
          image={imageUrl}
          alt={`${course.title} preview`}
          sx={{
            height: 180,
            minHeight: 120,
            flexShrink: 1,
            objectFit: 'cover',
          }}
        />
        {onStartCourse ? (
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
              startIcon={<PlayArrow />}
              onClick={() => onStartCourse(course)}
              aria-label={`Start course ${course.title}`}
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
              Start Course
            </Button>
          </Box>
        ) : null}
      </Box>
      <CardContent
        sx={{ flex: '1 1 auto', display: 'flex', flexDirection: 'column', minHeight: 0 }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: 1, mb: 1 }}>
          <Typography variant="h6">{course.title}</Typography>
          <>{console.log('Course completed:', course.completed)}</>
          {course.completed && <CourseCompletedBadge />}
        </Box>
        {course.summary && (
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
            {course.summary}
          </Typography>
        )}
        {categoryLabel && <CourseCategoryPill label={categoryLabel} />}
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
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <PlayLesson />
            <Typography variant="body2" color="text.secondary">
              {lessonsLabel}
            </Typography>
          </Box>
        </Box>
        {metadata && <Box>{metadata}</Box>}
        {onViewLessons ? (
          <Button
            variant="outlined"
            color="primary"
            size="small"
            onClick={() => onViewLessons(course)}
            sx={{ mt: 2 }}
          >
            View Lessons
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
        position: 'relative',
      }}
    >
      {course.attCourse ? (
        <Box
          sx={{
            position: 'absolute',
            top: 12,
            right: 12,
            zIndex: 2,
            backgroundColor: '#22D3EE', // cyan/400
            borderRadius: '999px',
            px: 1.5,
            py: 0.5,
            minHeight: 28,
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 12,
            fontWeight: 700,
            lineHeight: 1,
            color: '#0B1D26',
          }}
        >
          <Box component="img" src={attLogo} alt="ATT logo" sx={{ height: 16, mr: 0.5 }} />
        </Box>
      ) : null}
      {content}
    </Card>
  );
}
