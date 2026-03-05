import { useState } from 'react';
import { useParams } from 'react-router-dom'; // or your router
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Link from '@mui/material/Link';
import { usePageMetadata } from '../../../app/metadata/usePageMetadata';
import type { Course } from '../types';
import { useCourseQuery } from '../queries/courseQuery';
import { LessonListContainer } from '../../lessons/components/LessonListContainer';
import { Container } from '@mui/material';
import { CourseCategoryPill } from '../components/CourseCategoryPill';
import { CheckCircleOutline, Schedule, Speed } from '@mui/icons-material';
import { previewImageForRecord } from '../../../app/images/previewImages';

function buildCourseTitle(course: Course) {
  return course.seoPageTitle?.trim() || course.title.trim() || 'Course';
}

function buildCourseDescription(course: Course) {
  return course.seoMetaDescription?.trim() || course.summary?.trim() || undefined;
}

export function CoursePage() {
  const { courseId = '' } = useParams();
  const { data: course, isLoading, error: loadError } = useCourseQuery(courseId);

  const [error] = useState<string | null>(null);

  usePageMetadata(
    course
      ? {
          title: buildCourseTitle(course),
          description: buildCourseDescription(course),
        }
      : { title: 'Course' },
  );

  if (isLoading) return <CircularProgress />;
  if (loadError || !course)
    return <Alert severity="error">{loadError?.message ?? 'Course not found'}</Alert>;
  if (error) return <Alert severity="error">{error ?? 'Error completing course'}</Alert>;

  const attachments = course.attachments ?? [];
  const additionalResources = attachments.filter((item) => item.docType === 'additional-resource');
  const textCopies = attachments.filter((item) => item.docType === 'text-copy');
  const previewImageUrl = previewImageForRecord(course.id);
  const durationSeconds = Number(course.totalDuration);
  const durationLabel =
    Number.isFinite(durationSeconds) && durationSeconds > 0
      ? `${Math.floor(durationSeconds / 60).toString()} mins`
      : 'Duration TBD';
  const levelLabel = course.level ?? 'Unspecified';
  const lessonsCount = course.lessonsCount;
  const lessonsCompletedCount = course.lessonsCompletedCount;
  const progressLabel =
    typeof lessonsCount === 'number' && typeof lessonsCompletedCount === 'number'
      ? `${lessonsCompletedCount} of ${lessonsCount} lesson${lessonsCount === 1 ? '' : 's'} completed`
      : null;

  return (
    <Container sx={{ py: 3 }}>
      <Box
        sx={{
          display: 'flex',
          flexDirection: { xs: 'column', md: 'row' },
          gap: 3,
          alignItems: 'flex-start',
        }}
      >
        <Box
          component="img"
          src={previewImageUrl}
          alt={`${course.title} preview`}
          sx={{
            width: { xs: '100%', md: 280 },
            maxWidth: 360,
            borderRadius: 2,
            objectFit: 'cover',
          }}
        />
        <Box sx={{ flex: 1, minWidth: 0 }}>
          <Typography variant="h4" sx={{ mb: 1 }}>
            {course.title}
          </Typography>
          {course.summary && (
            <Typography variant="body1" sx={{ mb: 2 }}>
              {course.summary}
            </Typography>
          )}
          {course.categoryName && <CourseCategoryPill label={course.categoryName.trim()} />}
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
            {progressLabel && (
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <CheckCircleOutline fontSize="small" />
                <Typography variant="body2" color="text.secondary">
                  {progressLabel}
                </Typography>
              </Box>
            )}
          </Box>
        </Box>
      </Box>

      <LessonListContainer title="Lessons" params={{ courseId: course.id }} />

      {(additionalResources.length > 0 || textCopies.length > 0) && (
        <Box sx={{ mt: 4 }}>
          {additionalResources.length > 0 && (
            <Box sx={{ mb: 3 }}>
              <Typography variant="h6" sx={{ mb: 1 }}>
                Additional Resources
              </Typography>
              <List disablePadding>
                {additionalResources.map((item) => (
                  <ListItem key={`${item.docType}-${item.url}`} disableGutters>
                    <Link href={item.url} download>
                      {item.fileName}
                    </Link>
                  </ListItem>
                ))}
              </List>
            </Box>
          )}
          {textCopies.length > 0 && (
            <Box>
              <Typography variant="h6" sx={{ mb: 1 }}>
                Text Copies of Course
              </Typography>
              <List disablePadding>
                {textCopies.map((item) => (
                  <ListItem key={`${item.docType}-${item.url}`} disableGutters>
                    <Link href={item.url} download>
                      {item.fileName}
                    </Link>
                  </ListItem>
                ))}
              </List>
            </Box>
          )}
        </Box>
      )}
    </Container>
  );
}
