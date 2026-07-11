import { useState } from 'react';
import { useNavigate, useRouteLoaderData } from 'react-router-dom';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../../auth/useAuth';
import { dismissSurvey } from '../api/surveyApi';
import { getSurveyPath } from '../surveyNavigation';
import type { OrganizationConfig } from '../../../app/organization/types';

export function SurveyBanner() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { user, refresh } = useAuth();
  const [dismissing, setDismissing] = useState(false);

  const rootData = useRouteLoaderData('org') as { orgConfig: OrganizationConfig } | undefined;
  const surveyRequired = rootData?.orgConfig.features.surveyRequired ?? false;

  const handleDismiss = async () => {
    setDismissing(true);
    try {
      await dismissSurvey();
      await refresh();
    } finally {
      setDismissing(false);
    }
  };

  return (
    <Box
      sx={{
        backgroundColor: (theme) => theme.palette.background.default,
        borderBottom: '1px solid',
        borderColor: 'divider',
        px: { xs: 2, sm: 3 },
        py: { xs: 3, sm: 4 },
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        textAlign: 'center',
        gap: 2,
      }}
    >
      <Typography variant="h4" component="p" sx={{ fontWeight: 700 }}>
        {t('survey.banner.heading')}
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ maxWidth: 560 }}>
        {t('survey.banner.description')}
      </Typography>
      <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', justifyContent: 'center' }}>
        <Button variant="contained" size="large" onClick={() => navigate(getSurveyPath(user))}>
          {t('survey.banner.cta')}
        </Button>
        {!surveyRequired && (
          <Button
            variant="outlined"
            size="large"
            onClick={() => void handleDismiss()}
            disabled={dismissing}
            startIcon={dismissing ? <CircularProgress size={16} color="inherit" /> : undefined}
          >
            {t('survey.banner.notRightNow')}
          </Button>
        )}
      </Box>
    </Box>
  );
}
