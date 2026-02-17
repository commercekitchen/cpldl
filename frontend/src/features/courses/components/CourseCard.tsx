import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import type { Course } from '../types';
import { PlayLesson, Schedule, Speed } from '@mui/icons-material';
import { CourseCategoryPill } from './CourseCategoryPill';
import { previewImageForRecord } from '../../../app/images/previewImages';

type Props = {
  course: Course;
  metadata?: React.ReactNode;
  onClick?: (course: Course) => void;
};

export function CourseCard({ course, metadata, onClick }: Props) {
  const handleClick = () => onClick?.(course);
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
      <CardContent sx={{ flex: '1 1 auto' }}>
        <Typography variant="h6" sx={{ mb: 1 }}>
          {course.title}
        </Typography>
        {course.summary && (
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
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
      </CardContent>
    </>
  );

  return (
    <Card
      sx={{
        height: 'clamp(376px, 40vh, 460px)',
        minHeight: 'clamp(376px, 40vh, 460px)',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {onClick ? (
        <CardActionArea
          onClick={handleClick}
          aria-label={`View ${course.title}`}
          sx={{
            height: '100%',
            width: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'stretch',
            justifyContent: 'flex-start',
          }}
        >
          {content}
        </CardActionArea>
      ) : (
        content
      )}
    </Card>
  );
}
