import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import { useLocation, useNavigate, useRouteLoaderData } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { SubHeaderBanner } from '../app/components/SubHeaderBanner';
import type { OrganizationConfig } from '../app/organization/types';
import { CourseListContainer } from '../features/courses/components/CourseListContainer';
import { LessonListContainer } from '../features/lessons/components/LessonListContainer';
import { SurveyBanner } from '../features/survey/components/SurveyBanner';
import { useAuth } from '../auth/useAuth';
import { useLocale } from '../app/locale/LocaleContext';

export default function Home() {
  const { t } = useTranslation();
  const { status, user } = useAuth();
  const { locale } = useLocale();
  const location = useLocation();
  const navigate = useNavigate();
  const rootData = useRouteLoaderData('org') as { orgConfig: OrganizationConfig } | undefined;
  const customText = rootData?.orgConfig.customText;
  const isSpanish = locale === 'es';

  const bannerHeader = isSpanish
    ? (customText?.homeHeaderEs || customText?.homeHeaderEn)
    : customText?.homeHeaderEn;
  const bannerSubheader = isSpanish
    ? (customText?.homeSubheaderEs || customText?.homeSubheaderEn)
    : customText?.homeSubheaderEn;

  const surveyJustCompleted =
    (location.state as { surveyJustCompleted?: boolean } | null)?.surveyJustCompleted === true;
  const isAuthenticated = status === 'authenticated';
  const subdomain = rootData?.orgConfig.subdomain;

  const showSurveyBanner =
    isAuthenticated && !user?.surveyCompleted && !user?.optOutOfRecommendations;

  const showGetconnectedPromo =
    subdomain === 'getconnected' &&
    isAuthenticated &&
    user?.surveyCompleted === true &&
    Boolean(user?.uuid);

  return (
    <>
      <SubHeaderBanner header={bannerHeader} subheader={bannerSubheader} />
      {showSurveyBanner ? <SurveyBanner /> : null}
      {showGetconnectedPromo && <GetconnectedPromo uuid={user!.uuid!} />}
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

        <CourseListContainer
          title={t('home.featuredCourses')}
          params={{ scope: 'homepage', limit: 10 }}
        />

        <LessonListContainer
          title={t('home.popularLessons')}
          params={{ scope: 'popular', limit: 10 }}
        />
      </Container>
    </>
  );
}

function GetconnectedPromo({ uuid }: { uuid: string }) {
  const { t } = useTranslation();
  const surveyUrl = `${t('home.getconnectedPromo.surveyUrl')}?guest=${uuid}`;

  return (
    <Paper
      elevation={0}
      sx={{
        mx: { xs: 1, sm: 2, md: 3 },
        mt: 2,
        mb: 1,
        p: { xs: 2, sm: 3 },
        border: '1px solid',
        borderColor: 'divider',
        borderRadius: 2,
      }}
    >
      <Typography variant="h6" fontWeight={700} sx={{ mb: 1.5 }}>
        {t('home.getconnectedPromo.heading')}
      </Typography>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
        <Typography variant="body2">{t('home.getconnectedPromo.p1')}</Typography>
        <Typography variant="body2">{t('home.getconnectedPromo.p2')}</Typography>
        <Typography variant="body2">{t('home.getconnectedPromo.p3')}</Typography>
        <Typography variant="body2">{t('home.getconnectedPromo.p4')}</Typography>
      </Box>
      <Button
        component="a"
        href={surveyUrl}
        target="_blank"
        rel="noopener noreferrer"
        variant="contained"
        sx={{ mt: 2 }}
      >
        {t('home.getconnectedPromo.cta')}
      </Button>
    </Paper>
  );
}
