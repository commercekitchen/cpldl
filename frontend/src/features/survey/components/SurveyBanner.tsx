import { useNavigate } from 'react-router-dom';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';

export function SurveyBanner() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  return (
    <Box
      sx={{
        backgroundColor: (theme) => theme.palette.secondary.main,
        color: (theme) => theme.palette.secondary.contrastText,
        px: { xs: 2, sm: 3 },
        py: { xs: 2, sm: 2.5 },
        display: 'flex',
        flexDirection: { xs: 'column', sm: 'row' },
        alignItems: { xs: 'flex-start', sm: 'center' },
        gap: 2,
      }}
    >
      <Box sx={{ flex: 1 }}>
        <Typography variant="h6" component="p" sx={{ fontWeight: 700, lineHeight: 1.3 }}>
          {t('survey.banner.heading')}
        </Typography>
        <Typography variant="body2" sx={{ mt: 0.5, opacity: 0.92 }}>
          {t('survey.banner.description')}
        </Typography>
      </Box>
      <Button
        variant="contained"
        color="primary"
        onClick={() => navigate('/survey')}
        sx={{ whiteSpace: 'nowrap', flexShrink: 0 }}
      >
        {t('survey.banner.cta')}
      </Button>
    </Box>
  );
}
