import Container from '@mui/material/Container';
import { useRouteLoaderData } from 'react-router-dom';
import { SubHeaderBanner } from '../app/components/SubHeaderBanner';
import type { OrganizationConfig } from '../app/organization/types';
import { CourseListContainer } from '../features/courses/components/CourseListContainer';
import { LessonListContainer } from '../features/lessons/components/LessonListContainer';

export default function Home() {
  const rootData = useRouteLoaderData('root') as { orgConfig: OrganizationConfig } | undefined;
  const bannerText = rootData?.orgConfig.bannerText?.trim();

  return (
    <>
      {bannerText ? <SubHeaderBanner text={bannerText} /> : null}
      <Container
        maxWidth={false}
        disableGutters
        sx={{
          py: 2,
          px: { xs: 1, sm: 2, md: 3 }, // tighter side margins
        }}
      >
        <CourseListContainer title="Featured Classes" params={{ scope: 'homepage', limit: 10 }} />
        <LessonListContainer title="Popular Lessons" params={{ scope: 'popular', limit: 10 }} />
      </Container>
    </>
  );
}
