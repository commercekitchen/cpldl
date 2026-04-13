import { useParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';

export default function AdminEditLesson() {
  const { courseId } = useParams<{ courseId: string; lessonId: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();

  return (
    <Box sx={{ maxWidth: 800 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate(`/admin/courses/${courseId}/edit`)}
        variant="text"
        color="inherit"
        sx={{ mb: 2 }}
      >
        {t('admin.editLessonPage.backToCourse')}
      </Button>
      <Typography variant="h4" gutterBottom>
        {t('admin.editLessonPage.title')}
      </Typography>
      <Paper variant="outlined" sx={{ p: 3 }}>
        <Typography color="text.secondary">{t('admin.editLessonPage.placeholder')}</Typography>
      </Paper>
    </Box>
  );
}
