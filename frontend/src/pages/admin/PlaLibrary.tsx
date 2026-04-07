import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';

export default function AdminPlaLibrary() {
  const { t } = useTranslation();
  return <Typography variant="h4">{t('admin.plaLibrary')}</Typography>;
}
