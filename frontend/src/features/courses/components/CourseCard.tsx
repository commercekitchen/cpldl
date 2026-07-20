import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import type { Course } from '../types';
import { PlayArrow } from '@mui/icons-material';
import { useTranslation } from 'react-i18next';
import { CourseCategoryPill } from './CourseCategoryPill';
import { CourseCompletedBadge } from './CourseCompletedBadge';
import { CourseStats } from './CourseStats';
import { previewImageForRecord } from '../../../app/images/previewImages';
import { pushGaEvent } from '../../../app/analytics';
import attLogo from '../../../assets/att_logo.png';

type Props = {
  course: Course;
  metadata?: React.ReactNode;
  onViewLessons?: (course: Course) => void;
  onStartCourse?: (course: Course) => void;
};

export function CourseCard({ course, metadata, onViewLessons, onStartCourse }: Props) {
  const { t } = useTranslation();
  const imageUrl = previewImageForRecord(course.id);
  const categoryLabel = course.categoryName?.trim();
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
              onClick={() => {
                pushGaEvent('user_open_course', {
                  course_id: course.id,
                  course_name: course.title,
                });
                onStartCourse(course);
              }}
              aria-label={`${t('courses.startCourse')} ${course.title}`}
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
              {t('courses.startCourse')}
            </Button>
          </Box>
        ) : null}
      </Box>
      <CardContent
        sx={{ flex: '1 1 auto', display: 'flex', flexDirection: 'column', minHeight: 0 }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: 1, mb: 1 }}>
          <Typography variant="h6">{course.title}</Typography>
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
        <CourseStats course={course} showLessons />
        {metadata && <Box>{metadata}</Box>}
        {onViewLessons ? (
          <Button
            variant="outlined"
            color="primary"
            size="small"
            onClick={() => {
              pushGaEvent('user_open_course', {
                course_id: course.id,
                course_name: course.title,
              });
              onViewLessons(course);
            }}
            sx={{ mt: 2 }}
          >
            {t('courses.viewLessons')}
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
          component="img"
          src={attLogo}
          alt="ATT logo"
          sx={{
            position: 'absolute',
            top: 12,
            right: 12,
            zIndex: 2,
            height: 28,
          }}
        />
      ) : null}
      {content}
    </Card>
  );
}
