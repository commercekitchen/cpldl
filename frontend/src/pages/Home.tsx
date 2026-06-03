import Alert from '@mui/material/Alert';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import { useLocation, useNavigate, useRouteLoaderData } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { SubHeaderBanner } from '../app/components/SubHeaderBanner';
import type { OrganizationConfig } from '../app/organization/types';
import { CourseListContainer } from '../features/courses/components/CourseListContainer';
import { LessonListContainer } from '../features/lessons/components/LessonListContainer';
import { SurveyBanner } from '../features/survey/components/SurveyBanner';
import { useAuth } from '../auth/useAuth';

export default function Home() {
  const { t } = useTranslation();
  const { status, user } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const rootData = useRouteLoaderData('org') as { orgConfig: OrganizationConfig } | undefined;
  const bannerText = rootData?.orgConfig.bannerText?.trim();

  const surveyJustCompleted = (location.state as { surveyJustCompleted?: boolean } | null)?.surveyJustCompleted === true;
  const isAuthenticated = status === 'authenticated';

  const showSurveyBanner =
    isAuthenticated &&
    !user?.surveyCompleted &&
    !user?.optOutOfRecommendations;

  return (
    <>
      {bannerText ? <SubHeaderBanner text={bannerText} /> : null}
      {showSurveyBanner ? <SurveyBanner /> : null}
      <Container
        maxWidth={false}
        disableGutters
        sx={{
          py: 2,
          px: { xs: 1, sm: 2, md: 3 },
        }}
      >
        {surveyJustCompleted && (
          <Alert severity="success" sx={{ mb: 3 }}>
            {t('survey.completed')}
          </Alert>
        )}

        {isAuthenticated && (
          <CourseListContainer
            title={t('home.coursesForYou')}
            params={{ scope: 'tracked' }}
            headerAction={
              <Button variant="outlined" size="small" onClick={() => navigate('/survey')}>
                {t('survey.retake')}
              </Button>
            }
          />
        )}

        <CourseListContainer title={t('home.featuredCourses')} params={{ scope: 'homepage', limit: 10 }} />

        <LessonListContainer title={t('home.popularLessons')} params={{ scope: 'popular', limit: 10 }} />
      </Container>
    </>
  );
}
