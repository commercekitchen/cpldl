import { useState } from 'react';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import Typography from '@mui/material/Typography';
import { DownloadAttachmentRow } from '../components/DownloadAttachmentRow';
import { usePageMetadata } from '../../../app/metadata/usePageMetadata';
import type { Course } from '../types';
import { useCourseQuery } from '../queries/courseQuery';
import { LessonListContainer } from '../../lessons/components/LessonListContainer';
import { Container } from '@mui/material';
import { CourseCategoryPill } from '../components/CourseCategoryPill';
import { CourseCompletedBadge } from '../components/CourseCompletedBadge';
import { CourseStats } from '../components/CourseStats';
import { previewImageForRecord } from '../../../app/images/previewImages';
import DOMPurify from 'dompurify';


function buildCourseTitle(course: Course) {
  return course.seoPageTitle?.trim() || course.title.trim() || 'Course';
}

function buildCourseDescription(course: Course) {
  return course.seoMetaDescription?.trim() || course.summary?.trim() || undefined;
}

export function CoursePage() {
  const { t } = useTranslation();
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
  const lessonsCount = course.lessonsCount;
  const lessonsCompletedCount = course.lessonsCompletedCount;
  const titleBadge = course.completed
    ? 'Completed'
    : typeof lessonsCount === 'number' && typeof lessonsCompletedCount === 'number'
      ? `[${lessonsCompletedCount} of ${lessonsCount} completed]`
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
            aspectRatio: '4/3',
            borderRadius: 2,
            objectFit: 'cover',
            bgcolor: 'action.hover',
          }}
        />
        <Box sx={{ flex: 1, minWidth: 0 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: 1.5, mb: 1 }}>
            <Typography variant="h4">{course.title}</Typography>
            {course.completed ? (
              <CourseCompletedBadge />
            ) : (
              titleBadge && (
                <Typography component="span" variant="body2" color="text.secondary">
                  {titleBadge}
                </Typography>
              )
            )}
          </Box>
          {course.summary && (
            <Typography variant="body1" sx={{ mb: 2 }}>
              {course.summary}
            </Typography>
          )}
          {course.categoryName && <CourseCategoryPill label={course.categoryName.trim()} />}
          <CourseStats course={course} />
        </Box>
      </Box>

      {course.description && (
        <Box
          color="text.secondary"
          sx={{ mt: 2, '& p': { mt: 0 }, '& p:last-child': { mb: 0 } }}
          dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(course.description) }}
        />
      )}

      <LessonListContainer title="Lessons" params={{ courseId: course.id }} />

      {(additionalResources.length > 0 || textCopies.length > 0) && (
        <Box sx={{ mt: 4 }}>
          {additionalResources.length > 0 && (
            <Box sx={{ mb: 3 }}>
              <Typography variant="h6" sx={{ mb: 1 }}>
                {t('courses.additionalResources')}
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                {additionalResources.map((item) => (
                  <DownloadAttachmentRow
                    key={`${item.docType}-${item.url}`}
                    fileName={item.fileName}
                    url={item.url}
                    contentType={item.contentType}
                  />
                ))}
              </Box>
            </Box>
          )}
          {textCopies.length > 0 && (
            <Box>
              <Typography variant="h6" sx={{ mb: 1 }}>
                {t('courses.textCopies')}
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                {textCopies.map((item) => (
                  <DownloadAttachmentRow
                    key={`${item.docType}-${item.url}`}
                    fileName={item.fileName}
                    url={item.url}
                    contentType={item.contentType}
                  />
                ))}
              </Box>
            </Box>
          )}
        </Box>
      )}
    </Container>
  );
}
