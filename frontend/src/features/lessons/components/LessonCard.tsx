import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import type { Lesson } from '../types';
import { Schedule, Speed } from '@mui/icons-material';
import { previewImageForRecord } from '../../../app/images/previewImages';

type Props = {
  lesson: Lesson;
  metadata?: React.ReactNode;
  onClick?: (lesson: Lesson) => void;
};

export function LessonCard({ lesson, metadata, onClick }: Props) {
  const handleClick = () => onClick?.(lesson);
  const imageUrl = previewImageForRecord(lesson.id);
  const durationLabel = lesson.duration ? `${Math.floor(lesson.duration / 60).toString()} mins` : 'Unknown';
  const levelLabel = lesson.level?.trim() || 'Level TBD';

  const content = (
    <>
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
      <CardContent sx={{ flex: '1 1 auto' }}>
        <Typography variant="h6" sx={{ mb: 1 }}>
          {lesson.title}
        </Typography>
        {lesson.summary && (
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
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
          aria-label={`View ${lesson.title}`}
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
