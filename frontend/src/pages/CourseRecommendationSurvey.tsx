import { useEffect, useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';
import RequireAuth from '../auth/RequireAuth';
import { useAuth } from '../auth/useAuth';
import { fetchSurvey, submitSurvey } from '../features/survey/api/surveyApi';
import { SurveyForm } from '../features/survey/components/SurveyForm';
import type { Survey, SurveyResponses } from '../features/survey/types';

function CourseRecommendationSurveyInner() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { user, refresh } = useAuth();
  const [survey, setSurvey] = useState<Survey | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const profileValid = user?.profileValid !== false;

  useEffect(() => {
    if (!profileValid) return;

    const controller = new AbortController();
    fetchSurvey({ signal: controller.signal })
      .then(setSurvey)
      .catch((err: unknown) => {
        if (!controller.signal.aborted) {
          setError(err instanceof Error ? err.message : t('survey.loadError'));
        }
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });
    return () => controller.abort();
  }, [t, profileValid]);

  const handleSubmit = async (responses: SurveyResponses) => {
    await submitSurvey(responses);
    void refresh();
    navigate('/', { state: { surveyJustCompleted: true } });
  };

  const handleSkip = () => navigate('/');

  if (!profileValid) {
    return <Navigate to="/account" replace />;
  }

  return (
    <Container maxWidth="sm" sx={{ py: 4 }}>
      <Typography variant="h4" component="h1" sx={{ mb: 1 }}>
        {t('survey.pageTitle')}
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
        {t('survey.instructions')}
      </Typography>

      {loading && (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 6 }}>
          <CircularProgress />
        </Box>
      )}

      {error && <Alert severity="error">{t('survey.loadError')}</Alert>}

      {!loading && !error && survey && (
        <SurveyForm
          survey={survey}
          onSubmit={handleSubmit}
          onSkip={handleSkip}
        />
      )}
    </Container>
  );
}

export default function CourseRecommendationSurvey() {
  return (
    <RequireAuth>
      <CourseRecommendationSurveyInner />
    </RequireAuth>
  );
}
