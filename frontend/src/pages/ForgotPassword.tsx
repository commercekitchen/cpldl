import { type FormEvent, useState } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { apiFetch } from '../app/api/apiFetch';

export default function ForgotPassword() {
  const { t } = useTranslation();
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await apiFetch('/api/v1/password_reset', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email }),
      });
      setSubmitted(true);
    } catch {
      setError(t('auth.resetError'));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ py: { xs: 4, sm: 6 } }}>
      <Paper
        elevation={0}
        sx={{
          p: { xs: 3, sm: 4 },
          border: '1px solid',
          borderColor: 'divider',
          borderRadius: 3,
          background:
            'linear-gradient(180deg, rgba(255,255,255,1) 0%, rgba(249,250,251,1) 100%)',
        }}
      >
        <Stack spacing={2.5}>
          <Box>
            <Typography variant="h4" sx={{ mb: 0.75 }}>
              {t('auth.forgotPasswordTitle')}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {t('auth.forgotPasswordSubtitle')}
            </Typography>
          </Box>

          {submitted ? (
            <Alert severity="success" role="status">{t('auth.resetEmailSent')}</Alert>
          ) : (
            <>
              {error ? <Alert severity="error" role="alert">{error}</Alert> : null}

              <Box component="form" onSubmit={onSubmit}>
                <Stack spacing={2}>
                  <TextField
                    label="Email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    autoComplete="email"
                    fullWidth
                    required
                    autoFocus
                  />

                  <Button
                    type="submit"
                    variant="contained"
                    size="large"
                    disabled={submitting}
                    fullWidth
                  >
                    {submitting ? t('auth.sending') : t('auth.sendResetLink')}
                  </Button>
                </Stack>
              </Box>
            </>
          )}

          <Typography variant="body2" color="text.secondary">
            <Button component={Link} to="/login" size="small" variant="text" sx={{ p: 0, minWidth: 0 }}>
              {t('auth.backToLogin')}
            </Button>
          </Typography>
        </Stack>
      </Paper>
    </Container>
  );
}
